#!/usr/bin/env python3
"""Э4.4 acceptance: what breaking the stage does.

Some of the things in the pool do not only die -- they take the stage with
them.  $BE0F reads the cell a place falls in, and if what is written there is
something that stops anything at all, it marks the metatile broken in the
thirty two bytes at $0540 and redraws it.  The mark is kept by metatile
number, not by place, which is why a crate is given four numbers of its own
and why breaking one breaks every cell in the stage that names it.

So this stand puts a thing of that family down on a crate and lets it go off.
It takes a live slot out of a played run, writes the behaviour it wants onto
it with bit 7 on, moves it to the crate, and then asks the cartridge and the
engine for the same two things picture by picture: the sixteen slots, and the
thirty two bytes of the broken mark.

Nothing here is judged by eye: a run either matches on both, or the first
picture that parts company is printed.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import sol_probe as P                                            # noqa: E402
import verify_sol_player as V                                    # noqa: E402
import verify_sol_spawns as S                                    # noqa: E402
import verify_sol_minds as M                                     # noqa: E402
import subprocess                                                # noqa: E402

SLOTS = S.SLOTS
MARK = 0x0540             # the broken mark, one bit a metatile
MARKS = 32
LEN = 90                  # long enough for the longest burst to run out

R, L = 0x01, 0x02

SCRIPTS = {
    'still': S.hold(LEN, 0),
    'right': S.hold(LEN, R),
}

# The behaviours that break the stage, by the number they wear in $0650 with
# bit 7 already on.  $16 and $17 are the two borers, which need the three
# counters below them as well.
BURSTS = [
    ('burst three', 0x00),          # $A883
    ('burst two', 0x02),            # $A8ED
    ('burst one', 0x13),            # $A904
    ('burst four', 0x36),           # $A8B8
    ('burst and leave', 0x37),      # $A8D3
    ('bore up', 0x17),              # $A836
    ('bore down', 0x16),            # $A7F0
]

if os.environ.get('CRATE_MIND'):
    BURSTS = [('probe', int(os.environ['CRATE_MIND'], 0))]

PLACES = [('s%d' % n, n) for n in range(20)]

# Stage twenty keeps a script of its own in bank 8 ($9E63, $9E73, $9E90) which
# writes the pool by hand all through its opening, and that script is not
# ported.  Anything poked into a slot there is argued over by the script rather
# than by the behaviour under test, so the stage is counted apart until Э4.5
# brings the script in.
SCRIPTED = {'s19'}
TAIL = 40


def crates(stage):
    """Every cell of a stage whose metatile can be broken, by (mx, my)."""
    path = os.path.join(ROOT, 'game', 'data', 'sol', 'levels',
                        'stage%d.json' % stage)
    s = json.load(open(path))
    props, rooms, screens, blocks = s['props'], s['rooms'], s['screens'], s['blocks']
    out = []
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
                            m = blk[hx * 2 + hy]
                            if not (props[m] & 0x20):
                                continue
                            out.append((rx * 16 + bc * 2 + hx,
                                        ry * 16 + br * 2 + hy))
    return out


def nearest(cells, cam_x, cam_y):
    """The crate cell closest to the middle of the view, in cells."""
    cx = ((cam_x >> 8) + 8) & 0xFF
    cy = ((cam_y >> 8) + 7) & 0xFF
    best = None
    for mx, my in cells:
        d = abs(mx - cx) + abs(my - cy)
        if best is None or d < best[0]:
            best = (d, mx, my)
    return best


def cartridge(state, pads, base, pokes):
    """The pool and the broken mark, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.POOL) | set(S.POS) | set(S.TICKS)
    addrs |= {p + i for p in S.FIELDS for i in range(SLOTS)}
    addrs |= {MARK + i for i in range(MARKS)}
    addrs.add(0x26)
    rows = P.watched(state, script, base, base + len(pads), addrs, pokes=pokes)
    out, mark, ticks = [], [], []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04],
                      c[0x26]))
        out.append(tuple(
            (c[0x0600 + i], c[0xA0 + i] | c[0xB0 + i] << 8,
             c[0xC0 + i] | c[0xD0 + i] << 8,
             c[0x0650 + i], c[0x0690 + i], c[0x0660 + i], c[0x0670 + i])
            for i in range(SLOTS)))
        mark.append(tuple(c[MARK + i] for i in range(MARKS)))
    return out, mark, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=900)
    rows, mark = [], []
    for line in r.stdout.split('\n'):
        f = line.split()
        if f and f[0] == 'C' and len(f) == MARKS + 1:
            mark.append(tuple(int(v) for v in f[1:]))
            continue
        if len(f) != SLOTS or not all(t.count(',') == 6 for t in f):
            continue
        rows.append(tuple(tuple(int(v) for v in t.split(',')) for t in f))
    if not rows:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return rows, mark


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('crates')
    try:
        bad = total = known = 0
        for label, stage in PLACES:
            if places and label not in places:
                continue
            cells = crates(stage)
            if not cells:
                print('%-6s no crates in the stage' % label)
                sys.stdout.flush()
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            for name, pads in sorted(SCRIPTS.items()):
                rows, ticks = S.cartridge(state, pads, play, full=True)
                done = S.finished(ticks, len(rows))
                # A picture the cartridge finished, that has something in the
                # pool, and that leaves room for the burst to run out.
                pick = None
                for k in range(1, max(1, len(rows) - TAIL)):
                    if not done[k - 1]:
                        continue
                    held = [s for s in range(SLOTS) if rows[k - 1][s][0] != 0]
                    if held:
                        pick = (k, held[0])
                        break
                if pick is None:
                    print('%-6s %-16s nothing in the pool' % (label, name))
                    sys.stdout.flush()
                    continue
                at, slot = pick
                base = P.ram(state, V.cartridge_script(pads, play), play + at)
                near = nearest(cells, base[0x30] | base[0x31] << 8,
                               base[0x32] | base[0x33] << 8)
                mx, my = near[1], near[2]
                for bname, mind in BURSTS:
                    if only and bname not in only:
                        continue
                    total += 1
                    # The whole slot is written, not only its behaviour: where
                    # it stands, which list it is on, and the two counters the
                    # borers keep.
                    put = [(0x0650 + slot, 0x80 | mind),
                           (0x00A0 + slot, 0x00), (0x00B0 + slot, mx),
                           (0x00C0 + slot, 0x00), (0x00D0 + slot, my),
                           (0x0610 + slot, 0x00), (0x0620 + slot, my),
                           (0x0630 + slot, 0x00), (0x0640 + slot, 0x04),
                           (0x06C0 + slot, 0x00), (0x06D0 + slot, 0x00),
                           (0x06E0 + slot, 0x00)]
                    pk = [(a, v, play + at) for a, v in put]
                    want, wmark, ticks = cartridge(state, pads, play, pk)
                    cfg = dict(cfg0)
                    cfg['pads'] = pads
                    cfg['kill_at'] = at
                    cfg['put'] = [[a, v] for a, v in put]
                    cfg['crates'] = True
                    cfg['clock_at'] = [t[0] for t in ticks]
                    cfg['noise_at'] = [t[1] for t in ticks]
                    cfg['six_at'] = [t[2] for t in ticks]
                    cfg['step_at'] = [t[3] for t in ticks]
                    cfg['ride_at'] = [t[4] for t in ticks]
                    cfg['new_at'] = [t[5] for t in ticks]
                    # $26 is read where the frame ends, but the blanking that
                    # pays it off comes first -- so what a picture sees is what
                    # the one before it was left holding.
                    owed = [t[6] for t in ticks]
                    cfg['owed_at'] = owed[:1] + owed[:-1]
                    got, gmark = engine(cfg, scratch)
                    n = min(len(want), len(got), len(gmark))
                    # Once the slot is empty the behaviour under test is over,
                    # and what the pool does after belongs to somebody else --
                    # on stage nineteen a script in bank 9 watches this very
                    # pair of slots and moves on the moment one of them goes.
                    # The frame it goes on is still compared, so that what a
                    # behaviour leaves behind is compared with it.
                    for i in range(n):
                        if want[i][slot][0] == 0:
                            n = i + 1
                            break
                    fin = S.finished(ticks, n)
                    where = kind = None
                    for i in range(n):
                        if not fin[i]:
                            continue
                        if want[i] != got[i]:
                            where, kind = i, 'pool'
                            break
                        if wmark[i] != gmark[i]:
                            where, kind = i, 'mark'
                            break
                    if where is None and len(want) != len(got):
                        where, kind = n, 'length'
                    if where is None:
                        print('%-6s %-6s %-16s ok, %d frames, slot %d at %d,%d'
                              % (label, name, bname, n, slot, mx, my))
                        sys.stdout.flush()
                        continue
                    if label in SCRIPTED:
                        known += 1
                        print('%-6s %-6s %-16s %s differs on frame %d'
                              ' -- the stage has a script of its own'
                              % (label, name, bname, kind, where))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    if os.environ.get('CRATE_DUMP'):
                        for i in range(max(0, where - 2), min(n, where + 2)):
                            print('  f%d fin=%s' % (i, fin[i]))
                            for s in range(SLOTS):
                                if want[i][s] == got[i][s] and want[i][s][0] == 0:
                                    continue
                                print('    %2d want %s got %s'
                                      % (s, want[i][s], got[i][s]))
                    print('%-6s %-6s %-16s %s differs on frame %d'
                          % (label, name, bname, kind, where))
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
                    elif kind == 'mark':
                        for i in range(MARKS):
                            if wmark[where][i] != gmark[where][i]:
                                print('    mark %2d cartridge $%02X engine $%02X'
                                      % (i, wmark[where][i], gmark[where][i]))
                    sys.stdout.flush()
        print('%d of %d scripts differ, %d more only where stage twenty'
              ' writes the pool itself' % (bad, total, known))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
