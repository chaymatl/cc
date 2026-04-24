"""
Test rapide du Text CNN EcoRewind
===================================
Vérifie que le modèle entraîné classifie correctement
les publications citoyennes typiques.

Usage :
    python -X utf8 moderation_ai/test_cnn.py
"""

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from moderation_ai.text_cnn_model import TextCNNClassifier

G    = "\033[92m"
Y    = "\033[93m"
R    = "\033[91m"
B    = "\033[94m"
BOLD = "\033[1m"
RST  = "\033[0m"

PASS_COUNT = 0
FAIL_COUNT = 0

clf = TextCNNClassifier()

TESTS = [
    # (texte,                                                   label_attendu)
    ("J'ai trié mes déchets au point de collecte !",           "eco"),
    ("Nettoyage de la forêt avec les bénévoles ce matin",      "eco"),
    ("Plantation de 30 arbres dans le quartier",               "eco"),
    ("قمنا بتنظيف الشاطئ وجمعنا النفايات لحماية البيئة",       "eco"),
    ("Beach cleanup today with 50 volunteers, amazing!",       "eco"),
    ("Compostage de mes déchets organiques, zéro déchet",      "eco"),
    ("Installation de panneaux solaires sur notre toit",       "eco"),
    ("Terrible accident sur l'autoroute A1, 3 blessés",        "off_topic"),
    ("Les élections municipales approchent, qui voter ?",      "off_topic"),
    ("Quel match incroyable hier soir, 3-0 en finale",         "off_topic"),
    ("J'ai mangé un excellent couscous au restaurant",         "off_topic"),
    ("Décès d'une victime suite à l'accident de la route",     "off_topic"),
    ("Cette appli est nulle, quelle arnaque de merde",         "toxic"),
    ("Je m'en fous de la nature, jeter par terre c'est simple","toxic"),
    ("Vous êtes des connards avec votre écologie",             "toxic"),
    ("Who cares about nature, I'll throw garbage anywhere",    "toxic"),
]

print(f"\n{BOLD}{B}{'='*60}{RST}")
print(f"{BOLD}  EcoRewind — Test Text CNN (publications citoyennes){RST}")
print(f"{BOLD}{B}{'='*60}{RST}\n")

for text, expected in TESTS:
    probs   = clf.predict(text)
    pred    = max(probs, key=probs.get)
    conf    = probs[pred] * 100
    ok      = pred == expected

    status = f"{G}PASS{RST}" if ok else f"{R}FAIL (attendu={expected}){RST}"
    color  = G if pred == "eco" else (Y if pred == "off_topic" else R)

    print(f"  {status}  [{color}{pred:>9}{RST} {conf:>5.1f}%]  {text[:55]}")

    if ok:
        PASS_COUNT += 1
    else:
        FAIL_COUNT += 1

total = PASS_COUNT + FAIL_COUNT
print(f"\n{BOLD}{B}{'='*60}{RST}")
print(f"{BOLD}  RÉSULTATS : {G}{PASS_COUNT} PASS{RST}{BOLD}  |  {R}{FAIL_COUNT} FAIL{RST}{BOLD}  |  Total : {total}{RST}")
print(f"{BOLD}{B}{'='*60}{RST}\n")

if FAIL_COUNT > 0:
    sys.exit(1)
