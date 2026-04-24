"""
EcoRewind — Téléchargement automatique du dataset images (v2)
=============================================================
Télécharge des images supplémentaires par classe via Bing Image Search.
Ne re-télécharge que les classes qui manquent d'images (mode incrémental).

Classes :
  eco       -> photos environnementales (recyclage, nettoyage, nature)
  off_topic -> photos hors-sujet (accidents, sport, politique, food)
  nsfw      -> contenu sensible / adulte simulé

Cibles :
  eco       : 800 train + 200 val  = 1000 total
  off_topic : 800 train + 200 val  = 1000 total
  nsfw      : 500 train + 125 val  =  625 total

Usage :
    cd backend
    python moderation_ai/download_image_dataset.py

Durée estimée : 20-40 min selon la connexion
"""

import os
import shutil
import random
import logging

logging.getLogger("icrawler").setLevel(logging.ERROR)

_HERE    = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(_HERE, "data", "image_dataset")

# ── Requêtes de recherche par classe ──────────────────────────────────────────
SEARCH_QUERIES = {
    "eco": [
        ("recycling bins sorting waste plastic",      70),
        ("beach cleanup volunteers collecting trash", 70),
        ("tree planting reforestation community",     70),
        ("solar panels renewable energy rooftop",     60),
        ("composting organic waste garden",           60),
        ("nature biodiversity forest green trees",    60),
        ("zero waste sustainable lifestyle",          60),
        ("wind turbines clean energy field",          50),
        ("community garden urban farming vegetables", 50),
        ("wildlife conservation natural habitat",     50),
        ("river cleanup water pollution",             50),
        ("eco-friendly products sustainable",         50),
        ("green energy environment protest",          40),
        ("recycling center waste management",         40),
        ("electric vehicle charging renewable",       40),
    ],
    "off_topic": [
        ("football match stadium sport crowd game",       90),
        ("election campaign politics politician",         90),
        ("restaurant food plate meal fine dining",        80),
        ("makeup cosmetics beauty products brushes",      80),
        ("lipstick mascara eyeliner beauty products",     80),
        ("fashion clothing dress outfit model",           80),
        ("shopping mall retail clothing fashion store",   75),
        ("business meeting office corporate people",      75),
        ("music concert band performance crowd",          75),
        ("travel tourism city landmark architecture",     75),
        ("cooking recipe kitchen chef food",              65),
        ("car accident road crash police",                65),
        ("fitness gym workout exercise sport",            65),
        ("perfume cologne luxury cosmetics bottle",       60),
        ("jewelry accessories fashion luxury brand",      60),
        ("news anchor broadcast television studio",       55),
        ("school classroom students learning lesson",     55),
        ("hospital emergency medical doctor nurse",       55),
        ("stock market financial trading charts",         50),
        ("construction building workers site",            50),
        ("wedding celebration party people dancing",      50),
        ("airport travel luggage plane boarding",         50),
        ("smartphone technology gadget electronics",      50),
    ],
    "nsfw": [
        ("lingerie fashion model photoshoot editorial", 100),
        ("bikini swimwear beach fashion model",         100),
        ("pin up vintage poster illustration art",       80),
        ("provocative fashion advertising campaign",     70),
        ("nude classical art painting sculpture",        70),
        ("adult magazine cover vintage retro",           60),
        ("sensual artistic photography fashion",         60),
    ],
}

# Cibles par classe (train + val combinés)
TARGETS = {
    "eco":       1000,
    "off_topic": 1000,
    "nsfw":       625,
}

TRAIN_RATIO = 0.80


def count_images(split: str, cls: str) -> int:
    d = os.path.join(DATA_DIR, split, cls)
    if not os.path.isdir(d):
        return 0
    return len([f for f in os.listdir(d)
                if os.path.splitext(f)[1].lower() in {".jpg", ".jpeg", ".png", ".webp"}])


def download_class(class_name: str, queries: list, needed: int):
    """Telecharge 'needed' images supplementaires pour la classe donnee."""
    try:
        from icrawler.builtin import BingImageCrawler
    except ImportError:
        print("icrawler non installe. Lancez : pip install icrawler")
        return 0

    train_dir = os.path.join(DATA_DIR, "train", class_name)
    val_dir   = os.path.join(DATA_DIR, "val",   class_name)
    tmp_dir   = os.path.join(DATA_DIR, "_tmp",  class_name)
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(val_dir,   exist_ok=True)
    os.makedirs(tmp_dir,   exist_ok=True)

    # Distribuer 'needed' entre les requêtes proportionnellement
    total_quota = sum(n for _, n in queries)
    downloaded  = 0

    for query, quota in queries:
        # Proportionner la quota à nos besoins réels
        n = max(5, round(quota / total_quota * needed * 1.2))  # 20% de marge
        print(f"   >> '{query}' -> {n} images...")
        try:
            crawler = BingImageCrawler(
                storage={"root_dir": tmp_dir},
                downloader_threads=4,
                parser_threads=2,
            )
            crawler.crawl(
                keyword=query,
                max_num=n,
                min_size=(100, 100),
                file_idx_offset="auto",
            )
        except Exception as e:
            print(f"   [WARN] Erreur sur '{query}': {e}")

    # Split et déplacement
    valid_ext  = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
    all_images = [
        f for f in os.listdir(tmp_dir)
        if os.path.splitext(f)[1].lower() in valid_ext
    ]
    random.shuffle(all_images)

    split_idx  = int(len(all_images) * TRAIN_RATIO)
    train_imgs = all_images[:split_idx]
    val_imgs   = all_images[split_idx:]

    for fname in train_imgs:
        dst = os.path.join(train_dir, fname)
        if not os.path.exists(dst):
            shutil.move(os.path.join(tmp_dir, fname), dst)
        else:
            os.remove(os.path.join(tmp_dir, fname))

    for fname in val_imgs:
        dst = os.path.join(val_dir, fname)
        if not os.path.exists(dst):
            shutil.move(os.path.join(tmp_dir, fname), dst)
        else:
            os.remove(os.path.join(tmp_dir, fname))

    try:
        shutil.rmtree(tmp_dir)
    except Exception:
        pass

    return len(all_images)


def main():
    print("\n" + "="*65)
    print("  EcoRewind -- Telechargement dataset images (mode incremental)")
    print("="*65 + "\n")

    grand_total = 0

    for class_name, queries in SEARCH_QUERIES.items():
        target  = TARGETS[class_name]
        current = count_images("train", class_name) + count_images("val", class_name)
        needed  = max(0, target - current)

        print(f"\n[{class_name.upper()}]")
        print(f"  Existant : {current} images | Cible : {target} | Manquant : {needed}")

        if needed == 0:
            print(f"  [OK] Deja suffisant, on passe.")
            continue

        print(f"  Telechargement de ~{needed} images supplementaires...")
        count = download_class(class_name, queries, needed)
        grand_total += count
        after = count_images("train", class_name) + count_images("val", class_name)
        print(f"  [OK] {count} images telechargees -> total now: {after}")

    print("\n" + "="*65)
    print(f"  TERMINE -- {grand_total} nouvelles images telechargees")
    print("\n  Repartition finale :")
    for cls in ["eco", "off_topic", "nsfw"]:
        tr = count_images("train", cls)
        vl = count_images("val",   cls)
        print(f"    {cls:>10} : train={tr:>4} | val={vl:>4} | total={tr+vl:>4}")
    print("\n  Prochaine etape :")
    print("  python moderation_ai/train_image_resnet.py")
    print("="*65 + "\n")


if __name__ == "__main__":
    main()
