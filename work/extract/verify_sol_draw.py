#!/usr/bin/env python3
"""Э4.20 acceptance: the hero's own four slots put into the sprite table.

$A489 in bank twelve walks slots $0C to $0F, and every way through that walk
ends by drawing the slot -- $A6CD for four of the five, and $A564, which is
handed whole pixels at a fixed place, for the ring drawn while the satellite is
still being made.  Nothing else in the picture touches the table between the
two, so the cartridge is stopped either side of the walk alone: work memory is
written down at $A489, before the first slot, and again at $A52E, the RTS the
walk comes out by.

The engine is handed the memory as it stood at $A489 -- the pool, the hero, the
view, the table and the four cursors the drawing carries -- and must answer
with the same two hundred and fifty-six bytes of table, the same cursors, the
same four tile banks and the same eighteen numbers of each of the four slots.

A satellite is put there by hand, the same eleven bytes $92CD and $9347 write,
because getting one the way the game does means picking up three letters.
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
import verify_sol_spawns as S                                    # noqa: E402
import verify_sol_sat as T                                       # noqa: E402

EMU = os.path.join(ROOT, 'work', 'tools', 'nesemu')
# $A000 is the upper half of the pair, so both points report bank thirteen.
BEFORE, AFTER, BANK = 0xA489, 0xA52E, 13
REC = 8 + 2048
FIRST, HANDS = T.FIRST, T.HANDS
NAMES, PAGES = T.NAMES, T.PAGES


def records(path):
    """The work memory as it stood each time one of the two points was hit."""
    out = []
    if not os.path.exists(path):
        return out
    with open(path, 'rb') as f:
        while True:
            b = f.read(REC)
            if len(b) < REC:
                break
            fr, _pc, bank = struct.unpack('<IHH', b[:8])
            if bank == BANK:
                out.append((fr, b[8:]))
    return out


def play(state, pads, base, scratch, pokes=()):
    """Play the buttons and stop the cartridge either side of the walk.

    $A52E is the walk's own RTS but also the one $A531 takes when a slot that
    is not the satellite is asked during its making, so a picture can reach it
    more than once; the last of them is the one the walk came out by.
    """
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
    first = {}
    for fr, m in records(pre):
        first.setdefault(fr, m)
    final = {}
    for fr, m in records(post):
        final[fr] = m
    return [(fr, first[fr], final[fr]) for fr in sorted(first)
            if fr >= base and fr in final]


def slots(m):
    """The eighteen numbers of each of the four, the way $AF20 writes them."""
    out = []
    for i in range(HANDS):
        s = FIRST + i
        row = []
        for k, p in enumerate(PAGES):
            if NAMES[k] == 'x':
                row.append(m[0xA0 + s] | m[0xB0 + s] << 8)
            elif NAMES[k] == 'y':
                row.append(m[0xC0 + s] | m[0xD0 + s] << 8)
            else:
                row.append(m[p + s])
        out.append(tuple(row))
    return tuple(out)


def frame(m):
    """What the engine is handed for one picture."""
    cfg = S.seed(m)
    cfg['clock'] = m[0x0C]
    # $06 is the buttons the hero is handed and $04 what was pressed this
    # picture; the satellite reads both to know whether to fire.
    cfg['six'] = m[0x06]
    cfg['pad_new'] = m[0x04]
    cfg['count'] = m[0x6A]
    cfg['turn'] = m[0x6B]
    cfg['fwd'] = m[0x6C]
    cfg['back'] = m[0x6D]
    cfg['banks'] = [m[0x42], m[0x43], m[0x44], m[0x45]]
    cfg['oam'] = list(m[0x200:0x300])
    return cfg


def wanted(m):
    return (list(m[0x200:0x300]), m[0x6A], m[0x6B], m[0x6C], m[0x6D],
            [m[0x42], m[0x43], m[0x44], m[0x45]], slots(m))


def engine(cfg, scratch):
    path = os.path.join(scratch, 'draw.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--soldraw=%s' % path], capture_output=True, text=True,
                       timeout=600)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) == 9 + HANDS and len(f[0]) == 512:
            rows.append(([int(f[0][i:i + 2], 16) for i in range(0, 512, 2)],
                         int(f[1]), int(f[2]), int(f[3]), int(f[4]),
                         [int(x) for x in f[5:9]],
                         tuple(tuple(int(v) for v in t.split(','))
                               for t in f[9:])))
    if not rows:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return rows


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    guns = [int(a.split('=')[1]) for a in sys.argv[1:]
            if a.startswith('--weapon=')]
    letters_only = '--letters' in sys.argv[1:]
    scratch = P.scratch('draw')
    try:
        bad = total = 0
        for label, stage in T.PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play_at = first + 1
            state = V.stand(scratch, label, stage, None)
            base = P.ram(state, [(first, '-')], first)
            face = (base[0x05B2] & 0x80) != 0
            for tag0, made, scripts in T.cases(face, guns, letters_only):
                pk = [(a, v, play_at) for a, v in sorted(made.items())]
                for name, pads in sorted(scripts.items()):
                    if only and name not in only:
                        continue
                    total += 1
                    rows = play(state, pads, play_at, scratch, pk)
                    if _one(label, '%s / %s' % (tag0, name), rows, scratch):
                        bad += 1
        print('%d of %d runs differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


def _one(label, name, rows, scratch):
    """One run of one place: the whole table, picture by picture."""
    if not rows:
        print('%-4s %-28s nothing to draw' % (label, name))
        return False
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
        print('%-4s %-28s ok, %d pictures' % (label, name, n))
        sys.stdout.flush()
        return False
    if where is None:
        print('%-4s %-28s the engine gave %d pictures, not %d'
              % (label, name, len(got), len(want)))
        return True
    print('%-4s %-28s differs on picture %d' % (label, name, where))
    w, g = want[where], got[where]
    shown = 0
    for k in range(256):
        if w[0][k] != g[0][k]:
            print('    sprite %d.%d  cartridge %3d  engine %3d'
                  % (k // 4, k % 4, w[0][k], g[0][k]))
            shown += 1
            if shown == 4:
                break
    for k, nm in enumerate(('count', 'turn', 'fwd', 'back'), 1):
        if w[k] != g[k]:
            print('    %-6s cartridge %3d  engine %3d' % (nm, w[k], g[k]))
    if w[5] != g[5]:
        print('    tiles  cartridge %s  engine %s' % (w[5], g[5]))
    for i in range(HANDS):
        for k, nm in enumerate(NAMES):
            if w[6][i][k] != g[6][i][k]:
                print('    slot %02X %-7s cartridge %6d  engine %6d'
                      % (FIRST + i, nm, w[6][i][k], g[6][i][k]))
    return True


if __name__ == '__main__':
    sys.exit(main())
