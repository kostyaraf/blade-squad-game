"""Render a whole Solbrain stage as a PNG map, with the room grid, the player
start and the game's own object placements drawn on top.  This is the picture a
level converter has to reproduce."""
import sys, os
_d = os.path.dirname(os.path.abspath(__file__))
# work/tools has a dis.py that shadows the standard library's, which PIL needs
sys.path[:] = [p for p in sys.path if os.path.abspath(p or '.') != _d]
from PIL import Image, ImageDraw
sys.path.append(_d)
import sol_levels

NES_PAL = [
 (84,84,84),(0,30,116),(8,16,144),(48,0,136),(68,0,100),(92,0,48),(84,4,0),(60,24,0),
 (32,42,0),(8,58,0),(0,64,0),(0,60,0),(0,50,60),(0,0,0),(0,0,0),(0,0,0),
 (152,150,152),(8,76,196),(48,50,236),(92,30,228),(136,20,176),(160,20,100),(152,34,32),(120,60,0),
 (84,90,0),(40,114,0),(8,124,0),(0,118,40),(0,102,120),(0,0,0),(0,0,0),(0,0,0),
 (236,238,236),(76,154,236),(120,124,236),(176,98,236),(228,84,236),(236,88,180),(236,106,100),(212,136,32),
 (160,170,0),(116,196,0),(76,208,32),(56,204,108),(56,180,204),(60,60,60),(0,0,0),(0,0,0),
 (236,238,236),(168,204,236),(188,188,236),(212,178,236),(236,174,236),(236,174,212),(236,180,176),(228,196,144),
 (204,210,120),(180,222,120),(168,226,144),(152,226,180),(160,214,228),(160,162,160),(0,0,0),(0,0,0)]


def chr_tiles(rom, banks):
    """256 background tiles from MMC3 R0/R1 (2 KB each, 1 KB units)."""
    chr_rom = rom.chr
    out = []
    for kb in (banks[0] & 0xFE, (banks[0] & 0xFE) + 1, banks[1] & 0xFE, (banks[1] & 0xFE) + 1):
        base = kb * 0x400
        for t in range(64):
            out.append(chr_rom[base + t * 16: base + t * 16 + 16])
    return out


def render(rom, stage, path, overlay=True):
    st = sol_levels.Stage(rom, stage)
    x0, y0, x1, y1 = st.bbox()
    W, H = (x1 - x0 + 1) * 256, (y1 - y0 + 1) * 256
    tiles = chr_tiles(rom, st.chr_banks)
    pal = st.palette[:16]
    img = Image.new('RGB', (W, H), (0, 0, 0))
    px = img.load()
    used = set(st.used_rooms())
    for ry in range(y0, y1 + 1):
        for rx in range(x0, x1 + 1):
            if (rx, ry) not in used:
                continue
            for ty in range(32):
                for tx in range(32):
                    t = st.tile_at(rx * 32 + tx, ry * 32 + ty)
                    if t is None:
                        continue
                    p = st.palette_at(rx * 16 + tx // 2, ry * 16 + ty // 2) or 0
                    g = tiles[t]
                    ox, oy = (rx - x0) * 256 + tx * 8, (ry - y0) * 256 + ty * 8
                    for r in range(8):
                        a, b = g[r], g[r + 8]
                        for c in range(8):
                            v = ((a >> (7 - c)) & 1) | (((b >> (7 - c)) & 1) << 1)
                            px[ox + c, oy + r] = NES_PAL[pal[p * 4 + v] & 0x3F]
    if overlay:
        d = ImageDraw.Draw(img, 'RGBA')
        for ry in range(y0, y1 + 2):
            d.line([(0, (ry - y0) * 256), (W, (ry - y0) * 256)], fill=(255, 255, 0, 120))
        for rx in range(x0, x1 + 2):
            d.line([((rx - x0) * 256, 0), ((rx - x0) * 256, H)], fill=(255, 255, 0, 120))
        sx = st.start_x / 16 - x0 * 256
        sy = st.start_y / 16 - y0 * 256
        d.ellipse([sx - 7, sy - 7, sx + 7, sy + 7], outline=(255, 255, 255, 255), width=3)
        for room, g in st.room_objects.items():
            grp = st.object_groups.get(g) or {}
            for o in grp.get('objects', ()):
                ox = o['x_px'] - x0 * 256
                oy = o['y_px'] - y0 * 256
                d.rectangle([ox - 6, oy - 6, ox + 6, oy + 6], outline=(255, 0, 0, 255))
                d.text((ox - 5, oy - 5), '%02X' % o['kind'], fill=(255, 255, 0, 255))
    img.save(path)
    print(f"stage {stage}: {W}x{H} rooms {x0},{y0}..{x1},{y1} -> {path}")
    return st


if __name__ == '__main__':
    rom = sol_levels.Rom("Tokkyuu Shirei Solbrain (Japan).nes")
    out = sys.argv[1] if len(sys.argv) > 1 else '/tmp/solmap'
    os.makedirs(out, exist_ok=True)
    for s in [int(x) for x in sys.argv[2:]] or range(20):
        render(rom, s, f'{out}/stage%02d.png' % s)
