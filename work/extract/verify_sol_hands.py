#!/usr/bin/env python3
"""Э4.17 acceptance: the shots laid over the hero's own four slots.

`$A51E` asks bank eight's `$88F6` for each of the four slots `$0C`..`$0F` once
a picture, and it lays the sixteen shots of the `$0780` pool over the slot the
way `$8866` lays them over the hero.  The box is built by hand: a square
`$0101` across -- sixteen pixels and a sixteenth -- reaching from `$80` back
of the slot's own point.  That is how the satellite is shot out of the air.

The stand puts a satellite there the way `verify_sol_sat.py` does, and then
puts one shot of its own into the pool at a chosen distance from the hero.
The distances walk across the edge of the box on purpose -- `$7F`, `$80`,
`$81`, `$100`, `$101`, `$102` in sixteenths, each way -- because the carry
standing when `$88F6` subtracts its `$80` decides whether the box reaches one
sixteenth further back, and only the cartridge can settle that.

Compared, picture by picture: all eighteen numbers of each of the four slots,
and all six of each of the sixteen shots.
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
import verify_sol_shots as H                                     # noqa: E402

HANDS = T.HANDS
FIRST = T.FIRST
SHOTS = H.SHOTS

LEN = 30
R, B = 0x01, 0x40
SCRIPTS = {
    'still':  [0] * LEN,
    'firing': [0] * 4 + [B] * 6 + [0] * LEN,
    'walking': [R] * LEN,
    'long':   [0] * (LEN * 3),
}

# Which way from the hero the shot is put, in sixteenths of a pixel.  The box
# reaches from -$80 to +$80 of the slot's own point, so these walk over both
# of its edges, and the two furthest are well outside it.
STEPS = (0, 0x40, 0x7F, 0x80, 0x81, 0x100, 0x101, 0x102, 0x200)
OFFSETS = [(0, 0)]
for _d in STEPS[1:]:
    OFFSETS += [(_d, 0), (-_d, 0), (0, _d), (0, -_d)]

# Which behaviour the shot wears.  The first three of $895C are noughts, so a
# shot wearing one of them is asked about every picture; anything above that
# is asked about every other one, and which one depends on the shot's slot.
KINDS = (0x01, 0x03)
WHERE = (0, 1)                # and which slot of the pool it is put in

PLACES = [('s0', 0), ('s1', 1), ('s5', 5)]


def plan():
    """The cases.

    The whole walk of distances is done twice: once with a behaviour the table
    at $895C answers nought for, which is asked about every picture, and once
    with one it answers something for, which is asked about every other
    picture -- and which picture that is depends on the shot's own slot, so
    the second walk uses the other slot as well.  The second walk is the one
    that settles the carry question: the roll that asks about the picture is
    itself what leaves the carry the compares below then subtract with.

    The two moving scripts are run at the middle only, and a last case gives
    the shot enough life to take the satellite apart -- sixteen points of it,
    one a picture -- so the end of a slot is walked through as well.
    """
    out = []
    for dx, dy in OFFSETS:
        out.append((0x01, 0, dx, dy, 'still', 2))
        out.append((0x03, 1, dx, dy, 'still', 2))
    for sname in ('firing', 'walking'):
        for dx in (0, 0x80, -0x81):
            out.append((0x01, 0, dx, 0, sname, 2))
    out.append((0x01, 0, 0, 0, 'long', 0x40))
    out.append((0x03, 1, 0, 0, 'long', 0x40))
    return out


def cartridge(state, pads, base, pk):
    """The four slots and the whole $0780 page, picture by picture."""
    script = V.cartridge_script(pads, base)
    addrs = set(S.TICKS)
    for p in T.PAGES:
        if p is not None:
            addrs |= {p + FIRST + i for i in range(HANDS)}
    for p in (0xA0, 0xB0, 0xC0, 0xD0):
        addrs |= {p + FIRST + i for i in range(HANDS)}
    for p in H.PAGES:
        addrs |= {p + i for i in range(SHOTS)}
    rows = P.watched(state, script, base, base + len(pads), addrs, pokes=pk)
    hands = []
    arms = []
    ticks = []
    for _fr, c in rows[:-1]:
        ticks.append((c[0x0C], c[0x0E], c[0x06], c[0x7F], c[0x58], c[0x04]))
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
        arms.append(tuple(
            (c[0x0780 + i],
             c[0x0790 + i] | c[0x07A0 + i] << 8,
             c[0x07B0 + i] | c[0x07C0 + i] << 8,
             c[0x07D0 + i], c[0x07E0 + i], c[0x07F0 + i])
            for i in range(SHOTS)))
    return hands, arms, ticks


def engine(cfg, scratch):
    path = os.path.join(scratch, 'obj.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([S.GODOT, '--path', S.GAME, '--headless', '--',
                        '--solobj=%s' % path],
                       capture_output=True, text=True, timeout=600)
    hands = []
    arms = []
    for line in r.stdout.split('\n'):
        if line.startswith('H '):
            f = line[2:].split()
            if len(f) == HANDS and all(t.count(',') == 17 for t in f):
                hands.append(tuple(tuple(int(v) for v in t.split(','))
                                   for t in f))
        elif line.startswith('S '):
            f = line[2:].split()
            if len(f) == SHOTS and all(t.count(',') == 5 for t in f):
                arms.append(tuple(tuple(int(v) for v in t.split(','))
                                  for t in f))
    if not hands:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return hands, arms


def show(want, got, where):
    for s in range(HANDS):
        if want[where][s] == got[where][s]:
            continue
        for k, nm in enumerate(T.NAMES):
            if want[where][s][k] != got[where][s][k]:
                print('    slot %02X %-7s cartridge %6d   engine %6d'
                      % (FIRST + s, nm, want[where][s][k], got[where][s][k]))


def show_arms(want, got, where):
    for s in range(SHOTS):
        if want[where][s] == got[where][s]:
            continue
        for k, nm in enumerate(H.NAMES):
            if want[where][s][k] != got[where][s][k]:
                print('    shot %2d %-5s cartridge %6d   engine %6d'
                      % (s, nm, want[where][s][k], got[where][s][k]))


def shot_at(centre, slot, kind, dx, dy, life=2):
    """One shot of the pool, put beside the satellite by hand."""
    x = (centre[0] + dx) & 0xFFFF
    y = (centre[1] + dy) & 0xFFFF
    return {
        0x0780 + slot: 0x80 | kind,
        0x0790 + slot: x & 0xFF,
        0x07A0 + slot: (x >> 8) & 0xFF,
        0x07B0 + slot: y & 0xFF,
        0x07C0 + slot: (y >> 8) & 0xFF,
        0x07D0 + slot: 0,
        0x07E0 + slot: 0,
        0x07F0 + slot: life,
    }


KEYS = {0x0600: 'id', 0x0650: 'omind', 0x0690: 'okind', 0x0610: 'oa',
        0x0620: 'ob', 0x0630: 'oc', 0x0640: 'od', 0x0660: 'opic_lo',
        0x0670: 'opic_hi', 0x06A0: 'oanim_a', 0x06B0: 'oanim_b',
        0x06C0: 'oleft', 0x06D0: 'oframe', 0x06E0: 'ocool', 0x06F0: 'olife',
        0x0700: 'wkind', 0x0780: 'skind', 0x07D0: 'sa', 0x07E0: 'sb',
        0x07F0: 'slife'}


def into_cfg(cfg, made):
    """The same bytes, in the words the engine's seed is written in."""
    for a, v in sorted(made.items()):
        page = a & 0xFFF0
        i = a & 0x0F
        if page in (0x0790, 0x07A0):
            cfg['sx'] = list(cfg['sx'])
            old = cfg['sx'][i]
            cfg['sx'][i] = ((old & 0xFF00) | v if page == 0x0790
                            else (old & 0x00FF) | v << 8)
            continue
        if page in (0x07B0, 0x07C0):
            cfg['sy'] = list(cfg['sy'])
            old = cfg['sy'][i]
            cfg['sy'][i] = ((old & 0xFF00) | v if page == 0x07B0
                            else (old & 0x00FF) | v << 8)
            continue
        if a == 0x05C4:
            cfg['letters'] = v
            continue
        key = KEYS[page]
        cfg[key] = list(cfg[key])
        cfg[key][i] = v
    return cfg


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    scratch = P.scratch('hands')
    try:
        bad = total = 0
        for label, stage in PLACES:
            if places and label not in places:
                continue
            first = V.BASE if stage == 0 else P.WARP_IN
            play = first + 1
            state = V.stand(scratch, label, stage, None)
            base = P.ram(state, [(first, '-')], first)
            cfg0 = S.seed(base)
            face = (base[0x05B2] & 0x80) != 0
            # Where the satellite settles is the middle of the walk: it keeps
            # its own place beside the hero and is not where he is.  One run
            # with nothing thrown at it says where that is.
            born0 = T.born(1, 0, face)
            ctl, _a, _t = cartridge(
                state, SCRIPTS['still'], play,
                [(a, v, play) for a, v in sorted(born0.items())])
            centre = (ctl[0][0][1], ctl[0][0][2])
            print('%-3s satellite at %d, %d' % (label, centre[0], centre[1]))
            for kind, slot, dx, dy, sname, life in plan():
                        pads = SCRIPTS[sname]
                        made = dict(T.born(1, 0, face))
                        made.update(shot_at(centre, slot, kind, dx, dy, life))
                        name = ('kind %02X slot %d  %+5d %+5d'
                                % (kind, slot, dx, dy))
                        if True:
                            if only and sname not in only:
                                continue
                            total += 1
                            pk = [(a, v, play)
                                  for a, v in sorted(made.items())]
                            want, warm, ticks = cartridge(state, pads,
                                                          play, pk)
                            cfg = into_cfg(dict(cfg0), made)
                            cfg['pads'] = pads
                            cfg['clock_at'] = [t[0] for t in ticks]
                            cfg['noise_at'] = [t[1] for t in ticks]
                            cfg['six_at'] = [t[2] for t in ticks]
                            cfg['step_at'] = [t[3] for t in ticks]
                            cfg['ride_at'] = [t[4] for t in ticks]
                            cfg['new_at'] = [t[5] for t in ticks]
                            got, garm = engine(cfg, scratch)
                            n = min(len(want), len(got),
                                    len(warm), len(garm))
                            done = S.finished(ticks, n)
                            where = None
                            kindof = ''
                            for i in range(n):
                                if not done[i]:
                                    continue
                                if want[i] != got[i]:
                                    where, kindof = i, 'slot'
                                    break
                                if warm[i] != garm[i]:
                                    where, kindof = i, 'shot'
                                    break
                            tag = '%s / %s' % (name, sname)
                            if where is None:
                                print('%-3s %-42s ok, %d pictures'
                                      % (label, tag, n))
                                sys.stdout.flush()
                                continue
                            bad += 1
                            print('%-3s %-42s differs on picture %d'
                                  % (label, tag, where))
                            if kindof == 'slot':
                                show(want, got, where)
                            else:
                                show_arms(warm, garm, where)
                            sys.stdout.flush()
        print('%d of %d shots at his own slots differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)


if __name__ == '__main__':
    sys.exit(main())
