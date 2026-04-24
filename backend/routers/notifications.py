# routers/notifications.py — User notifications
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

import db_models as db_models
from database import get_db
from core.deps import get_current_user, _utc_iso

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("")
async def get_notifications(skip: int = 0, limit: int = 50,
                             db: Session = Depends(get_db),
                             current_user: db_models.User = Depends(get_current_user)):
    notifs = (
        db.query(db_models.Notification)
        .filter(db_models.Notification.user_id == current_user.id)
        .order_by(db_models.Notification.created_at.desc())
        .offset(skip).limit(limit).all()
    )
    return [
        {
            "id": n.id, "type": n.type, "title": n.title, "body": n.body,
            "from_user_name": n.from_user_name, "post_id": n.post_id,
            "comment_id": getattr(n, "comment_id", None),
            "is_read": n.is_read, "created_at": _utc_iso(n.created_at),
        }
        for n in notifs
    ]


@router.get("/unread-count")
async def unread_count(db: Session = Depends(get_db),
                       current_user: db_models.User = Depends(get_current_user)):
    count = db.query(db_models.Notification).filter(
        db_models.Notification.user_id == current_user.id,
        db_models.Notification.is_read == False,
    ).count()
    return {"count": count}


@router.put("/read-all")
async def mark_all_read(db: Session = Depends(get_db),
                        current_user: db_models.User = Depends(get_current_user)):
    db.query(db_models.Notification).filter(
        db_models.Notification.user_id == current_user.id,
        db_models.Notification.is_read == False,
    ).update({"is_read": True})
    db.commit()
    return {"message": "Toutes les notifications marquées comme lues"}


@router.put("/{notif_id}/read")
async def mark_read(notif_id: int, db: Session = Depends(get_db),
                    current_user: db_models.User = Depends(get_current_user)):
    notif = db.query(db_models.Notification).filter(
        db_models.Notification.id == notif_id,
        db_models.Notification.user_id == current_user.id,
    ).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification non trouvée")
    notif.is_read = True
    db.commit()
    return {"message": "Notification lue"}


@router.put("/{notif_id}/unread")
async def mark_unread(notif_id: int, db: Session = Depends(get_db),
                      current_user: db_models.User = Depends(get_current_user)):
    notif = db.query(db_models.Notification).filter(
        db_models.Notification.id == notif_id,
        db_models.Notification.user_id == current_user.id,
    ).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification non trouvée")
    notif.is_read = False
    db.commit()
    return {"message": "Notification marquée comme non lue"}
