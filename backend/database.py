import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# ── Connexion : PostgreSQL en priorité, SQLite en fallback ─────────────────────
DATABASE_URL = os.getenv("DATABASE_URL")

if DATABASE_URL:
    # PostgreSQL (production / développement avec Postgres installé)
    # Compatibilité Railway/Render : remplace "postgres://" par "postgresql://"
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    engine = create_engine(DATABASE_URL, pool_pre_ping=True)
    print(f"[DB] [OK] PostgreSQL connecte : {DATABASE_URL.split('@')[-1] if '@' in DATABASE_URL else DATABASE_URL}")
else:
    # SQLite (fallback local si DATABASE_URL non défini)
    _sqlite_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sql_app.db")
    engine = create_engine(
        f"sqlite:///{_sqlite_path}",
        connect_args={"check_same_thread": False},
    )
    print(f"[DB] [WARN] DATABASE_URL non trouve -- SQLite en fallback : {_sqlite_path}")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# ── Dependency FastAPI ─────────────────────────────────────────────────────────
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
