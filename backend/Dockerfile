# Dockerfile — FastAPI Backend EcoRewind
# ================================================================
# Build  : docker build -t ecorewind-api .
# Run    : docker compose --profile standalone up -d
# ================================================================

FROM python:3.11-slim

WORKDIR /app

# ── Dépendances système minimales ────────────────────────────────
# gcc / libpq-dev   : compilation psycopg2
# libgl1 / libglib2 : OpenCV headless (QR scan, modération image)
# curl              : healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    libffi-dev \
    libgl1 \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ── Cache des dépendances Python (couche indépendante du code) ───
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Copie du code source ─────────────────────────────────────────
COPY . .

# ── Répertoires persistants ──────────────────────────────────────
RUN mkdir -p /app/uploads

# ── Variables d'environnement par défaut ─────────────────────────
ENV PYTHONUNBUFFERED=1
ENV PORT=8000
# Chemin du fichier de credentials Firebase (monté en volume)
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/firebase_credentials.json

EXPOSE 8000

# ── Healthcheck HTTP ─────────────────────────────────────────────
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:8000/health || curl -f http://localhost:8000/docs || exit 1

# ── Démarrage Uvicorn ────────────────────────────────────────────
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
