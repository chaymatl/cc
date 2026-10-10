import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

"""
reset_utilisateurs.py
=====================
1. Supprime complètement le nœud /utilisateurs dans Firebase RTDB
2. Re-synchronise tous les utilisateurs avec qr_code comme clé

Exécution :
    cd backend
    python reset_utilisateurs.py
"""
import os, sys

# Racine du projet backend (trois niveaux au-dessus de scripts/utils/)
# scripts/utils/reset_utilisateurs.py -> scripts/utils/ -> scripts/ -> backend/
BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, BACKEND_DIR)

# Fix encodage Windows
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

# Charger .env depuis le dossier backend/
try:
    from dotenv import load_dotenv
    _env_file = os.path.join(BACKEND_DIR, ".env")
    if os.path.exists(_env_file):
        load_dotenv(_env_file)
        print(f"[ENV] .env charge depuis : {_env_file}")
    else:
        print(f"[WARN] .env introuvable a : {_env_file}")
except ImportError:
    # Chargement manuel si python-dotenv absent
    _env_file = os.path.join(BACKEND_DIR, ".env")
    if os.path.exists(_env_file):
        with open(_env_file, encoding="utf-8") as _f:
            for _line in _f:
                _line = _line.strip()
                if _line and not _line.startswith("#") and "=" in _line:
                    _k, _v = _line.split("=", 1)
                    os.environ.setdefault(_k.strip(), _v.strip())
        print("[ENV] .env charge manuellement.")

from services.firebase_service import _init_firebase, sync_user_to_firebase

# db_models importe TOUS les modeles SQLAlchemy (resout toutes les relations ORM)
import db_models  # noqa

from database import SessionLocal
from app.users.models import User

def main():
    print("")
    print("=" * 52)
    print("  EcoRewind - Reset /utilisateurs -> cle QR code")
    print("=" * 52)

    if not _init_firebase():
        print("[ERREUR] Firebase non disponible. Verifiez .env")
        return

    from firebase_admin import db as rtdb

    # ETAPE 1 : Supprimer tout le noeud /utilisateurs
    print("")
    print("[ETAPE 1] Suppression de /utilisateurs (anciens noeuds numeriques)...")
    rtdb.reference("utilisateurs").delete()
    print("[OK] Noeud /utilisateurs supprime.")
    print("")

    # ETAPE 2 : Re-synchroniser avec qr_code comme cle
    print("[ETAPE 2] Re-synchronisation avec qr_code comme cle...")
    db = SessionLocal()
    try:
        users = db.query(User).filter(User.is_active == True).all()
        print(f"  {len(users)} utilisateur(s) trouve(s) dans PostgreSQL.")
        ok = 0
        skip = 0
        err = 0
        for u in users:
            qr    = u.qr_code   or ""
            role  = u.role      or "citoyen"
            name  = u.full_name or ""
            mail  = u.email     or ""
            score = getattr(u, 'global_score', 0) or 0

            if not qr:
                print(f"  [SKIP] User #{u.id} ({mail}) : pas de QR code")
                skip += 1
                continue

            success = sync_user_to_firebase(
                user_id=u.id,
                role=role,
                qr_code=qr,
                full_name=name,
                email=mail,
                score=score,
            )
            if success:
                ok += 1
                extra = f", score={score}" if role == 'citoyen' else ""
                print(f"  [OK] {qr[:40]}  role={role}{extra}")
            else:
                err += 1
                print(f"  [ERR] User #{u.id} ({mail})")
    finally:
        db.close()

    print("")
    print("=" * 52)
    print(f"  OK={ok}  Erreurs={err}  Ignores={skip}")
    print("  Synchronisation Firebase terminee !")
    print("=" * 52)
    print("")

if __name__ == "__main__":
    main()
