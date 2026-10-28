"""
database.py — Connexion SQLAlchemy (PostgreSQL uniquement)
==========================================================
PostgreSQL est la seule base de données supportée.
Définissez DATABASE_URL dans .env :
  DATABASE_URL=postgresql://user:password@host:port/dbname
"""

import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# ── Charger .env ───────────────────────────────────────────────────────────────
try:
    from dotenv import load_dotenv
    _env_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
    if os.path.exists(_env_file):
        load_dotenv(_env_file)
except ImportError:
    pass

# ── Variables d'environnement ──────────────────────────────────────────────────
DATABASE_URL = os.getenv("DATABASE_URL", "")
APP_ENV = os.getenv("APP_ENV", "development").lower()


def _fail_fast(msg: str) -> None:
    """Affiche une erreur critique et arrête le processus."""
    print(f"\n{'='*70}", file=sys.stderr)
    print(f"[DB] [ERR]  ERREUR CRITIQUE — {msg}", file=sys.stderr)
    print(f"{'='*70}\n", file=sys.stderr)
    sys.exit(1)


# ── Vérification DATABASE_URL ─────────────────────────────────────────────────
if not DATABASE_URL:
    _fail_fast(
        "DATABASE_URL non défini.\n"
        "  Ajoutez dans backend/.env :\n"
        "  DATABASE_URL=postgresql://user:password@host:port/dbname"
    )

# Compatibilité Railway/Render : postgres:// → postgresql://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Force le driver psycopg2 (v2) — evite l'import de psycopg (v3) par SQLAlchemy 2.x
if DATABASE_URL.startswith("postgresql://") and "+psycopg" not in DATABASE_URL:
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg2://", 1)

if not DATABASE_URL.startswith("postgresql"):
    _fail_fast(
        "DATABASE_URL ne pointe pas vers PostgreSQL.\n"
        "  Valeur reçue : " + DATABASE_URL[:40] + "...\n"
        "  Format attendu : postgresql://user:password@host:port/dbname"
    )

# ── Création de l'engine PostgreSQL ──────────────────────────────────────────
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,    # Vérifie la connexion avant chaque utilisation
    pool_size=10,          # Connexions persistantes en pool
    max_overflow=20,       # Connexions supplémentaires autorisées
    pool_timeout=30,       # Timeout avant erreur (secondes)
    pool_recycle=1800,     # Recycler les connexions après 30 min
)

_db_label = DATABASE_URL.split("@")[-1] if "@" in DATABASE_URL else DATABASE_URL
print(f"[DB] [OK]  PostgreSQL connecté : {_db_label}")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# ── Dependency FastAPI ─────────────────────────────────────────────────────────
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
