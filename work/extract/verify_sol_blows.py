#!/usr/bin/env python3
"""Э4.18 acceptance: the hero's own eight weapon slots laid over a thing.

`$CFE8` asks bank eight's `$869C` once the thing's box is built, and it lays
the pool at `$0700` -- what the satellite throws, the swung weapon, his own
punch -- over that box.  Which of the eight slots are asked, and in what
order, is the satellite's own behaviour read through `$8759`.

The stand walks into a stage, lets it put a thing of its own into a slot, and
then puts one weapon into the pool by hand at a chosen distance from that
thing's box.  The distances are not guessed: the box is worked out from
`hits.json` the way `$814C` and `$817B` work it out, and the weapon is put one
sixteenth either side of each of its four edges.  That is what settles the
carry `$876D` subtracts its first pair with, because nothing between `$CF96`
and `$CFE8` sets it and so it walks in from whatever `$81B7` last left.

Compared, picture by picture: all eighteen numbers of all sixteen slots, and
all six of each of the eight weapon slots the pool walk reaches.
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
import verify_sol_sat as T                                       # noqa: E402
import verify_sol_weapon as W                                    # noqa: E402

SLOTS = S.SLOTS
NAMES = T.NAMES
PAGES = T.PAGES
WALKED = W.WALKED

LEN = 24
SCRIPTS = {'still': [0] * LEN, 'long': [0] * (LEN * 3)}

# Five stages that put a thing the hero's weapons can hurt within reach:
# one standing on the ground, one above him, one that walks.
PLACES = [('s0', 0), ('s1', 1), ('s2', 2), ('s4', 4), ('s9', 9)]

# The weapon is given the slash's behaviour ($B225).  It is the only one of
# the twenty two that neither asks the map where it is -- the others burst the
# moment they are put down inside the ground, and a thing standing on the
# ground has its box in the ground -- nor carries itself off somewhere.  Its
# own step is $FF00 plus its first byte, which is always upwards, so with $FF
# in that byte it climbs one sixteenth of a pixel a picture: slow enough to
# stand still for the purpose, and a free walk over the top edge of the box
# into the bargain.  Its second byte is how many cells of the row it draws,
# and one is enough.
KIND = 0x12

# Which row of $8759 the satellite's behaviour picks: nought asks all eight
# slots, five asks half of them, two asks the seventh set that leaves slot
# nought out.
INDEXES = (0, 5, 2)

HITS = json.load(open(os.path.join(ROOT, 'game', 'data', 'sol', 'hits.json')))


def add2(p, q, c):
    """Two bytes added, and the carry the add leaves."""
    lo = (p & 0xFF) + (q & 0xFF) + c
    hi = ((p >> 8) & 0xFF) + ((q >> 8) & 0xFF) + ((lo >> 8) & 1)
    return ((hi & 0xFF) << 8) | (lo & 0xFF), (hi >> 8) & 1


def box_of(row):
    """$814C and $817B -- the thing's box where the thing itself stands."""
    pic = row[16] | row[17] << 8
    if (row[9] & 0x80) != 0:
        pic += 1
    if pic >= len(HITS['pic']):
        return None
    flags, which = HITS['pic'][pic]
    if flags == 0:
        return None
    dx, dy, w, h = HITS['box'][which]
    x, c = add2(dx, row[1], 0)
    y, _c = add2(dy, row[2], c)
    return flags, x, y, w, h


def cartridge(state, script, first, last, pk):
    """The whole pool and the whole $0700 page, picture by picture."""
    addrs = set(S.TICKS)
    for p in PAGES:
        if p is not None:
            addrs |= {p + i for i in range(SLOTS)}
    for p in (0xA0, 0xB0, 0xC0, 0xD0):
        addrs |= {p + i for i in range(SLOTS)}
    for p in W.PAGES:
        addrs |= {p + i for i in range(WALKED)}
    rows = P.watched(state, script, first, last, addrs, pokes=pk)
    pool = []
    arms = []
    ticks = []
    frames = []
    for fr, c in rows[:-1]:
        frames.append(fr)
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04]))
        one = []
        for s in range(SLOTS):
            row = []
            for k, p in enumerate(PAGES):
                if NAMES[k] == 'x':
                    row.append(c[0xA0 + s] | c[0xB0 + s] << 8)
                elif NAMES[k] == 'y':
                    row.append(c[0xC0 + s] | c[0xD0 + s] << 8)
                else:
                    row.append(c[p + s])
            one.append(tuple(row))
        pool.append(tuple(one))
        arms.append(tuple(
            (c[0x0700 + i],
             c[0x0710 + i] | c[0x0720 + i] << 8,
             c[0x0730 + i] | c[0x0740 + i] << 8,
             c[0x0750 + i], c[0x0760 + i], c[0x0770 + i])
            for i in range(WALKED)))
    return pool, arms, ticks, frames


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=900)
    pool = []
    arms = []
    for line in r.stdout.split('\n'):
        if line.startswith('O '):
            f = line[2:].split()
            if len(f) == SLOTS and all(t.count(',') == 17 for t in f):
                pool.append(tuple(tuple(int(v) for v in t.split(','))
                                  for t in f))
        elif line.startswith('W '):
            f = line[2:].split()
            if len(f) == WALKED and all(t.count(',') == 5 for t in f):
                arms.append(tuple(tuple(int(v) for v in t.split(','))
                                  for t in f))
    if not pool:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return pool, arms


def show(want, got, where):
    for s in range(SLOTS):
        if want[where][s] == got[where][s]:
            continue
        for k, nm in enumerate(NAMES):
            if want[where][s][k] != got[where][s][k]:
                print('    slot %02X %-7s cartridge %6d   engine %6d'
                      % (s, nm, want[where][s][k], got[where][s][k]))


def show_arms(want, got, where):
    for s in range(WALKED):
        if want[where][s] == got[where][s]:
            continue
        for k, nm in enumerate(W.NAMES):
            if want[where][s][k] != got[where][s][k]:
                print('    weapon %d %-5s cartridge %6d   engine %6d'
                      % (s, nm, want[where][s][k], got[where][s][k]))


def arm_at(slot, x, y, pen):
    """One weapon of the hero's own pool, put beside the thing by hand."""
    return {
        0x0700 + slot: 0x80 | KIND,
        0x0710 + slot: x & 0xFF,
        0x0720 + slot: (x >> 8) & 0xFF,
        0x0730 + slot: y & 0xFF,
        0x0740 + slot: (y >> 8) & 0xFF,
        0x0750 + slot: 0xFF,
        0x0760 + slot: 0x01,
        0x0770 + slot: pen,
    }


KEYS = {0x0600: 'id', 0x0650: 'omind', 0x0690: 'okind', 0x0610: 'oa',
        0x0620: 'ob', 0x0630: 'oc', 0x0640: 'od', 0x0660: 'opic_lo',
        0x0670: 'opic_hi', 0x06A0: 'oanim_a', 0x06B0: 'oanim_b',
        0x06C0: 'oleft', 0x06D0: 'oframe', 0x06E0: 'ocool', 0x06F0: 'olife',
        0x0700: 'wkind', 0x0750: 'wvx', 0x0760: 'wvy', 0x0770: 'wpen'}


def into_cfg(cfg, made):
    """The same bytes, in the words the engine's seed is written in."""
    for a, v in sorted(made.items()):
        page = a & 0xFFF0
        i = a & 0x0F
        if page in (0x0710, 0x0720):
            cfg['wx'] = list(cfg['wx'])
            old = cfg['wx'][i]
            cfg['wx'][i] = ((old & 0xFF00) | v if page == 0x0710
                            else (old & 0x00FF) | v << 8)
            continue
        if page in (0x0730, 0x0740):
            cfg['wy'] = list(cfg['wy'])
            old = cfg['wy'][i]
            cfg['wy'][i] = ((old & 0xFF00) | v if page == 0x0730
                            else (old & 0x00FF) | v << 8)
            continue
        key = KEYS[page]
        cfg[key] = list(cfg[key])
        cfg[key][i] = v
    return cfg


def target(pool, i):
    """A thing the hero's weapons can actually hurt, at picture `i`.

    It must be in one of the twelve slots the stage fills, have been there a
    few pictures already so that its place is its own, be alive, and carry a
    box whose meaning is neither a pick-up ($60 bit seven) nor one of the two
    $869C turns round on.
    """
    for s in range(12):
        row = pool[i][s]
        if row[0] == 0 or (row[3] & 0x80) != 0 or row[15] == 0:
            continue
        if any(pool[i - k][s][0] != row[0] for k in (1, 2, 3)):
            continue
        got = box_of(row)
        if got is None:
            continue
        flags = got[0]
        if (flags & 0x80) != 0 or (flags & 0x3F) == 0 or (flags & 0x20) != 0:
            continue
        return s, got
    return None, None


def plan(got):
    """Where to put the weapon, and with what.

    Each of the four edges of the box is walked over a sixteenth at a time,
    because that is the whole of what the entry carry is worth.  The middle is
    then used again for the other two rows of $8759, for the slot the seventh
    set leaves out, and for the three amounts a weapon can go through.
    """
    _flags, x, y, w, h = got
    mx = (x + w // 2) & 0xFFFF
    my = (y + h // 2) & 0xFFFF
    spots = [('middle', mx, my)]
    for nm, ex in (('near x', x), ('far x', (x + w) & 0xFFFF)):
        for d in (-1, 0, 1):
            spots.append(('%s%+d' % (nm, d), (ex + d) & 0xFFFF, my))
    for nm, ey in (('near y', y), ('far y', (y + h) & 0xFFFF)):
        for d in (-1, 0, 1):
            spots.append(('%s%+d' % (nm, d), mx, (ey + d) & 0xFFFF))
    spots.append(('away', (x - 0x400) & 0xFFFF, my))
    out = []
    for nm, px, py in spots:
        out.append((nm, px, py, 0, 3, 0x7F, 'still'))
    for nm, px, py in spots[:9]:
        for index in INDEXES[1:]:
            out.append((nm, px, py, index, 3, 0x7F, 'still'))
    for slot in (0, 7):
        for index in (0, 2):
            out.append(('middle', mx, my, index, slot, 0x7F, 'still'))
    for pen in (1, 2, 4):
        out.append(('middle', mx, my, 0, 3, pen, 'still'))
    out.append(('middle', mx, my, 0, 3, 0x7F, 'long'))
    return out


SCAN = 150                # how far to look for a thing worth shooting at
WALKS = (('right', 0x01), ('left', 0x02))


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('blows')
    try:
        bad = total = 0
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            state = V.stand(scratch, label, stage, None)
            # Nothing is in the pool where the hero is set down: the stage lets
            # a thing in only once the view has carried far enough.  So he is
            # walked until one turns up, and the picture it has settled on is
            # where both the cartridge and the engine are started from.
            found = None
            for wname, bit in WALKS:
                walk = [bit] * SCAN
                script = V.cartridge_script(walk, first)
                ctl, _a, _t, frames = cartridge(
                    state, script, first + 1, first + SCAN, [])
                for i in range(4, len(ctl) - 4):
                    s, got = target(ctl, i)
                    if s is not None:
                        found = (wname, walk, i, s, got, frames[i])
                        break
                if found is not None:
                    break
            if found is None:
                print('%-3s nothing in the pool worth shooting at' % label)
                continue
            wname, walk, i, s, got, play = found
            run_up = walk[:play - first]
            base = P.ram(state, V.cartridge_script(run_up, first), play - 1)
            cfg0 = S.seed(base)
            face = (base[0x05B2] & 0x80) != 0
            # The box has to be the one the thing wears on the very picture the
            # weapon is put down on, and giving the hero a satellite moves him
            # about, so it is read again from a run that has one.
            pads = SCRIPTS['still']
            born = T.born(1, 0, face)
            ctl, _a, _t, _f = cartridge(
                state, V.cartridge_script(run_up + pads, first),
                play, play + len(pads),
                [(a, v, play) for a, v in sorted(born.items())])
            got = box_of(ctl[0][s])
            if got is None:
                print('%-3s the thing wears no box once he has a satellite'
                      % label)
                continue
            print('%-3s %s: thing in slot %d at picture %d, box %d,%d %d by %d'
                  % (label, wname, s, i, got[1], got[2], got[3], got[4]))
            sys.stdout.flush()
            for nm, px, py, index, slot, pen, sname in plan(got):
                if only and nm not in only:
                    continue
                total += 1
                made = dict(T.born(1, index, face))
                made.update(arm_at(slot, px, py, pen))
                pads = SCRIPTS[sname]
                script = V.cartridge_script(run_up + pads, first)
                pk = [(a, v, play) for a, v in sorted(made.items())]
                want, warm, ticks, _f = cartridge(
                    state, script, play, play + len(pads), pk)
                cfg = into_cfg(dict(cfg0), made)
                cfg['pads'] = pads
                cfg['clock_at'] = [t[0] for t in ticks]
                cfg['noise_at'] = [t[1] for t in ticks]
                cfg['six_at'] = [t[2] for t in ticks]
                cfg['step_at'] = [t[3] for t in ticks]
                cfg['ride_at'] = [t[4] for t in ticks]
                cfg['new_at'] = [t[5] for t in ticks]
                gpool, garm = engine(cfg, scratch)
                n = min(len(want), len(gpool), len(warm), len(garm))
                done = S.finished(ticks, n)
                where = None
                kindof = ''
                for k in range(n):
                    if not done[k]:
                        continue
                    if want[k] != gpool[k]:
                        where, kindof = k, 'slot'
                        break
                    if warm[k] != garm[k]:
                        where, kindof = k, 'weapon'
                        break
                tag = ('%-10s index %d slot %d pen %02X / %s'
                       % (nm, index, slot, pen, sname))
                if where is None:
                    print('%-3s %-46s ok, %d pictures' % (label, tag, n))
                    sys.stdout.flush()
                    continue
                bad += 1
                print('%-3s %-46s differs on picture %d' % (label, tag, where))
                if kindof == 'slot':
                    show(want, gpool, where)
                else:
                    show_arms(warm, garm, where)
                sys.stdout.flush()
        print('%d of %d weapons against things differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
