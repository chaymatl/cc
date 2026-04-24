"""
EcoRewind Backend — Application Factory
========================================
main.py est maintenant réduit à son strict minimum :
  - Création de l'app FastAPI
  - Configuration CORS & fichiers statiques
  - Inclusion des routers modulaires

Routes organisées dans backend/routers/ :
  auth.py            → /register, /token, /otp/*, /auth/*, /forgot-password…
  users.py           → /users, /admin/users/*, /users/me*
  posts.py           → /posts/*, /upload, /comments/*, /users/me/saved-posts
  notifications.py   → /notifications/*
  collection_points.py → /collection-points, /admin/collection-points/*
  community.py       → /testimonials/*, /center-proposals/*, /stats, /qr/*, /tips/*
"""

from dotenv import load_dotenv
load_dotenv()

import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from database import engine
import db_models as db_models

# ── Create all DB tables ───────────────────────────────────────────────────────
db_models.Base.metadata.create_all(bind=engine)

# ── App factory ────────────────────────────────────────────────────────────────
app = FastAPI(
    title="EcoRewind API",
    description="Backend REST API for the EcoRewind waste sorting platform.",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── Static files ───────────────────────────────────────────────────────────────
UPLOADS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "uploads")
os.makedirs(UPLOADS_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads")

# ── CORS ───────────────────────────────────────────────────────────────────────
IS_DEV = os.getenv("APP_ENV", "development").lower() != "production"
_raw = os.getenv("CORS_ORIGINS", "")
if _raw == "*" and IS_DEV:
    _origins = ["*"]
elif _raw:
    _origins = [o.strip() for o in _raw.split(",") if o.strip()]
else:
    _origins = ["http://localhost:3000", "http://localhost:8080", "http://localhost:5500"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Include routers ────────────────────────────────────────────────────────────
from routers import auth, users, posts, notifications, collection_points, community, moderation, quiz  # noqa: E402

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(posts.router)
app.include_router(notifications.router)
app.include_router(collection_points.router)
app.include_router(community.router)
app.include_router(moderation.router)
app.include_router(quiz.router)


# ── Startup : pré-chargement des modèles IA ────────────────────────────────────
@app.on_event("startup")
async def _preload_ai_models():
    """
    Charge tous les modèles IA au démarrage du serveur (une seule fois).
    Sans ça, le premier utilisateur qui publie attend 2-3 minutes (CLIP 2.4 GB).
    Avec ça, le chargement se fait invisiblement pendant le démarrage de uvicorn.
    """
    import asyncio
    import threading

    def _load():
        try:
            # Charge EcoCNNModerator (Text CNN + ResNet18 + Detoxify + regles)
            from moderation_ai.eco_moderator import get_cnn_moderator
            get_cnn_moderator()
            print("[STARTUP] [OK] Modeles IA pre-charges -- moderation prete")
        except Exception as e:
            print(f"[STARTUP] [WARN] Pre-chargement IA echoue (mode regles actif) : {e}")

    # Lancer dans un thread séparé pour ne pas bloquer la boucle asyncio
    thread = threading.Thread(target=_load, daemon=True, name="ai-preload")
    thread.start()


# ── Health check ───────────────────────────────────────────────────────────────
@app.get("/", tags=["health"])
async def root():
    return {"status": "ok", "service": "EcoRewind API", "version": "2.0.0"}
