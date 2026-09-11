#!/usr/bin/env python3
"""Э4.1 acceptance: the hero put into the console's sprite table.

The cartridge chooses the picture in bank 12 ($937A) and lays it out in the
fixed bank ($F461).  Both are stopped either side of that one call -- the work
memory is written down at $91DA, just before `JSR $937A`, and again at $91DD,
just after it -- so what is on trial is exactly what that call did and nothing
else in the frame.

The engine is handed the hero as the first record has him, together with the
place on screen ($90..$93) and the four cursors the drawing carries ($6A..$6D),
and must answer with the same two hundred and fifty-six bytes of sprite table,
the same four cursors and the same four kilobytes of tiles ($42..$45).
"""
import json
import os
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402

EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
BEFORE, AFTER, BANK = 0x91DA, 0x91DD, 12
REC = 8 + 2048


def records(path):
    """The work memory as it stood each time one of the two points was hit."""
    out = []
    with open(path, 'rb') as f:
        while True:
            b = f.read(REC)
            if len(b) < REC:
                break
            fr, pc, bank = struct.unpack('<IHH', b[:8])
            if bank == BANK:
                out.append((fr, b[8:]))
    return out


def play(state, pads, base, scratch, pokes=()):
    """Play the buttons into the cartridge and stop it either side of the draw."""
    inp = os.path.join(scratch, 'i.inp')
    pre = os.path.join(scratch, 'pre.bin')
    post = os.path.join(scratch, 'post.bin')
    last = None
    with open(inp, 'w') as f:
        for i, p in enumerate(pads):
            if p != last:
                names = [n for n, b in V.BITS if p & b]
                f.write('%d %s\n' % (base + i, ','.join(names) or '-'))
                last = p
    cmd = [EMU, P.ROM, '-loadstate', state, '-input', inp,
           '-frames', str(base + len(pads)),
           '-ramat', '%s@%04X' % (pre, BEFORE),
           '-ramat', '%s@%04X' % (post, AFTER)]
    for a, v, fr in pokes:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, fr)]
    subprocess.run(cmd, check=True, capture_output=True)
    a, b = records(pre), records(post)
    n = min(len(a), len(b))
    return [(a[i][0], a[i][1], b[i][1]) for i in range(n)
            if a[i][0] == b[i][0] and a[i][0] >= base]


def s16(m, lo):
    return m[lo] | m[lo + 1] << 8


def frame(m):
    """What the engine is handed for one picture."""
    return dict(
        state=m[0x05A2], timer=m[0x05A3], step_t=m[0x05A4], step_i=m[0x05B4],
        pic_lo=m[0x05A6], pic_hi=m[0x05A7], hurt=m[0x05C2], suit=m[0x05C5],
        flags=m[0x05CB], jump_flags=m[0x05C9], clock=m[0x0C],
        face_left=bool(m[0x05B2] & 0x80),
        x=s16(m, 0x90), y=s16(m, 0x92),
        count=m[0x6A], turn=m[0x6B], fwd=m[0x6C], back=m[0x6D],
        banks=[m[0x42], m[0x43], m[0x44], m[0x45]],
        oam=list(m[0x200:0x300]),
    )


def wanted(m):
    return (list(m[0x200:0x300]), m[0x6A], m[0x6B], m[0x6C], m[0x6D],
            [m[0x42], m[0x43], m[0x44], m[0x45]])


def engine(cfg, scratch):
    path = os.path.join(scratch, 'oam.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--soloam=%s' % path], capture_output=True, text=True,
                       timeout=300)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) == 9 and len(f[0]) == 512:
            rows.append(([int(f[0][i:i + 2], 16) for i in range(0, 512, 2)],
                         int(f[1]), int(f[2]), int(f[3]), int(f[4]),
                         [int(x) for x in f[5:9]]))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('oam')
    try:
        bad = total = 0
        for label, stage, spot in V.PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else V.WARPED
            state = V.stand(scratch, label, stage, spot)
            for name, pads in sorted(V.SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                rows = play(state, pads, first + 1, scratch)
                cfg = dict(frames=[frame(a) for _, a, _ in rows])
                got = engine(cfg, scratch)
                want = [wanted(b) for _, _, b in rows]
                n = min(len(want), len(got))
                where = None
                for i in range(n):
                    if want[i] != got[i]:
                        where = i
                        break
                if where is None and len(got) == len(want):
                    print('%-6s %-11s ok, %d pictures' % (label, name, n))
                    continue
                bad += 1
                if where is None:
                    print('%-6s %-11s the engine gave %d pictures, not %d'
                          % (label, name, len(got), len(want)))
                    continue
                print('%-6s %-11s differs on picture %d' % (label, name, where))
                w, g = want[where], got[where]
                for k in range(256):
                    if w[0][k] != g[0][k]:
                        print('    sprite %d.%d  cartridge %d  engine %d'
                              % (k // 4, k % 4, w[0][k], g[0][k]))
                        break
                for k, nm in enumerate(('count', 'turn', 'fwd', 'back'), 1):
                    if w[k] != g[k]:
                        print('    %-6s cartridge %3d  engine %3d'
                              % (nm, w[k], g[k]))
                if w[5] != g[5]:
                    print('    tiles  cartridge %s  engine %s' % (w[5], g[5]))
        print('%d of %d pictures differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
