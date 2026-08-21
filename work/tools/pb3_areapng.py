"""Render the areas a Solbrain stage converts into, exactly as Power Blade 2
will show them, with every solid tile outlined.  This is the picture to compare
against work/tools/sol_map.py's rendering of the original stage."""
import sys, os
_d = os.path.dirname(os.path.abspath(__file__))
# work/tools has a dis.py that shadows the standard library's, which PIL needs
sys.path[:] = [p for p in sys.path if os.path.abspath(p or '.') != _d]
from PIL import Image, ImageDraw
sys.path.append(_d)
import sol2pb2, sol_levels
from sol_map import NES_PAL


def tile_image(chunk, pal):
    px = []
    for r in range(8):
        lo, hi = chunk[r], chunk[r + 8]
        px.append([((lo >> (7 - c)) & 1) | (((hi >> (7 - c)) & 1) << 1)
                   for c in range(8)])
    return px


def render(stage, out):
    st, screens, areas, bands = sol2pb2.convert(stage)
    first_solid = st.pb3_collision[0][0]
    pal = st.palette[:16]
    for ai, ids in enumerate(areas):
        W, H = len(ids) * 256, len(screens[ids[0]].tiles) * 8
        img = Image.new('RGB', (W, H), (0, 0, 0))
        d = ImageDraw.Draw(img)
        for n, si in enumerate(ids):
            s = screens[si]
            for ty, row in enumerate(s.tiles):
                for tx, t in enumerate(row):
                    ch = st.pb3_chr[t * 16: t * 16 + 16]
                    a = s.attrs[ty // 4][tx // 4] >> (((ty // 2) & 1) * 2
                                                      + ((tx // 2) & 1)) * 2
                    base = (a & 3) * 4
                    px = tile_image(ch, pal)
                    x0, y0 = n * 256 + tx * 8, ty * 8
                    for r in range(8):
                        for c in range(8):
                            v = px[r][c]
                            img.putpixel((x0 + c, y0 + r),
                                         NES_PAL[pal[base + v] & 0x3F])
                    if t >= first_solid:
                        d.point([(x0, y0), (x0 + 7, y0 + 7)], fill=(255, 0, 0))
        img.save(f'{out}/stage%02d_area%02d.png' % (stage, ai))
    print(f'stage {stage}: {len(areas)} areas, bands {bands} -> {out}')


if __name__ == '__main__':
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for s in [int(x) for x in sys.argv[2:]]:
        render(s, out)
