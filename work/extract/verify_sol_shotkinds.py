#!/usr/bin/env python3
"""Э4.3 acceptance: every behaviour of the two shot tables, one at a time.

`verify_sol_shots.py` watches the sixteen shot slots while the hero walks, so
it meets only what a stage happens to throw -- and most of the forty eight
numbers in $B317 and $B386 are never thrown at all in the first few seconds of
any stage.  So this stand asks for them by name.

A free shot slot is written by hand on a settled picture: the behaviour number
(bit seven up for the flying table, down for the burning-out one), the hero's
own place, both of the slot's two bytes cleared and a life of eight.  The
cartridge and the engine are then run over the same pictures and must answer
the same numbers for all sixteen shot slots -- and for all sixteen object
slots too, because a shot may let something out of itself.
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
import verify_sol_shots as H                                     # noqa: E402

SLOTS = S.SLOTS
SHOTS = S.SHOTS
LEN = 90                  # long enough for anything thrown to burn out
AT = 40                   # a settled picture, well past the door
SLOT = 0x0F               # $B2E9 walks from fifteen down, so this one is first

# Stage twenty writes both pools by hand out of a script in bank 8 that is not
# ported yet, so it is counted apart.
SCRIPTED = {'s19'}


def cartridge(state, pads, base, pokes):
    """Both pools, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.POOL) | set(S.POS) | set(S.TICKS)
    addrs |= {p + i for p in S.FIELDS for i in range(SLOTS)}
    for p in H.PAGES:
        addrs |= {p + i for i in range(SHOTS)}
    addrs.add(0x26)
    rows = P.watched(state, script, base, base + len(pads), addrs, pokes=pokes)
    pool, shot, ticks = [], [], []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04],
                      c[0x26]))
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


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=900)
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
    if not pool:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return pool, shot


def main():
    only = [int(a, 0) for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    tables = [0x80, 0x00]
    if '--live' in sys.argv:
        tables = [0x80]
    if '--dead' in sys.argv:
        tables = [0x00]
    labels = places or ['s%d' % n for n in range(20) if n != 19]
    pads = S.hold(LEN, 0x01)
    scratch = P.scratch('shotkinds')
    try:
        bad = total = known = 0
        for label in labels:
            stage = int(label[1:])
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            cfg0 = S.seed(P.ram(state, [(first, '-')], first))
            was = P.ram(state, V.cartridge_script(pads, play), play + AT)
            hx = was[0x80] | was[0x81] << 8
            hy = was[0x82] | was[0x83] << 8
            print('%-6s slot %d at %d,%d from frame %d'
                  % (label, SLOT, hx, hy, AT))
            sys.stdout.flush()
            for top in tables:
                for m in range(0x30):
                    if only and m not in only:
                        continue
                    total += 1
                    put = [(0x0780 + SLOT, top | m),
                           (0x0790 + SLOT, hx & 0xFF),
                           (0x07A0 + SLOT, (hx >> 8) & 0xFF),
                           (0x07B0 + SLOT, hy & 0xFF),
                           (0x07C0 + SLOT, (hy >> 8) & 0xFF),
                           (0x07D0 + SLOT, 0x00), (0x07E0 + SLOT, 0x00),
                           (0x07F0 + SLOT, 0x08)]
                    pk = [(a, v, play + AT) for a, v in put]
                    wp, ws, tk = cartridge(state, pads, play, pk)
                    cfg = dict(cfg0)
                    cfg['pads'] = pads
                    cfg['kill_at'] = AT
                    cfg['put'] = [[a, v] for a, v in put]
                    cfg['crates'] = True
                    cfg['clock_at'] = [t[0] for t in tk]
                    cfg['noise_at'] = [t[1] for t in tk]
                    cfg['six_at'] = [t[2] for t in tk]
                    cfg['step_at'] = [t[3] for t in tk]
                    cfg['ride_at'] = [t[4] for t in tk]
                    cfg['new_at'] = [t[5] for t in tk]
                    owed = [t[6] for t in tk]
                    cfg['owed_at'] = owed[:1] + owed[:-1]
                    gp, gs = engine(cfg, scratch)
                    n = min(len(wp), len(ws), len(gp), len(gs))
                    # Once the slot has burnt out the behaviour is over; the
                    # picture it goes on is still compared.
                    for i in range(AT, n):
                        if ws[i][SLOT][0] == 0:
                            n = i + 1
                            break
                    fin = S.finished(tk, n)
                    where = kind = None
                    for i in range(n):
                        if not fin[i]:
                            continue
                        if ws[i] != gs[i]:
                            where, kind = i, 'shots'
                            break
                        if wp[i] != gp[i]:
                            where, kind = i, 'pool'
                            break
                    name = '%s $%02X' % ('live' if top else 'dead', m)
                    if where is None:
                        print('%-6s %-10s ok, %d frames' % (label, name, n))
                        sys.stdout.flush()
                        continue
                    if label in SCRIPTED:
                        known += 1
                        print('%-6s %-10s %s differs on frame %d'
                              ' -- the stage has a script of its own'
                              % (label, name, kind, where))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    print('%-6s %-10s %s differs on frame %d'
                          % (label, name, kind, where))
                    rows = (ws, gs, H.NAMES, SHOTS) if kind == 'shots' \
                        else (wp, gp, M.NAMES, SLOTS)
                    w, g, names, count = rows
                    for j in range(count):
                        if w[where][j] == g[where][j]:
                            continue
                        for k, nm in enumerate(names):
                            if w[where][j][k] != g[where][j][k]:
                                print('    slot %2d %-6s cartridge %6d'
                                      '   engine %6d'
                                      % (j, nm, w[where][j][k], g[where][j][k]))
                    sys.stdout.flush()
            if not places:
                break
        print('%d of %d shot behaviours differ, %d more only where stage'
              ' twenty writes the pool itself' % (bad, total, known))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    sys.exit(main())
