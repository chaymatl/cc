"""
EcoRewind -- Text CNN Classifier
=================================
Architecture : 1D CNN à noyaux multiples (3, 4, 5)
Tâche        : Classification éco-pertinence du texte
Classes      : eco | off_topic | toxic
Langues      : FR / AR / EN

Usage (inférence) :
    from moderation_ai.text_cnn_model import TextCNNClassifier
    clf = TextCNNClassifier()
    probs = clf.predict("J'ai trié mes déchets aujourd'hui !")
    # → {'eco': 0.89, 'off_topic': 0.08, 'toxic': 0.03}
"""

import os
import re
import pickle
import unicodedata
from typing import Dict

import torch
import torch.nn as nn

# ── Chemins par défaut ───────────────────────────────────────────────────────
_HERE       = os.path.dirname(os.path.abspath(__file__))
DEFAULT_MODEL = os.path.join(_HERE, "models", "eco_text_cnn.pth")
DEFAULT_VOCAB = os.path.join(_HERE, "models", "vocab.pkl")

# ── Labels ───────────────────────────────────────────────────────────────────
LABELS = ["eco", "off_topic", "toxic"]


# ═══════════════════════════════════════════════════════════════════════════════
# Architecture du modèle (doit être identique à l'entraînement)
# ═══════════════════════════════════════════════════════════════════════════════

class EcoTextCNN(nn.Module):
    """
    1D CNN multi-kernel pour la classification de texte éco-environnemental.

    Architecture inspirée de Kim (2014) « Convolutional Neural Networks
    for Sentence Classification » -- adaptée à 3 classes et multilingue.

    Flux :
        texte → embedding (128d) → 3× Conv1D (k=3,4,5) → MaxPool
              → concat (384d) → Dropout(0.5) → FC(384→3) → logits
    """

    def __init__(
        self,
        vocab_size:    int,
        embedding_dim: int = 128,
        num_filters:   int = 128,
        num_classes:   int = 3,
        dropout:       float = 0.5,
    ):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embedding_dim, padding_idx=0)

        # Trois noyaux de convolution capturant des n-grammes de longueurs 3, 4, 5
        self.convs = nn.ModuleList([
            nn.Conv1d(
                in_channels  = embedding_dim,
                out_channels = num_filters,
                kernel_size  = k,
            )
            for k in [3, 4, 5]
        ])

        self.dropout = nn.Dropout(dropout)
        self.fc      = nn.Linear(len([3, 4, 5]) * num_filters, num_classes)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x : [batch, seq_len]
        emb = self.embedding(x)          # [batch, seq_len, emb_dim]
        emb = emb.permute(0, 2, 1)       # [batch, emb_dim, seq_len]

        pooled = []
        for conv in self.convs:
            c = torch.relu(conv(emb))    # [batch, filters, seq-k+1]
            c = torch.max_pool1d(c, c.size(2)).squeeze(2)  # [batch, filters]
            pooled.append(c)

        out = torch.cat(pooled, dim=1)   # [batch, 384]
        out = self.dropout(out)
        return self.fc(out)              # [batch, 3]


# ═══════════════════════════════════════════════════════════════════════════════
# Classificateur (inférence)
# ═══════════════════════════════════════════════════════════════════════════════

class TextCNNClassifier:
    """
    Wrapper d'inférence pour EcoTextCNN.
    Charge le modèle et le vocabulaire, fournit predict().
    """

    MAX_LEN   = 120   # longueur de sequence (doit correspondre a l'entrainement)
    NUM_FILT  = 256   # nombre de filtres (doit correspondre a l'entrainement)

    def __init__(
        self,
        model_path: str = DEFAULT_MODEL,
        vocab_path: str = DEFAULT_VOCAB,
    ):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        # Vocabulaire
        if not os.path.exists(vocab_path):
            raise FileNotFoundError(
                f"Vocabulaire introuvable : {vocab_path}\n"
                "Lancez d'abord : python moderation_ai/train_text_cnn.py"
            )
        with open(vocab_path, "rb") as f:
            self.vocab: Dict[str, int] = pickle.load(f)

        # Modèle
        if not os.path.exists(model_path):
            raise FileNotFoundError(
                f"Modèle introuvable : {model_path}\n"
                "Lancez d'abord : python moderation_ai/train_text_cnn.py"
            )
        # Charger le checkpoint (peut etre un dict avec metadonnees d'archi,
        # ou un simple state_dict pour compatibilite avec les anciens modeles)
        raw = torch.load(model_path, map_location=self.device, weights_only=True)

        if isinstance(raw, dict) and "state_dict" in raw:
            # Nouveau format : dict avec vocab_size, num_filters, etc.
            state_dict   = raw["state_dict"]
            vocab_size   = raw.get("vocab_size", len(self.vocab) + 2)
            num_filters  = raw.get("num_filters", self.NUM_FILT)
            emb_dim      = raw.get("embedding_dim", 128)
        else:
            # Ancien format : state_dict brut -- inferer vocab_size depuis les poids
            state_dict  = raw
            vocab_size  = raw["embedding.weight"].shape[0]
            num_filters = raw["convs.0.weight"].shape[0]
            emb_dim     = raw["embedding.weight"].shape[1]

        self.model = EcoTextCNN(
            vocab_size    = vocab_size,
            embedding_dim = emb_dim,
            num_filters   = num_filters,
            num_classes   = 3,
        )
        self.model.load_state_dict(state_dict)
        self.model.to(self.device).eval()
        print(f"[TextCNN] [OK] Modèle chargé sur {self.device} -- vocab={len(self.vocab)}")

    # ── Prétraitement ────────────────────────────────────────────────────────

    @staticmethod
    def _normalize(text: str) -> str:
        """Normalisation NFKD : supprime les accents, met en minuscules."""
        nfkd = unicodedata.normalize("NFKD", text.lower())
        return "".join(c for c in nfkd if not unicodedata.combining(c))

    def _tokenize(self, text: str) -> torch.Tensor:
        """
        Tokenise le texte, convertit en ids, pad/tronque à MAX_LEN.
        0 = PAD, 1 = <UNK>
        """
        tokens = re.findall(r"\b\w+\b", self._normalize(text))
        ids    = [self.vocab.get(t, 1) for t in tokens[:self.MAX_LEN]]
        ids   += [0] * (self.MAX_LEN - len(ids))   # padding
        return torch.tensor([ids], dtype=torch.long)

    # ── Inférence ────────────────────────────────────────────────────────────

    def predict(self, text: str) -> Dict[str, float]:
        """
        Retourne les probabilités pour chaque classe.

        Returns
        -------
        dict avec clés : 'eco', 'off_topic', 'toxic'
        """
        if not text or not text.strip():
            return {"eco": 0.0, "off_topic": 0.0, "toxic": 0.0}

        with torch.no_grad():
            tokens = self._tokenize(text).to(self.device)
            logits = self.model(tokens)                  # [1, 3]
            probs  = torch.softmax(logits, dim=-1)[0]    # [3]

        return {
            label: round(prob.item(), 4)
            for label, prob in zip(LABELS, probs)
        }

    def classify(self, text: str) -> str:
        """Retourne uniquement la classe prédite ('eco', 'off_topic' ou 'toxic')."""
        probs = self.predict(text)
        return max(probs, key=probs.get)
