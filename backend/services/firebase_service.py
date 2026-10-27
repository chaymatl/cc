"""
services/firebase_service.py
-----------------------------
Service Firebase Admin SDK -- Realtime Database.
Utilise pour synchroniser :
  - /scores/{user_id}          : score du citoyen
  - /utilisateurs/{qr_code}   : profil de chaque utilisateur (cle = QR code)
  - /poubelles/{bin_id}       : poids + etat de la poubelle

Initialisation lazy : Firebase est initialise au premier appel.
Si les credentials sont absents, le service fonctionne en mode "noop"
(pas d'erreur fatale -- le reste de l'app continue).
"""
import os
import sys
import json
import traceback
from datetime import datetime, timezone
from typing import Optional

_firebase_app = None
_firebase_initialized = False
_firebase_available = False
_firebase_db_url = None


def _safe_print(msg: str):
    """Print robuste pour Windows (evite UnicodeEncodeError)."""
    try:
        print(msg)
    except UnicodeEncodeError:
        print(msg.encode('ascii', errors='replace').decode('ascii'))


def _init_firebase() -> bool:
    """Initialise Firebase Admin SDK (lazy init avec retry en cas d'echec)."""
    global _firebase_app, _firebase_initialized, _firebase_available, _firebase_db_url

    # Si deja initialise avec succes, pas besoin de retenter
    if _firebase_initialized and _firebase_available:
        return True

    creds_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase_credentials.json")
    db_url = os.getenv("FIREBASE_DATABASE_URL", "")

    # Resoudre le chemin relatif depuis le dossier backend
    if not os.path.isabs(creds_path):
        creds_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", creds_path)
        creds_path = os.path.normpath(creds_path)

    if not os.path.exists(creds_path):
        if not _firebase_initialized:
            _safe_print(f"[Firebase] Credentials introuvables : {creds_path}")
            _safe_print("[Firebase] Mode noop actif -- scores Firebase desactives")
        _firebase_initialized = True
        _firebase_available = False
        return False

    if not db_url:
        if not _firebase_initialized:
            _safe_print("[Firebase] FIREBASE_DATABASE_URL non defini dans .env")
        _firebase_initialized = True
        _firebase_available = False
        return False

    try:
        import firebase_admin
        from firebase_admin import credentials

        # Si l'app existe deja avec une URL differente, la supprimer et recreer
        if firebase_admin._apps:
            existing_app = firebase_admin.get_app()
            existing_url = existing_app.options.get("databaseURL", "")
            if existing_url != db_url:
                _safe_print(f"[Firebase] URL changee ({existing_url} -> {db_url}), reinitialisation...")
                firebase_admin.delete_app(existing_app)

        if not firebase_admin._apps:
            cred = credentials.Certificate(creds_path)
            _firebase_app = firebase_admin.initialize_app(cred, {"databaseURL": db_url})
        else:
            _firebase_app = firebase_admin.get_app()

        _firebase_initialized = True
        _firebase_available = True
        _firebase_db_url = db_url
        _safe_print(f"[Firebase] [OK] Connecte a : {db_url}")
        return True

    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] Initialisation : {e}")
        _firebase_initialized = True
        _firebase_available = False
        return False


def update_user_score(user_id: int, new_total: float, points_added: float,
                      bin_type: str = "general", bin_id: Optional[str] = None,
                      qr_code: Optional[str] = None) -> bool:
    """
    Met a jour le score d'un citoyen dans Firebase RTDB.

    Structure : /scores/{user_id}/
      - total         : float  (score cumule)
      - last_points   : float  (points du dernier scan)
      - last_scan     : str    (ISO datetime UTC)
      - last_bin_type : str    (type de dechet scanne)
      - last_bin_id   : str    (identifiant de la poubelle, optionnel)

    Met egalement a jour /utilisateurs/{qr_code}/score si qr_code fourni
    (synchronisation du score dans le profil citoyen en temps reel).

    Retourne True si l'ecriture a reussi, False sinon.
    """
    if not _init_firebase():
        return False

    try:
        from firebase_admin import db as rtdb

        # 1) Mise a jour du noeud /scores/{user_id}
        ref = rtdb.reference(f"scores/{user_id}")
        ref.update({
            "total": round(new_total, 2),
            "last_points": round(points_added, 2),
            "last_scan": datetime.now(timezone.utc).isoformat(),
            "last_bin_type": bin_type,
            "last_bin_id": bin_id or "unknown",
        })

        # 2) Mise a jour du champ score dans /utilisateurs/{qr_code}
        #    (uniquement pour les citoyens — cle = qr_code, pas l'id numerique)
        if qr_code:
            user_ref = rtdb.reference(f"utilisateurs/{qr_code}")
            user_data = user_ref.get()
            if user_data and isinstance(user_data, dict) and user_data.get("role") == "citoyen":
                user_ref.update({"score": round(new_total, 2)})

        _safe_print(f"[Firebase] [OK] Score user {user_id} mis a jour : {new_total} pts (+{points_added})")
        return True
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] Mise a jour score user {user_id} : {e}")
        traceback.print_exc()
        return False


def update_quiz_score(user_id: int, new_total: float, quiz_points: float,
                      quiz_id: int, qr_code: Optional[str] = None) -> bool:
    """
    Met a jour le score d'un citoyen apres un quiz dans Firebase RTDB.

    Systeme independant du scan de poubelle — pas de champs bin_type / bin_id.

    Structure mise a jour : /scores/{user_id}/
      - total           : float  (score cumule global)
      - last_points     : float  (points gagnes sur ce quiz)
      - last_activity   : str    (ISO datetime UTC)
      - last_source     : str    (toujours "quiz")
      - last_quiz_id    : int    (ID du quiz complete)

    Met egalement a jour /utilisateurs/{qr_code}/score si qr_code fourni.

    Retourne True si l'ecriture a reussi, False sinon.
    """
    if not _init_firebase():
        return False

    try:
        from firebase_admin import db as rtdb

        # 1) Mise a jour du noeud /scores/{user_id}
        ref = rtdb.reference(f"scores/{user_id}")
        ref.update({
            "total":          round(new_total, 2),
            "last_points":    round(quiz_points, 2),
            "last_activity":  datetime.now(timezone.utc).isoformat(),
            "last_source":    "quiz",
            "last_quiz_id":   quiz_id,
        })

        # 2) Mise a jour du champ score dans /utilisateurs/{qr_code}
        if qr_code:
            user_ref = rtdb.reference(f"utilisateurs/{qr_code}")
            user_data = user_ref.get()
            if user_data and isinstance(user_data, dict) and user_data.get("role") == "citoyen":
                user_ref.update({"score": round(new_total, 2)})

        _safe_print(f"[Firebase] [OK] Quiz score user {user_id} : {new_total} pts (+{quiz_points} quiz #{quiz_id})")
        return True
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] update_quiz_score user {user_id} : {e}")
        traceback.print_exc()
        return False


def get_user_score(user_id: int) -> Optional[dict]:
    """Recupere les donnees de score d'un citoyen depuis Firebase RTDB."""
    if not _init_firebase():
        return None
    try:
        from firebase_admin import db as rtdb
        ref = rtdb.reference(f"scores/{user_id}")
        return ref.get()
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] Lecture score user {user_id} : {e}")
        return None


def generate_custom_token(user_id: int) -> Optional[str]:
    """
    Génère un Firebase Custom Token pour un utilisateur EcoRewind.

    Firebase ne connaît pas les utilisateurs JWT FastAPI. Ce token permet
    à Flutter d'appeler FirebaseAuth.signInWithCustomToken(token) et
    d'obtenir une identité Firebase reconnue par les Security Rules.

    Le uid Firebase = str(user_id) pour que la règle
        auth.uid == $user_id
    fonctionne avec les chemins /scores/{user_id}.

    Retourne None si Firebase est indisponible (mode noop).
    """
    if not _init_firebase():
        return None
    try:
        import firebase_admin.auth as fb_auth
        # uid doit être une string — on utilise l'ID PostgreSQL converti
        uid = str(user_id)
        token_bytes = fb_auth.create_custom_token(uid)
        # create_custom_token retourne des bytes sur certaines versions
        if isinstance(token_bytes, bytes):
            return token_bytes.decode("utf-8")
        return token_bytes
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] generate_custom_token user {user_id} : {e}")
        return None


# Bareme des points par type de dechet
WASTE_POINTS: dict[str, float] = {
    "plastique": 10.0,
    "verre":     15.0,
    "papier":    8.0,
    "carton":    8.0,
    "metal":     12.0,
    "organique": 6.0,
    "electronique": 20.0,
    "textile":   10.0,
    "general":   5.0,
}


def calculate_points(waste_type: str, weight_kg: Optional[float] = None) -> float:
    """
    Calcule les points pour un scan de poubelle.
    Si weight_kg est fourni (poubelle connectee), les points sont multiplies par le poids.
    Sinon, retourne les points de base pour le type de dechet.
    """
    base = WASTE_POINTS.get(waste_type.lower().strip(), WASTE_POINTS["general"])
    if weight_kg and weight_kg > 0:
        return round(base * weight_kg, 2)
    return base


# ─────────────────────────────────────────────────────────────────────────────
# TABLE : /utilisateurs/{qr_code}
# Cle = QR code unique (ex: TRIDECHET-aaa433a8-7683-4574-8fa7-64b600916f0c)
# ─────────────────────────────────────────────────────────────────────────────

def sync_user_to_firebase(
    user_id: int,
    role: str,
    qr_code: str,
    full_name: str = "",
    email: str = "",
    score: Optional[float] = None,
) -> float:
    """
    Synchronise les donnees d'identification d'un utilisateur dans Firebase RTDB.

    Cle du noeud = qr_code (ex: TRIDECHET-aaa433a8-7683-4574-8fa7-64b600916f0c)
    Structure : /utilisateurs/{qr_code}/
      - id        : int  (identifiant PostgreSQL pour retrouver l'utilisateur)
      - full_name : str  (nom complet)
      - email     : str  (adresse email)
      - role      : str  (ex: "user", "admin", "collector"...)
      - score     : float  (UNIQUEMENT pour role="citoyen" / citoyens)

    Strategie score (protection contre l'ecrasement Arduino) :
      - Lit le score ACTUEL dans Firebase avant d'ecrire
      - Conserve le MAXIMUM entre le score Firebase (mis a jour par l'Arduino)
        et le score PostgreSQL (mis a jour par l'API scan)
      - Cela empeche le login de remettre le score a 0 si l'Arduino a deja
        enregistre des points directement dans Firebase RTDB.

    Retourne le score autoritatif retenu (utile pour re-sync PostgreSQL).
    Retourne -1.0 en cas d'echec.
    """
    if not _init_firebase():
        return -1.0

    # Si pas de QR code, impossible d'ecrire le noeud
    if not qr_code:
        _safe_print(f"[Firebase] [WARN] sync_user_to_firebase : qr_code vide pour user {user_id} — skip")
        return -1.0

    try:
        from firebase_admin import db as rtdb
        # Cle = QR code (pas l'ID numerique)
        ref = rtdb.reference(f"utilisateurs/{qr_code}")

        data = {
            "id":        user_id,
            "full_name": full_name or "",
            "email":     email or "",
            "role":      role,
        }

        # ── Score : protection contre l'ecrasement du score Arduino ────────────
        # L'Arduino met a jour /utilisateurs/{qr}/score directement dans Firebase.
        # Lors du login, PostgreSQL.global_score peut valoir 0 (pas encore sync).
        # On lit le score Firebase existant et on prend le MAXIMUM pour ne jamais
        # regresser le score affiche dans l'app.
        authoritative_score = 0.0
        if role == "citoyen":
            pg_score = round(float(score), 2) if score is not None else 0.0
            # Lire le score actuel Firebase (ecrit par l'Arduino ou l'API)
            try:
                current_data = ref.get() or {}
                fb_score = float(current_data.get("score", 0.0))
            except Exception:
                fb_score = 0.0
            # Conserver le score le plus eleve (Arduino peut avoir score > PostgreSQL)
            authoritative_score = round(max(pg_score, fb_score), 2)
            data["score"] = authoritative_score

        # Utiliser update() au lieu de set() pour ne pas ecraser les champs
        # eventuellement ecrits par d'autres processus (Arduino, BinSync...)
        ref.update(data)
        _safe_print(
            f"[Firebase] [OK] Utilisateur {qr_code} ({full_name}) synchro "
            f"(role={role}" + (f", score={authoritative_score}" if role == "citoyen" else "") + ")"
        )
        return authoritative_score
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] sync_user_to_firebase user {user_id} : {e}")
        traceback.print_exc()
        return -1.0


def get_firebase_user(qr_code: str) -> Optional[dict]:
    """Recupere les donnees /utilisateurs/{qr_code} depuis Firebase RTDB."""
    if not _init_firebase():
        return None
    try:
        from firebase_admin import db as rtdb
        ref = rtdb.reference(f"utilisateurs/{qr_code}")
        return ref.get()
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] get_firebase_user qr={qr_code} : {e}")
        return None


def get_user_id_by_qr(qr_code: str) -> Optional[int]:
    """
    Retrouve l'user_id PostgreSQL depuis un QR code.
    Lookup direct : /utilisateurs/{qr_code}/id
    (La cle du noeud EST le qr_code — pas besoin de scanner tous les noeuds.)
    Retourne l'user_id (int) si trouve, None sinon.
    """
    if not _init_firebase():
        return None
    try:
        from firebase_admin import db as rtdb
        # Lookup direct O(1) : la cle du noeud est le qr_code
        ref = rtdb.reference(f"utilisateurs/{qr_code}/id")
        user_id = ref.get()
        if user_id is not None:
            return int(user_id)
        return None
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] get_user_id_by_qr qr={qr_code} : {e}")
        return None


# ─────────────────────────────────────────────────────────────────────────────
# TABLE : /poubelles/{bin_id}
# ─────────────────────────────────────────────────────────────────────────────

# Etats valides pour une poubelle
BIN_ETATS = {"vide", "mi-plein", "plein", "en_maintenance"}


def update_bin_status(bin_id: str, poids: float, etat: str) -> bool:
    """
    Met a jour l'etat d'une poubelle dans Firebase RTDB.

    Structure : /poubelles/{bin_id}/
      - poids : float  (poids actuel du contenu en kg)
      - etat  : str    ("vide" | "mi-plein" | "plein" | "en_maintenance")

    A appeler apres chaque mesure IoT ou scan de poubelle.
    Retourne True si l'ecriture a reussi, False sinon.
    """
    if not _init_firebase():
        return False

    # Validation de l'etat
    etat_valide = etat if etat in BIN_ETATS else "vide"
    if etat != etat_valide:
        _safe_print(f"[Firebase] [WARN] Etat inconnu '{etat}' -> utilise 'vide'")

    try:
        from firebase_admin import db as rtdb
        ref = rtdb.reference(f"poubelles/{bin_id}")
        ref.update({
            "poids": round(float(poids), 2),
            "etat": etat_valide,
            "derniere_mise_a_jour": datetime.now(timezone.utc).isoformat(),
        })
        _safe_print(f"[Firebase] [OK] Poubelle {bin_id} : poids={poids}kg, etat={etat_valide}")
        return True
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] update_bin_status bin={bin_id} : {e}")
        traceback.print_exc()
        return False


def get_bin_status(bin_id: str) -> Optional[dict]:
    """Recupere l'etat actuel d'une poubelle depuis Firebase RTDB."""
    if not _init_firebase():
        return None
    try:
        from firebase_admin import db as rtdb
        ref = rtdb.reference(f"poubelles/{bin_id}")
        return ref.get()
    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] get_bin_status bin={bin_id} : {e}")
        return None


# ─────────────────────────────────────────────────────────────────────────────
# TABLE : /admin_stats/
# Nœud agrégé mis à jour après chaque scan pour le dashboard admin temps réel.
# ─────────────────────────────────────────────────────────────────────────────

def update_admin_stats(db) -> bool:
    """
    Calcule et pousse les statistiques agrégées dans Firebase RTDB.

    Structure : /admin_stats/
      - total_users          : int
      - active_users_week    : int
      - new_users_month      : int
      - average_score        : float
      - total_scans          : int
      - scans_today          : int
      - scans_week           : int
      - points_distributed   : float
      - pending_moderation   : int
      - pending_testimonials : int
      - pending_proposals    : int
      - total_centers        : int
      - active_centers       : int
      - last_updated         : ISO datetime UTC

    Retourne True si l'écriture a réussi, False sinon (non bloquant).
    """
    if not _init_firebase():
        return False

    try:
        from firebase_admin import db as rtdb
        from datetime import timedelta
        from sqlalchemy import func

        now = datetime.now(timezone.utc).replace(tzinfo=None)
        since_week  = now - timedelta(days=7)
        # Utiliser le fuseau local Tunisie (UTC+1) pour "aujourd'hui"
        # afin qu'un scan à 23h43 UTC (= 00h43 locale) compte comme "aujourd'hui"
        _tz_offset_h = 2  # Tunisie : UTC+2 (heure locale de l'utilisateur)
        local_now = now + timedelta(hours=_tz_offset_h)
        since_today = local_now.replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(hours=_tz_offset_h)
        since_month = now - timedelta(days=30)

        # Import des modèles ici pour éviter les imports circulaires
        from app.users.models import User
        from app.qr_bins.models import BinScan
        try:
            from app.collection_points.models import CollectionPoint
            total_centers  = db.query(func.count(CollectionPoint.id)).scalar() or 0
            active_centers = db.query(func.count(CollectionPoint.id)).filter(
                CollectionPoint.status == 'disponible'
            ).scalar() or 0
            centers_sature = db.query(func.count(CollectionPoint.id)).filter(
                CollectionPoint.status == 'saturé'
            ).scalar() or 0
            centers_maintenance = db.query(func.count(CollectionPoint.id)).filter(
                CollectionPoint.status == 'maintenance'
            ).scalar() or 0
        except Exception:
            total_centers  = 0
            active_centers = 0
            centers_sature = 0
            centers_maintenance = 0

        try:
            from app.posts.models import Post
            pending_mod = db.query(func.count(Post.id)).filter(
                Post.status.in_(['pending_ai', 'pending_review'])
            ).scalar() or 0
        except Exception:
            pending_mod = 0

        try:
            from app.community.models import CenterProposal
            pending_proposals = db.query(func.count(CenterProposal.id)).filter(
                CenterProposal.status == 'pending'
            ).scalar() or 0
        except Exception:
            pending_proposals = 0

        try:
            from app.community.models import Testimonial
            pending_testimonials = db.query(func.count(Testimonial.id)).filter(
                Testimonial.is_approved == False  # noqa: E712
            ).scalar() or 0
        except Exception:
            pending_testimonials = 0

        # Statistiques utilisateurs
        total_users  = db.query(func.count(User.id)).scalar() or 0
        # Utilisateurs ayant effectué au moins 1 scan cette semaine
        active_users_week = db.query(
            func.count(func.distinct(BinScan.user_id))
        ).filter(
            BinScan.scanned_at >= since_week
        ).scalar() or 0
        # Nouveaux inscrits ce mois
        new_users_month = db.query(func.count(User.id)).filter(
            User.created_at >= since_month
        ).scalar() or 0
        avg_score = db.query(func.avg(User.global_score)).scalar() or 0.0

        # Statistiques scans citoyens — PostgreSQL
        total_scans   = db.query(func.count(BinScan.id)).scalar() or 0
        scans_today   = db.query(func.count(BinScan.id)).filter(
            BinScan.scanned_at >= since_today
        ).scalar() or 0
        scans_week    = db.query(func.count(BinScan.id)).filter(
            BinScan.scanned_at >= since_week
        ).scalar() or 0
        points_total  = db.query(func.sum(BinScan.points_earned)).scalar() or 0.0

        # ── Enrichissement depuis Firebase /scans/ + /scores/ + /poubelles/ ──
        # L'Arduino écrit chaque scan dans Firebase /scans/ avec :
        #   { binId, userKey, role, points, timestamp, fillPct, weightKg }
        # PROBLÈME : beaucoup de /scans/ ont des timestamps numériques Arduino
        # (millis) qui ne sont pas des dates exploitables.
        # SOLUTION : on complète avec /scores/{uid}/last_scan pour la récence
        # et /poubelles/ pour détecter les collectes récentes.
        fb_total_collections = 0
        fb_collections_week  = 0
        try:
            # ── 1) Compter depuis /scans/ (totaux + dates parsables) ──
            all_fb_scans = rtdb.reference("scans").get() or {}
            fb_citizen_total   = 0
            fb_citizen_today   = 0
            fb_citizen_week    = 0
            fb_collector_total = 0
            fb_collector_week  = 0

            for scan_key, scan_data in all_fb_scans.items():
                if not isinstance(scan_data, dict):
                    continue

                role = scan_data.get("role", "user")
                ts_raw = scan_data.get("timestamp", "")

                # Parser le timestamp (ISO string uniquement)
                scan_dt = None
                if isinstance(ts_raw, str) and len(ts_raw) > 8:
                    try:
                        scan_dt = datetime.fromisoformat(
                            ts_raw.replace("+00:00", "").replace("Z", "")
                        )
                    except Exception:
                        pass
                # Clé du scan = parfois un timestamp ISO (ex: "2026-07-11T18:57:14")
                if scan_dt is None and isinstance(scan_key, str) and len(scan_key) > 8 and "T" in scan_key:
                    try:
                        scan_dt = datetime.fromisoformat(
                            scan_key.replace("+00:00", "").replace("Z", "")
                        )
                    except Exception:
                        pass

                is_citizen   = role in ("user", "citoyen")
                is_collector = role == "collector"

                if is_citizen:
                    fb_citizen_total += 1
                    if scan_dt:
                        if scan_dt >= since_today:
                            fb_citizen_today += 1
                        if scan_dt >= since_week:
                            fb_citizen_week += 1
                elif is_collector:
                    fb_collector_total += 1
                    if scan_dt and scan_dt >= since_week:
                        fb_collector_week += 1

            # ── 2) Compléter avec /scores/ pour la récence ──
            # Beaucoup de /scans/ ont des timestamps Arduino numériques non
            # datables. On lit /scores/{uid}/last_scan pour détecter les
            # utilisateurs ayant scanné récemment.
            all_scores = rtdb.reference("scores").get() or {}
            fb_points = 0.0
            fb_users_today = 0
            fb_users_week  = 0

            for uid, data in all_scores.items():
                if not isinstance(data, dict):
                    continue
                fb_points += float(data.get("total", 0))
                last_scan_str = data.get("last_scan", data.get("last_activity", ""))
                if last_scan_str:
                    try:
                        ls = str(last_scan_str).replace("+00:00", "").replace("Z", "")
                        last_dt = datetime.fromisoformat(ls)
                        if last_dt >= since_today:
                            fb_users_today += 1
                        if last_dt >= since_week:
                            fb_users_week += 1
                    except Exception:
                        pass

            # Combiner : utiliser le MAX de /scans/ datés ET /scores/ récence
            fb_citizen_today = max(fb_citizen_today, fb_users_today)
            fb_citizen_week  = max(fb_citizen_week, fb_users_week)

            # ── 3) Collectes récentes depuis /poubelles/ ──
            # Quand BIN-GENERAL passe à "vide" avec poids=0, c'est une collecte.
            # On regarde derniere_mise_a_jour pour les collectes récentes.
            try:
                all_bins = rtdb.reference("poubelles").get() or {}
                for bcode, bdata in all_bins.items():
                    if not isinstance(bdata, dict):
                        continue
                    etat = bdata.get("etat", "")
                    maj_str = bdata.get("derniere_mise_a_jour", "")
                    if etat == "vide" and maj_str:
                        try:
                            maj = datetime.fromisoformat(
                                str(maj_str).replace("+00:00", "").replace("Z", "")
                            )
                            if maj >= since_week:
                                fb_collector_week += 1
                        except Exception:
                            pass
            except Exception:
                pass

            # Utiliser le MAX entre PostgreSQL et Firebase
            total_scans  = max(total_scans, fb_citizen_total)
            scans_today  = max(scans_today, fb_citizen_today)
            scans_week   = max(scans_week, fb_citizen_week)
            points_total = max(float(points_total), fb_points)
            fb_total_collections = fb_collector_total
            fb_collections_week  = fb_collector_week

        except Exception:
            pass  # Firebase indisponible : on garde les valeurs PostgreSQL

        # Statistiques collecteurs — PostgreSQL + Firebase
        try:
            from app.qr_bins.models import CollectorLog
            pg_collections   = db.query(func.count(CollectorLog.id)).scalar() or 0
            pg_coll_week     = db.query(func.count(CollectorLog.id)).filter(
                CollectorLog.collected_at >= since_week
            ).scalar() or 0
            total_collections = max(pg_collections, fb_total_collections)
            collections_week  = max(pg_coll_week, fb_collections_week)
        except Exception:
            total_collections = fb_total_collections
            collections_week  = fb_collections_week


        stats = {
            # Utilisateurs
            "total_users":          int(total_users),
            "active_users_week":    int(active_users_week),
            "new_users_month":      int(new_users_month),
            "average_score":        round(float(avg_score), 2),
            # Scans citoyens
            "total_scans":          int(total_scans),
            "scans_today":          int(scans_today),
            "scans_week":           int(scans_week),
            "points_distributed":   round(float(points_total), 2),
            # Collectes
            "total_collections":    int(total_collections),
            "collections_week":     int(collections_week),
            # Modération
            "pending_moderation":   int(pending_mod),
            "pending_testimonials": int(pending_testimonials),
            "pending_proposals":    int(pending_proposals),
            # Centres
            "total_centers":        int(total_centers),
            "active_centers":       int(active_centers),
            "centers_disponible":   int(active_centers),
            "centers_sature":      int(centers_sature),
            "centers_maintenance": int(centers_maintenance),
            "last_updated":         datetime.now(timezone.utc).isoformat(),
        }

        ref = rtdb.reference("admin_stats")
        ref.set(stats)
        _safe_print(f"[Firebase] [OK] admin_stats mis à jour : {total_scans} scans, {total_users} users")
        return True

    except Exception as e:
        _safe_print(f"[Firebase] [ERREUR] update_admin_stats : {e}")
        traceback.print_exc()
        return False


def notify_new_message(receiver_id: int, sender_name: str, content: str,
                       sender_id: int, msg_type: str = "message",
                       group_id: int = None, group_name: str = None) -> bool:
    """
    Ecrit une notification de message dans Firebase RTDB.
    Structure : /notifications/{receiver_id}/new_message
    L'app Flutter ecoute ce noeud et affiche une notification locale.
    Compatible Huawei EMUI (pas besoin de Google Play Services).
    """
    if not _init_firebase():
        return False
    try:
        from firebase_admin import db as rtdb
        from datetime import datetime, timezone
        payload = {
            "type": msg_type,
            "sender_id": sender_id,
            "sender_name": sender_name,
            "preview": content[:100] if content else "",
            "ts": datetime.now(timezone.utc).isoformat(),
        }
        if group_id:
            payload["group_id"] = group_id
        if group_name:
            payload["group_name"] = group_name

        ref = rtdb.reference(f"/notifications/{receiver_id}/new_message")
        ref.set(payload)
        _safe_print(f"[Firebase] Notif message ecrite pour user {receiver_id}")
        return True
    except Exception as e:
        _safe_print(f"[Firebase] Erreur notify_new_message : {e}")
        return False