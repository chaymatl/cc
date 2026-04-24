"""
EcoRewind — Correction dataset + ré-entraînement ResNet18
==========================================================
Ce script :
  1. Purge les dossiers off_topic et nsfw du dataset actuel
  2. Re-télécharge avec de NOUVELLES requêtes sans ambiguïté
  3. Ré-entraîne ResNet18 et sauvegarde le meilleur modèle

Pourquoi ?
  Le test réseau montre que off_topic est confondu avec nsfw à 85%
  car les requêtes "violence/crash/war" créent des images similaires
  aux contenus nsfw (corps, sang, scènes choquantes).

Usage :
    cd backend
    python -X utf8 moderation_ai/retrain_image_fix.py
"""

import os, sys, shutil, random, time
_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(_HERE))

DATA_DIR = os.path.join(_HERE, "data", "image_dataset")
MDL_DIR  = os.path.join(_HERE, "models")
MDL_PATH = os.path.join(MDL_DIR, "eco_image_resnet.pth")

# ── Nouvelles requêtes (sans ambiguïté visuelle) ─────────────────────────────
NEW_QUERIES = {
    "off_topic": [
        ("football match stadium sport crowd",   80),
        ("election campaign politics speech",    80),
        ("restaurant food plate meal dining",    80),
        ("shopping mall retail clothing store",  80),
        ("business meeting office corporate",    80),
        ("music concert band performance",       80),
        ("travel tourism landmark city",         80),
        ("cooking recipe kitchen chef",          70),
        ("car automobile road driving",          70),
        ("fitness gym workout exercise",         70),
        ("news anchor broadcast television",     60),
        ("school classroom students learning",   60),
    ],
    "nsfw": [
        ("lingerie fashion model photoshoot",    90),
        ("bikini swimwear beach model",          90),
        ("pin up vintage poster illustration",   80),
        ("adult magazine cover vintage",         70),
        ("nude classical art painting",          70),
        ("provocative fashion advertising",      60),
    ],
}

TRAIN_RATIO = 0.80

G    = "\033[92m"
Y    = "\033[93m"
R    = "\033[91m"
B    = "\033[94m"
BOLD = "\033[1m"
RST  = "\033[0m"


def count_images(split, cls):
    d = os.path.join(DATA_DIR, split, cls)
    if not os.path.isdir(d):
        return 0
    return len([f for f in os.listdir(d)
                if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp'))])


def purge_class(cls):
    """Supprime toutes les images de la classe dans train/ et val/."""
    for split in ["train", "val"]:
        d = os.path.join(DATA_DIR, split, cls)
        if os.path.isdir(d):
            removed = 0
            for f in os.listdir(d):
                if f.lower().endswith(('.jpg', '.jpeg', '.png', '.webp', '.bmp')):
                    os.remove(os.path.join(d, f))
                    removed += 1
            print(f"  → {split}/{cls}: {removed} images supprimées")


def download_class(cls, queries):
    """Télécharge les images pour la classe via Bing Image Search."""
    try:
        from icrawler.builtin import BingImageCrawler
    except ImportError:
        print(f"{R}[ERR] icrawler non installé — pip install icrawler{RST}")
        return 0

    train_dir = os.path.join(DATA_DIR, "train", cls)
    val_dir   = os.path.join(DATA_DIR, "val",   cls)
    tmp_dir   = os.path.join(DATA_DIR, "_tmp",  cls)
    os.makedirs(train_dir, exist_ok=True)
    os.makedirs(val_dir,   exist_ok=True)
    os.makedirs(tmp_dir,   exist_ok=True)

    # Purger tmp
    for f in os.listdir(tmp_dir):
        try: os.remove(os.path.join(tmp_dir, f))
        except: pass

    for query, n in queries:
        print(f"    >> '{query}' → {n} images...")
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
            print(f"    {Y}[WARN]{RST} '{query}': {e}")

    valid_ext  = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
    all_images = [f for f in os.listdir(tmp_dir)
                  if os.path.splitext(f)[1].lower() in valid_ext]
    random.shuffle(all_images)

    split_idx  = int(len(all_images) * TRAIN_RATIO)
    for fname in all_images[:split_idx]:
        shutil.move(os.path.join(tmp_dir, fname), os.path.join(train_dir, fname))
    for fname in all_images[split_idx:]:
        shutil.move(os.path.join(tmp_dir, fname), os.path.join(val_dir, fname))

    try: shutil.rmtree(tmp_dir)
    except: pass

    return len(all_images)


def retrain():
    """Lance le script d'entraînement principal."""
    import subprocess
    train_script = os.path.join(_HERE, "train_image_resnet.py")
    backend_dir  = os.path.dirname(_HERE)
    print(f"\n{BOLD}Lancement de l'entraînement ResNet18...{RST}")
    result = subprocess.run(
        [sys.executable, "-X", "utf8", train_script],
        cwd=backend_dir,
    )
    return result.returncode == 0


def run_test():
    """Lance le test de validation et retourne l'accuracy."""
    import subprocess
    test_script = os.path.join(_HERE, "test_resnet.py")
    backend_dir  = os.path.dirname(_HERE)
    result = subprocess.run(
        [sys.executable, "-X", "utf8", test_script],
        cwd=backend_dir,
    )
    return result.returncode == 0


# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print(f"\n{BOLD}{B}{'='*60}{RST}")
    print(f"{BOLD}  EcoRewind — Correction Dataset + Ré-entraînement ResNet18{RST}")
    print(f"{BOLD}{B}{'='*60}{RST}\n")

    # ── Étape 1 : Compter l'état actuel ───────────────────────────────────────
    print(f"{BOLD}[1/4] État actuel du dataset :{RST}")
    for cls in ["eco", "off_topic", "nsfw"]:
        tr = count_images("train", cls)
        vl = count_images("val",   cls)
        print(f"    {cls:>10} : train={tr:>4} | val={vl:>4}")

    # ── Étape 2 : Purger off_topic et nsfw ────────────────────────────────────
    print(f"\n{BOLD}[2/4] Purge des classes problématiques :{RST}")
    for cls in NEW_QUERIES:
        print(f"  [{cls}]")
        purge_class(cls)

    # ── Étape 3 : Re-télécharger ──────────────────────────────────────────────
    print(f"\n{BOLD}[3/4] Téléchargement des nouvelles images :{RST}")
    for cls, queries in NEW_QUERIES.items():
        target = sum(n for _, n in queries)
        print(f"\n  [{cls.upper()}] Cible: ~{target} images")
        count = download_class(cls, queries)
        tr = count_images("train", cls)
        vl = count_images("val",   cls)
        print(f"  {G}✓{RST} {count} images → train={tr}, val={vl}")

    # ── Résumé dataset ────────────────────────────────────────────────────────
    print(f"\n{BOLD}Dataset final :{RST}")
    for cls in ["eco", "off_topic", "nsfw"]:
        tr = count_images("train", cls)
        vl = count_images("val",   cls)
        ok = G if tr >= 100 else R
        print(f"    {cls:>10} : {ok}train={tr:>4}{RST} | {ok}val={vl:>4}{RST}")

    # ── Étape 4 : Ré-entraîner ────────────────────────────────────────────────
    print(f"\n{BOLD}[4/4] Ré-entraînement ResNet18...{RST}")
    ok = retrain()

    if ok:
        print(f"\n{G}✅ Entraînement terminé !{RST}")
        print(f"\n{BOLD}Validation du nouveau modèle :{RST}")
        test_ok = run_test()
        if test_ok:
            print(f"\n{G}🎉 Le pipeline ResNet18 est entièrement fonctionnel !{RST}")
        else:
            print(f"\n{Y}⚠️  Le modèle est entraîné mais l'accuracy reste < 70%.{RST}")
            print(f"   Essayez d'ajouter plus d'images ou d'ajuster les seuils.")
    else:
        print(f"\n{R}❌ L'entraînement a échoué. Vérifiez les logs ci-dessus.{RST}")
