"""
check_pg.py — Vérification de l'état de la base PostgreSQL
"""
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

import psycopg2

PG_URL = "postgresql://postgres@localhost:5432/ecorewind"

try:
    pg = psycopg2.connect(PG_URL)
    pg.autocommit = True
    c = pg.cursor()
    print("[OK] Connexion PostgreSQL reussie !\n")
    
    tables = [
        'users', 'posts', 'comments', 'likes', 'notifications',
        'collection_points', 'quizzes', 'quiz_submissions',
        'educator_videos', 'video_categories', 'testimonials',
        'center_proposals'
    ]
    
    total = 0
    for t in tables:
        try:
            c.execute(f"SELECT COUNT(*) FROM {t}")
            n = c.fetchone()[0]
            total += n
            status = "OK" if n > 0 else "vide"
            print(f"  [{status}] {t}: {n} lignes")
        except Exception as e:
            print(f"  [ERR] {t}: {e}")
    
    print(f"\n  Total : {total} lignes dans PostgreSQL")
    pg.close()

except Exception as e:
    print(f"[ERREUR] Impossible de se connecter : {e}")
    print("\nVeuillez verifier que PostgreSQL est demarre.")
