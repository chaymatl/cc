"""
routers/qr_bins.py — QR Poubelle Intelligente + Attribution de Score
══════════════════════════════════════════════════════════════════════
Endpoints :
  POST /qr/scan-bin     → Scan d'une poubelle, calcul et attribution des points
  GET  /qr/scan-history → Historique des scans du citoyen connecté
  GET  /qr/leaderboard  → Classement des citoyens par score
  GET  /qr/bin-stats    → Statistiques globales (admin)
"""

from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import func, desc

import db_models as db_models
from database import get_db
from core.deps import get_current_user, get_admin_user
from services.firebase_service import (
    calculate_points, update_user_score, get_user_score, WASTE_POINTS
)

router = APIRouter(tags=["qr-bins"])


# ── Pydantic Schemas ──────────────────────────────────────────────────────────

class BinScanRequest(BaseModel):
    """Payload envoyé par la poubelle intelligente lors du scan QR."""
    qr_code: str
    waste_type: str = "general"          # plastique, verre, papier, métal, organique, electronique, general
    weight_kg: Optional[float] = None   # Optionnel : si la poubelle pèse les déchets
    bin_id: Optional[str] = None        # Identifiant unique de la poubelle


class BinScanResponse(BaseModel):
    success: bool
    user_id: int
    user_name: str
    waste_type: str
    points_earned: float
    score_before: float
    score_after: float
    firebase_synced: bool
    message: str


# ── POST /qr/scan-bin ─────────────────────────────────────────────────────────

@router.post("/qr/scan-bin", response_model=BinScanResponse)
async def scan_bin(data: BinScanRequest, db: Session = Depends(get_db)):
    """
    Endpoint appelé par la poubelle intelligente lors du scan du QR code citoyen.
    - Identifie le citoyen via son QR code unique
    - Calcule les points selon le type de déchet (et le poids si disponible)
    - Met à jour le global_score dans PostgreSQL
    - Synchronise en temps réel avec Firebase RTDB (push vers l'app Flutter)
    - Enregistre le scan dans l'historique (table bin_scans)

    Peut être appelé sans authentification JWT (la poubelle n'a pas de compte).
    L'authentification est faite via le QR code lui-même.
    """
    qr = data.qr_code.strip()
    if not qr:
        raise HTTPException(status_code=400, detail="QR code requis")

    # 1. Identifier le citoyen
    user = db.query(db_models.User).filter(db_models.User.qr_code == qr).first()
    if not user:
        raise HTTPException(status_code=404, detail="QR code invalide — citoyen non trouvé")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Compte désactivé")

    # 2. Calculer les points
    waste_type = data.waste_type.lower().strip()
    points = calculate_points(waste_type, data.weight_kg)

    score_before = user.global_score or 0.0
    score_after = round(score_before + points, 2)

    # 3. Mettre à jour le score dans PostgreSQL
    user.global_score = score_after
    db.commit()
    db.refresh(user)

    # 4. Synchroniser avec Firebase RTDB (temps réel)
    firebase_ok = update_user_score(
        user_id=user.id,
        new_total=score_after,
        points_added=points,
        bin_type=waste_type,
        bin_id=data.bin_id,
    )

    # 5. Enregistrer dans l'historique
    scan = db_models.BinScan(
        user_id=user.id,
        qr_code=qr,
        bin_id=data.bin_id,
        waste_type=waste_type,
        weight_kg=data.weight_kg,
        points_earned=points,
        score_before=score_before,
        score_after=score_after,
        firebase_synced=firebase_ok,
    )
    db.add(scan)
    db.commit()

    return BinScanResponse(
        success=True,
        user_id=user.id,
        user_name=user.full_name or user.email,
        waste_type=waste_type,
        points_earned=points,
        score_before=score_before,
        score_after=score_after,
        firebase_synced=firebase_ok,
        message=f"✅ +{points} pts attribués à {user.full_name or user.email} pour '{waste_type}'",
    )


# ── GET /qr/scan-history ─────────────────────────────────────────────────────

@router.get("/qr/scan-history")
async def get_scan_history(
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user: db_models.User = Depends(get_current_user),
):
    """Historique des scans QR du citoyen connecté."""
    scans = (
        db.query(db_models.BinScan)
        .filter(db_models.BinScan.user_id == current_user.id)
        .order_by(desc(db_models.BinScan.scanned_at))
        .limit(min(limit, 100))
        .all()
    )
    return {
        "user_id": current_user.id,
        "total_scans": len(scans),
        "current_score": current_user.global_score or 0.0,
        "scans": [
            {
                "id": s.id,
                "waste_type": s.waste_type,
                "bin_id": s.bin_id,
                "weight_kg": s.weight_kg,
                "points_earned": s.points_earned,
                "score_before": s.score_before,
                "score_after": s.score_after,
                "scanned_at": s.scanned_at.isoformat() if s.scanned_at else None,
            }
            for s in scans
        ],
    }


# ── GET /qr/leaderboard ──────────────────────────────────────────────────────

@router.get("/qr/leaderboard")
async def get_leaderboard(limit: int = 10, db: Session = Depends(get_db)):
    """Classement des citoyens par score global (public)."""
    top = (
        db.query(db_models.User)
        .filter(db_models.User.is_active == True, db_models.User.role == "user")
        .order_by(desc(db_models.User.global_score))
        .limit(min(limit, 50))
        .all()
    )
    return {
        "leaderboard": [
            {
                "rank": i + 1,
                "user_id": u.id,
                "full_name": u.full_name or "Citoyen",
                "avatar_url": u.avatar_url,
                "global_score": round(u.global_score or 0.0, 2),
            }
            for i, u in enumerate(top)
        ]
    }


# ── GET /qr/bin-stats (admin) ────────────────────────────────────────────────

@router.get("/qr/bin-stats")
async def get_bin_stats(
    db: Session = Depends(get_db),
    admin: db_models.User = Depends(get_admin_user),
):
    """Statistiques globales des scans de poubelles (admin uniquement)."""
    total_scans = db.query(func.count(db_models.BinScan.id)).scalar() or 0
    total_points = db.query(func.sum(db_models.BinScan.points_earned)).scalar() or 0.0
    total_weight = db.query(func.sum(db_models.BinScan.weight_kg)).scalar() or 0.0

    # Répartition par type de déchet
    by_type = (
        db.query(
            db_models.BinScan.waste_type,
            func.count(db_models.BinScan.id).label("count"),
            func.sum(db_models.BinScan.points_earned).label("total_points"),
        )
        .group_by(db_models.BinScan.waste_type)
        .all()
    )

    return {
        "total_scans": total_scans,
        "total_points_distributed": round(float(total_points), 2),
        "total_weight_kg": round(float(total_weight), 2),
        "waste_types_breakdown": [
            {
                "waste_type": row.waste_type,
                "scans": row.count,
                "total_points": round(float(row.total_points or 0), 2),
            }
            for row in by_type
        ],
        "points_scale": WASTE_POINTS,
    }
