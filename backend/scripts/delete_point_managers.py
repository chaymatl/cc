"""Script robuste de suppression des pointManager avec SAVEPOINT."""
import sys, os, re
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import psycopg2

# Connexion sans mot de passe (trust/ident local)
CONN_PARAMS = dict(host="localhost", port=5432, user="postgres", dbname="ecorewind")

conn = psycopg2.connect(**CONN_PARAMS)
conn.autocommit = False
cur = conn.cursor()

try:
    cur.execute("SELECT id, email FROM users WHERE role = 'pointManager'")
    rows = cur.fetchall()
    if not rows:
        print("Aucun utilisateur pointManager. Rien a faire.")
        conn.close()
        sys.exit(0)

    ids = [r[0] for r in rows]
    id_ph = ",".join(str(i) for i in ids)
    print(f"Utilisateurs a supprimer: {[(r[0], r[1]) for r in rows]}")

    steps = [
        ("notifications",           f"DELETE FROM notifications WHERE user_id IN ({id_ph})"),
        ("scans",                   f"DELETE FROM scans WHERE user_id IN ({id_ph})"),
        ("user_badges",             f"DELETE FROM user_badges WHERE user_id IN ({id_ph})"),
        ("quiz_responses",          f"DELETE FROM quiz_responses WHERE user_id IN ({id_ph})"),
        ("post_reactions",          f"DELETE FROM post_reactions WHERE user_id IN ({id_ph})"),
        ("post_comments",           f"DELETE FROM post_comments WHERE user_id IN ({id_ph})"),
        ("posts",                   f"DELETE FROM posts WHERE user_id IN ({id_ph})"),
        ("conversation_participants", f"DELETE FROM conversation_participants WHERE user_id IN ({id_ph})"),
        ("messages",                f"DELETE FROM messages WHERE sender_id IN ({id_ph}) OR receiver_id IN ({id_ph})"),
        ("reports(update)",         f"UPDATE reports SET assigned_to = NULL WHERE assigned_to IN ({id_ph})"),
        ("reports(delete)",         f"DELETE FROM reports WHERE created_by IN ({id_ph})"),
        ("collection_point_actions",f"DELETE FROM collection_point_actions WHERE user_id IN ({id_ph})"),
    ]

    for label, sql in steps:
        sp = f"sp_{label[:20].replace('(','').replace(')','')}"
        cur.execute(f"SAVEPOINT {sp}")
        try:
            cur.execute(sql)
            print(f"  [OK] {label}: {cur.rowcount} lignes")
        except Exception as e:
            cur.execute(f"ROLLBACK TO SAVEPOINT {sp}")
            print(f"  [SKIP] {label}: {type(e).__name__}")

    # Suppression finale
    cur.execute(f"DELETE FROM users WHERE id IN ({id_ph})")
    print(f"\n[OK] Utilisateurs supprimes: {cur.rowcount}")
    conn.commit()
    print("SUCCES - pointManager effaces de la base de donnees.")

except Exception as e:
    conn.rollback()
    print(f"ERREUR FATALE: {e}")
    sys.exit(1)
finally:
    cur.close()
    conn.close()
