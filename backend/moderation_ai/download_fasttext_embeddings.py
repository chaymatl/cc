# -*- coding: utf-8 -*-
"""
EcoRewind — Téléchargement des embeddings FastText pré-entraînés
================================================================
Télécharge les vecteurs FastText pour le français (cc.fr.300.vec.gz)
et extrait UNIQUEMENT les mots de notre vocabulaire.

Avantage : ~4 GB de vecteurs complets → ~12 MB pour notre vocab seulement.
Les mots non trouvés utilisent la moyenne des vecteurs comme fallback.

Sortie :
    moderation_ai/models/fasttext_embeddings.pt   (matrice PyTorch)

Usage :
    cd backend
    python moderation_ai/download_fasttext_embeddings.py
"""

import os, sys, pickle, gzip, io
import numpy as np
import torch

_HERE    = os.path.dirname(os.path.abspath(__file__))
MDL_DIR  = os.path.join(_HERE, "models")
VOC_PATH = os.path.join(MDL_DIR, "vocab.pkl")
EMB_PATH = os.path.join(MDL_DIR, "fasttext_embeddings.pt")

# Dimension des vecteurs FastText pré-entraînés
EMB_DIM  = 300

# URL des vecteurs FastText (français, 300d, CommonCrawl + Wikipedia)
FASTTEXT_URL = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.fr.300.vec.gz"

# Nombre max de lignes à lire du fichier .vec (top N mots les plus fréquents)
MAX_LINES = 500_000


def download_and_extract():
    """
    1. Télécharge le fichier compressé de vecteurs FastText
    2. Extrait uniquement les vecteurs pour les mots de notre vocabulaire
    3. Sauvegarde la matrice d'embeddings en format PyTorch
    """
    # Charger le vocabulaire existant
    if not os.path.exists(VOC_PATH):
        print("[ERREUR] Vocabulaire introuvable. Entraînez d'abord le TextCNN :")
        print("  python moderation_ai/train_text_cnn.py")
        sys.exit(1)

    with open(VOC_PATH, "rb") as f:
        vocab = pickle.load(f)

    vocab_size = len(vocab) + 2  # +2 pour PAD=0 et UNK=1
    print(f"[INFO] Vocabulaire chargé : {len(vocab)} mots (total avec PAD/UNK: {vocab_size})")

    # Initialiser la matrice d'embeddings avec des valeurs aléatoires
    embedding_matrix = np.random.uniform(-0.25, 0.25, (vocab_size, EMB_DIM)).astype(np.float32)
    embedding_matrix[0] = np.zeros(EMB_DIM)  # PAD = vecteur nul

    # Essayer de charger depuis gensim d'abord (plus simple)
    found = 0
    try:
        print(f"\n[DOWNLOAD] Téléchargement des vecteurs FastText français...")
        print(f"  Source : {FASTTEXT_URL}")
        print(f"  Note : seuls les {MAX_LINES} mots les plus fréquents sont lus.")
        print(f"  Cela peut prendre 5-15 min selon votre connexion...\n")

        import urllib.request
        # Télécharger en streaming pour économiser la RAM
        req = urllib.request.Request(FASTTEXT_URL, headers={"User-Agent": "EcoRewind/1.0"})
        response = urllib.request.urlopen(req, timeout=300)

        with gzip.GzipFile(fileobj=response) as gz:
            reader = io.TextIOWrapper(gz, encoding="utf-8", errors="ignore")
            header = reader.readline()  # première ligne = nb_mots dimension
            print(f"  Header: {header.strip()}")

            for line_num, line in enumerate(reader):
                if line_num >= MAX_LINES:
                    break
                if line_num % 50_000 == 0:
                    print(f"  ... {line_num}/{MAX_LINES} lignes lues, {found} mots trouvés")

                parts = line.rstrip().split(" ")
                word = parts[0]

                if word in vocab:
                    idx = vocab[word]
                    try:
                        vec = np.array(parts[1:EMB_DIM+1], dtype=np.float32)
                        if len(vec) == EMB_DIM:
                            embedding_matrix[idx] = vec
                            found += 1
                    except ValueError:
                        pass

        response.close()

    except Exception as e:
        print(f"\n[WARN] Téléchargement FastText échoué : {e}")
        print("[INFO] Tentative avec gensim.downloader comme fallback...")

        try:
            import gensim.downloader as api
            print("[DOWNLOAD] Chargement du modèle word2vec (English, 100d)...")
            model = api.load("glove-wiki-gigaword-100")
            EMB_DIM_FALLBACK = 100
            embedding_matrix = np.random.uniform(-0.25, 0.25, (vocab_size, EMB_DIM_FALLBACK)).astype(np.float32)
            embedding_matrix[0] = np.zeros(EMB_DIM_FALLBACK)

            for word, idx in vocab.items():
                if word in model:
                    embedding_matrix[idx] = model[word]
                    found += 1

            print(f"[INFO] Fallback: {found}/{len(vocab)} mots trouvés (English GloVe 100d)")

        except Exception as e2:
            print(f"[ERREUR] Impossible de charger des embeddings : {e2}")
            print("[INFO] Les embeddings random seront utilisés.")

    coverage = found / len(vocab) * 100
    print(f"\n[RÉSULTAT]")
    print(f"  Mots trouvés    : {found}/{len(vocab)} ({coverage:.1f}%)")
    print(f"  Mots manquants  : {len(vocab) - found} (embeddings random)")
    print(f"  Dimension       : {embedding_matrix.shape[1]}d")
    print(f"  Taille matrice  : {embedding_matrix.nbytes / 1024 / 1024:.1f} MB")

    # Sauvegarder en format PyTorch
    os.makedirs(MDL_DIR, exist_ok=True)
    torch.save({
        "embeddings": torch.tensor(embedding_matrix),
        "vocab_size": vocab_size,
        "emb_dim": embedding_matrix.shape[1],
        "found": found,
        "total": len(vocab),
        "coverage": coverage,
    }, EMB_PATH)

    print(f"\n[OK] Matrice sauvegardée → {EMB_PATH}")
    print(f"     Utilisez --pretrained dans train_text_cnn.py pour l'exploiter")


if __name__ == "__main__":
    download_and_extract()
