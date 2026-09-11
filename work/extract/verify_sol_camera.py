#!/usr/bin/env python3
"""Э4.1 acceptance: where Solbrain's view stands, engine against cartridge.

The hero is seeded off the cartridge exactly as the movement stand seeds him,
a list of buttons is played, and on every frame the view's own two numbers --
$30:$31 across and $32:$33 down -- plus the byte that says which way it may
go ($05D8) are written down on both sides and must agree exactly.

The view is not a matter of taste here: it moves by the hero's own speed and
only while he is outside a band held in the middle of the screen, so a single
frame out of step shows up at once and never heals.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
import sol_probe as P                                            # noqa: E402
sys.path.insert(0, HERE)
import verify_sol_player as V                                    # noqa: E402

GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
GAME = os.path.join(ROOT, 'game')

WATCH = {0x30, 0x31, 0x32, 0x33, 0x05D8}
NAMES = ('cam x', 'cam y', 'want')


def cartridge(state, pads, base):
    rows = P.watched(state, V.cartridge_script(pads, base), base,
                     base + len(pads), WATCH)
    out = []
    for _fr, c in rows[:-1]:
        out.append((c[0x30] | c[0x31] << 8, c[0x32] | c[0x33] << 8, c[0x05D8]))
    return out


def engine(cfg, scratch):
    path = os.path.join(scratch, 'cam.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--solcam=%s' % path],
                       capture_output=True, text=True, timeout=300)
    rows = []
    for line in r.stdout.split('\n'):
        f = line.split()
        if len(f) == 3 and all(x.lstrip('-').isdigit() for x in f):
            rows.append(tuple(int(x) for x in f))
    if not rows:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return rows


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('solcam')
    try:
        bad = 0
        total = 0
        for label, stage, spot in V.PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, spot)
            base = P.ram(state, [(first, '-')], first)
            cfg0 = V.snapshot(base)
            cfg0['cam_x'] = base[0x30] | base[0x31] << 8
            cfg0['cam_y'] = base[0x32] | base[0x33] << 8
            cfg0['ride_hold'] = base[0x05C3]
            cfg0['ride_fall'] = base[0x34]
            # The view moves on the speed he had when it ran, and on the first
            # frame that is the speed the cartridge was carrying already.
            cfg0['vx'] = V.s16(base[0x05B6], base[0x05B7])
            cfg0['vy'] = V.s16(base[0x05B8], base[0x05B9])
            for name, pads in sorted(V.SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                want = cartridge(state, pads, play)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                got = engine(cfg, scratch)
                n = min(len(want), len(got))
                where = None
                for i in range(n):
                    if want[i] != got[i]:
                        where = i
                        break
                if where is None and len(want) != len(got):
                    where = n
                if where is None:
                    print('%-6s %-11s ok, %d frames' % (label, name, n))
                    continue
                bad += 1
                print('%-6s %-11s differs on frame %d' % (label, name, where))
                if where < n:
                    for k, nm in enumerate(NAMES):
                        if want[where][k] != got[where][k]:
                            print('    %-5s cartridge %6d   engine %6d'
                                  % (nm, want[where][k], got[where][k]))
                else:
                    print('    cartridge %d frames, engine %d'
                          % (len(want), len(got)))
                sys.stdout.flush()
        print('%d of %d views differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
