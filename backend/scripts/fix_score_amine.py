"""
fix_score_amine.py - Correction du score /scores pour Amine T.
PG = 1827.0  |  Firebase /scores = 888.0  -> mise a jour Firebase
"""
import os, sys
BACKEND = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BACKEND)
from dotenv import load_dotenv
load_dotenv(os.path.join(BACKEND, ".env"))

from services.firebase_service import _init_firebase

if not _init_firebase():
    print("[ERR] Firebase non disponible")
    sys.exit(1)

from firebase_admin import db as rtdb

user_id   = 16
pg_score  = 1827.0
user_name = "Amine T."
qr_code   = "TRIDECHET-8804aea0-0308-42a8-983d-e9edefcad4e4"

ref_scores = rtdb.reference(f"scores/{user_id}")
ref_scores.update({"total": pg_score})
print(f"[OK] /scores/{user_id}/total mis a jour : {pg_score}")

ref_user = rtdb.reference(f"utilisateurs/{qr_code}")
ref_user.update({"score": pg_score})
print(f"[OK] /utilisateurs/{qr_code}/score mis a jour : {pg_score}")

print(f"\n[OK] Score de {user_name} corrige : 888.0 -> {pg_score} dans Firebase RTDB")
