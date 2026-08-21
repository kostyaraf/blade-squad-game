"""Tile PNGs into one sheet, `montage.py OUT COLS FILE...`."""
import sys, os
_d = os.path.dirname(os.path.abspath(__file__))
sys.path[:] = [p for p in sys.path if os.path.abspath(p or '.') != _d]
from PIL import Image
out, cols, files = sys.argv[1], int(sys.argv[2]), sys.argv[3:]
ims = [Image.open(f).convert('RGB') for f in files]
w, h = ims[0].size
rows = (len(ims) + cols - 1) // cols
o = Image.new('RGB', (w * cols, h * rows))
for i, im in enumerate(ims):
    o.paste(im, ((i % cols) * w, (i // cols) * h))
o.save(out)
print(out, o.size, len(ims))
