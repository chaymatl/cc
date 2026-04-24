"""
EcoRewind - Image ResNet18 Classifier
=======================================
Architecture : ResNet18 pre-entraine (ImageNet) + couche finale Sequential
Tache        : Classification eco-pertinence de l'image
Classes      : eco | nsfw | off_topic  (ordre ImageFolder alphabetique)

Usage (inference) :
    from moderation_ai.image_resnet_model import ImageResNetClassifier
    clf = ImageResNetClassifier()
    probs = clf.predict("/path/to/image.jpg")
    # -> {'eco': 0.82, 'off_topic': 0.12, 'nsfw': 0.06}
"""

import os
from typing import Dict

import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as T
from PIL import Image, UnidentifiedImageError

# -- Chemins par defaut --------------------------------------------------------
_HERE         = os.path.dirname(os.path.abspath(__file__))
DEFAULT_MODEL = os.path.join(_HERE, "models", "eco_image_resnet.pth")

# -- Labels dans l'ordre alphabetique de ImageFolder --------------------------
# ImageFolder trie les dossiers : eco=0, nsfw=1, off_topic=2
# C'est l'ordre qui correspond aux indices de sortie du modele
LABELS_FOLDER = ["eco", "nsfw", "off_topic"]

# -- Normalisation ImageNet standard -------------------------------------------
IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD  = [0.229, 0.224, 0.225]
IMG_SIZE      = 224

NUM_CLASSES   = 3


def _build_resnet18():
    """Construit le ResNet18 avec la meme architecture fc que le trainer v2."""
    base = models.resnet18(weights=None)
    base.fc = nn.Sequential(
        nn.Dropout(0.3),
        nn.Linear(512, 256),
        nn.ReLU(),
        nn.Dropout(0.2),
        nn.Linear(256, NUM_CLASSES),
    )
    return base


# ==============================================================================
# Classificateur (inference)
# ==============================================================================

class ImageResNetClassifier:
    """
    Wrapper d'inference pour ResNet18 fine-tune sur 3 classes eco.

    La couche fc est un Sequential [Dropout -> Linear(512,256) -> ReLU
    -> Dropout -> Linear(256,3)] entraine sur le dataset EcoRewind v2.
    Les couches de convolution (layer1-4) sont partiellement fine-tunees
    (layer4 degelee) sur le dataset image.
    """

    def __init__(self, model_path: str = DEFAULT_MODEL):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        # Construire l'architecture (mirror du trainer v2)
        self.model = _build_resnet18()

        # Charger les poids
        if not os.path.exists(model_path):
            raise FileNotFoundError(
                f"Modele ResNet introuvable : {model_path}\n"
                "Lancez d'abord : python moderation_ai/train_image_resnet.py"
            )
        self.model.load_state_dict(
            torch.load(model_path, map_location=self.device, weights_only=True)
        )
        self.model.to(self.device).eval()

        # Transformations (identiques a la validation d'entrainement)
        self.transform = T.Compose([
            T.Resize((IMG_SIZE, IMG_SIZE)),
            T.ToTensor(),
            T.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
        ])

        print(f"[ResNet18] OK Modele charge sur {self.device}")

    # -- Inference -------------------------------------------------------------

    def predict(self, image_path: str) -> Dict[str, float]:
        """
        Classe une image et retourne les probabilites par classe.

        Returns
        -------
        dict avec cles : 'eco', 'off_topic', 'nsfw'
        """
        if not image_path or not os.path.exists(image_path):
            return {"eco": 0.0, "off_topic": 0.0, "nsfw": 0.0}

        try:
            img    = Image.open(image_path).convert("RGB")
            tensor = self.transform(img).unsqueeze(0).to(self.device)
        except (UnidentifiedImageError, OSError) as e:
            print(f"[ResNet18] WARN Erreur lecture image {image_path}: {e}")
            return {"eco": 0.0, "off_topic": 0.0, "nsfw": 0.0}

        with torch.no_grad():
            logits     = self.model(tensor)               # [1, 3]
            probs_list = torch.softmax(logits, dim=-1)[0] # [3]

        # LABELS_FOLDER = [eco, nsfw, off_topic] (ordre alphabetique ImageFolder)
        # index 0 = eco | index 1 = nsfw | index 2 = off_topic
        return {
            "eco":       round(probs_list[0].item(), 4),
            "nsfw":      round(probs_list[1].item(), 4),
            "off_topic": round(probs_list[2].item(), 4),
        }

    def classify(self, image_path: str) -> str:
        """Retourne uniquement la classe predite ('eco', 'off_topic' ou 'nsfw')."""
        probs = self.predict(image_path)
        return max(probs, key=probs.get)
