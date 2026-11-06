import subprocess, sys, os

req_path = r"C:\Users\lenovo\Desktop\EcoRewind\backend\requirements.txt"

with open(req_path, "rb") as f:
    content = f.read().decode("utf-8")

# Remplacer bcrypt==4.0.1 par bcrypt>=4.0.1 pour eviter le hash-pinning strict
old = "bcrypt==4.0.1"
new = "bcrypt>=4.0.1"
if old in content:
    content = content.replace(old, new)
    print(f"OK: {old} -> {new}")
else:
    print(f"INFO: '{old}' non trouve, rien a changer")

with open(req_path, "wb") as f:
    f.write(content.encode("utf-8"))

print("requirements.txt mis a jour.")
