"""
EcoRewind -- CNN Moderator (Text CNN + ResNet18)
================================================
Remplace/complète ai_moderator.py avec des modèles CNN
entraînés spécifiquement sur les publications citoyennes EcoRewind.

Pipeline complet :
  Couche 0 : Règles (mots-clés FR/AR/EN)        -- toujours actif, < 1ms
  Couche 1 : Text CNN (EcoTextCNN)               -- ~5ms, CPU
  Couche 2 : ResNet18 fine-tuné (image)          -- ~20ms, CPU
  Couche 3 : NudeNet (NSFW images)               -- ~100ms (optionnel)

Seuils de décision CNN :
  P(toxic)    ≥ 0.50 → REJECTED
  P(eco)      ≥ 0.60 → PUBLISHED
  P(off_topic)≥ 0.55 → PENDING_REVIEW
  else               → PENDING_REVIEW (précaution)
"""

import os
import sys
import time
import json
from typing import Optional

# ── Résolution path backend ───────────────────────────────────────────────────
# __file__ = backend/moderation_ai/eco_moderator.py
# _BACKEND  = backend/   (remonter d'un niveau depuis moderation_ai/)
_BACKEND = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, _BACKEND)

from services.ai_moderator import (
    AIModerator, ModerationResult, ModerationStatus,
    SAFE_THRESHOLD, REVIEW_THRESHOLD,
)

# ── Seuils CNN ────────────────────────────────────────────────────────────────
CNN_ECO_THRESHOLD      = 0.45   # -> publie (seuil abaisse pour eco dominant)
CNN_OFFTOPIC_THRESHOLD = 0.55   # -> REJETE si image hors-sujet (vetements, maquillage, violence...)
CNN_TOXIC_THRESHOLD    = 0.50   # -> rejete (texte)
CNN_NSFW_THRESHOLD     = 0.45   # -> rejete (contenu violent/NSFW detecte par ResNet18)


class EcoCNNModerator(AIModerator):
    """
    Moderator augmenté avec Text CNN + ResNet18 entraînés sur mesure.

    Hérite de AIModerator (règles + Detoxify + CLIP + NudeNet)
    et ajoute les couches CNN custom en remplacement/complément.
    """

    def __init__(self, rules_only: bool = False):
        # Initialise les couches règles (+ optionnellement les modèles pré-entraînés)
        super().__init__(rules_only=rules_only)
        self._text_cnn   = None
        self._img_resnet = None
        self._cnn_ready  = False
        if not rules_only:
            self._load_cnn_models()

    def _load_cnn_models(self):
        """Charge Text CNN et ResNet18 (silencieux si pas encore entraînés)."""
        # ── Text CNN ─────────────────────────────────────────────────────────
        try:
            from moderation_ai.text_cnn_model import TextCNNClassifier
            self._text_cnn = TextCNNClassifier()
            self._cnn_ready = True
            print("[CNN] [OK] Text CNN (EcoTextCNN) chargé")
        except FileNotFoundError:
            print("[CNN] [WARN]  Text CNN non trouvé -- lancez train_text_cnn.py")
        except Exception as e:
            print(f"[CNN] [ERR] Erreur Text CNN : {e}")

        # ── ResNet18 ─────────────────────────────────────────────────────────
        try:
            from moderation_ai.image_resnet_model import ImageResNetClassifier
            self._img_resnet = ImageResNetClassifier()
            self._cnn_ready  = True
            print("[CNN] [OK] ResNet18 (image eco-classifier) chargé")
        except FileNotFoundError:
            print("[CNN] [WARN]  ResNet18 non trouvé -- lancez train_image_resnet.py")
        except Exception as e:
            print(f"[CNN] [ERR] Erreur ResNet18 : {e}")

    # ── Analyse texte enrichie ────────────────────────────────────────────────

    def analyze_text(self, text: str) -> dict:
        """
        Couche 0 (règles) + Couche 1 (Text CNN) fusionnées.
        Le score CNN prime sur le score règles si le modèle est disponible.
        """
        result = super().analyze_text(text)   # Règles + Detoxify + XLM-RoBERTa

        if self._text_cnn and text and text.strip():
            try:
                probs = self._text_cnn.predict(text)
                result["categories"]["cnn_text"] = {
                    **probs,
                    "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)",
                }
                result["cnn_probs"] = probs
                result["ml_used"]   = True

                # ── Ajustement du score final via CNN ─────────────────────────
                if probs["toxic"] >= CNN_TOXIC_THRESHOLD:
                    # CNN détecte du contenu toxique → forcer score élevé
                    result["score"] = max(result["score"], 0.70)
                    result["cnn_decision"] = "toxic"

                elif probs["eco"] >= CNN_ECO_THRESHOLD:
                    # CNN détecte du contenu éco → alléger le score
                    result["score"] = min(result["score"], 0.20)
                    result["cnn_decision"] = "eco"

                elif probs["off_topic"] >= CNN_OFFTOPIC_THRESHOLD:
                    # CNN détecte du hors-sujet → pousser vers pending_review
                    result["score"] = max(result["score"], SAFE_THRESHOLD + 0.05)
                    result["cnn_decision"] = "off_topic"

                else:
                    result["cnn_decision"] = "uncertain"

            except Exception as e:
                print(f"[CNN] [WARN]  Erreur Text CNN inférence : {e}")

        return result

    # ── Analyse image enrichie ────────────────────────────────────────────────

    def analyze_image(self, image_path: str) -> dict:
        """
        Couche NudeNet (héritée) + Couche 2 (ResNet18 custom) fusionnées.
        """
        result = super().analyze_image(image_path)   # NudeNet + CLIP

        if self._img_resnet and image_path and os.path.exists(image_path):
            try:
                probs = self._img_resnet.predict(image_path)
                result["categories"]["resnet_image"] = {
                    **probs,
                    "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)",
                }
                result["resnet_probs"] = probs
                result["ml_used"]      = True

                # ── Ajustement du score image via ResNet18 (logique argmax) ──────────
                eco_p  = probs.get("eco", 0)
                off_p  = probs.get("off_topic", 0)
                nsfw_p = probs.get("nsfw", 0)

                # Priorité 1 : NSFW → rejet immédiat (indépendant des autres)
                if nsfw_p >= CNN_NSFW_THRESHOLD:
                    result["score"] = 0.95
                    result["resnet_decision"] = "nsfw"
                    result["categories"]["nsfw"] = {
                        "score": nsfw_p, "severity": "high", "source": "ResNet18-CNN",
                    }

                # Priorité 2 : Eco dominant (argmax) → lever les pénalités
                # FIX: vérifie que eco EST la classe majoritaire, pas juste un seuil absolu
                elif eco_p >= off_p and eco_p >= CNN_ECO_THRESHOLD:
                    result["score"] = min(result["score"], 0.15)
                    result["resnet_decision"] = "eco"

                # Priorité 3 : Off-topic clairement dominant ET au-dessus du seuil relevé
                elif off_p >= CNN_OFFTOPIC_THRESHOLD and off_p > eco_p:
                    result["score"] = max(result["score"], 0.45)
                    result["resnet_decision"] = "off_topic"
                    result["categories"]["off_topic_image"] = {
                        "score": off_p, "severity": "medium",
                        "source": "ResNet18-CNN",
                        "description": "Image hors-sujet detectable (en attente validation admin)",
                    }

                # Cas incertain
                else:
                    if eco_p < 0.40:
                        result["score"] = max(result["score"], SAFE_THRESHOLD + 0.05)
                    result["resnet_decision"] = "uncertain"

            except Exception as e:
                print(f"[CNN] [WARN]  Erreur ResNet18 inférence : {e}")

        return result

    # ── Pipeline final : correction CNN éco ──────────────────────────────────

    def moderate(self, text: str = "", image_local_path: str = "") -> "ModerationResult":
        """
        Override de AIModerator.moderate() :
        Corrige les faux positifs quand ResNet18 ou EcoTextCNN confirme
        un contenu éco-pertinent, annulant les pénalités de contexte.

        Cas typique : "Bonjour !" + photo de nettoyage de plage
          → parent : score=0.60 pending_review (pénalité texte+image sans contexte eco)
          → ici      : score=0.10 published (ResNet18 confirme image éco → pénalités levées)
        """
        import time
        t0 = time.time()

        # Exécuter le pipeline parent (règles + Detoxify + scoring de base)
        result = super().moderate(text=text, image_local_path=image_local_path)

        # ── Récupérer les décisions CNN ───────────────────────────────────────
        cnn_text_decision = result.text_analysis.get("cnn_decision", "uncertain")
        cnn_img_decision  = result.image_analysis.get("resnet_decision", "uncertain")
        cnn_text_probs    = result.text_analysis.get("cnn_probs", {})
        cnn_img_probs     = result.image_analysis.get("resnet_probs", {})

        toxic_txt = cnn_text_probs.get("toxic", 0.0)
        nsfw_img  = cnn_img_probs.get("nsfw",  0.0)
        off_img   = cnn_img_probs.get("off_topic", 0.0)
        eco_img   = cnn_img_probs.get("eco",   0.0)

        # ── NSFW image : rejet automatique ───────────────────────────────────
        if cnn_img_decision == "nsfw":
            result.score  = 0.95
            result.status = ModerationStatus.REJECTED.value
            result.processing_time_ms = round((time.time() - t0) * 1000, 2)
            return result

        # ── Déterminer si le texte PROMEUT une action éco ────────────────────
        # Pour primer sur une image off_topic (pollution, décharge...), le texte
        # doit EXPLICITEMENT promouvoir une amélioration, réparation ou protection
        # de l'environnement. Décrire simplement le problème ne suffit pas.
        #   OK  : "Nettoyons cette plage !", "Recyclons ensemble"
        #   NOK : "La pollution est terrible", "Quelle honte cette décharge"
        from services.ai_moderator import _normalize as _norm
        norm_text_full = _norm(text or "")

        # Racines de verbes/noms d'ACTION éco (conjugaison-agnostique)
        _ECO_ACTION_STEMS = [
            # Nettoyage / ramassage
            "nettoy",      # nettoyer, nettoyage, nettoyons, nettoyee...
            "ramass",      # ramasser, ramassage, ramassons...
            "depollut",    # depollution, depolluer
            "depollu",     # depolluer
            # Recyclage / tri
            "recycl",      # recycler, recyclage, recyclons...
            "trier", "trions", "tri selectif", "tri des",
            "compost",     # composter, compostage...
            # Protection / préservation
            "proteg",      # proteger, protegeons, protegez...
            "preserv",     # preserver, preservation...
            "sauvegard",   # sauvegarder, sauvegardons...
            # Plantation / reboisement
            "plant",       # planter, plantons, plantation...
            "rebois",      # reboiser, reboisement...
            "reforest",    # reforestation...
            # Mobilisation / appels à l'action
            "agissons", "mobilisons", "mobilisez", "engageons",
            "venez", "rejoignez", "participez",
            # Verbes d'arrêt / lutte
            "doit cesser", "arretons", "luttons", "combattons",
            "stop a la",
            # Propreté (nom d'action)
            "proprete",
            # Réduction / réutilisation
            "reduire", "reutilis",   # reutiliser, reutilisable...
            "zero dechet",
            # Énergie renouvelable (installation = action)
            "solaire", "eolien", "panneau",
        ]
        text_promotes_action = any(
            stem in norm_text_full for stem in _ECO_ACTION_STEMS
        )

        # ── Image off_topic + Texte d'ACTION éco → PUBLISHED ─────────────────
        # Une image négative (pollution, décharge, ordures) accompagnée d'un texte
        # qui PROMEUT activement l'amélioration (nettoyage, recyclage, protection)
        # est un acte citoyen valide.
        # Exemple OK  : photo de plage polluée + "Nettoyons ensemble notre littoral !"
        # Exemple NOK : photo de plage polluée + "C'est dégueulasse ici"
        if cnn_img_decision == "off_topic" and text_promotes_action:
            if toxic_txt < CNN_TOXIC_THRESHOLD and nsfw_img < CNN_NSFW_THRESHOLD:
                result.reasons = [
                    r for r in result.reasons
                    if "sans contexte environnemental" not in r
                    and "hors sujet" not in r.lower()
                ]
                result.score  = min(result.score, 0.20)
                result.status = ModerationStatus.PUBLISHED.value
                result.processing_time_ms = round((time.time() - t0) * 1000, 2)
                return result

        # ── Image off_topic (sans texte éco) → PENDING_REVIEW ────────────────
        if cnn_img_decision == "off_topic":
            result.score  = max(result.score, 0.45)  # zone pending
            result.status = ModerationStatus.PENDING_REVIEW.value
            off_reason = "Contenu hors sujet detecte : image non liee a l'environnement (validation admin requise)"
            if off_reason not in result.reasons:
                result.reasons.append(off_reason)
            result.processing_time_ms = round((time.time() - t0) * 1000, 2)
            return result

        # ── Image éco + Texte d'ACTION → PUBLISHED ─────────────────────────
        # Même quand ResNet18 confirme l'image comme éco (nature, recyclage...),
        # le TEXTE doit AUSSI promouvoir une action concrète d'amélioration.
        #   OK  : photo nature + "Protegeons notre environnement !"
        #   NOK : photo nature + "bonjour" (salutation seule = pending_review)
        #   NOK : photo pollution + "bonjour" (pas d'action = pending_review)
        if (
            cnn_img_decision == "eco"
            and nsfw_img  < CNN_NSFW_THRESHOLD
            and eco_img   > off_img          # eco EST dominant sur off_topic
            and text_promotes_action          # texte PROMEUT une action éco
        ):
            # Supprimer TOUTES les pénalités textuelles (image + texte action = valide)
            result.reasons = [
                r for r in result.reasons
                if "sans contexte environnemental" not in r
                and "hors sujet" not in r.lower()
                and "contenu potentiellement inapproprie" not in r.lower()
            ]
            result.score  = min(result.score, 0.20)
            result.status = ModerationStatus.PUBLISHED.value
            result.processing_time_ms = round((time.time() - t0) * 1000, 2)
            return result

        # ── Image éco SANS texte d'action → PENDING_REVIEW ────────────────
        # L'image est eco mais le texte est une salutation/neutre :
        # l'admin doit valider manuellement.
        if cnn_img_decision == "eco" and not text_promotes_action:
            result.score  = max(result.score, 0.40)
            result.status = ModerationStatus.PENDING_REVIEW.value
            pending_reason = "Image positive detectee mais texte sans action eco (validation admin requise)"
            if pending_reason not in result.reasons:
                result.reasons.append(pending_reason)
            result.processing_time_ms = round((time.time() - t0) * 1000, 2)
            return result

        result.processing_time_ms = round((time.time() - t0) * 1000, 2)
        return result


# ─────────────────────────────────────────────────────────────────────────────
# Singleton lazy (utilisé par routers/posts.py)
# ─────────────────────────────────────────────────────────────────────────────

_cnn_moderator_instance: Optional[EcoCNNModerator] = None


def get_cnn_moderator() -> EcoCNNModerator:
    """Retourne le singleton EcoCNNModerator, chargé au premier appel."""
    global _cnn_moderator_instance
    if _cnn_moderator_instance is None:
        _cnn_moderator_instance = EcoCNNModerator()
    return _cnn_moderator_instance


class _LazyCNNModerator:
    """Proxy transparent -- instancie EcoCNNModerator au premier accès."""
    _obj = None

    def _ensure(self):
        if self._obj is None:
            self._obj = get_cnn_moderator()

    def __getattr__(self, name):
        self._ensure()
        return getattr(self._obj, name)

    def moderate(self, *args, **kwargs):
        self._ensure()
        return self._obj.moderate(*args, **kwargs)


# Alias utilisable par les routers :
#   from moderation_ai.eco_moderator import cnn_moderator
cnn_moderator = _LazyCNNModerator()
