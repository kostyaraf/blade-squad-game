#!/usr/bin/env python3
"""Draw Power Blade 2's hero into Solbrain's sprite layout.

The two engines lay a man out differently -- different tile slots, different
number of 8x16 sprites, different anchor.  Rather than translate one metasprite
format into the other, this takes the shape Solbrain draws (which tile slot
goes where, ripped from the running game) and fills those slots with the pixels
of the matching Power Blade 2 frame, rasterised and re-cut.  The engine then
draws its own layout and gets somebody else's man.
"""
import collections, os, pickle, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import rip                                                    # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
SOL = os.path.join(ROOT, 'Tokkyuu Shirei Solbrain (Japan).nes')
PB2 = os.path.join(ROOT, 'Power Blade 2 (USA).nes')
PB3 = os.path.join(ROOT, 'work/build/PB3.nes')
CACHE = os.path.join(ROOT, 'work/build/frames.pkl')

SOL_BANKS = {64, 65, 66, 67, 70, 85, 92}


SOL_PATTERNS = [
    [('RIGHT', 0), ('RIGHT', 6), ('RIGHT', 12), ('RIGHT', 18),
     ('RIGHT,A', 24), ('RIGHT,A', 30), ('RIGHT', 38), ('B', 44),
     ('B', 48), ('-', 52), ('DOWN', 56), ('-', 62), ('LEFT', 66),
     ('LEFT', 72), ('LEFT', 78), ('A', 84), ('-', 92)],
    [('RIGHT', 0), ('RIGHT', 20), ('RIGHT,A', 28), ('RIGHT', 36),
     ('B', 42), ('UP', 48), ('UP,A', 54), ('-', 60), ('DOWN', 64),
     ('DOWN,B', 70), ('-', 76), ('LEFT', 80), ('LEFT,B', 88), ('-', 94)],
    [('-', 0), ('A', 8), ('-', 16), ('B', 22), ('-', 28), ('UP', 34),
     ('-', 40), ('DOWN', 46), ('-', 52), ('LEFT', 58), ('LEFT,A', 66),
     ('LEFT', 74), ('RIGHT', 82), ('RIGHT,B', 90), ('-', 96)],
]


def sol_script(start=2000, end=5200, step=100, pat=0):
    L = ['40 START', '50 -', '80 START', '90 -', '400 START', '410 -']
    p = SOL_PATTERNS[pat % len(SOL_PATTERNS)]
    f = start
    while f < end:
        L += ['%d %s' % (f + o, k) for k, o in p]
        f += step
    return L


def pb2_script(start=2400, end=5600, step=100):
    L = open(os.path.join(ROOT, 'work/re/pb2play.inp')).read().splitlines()
    pat = [('LEFT', 0), ('LEFT', 6), ('LEFT', 12), ('LEFT', 18), ('LEFT', 24),
           ('LEFT,A', 30), ('LEFT,A', 36), ('LEFT', 44), ('B', 50), ('-', 56),
           ('DOWN', 60), ('-', 66), ('RIGHT', 70), ('RIGHT', 76),
           ('RIGHT', 82), ('A', 88), ('-', 96)]
    f = start
    while f < end:
        L += ['%d %s' % (f + o, k) for k, o in pat]
        f += step
    return L


def clean(frames, banks, maxtile, lo=3, hi=10):
    """Keep the man's own sprites and re-anchor to his bounding box."""
    out = {}
    for k, (fno, sprs, tag) in frames.items():
        m = [s for s in sprs if s[3] in banks and (maxtile is None or s[4] < maxtile)]
        if not lo <= len(m) <= hi:
            continue
        x0 = min(s[0] for s in m)
        y1 = max(s[1] for s in m)
        m = [[s[0] - x0, s[1] - y1, s[2], s[3], s[4]] for s in m]
        kk = tuple(sorted((s[0], s[1], s[2] & 0xC3, s[3], s[4]) for s in m))
        out.setdefault(kk, (fno, m, tag))
    return out


def collect(force=False):
    if os.path.exists(CACHE) and not force:
        return pickle.load(open(CACHE, 'rb'))
    sol, pb2 = {}, {}
    for i, (a, b) in enumerate(((2000, 5200), (2050, 5250), (2000, 5400),
                                (2030, 5300), (2010, 5100), (2070, 5270))):
        s = sol_script(a, b, pat=i)
        sol.update(rip.tag_frames(PB3, s, b, list(range(a, b, 7)),
                                  '/tmp/nsol%d_%d' % (a, i), rip.sol_origin))
    for a, b in ((2400, 5600), (2450, 5650)):
        s = pb2_script(a, b)
        pb2.update(rip.tag_frames(PB2, s, b, list(range(a, b, 7)),
                                  '/tmp/npb2%d' % a, rip.pb2_origin))
    sol = man_sized(clean(sol, SOL_BANKS, 0x20))
    pb2 = man_sized(clean(pb2, set(range(6)), None, 4, 8))
    os.makedirs(os.path.dirname(CACHE), exist_ok=True)
    pickle.dump((sol, pb2), open(CACHE, 'wb'))
    return sol, pb2


if __name__ == '__main__':
    sol, pb2 = collect('-f' in sys.argv)
    print('solbrain frames %d, power blade frames %d' % (len(sol), len(pb2)))
    slots = collections.Counter()
    where = collections.defaultdict(set)
    for k, (f, m, t) in sol.items():
        for dx, dy, at, bank, idx in m:
            slots[(bank, idx)] += 1
            where[(bank, idx)].add((dx, dy))
    print('distinct tile slots %d' % len(slots))
    multi = {k: v for k, v in where.items() if len(v) > 1}
    print('slots drawn at more than one place: %d of %d'
          % (len(multi), len(where)))


# --- turning ripped frames into new CHR ------------------------------------

def bbox(frame):
    xs = [s[0] for s in frame] + [s[0] + 7 for s in frame]
    ys = [s[1] for s in frame] + [s[1] + 15 for s in frame]
    return min(xs), min(ys), max(xs), max(ys)


def raster(rom_path, frame):
    """Draw one ripped frame into a pixel grid, flips resolved.

    Returns (pixels, x0, y1): the grid and where its own anchor sits, so two
    men of different builds can be lined up by their feet and their middle.
    """
    x0, y0, x1, y1 = bbox(frame)
    w, h = x1 - x0 + 1, y1 - y0 + 1
    px = [[0] * w for _ in range(h)]
    for dx, dy, at, bank, idx in frame:
        for half in range(2):
            d = rip.tiles_of(rom_path, bank, idx + half)
            for y in range(8):
                lo, hi = d[y], d[y + 8]
                for x in range(8):
                    v = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                    if not v:
                        continue
                    sx = dx + (7 - x if at & 0x40 else x) - x0
                    sy = dy + (half * 8 + y if not at & 0x80
                               else 15 - (half * 8 + y)) - y0
                    if 0 <= sx < w and 0 <= sy < h:
                        px[sy][sx] = v
    return px, x0, y0


def cut(px, ax, ay, w=8, h=16, flip=0):
    """Take an 8x16 window out of a rasterised man, as two CHR tiles."""
    out = bytearray(32)
    for y in range(h):
        for x in range(w):
            sx, sy = ax + x, ay + y
            v = px[sy][sx] if 0 <= sy < len(px) and 0 <= sx < len(px[0]) else 0
            if flip & 0x40:
                v = px[sy][ax + (w - 1 - x)] if 0 <= sy < len(px) and \
                    0 <= ax + (w - 1 - x) < len(px[0]) else 0
            if not v:
                continue
            t, yy = (0, y) if y < 8 else (16, y - 8)
            if v & 1:
                out[t + yy] |= 0x80 >> x
            if v & 2:
                out[t + 8 + yy] |= 0x80 >> x
    return bytes(out)


def activity(tag):
    if 'A' in tag.replace('LEFT', '').replace('RIGHT', ''):
        return 'jump'
    if 'B' in tag:
        return 'attack'
    if 'DOWN' in tag:
        return 'duck'
    if 'LEFT' in tag or 'RIGHT' in tag:
        return 'walk'
    return 'idle'


def man_sized(frames, wmax=44, hmax=50, hmin=24):
    """Drop frames that caught something else -- a pickup, a shot, a piece of
    an enemy standing on him.  A man is about two tiles wide and three tall."""
    out = {}
    for k, v in frames.items():
        x0, y0, x1, y1 = bbox(v[1])
        if x1 - x0 + 1 <= wmax and hmin <= y1 - y0 + 1 <= hmax:
            out[k] = v
    return out


def match(sol, pb2):
    """Pair every Solbrain frame with the Power Blade frame that is doing the
    same thing and is built the same way -- same activity first, then the
    closest silhouette, so a jump is not filled with a crouch."""
    buckets = collections.defaultdict(list)
    for k, (f, m, t) in sorted(pb2.items(), key=lambda kv: kv[1][0]):
        buckets[activity(t)].append(m)
    if not buckets:
        raise SystemExit('no power blade frames ripped')
    order = collections.defaultdict(int)
    out = {}
    for k, (f, m, t) in sorted(sol.items(), key=lambda kv: kv[1][0]):
        a = activity(t)
        pool = buckets.get(a) or buckets.get('idle') or next(iter(buckets.values()))
        sx0, sy0, sx1, sy1 = bbox(m)
        sw, sh = sx1 - sx0 + 1, sy1 - sy0 + 1

        def fit(p):
            px0, py0, px1, py1 = bbox(p)
            return abs((px1 - px0 + 1) - sw) + 2 * abs((py1 - py0 + 1) - sh)
        pool = sorted(pool, key=fit)
        out[k] = pool[order[a] % max(1, min(3, len(pool)))]
        order[a] += 1
    return out


def ink_box(px):
    """Where the pixels actually are, which is not where the sprites are."""
    xs, ys = [], []
    for y, row in enumerate(px):
        for x, v in enumerate(row):
            if v:
                xs.append(x)
                ys.append(y)
    if not xs:
        return None
    return min(xs), min(ys), max(xs), max(ys)


def build_banks(sol, pb2):
    """Fill every Solbrain tile slot with the matching piece of a PB2 frame.

    A slot is one 8x16 sprite of one bank.  It is used by several frames, not
    always in the same place, so the place it is used most often wins; the rest
    come out a pixel or two off, which is invisible next to getting the man
    right.  Slots never seen in a rip keep Solbrain's own art.
    """
    pairs = match(sol, pb2)
    votes = collections.defaultdict(collections.Counter)
    for k, (f, m, t) in sol.items():
        for dx, dy, at, bank, idx in m:
            votes[(bank, idx)][(k, dx, dy, at & 0x40)] += 1

    banks = {}
    filled = 0
    for (bank, idx), cnt in votes.items():
        (k, dx, dy, flip), _ = cnt.most_common(1)[0]
        frame = sol[k][1]
        px, nx0, ny0 = raster(PB2, pairs[k])
        sp, sx0, sy0 = raster(SOL, frame)
        ib, sb = ink_box(px), ink_box(sp)
        if not ib or not sb:
            continue
        # line the two men up by their feet and their middle, using where the
        # pixels are and not where the sprite boxes are
        ncx = (ib[0] + ib[2]) / 2.0 + nx0
        nby = ib[3] + ny0
        scx = (sb[0] + sb[2]) / 2.0 + sx0
        sby = sb[3] + sy0
        ax = int(round(dx - scx + ncx)) - nx0
        ay = int(round(dy - sby + nby)) - ny0
        banks.setdefault(bank, {})[idx] = cut(px, ax, ay, flip=flip)
        filled += 1
    return banks, filled


def bank_bytes(rom_path, bank, slots):
    """One finished 1K bank: new art where we have it, the original elsewhere."""
    rom = open(rom_path, 'rb').read()
    chr0 = 16 + rom[4] * 0x4000
    out = bytearray(rom[chr0 + bank * 1024:chr0 + (bank + 1) * 1024])
    for idx, data in slots.items():
        out[idx * 16:idx * 16 + 32] = data
    return bytes(out)


def preview(sol, banks, path):
    """Redraw every ripped Solbrain frame out of the new banks."""
    import struct, zlib
    frames = [m for k, (f, m, t) in sorted(sol.items(), key=lambda kv: kv[1][0])]
    cols, cw, chh, scale = 10, 40, 48, 3
    rows = (len(frames) + cols - 1) // cols
    W, H = cols * cw, rows * chh
    grid = [[0] * W for _ in range(H)]
    for i, frame in enumerate(frames):
        bx, by = (i % cols) * cw + 10, (i // cols) * chh + chh - 10
        for dx, dy, at, bank, idx in frame:
            data = banks.get(bank, {}).get(idx)
            if data is None:
                continue
            for half in range(2):
                d = data[half * 16:half * 16 + 16]
                for y in range(8):
                    lo, hi = d[y], d[y + 8]
                    for x in range(8):
                        v = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                        if not v:
                            continue
                        sx = bx + dx + (7 - x if at & 0x40 else x)
                        sy = by + dy + (half * 8 + y if not at & 0x80
                                        else 15 - (half * 8 + y))
                        if 0 <= sx < W and 0 <= sy < H:
                            grid[sy][sx] = v
    pal = [(12, 12, 40), (245, 245, 245), (215, 75, 75), (85, 155, 255)]
    raw = b''
    for row in grid:
        line = b''.join(bytes(pal[v]) * scale for v in row)
        for _ in range(scale):
            raw += b'\x00' + line
    ch = lambda t, d: (struct.pack('>I', len(d)) + t + d +
                       struct.pack('>I', zlib.crc32(t + d)))
    open(path, 'wb').write(
        b'\x89PNG\r\n\x1a\n' +
        ch(b'IHDR', struct.pack('>IIBBBBB', W * scale, H * scale, 8, 2, 0, 0, 0)) +
        ch(b'IDAT', zlib.compress(raw)) + ch(b'IEND', b''))


# --- what the cartridge builder asks for -----------------------------------

# Solbrain's player art bank -> the bank holding the same poses drawn as the
# Power Blade 2 hero.  Measured: those are the only banks the engine ever puts
# in the player's CHR slot.
NOVA_BASE = 128
SOL_ORDER = [64, 65, 66, 67, 70, 85, 92]
R3_BANK = 86            # what normally sits in the slot player two borrows


def novabanks():
    """(mapping, [1K bank images]) ready to be appended to the CHR."""
    sol, pb2 = collect()
    banks, filled = build_banks(sol, pb2)
    rom = open(SOL, 'rb').read()
    chr0 = 16 + rom[4] * 0x4000

    def orig(b):
        return bytearray(rom[chr0 + b * 1024:chr0 + (b + 1) * 1024])

    out, mapping = [], {}
    for i, b in enumerate(SOL_ORDER):
        # the lower half is the man; the upper half has to keep what the
        # borrowed slot normally holds, or every object drawn out of tiles
        # $60-$7F turns to rubble the moment player two joins
        img = orig(b)
        img[0x200:0x400] = orig(R3_BANK)[0x200:0x400]
        for idx, data in banks.get(b, {}).items():
            img[idx * 16:idx * 16 + 32] = data
        out.append(bytes(img))
        mapping[b] = NOVA_BASE + i
    return mapping, out, filled


if __name__ == '__main__' and '-emit' in sys.argv:
    m, imgs, filled = novabanks()
    print('%d slots redrawn, %d banks: %s' % (filled, len(imgs), m))
