#!/usr/bin/env python3
"""Э3.10b acceptance: the screen a stage is picked on, point for point.

The cartridge is stood on that screen ($18/$19 := 3/$14, which is where the
map leaves it), played with a script of buttons, and photographed.  The engine
is given the same script and photographed too, and the two pictures have to be
the same -- every one of the sixty-one thousand points of them.

What that catches is everything the screen is: the two pages of names, the
colours, the patch over a stage already finished, where the ground stands, the
two slices the screen is drawn in, the man and the sign over him, and the ride
from one sign to the next.

Run with no arguments it walks every scene there is.
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_probe as P                                        # noqa: E402
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402

GODOT, GAME = V.GODOT, V.GAME

# $18 := 3 and $19 := $14 is what the map hands over ($8838).  The stage, the
# stages already finished and the suits already taken are poked a picture
# earlier, because $8838 reads $53 the moment it starts.
SET_AT = 60
PUSH_AT = 61
# ...and sixty-four pictures later the screen stands at step 12, waiting for
# the pad.  That is picture nought of a scene; everything is counted from it.
READY = 64
# $28 -- where in the sprite table the writing starts.  It is a running count
# ($44 a picture) and the screen inherits it, so which of the pieces the
# console drops when more than eight stand on a line depends on it.  Every
# scene here comes out of the same boot, so at picture nought it is this.
ROT = 0xB8

# stage, $5B, $56, the script, and the pictures to look at.
#
# A scene is a stage to stand on and a script of buttons.  The four the game
# itself can be in are all here: nothing pressed, the ride right, the ride
# left, and the pad pushed back mid-ride ($8985).
SCENES = [
    ('still', 0, 0x00, 0x00, [], [2, 3, 30, 90]),
    # Three stamps and more make the dressing step run a second picture, and
    # the man stands still through it: pictures 31 and 33 are the ones where
    # that one picture shows, the others agree either way.
    ('cleared', 0, 0x0F, 0x00, [], [2, 30, 33]),
    ('cleared-three', 3, 0x07, 0x00, [], [2, 30, 31]),
    ('two', 2, 0x03, 0x00, [], [2, 40]),
    ('ride-right', 0, 0x00, 0x00, [('-', 8), ('RIGHT', 4)],
     [16, 48, 88, 136, 168]),
    ('ride-left', 2, 0x00, 0x00,
     [('-', 8), ('LEFT', 4), ('-', 20), ('LEFT', 4)],
     [16, 40, 60, 100, 140]),
    ('turn-about', 0, 0x00, 0x00, [('-', 8), ('LEFT', 4)], [10, 16, 24, 40]),
    ('changed-mind', 0, 0x00, 0x00,
     [('-', 8), ('RIGHT', 4), ('-', 30), ('LEFT', 4)],
     [48, 60, 80, 110, 150, 200, 240]),
    ('mind-late', 2, 0x00, 0x00,
     [('-', 8), ('LEFT', 4), ('-', 90), ('RIGHT', 4)],
     [110, 130, 170, 230, 280]),
    ('edge-right', 3, 0x00, 0x00, [('-', 8), ('RIGHT', 4)], [16, 40]),
    ('fifth', 3, 0x0F, 0x00, [('-', 8), ('RIGHT', 4)],
     [16, 48, 136, 151, 168]),
    ('refused', 0, 0x01, 0x01, [('-', 8), ('START', 4)], [16, 40]),
]

# The picture unit is two pictures behind the cartridge: step 21 pushes the
# colours into the queue and the blanking after it empties them, so the first
# two pictures of a scene show the screen before it is dressed.  Nothing is
# looked at inside them.
FIRST = 2
# And what is on the screen during a picture is what the cartridge worked out
# in the one before it: the sprite table and the scroll are both handed to the
# picture unit in the blanking that opens the picture.  So the cartridge's
# picture `w` is the engine's step `w - 1`.
LAG = 1


def script_frames(script):
    """The script as one button word a picture."""
    out = []
    for keys, n in script:
        out += [keys] * n
    return out


def cartridge(stage, cleared, owned, script, want, into):
    """Photograph the cartridge on that screen at each wanted picture."""
    state = pb2_trace.state_for(P.PICK_LEVEL, 0, 0, None)
    d = P.scratch('select')
    try:
        inp = os.path.join(d, 'i.inp')
        frames = script_frames(script)
        with open(inp, 'w') as f:
            f.write('%d -\n' % P.PICK_LEVEL)
            for n, keys in enumerate(frames):
                f.write('%d %s\n' % (P.PICK_LEVEL + READY + n, keys or '-'))
            f.write('%d -\n' % (P.PICK_LEVEL + READY + len(frames)))
        last = max(want)
        shots = ','.join(str(P.PICK_LEVEL + READY + w) for w in want)
        cmd = P.emu(
            '-loadstate', state, '-input', inp,
            '-frames', str(P.PICK_LEVEL + READY + last + 2),
            '-poke', '0053=%02X@%d' % (stage, P.PICK_LEVEL + SET_AT),
            '-poke', '005B=%02X@%d' % (cleared, P.PICK_LEVEL + SET_AT),
            '-poke', '0056=%02X@%d' % (owned, P.PICK_LEVEL + SET_AT),
            '-poke', '0019=14@%d' % (P.PICK_LEVEL + PUSH_AT),
            '-poke', '0018=03@%d' % (P.PICK_LEVEL + PUSH_AT),
            '-png', os.path.join(into, 'rom'), '-shot', shots)
        subprocess.run(cmd, check=True, capture_output=True)
        return {w: os.path.join(into, 'rom_%d.png'
                                % (P.PICK_LEVEL + READY + w)) for w in want}
    finally:
        P.sweep(d)


def engine(stage, cleared, owned, script, want, into):
    """The same, out of the engine, a step earlier -- see `LAG`."""
    spec = '%d:%d:%d' % (cleared, owned, ROT)
    for keys, n in script:
        spec += ',%s:%d' % (keys.replace(',', '+') or '-', n)
    spec += ',%s,%s' % ('+'.join(str(w - LAG) for w in want),
                        os.path.join(into, 'eng'))
    r = subprocess.run([GODOT, '--path', GAME, '--rendering-driver', 'opengl3',
                        '--resolution', '256x240', '--quit-after', '600', '--',
                        '--select=' + spec, '--stage=%d' % stage],
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError(r.stdout[-2000:] + r.stderr[-2000:])
    return {w: os.path.join(into, 'eng_%d.png' % (w - LAG)) for w in want}


def differ(a, b):
    """How many points of the two pictures are not the same."""
    from PIL import Image
    x = Image.open(a).convert('RGB')
    y = Image.open(b).convert('RGB')
    if x.size != y.size:
        return x.size[0] * x.size[1]
    return sum(1 for p, q in zip(x.get_flattened_data(),
                                 y.get_flattened_data()) if p != q)


def run(only=None):
    bad = 0
    d = P.scratch('selshots')
    try:
        for name, stage, cleared, owned, script, want in SCENES:
            if only and name != only:
                continue
            rom = cartridge(stage, cleared, owned, script, want, d)
            eng = engine(stage, cleared, owned, script, want, d)
            for w in want:
                n = differ(rom[w], eng[w])
                if n:
                    bad += 1
                    print('%-14s picture %4d  %6d points differ'
                          % (name, w, n))
                else:
                    print('%-14s picture %4d  ok' % (name, w))
    finally:
        P.sweep(d)
    print('%d of the pictures differ' % bad)
    return bad


if __name__ == '__main__':
    sys.exit(1 if run(sys.argv[1] if len(sys.argv) > 1 else None) else 0)
