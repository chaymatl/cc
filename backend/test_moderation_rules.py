"""
Test complet des regles metier EcoRewind
=========================================
REGLE FONDAMENTALE :
  Quand une image est presente, le TEXTE doit EXPLICITEMENT promouvoir
  une action d'amelioration / reparation / protection environnementale.
  Une salutation ou un texte neutre + image = PENDING_REVIEW.
"""
import sys, os
sys.stdout.reconfigure(encoding="utf-8")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from moderation_ai.eco_moderator import get_cnn_moderator
m = get_cnn_moderator()

# ── Simuler des images via monkey-patching ───────────────────────────────────
_original_analyze_image = m.analyze_image

def _fake_offtopic_image(image_path):
    return {
        "score": 0.45,
        "categories": {"resnet_image": {"eco": 0.20, "off_topic": 0.65, "nsfw": 0.05}},
        "resnet_probs": {"eco": 0.20, "off_topic": 0.65, "nsfw": 0.05},
        "resnet_decision": "off_topic",
        "ml_used": True, "detections": [], "clip_analysis": {},
    }

def _fake_eco_image(image_path):
    return {
        "score": 0.10,
        "categories": {"resnet_image": {"eco": 0.75, "off_topic": 0.15, "nsfw": 0.02}},
        "resnet_probs": {"eco": 0.75, "off_topic": 0.15, "nsfw": 0.02},
        "resnet_decision": "eco",
        "ml_used": True, "detections": [], "clip_analysis": {},
    }


TESTS = [
    # ══════════════════════════════════════════════════════════════════════════
    #  TEXTE SEUL (pas d'image) -- regles textuelles classiques
    # ══════════════════════════════════════════════════════════════════════════

    # ── ECO VALIDES → PUBLIES ────────────────────────────────────────────────
    ("ECO", "Tri des dechets ce matin avec toute la famille !",             None, "published"),
    ("ECO", "Nettoyage de la foret ce week-end, 200kg ramasses",            None, "published"),
    ("ECO", "Recyclage plastique avec mon association locale",               None, "published"),
    ("ECO", "Plantation de 30 arbres dans notre quartier",                  None, "published"),
    ("ECO", "Panneau solaire installe, energie propre maintenant",          None, "published"),
    ("ECO", "Compostage des dechets organiques, zero dechet !",             None, "published"),

    # ── SALUTATIONS + CONSEILS ECO → PUBLIES ─────────────────────────────────
    ("SAL", "Bonjour a tous ! Pensez a trier vos dechets aujourd hui",      None, "published"),
    ("SAL", "Salam ! Protegez la nature autour de vous",                    None, "published"),
    ("SAL", "Bonjour la communaute EcoRewind ! Ensemble pour la proprete",  None, "published"),
    ("SAL", "Salut ! Astuce : utilisez des sacs reutilisables au marche",   None, "published"),
    ("SAL", "Bonsoir ! Chaque petit geste compte pour la planete",          None, "published"),
    ("SAL", "Hello ! Saviez-vous que recycler une canette economise 95% d energie ?", None, "published"),
    ("SAL", "Bonjour tout le monde, belle journee pour la nature !",        None, "published"),

    # ── POLLUTION DOCUMENTEE + MESSAGE ECO (texte seul) → PUBLIES ────────────
    ("POL", "Photo choc : plage recouverte de plastique, venez nettoyer samedi !", None, "published"),
    ("POL", "Regardez ces ordures dans notre riviere ! Agissons ensemble maintenant", None, "published"),
    ("POL", "Depot sauvage signale en foret, la nature merite mieux",       None, "published"),

    # ══════════════════════════════════════════════════════════════════════════
    #  IMAGE + TEXTE D'ACTION ECO → PUBLIES
    #  Le texte PROMEUT activement : nettoyage, recyclage, protection...
    # ══════════════════════════════════════════════════════════════════════════

    # ── Image OFF_TOPIC (pollution) + ACTION eco → PUBLIE ────────────────────
    ("A+O", "Nettoyons notre plage ! La pollution doit cesser",             "off_topic", "published"),
    ("A+O", "Regardez l etat de cette riviere ! Protegeons notre nature",   "off_topic", "published"),
    ("A+O", "Tri des dechets : voici ce que j ai ramasse ce matin",         "off_topic", "published"),
    ("A+O", "Stop a la pollution ! Recyclons pour la planete",              "off_topic", "published"),
    ("A+O", "Cette decharge sauvage doit etre nettoyee, mobilisons-nous",   "off_topic", "published"),

    # ── Image ECO (nature) + ACTION eco → PUBLIE ────────────────────────────
    ("A+E", "Nettoyage de la plage avec mon equipe, 100kg ramasses",        "eco", "published"),
    ("A+E", "Protegeons cet espace naturel magnifique !",                   "eco", "published"),
    ("A+E", "Plantation d arbres prevue ce week-end, venez participer",     "eco", "published"),
    ("A+E", "Recyclage et compostage en action chez nous !",                "eco", "published"),

    # ══════════════════════════════════════════════════════════════════════════
    #  IMAGE + SALUTATION/NEUTRE (PAS d'action) → PENDING_REVIEW
    #  Le texte ne promeut PAS d'action concrète → admin doit valider
    # ══════════════════════════════════════════════════════════════════════════

    # ── Image OFF_TOPIC (pollution) + salutation/neutre → PENDING ────────────
    ("S+O", "Regardez cette photo !",                                        "off_topic", "pending_review"),
    ("S+O", "Bonjour",                                                       "off_topic", "pending_review"),
    ("S+O", "La pollution est terrible dans cette riviere",                  "off_topic", "pending_review"),
    ("S+O", "Quelle honte cette decharge sauvage",                          "off_topic", "pending_review"),
    ("S+O", "C est sale ici, vraiment triste",                              "off_topic", "pending_review"),

    # ── Image ECO (nature) + salutation/neutre → PENDING ─────────────────────
    ("S+E", "bonjour",                                                       "eco", "pending_review"),
    ("S+E", "hi",                                                            "eco", "pending_review"),
    ("S+E", "Salam",                                                         "eco", "pending_review"),
    ("S+E", "Belle photo",                                                   "eco", "pending_review"),
    ("S+E", "Regardez cette image",                                          "eco", "pending_review"),

    # ══════════════════════════════════════════════════════════════════════════
    #  HORS SUJET / TOXIQUE (texte seul)
    # ══════════════════════════════════════════════════════════════════════════

    # ── Hors-sujet → PENDING_REVIEW ──────────────────────────────────────────
    ("OOT", "Match de foot incroyable hier soir 3-0 en finale",             None, "pending_review"),
    ("OOT", "Nouveau film au cinema, carton au box-office ce week-end",     None, "pending_review"),
    ("OOT", "Bitcoin monte encore, marches cryptos en hausse",              None, "pending_review"),
    ("OOT", "Resultats des elections, le candidat centriste gagne",         None, "pending_review"),

    # ── Toxique / anti-eco → REJETES ─────────────────────────────────────────
    ("TOX", "Nique ta mere et ton recyclage inutile, application nulle",    None, "rejected"),
    ("TOX", "Je m en fous de la nature, jeter par terre c est plus simple", None, "rejected"),
    ("TOX", "L ecologie c est une arnaque inventee pour nous taxer",        None, "rejected"),
    ("TOX", "Vous etes tous des connards avec votre ecologie de merde",     None, "rejected"),
]

# ── Affichage ────────────────────────────────────────────────────────────────
W = 58
print(f"\n{'='*(W+50)}")
print(f"{'TYPE':5s} | {'TEXTE':{W}s} | {'IMG':10s} | {'ATTENDU':15s} | {'OBTENU':15s} | {'SCORE':5s} | RES")
print(f"{'='*(W+50)}")

ok = fail = 0
for typ, text, img_type, expected in TESTS:
    if img_type == "off_topic":
        m.analyze_image = _fake_offtopic_image
        fake_img = "fake_pollution.jpg"
    elif img_type == "eco":
        m.analyze_image = _fake_eco_image
        fake_img = "fake_eco.jpg"
    else:
        m.analyze_image = _original_analyze_image
        fake_img = ""

    r = m.moderate(text=text, image_local_path=fake_img)
    m.analyze_image = _original_analyze_image

    passed = r.status == expected
    if passed: ok   += 1
    else:      fail += 1
    res  = "[PASS]" if passed else "[FAIL]"
    disp = text[:W-2] + ".." if len(text) > W else text
    img_disp = img_type or "---"
    print(f"[{typ:3s}] | {disp:{W}s} | {img_disp:10s} | {expected:15s} | {r.status:15s} | {r.score:.2f} | {res}")

print(f"{'='*(W+50)}")
print(f"\nResultat : {ok}/{len(TESTS)} reussis | {fail} echecs\n")
if fail == 0:
    print("[OK] Toutes les regles metier EcoRewind sont respectees !")
else:
    print(f"[WARN] {fail} cas a corriger")
