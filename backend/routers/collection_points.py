# routers/collection_points.py — Points de collecte (DB-backed, admin CRUD)
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import db_models as db_models
import models as models
from database import get_db
from core.deps import get_current_user

router = APIRouter(tags=["collection_points"])


def _seed(db: Session):
    if db.query(db_models.CollectionPoint).count() > 0:
        return
    initial = [
        {"name": "Ariana Nord", "lat": "36.8665", "lng": "10.1647", "is_verified": True, "types": "plastique,verre,papier", "address": "Rue de la République, Ariana", "hours": "8h-18h", "status": "disponible", "load_level": "0.45"},
        {"name": "Tunis Centre", "lat": "36.8065", "lng": "10.1815", "is_verified": False, "types": "plastique,batteries", "address": "Avenue Habib Bourguiba, Tunis", "hours": "7h-20h", "status": "disponible", "load_level": "0.85"},
        {"name": "La Marsa", "lat": "36.8782", "lng": "10.3247", "is_verified": True, "types": "plastique,verre,compost", "address": "Rue du Lac, La Marsa", "hours": "9h-17h", "status": "maintenance", "load_level": "0.0"},
        {"name": "Bardo", "lat": "36.8189", "lng": "10.1658", "is_verified": False, "types": "plastique,papier", "address": "Avenue du Bardo, Le Bardo", "hours": "8h-16h", "status": "disponible", "load_level": "0.45"},
        {"name": "Ben Arous", "lat": "36.7256", "lng": "10.2164", "is_verified": True, "types": "plastique,verre,batteries,electronique", "address": "Zone industrielle, Ben Arous", "hours": "7h-19h", "status": "disponible", "load_level": "0.72"},
        {"name": "Manouba", "lat": "36.8094", "lng": "10.0971", "is_verified": True, "types": "plastique,verre", "address": "Centre ville, Manouba", "hours": "8h-17h", "status": "disponible", "load_level": "0.30"},
        {"name": "Carthage", "lat": "36.8528", "lng": "10.3306", "is_verified": True, "types": "plastique,verre,papier,compost", "address": "Rue Hannibal, Carthage", "hours": "8h-18h", "status": "disponible", "load_level": "0.55"},
        {"name": "Lac 1", "lat": "36.8325", "lng": "10.2336", "is_verified": False, "types": "plastique,batteries", "address": "Les Berges du Lac, Tunis", "hours": "9h-20h", "status": "saturé", "load_level": "0.98"},
        {"name": "Sidi Bou Said", "lat": "36.8687", "lng": "10.3414", "is_verified": True, "types": "plastique,verre,compost", "address": "Village de Sidi Bou Said", "hours": "9h-16h", "status": "disponible", "load_level": "0.20"},
        {"name": "Hammam Lif", "lat": "36.7333", "lng": "10.1667", "is_verified": True, "types": "plastique,verre,papier,electronique", "address": "Avenue de la Plage, Hammam Lif", "hours": "7h-18h", "status": "disponible", "load_level": "0.60"},
    ]
    for p in initial:
        db.add(db_models.CollectionPoint(**p))
    db.commit()


def _to_dict(p):
    return {
        "id": p.id, "name": p.name,
        "lat": float(p.lat), "lng": float(p.lng),
        "is_verified": p.is_verified,
        "types": [t.strip() for t in (p.types or "").split(",") if t.strip()],
        "address": p.address or "", "hours": p.hours or "",
        "status": p.status or "disponible",
        "load_level": p.load_level or "0.0",
    }


@router.get("/collection-points")
async def list_points(type: Optional[str] = None, search: Optional[str] = None,
                      db: Session = Depends(get_db)):
    _seed(db)
    points = [_to_dict(p) for p in db.query(db_models.CollectionPoint).all()]
    if type:
        points = [p for p in points if type.lower() in p["types"]]
    if search:
        q = search.lower()
        points = [p for p in points if q in p["name"].lower() or q in p["address"].lower()]
    return points


@router.post("/admin/collection-points")
async def create_point(point: models.CollectionPointCreate, db: Session = Depends(get_db),
                       current_user: db_models.User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Réservé aux administrateurs")
    db_point = db_models.CollectionPoint(**point.dict())
    db.add(db_point)
    db.commit()
    db.refresh(db_point)
    return _to_dict(db_point)


@router.put("/admin/collection-points/{point_id}")
async def update_point(point_id: int, update: models.CollectionPointUpdate,
                       db: Session = Depends(get_db),
                       current_user: db_models.User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Réservé aux administrateurs")
    db_point = db.query(db_models.CollectionPoint).filter(
        db_models.CollectionPoint.id == point_id).first()
    if not db_point:
        raise HTTPException(status_code=404, detail="Point de collecte non trouvé")
    for field, value in update.dict(exclude_unset=True).items():
        if value is not None:
            setattr(db_point, field, value)
    db.commit()
    db.refresh(db_point)
    return _to_dict(db_point)


@router.delete("/admin/collection-points/{point_id}")
async def delete_point(point_id: int, db: Session = Depends(get_db),
                       current_user: db_models.User = Depends(get_current_user)):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Réservé aux administrateurs")
    db_point = db.query(db_models.CollectionPoint).filter(
        db_models.CollectionPoint.id == point_id).first()
    if not db_point:
        raise HTTPException(status_code=404, detail="Point de collecte non trouvé")
    db.delete(db_point)
    db.commit()
    return {"message": "Point de collecte supprimé"}
