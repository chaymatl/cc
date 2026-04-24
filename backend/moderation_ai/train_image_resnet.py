"""
EcoRewind — Entraînement ResNet18 v2 (fine-tuning complet)
============================================================
Améliorations v2 :
  - Dégel progressif des couches (layer4 + fc entraînées)
  - LR différentiel : couches profondes LR×0.1, fc LR×1.0
  - LR Scheduler (CosineAnnealingLR)
  - Early stopping (patience=5)
  - Augmentation de données plus agressive
  - Mixup augmentation optionnel
  - Rapport par classe à chaque meilleure epoch

Structure attendue :
    moderation_ai/data/image_dataset/
    ├── train/
    │   ├── eco/        <- images eco
    │   ├── off_topic/  <- images hors-sujet
    │   └── nsfw/       <- images sensibles
    └── val/
        ├── eco/
        ├── off_topic/
        └── nsfw/

Usage :
    cd backend
    python moderation_ai/train_image_resnet.py

Sortie :
    moderation_ai/models/eco_image_resnet.pth
"""

import os, sys, time, math

import torch
import torch.nn as nn
import torchvision.models as tv_models
import torchvision.transforms as T
from torchvision.datasets import ImageFolder
from torch.utils.data import DataLoader

# ── Chemins ───────────────────────────────────────────────────────────────────
_HERE    = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(_HERE, "data", "image_dataset")
MDL_DIR  = os.path.join(_HERE, "models")
MDL_PATH = os.path.join(MDL_DIR, "eco_image_resnet.pth")

# ── Hyper-paramètres ──────────────────────────────────────────────────────────
IMG_SIZE    = 224
BATCH_SIZE  = 32
EPOCHS      = 30        # max epochs (early stopping peut couper avant)
LR_FC       = 1e-3      # LR couche de classification
LR_FEAT     = 1e-4      # LR couches de features (10x plus faible)
PATIENCE    = 5         # early stopping patience
NUM_CLASSES = 3         # eco, off_topic, nsfw
LABEL_SMOOTH = 0.1      # label smoothing

IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD  = [0.229, 0.224, 0.225]


def has_enough_images(split_dir: str, min_per_class: int = 10) -> bool:
    """Vérifie que chaque classe contient assez d'images."""
    if not os.path.isdir(split_dir):
        return False
    for cls in ["eco", "off_topic", "nsfw"]:
        cls_dir = os.path.join(split_dir, cls)
        if not os.path.isdir(cls_dir):
            return False
        imgs = [f for f in os.listdir(cls_dir)
                if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp'))]
        if len(imgs) < min_per_class:
            return False
    return True


def count_per_class(split_dir: str) -> dict:
    counts = {}
    for cls in ["eco", "off_topic", "nsfw"]:
        d = os.path.join(split_dir, cls)
        if os.path.isdir(d):
            counts[cls] = len([f for f in os.listdir(d)
                                if f.lower().endswith(('.jpg','.jpeg','.png','.webp'))])
        else:
            counts[cls] = 0
    return counts


def mixup_data(x, y, alpha=0.2):
    """Mixup augmentation."""
    if alpha > 0:
        lam = torch.distributions.Beta(alpha, alpha).sample().item()
    else:
        lam = 1.0
    batch_size = x.size(0)
    index = torch.randperm(batch_size, device=x.device)
    mixed_x = lam * x + (1 - lam) * x[index]
    y_a, y_b = y, y[index]
    return mixed_x, y_a, y_b, lam


def mixup_criterion(criterion, pred, y_a, y_b, lam):
    return lam * criterion(pred, y_a) + (1 - lam) * criterion(pred, y_b)


def train():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"\n{'='*60}")
    print(f"  EcoRewind --- Entrainement ResNet18 v2 (fine-tuning)")
    print(f"  Device         : {device}")
    print(f"  Epochs (max)   : {EPOCHS}  | Early-stop patience: {PATIENCE}")
    print(f"  LR fc={LR_FC} | LR features={LR_FEAT}")
    print(f"{'='*60}\n")

    train_dir = os.path.join(DATA_DIR, "train")
    val_dir   = os.path.join(DATA_DIR, "val")

    if not has_enough_images(train_dir):
        print("[ERREUR] Pas assez d'images dans train/")
        print("Lancez d'abord : python moderation_ai/download_image_dataset.py")
        sys.exit(1)

    # Affichage du nombre d'images par classe
    train_counts = count_per_class(train_dir)
    val_counts   = count_per_class(val_dir)
    print("[DATA] Images par classe :")
    for cls in ["eco", "off_topic", "nsfw"]:
        print(f"       {cls:>10} : train={train_counts[cls]:>4} | val={val_counts[cls]:>4}")
    print()

    # ── Augmentation agressive pour train ─────────────────────────────────────
    train_tf = T.Compose([
        T.Resize((256, 256)),
        T.RandomResizedCrop(IMG_SIZE, scale=(0.7, 1.0)),
        T.RandomHorizontalFlip(),
        T.RandomVerticalFlip(p=0.1),
        T.RandomRotation(15),
        T.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.2, hue=0.1),
        T.RandomGrayscale(p=0.05),
        T.ToTensor(),
        T.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        T.RandomErasing(p=0.1),   # occlusion aléatoire
    ])
    val_tf = T.Compose([
        T.Resize((IMG_SIZE, IMG_SIZE)),
        T.ToTensor(),
        T.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
    ])

    # ── Datasets & DataLoaders ────────────────────────────────────────────────
    train_ds = ImageFolder(train_dir, transform=train_tf)
    val_ds   = ImageFolder(val_dir,   transform=val_tf)

    # Calcul des poids de classes pour compenser le déséquilibre
    class_counts  = [len([f for f in os.listdir(os.path.join(train_dir, cls))
                          if f.lower().endswith(('.jpg','.jpeg','.png','.webp'))])
                     for cls in train_ds.classes]
    class_weights = torch.tensor([1.0 / max(c, 1) for c in class_counts], dtype=torch.float)
    class_weights = class_weights / class_weights.sum() * NUM_CLASSES

    train_dl = DataLoader(train_ds, batch_size=BATCH_SIZE, shuffle=True, num_workers=0)
    val_dl   = DataLoader(val_ds,   batch_size=BATCH_SIZE, shuffle=False, num_workers=0)

    print(f"[DATA] Classes : {train_ds.classes}")
    print(f"[DATA] Poids   : {dict(zip(train_ds.classes, class_weights.tolist()))}")
    print(f"[DATA] Train={len(train_ds)} | Val={len(val_ds)}\n")

    # ── Modèle — ResNet18 avec fine-tuning partiel ────────────────────────────
    model = tv_models.resnet18(weights=tv_models.ResNet18_Weights.DEFAULT)

    # Geler toutes les couches
    for param in model.parameters():
        param.requires_grad = False

    # Dégeler layer4 (couche de features de haut niveau) + fc
    for param in model.layer4.parameters():
        param.requires_grad = True

    # Remplacer la couche de classification
    model.fc = nn.Sequential(
        nn.Dropout(0.3),
        nn.Linear(model.fc.in_features, 256),
        nn.ReLU(),
        nn.Dropout(0.2),
        nn.Linear(256, NUM_CLASSES),
    )
    model = model.to(device)

    # Paramètres entraînables
    trainable = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total     = sum(p.numel() for p in model.parameters())
    print(f"[MODEL] ResNet18 --- {trainable:,} / {total:,} parametres entrainables")
    print(f"        Couches degelees : layer4 + fc\n")

    # LR différentiel : layer4 apprend plus lentement que fc
    param_groups = [
        {"params": model.layer4.parameters(), "lr": LR_FEAT},
        {"params": model.fc.parameters(),     "lr": LR_FC},
    ]
    opt       = torch.optim.Adam(param_groups, weight_decay=1e-4)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(opt, T_max=EPOCHS)
    loss_fn   = nn.CrossEntropyLoss(
        weight=class_weights.to(device),
        label_smoothing=LABEL_SMOOTH,
    )

    # ── Boucle d'entraînement ──────────────────────────────────────────────────
    best_acc    = 0.0
    patience_ct = 0
    os.makedirs(MDL_DIR, exist_ok=True)

    print("-" * 65)
    print(f"{'Epoch':>6} | {'Train Loss':>10} | {'Val Acc':>8} | {'LR (fc)':>10} | {'Temps':>7}")
    print("-" * 65)

    for epoch in range(1, EPOCHS + 1):
        t0 = time.time()
        model.train()
        total_loss = 0.0

        for imgs, labels in train_dl:
            imgs, labels = imgs.to(device), labels.to(device)

            # Mixup avec probabilité 50%
            if torch.rand(1).item() > 0.5:
                imgs, y_a, y_b, lam = mixup_data(imgs, labels)
                out  = model(imgs)
                loss = mixup_criterion(loss_fn, out, y_a, y_b, lam)
            else:
                out  = model(imgs)
                loss = loss_fn(out, labels)

            opt.zero_grad()
            loss.backward()
            nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            opt.step()
            total_loss += loss.item()

        # Validation
        model.eval()
        correct = total = 0
        class_correct = [0] * NUM_CLASSES
        class_total   = [0] * NUM_CLASSES

        with torch.no_grad():
            for imgs, labels in val_dl:
                imgs, labels = imgs.to(device), labels.to(device)
                preds   = model(imgs).argmax(dim=1)
                correct += (preds == labels).sum().item()
                total   += labels.size(0)
                for lbl, pred in zip(labels.cpu(), preds.cpu()):
                    class_total[lbl.item()]   += 1
                    class_correct[lbl.item()] += int(pred.item() == lbl.item())

        val_acc  = correct / total * 100 if total > 0 else 0.0
        avg_loss = total_loss / len(train_dl)
        elapsed  = time.time() - t0
        cur_lr   = opt.param_groups[1]["lr"]   # LR de fc

        print(f"  {epoch:>4}/{EPOCHS} | {avg_loss:>10.4f} | {val_acc:>7.1f}% | {cur_lr:>10.2e} | {elapsed:>5.1f}s")

        scheduler.step()

        if val_acc > best_acc:
            best_acc    = val_acc
            patience_ct = 0
            torch.save(model.state_dict(), MDL_PATH)
            # Affichage par classe
            per_class = " | ".join(
                f"{train_ds.classes[i]}={class_correct[i]/max(class_total[i],1)*100:.0f}%"
                for i in range(NUM_CLASSES)
            )
            print(f"          [OK] Meilleur modele sauvegarde ({val_acc:.1f}%) --- [{per_class}]")
        else:
            patience_ct += 1
            if patience_ct >= PATIENCE:
                print(f"\n[STOP] Early stopping apres {epoch} epochs (patience={PATIENCE})")
                break

    print(f"\n{'='*60}")
    print(f"  Entrainement termine !")
    print(f"  Meilleure accuracy : {best_acc:.1f}%")
    print(f"  Modele sauvegarde  : {MDL_PATH}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    train()
