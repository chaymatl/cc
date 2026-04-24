"""
Test complet du ResNet18 EcoRewind
====================================
Évalue le modèle sur un échantillon du dataset de validation.
Affiche : précision par classe + accuracy globale + matrice de confusion.

Usage :
    python -X utf8 moderation_ai/test_resnet.py
"""

import sys, os, random
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from moderation_ai.image_resnet_model import ImageResNetClassifier

G    = "\033[92m"
Y    = "\033[93m"
R    = "\033[91m"
B    = "\033[94m"
BOLD = "\033[1m"
RST  = "\033[0m"

CLASSES  = ["eco", "off_topic", "nsfw"]
VAL_DIR  = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "image_dataset", "val")
MAX_PER_CLASS = 20   # limite pour que le test reste rapide

# ── Charger le modèle ─────────────────────────────────────────────────────────
print(f"\n{BOLD}{B}{'='*60}{RST}")
print(f"{BOLD}  EcoRewind — Test ResNet18 (classification image){RST}")
print(f"{BOLD}{B}{'='*60}{RST}\n")

clf = ImageResNetClassifier()
print()

# ── Collecter les images ──────────────────────────────────────────────────────
samples = []   # (path, true_label)
for cls in CLASSES:
    cls_dir = os.path.join(VAL_DIR, cls)
    if not os.path.isdir(cls_dir):
        print(f"{Y}[WARN] Dossier introuvable : {cls_dir}{RST}")
        continue
    imgs = [
        os.path.join(cls_dir, f) for f in os.listdir(cls_dir)
        if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp'))
    ]
    random.shuffle(imgs)
    for p in imgs[:MAX_PER_CLASS]:
        samples.append((p, cls))

if not samples:
    print(f"{R}[ERREUR] Aucune image trouvée dans {VAL_DIR}{RST}")
    print("Vérifiez la structure : val/{eco,off_topic,nsfw}/")
    sys.exit(1)

print(f"  Évaluation sur {len(samples)} images ({MAX_PER_CLASS} max par classe)\n")

# ── Évaluer ───────────────────────────────────────────────────────────────────
# confusion[true][pred] = count
confusion = {c: {c2: 0 for c2 in CLASSES} for c in CLASSES}
total_ok  = 0

for path, true_label in samples:
    probs = clf.predict(path)
    pred  = max(probs, key=probs.get)
    conf  = probs[pred] * 100
    ok    = pred == true_label

    confusion[true_label][pred] += 1
    if ok:
        total_ok += 1

    status = f"{G}PASS{RST}" if ok else f"{R}FAIL (pred={pred}){RST}"
    color  = G if pred == "eco" else (Y if pred == "off_topic" else R)
    fname  = os.path.basename(path)[:40]
    print(f"  {status}  [{color}{pred:>9}{RST} {conf:>5.1f}%]  [{true_label:>9}]  {fname}")

# ── Résultats ─────────────────────────────────────────────────────────────────
total   = len(samples)
acc     = total_ok / total * 100 if total > 0 else 0.0
fail    = total - total_ok

print(f"\n{BOLD}{B}{'='*60}{RST}")
print(f"{BOLD}  ACCURACY GLOBALE : {G if acc >= 70 else R}{acc:.1f}%{RST}  "
      f"{BOLD}({G}{total_ok} PASS{RST}{BOLD} / {R}{fail} FAIL{RST}{BOLD} / {total} total){RST}")
print(f"{BOLD}{B}{'='*60}{RST}")

# ── Précision par classe ──────────────────────────────────────────────────────
print(f"\n{BOLD}  Précision par classe :{RST}")
for cls in CLASSES:
    row   = confusion[cls]
    total_cls = sum(row.values())
    ok_cls    = row[cls]
    cls_acc   = ok_cls / total_cls * 100 if total_cls > 0 else 0.0
    color     = G if cls_acc >= 70 else R
    print(f"    {cls:>10} : {color}{cls_acc:5.1f}%{RST}  ({ok_cls}/{total_cls})")

# ── Matrice de confusion ──────────────────────────────────────────────────────
print(f"\n{BOLD}  Matrice de confusion (lignes=vrai, cols=prédit) :{RST}")
header = f"{'':>12}" + "".join(f"  {c:>10}" for c in CLASSES)
print(f"    {header}")
for true_cls in CLASSES:
    row_str = f"  {true_cls:>10}  "
    for pred_cls in CLASSES:
        val = confusion[true_cls][pred_cls]
        if true_cls == pred_cls:
            row_str += f"{G}{val:>10}{RST}  "
        elif val > 0:
            row_str += f"{R}{val:>10}{RST}  "
        else:
            row_str += f"{'0':>10}  "
    print(f"    {row_str}")

print()
if acc < 70:
    print(f"{R}⚠️  Accuracy < 70% — le modèle nécessite un ré-entraînement.{RST}")
    sys.exit(1)
else:
    print(f"{G}✅ Modèle ResNet18 validé ({acc:.1f}% accuracy).{RST}")
