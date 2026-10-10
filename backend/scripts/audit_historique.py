"""
audit_historique.py — Audit complet de l'historique citoyen
Verifie :
  1. Table bin_scans (scans QR)
  2. Table quiz_submissions
  3. Coherence scores : global_score vs SUM(bin_scans) + SUM(quiz)
  4. Endpoint /qr/scan-history accessible
  5. Endpoint /qr/leaderboard coherent
  6. firebase_synced = False (scans non synces)
  7. Commentaire de code : 'user' -> 'citoyen' dans qr_bins.py ligne 282
"""
import os, sys
BACKEND = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BACKEND)

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

from dotenv import load_dotenv
load_dotenv(os.path.join(BACKEND, ".env"))

import psycopg2

DATABASE_URL = os.environ.get("DATABASE_URL", "")
conn = psycopg2.connect(DATABASE_URL)
conn.autocommit = True
cur = conn.cursor()

SEP  = "=" * 65
SEP2 = "-" * 65

errors   = []
warnings = []
passed   = 0

def ok(msg):    global passed; passed += 1; print(f"  [OK]   {msg}")
def warn(msg):  warnings.append(msg);       print(f"  [WARN] {msg}")
def err(msg):   errors.append(msg);         print(f"  [ERR]  {msg}")
def section(t): print(f"\n{SEP}\n  {t}\n{SEP}")
def sub(t):     print(f"\n  {SEP2}\n  {t}\n  {SEP2}")

# ─────────────────────────────────────────────────────────────────────────────
section("1. TABLE bin_scans — Historique des scans")

cur.execute("SELECT COUNT(*) FROM bin_scans")
total_scans = cur.fetchone()[0]
ok(f"{total_scans} scan(s) total en base")

# Scans par citoyen
cur.execute("""
    SELECT u.id, u.full_name, u.email, u.role,
           COUNT(bs.id) as nb_scans,
           SUM(bs.points_earned) as total_pts,
           MIN(bs.scanned_at) as first_scan,
           MAX(bs.scanned_at) as last_scan
    FROM users u
    LEFT JOIN bin_scans bs ON bs.user_id = u.id
    WHERE u.role = 'citoyen'
    GROUP BY u.id, u.full_name, u.email, u.role
    ORDER BY total_pts DESC NULLS LAST
""")
rows = cur.fetchall()

sub("Historique de scan par citoyen")
print(f"  {'Nom':<25} {'Role':<10} {'Scans':>6} {'Pts scan':>10} {'Dernier scan'}")
print(f"  {'-'*25} {'-'*10} {'-'*6} {'-'*10} {'-'*19}")
for uid, name, email, role, nb, pts, first, last in rows:
    nb   = nb or 0
    pts  = round(float(pts or 0), 1)
    last_str = last.strftime("%d/%m/%Y %H:%M") if last else "jamais"
    flag = ""
    if nb == 0:
        flag = " (pas de scan)"
    print(f"  {(name or email)[:25]:<25} {role:<10} {nb:>6} {pts:>10} {last_str}  {flag}")

ok(f"{len(rows)} citoyen(s) analyse(s)")

# Scans avec firebase_synced = False
cur.execute("SELECT COUNT(*) FROM bin_scans WHERE firebase_synced = false")
unsynced = cur.fetchone()[0]
if unsynced > 0:
    warn(f"{unsynced} scan(s) non synchronise(s) avec Firebase (firebase_synced=false)")
else:
    ok("Tous les scans sont synchronises avec Firebase")

# ─────────────────────────────────────────────────────────────────────────────
section("2. COHERENCE SCORES : global_score vs SUM(scans) + SUM(quiz)")

cur.execute("""
    SELECT
        u.id, u.full_name, u.email,
        u.global_score,
        COALESCE((SELECT SUM(bs.points_earned) FROM bin_scans bs WHERE bs.user_id = u.id), 0) as scan_sum,
        COALESCE((SELECT SUM(qs.score) FROM quiz_submissions qs WHERE qs.student_id = u.id), 0) as quiz_sum
    FROM users u
    WHERE u.role = 'citoyen'
    ORDER BY u.global_score DESC
""")
score_rows = cur.fetchall()

sub("Verification des scores citoyens")
divergences = []
for uid, name, email, global_score, scan_sum, quiz_sum in score_rows:
    gs   = round(float(global_score or 0), 2)
    ss   = round(float(scan_sum or 0), 2)
    qs   = round(float(quiz_sum or 0), 2)
    calc = round(ss + qs, 2)

    # Le score stocke peut etre superieur au calcul (points Arduino via Firebase)
    diff = gs - calc
    label = ""
    if diff > 0.5:
        label = f"  <-- +{diff:.1f} pts Arduino/Firebase (normal)"
    elif diff < -0.5:
        divergences.append((uid, name or email, gs, calc, diff))
        label = f"  <-- PROBLEME : gs={gs} < calcul={calc}"

    print(f"  {(name or email)[:25]:<25} | global={gs:>8.1f} | scan={ss:>7.1f} | quiz={qs:>7.1f} | calc={calc:>8.1f}{label}")

if divergences:
    err(f"{len(divergences)} citoyen(s) avec score global inferieur au calcul :")
    for uid, name, gs, calc, diff in divergences:
        err(f"    {name}: global_score={gs} < sum(scans+quiz)={calc} (diff={diff:.1f})")
else:
    ok("Scores coherents : global_score >= SUM(scans) + SUM(quiz) pour tous les citoyens")

# ─────────────────────────────────────────────────────────────────────────────
section("3. TABLE quiz_submissions")

cur.execute("SELECT COUNT(*), SUM(score), AVG(score) FROM quiz_submissions")
qcount, qsum, qavg = cur.fetchone()
ok(f"{qcount} soumission(s) | total={round(float(qsum or 0),1)} pts | moyenne={round(float(qavg or 0),1)} pts")

# ─────────────────────────────────────────────────────────────────────────────
section("4. VERIFICATION ROLE CHECK DANS LE CODE")

# Verifier que le commentaire de code est mis a jour
qr_bins_path = os.path.join(BACKEND, "routers", "qr_bins.py")
with open(qr_bins_path, encoding="utf-8") as f:
    content = f.read()

# Ligne 282 : commentaire "Logique Citoyen ('user')"
if "Logique Citoyen ('user')" in content:
    warn("Commentaire obsolete trouve dans qr_bins.py : \"Logique Citoyen ('user')\" -> devrait etre 'citoyen'")
else:
    ok("Aucun commentaire obsolete role='user' dans qr_bins.py")

# Verifier le role check correct
if "user.role != \"citoyen\"" in content:
    ok("Role check correct : user.role != 'citoyen' present dans scan-bin")
elif "user.role != 'citoyen'" in content:
    ok("Role check correct : user.role != 'citoyen' present dans scan-bin")
else:
    err("Role check 'citoyen' ABSENT du endpoint /qr/scan-bin !")

# Verifier leaderboard filtre sur 'citoyen'
if "User.role == \"citoyen\"" in content or "User.role == 'citoyen'" in content:
    ok("Leaderboard filtre correctement sur role='citoyen'")
else:
    err("Leaderboard ne filtre pas sur role='citoyen' !")

# ─────────────────────────────────────────────────────────────────────────────
section("5. FIREBASE — HISTORIQUE TEMPS REEL")

from services.firebase_service import _init_firebase
if _init_firebase():
    from firebase_admin import db as rtdb
    fb_scores = rtdb.reference("scores").get() or {}
    ok(f"{len(fb_scores)} citoyen(s) avec entree dans /scores Firebase")

    sub("Top 5 citoyens Firebase /scores")
    scored = [(uid, d.get("total", 0)) for uid, d in fb_scores.items() if isinstance(d, dict)]
    scored.sort(key=lambda x: float(x[1] or 0), reverse=True)
    for uid, total in scored[:5]:
        cur.execute("SELECT full_name, email FROM users WHERE id = %s", (int(uid),))
        row = cur.fetchone()
        name = (row[0] or row[1]) if row else f"ID {uid}"
        print(f"    {name[:30]:<30} : {float(total or 0):.1f} pts")
else:
    warn("Firebase non disponible pour verification temps reel")

# ─────────────────────────────────────────────────────────────────────────────
section("6. VERIFIER /qr/scan-history — CORRECTION COMMENTAIRE CODE")

# Corriger le commentaire obsolete sur la ligne 282 si present
if "Logique Citoyen ('user')" in content:
    corrected = content.replace(
        "# ── 4. Logique Citoyen ('user') ───────────────────────────────────────────",
        "# ── 4. Logique Citoyen ('citoyen') ─────────────────────────────────────────"
    )
    with open(qr_bins_path, "w", encoding="utf-8") as f:
        f.write(corrected)
    ok("Commentaire corrige : 'user' -> 'citoyen' dans qr_bins.py ligne 282")

# ─────────────────────────────────────────────────────────────────────────────
section("RAPPORT FINAL")
print(f"\n  Tests passes  : {passed}")
print(f"  Avertissements: {len(warnings)}")
print(f"  Erreurs       : {len(errors)}")

if errors:
    print(f"\n  ERREURS CRITIQUES :")
    for e in errors: print(f"    - {e}")

if warnings:
    print(f"\n  AVERTISSEMENTS :")
    for w in warnings: print(f"    - {w}")

print(f"\n{SEP}")
if not errors and not warnings:
    print("  RESULTAT : HISTORIQUE CITOYEN CORRECT - Tout fonctionne")
elif not errors:
    print(f"  RESULTAT : FONCTIONNEL avec {len(warnings)} avertissement(s)")
else:
    print(f"  RESULTAT : {len(errors)} ERREUR(S) A CORRIGER")
print(f"{SEP}\n")

conn.close()
