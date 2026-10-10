"""
migrate_simple.py - Migration directe SQLite : role 'user' -> 'citoyen'
"""
import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sql_app.db")

print("=" * 60)
print("  MIGRATION : role 'user' -> 'citoyen'")
print("=" * 60)
print(f"\n[DB] Fichier SQLite : {DB_PATH}")

conn = sqlite3.connect(DB_PATH)
cur  = conn.cursor()

# Compter avant
cur.execute("SELECT COUNT(*) FROM users WHERE role = 'user'")
count = cur.fetchone()[0]
print(f"[DB] {count} citoyen(s) avec role='user' trouves.")

if count > 0:
    cur.execute("UPDATE users SET role = 'citoyen' WHERE role = 'user'")
    conn.commit()
    print(f"[DB] OK - {cur.rowcount} enregistrement(s) mis a jour : role 'user' -> 'citoyen'.")
else:
    print("[DB] Rien a migrer (0 enregistrement avec role='user').")

# Verification finale
cur.execute("SELECT role, COUNT(*) FROM users GROUP BY role ORDER BY role")
rows = cur.fetchall()
print("\n[DB] Repartition des roles apres migration :")
for role, cnt in rows:
    print(f"     {role:<20} : {cnt} utilisateur(s)")

conn.close()

print("\n" + "=" * 60)
print("  Migration SQLite terminee avec succes !")
print("=" * 60)
print("\nNOTE : Pour Firebase, relancez le script de synchronisation")
print("       scripts/utils/sync_firebase_complet.py")
print("       pour propager le nouveau role 'citoyen' dans Firebase RTDB.")
