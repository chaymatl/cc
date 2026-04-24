import os
base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "image_dataset")
exts = {".jpg", ".jpeg", ".png", ".webp"}
for s in ["train", "val"]:
    for c in ["eco", "off_topic", "nsfw"]:
        d = os.path.join(base, s, c)
        if os.path.isdir(d):
            count = len([f for f in os.listdir(d) if os.path.splitext(f)[1].lower() in exts])
            print(f"  {s}/{c}: {count} images")
        else:
            print(f"  {s}/{c}: (missing)")
