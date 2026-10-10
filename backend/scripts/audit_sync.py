"""
audit_sync.py - Audit complet PostgreSQL <-> Firebase RTDB
============================================================
Verifie :
  1. Connexion PostgreSQL
  2. Connexion Firebase RTDB
  3. Roles : tous 'citoyen' (plus de 'user')
  4. Synchronisation utilisateurs PG <-> Firebase /utilisateurs
  5. Synchronisation scores PG <-> Firebase /scores
  6. Coherence des donnees (QR codes, roles, scores)

Usage :
    cd backend
    python scripts/audit_sync.py
"""

import os, sys

# ── Chemin backend ─────────────────────────────────────────────────────────────
BACKEND = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BACKEND)

# Fix encodage Windows
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

# ── Charger .env ───────────────────────────────────────────────────────────────
_env_file = os.path.join(BACKEND, ".env")
try:
    from dotenv import load_dotenv
    load_dotenv(_env_file)
except ImportError:
    if os.path.exists(_env_file):
        with open(_env_file, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    os.environ.setdefault(k.strip(), v.strip())

import psycopg2
from collections import defaultdict

# ────────────────────────────────────────────────────────────────────────────────
# COULEURS CONSOLE
# ────────────────────────────────────────────────────────────────────────────────
OK    = "[OK]"
WARN  = "[WARN]"
ERR   = "[ERR]"
INFO  = "[INFO]"
SEP   = "=" * 65
SEP2  = "-" * 65

errors   = []
warnings = []
passed   = 0

def ok(msg):
    global passed
    passed += 1
    print(f"  {OK}   {msg}")

def warn(msg):
    warnings.append(msg)
    print(f"  {WARN} {msg}")

def err(msg):
    errors.append(msg)
    print(f"  {ERR}  {msg}")

def section(title):
    print(f"\n{SEP}")
    print(f"  {title}")
    print(SEP)

def sub(title):
    print(f"\n  {SEP2}")
    print(f"  {title}")
    print(f"  {SEP2}")

# ────────────────────────────────────────────────────────────────────────────────
# 1. CONNEXION POSTGRESQL
# ────────────────────────────────────────────────────────────────────────────────
section("1. CONNEXION POSTGRESQL")

DATABASE_URL = os.environ.get("DATABASE_URL", "")
pg_conn = None

if not DATABASE_URL:
    err("DATABASE_URL non defini dans .env")
    sys.exit(1)

try:
    pg_conn = psycopg2.connect(DATABASE_URL)
    pg_conn.autocommit = True
    cur = pg_conn.cursor()
    cur.execute("SELECT version()")
    version = cur.fetchone()[0]
    ok(f"Connexion PostgreSQL etablie")
    ok(f"Version : {version[:60]}")
except Exception as e:
    err(f"Connexion PostgreSQL echouee : {e}")
    sys.exit(1)

# Tables existantes
cur.execute("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename")
pg_tables = [r[0] for r in cur.fetchall()]
ok(f"{len(pg_tables)} table(s) trouvee(s) dans PostgreSQL")

# Verifier table users
if "users" not in pg_tables:
    err("Table 'users' absente de PostgreSQL !")
else:
    ok("Table 'users' presente")

# ────────────────────────────────────────────────────────────────────────────────
# 2. DONNEES UTILISATEURS POSTGRESQL
# ────────────────────────────────────────────────────────────────────────────────
section("2. UTILISATEURS POSTGRESQL")

cur.execute("SELECT id, email, full_name, role, qr_code, global_score, is_active FROM users ORDER BY id")
pg_users = cur.fetchall()

ok(f"{len(pg_users)} utilisateur(s) en base")

# Roles
roles_count = defaultdict(int)
pg_citizens = []
pg_users_by_qr = {}

for uid, email, name, role, qr, score, active in pg_users:
    roles_count[role or "NULL"] += 1
    if role == "citoyen":
        pg_citizens.append((uid, email, name, qr, score or 0.0, active))
    if qr:
        pg_users_by_qr[qr] = {
            "id": uid, "email": email, "name": name,
            "role": role, "score": score or 0.0, "active": active
        }

sub("Repartition des roles")
for role, count in sorted(roles_count.items()):
    marker = " <-- OK (migre)" if role == "citoyen" else (" <-- ERREUR ancien role!" if role == "user" else "")
    print(f"    {role:<25} : {count}{marker}")

if roles_count.get("user", 0) > 0:
    err(f"{roles_count['user']} utilisateur(s) ont encore role='user' (non migre !)")
else:
    ok("Aucun utilisateur avec role='user' (migration complete)")

if roles_count.get("citoyen", 0) > 0:
    ok(f"{roles_count['citoyen']} citoyen(s) avec role='citoyen'")

# QR codes manquants
no_qr = [(uid, email) for uid, email, name, role, qr, score, active in pg_users if not qr]
if no_qr:
    warn(f"{len(no_qr)} utilisateur(s) sans QR code (non synchronisables avec Firebase) :")
    for uid, email in no_qr[:5]:
        print(f"    - ID {uid} : {email}")
else:
    ok("Tous les utilisateurs ont un QR code")

# Scores
cur.execute("SELECT COUNT(*), SUM(global_score), MAX(global_score) FROM users WHERE role='citoyen' AND global_score > 0")
score_stats = cur.fetchone()
if score_stats[0]:
    ok(f"{score_stats[0]} citoyen(s) avec score > 0 | Total={score_stats[1]:.1f} | Max={score_stats[2]:.1f}")

# ────────────────────────────────────────────────────────────────────────────────
# 3. CONNEXION FIREBASE RTDB
# ────────────────────────────────────────────────────────────────────────────────
section("3. CONNEXION FIREBASE RTDB")

from services.firebase_service import _init_firebase

fb_ok = _init_firebase()
if not fb_ok:
    err("Firebase RTDB non disponible - verifiez FIREBASE_CREDENTIALS_PATH et FIREBASE_DATABASE_URL dans .env")
    print("\n[RESULTAT] Audit partiel - Firebase inaccessible.")
    sys.exit(1)
else:
    ok("Firebase RTDB initialise avec succes")
    ok(f"URL : {os.environ.get('FIREBASE_DATABASE_URL', 'N/A')}")

from firebase_admin import db as rtdb

# ────────────────────────────────────────────────────────────────────────────────
# 4. DONNEES FIREBASE /utilisateurs
# ────────────────────────────────────────────────────────────────────────────────
section("4. NOEUD FIREBASE /utilisateurs")

fb_utilisateurs = rtdb.reference("utilisateurs").get() or {}
ok(f"{len(fb_utilisateurs)} noeud(s) dans /utilisateurs")

fb_roles = defaultdict(int)
fb_by_qr = {}
fb_score_mismatches = []
fb_role_mismatches  = []
fb_extra_nodes      = []  # dans Firebase mais pas dans PG
fb_missing_nodes    = []  # dans PG mais pas dans Firebase

for qr, data in fb_utilisateurs.items():
    if not isinstance(data, dict):
        warn(f"Noeud /utilisateurs/{qr} invalide (pas un dict) : {data}")
        continue
    role = data.get("role", "NULL")
    fb_roles[role] += 1
    fb_by_qr[qr] = data

sub("Repartition des roles dans Firebase")
for role, count in sorted(fb_roles.items()):
    marker = " <-- OK" if role == "citoyen" else (" <-- ERREUR ancien role!" if role == "user" else "")
    print(f"    {role:<25} : {count}{marker}")

if fb_roles.get("user", 0) > 0:
    err(f"{fb_roles['user']} noeud(s) Firebase ont encore role='user' (resync necessaire !)")
else:
    ok("Aucun noeud Firebase avec role='user'")

# ────────────────────────────────────────────────────────────────────────────────
# 5. SYNCHRONISATION PG <-> FIREBASE
# ────────────────────────────────────────────────────────────────────────────────
section("5. SYNCHRONISATION PG <-> FIREBASE /utilisateurs")

# Utilisateurs dans PG avec QR mais absents de Firebase
for qr, pg_data in pg_users_by_qr.items():
    if qr not in fb_by_qr:
        fb_missing_nodes.append((qr, pg_data))

# Noeuds Firebase sans correspondance dans PG
for qr, fb_data in fb_by_qr.items():
    if qr not in pg_users_by_qr:
        fb_extra_nodes.append((qr, fb_data))

# Divergences de roles et scores
for qr, pg_data in pg_users_by_qr.items():
    if qr not in fb_by_qr:
        continue
    fb_data = fb_by_qr[qr]

    # Role
    pg_role = pg_data["role"] or ""
    fb_role = fb_data.get("role", "")
    if pg_role != fb_role:
        fb_role_mismatches.append({
            "qr": qr, "name": pg_data["name"],
            "pg_role": pg_role, "fb_role": fb_role
        })

    # Score (seulement pour les citoyens)
    if pg_role == "citoyen":
        pg_score = round(float(pg_data["score"] or 0), 2)
        fb_score = round(float(fb_data.get("score", 0) or 0), 2)
        diff = abs(pg_score - fb_score)
        if diff > 0.5:
            fb_score_mismatches.append({
                "qr": qr, "name": pg_data["name"],
                "pg_score": pg_score, "fb_score": fb_score, "diff": diff
            })

sub("Utilisateurs PG absents de Firebase")
if fb_missing_nodes:
    warn(f"{len(fb_missing_nodes)} utilisateur(s) PG non synchronises dans Firebase :")
    for qr, d in fb_missing_nodes[:10]:
        print(f"    - {qr[:45]} | {d['name']} | role={d['role']}")
else:
    ok("Tous les utilisateurs PG (avec QR) sont dans Firebase")

sub("Noeuds Firebase sans correspondance PG")
if fb_extra_nodes:
    warn(f"{len(fb_extra_nodes)} noeud(s) Firebase sans correspondance en base :")
    for qr, d in fb_extra_nodes[:10]:
        print(f"    - {qr[:45]} | role={d.get('role','?')}")
else:
    ok("Tous les noeuds Firebase correspondent a un utilisateur PG")

sub("Divergences de roles PG <-> Firebase")
if fb_role_mismatches:
    err(f"{len(fb_role_mismatches)} divergence(s) de role :")
    for m in fb_role_mismatches:
        print(f"    - {m['name']:<25} | PG={m['pg_role']:<15} | FB={m['fb_role']}")
else:
    ok("Roles identiques entre PG et Firebase pour tous les utilisateurs")

sub("Divergences de scores citoyens PG <-> Firebase")
if fb_score_mismatches:
    warn(f"{len(fb_score_mismatches)} divergence(s) de score (diff > 0.5 pt) :")
    for m in sorted(fb_score_mismatches, key=lambda x: x['diff'], reverse=True)[:10]:
        print(f"    - {m['name']:<25} | PG={m['pg_score']:<8} | FB={m['fb_score']:<8} | diff={m['diff']:.1f}")
else:
    ok("Scores identiques entre PG et Firebase pour tous les citoyens")

# ────────────────────────────────────────────────────────────────────────────────
# 6. NOEUD FIREBASE /scores
# ────────────────────────────────────────────────────────────────────────────────
section("6. NOEUD FIREBASE /scores")

fb_scores = rtdb.reference("scores").get() or {}
ok(f"{len(fb_scores)} entree(s) dans /scores")

score_node_issues = []
for user_id_str, score_data in fb_scores.items():
    if not isinstance(score_data, dict):
        continue
    total = score_data.get("total", 0)
    # Verifier si l'utilisateur existe en PG
    cur.execute("SELECT id, email, global_score, role FROM users WHERE id = %s", (int(user_id_str),))
    pg_row = cur.fetchone()
    if not pg_row:
        score_node_issues.append(f"ID {user_id_str} dans /scores mais absent de PostgreSQL")
    else:
        pg_score = round(float(pg_row[2] or 0), 2)
        fb_total = round(float(total or 0), 2)
        if abs(pg_score - fb_total) > 0.5:
            score_node_issues.append(
                f"ID {user_id_str} ({pg_row[1]}) : PG={pg_score} | /scores={fb_total} | diff={abs(pg_score-fb_total):.1f}"
            )

if score_node_issues:
    warn(f"{len(score_node_issues)} divergence(s) dans /scores :")
    for issue in score_node_issues[:10]:
        print(f"    - {issue}")
else:
    ok("Scores /scores coherents avec PostgreSQL")

# ────────────────────────────────────────────────────────────────────────────────
# 7. NOEUD FIREBASE /poubelles
# ────────────────────────────────────────────────────────────────────────────────
section("7. NOEUD FIREBASE /poubelles (Smart Bins)")

fb_poubelles = rtdb.reference("poubelles").get() or {}
ok(f"{len(fb_poubelles)} poubelle(s) dans /poubelles")

if "smart_bins" in pg_tables:
    cur.execute("SELECT bin_code, bin_type, status FROM smart_bins")
    pg_bins = {row[0]: {"type": row[1], "status": row[2]} for row in cur.fetchall()}
    ok(f"{len(pg_bins)} smart bin(s) actif(s) en PostgreSQL")

    bins_missing_fb = [bc for bc in pg_bins if bc not in fb_poubelles]
    bins_extra_fb   = [bc for bc in fb_poubelles if bc not in pg_bins]

    if bins_missing_fb:
        warn(f"{len(bins_missing_fb)} bin(s) PG absents de Firebase : {bins_missing_fb[:5]}")
    else:
        ok("Tous les smart bins PG sont dans /poubelles Firebase")

    if bins_extra_fb:
        warn(f"{len(bins_extra_fb)} bin(s) Firebase sans correspondance PG : {bins_extra_fb[:5]}")
    else:
        ok("Tous les noeuds /poubelles ont un correspondant en PG")

# ────────────────────────────────────────────────────────────────────────────────
# 8. NOEUD FIREBASE /leaderboard
# ────────────────────────────────────────────────────────────────────────────────
section("8. NOEUD FIREBASE /leaderboard")

fb_leaderboard = rtdb.reference("leaderboard").get() or {}
ok(f"{len(fb_leaderboard)} entree(s) dans /leaderboard")

if fb_leaderboard:
    # Top 3
    top = sorted(fb_leaderboard.values(), key=lambda x: x.get("global_score", 0) if isinstance(x, dict) else 0, reverse=True)[:3]
    print("  Top 3 leaderboard Firebase :")
    for i, entry in enumerate(top):
        if isinstance(entry, dict):
            print(f"    #{i+1} {entry.get('full_name','?'):<25} score={entry.get('global_score', 0):.1f}")

# ────────────────────────────────────────────────────────────────────────────────
# 9. VERIFICATION LOGIQUE METIER
# ────────────────────────────────────────────────────────────────────────────────
section("9. COHERENCE LOGIQUE METIER")

# Verifier bin_scans
if "bin_scans" in pg_tables:
    cur.execute("SELECT COUNT(*) FROM bin_scans")
    scan_count = cur.fetchone()[0]
    ok(f"{scan_count} scan(s) dans bin_scans")

    # Scans par des non-citoyens (probleme potentiel)
    cur.execute("""
        SELECT COUNT(*) FROM bin_scans bs
        JOIN users u ON bs.user_id = u.id
        WHERE u.role != 'citoyen'
    """)
    bad_scans = cur.fetchone()[0]
    if bad_scans > 0:
        warn(f"{bad_scans} scan(s) effectue(s) par des non-citoyens")
    else:
        ok("Tous les scans sont associes a des citoyens")

# Quiz submissions
if "quiz_submissions" in pg_tables:
    cur.execute("SELECT COUNT(*) FROM quiz_submissions")
    quiz_count = cur.fetchone()[0]
    ok(f"{quiz_count} soumission(s) de quiz en base")

# Posts
if "posts" in pg_tables:
    cur.execute("SELECT status, COUNT(*) FROM posts GROUP BY status")
    posts_by_status = {r[0]: r[1] for r in cur.fetchall()}
    total_posts = sum(posts_by_status.values())
    ok(f"{total_posts} post(s) : " + " | ".join(f"{s}={c}" for s, c in posts_by_status.items()))

# ────────────────────────────────────────────────────────────────────────────────
# RAPPORT FINAL
# ────────────────────────────────────────────────────────────────────────────────
section("RAPPORT FINAL")

total = passed + len(warnings) + len(errors)
print(f"\n  Tests passes  : {passed}")
print(f"  Avertissements: {len(warnings)}")
print(f"  Erreurs       : {len(errors)}")

if errors:
    print(f"\n  {SEP2}")
    print(f"  ERREURS CRITIQUES ({len(errors)}) :")
    for i, e in enumerate(errors, 1):
        print(f"    {i}. {e}")

if warnings:
    print(f"\n  {SEP2}")
    print(f"  AVERTISSEMENTS ({len(warnings)}) :")
    for i, w in enumerate(warnings, 1):
        print(f"    {i}. {w}")

print(f"\n{SEP}")
if not errors and not warnings:
    print("  RESULTAT : TOUT EST CORRECT - PG <-> Firebase synchronises")
elif not errors:
    print(f"  RESULTAT : SYSTEME FONCTIONNEL avec {len(warnings)} avertissement(s) mineurs")
else:
    print(f"  RESULTAT : {len(errors)} ERREUR(S) CRITIQUE(S) A CORRIGER")
print(f"{SEP}\n")

pg_conn.close()
