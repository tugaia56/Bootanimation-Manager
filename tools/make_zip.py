"""Builds the flashable module zip from ../module (run: python tools/make_zip.py)."""
import os, zipfile

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SRC = os.path.join(ROOT, "module")
OUT = os.path.join(ROOT, "release", "Magisk_Bootanimation_Manager_A14-A17.zip")
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    for base, _, files in os.walk(SRC):
        for f in sorted(files):
            p = os.path.join(base, f)
            rel = os.path.relpath(p, SRC).replace("\\", "/")
            data = open(p, "rb").read()
            if rel.endswith((".sh", ".prop")) or rel in ("META-INF/com/google/android/update-binary", "META-INF/com/google/android/updater-script"):
                data = data.replace(b"\r\n", b"\n")      # the phone shell rejects CRLF
            z.writestr(rel, data, compress_type=zipfile.ZIP_STORED if rel.endswith(".webp") else zipfile.ZIP_DEFLATED)
print("built", OUT)
