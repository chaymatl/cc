"""
migrate_role_user_to_citoyen.py
═══════════════════════════════
Migration : renomme le rôle 'user' → 'citoyen' dans :
  1. La base de données PostgreSQL (table users)
  2. Firebase RTDB (nœuds /utilisateurs/{qr}/role)

Usage :
  cd backend
  python scripts/migrate_role_user_to_citoyen.py
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import SessionLocal
from app.users.models import User

# ─── 1. MIGRATION BASE DE DONNÉES ───────────────────────────────────────────

def migrate_db():
    db = SessionLocal()
    try:
        users = db.query(User).filter(User.role == "user").all()
        count = len(users)
        print(f"\n[DB] {count} utilisateur(s) avec role='user' trouvé(s).")
        if count == 0:
            print("[DB] ✅ Rien à migrer en base de données.")
            return
        for u in users:
            u.role = "citoyen"
        db.commit()
        print(f"[DB] ✅ {count} utilisateur(s) migré(s) : role 'user' → 'citoyen'.")
    except Exception as e:
        db.rollback()
        print(f"[DB] ❌ Erreur lors de la migration DB : {e}")
        raise
    finally:
        db.close()

# ─── 2. MIGRATION FIREBASE RTDB ─────────────────────────────────────────────

def migrate_firebase():
    try:
        from services.firebase_service import _init_firebase
        if not _init_firebase():
            print("[Firebase] ⚠️  Impossible d'initialiser Firebase. Migration Firebase ignorée.")
            return

        from firebase_admin import db as rtdb
        ref = rtdb.reference("utilisateurs")
        all_users = ref.get()

        if not all_users:
            print("[Firebase] ✅ Aucun nœud /utilisateurs trouvé. Rien à migrer.")
            return

        migrated = 0
        skipped = 0
        for qr_code, data in all_users.items():
            if not isinstance(data, dict):
                continue
            if data.get("role") == "user":
                rtdb.reference(f"utilisateurs/{qr_code}/role").set("citoyen")
                migrated += 1
            else:
                skipped += 1

        print(f"[Firebase] ✅ {migrated} nœud(s) migré(s) : role 'user' → 'citoyen'. ({skipped} ignoré(s))")
    except ImportError as e:
        print(f"[Firebase] ⚠️  Module Firebase non disponible : {e}. Migration Firebase ignorée.")
    except Exception as e:
        print(f"[Firebase] ❌ Erreur lors de la migration Firebase : {e}")
        raise

# ─── MAIN ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  MIGRATION : role 'user' -> 'citoyen'")
    print("=" * 60)

    print("\n-- Etape 1 : Base de donnees --")
    migrate_db()

    print("\n-- Etape 2 : Firebase RTDB --")
    migrate_firebase()

    print("\n" + "=" * 60)
    print("  Migration terminee.")
    print("=" * 60)
