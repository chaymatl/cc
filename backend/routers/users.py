# routers/users.py — User management (admin CRUD + profile)
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List

import db_models as db_models
import models as models
from auth import get_password_hash
from database import get_db
from core.deps import get_current_user, get_admin_user

router = APIRouter(tags=["users"])


class AvatarUpdate(BaseModel):
    avatar_url: str


# ── Admin user management ─────────────────────────────────────────────────────

@router.get("/users", response_model=List[models.User])
async def list_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db),
                     admin: db_models.User = Depends(get_admin_user)):
    return db.query(db_models.User).offset(skip).limit(limit).all()


@router.post("/admin/users", response_model=models.User)
async def create_user(user: models.UserCreate, db: Session = Depends(get_db),
                      admin: db_models.User = Depends(get_admin_user)):
    if db.query(db_models.User).filter(db_models.User.email == user.email).first():
        raise HTTPException(status_code=400, detail="Cet email est déjà utilisé")
    new_user = db_models.User(
        email=user.email, full_name=user.full_name,
        hashed_password=get_password_hash(user.password),
        role=user.role, is_active=True,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.put("/admin/users/{user_id}", response_model=models.User)
async def update_user(user_id: int, user_update: models.UserUpdate,
                      db: Session = Depends(get_db),
                      admin: db_models.User = Depends(get_admin_user)):
    db_user = db.query(db_models.User).filter(db_models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    if user_update.full_name:
        db_user.full_name = user_update.full_name
    if user_update.role:
        db_user.role = user_update.role
    if user_update.password:
        db_user.hashed_password = get_password_hash(user_update.password)
    db.commit()
    db.refresh(db_user)
    return db_user


@router.delete("/admin/users/{user_id}")
async def delete_user(user_id: int, db: Session = Depends(get_db),
                      admin: db_models.User = Depends(get_admin_user)):
    db_user = db.query(db_models.User).filter(db_models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    db.delete(db_user)
    db.commit()
    return {"message": "Utilisateur supprimé"}


# ── Current user profile ──────────────────────────────────────────────────────

@router.get("/users/me")
async def get_me(current_user: db_models.User = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "role": current_user.role,
        "avatar_url": getattr(current_user, "avatar_url", None) or "",
        "qr_code": current_user.qr_code,
        "points": getattr(current_user, "points", 0),
    }


@router.put("/users/me/avatar")
async def update_avatar(data: AvatarUpdate, db: Session = Depends(get_db),
                        current_user: db_models.User = Depends(get_current_user)):
    current_user.avatar_url = data.avatar_url
    db.commit()
    db.refresh(current_user)
    return {"message": "Avatar mis à jour", "avatar_url": current_user.avatar_url}


@router.get("/users/me/stats")
async def get_my_stats(db: Session = Depends(get_db),
                       current_user: db_models.User = Depends(get_current_user)):
    """Statistiques personnelles de l'utilisateur connecte."""
    from sqlalchemy import func

    posts_count = db.query(func.count(db_models.Post.id)).filter(
        db_models.Post.user_id == current_user.id,
        db_models.Post.status == "published",
    ).scalar() or 0

    likes_received = db.query(func.sum(db_models.Post.likes_count)).filter(
        db_models.Post.user_id == current_user.id,
        db_models.Post.status == "published",
    ).scalar() or 0

    comments_count = db.query(func.count(db_models.Comment.id)).filter(
        db_models.Comment.user_id == current_user.id,
    ).scalar() or 0

    saved_count = db.query(func.count(db_models.SavedPost.id)).filter(
        db_models.SavedPost.user_id == current_user.id,
    ).scalar() or 0

    return {
        "posts_count": posts_count,
        "likes_received": int(likes_received),
        "comments_count": comments_count,
        "saved_count": saved_count,
        "eco_score": posts_count * 10 + int(likes_received) * 2 + comments_count * 5,
    }
