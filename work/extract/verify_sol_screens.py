#!/usr/bin/env python3
"""Э4.5 acceptance: the screens of Solbrain that are not stages, point for
point.

The cartridge is walked or poked to each screen -- the same way
`sol_scenes.py` walked or poked it to write the scene down -- and
photographed.  The engine is asked for the same scene and photographed too,
and the two pictures are compared point by point.

What that catches is the whole of a screen: the stream that writes it, the
board it is written on, the mirroring, the sixty four bytes of colour, the
thirty two colours themselves and the banks the tiles come out of, band by
band.

Two things on a screen are not the screen.  One is what the mode writes into
the board itself -- a score counted up, a word typed out one letter at a time;
that is the mode's and not the screen's, is not ported here, and is allowed to
differ by a stated number of points.  The other is the sprites, which are not
in the board at all: the man who walks on at the end, the cursor on TEST MODE.
Those are cut out of the comparison altogether, by taking the console's own
sprite table at the same picture and leaving every point one of them covers
out of it.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                          # noqa: E402
import sol_scenes as S                                         # noqa: E402
import verify_sol_player as V                                  # noqa: E402

# How many points a scene may differ by, and why.  A point is one of the
# sixty-one thousand the screen has.
ALLOW = {
    'title': 0,
    'select': 0,
    'staff': 0,
    'test': 0,
    'bgm': 100,         # the two digits of the tune being counted
    'over': 2400,       # the two scores
    'best': 2500,       # five scores and five names
    'cleared': 2700,    # the score and the tries
    'tale': 100,        # the words, typed out one at a time
}


def cartridge(name, cfg, into):
    """Photograph the cartridge standing on that screen, and take its sprite
    table at the same picture."""
    how = cfg['how']
    d = P.scratch('shot')
    try:
        inp = os.path.join(d, 'i.inp')
        out = os.path.join(into, 'rom_' + name)
        if how[0] == 'walk':
            at = int(how[1])
            open(inp, 'w').write(P.BOOT)
            cmd = [P.EMU, P.ROM, '-input', inp, '-frames', str(at + 3),
                   '-png', out, '-shot', str(at),
                   # A picture is taken at the end of a frame and the dump at
                   # the start of one, so the sprite table that stood in the
                   # picture of frame N is the one the dump of frame N+1 has.
                   '-vram', '%s@%d' % (out + '.vram', at + 1)]
        else:
            mode, poke_at, at = how[1], how[2], how[3]
            # A scene may need more than the mode poked into it -- AREA x is
            # not drawn at all unless $55 names a stage -- and what else was
            # poked when the scene was written down is written down with it.
            also = how[4] if len(how) > 4 else []
            state = P.make_state(os.path.join(into, 'base'))
            open(inp, 'w').write('%d -\n' % (P.IN_LEVEL + 1))
            cmd = [P.EMU, P.ROM, '-loadstate', state, '-input', inp,
                   '-frames', str(at + 3),
                   '-poke', '0002=%02X@%d' % (mode, poke_at)]
            for one in also:
                cmd += ['-poke', '%s@%d' % (one, poke_at)]
            cmd += ['-png', out, '-shot', str(at),
                    # A picture is taken at the end of a frame and the dump
                    # at the start of one, so the sprite table that stood in
                    # the picture of frame N is the dump of frame N+1's.
                    '-vram', '%s@%d' % (out + '.vram', at + 1)]
        subprocess.run(cmd, check=True, capture_output=True)
        at = int(how[1]) if how[0] == 'walk' else int(how[3])
        return '%s_%d.png' % (out, at), out + '.vram'
    finally:
        P.sweep(d)


def engine(name, into):
    out = os.path.join(into, 'eng_%s.png' % name)
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--rendering-driver',
                        'opengl3', '--resolution', '256x240',
                        '--quit-after', '300', '--',
                        '--solscene=%s,%s' % (name, out)],
                       capture_output=True, text=True, timeout=300)
    if not os.path.exists(out):
        raise RuntimeError(r.stdout[-2000:] + r.stderr[-2000:])
    return out


def covered(dump):
    """Every point a sprite of the console's own table stands on.

    A sprite is eight across and, in the mode both games run the console in,
    sixteen down, and it is drawn one line lower than the table says.  A
    sprite parked below the screen is the way a game hides one.
    """
    d = S.vram(dump)
    tall = 16 if (d['ctrl'] & 0x20) else 8
    out = set()
    for i in range(64):
        y = d['oam'][i * 4] + 1
        x = d['oam'][i * 4 + 3]
        if y > 239:
            continue
        for dy in range(tall):
            for dx in range(8):
                out.add((x + dx, y + dy))
    return out


def differ(a, b, skip):
    from PIL import Image
    x = Image.open(a).convert('RGB')
    y = Image.open(b).convert('RGB')
    if x.size != y.size:
        return x.size[0] * x.size[1]
    px, py = x.load(), y.load()
    n = 0
    for j in range(x.size[1]):
        for i in range(x.size[0]):
            if (i, j) not in skip and px[i, j] != py[i, j]:
                n += 1
    return n


def main():
    import json
    only = [a for a in sys.argv[1:] if not a.startswith('-')]
    scenes = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol',
                                         'scenes.json')))['scenes']
    d = P.scratch('screens')
    bad = 0
    try:
        for name, cfg in scenes.items():
            if only and name not in only:
                continue
            rom, dump = cartridge(name, cfg, d)
            eng = engine(name, d)
            skip = covered(dump)
            n = differ(rom, eng, skip)
            cap = ALLOW.get(name, 0)
            if n > cap:
                bad += 1
                print('%-8s %6d points differ, more than the %d allowed'
                      % (name, n, cap))
            else:
                print('%-8s ok, %d points differ of the %d allowed '
                      '(%d under a sprite)' % (name, n, cap, len(skip)))
    finally:
        P.sweep(d)
    print('%d of %d screens differ' % (bad, len(scenes) if not only
                                       else len(only)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
