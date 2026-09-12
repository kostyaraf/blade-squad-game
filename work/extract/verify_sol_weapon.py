#!/usr/bin/env python3
"""Э4.2 acceptance: the pool the hero's satellite throws into.

A third pool lives at $0700, apart from the sixteen slots for things and the
sixteen for what they throw.  $B168 in bank thirteen walks it once a picture --
slot seven down to slot nought, and no further, though the pool is sixteen wide
-- inside the same call that draws the hero ($CDD2 is $9150, which is "draw him
and then walk this").

Nothing puts anything into the pool until the satellite itself is ported, so
the stand puts things there by hand: a load of eight slots is written straight
into the cartridge's memory on the first picture that is played, and the engine
is handed exactly the same eight.  Both then walk them and must answer the same
six numbers -- behaviour, place, the two bytes the behaviour keeps and how much
it can still go through -- on every picture.

The loads between them name all twenty two flying behaviours and all five of
the burning-out ones that do anything beyond letting the slot go.

A slot that leaves the stage upwards is dropped.  Row nought of every stage's
room map is not a row of screens at all -- it is padding, and the numbers in it
are not screen numbers -- so a thing standing there makes the cartridge read a
screen that does not exist and answer with whatever bytes happen to follow the
table.  That is the cartridge reading off the end of its own data, not a rule
worth copying, so a slot is compared only while it is still inside the stage.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402
import verify_sol_spawns as S                                    # noqa: E402

WALKED = 8                # $B168 counts X down from seven
NAMES = ('kind', 'x', 'y', 'vx', 'vy', 'pen')
PAGES = (0x0700, 0x0710, 0x0720, 0x0730, 0x0740, 0x0750, 0x0760, 0x0770)

# $AF84 / $AFB0 / $AFDC -- what the cartridge's own spawn routine would put in
# the two bytes and the budget for each of the twenty two behaviours.  They are
# used as the seed so that a hand-written load is one the game could have made.
XVEL = [0x33, 0x40, 0x43, 0x77, 0x40, 0x00, 0x40, 0x40, 0x74, 0x48, 0x53,
        0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 0x50, 0x33]
YVEL = [0x02, 0x40, 0x43, 0x02, 0x30, 0x10, 0x40, 0x40, 0x02, 0x28, 0x30,
        0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x0D, 0x0D, 0x02]
PEN = [0x01, 0x01, 0x01, 0x7F, 0x01, 0x01, 0x01, 0x01, 0x7F, 0x01, 0x01,
       0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x10, 0x10, 0x01]

# The six behaviours that bounce keep nothing in their own two bytes when the
# cartridge makes them, which would leave them standing still; they are given a
# step so that the walls are actually reached.
STEP = {0x0C: (0x43, 0x43), 0x0D: (0x43, 0xBD), 0x0E: (0xBD, 0x43),
        0x10: (0x30, 0xD0), 0x11: (0xD0, 0x30), 0x0F: (0xBD, 0xBD)}

# Four loads of eight.  Together they name every entry of both tables.
LOADS = {
    'flying 0-7':   [0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87],
    'flying 8-15':  [0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F],
    'flying 16-21': [0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x83, 0x87],
    'burning out':  [0x03, 0x07, 0x04, 0x09, 0x12, 0x15, 0x00, 0x0B],
}

SCRIPTS = {
    'still': S.SCRIPTS['still'],
    'right': S.SCRIPTS['right'],
    'there and back': S.SCRIPTS['there and back'],
}

PLACES = [('s0', 0), ('s1', 1), ('s2', 2), ('s5', 5), ('s9', 9)]

INSIDE = 0x1100           # room row nought is padding: the stage starts at
                          # $1000, and a slot looks a little ahead of itself


def inside(rows):
    """Which slots are still worth comparing, picture by picture.

    Once the cartridge has a slot standing in room row nought it is reading the
    padding at the top of the room map, and nothing it answers after that means
    anything.  The slot is dropped for the rest of the run.
    """
    out = []
    left = set()
    for r in rows:
        for s in range(WALKED):
            if r[s][0] != 0 and r[s][2] < INSIDE:
                left.add(s)
        out.append(frozenset(s for s in range(WALKED) if s not in left))
    return out


def seen(row, keep):
    return tuple(row[s] for s in sorted(keep))


def load(kinds, hx, hy):
    """A load of eight slots, laid out in a row a little above the hero."""
    out = []
    for i, k in enumerate(kinds):
        t = k & 0x7F
        vx, vy = STEP.get(t, (XVEL[t], YVEL[t]))
        out.append(dict(kind=k,
                        x=(hx + (i - 4) * 0x100) & 0xFFFF,
                        y=(hy - 0x180) & 0xFFFF,
                        vx=vx, vy=vy, pen=PEN[t]))
    return out


def pokes(slots, frame):
    """The load, written straight into the cartridge on picture `frame`."""
    out = []
    for i, s in enumerate(slots):
        out.append((0x0700 + i, s['kind'], frame))
        out.append((0x0710 + i, s['x'] & 0xFF, frame))
        out.append((0x0720 + i, s['x'] >> 8, frame))
        out.append((0x0730 + i, s['y'] & 0xFF, frame))
        out.append((0x0740 + i, s['y'] >> 8, frame))
        out.append((0x0750 + i, s['vx'], frame))
        out.append((0x0760 + i, s['vy'], frame))
        out.append((0x0770 + i, s['pen'], frame))
    return out


def cartridge(state, pads, base, pk):
    script = V.cartridge_script(pads, base)
    addrs = set(S.TICKS)
    for p in PAGES:
        addrs |= {p + i for i in range(WALKED)}
    rows = P.watched(state, script, base, base + len(pads), addrs, pokes=pk)
    out = []
    ticks = []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04]))
        out.append(tuple(
            (c[0x0700 + i],
             c[0x0710 + i] | c[0x0720 + i] << 8,
             c[0x0730 + i] | c[0x0740 + i] << 8,
             c[0x0750 + i], c[0x0760 + i], c[0x0770 + i])
            for i in range(WALKED)))
    return out, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=600)
    rows = []
    for line in r.stdout.split('\n'):
        if not line.startswith('W '):
            continue
        f = line[2:].split()
        if len(f) != WALKED or not all(t.count(',') == 5 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    missing = {}
    for line in r.stderr.split('\n'):
        if line.startswith('weapons not read yet: '):
            body = line.split(': ', 1)[1].replace('"', '')
            for part in body.strip('{}').split(','):
                k, _, v = part.partition(':')
                if v.strip().isdigit():
                    missing[k.strip()] = missing.get(k.strip(), 0) + int(v)
    if not rows:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return rows, missing


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    loads = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--load=')]
    scratch = P.scratch('weapon')
    try:
        bad = total = 0
        owed = {}
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            base = P.ram(state, [(first, '-')], first)
            cfg0 = S.seed(base)
            hx = base[0x80] | base[0x81] << 8
            hy = base[0x82] | base[0x83] << 8
            for lname, kinds in sorted(LOADS.items()):
                if loads and lname not in loads:
                    continue
                slots = load(kinds, hx, hy)
                pk = pokes(slots, play)
                for name, pads in sorted(SCRIPTS.items()):
                    if only and name not in only:
                        continue
                    total += 1
                    want, ticks = cartridge(state, pads, play, pk)
                    cfg = dict(cfg0)
                    cfg['pads'] = pads
                    cfg['clock_at'] = [t[0] for t in ticks]
                    cfg['noise_at'] = [t[1] for t in ticks]
                    cfg['six_at'] = [t[2] for t in ticks]
                    cfg['step_at'] = [t[3] for t in ticks]
                    cfg['ride_at'] = [t[4] for t in ticks]
                    cfg['new_at'] = [t[5] for t in ticks]
                    for k in ('wkind', 'wx', 'wy', 'wvx', 'wvy', 'wpen'):
                        cfg[k] = list(cfg0[k])
                    for i, s in enumerate(slots):
                        cfg['wkind'][i] = s['kind']
                        cfg['wx'][i] = s['x']
                        cfg['wy'][i] = s['y']
                        cfg['wvx'][i] = s['vx']
                        cfg['wvy'][i] = s['vy']
                        cfg['wpen'][i] = s['pen']
                    got, missing = engine(cfg, scratch)
                    for k, v in missing.items():
                        owed[k] = owed.get(k, 0) + v
                    n = min(len(want), len(got))
                    done = S.finished(ticks, n)
                    keep = inside(want)
                    where = None
                    for i in range(n):
                        if done[i] and seen(want[i], keep[i]) \
                                != seen(got[i], keep[i]):
                            where = i
                            break
                    if where is None and len(want) != len(got):
                        where = n
                    tag = '%s / %s' % (lname, name)
                    if where is None:
                        print('%-4s %-30s ok, %d frames' % (label, tag, n))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    print('%-4s %-30s differs on frame %d' % (label, tag, where))
                    if where < n:
                        for s in sorted(keep[where]):
                            if want[where][s] == got[where][s]:
                                continue
                            for k, nm in enumerate(NAMES):
                                if want[where][s][k] != got[where][s][k]:
                                    print('    slot %d %-4s cartridge %6d'
                                          '   engine %6d'
                                          % (s, nm, want[where][s][k],
                                             got[where][s][k]))
                    else:
                        print('    cartridge %d frames, engine %d'
                              % (len(want), len(got)))
                    sys.stdout.flush()
        print('%d of %d scripts differ' % (bad, total))
        if owed:
            print('weapon behaviours not read yet: %s'
                  % ', '.join('%s x%d' % (k, v) for k, v in sorted(owed.items())))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
