"""
EcoRewind -- Script de ré-entraînement complet (v2)
====================================================
Orchestre dans l'ordre :
  1. Régénération du dataset texte (9 000 exemples)
  2. Téléchargement des images manquantes
  3. Entraînement Text CNN
  4. Entraînement ResNet18
  5. Test rapide des deux modèles

Usage :
    cd backend
    python -X utf8 moderation_ai/retrain_all.py [--skip-images] [--text-only] [--image-only]

Options :
  --skip-images  : ne pas re-télécharger les images (utiliser celles existantes)
  --text-only    : entraîner uniquement le Text CNN
  --image-only   : entraîner uniquement le ResNet18
"""

import os, sys, time, argparse

_HERE    = os.path.dirname(os.path.abspath(__file__))
_BACKEND = os.path.dirname(_HERE)
sys.path.insert(0, _BACKEND)


def separator(title: str):
    w = 65
    print(f"\n{'='*w}")
    print(f"  {title}")
    print(f"{'='*w}\n")


def step_build_text_dataset():
    separator("ÉTAPE 1/4 -- Génération du dataset texte (9 000 exemples)")
    from moderation_ai.build_text_dataset import build_dataset, OUT
    build_dataset(OUT, n_per_class=3000)


def step_download_images():
    separator("ÉTAPE 2/4 -- Téléchargement des images manquantes")
    # Import et exécution
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "download_image_dataset",
        os.path.join(_HERE, "download_image_dataset.py")
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    mod.main()


def step_train_text():
    separator("ÉTAPE 3/4 -- Entraînement Text CNN")
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "train_text_cnn",
        os.path.join(_HERE, "train_text_cnn.py")
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    mod.train()


def step_train_image():
    separator("ÉTAPE 4/4 -- Entraînement ResNet18 (fine-tuning)")
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "train_image_resnet",
        os.path.join(_HERE, "train_image_resnet.py")
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    mod.train()


def step_test_models():
    separator("TEST RAPIDE -- Vérification des modèles rechargés")
    try:
        from moderation_ai.eco_moderator import EcoCNNModerator
        moderator = EcoCNNModerator()

        test_cases = [
            # (texte, label_attendu)
            ("J'ai ramassé les déchets sur la plage ce matin avec des bénévoles", "eco"),
            ("Nettoyage du parc municipal avec l'association verte", "eco"),
            ("Terrible accident sur l'autoroute, 3 blessés graves", "off_topic"),
            ("Quel match incroyable hier soir, 3-0 !", "off_topic"),
            ("Cette application est nulle, arnaque de merde", "toxic"),
            ("Je m'en fous de la nature, jeter par terre c'est plus simple", "toxic"),
            ("Bonjour tout le monde !", "uncertain"),
            ("Recyclage du plastique aujourd'hui", "eco"),
        ]

        print(f"{'Texte':<50} | {'CNN':>8} | {'Score':>6}")
        print("-" * 70)

        for text, expected in test_cases:
            if not moderator._text_cnn:
                print("[WARN] Text CNN non disponible")
                break
            probs = moderator._text_cnn.predict(text)
            best  = max(probs, key=probs.get)
            score = probs[best]
            icon  = "[OK]" if best == expected else ("[WARN] " if expected == "uncertain" else "[ERR]")
            short = text[:48] + ".." if len(text) > 50 else text
            print(f"{icon} {short:<50} | {best:>8} | {score:>5.2f}")

        print()
        print("[OK] Test Text CNN terminé")

    except Exception as e:
        print(f"[WARN] Erreur lors du test : {e}")


def main():
    parser = argparse.ArgumentParser(description="EcoRewind -- Ré-entraînement complet")
    parser.add_argument("--skip-images", action="store_true",
                        help="Ne pas télécharger/regénérer les images")
    parser.add_argument("--text-only",   action="store_true",
                        help="Entraîner uniquement le Text CNN")
    parser.add_argument("--image-only",  action="store_true",
                        help="Entraîner uniquement le ResNet18")
    args = parser.parse_args()

    t_start = time.time()

    print("\n" + "[*] " * 20)
    print("  ECOREWIND -- PIPELINE DE RÉ-ENTRAÎNEMENT COMPLET v2")
    print("[*] " * 20)

    if not args.image_only:
        step_build_text_dataset()

    if not args.skip_images and not args.text_only:
        step_download_images()

    if not args.image_only:
        step_train_text()

    if not args.text_only:
        step_train_image()

    step_test_models()

    elapsed = time.time() - t_start
    m, s = divmod(int(elapsed), 60)
    print(f"\n{'='*65}")
    print(f"  [OK] PIPELINE TERMINÉ en {m}min {s}s")
    print(f"  Modèles dans : {os.path.join(_HERE, 'models')}")
    print(f"    - eco_text_cnn.pth")
    print(f"    - eco_image_resnet.pth")
    print(f"    - vocab.pkl")
    print(f"\n  Redémarrez le backend FastAPI pour charger les nouveaux modèles.")
    print(f"{'='*65}\n")


if __name__ == "__main__":
    main()
