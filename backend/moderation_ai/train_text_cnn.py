"""
EcoRewind — Entraînement du Text CNN (v2 — plus de données, meilleure convergence)
====================================================================================
Entraîne EcoTextCNN sur le dataset de publications citoyennes.

Améliorations v2 :
  - 9 000 exemples (3 000/classe) au lieu de 2 100
  - LR Scheduler (ReduceLROnPlateau)
  - Early stopping (patience=4)
  - Dropout 0.4 pour réduire l'overfitting
  - Augmentation de données au vol (word-dropout)
  - Sauvegarde du meilleur modèle + rapport final

Usage :
    cd backend
    python -X utf8 moderation_ai/train_text_cnn.py

Sorties :
    moderation_ai/models/eco_text_cnn.pth   <- poids du modèle
    moderation_ai/models/vocab.pkl           <- vocabulaire
"""

import os, re, sys, time, pickle, unicodedata, random
from collections import Counter

import pandas as pd
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader

# ── Résolution des chemins ─────────────────────────────────────────────────────
_HERE    = os.path.dirname(os.path.abspath(__file__))
DATA_CSV = os.path.join(_HERE, "data", "text_dataset.csv")
MDL_DIR  = os.path.join(_HERE, "models")
MDL_PATH = os.path.join(MDL_DIR, "eco_text_cnn.pth")
VOC_PATH = os.path.join(MDL_DIR, "vocab.pkl")

# ── Hyper-paramètres ──────────────────────────────────────────────────────────
MAX_LEN    = 120      # longueur max d'une séquence (tokens)
EMB_DIM    = 128      # dimension des embeddings (sera 300 si FastText)
NUM_FILT   = 256      # nombre de filtres par conv
EPOCHS     = 30       # max epochs (early stopping peut couper avant)
BATCH_SIZE = 64       # plus grand batch pour meilleure convergence
LR         = 5e-4     # learning rate initial
VOCAB_SIZE = 25_000   # taille max du vocabulaire
PATIENCE   = 5        # early stopping patience (augmenté)
DROPOUT    = 0.4      # dropout pour régularisation
N_PER_CLASS = 6000    # exemples par classe (doublé vs v2)

# Embeddings pré-entraînés FastText (si disponibles)
PRETRAINED_EMB_PATH = os.path.join(MDL_DIR, "fasttext_embeddings.pt")
USE_PRETRAINED = os.path.exists(PRETRAINED_EMB_PATH)

LABEL_MAP  = {"eco": 0, "off_topic": 1, "toxic": 2}

# ── Importation locale de l'architecture ──────────────────────────────────────
sys.path.insert(0, os.path.dirname(_HERE))
from moderation_ai.text_cnn_model import EcoTextCNN


# ─────────────────────────────────────────────────────────────────────────────
# Utilitaires texte
# ─────────────────────────────────────────────────────────────────────────────

def _normalize(text: str) -> str:
    nfkd = unicodedata.normalize("NFKD", str(text).lower())
    return "".join(c for c in nfkd if not unicodedata.combining(c))

def _tokenize(text: str) -> list:
    return re.findall(r"\b\w+\b", _normalize(text))


# ─────────────────────────────────────────────────────────────────────────────
# Dataset PyTorch avec word dropout
# ─────────────────────────────────────────────────────────────────────────────

class CitizenPostDataset(Dataset):
    def __init__(self, df: pd.DataFrame, vocab: dict, max_len: int = MAX_LEN,
                 augment: bool = False):
        self.texts   = df["text"].tolist()
        self.labels  = df["label_id"].tolist()
        self.vocab   = vocab
        self.max_len = max_len
        self.augment = augment  # word-dropout uniquement en entraînement

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, i):
        tokens = _tokenize(str(self.texts[i]))
        # Word-dropout : supprimer ~10% des tokens au hasard (augmentation)
        if self.augment and len(tokens) > 3:
            tokens = [t for t in tokens if random.random() > 0.10]
        ids  = [self.vocab.get(t, 1) for t in tokens[:self.max_len]]
        ids += [0] * (self.max_len - len(ids))
        return (
            torch.tensor(ids, dtype=torch.long),
            torch.tensor(self.labels[i], dtype=torch.long),
        )


# ─────────────────────────────────────────────────────────────────────────────
# Pipeline d'entraînement
# ─────────────────────────────────────────────────────────────────────────────

def train():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Détecter embeddings pré-entraînés
    if USE_PRETRAINED:
        pretrained_data = torch.load(PRETRAINED_EMB_PATH, map_location="cpu", weights_only=True)
        EMB_DIM = pretrained_data["emb_dim"]
        NUM_FILT = 256
        coverage = pretrained_data.get("coverage", 0)
        print(f"\n{'='*60}")
        print(f"  EcoRewind — Entraînement Text CNN v3 (FastText {EMB_DIM}d)")
        print(f"  Embeddings pré-entraînés : {coverage:.1f}% couverture")
    else:
        EMB_DIM = 128
        NUM_FILT = 256
        pretrained_data = None
        print(f"\n{'='*60}")
        print(f"  EcoRewind — Entraînement Text CNN v3 (embeddings {EMB_DIM}d)")

    print(f"  Device        : {device}")
    print(f"  Epochs (max)  : {EPOCHS}  | Early-stop patience: {PATIENCE}")
    print(f"  Batch size    : {BATCH_SIZE} | Dataset : {N_PER_CLASS}/classe")
    print(f"{'='*60}\n")

    # ── Génération automatique du dataset si absent ou trop petit ─────────────
    regenerate = False
    if not os.path.exists(DATA_CSV):
        regenerate = True
        print("[INFO] Dataset absent — génération automatique...")
    else:
        df_check = pd.read_csv(DATA_CSV)
        if len(df_check) < N_PER_CLASS * 3 * 0.9:  # vérifier taille vs cible
            regenerate = True
            print(f"[INFO] Dataset trop petit ({len(df_check)} lignes, cible={N_PER_CLASS*3}) — régénération...")

    if regenerate:
        from moderation_ai.build_text_dataset import build_dataset
        build_dataset(DATA_CSV, n_per_class=N_PER_CLASS)

    # ── Chargement données ─────────────────────────────────────────────────────
    df = pd.read_csv(DATA_CSV)
    df["label_id"] = df["label"].map(LABEL_MAP)
    df = df.dropna(subset=["label_id"])
    df["label_id"] = df["label_id"].astype(int)
    print(f"[DATA] {len(df)} exemples | Distribution:")
    print(df["label"].value_counts().to_string())

    # ── Construction vocabulaire ───────────────────────────────────────────────
    all_tokens = [tok for text in df["text"] for tok in _tokenize(str(text))]
    freq  = Counter(all_tokens)
    vocab = {
        word: idx + 2
        for idx, (word, _) in enumerate(freq.most_common(VOCAB_SIZE))
    }
    os.makedirs(MDL_DIR, exist_ok=True)
    with open(VOC_PATH, "wb") as f:
        pickle.dump(vocab, f)
    print(f"\n[VOCAB] {len(vocab)} mots -> {VOC_PATH}")

    # ── Split 80/20 (stratifié par label) ─────────────────────────────────────
    train_df = df.groupby("label", group_keys=False).apply(
        lambda x: x.sample(frac=0.80, random_state=42)
    )
    val_df = df.drop(train_df.index)

    train_dl = DataLoader(
        CitizenPostDataset(train_df, vocab, augment=True),
        batch_size=BATCH_SIZE, shuffle=True, drop_last=True,
    )
    val_dl = DataLoader(
        CitizenPostDataset(val_df, vocab, augment=False),
        batch_size=BATCH_SIZE,
    )
    print(f"[SPLIT] Train={len(train_df)} | Val={len(val_df)}\n")

    # ── Modèle ─────────────────────────────────────────────────────────────────
    # Charger embeddings pré-entraînés si disponibles
    pretrained_data = None
    if USE_PRETRAINED:
        pretrained_data = torch.load(PRETRAINED_EMB_PATH, map_location="cpu", weights_only=True)
        EMB_DIM = pretrained_data["emb_dim"]
        coverage = pretrained_data.get("coverage", 0)
        print(f"[EMB] FastText {EMB_DIM}d détecté ({coverage:.1f}% couverture)")

    model = EcoTextCNN(
        vocab_size    = len(vocab) + 2,
        embedding_dim = EMB_DIM,
        num_filters   = NUM_FILT,
        num_classes   = len(LABEL_MAP),
    ).to(device)

    if pretrained_data is not None:
        pretrained_emb = pretrained_data["embeddings"]
        model_vs = len(vocab) + 2
        load_sz = min(pretrained_emb.shape[0], model_vs)
        model.embedding.weight.data[:load_sz] = pretrained_emb[:load_sz].to(device)
        # Geler les embeddings pendant le warm-up (3 premières epochs)
        model.embedding.weight.requires_grad = False
        print(f"[EMB] Embeddings chargés et gelés (dégel epoch 4)")

    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"[MODEL] EcoTextCNN — {total_params:,} params ({trainable_params:,} entraînables)\n")

    opt       = torch.optim.Adam(model.parameters(), lr=LR, weight_decay=1e-4)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
        opt, mode="max", patience=2, factor=0.5
    )
    loss_fn   = nn.CrossEntropyLoss()

    # ── Boucle d'entraînement ──────────────────────────────────────────────────
    best_acc    = 0.0
    patience_ct = 0

    print(f"{'─'*60}")
    print(f"{'Epoch':>6} | {'Train Loss':>10} | {'Val Acc':>8} | {'LR':>10} | {'Temps':>7}")
    print(f"{'─'*60}")

    for epoch in range(1, EPOCHS + 1):
        t0 = time.time()
        model.train()
        total_loss = 0.0

        for texts_b, labels_b in train_dl:
            texts_b, labels_b = texts_b.to(device), labels_b.to(device)
            out  = model(texts_b)
            loss = loss_fn(out, labels_b)
            opt.zero_grad()
            loss.backward()
            nn.utils.clip_grad_norm_(model.parameters(), 1.0)   # gradient clipping
            opt.step()
            total_loss += loss.item()

        # Dégeler les embeddings après les 3 premières epochs (warm-up)
        if epoch == 3 and pretrained_data is not None and not model.embedding.weight.requires_grad:
            model.embedding.weight.requires_grad = True
            print(f"          🔓 Embeddings dégelés (fine-tuning activé)")

        # Validation
        model.eval()
        correct = total = 0
        class_correct = [0] * len(LABEL_MAP)
        class_total   = [0] * len(LABEL_MAP)

        with torch.no_grad():
            for texts_b, labels_b in val_dl:
                texts_b, labels_b = texts_b.to(device), labels_b.to(device)
                preds   = model(texts_b).argmax(dim=1)
                correct += (preds == labels_b).sum().item()
                total   += labels_b.size(0)
                for lbl, pred in zip(labels_b.cpu(), preds.cpu()):
                    class_total[lbl.item()]   += 1
                    class_correct[lbl.item()] += int(pred.item() == lbl.item())

        val_acc  = correct / total * 100
        avg_loss = total_loss / len(train_dl)
        elapsed  = time.time() - t0
        cur_lr   = opt.param_groups[0]["lr"]

        print(f"  {epoch:>4}/{EPOCHS} | {avg_loss:>10.4f} | {val_acc:>7.1f}% | {cur_lr:>10.2e} | {elapsed:>5.1f}s")

        scheduler.step(val_acc)

        if val_acc > best_acc:
            best_acc    = val_acc
            patience_ct = 0
            torch.save({
                "state_dict": model.state_dict(),
                "vocab_size": len(vocab) + 2,
                "num_filters": NUM_FILT,
                "embedding_dim": EMB_DIM,
                "num_classes": len(LABEL_MAP),
            }, MDL_PATH)
            # Affichage par classe
            label_names = {v: k for k, v in LABEL_MAP.items()}
            per_class = " | ".join(
                f"{label_names[i]}={class_correct[i]/max(class_total[i],1)*100:.0f}%"
                for i in range(len(LABEL_MAP))
            )
            print(f"          ✅ Meilleur modele sauvegarde ({val_acc:.1f}%) — [{per_class}]")
        else:
            patience_ct += 1
            if patience_ct >= PATIENCE:
                print(f"\n⏹  Early stopping apres {epoch} epochs (patience={PATIENCE})")
                break

    print(f"\n{'='*60}")
    print(f"  Entraînement terminé !")
    print(f"  Meilleure accuracy : {best_acc:.1f}%")
    print(f"  Modèle : {MDL_PATH}")
    print(f"  Vocab  : {VOC_PATH}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    train()
