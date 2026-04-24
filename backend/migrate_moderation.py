
import sqlite3

conn = sqlite3.connect("sql_app.db")
cursor = conn.cursor()

cursor.execute("PRAGMA table_info(posts)")
existing_cols = [row[1] for row in cursor.fetchall()]
print(f"Colonnes actuelles posts: {existing_cols}")

migrations = [
    ("status", "TEXT NOT NULL DEFAULT 'published'"),
    ("moderation_score", "REAL NOT NULL DEFAULT 0.0"),
    ("moderation_reason", "TEXT"),
    ("moderation_details", "TEXT"),
]

for col_name, col_def in migrations:
    if col_name not in existing_cols:
        cursor.execute(f"ALTER TABLE posts ADD COLUMN {col_name} {col_def}")
        print(f"+ Colonne ajoutée: {col_name}")
    else:
        print(f"= Colonne existante (ignorée): {col_name}")

conn.commit()

# Vérification finale
cursor.execute("PRAGMA table_info(posts)")
final_cols = [row[1] for row in cursor.fetchall()]
print(f"\nposts APRES migration: {final_cols}")

conn.close()
print("\nMigration modération terminée !")
