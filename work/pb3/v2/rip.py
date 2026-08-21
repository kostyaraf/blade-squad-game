#!/usr/bin/env python3
"""Rip a hero's animation frames straight out of a running game.

Reverse engineering the metasprite tables of two different engines is a lot of
work for something the games will tell us themselves: play, dump what the PPU
was actually about to draw, and keep the sprites that belong to the man.  A
frame comes out as the list of 8x16 sprites that make him up, each with its
offset from his feet, its attribute byte, and the CHR bank and tile it came
from -- which is everything needed to redraw him as somebody else.
"""
import os, struct, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.dirname(os.path.abspath(__file__)))))
EMU = os.path.join(ROOT, 'work/tools/nesemu')

VR_OAM, VR_CTRL, VR_SCAN, VR_RAM = 2092, 2365, 2382, 6222


class Dump:
    def __init__(self, path):
        d = open(path, 'rb').read()
        self.oam = d[VR_OAM:VR_OAM + 256]
        self.ctrl = d[VR_CTRL]
        self.scan = [struct.unpack('<8H', d[VR_SCAN + y * 16:VR_SCAN + y * 16 + 16])
                     for y in range(240)]
        self.ram = d[VR_RAM:VR_RAM + 2048]

    def sprites(self):
        """(y, tile, attr, x) for every live OAM entry."""
        return [(self.oam[i], self.oam[i + 1], self.oam[i + 2], self.oam[i + 3])
                for i in range(0, 256, 4) if self.oam[i] < 0xEF]

    def bank_of(self, y, tile):
        """Which 1K CHR bank the PPU had mapped where this tile lives."""
        table = tile & 1                        # 8x16: the tile's bit 0
        slot = 4 * table + ((tile & 0xFE) >> 6)
        return self.scan[min(239, y + 1)][slot]


def play(rom, script, frames, at, prefix):
    """Run the game once and dump the PPU state at each frame in `at`."""
    inp = prefix + '.inp'
    open(inp, 'w').write('\n'.join(script) + '\n')
    cmd = [EMU, rom, '-input', inp, '-frames', str(frames)]
    out = []
    for f in at:
        p = '%s_%d.vram' % (prefix, f)
        cmd += ['-vram', '%s@%d' % (p, f)]
        out.append((f, p))
    subprocess.run(cmd, capture_output=True)
    return [(f, Dump(p)) for f, p in out if os.path.exists(p)]


def tiles_of(rom_path, bank, idx):
    """The 16 bytes of one 8x8 tile, out of the cartridge's CHR."""
    rom = open(rom_path, 'rb').read()
    chr0 = 16 + (rom[4] * 0x4000)
    o = chr0 + bank * 1024 + (idx & 0x3F) * 16
    return rom[o:o + 16]


def frame_key(sprs):
    """A frame is the shape it draws: offsets, flips and tiles, ordered."""
    return tuple(sorted((dx, dy, at & 0xC3, t) for dx, dy, at, t in sprs))


def collect(rom, script, frames, at, prefix, pick, origin):
    """Gather distinct frames of whatever `pick` says is the hero.

    `pick(dump, sprite)` decides membership; `origin(dump)` returns his screen
    position, so offsets are relative to the man and not to the camera.
    """
    seen = {}
    for fno, d in play(rom, script, frames, at, prefix):
        ox, oy = origin(d)
        if ox is None:
            continue
        sprs = []
        for y, t, a, x in d.sprites():
            if not pick(d, (y, t, a, x)):
                continue
            sprs.append((((x - ox + 128) & 0xFF) - 128,
                         ((y - oy + 128) & 0xFF) - 128, a,
                         (d.bank_of(y, t), t & 0xFE)))
        if not sprs:
            continue
        k = frame_key(sprs)
        seen.setdefault(k, (fno, sprs))
    return seen


# --- the two heroes --------------------------------------------------------

def sol_origin(d):
    """Solbrain: world position minus camera, both 12.4 fixed point."""
    r = d.ram
    px = (r[0x81] * 256 + r[0x80]) // 16 - (r[0x31] * 256 + r[0x30]) // 16
    py = (r[0x83] * 256 + r[0x82]) // 16 - (r[0x33] * 256 + r[0x32]) // 16
    return px, py


def pb2_origin(d):
    """Power Blade 2 keeps its objects in screen coordinates already."""
    r = d.ram
    return r[0x0508] + r[0x04F2] * 256, r[0x04C6] + r[0x04B0] * 256


def near(ox, oy, dx=28, dy=44):
    def pick(d, s):
        y, t, a, x = s
        return abs(((x - ox + 128) & 0xFF) - 128) <= dx and \
               abs(((y - oy + 128) & 0xFF) - 128) <= dy
    return pick


def held_at(script):
    """frame -> the buttons the script holds there, so a ripped frame can be
    labelled by what the player was doing when it was drawn."""
    ev = []
    for line in script:
        line = line.strip()
        if not line:
            continue
        n, _, keys = line.partition(' ')
        ev.append((int(n), '' if keys.strip() == '-' else keys.strip()))
    ev.sort()
    def at(f):
        cur = ''
        for n, k in ev:
            if n <= f:
                cur = k
            else:
                break
        return cur
    return at


def hero_frames(rom, script, frames, at, prefix, origin):
    """Distinct frames of the man, offsets normalised to his own bounding box."""
    out = {}
    for fno, d in play(rom, script, frames, at, prefix):
        ox, oy = origin(d)
        if not (0 < ox < 256 and 0 < oy < 240):
            continue
        pick = near(ox, oy)
        sprs = []
        for y, t, a, x in d.sprites():
            if not pick(d, (y, t, a, x)):
                continue
            sprs.append([((x - ox + 128) & 0xFF) - 128,
                         ((y - oy + 128) & 0xFF) - 128, a,
                         d.bank_of(y, t), t & 0xFE])
        if not sprs or len(sprs) > 12:
            continue
        x0 = min(s[0] for s in sprs)
        y1 = max(s[1] for s in sprs)
        for s in sprs:
            s[0] -= x0
            s[1] -= y1
        k = tuple(sorted((s[0], s[1], s[2] & 0xC3, s[3], s[4]) for s in sprs))
        out.setdefault(k, (fno, sprs))
    return out


def tag_frames(rom, script, frames, at, prefix, origin):
    """Ripped frames, each with the buttons that were held when it appeared."""
    held = held_at(script)
    return {k: (f, sprs, held(f))
            for k, (f, sprs) in hero_frames(rom, script, frames, at, prefix,
                                            origin).items()}


def draw_frames(rom_path, frames, path, cols=8, scale=3, cell=(40, 48)):
    """Contact sheet of ripped frames, so a human can see what was caught."""
    import zlib
    cw, chh = cell
    rows = (len(frames) + cols - 1) // cols
    W, H = cols * cw, rows * chh
    px = [[0] * W for _ in range(H)]
    for i, sprs in enumerate(frames):
        bx, by = (i % cols) * cw + 8, (i // cols) * chh + chh - 8
        for dx, dy, at, bank, idx in sprs:
            for half in range(2):
                d = tiles_of(rom_path, bank, idx + half)
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
                            px[sy][sx] = v
    pal = [(12, 12, 40), (245, 245, 245), (215, 75, 75), (85, 155, 255)]
    raw = b''
    for row in px:
        line = b''.join(bytes(pal[v]) * scale for v in row)
        for _ in range(scale):
            raw += b'\x00' + line
    ch = lambda t, d: (struct.pack('>I', len(d)) + t + d +
                       struct.pack('>I', zlib.crc32(t + d)))
    open(path, 'wb').write(
        b'\x89PNG\r\n\x1a\n' +
        ch(b'IHDR', struct.pack('>IIBBBBB', W * scale, H * scale, 8, 2, 0, 0, 0)) +
        ch(b'IDAT', zlib.compress(raw)) + ch(b'IEND', b''))
