"""
EcoRewind -- Test rapide des modeles re-entraines
==================================================
Usage :
    cd backend
    python -X utf8 moderation_ai/test_models.py
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from moderation_ai.eco_moderator import EcoCNNModerator

print("\n" + "=" * 72)
print("  EcoRewind -- Test des modeles re-entraines")
print("=" * 72)

m = EcoCNNModerator()

# ── Tests Text CNN ──────────────────────────────────────────────────────────
TEXT_TESTS = [
    # (texte, label_attendu)
    ("J ai ramasse les dechets sur la plage ce matin avec les benevoles",  "eco"),
    ("Nettoyage du parc municipal avec notre association verte",            "eco"),
    ("Plantation de 50 arbres dans notre quartier pour reverdir la ville", "eco"),
    ("Recyclage plastique : 200kg collectes ce week-end !",                "eco"),
    ("Installation de panneaux solaires sur le toit de l ecole",           "eco"),
    ("Bonjour tout le monde !",                                            "?"),
    ("Coucou, comment ca va ?",                                            "?"),
    ("Terrible accident sur l autoroute ce matin, 3 blesses graves",       "off_topic"),
    ("Quel match incroyable hier soir ! 3-0 en finale de coupe",           "off_topic"),
    ("Resultats des elections, le candidat vert en tete",                  "off_topic"),
    ("Je m en fous de la nature, jeter par terre c est plus simple",       "toxic"),
    ("Cette application est nulle et une vraie arnaque",                   "toxic"),
    ("Vous etes tous des idiots avec votre ecologie de merde",             "toxic"),
    ("Brulons les forets, c est notre droit",                              "toxic"),
]

if m._text_cnn:
    print("\n[TEXT CNN] Resultats :")
    print("-" * 72)
    print(f"  {'Texte':<44} | {'Pred':>9} | {'Eco':>5} | {'Off':>5} | {'Tox':>5} | {'OK?':>4}")
    print("-" * 72)
    ok = 0
    for text, expected in TEXT_TESTS:
        p    = m._text_cnn.predict(text)
        pred = max(p, key=p.get)
        good = "OK" if (pred == expected or expected == "?") else "FAIL"
        if good == "OK":
            ok += 1
        short = text[:44]
        print(f"  {short:<44} | {pred:>9} | {p['eco']:.2f} | {p['off_topic']:.2f} | {p['toxic']:.2f} | {good}")
    real = sum(1 for _, e in TEXT_TESTS if e != "?")
    print("-" * 72)
    print(f"  Score : {ok}/{len(TEXT_TESTS)} ({ok/len(TEXT_TESTS)*100:.0f}%)")
else:
    print("[WARN] Text CNN non charge !")

# ── Test pipeline complet (moderation) ─────────────────────────────────────
print("\n" + "=" * 72)
print("[PIPELINE] Test moderation complete (texte seul) :")
print("-" * 72)

PIPELINE_TESTS = [
    ("Nettoyage de la plage avec 50 benevoles, 200kg ramasses !",          "published"),
    ("Recyclage du plastique au centre de tri ce samedi",                  "published"),
    ("Accident grave sur l autoroute, 3 morts",                            "pending_review"),
    ("Match de foot hier soir, victoire 2-0 !",                            "pending_review"),
    ("Je m en fous de la nature, les ecolos sont des crétins",             "rejected"),
    ("Cette appli est de la merde, arnaque totale",                        "rejected"),
]

for text, expected in PIPELINE_TESTS:
    result = m.moderate(text=text)
    good   = "OK" if result.status == expected else "FAIL"
    short  = text[:44]
    print(f"  {good} [{expected:>14}] score={result.score:.2f} | {short}")

print("=" * 72)
print("  Test termine !")
print("=" * 72 + "\n")
