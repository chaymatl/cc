import pandas as pd, os
df = pd.read_csv('moderation_ai/data/text_dataset.csv')
print(f"Text dataset: {len(df)} exemples")
print(df['label'].value_counts().to_string())
print()
for split in ['train', 'val']:
    d = f'moderation_ai/data/image_dataset/{split}'
    if os.path.isdir(d):
        for c in ['eco', 'off_topic', 'nsfw']:
            cd = os.path.join(d, c)
            if os.path.isdir(cd):
                n = len([f for f in os.listdir(cd) if f.lower().endswith(('.jpg','.jpeg','.png','.webp'))])
                print(f"  {split}/{c}: {n} images")
