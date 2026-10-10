import psycopg2, os
from dotenv import load_dotenv
load_dotenv(".env")
conn = psycopg2.connect(os.environ["DATABASE_URL"])
cur = conn.cursor()
cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='smart_bins' ORDER BY ordinal_position")
cols = [r[0] for r in cur.fetchall()]
print("smart_bins columns:", cols)
conn.close()
