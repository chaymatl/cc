"""
alembic/env.py — Configuration Alembic pour EcoRewind (PostgreSQL uniquement)
==============================================================================
- Lit DATABASE_URL depuis .env (PostgreSQL obligatoire)
- Importe tous les modèles SQLAlchemy via db_models (nécessaire pour --autogenerate)
- Supporte les migrations online et offline
"""

import os
import sys
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool
from alembic import context

# ── Ajouter le répertoire backend/ au PYTHONPATH ─────────────────────────────
_backend_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _backend_dir not in sys.path:
    sys.path.insert(0, _backend_dir)

# ── Charger les variables d'environnement depuis .env ────────────────────────
from dotenv import load_dotenv
load_dotenv(os.path.join(_backend_dir, ".env"))

# ── Importer Base + tous les modèles (pour que --autogenerate les détecte) ───
from database import Base  # noqa: E402

import db_models  # noqa: F401, E402
from app.intercommunality import zone_models  # noqa: F401, E402
from app.intercommunality import models as intercommunality_models  # noqa: F401, E402

# ── Résoudre l'URL de la base de données ─────────────────────────────────────
DATABASE_URL = os.getenv("DATABASE_URL", "")
APP_ENV = os.getenv("APP_ENV", "development").lower()

if not DATABASE_URL:
    print(
        "\n" + "="*70 + "\n"
        "[Alembic] [ERR]  ERREUR CRITIQUE — DATABASE_URL non défini.\n"
        "[Alembic]     Ajoutez dans backend/.env :\n"
        "[Alembic]     DATABASE_URL=postgresql://user:password@host:port/dbname\n"
        + "="*70 + "\n"
    )
    sys.exit(1)

# Compatibilité Railway/Render : postgres:// → postgresql://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

if not DATABASE_URL.startswith("postgresql"):
    print(f"[Alembic] [ERR]  DATABASE_URL invalide : {DATABASE_URL[:60]}")
    sys.exit(1)

# ── Configuration Alembic ────────────────────────────────────────────────────
config = context.config
config.set_main_option("sqlalchemy.url", DATABASE_URL)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

_db_label = DATABASE_URL.split("@")[-1] if "@" in DATABASE_URL else DATABASE_URL[:40]
print(f"[Alembic] [DB]  Cible PostgreSQL : {_db_label}")


def run_migrations_offline() -> None:
    """Mode offline : génère du SQL pur sans connexion DB."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Mode online : connexion directe à la DB, migration immédiate."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )
        with context.begin_transaction():
            context.run_migrations()


# ── Point d'entrée ───────────────────────────────────────────────────────────
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
