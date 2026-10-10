"""
migrate_pg.py - Migration PostgreSQL : role 'user' -> 'citoyen'
Lance depuis le dossier backend/ :
    python scripts/migrate_pg.py
"""
import os
import sys

# Charger .env manuellement
env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env")
if os.path.exists(env_path):
    with open(env_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())

DATABASE_URL = os.environ.get("DATABASE_URL", "")

if not DATABASE_URL or "postgresql" not in DATABASE_URL:
    print("[ERR] DATABASE_URL PostgreSQL introuvable dans .env")
    print(f"      Valeur : {DATABASE_URL!r}")
    sys.exit(1)

try:
    import psycopg2
except ImportError:
    print("[ERR] psycopg2 non installe. Lancez : pip install psycopg2-binary")
    sys.exit(1)

# Convertir postgres:// -> postgresql:// si besoin
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Connexion
print("=" * 60)
print("  MIGRATION PostgreSQL : role 'user' -> 'citoyen'")
print("=" * 60)
print(f"\n[PG] Connexion : {DATABASE_URL.split('@')[-1] if '@' in DATABASE_URL else DATABASE_URL}")

try:
    conn = psycopg2.connect(DATABASE_URL)
    conn.autocommit = False
    cur = conn.cursor()
    print("[PG] Connexion reussie.\n")
except Exception as e:
    print(f"[ERR] Impossible de se connecter a PostgreSQL : {e}")
    sys.exit(1)

try:
    # 1. Compter avant
    cur.execute("SELECT COUNT(*) FROM users WHERE role = 'user'")
    count = cur.fetchone()[0]
    print(f"[PG] {count} enregistrement(s) avec role='user' trouve(s).")

    if count > 0:
        # 2. Mise a jour
        cur.execute("UPDATE users SET role = 'citoyen' WHERE role = 'user'")
        updated = cur.rowcount
        conn.commit()
        print(f"[PG] OK - {updated} enregistrement(s) mis a jour : role 'user' -> 'citoyen'.")
    else:
        print("[PG] Rien a migrer (deja a jour ou table vide).")
        conn.commit()

    # 3. Verification finale
    cur.execute("SELECT role, COUNT(*) FROM users GROUP BY role ORDER BY role")
    rows = cur.fetchall()
    print("\n[PG] Repartition des roles apres migration :")
    for role, cnt in rows:
        marker = " <-- migre" if role == "citoyen" else ""
        print(f"     {str(role):<20} : {cnt} utilisateur(s){marker}")

    print("\n" + "=" * 60)
    print("  Migration PostgreSQL terminee avec succes !")
    print("=" * 60)

except Exception as e:
    conn.rollback()
    print(f"[ERR] Erreur lors de la migration : {e}")
    sys.exit(1)
finally:
    cur.close()
    conn.close()
