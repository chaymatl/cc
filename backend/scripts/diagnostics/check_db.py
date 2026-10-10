"""
scripts/diagnostics/check_db.py - Verification de la base de données PostgreSQL
"""
import os, sys

# Charger .env depuis backend/
_backend = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, _backend)
_env = os.path.join(_backend, ".env")
if os.path.exists(_env):
    try:
        from dotenv import load_dotenv
        load_dotenv(_env)
    except ImportError:
        with open(_env, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    os.environ.setdefault(k.strip(), v.strip())

import psycopg2

DATABASE_URL = os.environ.get("DATABASE_URL", "")
if not DATABASE_URL:
    print("[ERR] DATABASE_URL non défini dans .env")
    sys.exit(1)

try:
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    cur.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename")
    tables = [row[0] for row in cur.fetchall()]
    print(f"[OK] PostgreSQL connecte - {len(tables)} table(s) :")
    for t in tables:
        cur.execute(f"SELECT COUNT(*) FROM {t}")
        count = cur.fetchone()[0]
        print(f"  {t:<35} {count:>6} ligne(s)")
    conn.close()
except Exception as e:
    print(f"[ERR] Connexion PostgreSQL echouee : {e}")
    sys.exit(1)
