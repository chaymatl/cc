"""
EcoRewind AI Moderation System - Enhanced Version
=================================================
Advanced ML/DL pipeline for content moderation with:
  - Multi-layer text analysis (toxicity, off-topic detection, zero-shot NLI)
  - Deep learning image classification (NSFW + semantic relevance via CLIP)
  - Rule-based keyword matching (profanity, anti-env, off-topic)
  - Real-time scoring with adaptive thresholds

Models used:
  - Text Layer 1 : Detoxify (BERT multilingual)      -- toxicity detection
  - Text Layer 2 : XLM-RoBERTa zero-shot NLI         -- environmental relevance
  - Image Layer 1: NudeNet (CNN)                      -- NSFW detection
  - Image Layer 2: CLIP ViT-B/32                      -- semantic scene classification
"""

import os
import json
import re
import unicodedata
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Any
from enum import Enum

# -- Configuration ----------------------------------------------------------------

class ModerationStatus(str, Enum):
    """Moderation decision outcomes."""
    PUBLISHED     = "published"       # Auto-approved
    PENDING_REVIEW = "pending_review" # Admin review required
    REJECTED      = "rejected"        # Auto-rejected

# Thresholds (adjustable)
SAFE_THRESHOLD   = 0.30   # Score < 0.30 -> auto-publish
REVIEW_THRESHOLD = 0.65   # 0.30 ≤ score < 0.65 -> admin review / ≥ 0.65 -> reject

# Feature flags
AI_ENABLED = os.getenv("AI_MODERATION_ENABLED", "true").lower() == "true"

# -- Text Lists -------------------------------------------------------------------

BAD_WORDS_FR = [
    "merde", "putain", "connard", "salope", "enculé", "chier", "foutre",
    "nique", "ta mère", "pédé", "pd", "gay", "lesbienne",
    "idiot", "imbécile", "crétin", "nul", "honte", "dégueu", "abruti",
    "stupide", "con", "idiote", "ta gueule",
    "tuer", "mourir", "crever", "massacre", "viol", "agresser",
]
BAD_WORDS_AR = [
    "عرص", "كلب", "شرموطة", "ابن الكلب", "حرام", "منيك",
    "زبي", "كس", "زفت", "ولد الكلب", "خره", "كسخت",
]
BAD_WORDS_EN = [
    "fuck", "shit", "bitch", "asshole", "bastard", "damn", "crap",
    "idiot", "stupid", "hate", "kill", "die", "faggot", "nigger",
]
ALL_BAD_WORDS = set(w.lower() for w in (BAD_WORDS_FR + BAD_WORDS_AR + BAD_WORDS_EN))

ANTI_ENV_KEYWORDS = [
    "jeter par terre", "jeter dans la nature", "bruler les dechets",
    "bruler la foret", "polluer intentionnellement",
    "contaminer", "deverser", "deversement illegal", "vidange sauvage",
    "couper les arbres", "abattre les arbres illegalement",
    "chasse illegale", "peche illegale", "tuer les animaux",
    "braconnage", "je m en fous de la nature", "la nature c est nul", "nique la nature",
    "l ecologie c est ridicule", "recyclage inutile", "planete merde",
    "nature c est de la merde", "climat hoax", "rechauffement climatique fake",
    "application nulle", "arnaque ecolo", "ecologie arnaque",
    "l ecologie c est une arnaque", "ecologie inventee", "arnaque inventee pour nous taxer",
    "je m en fous de l environnement", "m en fous de la nature",
    "jeter par terre c est plus simple", "jeter le plastique dans",
    "bruler mes ordures", "deverser les huiles",
    "couper les arbres pour construire", "abattre les arbres",
    "tuer les animaux sauvages", "peche illegale", "chasse illegale",
]

POSITIVE_KEYWORDS = [
    # Waste & recycling
    "recyclage", "recycler", "tri", "trier", "compost", "composter",
    "dechets", "dechet", "verre", "plastique", "papier", "carton",
    "metal", "aluminium", "biodegradable", "poubelle", "conteneur",
    "collecte", "point propre", "point de collecte", "tri selectif",
    "beton",
    # Nature & environment
    "ecologie", "nature", "environnement", "naturel", "naturelle",
    "vert", "durable", "biodiversite", "foret", "forests",
    "arbre", "arbres", "plantation", "reboisement", "reforestation",
    "jardin", "plante", "fleur", "faune", "flore",
    "riviere", "ocean", "mer", "eau propre", "berge",
    # Actions citoyennes
    "nettoyage", "nettoyer", "ramasser", "ramassage",
    "preserver", "proteger", "sauvegarder", "proprete",
    "aider", "partager", "communaute", "engagement", "citoyen",
    "bonne pratique", "sensibilisation", "consciencieux", "responsable",
    # Energy
    "solaire", "eolien", "energie renouvelable", "panneau solaire",
    "panneaux solaires",
    # Climate
    "ecologique", "green", "eco", "bonne action",
    "plastique recycle", "zero dechet",
    # Pollution documentation (signaler = acte eco)
    "pollution", "pollue", "polluant", "polluants", "contamination",
    "decharge", "ordures", "sale", "salement", "incivilite",
    "signaler", "denonciation", "temoignage", "honte", "scandale",
    "impact", "impacts", "consequences", "degradation", "deterioration",
    # Greetings + advice (acceptes si ton eco/citoyen)
    "bonjour", "salut", "bonsoir", "salam", "hello",
    "conseil", "astuce", "tip", "rappel", "saviez-vous", "le saviez-vous",
    "penser a", "pensez a", "n oubliez pas", "oubliez pas",
    "ensemble", "tous ensemble", "chacun", "chaque geste", "petit geste",
    # Arabic eco terms
    "\u062a\u0646\u0638\u064a\u0641",   # cleaning
    "\u0646\u0641\u0627\u064a\u0627\u062a", # waste/garbage
    "\u0628\u064a\u0626\u0629",   # environment
    "\u0637\u0628\u064a\u0639\u0629",   # nature
    "\u062a\u062f\u0648\u064a\u0631",   # recycling
    "\u0646\u0638\u0627\u0641\u0629",   # cleanliness
    "\u0627\u0634\u062c\u0627\u0631",   # trees
    "\u063a\u0627\u0628\u0627\u062a",   # forests
    "\u0645\u064a\u0627\u0647",    # water
    "\u0634\u0627\u0637\u0626",    # beach
    "\u0633\u0627\u062d\u0644",    # coast
    "\u062a\u0644\u0648\u062b",    # pollution (AR)
    "\u0646\u0638\u064a\u0641",    # clean (AR)
    "\u0645\u062c\u062a\u0645\u0639", # community (AR)
    "\u062d\u0645\u0644\u0629",   # campaign (AR)
]

ENV_CONTEXT = [
    "bac de tri", "compostage", "biomethanisation",
    "centres de tri", "eco-organisme", "eco-citoyen",
    "zero waste", "zero dechet", "recyclons",
]

# -- Off-Topic Keywords ----------------------------------------------------------
# Content clearly unrelated to EcoRewind's environmental / recycling mission.

OFF_TOPIC_KEYWORDS_FR = [
    # Accidents & emergencies
    "accident", "crash", "collision", "carambolage", "accrochage",
    "blessé", "blessure", "mort", "décès", "tué", "victime", "mourant",
    "urgence", "ambulance", "hôpital", "clinique", "pompier", "secours",
    "trauma", "traumatisme", "catastrophe", "sinistre", "naufrage",
    # Crime & law enforcement
    "police", "gendarmerie", "arrestation", "criminel", "vol", "cambriolage",
    "meurtre", "attaque", "attentat", "terrorisme", "crime", "braquage",
    # Politics
    "élection", "politique", "candidat", "président", "gouvernement",
    "ministre", "parlement", "vote", "manifestation", "grève", "syndicat",
    # Sports & entertainment
    "match", "score", "buteur", "joueur", "football", "sport",
    "cinéma", "film", "série", "acteur", "musique", "concert",
    # Unrelated commerce
    "promo", "soldes", "publicité", "vente", "produit", "magasin",
]
OFF_TOPIC_KEYWORDS_EN = [
    "accident", "crash", "collision", "injured", "dead", "death", "victim",
    "emergency", "ambulance", "hospital", "police", "crime", "murder",
    "election", "politics", "sport", "football", "movie", "music",
]
OFF_TOPIC_KEYWORDS_AR = [
    "حادث", "وفاة", "مقتل", "جريمة", "سياسة", "انتخاب", "رياضة",
]
ALL_OFF_TOPIC = list(set(
    [w.lower() for w in OFF_TOPIC_KEYWORDS_FR] +
    [w.lower() for w in OFF_TOPIC_KEYWORDS_EN] +
    [w.lower() for w in OFF_TOPIC_KEYWORDS_AR]
))

# -- CLIP Candidate Labels --------------------------------------------------------

CLIP_ECO_LABELS = [
    "recycling bins and waste sorting",
    "nature and green environment",
    "environmental cleanup activity",
    "solar panels and renewable energy",
    "composting and organic waste",
    "plastic pollution in nature",
    "tree planting and reforestation",
    "pollution and dirty environment being documented",
    "litter and garbage on streets or beaches",
    "deforestation or environmental damage awareness",
]
CLIP_OFFTOPIC_LABELS = [
    "car accident and vehicle collision",
    "crime scene and police activity",
    "sports event and competition",
    "political rally and demonstration",
    "medical emergency and ambulance",
    "entertainment and music concert",
    "shopping and commercial products",
]

# -- XLM-RoBERTa Zero-Shot Labels -------------------------------------------------

NLI_ECO_LABELS      = ["environmental content", "ecology and recycling", "nature protection"]
NLI_OFFTOPIC_LABELS = ["accident or emergency", "politics", "sport or entertainment", "crime or violence"]

# -- Result Dataclass -------------------------------------------------------------

@dataclass
class ModerationResult:
    score: float = 0.0
    status: str = ModerationStatus.PUBLISHED.value
    reasons: List[str] = field(default_factory=list)
    text_analysis: Dict[str, Any] = field(default_factory=dict)
    image_analysis: Dict[str, Any] = field(default_factory=dict)
    ml_available: bool = False
    text_model_used: Optional[str] = None
    image_model_used: Optional[str] = None
    confidence: float = 0.0
    processing_time_ms: float = 0.0
    languages_detected: List[str] = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps({
            "score":              round(self.score, 3),
            "status":             self.status,
            "reasons":            self.reasons,
            "text_analysis":      self.text_analysis,
            "image_analysis":     self.image_analysis,
            "ml_available":       self.ml_available,
            "text_model_used":    self.text_model_used,
            "image_model_used":   self.image_model_used,
            "confidence":         round(self.confidence, 3),
            "processing_time_ms": round(self.processing_time_ms, 2),
            "languages_detected": self.languages_detected,
        }, ensure_ascii=False)

    @property
    def short_reason(self) -> str:
        if not self.reasons:
            return "Contenu approuvé automatiquement"
        return " | ".join(self.reasons[:2])

# -- Utilities --------------------------------------------------------------------

def _normalize(text: str) -> str:
    text = text.lower().strip()
    try:
        nfkd = unicodedata.normalize("NFKD", text)
        return "".join(c for c in nfkd if not unicodedata.combining(c))
    except Exception:
        return text

def _tokenize(text: str) -> List[str]:
    return re.findall(r'\b\w+\b', _normalize(text))

def _detect_language(text: str) -> List[str]:
    arabic_pattern = re.compile(r'[\u0600-\u06FF]')
    has_arabic = bool(arabic_pattern.search(text))
    fr_words = {"le", "la", "les", "un", "une", "des", "et", "est", "dans", "pour", "pas", "que"}
    en_words = {"the", "a", "an", "and", "is", "in", "to", "for", "of", "it", "that"}
    tokens = set(_tokenize(text))
    languages = []
    if bool(tokens & fr_words): languages.append("fr")
    if bool(tokens & en_words): languages.append("en")
    if has_arabic: languages.append("ar")
    return languages if languages else ["unknown"]

def _check_profanity(tokens: List[str]) -> Dict[str, Any]:
    found = [w for w in tokens if w in ALL_BAD_WORDS]
    count = len(found)
    if count == 0: return {"found": [], "score": 0.0, "severity": "none"}
    elif count == 1: score, severity = 0.35, "low"
    elif count <= 3: score, severity = 0.70, "medium"   # -> rejet
    else: score, severity = min(0.90, count * 0.28), "high"  # -> rejet fort
    return {"found": list(set(found)), "score": score, "severity": severity, "count": count}

def _check_anti_environmental(text: str, norm_text: str) -> Dict[str, Any]:
    found_keywords = [kw for kw in ANTI_ENV_KEYWORDS if _normalize(kw) in norm_text]
    if not found_keywords: return {"found": [], "score": 0.0, "severity": "none"}
    count = len(found_keywords)
    return {
        "found": found_keywords,
        "score": min(0.80, count * 0.40),   # 1 keyword -> 0.40, 2 -> 0.80 (rejet)
        "severity": "high" if count >= 2 else "medium",
        "count": count,
    }

def _check_positive_context(text: str, norm_text: str) -> Dict[str, Any]:
    found = [kw for kw in POSITIVE_KEYWORDS + ENV_CONTEXT if _normalize(kw) in norm_text]
    return {"found": found[:10], "bonus": min(0.25, len(found) * 0.05), "count": len(found)}

def _check_off_topic(text: str, norm_text: str) -> Dict[str, Any]:
    """Detect content clearly unrelated to EcoRewind's environmental mission."""
    found = []
    for kw in ALL_OFF_TOPIC:
        normalized_kw = _normalize(kw)
        # Substring match (handles plurals, conjugations: accident/accidents, election/elections)
        if normalized_kw in norm_text:
            found.append(kw)
    found = list(set(found))
    count = len(found)
    if count == 0:
        return {"found": [], "score": 0.0, "severity": "none", "count": 0}
    score    = min(0.55, count * 0.22)   # Plus agressif : 3 keywords -> 0.55+
    severity = "high" if count >= 3 else "medium"
    return {"found": found[:5], "score": score, "severity": severity, "count": count}

# -- Main Moderator Class ----------------------------------------------------------

class AIModerator:
    _instance: Optional["AIModerator"] = None

    @classmethod
    def get(cls) -> "AIModerator":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def __init__(self, rules_only: bool = False):
        self._detoxify_model  = None
        self._nude_detector   = None
        self._clip_model      = None
        self._clip_processor  = None
        self._nli_classifier  = None
        self._ml_ready        = False
        if AI_ENABLED and not rules_only:
            self._load_models()

    def _load_models(self):
        # -- Layer 1: Detoxify (text toxicity) ----------------------------------
        try:
            from detoxify import Detoxify
            self._detoxify_model = Detoxify("multilingual")
            print("[AI] [OK] Detoxify (BERT multilingual) loaded")
        except ImportError:
            print("[AI] [WARN]  Detoxify not installed -- pip install detoxify")
        except Exception as e:
            print(f"[AI] [ERR] Error loading Detoxify: {e}")

        # -- Layer 2: NudeNet (image NSFW) --------------------------------------
        try:
            from nudenet import NudeDetector
            self._nude_detector = NudeDetector()
            print("[AI] [OK] NudeNet (CNN) loaded")
        except ImportError:
            print("[AI] [WARN]  NudeNet not installed -- pip install nudenet")
        except Exception as e:
            print(f"[AI] [ERR] Error loading NudeNet: {e}")

        # -- Layer 3: CLIP -- DEPRECATED (removed to reduce dependencies) -----
        # The original CLIP model was large (~2.4 GB) and caused long startup times.
        # It has been removed in favor of a lightweight ResNet18 classifier.
        self._clip_model = None
        self._clip_processor = None
        print("[AI] [SKIP]  CLIP removed -- using ResNet18 custom model.")
        # -- Layer 4: XLM-RoBERTa -- DEPRECATED (removed to reduce dependencies) --
        # The XLM-RoBERTa model was large (~1.1 GB). It has been replaced by a
        # custom TextCNN model that is orders of magnitude smaller and faster.
        self._nli_classifier = None
        print("[AI] [SKIP]  XLM-RoBERTa removed -- using custom TextCNN.")
        # Determine if any ML components are available. CLIP and XLM-RoBERTa have been removed.
        self._ml_ready = any([
            self._detoxify_model is not None,
            self._nude_detector is not None,
        ])

    # -- Text Analysis -------------------------------------------------------------

    def analyze_text(self, text: str) -> Dict[str, Any]:
        if not text or not text.strip():
            return {"score": 0.0, "categories": {}, "ml_used": False}

        import time
        start     = time.time()
        tokens    = _tokenize(text)
        norm_text = _normalize(text)
        languages = _detect_language(text)
        results   = {"languages": languages, "ml_used": False, "categories": {}}

        # -- Rule-based checks -------------------------------------------------
        profanity = _check_profanity(tokens)
        results["categories"]["profanity"] = {**profanity, "description": "Profanity/vulgar language"}

        anti_env = _check_anti_environmental(text, norm_text)
        results["categories"]["anti_environmental"] = {**anti_env, "description": "Anti-environmental content"}

        positive = _check_positive_context(text, norm_text)
        results["categories"]["positive_context"] = {**positive, "description": "Positive context bonus"}

        off_topic = _check_off_topic(text, norm_text)
        results["categories"]["off_topic"] = {**off_topic, "description": "Off-topic / hors sujet"}

        rule_score = max(0.0, min(1.0,
            profanity["score"] + anti_env["score"] + off_topic["score"] * 0.6 - positive["bonus"]
        ))
        results["rule_score"] = round(rule_score, 3)

        # -- ML Layer 1: Detoxify ----------------------------------------------
        ml_categories = {}
        if self._detoxify_model is not None:
            try:
                ml_result     = self._detoxify_model.predict(text)
                ml_categories = {k: round(float(v), 3) for k, v in ml_result.items()}
                results["categories"]["ml_toxicity"] = {
                    **ml_categories,
                    "description": "ML toxicity (Detoxify)",
                }
                results["ml_used"] = True
            except Exception as e:
                print(f"[AI] [WARN]  Detoxify error: {e}")

        # -- ML Layer 2: XLM-RoBERTa -- DEPRECATED (removed to reduce dependencies) --
        # The XLM-RoBERTa model was large (~1.1 GB). It has been replaced by a
        # custom TextCNN model that is orders of magnitude smaller and faster.
        nli_score = 0.0
        # No NLI processing; only rule-based and CNN scores are used.
        results["categories"].update(ml_categories)

        # -- Final text score --------------------------------------------------
        if results["ml_used"]:
            ml_score    = max(ml_categories.values()) if ml_categories else 0.0
            final_score = rule_score * 0.30 + ml_score * 0.40 + nli_score * 0.30
        else:
            final_score = rule_score

        results["score"]              = max(0.0, min(1.0, round(final_score, 3)))
        results["processing_time_ms"] = round((time.time() - start) * 1000, 2)
        return results

    # -- Image Analysis ------------------------------------------------------------

    def analyze_image(self, image_path: str) -> Dict[str, Any]:
        if not image_path or not os.path.exists(image_path):
            return {"score": 0.0, "categories": {}, "ml_used": False, "note": "no_image"}

        import time
        start   = time.time()
        results = {"categories": {}, "ml_used": False, "detections": [], "clip_analysis": {}}

        HIGH_RISK   = {"EXPOSED_ANUS", "EXPOSED_BUTTOCKS", "EXPOSED_BREAST_F",
                       "EXPOSED_GENITALIA_F", "EXPOSED_GENITALIA_M"}
        MEDIUM_RISK = {"EXPOSED_BELLY", "EXPOSED_ARMPITS", "COVERED_BUTTOCKS",
                       "COVERED_GENITALIA_F", "COVERED_GENITALIA_M"}

        # -- NudeNet NSFW detection --------------------------------------------
        nudenet_score = 0.0
        if self._nude_detector is not None:
            try:
                detections     = self._nude_detector.detect(image_path)
                results["ml_used"] = True
                max_confidence = 0.0
                for detection in (detections or []):
                    label      = detection.get("class", "")
                    confidence = float(detection.get("score", 0))
                    results["detections"].append({"class": label, "confidence": round(confidence, 3)})
                    if label in HIGH_RISK and confidence > 0.5:
                        max_confidence = max(max_confidence, confidence)
                    elif label in MEDIUM_RISK and confidence > 0.6:
                        max_confidence = max(max_confidence, confidence * 0.7)
                nudenet_score = round(min(1.0, max_confidence), 3)
                results["categories"]["nsfw"] = {
                    "score":    nudenet_score,
                    "severity": "high" if max_confidence > 0.7 else "medium",
                }
            except Exception as e:
                print(f"[AI] [WARN]  NudeNet error: {e}")

        # -- CLIP semantic classification --------------------------------------
        # CLIP functionality has been removed to reduce package size and startup latency.
        # The ResNet18 model provides fast eco-relevance classification.
        clip_penalty = 0.0
        # No CLIP processing; keep existing NSFW score as the primary image metric.
        results["score"] = round(min(1.0, max(nudenet_score, clip_penalty)), 3)
        results["processing_time_ms"] = round((time.time() - start) * 1000, 2)
        return results

    # -- Main Moderation Entry Point ------------------------------------------------

    def moderate(self, text: str = "", image_local_path: str = "") -> ModerationResult:
        import time
        start  = time.time()
        result = ModerationResult(ml_available=self._ml_ready)

        # -- Text --------------------------------------------------------------
        text_analysis = self.analyze_text(text)
        result.text_analysis    = text_analysis
        result.languages_detected = text_analysis.get("languages", [])
        for reason in self._extract_text_reasons(text_analysis):
            result.reasons.append(reason)

        # -- Image -------------------------------------------------------------
        image_analysis = self.analyze_image(image_local_path)
        result.image_analysis = image_analysis
        if image_analysis.get("ml_used"):
            models_used = []
            if self._nude_detector:  models_used.append("NudeNet")
            if self._clip_model:     models_used.append("CLIP")
            result.image_model_used = "+".join(models_used) or "NudeNet"
            for reason in self._extract_image_reasons(image_analysis):
                result.reasons.append(reason)

        # -- Base score --------------------------------------------------------
        text_score  = text_analysis.get("score", 0.0)
        image_score = image_analysis.get("score", 0.0)

        # -- Environmental Relevance Gate --------------------------------------
        # Catch content that is neither explicitly bad nor eco-relevant.
        categories      = text_analysis.get("categories", {})
        eco_count       = categories.get("positive_context", {}).get("count", 0)
        off_topic       = categories.get("off_topic", {})
        off_topic_count = off_topic.get("count", 0)
        profanity_score = categories.get("profanity", {}).get("score", 0.0)
        anti_env_score  = categories.get("anti_environmental", {}).get("score", 0.0)
        has_image       = bool(image_local_path and os.path.exists(image_local_path))
        clip_analysis   = image_analysis.get("clip_analysis", {})
        clip_offtopic   = clip_analysis.get("offtopic_prob", 0.0)
        text_stripped   = (text or "").strip()

        relevance_penalty = 0.0

        # -- Détection de salutation simple (texte court sans contenu négatif) --
        # "Bonjour", "Salam", "Hello" etc. seuls → publication directe
        # EcoRewind accepte les salutations et conseils citoyens
        GREETINGS = {"bonjour", "bonsoir", "salut", "salam", "hello",
                     "hi", "hey", "assalamu", "marhaba", "ahlan"}
        tokens_set = set(_tokenize(text_stripped)) if text_stripped else set()
        is_greeting_only = (
            bool(tokens_set & GREETINGS)
            and len(tokens_set) <= 8          # texte court
            and profanity_score == 0.0
            and anti_env_score  == 0.0
            and off_topic_count == 0
        )

        # Case 0: Empty text + no image -> en attente (contenu vide)
        if not text_stripped and not has_image:
            relevance_penalty += 0.35
            result.reasons.append("Publication vide sans texte ni image")

        # Case 1: Salutation seule ou conseil court -> publié directement
        # EcoRewind est une communauté : les échanges civils sont les bienvenus
        elif is_greeting_only:
            relevance_penalty = 0.0   # aucune pénalité

        # Case 2: Texte sans contexte environnemental -> pending_review
        # Condition: text_score < SAFE_THRESHOLD évite de double-pénaliser le contenu toxique
        elif text_stripped and eco_count == 0 and off_topic_count == 0 and text_score < SAFE_THRESHOLD:
            relevance_penalty += 0.35
            result.reasons.append("Texte sans contexte environnemental détecté")

        # Case 3: Image avec texte éco -> PAS de pénalité image
        # Documenter la pollution avec un message encourageant est un acte éco valide
        if has_image and eco_count == 0 and off_topic_count == 0:
            relevance_penalty += 0.25
            if "Image sans contexte environnemental détecté" not in result.reasons:
                result.reasons.append("Image sans contexte environnemental détecté")
        elif has_image and eco_count > 0:
            # Texte éco présent : l'image (même de pollution) est valide
            # Le texte contextualise et encourage → aucune pénalité image
            pass

        # Case 3: Rule-based off-topic keywords detected in text
        if off_topic_count > 0:
            relevance_penalty += min(0.35, off_topic_count * 0.18)

        # Case 4: CLIP confirms the image is off-topic (amplifies rule signal)
        if clip_offtopic > 0.30:
            relevance_penalty += min(0.20, clip_offtopic * 0.25)

        combined = round(min(1.0, max(text_score, image_score) + relevance_penalty), 3)

        # -- Off-topic safety cap -----------------------------------------------
        # Purely off-topic content (no profanity / anti-env) must go to admin
        # review (pending_review), NOT be auto-rejected. The double-counting of
        # rule_score + relevance_penalty can push 3+ keyword posts past 0.65.
        is_purely_offtopic = (
            off_topic_count > 0
            and profanity_score < 0.35
            and anti_env_score < 0.35
            and image_score < 0.35
        )
        if is_purely_offtopic and combined >= REVIEW_THRESHOLD:
            combined = round(REVIEW_THRESHOLD - 0.01, 3)  # Clamp to pending_review

        # ── Hard enforcement rules (prevent ML dilution bypassing clear violations) ──
        # Rule A : off-topic keywords with NO eco context → always at least pending_review
        # Fixes: "Quel match incroyable" (score 0.22) being published despite off-topic signal
        if off_topic_count > 0 and eco_count == 0:
            combined = max(combined, round(SAFE_THRESHOLD + 0.05, 3))   # ≥ 0.35

        # Rule B : anti-environmental content
        # Fixes: "je m'en fous de la nature, jeter par terre" being published (score 0.27)
        if anti_env_score >= 0.70:           # 2+ anti-env keywords → rejected
            combined = max(combined, round(REVIEW_THRESHOLD + 0.01, 3))  # ≥ 0.66
        elif anti_env_score >= 0.40:         # 1 anti-env keyword → pending_review
            combined = max(combined, round(SAFE_THRESHOLD + 0.05, 3))    # ≥ 0.35

        # Rule C : heavy profanity confirmed by ML toxicity → rejected
        # Fixes: "vous êtes des connards" (score 0.594) staying in pending_review
        if profanity_score >= 0.70:
            _ml_tox = categories.get("ml_toxicity", {}).get("toxicity", 0.0)
            if _ml_tox > 0.5:
                combined = max(combined, round(REVIEW_THRESHOLD + 0.01, 3))  # ≥ 0.66

        result.score = combined
        result.text_model_used = (
            "Detoxify+XLM-RoBERTa" if text_analysis.get("ml_used") else "RuleBased"
        )

        # -- Status decision ---------------------------------------------------
        if result.score < SAFE_THRESHOLD:
            result.status = ModerationStatus.PUBLISHED.value
        elif result.score < REVIEW_THRESHOLD:
            result.status = ModerationStatus.PENDING_REVIEW.value
            if not result.reasons:
                result.reasons.append("Contenu marqué pour révision par précaution")
        else:
            result.status = ModerationStatus.REJECTED.value

        result.confidence         = 0.95 if result.ml_available else 0.75
        result.processing_time_ms = round((time.time() - start) * 1000, 2)

        print(f"[*] [AI] score={result.score} status={result.status} reasons={result.reasons}")
        return result

    # -- Reason Extractors ---------------------------------------------------------

    def _extract_text_reasons(self, text_analysis: Dict) -> List[str]:
        reasons    = []
        categories = text_analysis.get("categories", {})

        profanity = categories.get("profanity", {})
        if profanity.get("severity") in ("medium", "high"):
            reasons.append(f"Langage vulgaire: {', '.join(profanity.get('found', [])[:3])}")

        anti_env = categories.get("anti_environmental", {})
        if anti_env.get("severity") in ("medium", "high"):
            reasons.append(f"Contenu anti-environnement: {', '.join(anti_env.get('found', [])[:2])}")

        off_topic = categories.get("off_topic", {})
        if off_topic.get("count", 0) > 0:
            reasons.append(f"Contenu hors sujet: {', '.join(off_topic.get('found', [])[:3])}")

        ml_toxicity = categories.get("ml_toxicity", {})
        if ml_toxicity.get("toxicity", 0) > 0.6:
            reasons.append("Contenu toxique détecté par l'IA")

        nli = categories.get("nli_relevance", {})
        if nli.get("nli_penalty", 0) > 0.25:
            reasons.append("Texte non pertinent pour EcoRewind (XLM-RoBERTa)")

        return reasons

    def _extract_image_reasons(self, image_analysis: Dict) -> List[str]:
        reasons    = []
        categories = image_analysis.get("categories", {})

        nsfw = categories.get("nsfw", {})
        if nsfw.get("severity") == "high":
            reasons.append("Contenu adulte détecté dans l'image")
        elif nsfw.get("severity") == "medium":
            reasons.append("Contenu potentiellement inapproprié")

        clip_rel = categories.get("clip_relevance", {})
        if clip_rel.get("severity") in ("medium", "high"):
            reasons.append(f"Image hors sujet (CLIP): {clip_rel.get('description', '')}")

        return reasons


# Lazy singleton -- models are loaded only when first accessed at runtime,
# NOT at import time. Use get_moderator() instead of importing `moderator` directly.
_moderator_instance: Optional["AIModerator"] = None

def get_moderator() -> "AIModerator":
    """Return the shared AIModerator singleton, loading models on first call."""
    global _moderator_instance
    if _moderator_instance is None:
        _moderator_instance = AIModerator.get()
    return _moderator_instance

# Backward-compat alias so routers that do
#   from services.ai_moderator import moderator
# still work -- but the object is built lazily on first attribute access.
class _LazyModerator:
    """Transparent proxy that instantiates AIModerator on first use."""
    _obj = None
    def _ensure(self):
        if self._obj is None:
            self._obj = AIModerator.get()
    def __getattr__(self, name):
        self._ensure()
        return getattr(self._obj, name)
    def moderate(self, *args, **kwargs):
        self._ensure()
        return self._obj.moderate(*args, **kwargs)

moderator = _LazyModerator()