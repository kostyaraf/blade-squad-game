#!/usr/bin/env python3
"""Э4.4 acceptance: the hero's own punch against a wall.

$B933 is the other way the stage gets broken.  A crate is broken by something
in the pool going off next to it; a wall is broken by the hero hitting it, and
the question asked of the stage is a harder one ($B9CD): what is under the
reach must be a wall that stops something, must stop it with its bottom two
bits at two or three, and must not already be broken.

What is left behind is two things, not one: a piece of rubble in the first free
slot counting down from eleven ($B944), and a second piece let out of that one
by $8C83, which counts up from nought instead.  Which rubble is left depends on
what gave way, on which suit is on and on the hash.

So the stand stands the hero on the ground with a breakable wall at his elbow,
lets him punch it, and asks the cartridge and the engine for the same three
things picture by picture: the sixteen slots of the pool, his own four, and the
thirty two bytes of the broken mark.
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
import verify_sol_minds as M                                     # noqa: E402
import verify_sol_sat as T                                       # noqa: E402

SLOTS = S.SLOTS
HANDS, FIRST = T.HANDS, T.FIRST
MARK = 0x0540
MARKS = 32
LEN = 100

R, L, B, A = 0x01, 0x02, 0x40, 0x80


def hold(n, pad):
    return [pad] * n


# He has to be looking at the wall before he hits it, so every script but the
# first walks him into it first.
def scripts(way):
    return {
        'standing': hold(24, way) + hold(4, B) + hold(LEN, 0),
        'walking':  hold(24, way) + hold(4, way | B) + hold(LEN, way),
        'tapping':  (hold(4, way) + hold(2, way | B)) * 20,
    }

PLACES = [('s%d' % n, n) for n in range(20)]
SPOTS = 3                 # how many walls of a stage are stood at
SCRIPTED = {'s19'}        # stage twenty writes the pool from a script of its own


def free(props, m):
    """$90FA -- a place nothing is stopped by."""
    n = props[m] & 0x0F
    return n < 0x0C and (n & 0x03) == 0


def grid(stage):
    """The stage as cells: the props table and what metatile each cell holds."""
    path = os.path.join(ROOT, 'game', 'data', 'sol', 'levels',
                        'stage%d.json' % stage)
    s = json.load(open(path))
    props, rooms, screens, blocks = (s['props'], s['rooms'], s['screens'],
                                     s['blocks'])
    out = {}
    for ry in range(16):
        for rx in range(16):
            scr = rooms[ry][rx]
            if scr is None or scr >= len(screens):
                continue
            for br in range(8):
                for bc in range(8):
                    blk = blocks[screens[scr][br][bc]]
                    for hx in range(2):
                        for hy in range(2):
                            out[(rx * 16 + bc * 2 + hx,
                                 ry * 16 + br * 2 + hy)] = blk[hx * 2 + hy]
    return props, out


def walls(stage):
    """Every place he could stand and punch a wall that would give way.

    His reach lands one cell along and one cell up from the one he stands in
    ($B881's table), so the wall wanted is at his elbow, not at his feet.  He
    wants solid ground under him and two clear cells to stand in.
    """
    props, cells = grid(stage)
    out = []
    for (mx, my), m in sorted(cells.items()):
        v = props[m] & 0x1F
        if v >= 0x0C or (v & 0x03) < 0x02:
            continue
        for step, way in ((-1, R), (1, L)):
            sx, sy = mx + step, my + 1
            here = cells.get((sx, sy))
            over = cells.get((sx, sy - 1))
            under = cells.get((sx, sy + 1))
            if here is None or over is None or under is None:
                continue
            if not free(props, here) or not free(props, over):
                continue
            if free(props, under):
                continue
            out.append((sx, sy, mx, my, way))
        if len(out) >= SPOTS:
            break
    return out


def cartridge(state, pads, base):
    """The pool, his own four, and the broken mark, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.POOL) | set(S.POS) | set(S.TICKS)
    addrs |= {p + i for p in S.FIELDS for i in range(SLOTS)}
    addrs |= {MARK + i for i in range(MARKS)}
    for q in T.PAGES:
        if q is not None:
            addrs |= {q + FIRST + i for i in range(HANDS)}
    for q in (0xA0, 0xB0, 0xC0, 0xD0):
        addrs |= {q + FIRST + i for i in range(HANDS)}
    addrs |= {0x26, 0x7C}
    rows = P.watched(state, script, base, base + len(pads), addrs)
    out, hands, mark, ticks = [], [], [], []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04],
                      c[0x26]))
        out.append(tuple(
            (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
             c[0xC0 + i] | c[0xD0 + i] << 8,
             c[0x0650 + i], c[0x0690 + i], c[0x0660 + i], c[0x0670 + i])
            for i in range(SLOTS)))
        one = []
        for i in range(HANDS):
            s = FIRST + i
            row = []
            for k, p in enumerate(T.PAGES):
                if T.NAMES[k] == 'x':
                    row.append(c[0xA0 + s] | c[0xB0 + s] << 8)
                elif T.NAMES[k] == 'y':
                    row.append(c[0xC0 + s] | c[0xD0 + s] << 8)
                else:
                    row.append(c[p + s])
            one.append(tuple(row))
        hands.append(tuple(one))
        mark.append(tuple(c[MARK + i] for i in range(MARKS)))
    return out, hands, mark, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=900)
    rows, hands, mark = [], [], []
    for line in r.stdout.split('\n'):
        f = line.split()
        if f and f[0] == 'C' and len(f) == MARKS + 1:
            mark.append(tuple(int(v) for v in f[1:]))
            continue
        if f and f[0] == 'H' and len(f) == HANDS + 1:
            hands.append(tuple(tuple(int(v) for v in t.split(','))
                               for t in f[1:]))
            continue
        if len(f) != SLOTS or not all(t.count(',') == 6 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    if not rows:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return rows, hands, mark


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('punch')
    try:
        bad = total = known = hit = 0
        for label, stage in PLACES:
            if places and label not in places:
                continue
            spots = walls(stage)
            if not spots:
                print('%-6s no wall he could stand and punch' % label)
                sys.stdout.flush()
                continue
            for sx, sy, mx, my, way in spots:
                state = V.stand(scratch, label, stage, (sx, sy))
                first = V.BASE if stage == 0 else V.WARPED
                play = first + 1
                base = P.ram(state, [(first, '-')], first)
                cfg0 = S.seed(base)
                for name, pads in sorted(scripts(way).items()):
                    if only and name not in only:
                        continue
                    total += 1
                    want, whand, wmark, ticks = cartridge(state, pads, play)
                    broke = wmark[0] != wmark[-1]
                    if broke:
                        hit += 1
                    cfg = dict(cfg0)
                    cfg['pads'] = pads
                    cfg['crates'] = True
                    cfg['clock_at'] = [t[0] for t in ticks]
                    cfg['noise_at'] = [t[1] for t in ticks]
                    cfg['six_at'] = [t[2] for t in ticks]
                    cfg['step_at'] = [t[3] for t in ticks]
                    cfg['ride_at'] = [t[4] for t in ticks]
                    cfg['new_at'] = [t[5] for t in ticks]
                    owed = [t[6] for t in ticks]
                    cfg['owed_at'] = owed[:1] + owed[:-1]
                    got, ghand, gmark = engine(cfg, scratch)
                    n = min(len(want), len(got), len(gmark), len(ghand))
                    fin = S.finished(ticks, n)
                    where = kind = None
                    for i in range(n):
                        if not fin[i]:
                            continue
                        if wmark[i] != gmark[i]:
                            where, kind = i, 'mark'
                            break
                        if want[i] != got[i]:
                            where, kind = i, 'pool'
                            break
                        if whand[i] != ghand[i]:
                            where, kind = i, 'hand'
                            break
                    if where is None and len(want) != len(got):
                        where, kind = n, 'length'
                    tag = '%d,%d %s %d,%d' % (sx, sy,
                                             '->' if way == R else '<-', mx, my)
                    if where is None:
                        print('%-6s %-9s %-16s ok, %d frames%s'
                              % (label, name, tag, n,
                                 ', broken' if broke else ''))
                        sys.stdout.flush()
                        continue
                    if label in SCRIPTED:
                        known += 1
                        print('%-6s %-9s %-16s %s differs on frame %d'
                              ' -- the stage has a script of its own'
                              % (label, name, tag, kind, where))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    print('%-6s %-9s %-16s %s differs on frame %d'
                          % (label, name, tag, kind, where))
                    if kind == 'pool':
                        for s in range(SLOTS):
                            if want[where][s] == got[where][s]:
                                continue
                            for k, nm in enumerate(M.NAMES):
                                if want[where][s][k] != got[where][s][k]:
                                    print('    slot %2d %-6s cartridge %6d'
                                          '   engine %6d'
                                          % (s, nm, want[where][s][k],
                                             got[where][s][k]))
                    elif kind == 'hand':
                        T.show(whand, ghand, where)
                    elif kind == 'mark':
                        for i in range(MARKS):
                            if wmark[where][i] != gmark[where][i]:
                                print('    mark %2d cartridge $%02X engine $%02X'
                                      % (i, wmark[where][i], gmark[where][i]))
                    sys.stdout.flush()
        print('%d of %d scripts differ, %d broke a wall, %d more only where'
              ' stage twenty writes the pool itself' % (bad, total, hit, known))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
