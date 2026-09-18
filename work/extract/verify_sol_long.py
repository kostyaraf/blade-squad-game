#!/usr/bin/env python3
"""Э4.22 acceptance: the same walk about, but long enough to matter.

Every walk-about stand so far runs forty pictures, or a hundred and twenty for
the "far" scripts.  Э4.21 showed what that hides: the getting-up branch of mind
$0B had both of its compares wrong, and the first picture that parts company
over it is the two hundred and twenty ninth -- further than any stand had ever
looked.

So this one asks the same question over a much longer run, and asks it of both
pools at once: all seven numbers of the sixteen object slots and all six of the
sixteen shot slots, on every finished picture of twelve hundred.
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
import verify_sol_minds as M                                     # noqa: E402
import verify_sol_shots as H                                     # noqa: E402
import verify_sol_draw as D                                      # noqa: E402

# $C3E0 and $C398 are the two places the blanking pays off what the stage's own
# script asked of the lift's line ($75 += $74).  Neither the script nor the
# blanking is this stand's business, so what was asked for is read here and
# handed to the engine picture by picture.
PAID = (0xC3E0, 0xC398)

SLOTS = S.SLOTS
SHOTS = S.SHOTS
LEN = 1200
R = S.R
L = S.L
A = S.A

SCRIPTS = {
    'still':          S.hold(LEN, 0),
    'right':          S.hold(LEN, R),
    'left':           S.hold(LEN, L),
    'there and back': S.hold(LEN // 2, R) + S.hold(LEN // 2, L),
    # Something has to leave the ground now and then, or half of what a turn
    # can do is never asked for.
    'hopping right':  (S.hold(10, R) + S.hold(8, R | A)) * (LEN // 18),
}

PLACES = [('s%d' % n, n) for n in range(20)]


def cartridge(state, pads, base):
    """Both pools, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.POOL) | set(S.POS) | set(S.TICKS)
    addrs |= {p + i for p in S.FIELDS for i in range(SLOTS)}
    for p in H.PAGES:
        addrs |= {p + i for i in range(SHOTS)}
    rows = P.watched(state, script, base, base + len(pads), addrs)
    pool, shot, ticks = [], [], []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04]))
        pool.append(tuple(
            (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
             c[0xC0 + i] | c[0xD0 + i] << 8,
             c[0x0650 + i], c[0x0690 + i], c[0x0660 + i], c[0x0670 + i])
            for i in range(SLOTS)))
        shot.append(tuple(
            (c[0x0780 + i], c[0x0790 + i] | c[0x07A0 + i] << 8,
             c[0x07B0 + i] | c[0x07C0 + i] << 8,
             c[0x07D0 + i], c[0x07E0 + i], c[0x07F0 + i])
            for i in range(SHOTS)))
    return pool, shot, ticks


def line(state, pads, base, scratch):
    """What the blanking was asked to move the lift's line by, per picture."""
    inp = os.path.join(scratch, 'line.inp')
    last = None
    with open(inp, 'w') as f:
        for i, p in enumerate(pads):
            if p != last:
                names = [n for n, b in V.BITS if p & b]
                f.write('%d %s\n' % (base + i, ','.join(names) or '-'))
                last = p
    cmd = [D.EMU, P.ROM, '-loadstate', state, '-input', inp,
           '-frames', str(base + len(pads))]
    outs = []
    for k, a in enumerate(PAID):
        path = os.path.join(scratch, 'paid%d.bin' % k)
        outs.append(path)
        cmd += ['-ramat', '%s@%04X' % (path, a)]
    subprocess.run(cmd, check=True, capture_output=True)
    got = {}
    for path in outs:
        if not os.path.exists(path):
            continue
        with open(path, 'rb') as f:
            while True:
                b = f.read(D.REC)
                if len(b) < D.REC:
                    break
                fr = struct.unpack('<I', b[:4])[0]
                got[fr] = (got.get(fr, 0) + b[8 + 0x74]) & 0xFF
        os.remove(path)
    os.remove(inp)
    return [got.get(base + i, 0) for i in range(len(pads))]


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=1800)
    pool, shot = [], []
    for line in r.stdout.split('\n'):
        if line.startswith('S '):
            f = line[2:].split()
            if len(f) == SHOTS and all(t.count(',') == 5 for t in f):
                shot.append(tuple(tuple(int(v) for v in t.split(','))
                                  for t in f))
            continue
        f = line.split()
        if len(f) != SLOTS or not all(t.count(',') == 6 for t in f):
            continue
        pool.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    owed = {}
    for line in r.stderr.split('\n'):
        for head in ('minds not read yet: ', 'shots not read yet: ',
                     'weapons not read yet: ', 'satellite not read yet: '):
            if not line.startswith(head):
                continue
            body = line.split(': ', 1)[1].replace('"', '')
            for part in body.strip('{}').split(','):
                k, _, v = part.partition(':')
                if v.strip().isdigit():
                    key = head.split()[0] + ' ' + k.strip()
                    owed[key] = owed.get(key, 0) + int(v)
    if not pool:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return pool, shot, owed


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('long')
    try:
        bad = total = 0
        owed = {}
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(SCRIPTS.items()):
                if only and name not in only:
                    continue
                total += 1
                wp, ws, tk = cartridge(state, pads, play)
                cfg = dict(cfg0)
                cfg['pads'] = pads
                cfg['clock_at'] = [t[0] for t in tk]
                cfg['noise_at'] = [t[1] for t in tk]
                cfg['six_at'] = [t[2] for t in tk]
                cfg['step_at'] = [t[3] for t in tk]
                cfg['ride_at'] = [t[4] for t in tk]
                cfg['new_at'] = [t[5] for t in tk]
                cfg['line_at'] = line(state, pads, play, scratch)
                # Э4.23 -- the stage's own script runs.  It is not scenery to a
                # stand of the pool: $A211 is one of several steps that write a
                # slot's own kind, and without it a stage's machinery never
                # moves on.
                cfg['script'] = 1
                gp, gs, missing = engine(cfg, scratch)
                for k, v in missing.items():
                    owed[k] = owed.get(k, 0) + v
                n = min(len(wp), len(ws), len(gp), len(gs))
                done = S.finished(tk, n)
                where = kind = None
                for i in range(n):
                    if not done[i]:
                        continue
                    if wp[i] != gp[i]:
                        where, kind = i, 'pool'
                        break
                    if ws[i] != gs[i]:
                        where, kind = i, 'shots'
                        break
                if where is None:
                    print('%-6s %-16s ok, %d frames' % (label, name, n))
                    sys.stdout.flush()
                    continue
                bad += 1
                print('%-6s %-16s %s differs on frame %d'
                      % (label, name, kind, where))
                w, g, names, count = (ws, gs, H.NAMES, SHOTS) \
                    if kind == 'shots' else (wp, gp, M.NAMES, SLOTS)
                for j in range(count):
                    if w[where][j] == g[where][j]:
                        continue
                    for k, nm in enumerate(names):
                        if w[where][j][k] != g[where][j][k]:
                            print('    slot %2d %-6s cartridge %6d'
                                  '   engine %6d'
                                  % (j, nm, w[where][j][k], g[where][j][k]))
                sys.stdout.flush()
        print('%d of %d long runs differ' % (bad, total))
        if owed:
            print('not read yet: %s'
                  % ', '.join('%s x%d' % (k, v) for k, v in sorted(owed.items())))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
