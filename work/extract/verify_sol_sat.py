#!/usr/bin/env python3
"""Э4.1 acceptance: the hero's own four slots, $0C to $0F.

Slot $0C is the satellite a finished letter combination gives him, $0D holds
its bang, $0E what the seventh weapon swings in close and $0F his punch.  They
are not walked with the rest of the pool: $A489 in bank twelve walks them on
their own, from $9156, after the hero himself and after the $0700 pool.

Getting a satellite the way the game does means picking up three letters, so
the stand puts one there by hand instead -- the same eleven bytes $92CD and
$9347 write -- on the first picture that is played, and the engine is handed
the same.  Both are then given the same buttons and must answer the same
numbers for all four slots and for the eight slots of the $0700 pool.

Each of the eight weapons is stood up in turn, and the buttons include the one
that fires ($40, which is B) pressed, held and let go, because several of the
weapons only do anything on one of those three.
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
import verify_sol_weapon as W                                    # noqa: E402

HANDS = 4                 # $0C..$0F
FIRST = 0x0C
NAMES = ('id', 'x', 'y', 'mind', 'kind', 'a', 'b', 'c', 'd', 'face',
         'anim_a', 'anim_b', 'left', 'frame', 'cool', 'life',
         'pic_lo', 'pic_hi')
# Where each of those eighteen lives, in the order $AF20 writes them.
PAGES = (0x0600, None, None, 0x0650, 0x0690, 0x0610, 0x0620, 0x0630, 0x0640,
         0x0680, 0x06A0, 0x06B0, 0x06C0, 0x06D0, 0x06E0, 0x06F0,
         0x0660, 0x0670)

R, L, B = 0x01, 0x02, 0x40
LEN = 40


def hold(n, pad):
    return [pad] * n


# The buttons.  A weapon that fires on a press, one that fires while held and
# one that only lets go when the button does all have to be met.
SCRIPTS = {
    'still':        hold(LEN, 0),
    'one shot':     hold(4, 0) + hold(2, B) + hold(LEN - 6, 0),
    'held down':    hold(4, 0) + hold(LEN * 2, B),
    'held and let go': hold(4, 0) + hold(60, B) + hold(LEN, 0),
    'firing right': hold(4, R) + hold(LEN, R | B) + hold(LEN, R),
    'tapping':      (hold(3, 0) + hold(2, B)) * 12,
}

PLACES = [('s0', 0), ('s1', 1), ('s5', 5)]

# $9337 -- and which weapon each of the eight letter combinations gives.
WEAPONS = [(1, 0), (2, 1), (3, 2), (4, 3), (5, 4), (6, 5), (7, 6), (8, 7)]

# $9337 itself, as the exporter left it.
COMBOS = json.load(open(os.path.join(
    ROOT, 'game', 'data', 'sol', 'sat.json')))['combos']

# The wait runs $80 down to $30 before anything is made, so a script that is
# to see a satellite born has to be long enough to get there and then watch it.
LETTER_SCRIPTS = {
    'waiting':      hold(LEN * 4, 0),
    'walking':      hold(LEN * 4, R),
    'firing after': hold(90, 0) + hold(LEN * 2, B),
}


def cases(face, guns, letters_only):
    """What is stood up: a satellite put there by hand, or three letters.

    The letters are the way the game itself does it -- $05C4 is set, $923B
    sees a combination it knows, and eighty pictures later $92CD pays it out.
    The second half of each pair also puts the satellite the combination would
    give there already, which is what makes $92F2 take the other branch and
    burst the one he has instead of giving him a second.
    """
    out = []
    if not letters_only:
        for weapon, index in WEAPONS:
            if guns and weapon not in guns:
                continue
            out.append(('weapon %d' % weapon, born(weapon, index, face),
                        SCRIPTS))
        return out
    for weapon, index in WEAPONS:
        if guns and weapon not in guns:
            continue
        out.append(('letters %d' % weapon, {0x05C4: COMBOS[index]},
                    LETTER_SCRIPTS))
        made = born(weapon, index, face)
        made[0x05C4] = COMBOS[index]
        out.append(('letters %d again' % weapon, made, LETTER_SCRIPTS))
    return out


def born(weapon, index, face):
    """$92CD and $9347 -- the eleven bytes that make a satellite.

    $9310 sets the resting angle from which way the hero is looking, $9321 puts
    the weapon's id in the slot and its number in the behaviour, and $9347
    gives it its sixteen points of life and wipes everything else.
    """
    out = {
        0x060C: weapon,                 # $9327
        0x060D: 0,                      # $92E0 -- and the bang is not there yet
        0x065C: index,                  # $9324
        0x061C: 0x2B if face else 0x35,  # $931E
        0x06FC: 0x10,                   # $9349
        0x06EC: 0xFF,                   # $934E
    }
    for a in (0x062C, 0x063C, 0x064C, 0x069C, 0x06CC, 0x06DC,
              0x06AC, 0x06BC, 0x066C, 0x067C):
        out[a] = 0                      # $9359
    for i in range(11):
        out[0x0700 + i] = 0             # $92E5 -- eleven of the $0700 pool
    return out


def cartridge(state, pads, base, pk):
    script = V.cartridge_script(pads, base)
    addrs = set(S.TICKS)
    for p in PAGES:
        if p is not None:
            addrs |= {p + FIRST + i for i in range(HANDS)}
    addrs |= {0xA0 + FIRST + i for i in range(HANDS)}
    addrs |= {0xB0 + FIRST + i for i in range(HANDS)}
    addrs |= {0xC0 + FIRST + i for i in range(HANDS)}
    addrs |= {0xD0 + FIRST + i for i in range(HANDS)}
    for p in W.PAGES:
        addrs |= {p + i for i in range(W.WALKED)}
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
            for k, p in enumerate(PAGES):
                if NAMES[k] == 'x':
                    row.append(c[0xA0 + s] | c[0xB0 + s] << 8)
                elif NAMES[k] == 'y':
                    row.append(c[0xC0 + s] | c[0xD0 + s] << 8)
                else:
                    row.append(c[p + s])
            one.append(tuple(row))
        hands.append(tuple(one))
        arms.append(tuple(
            (c[0x0700 + i],
             c[0x0710 + i] | c[0x0720 + i] << 8,
             c[0x0730 + i] | c[0x0740 + i] << 8,
             c[0x0750 + i], c[0x0760 + i], c[0x0770 + i])
            for i in range(W.WALKED)))
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
        elif line.startswith('W '):
            f = line[2:].split()
            if len(f) == W.WALKED and all(t.count(',') == 5 for t in f):
                arms.append(tuple(tuple(int(v) for v in t.split(','))
                                  for t in f))
    missing = {}
    for line in r.stderr.split('\n'):
        for tag in ('satellite not read yet: ', 'weapons not read yet: '):
            if not line.startswith(tag):
                continue
            body = line.split(': ', 1)[1].replace('"', '')
            for part in body.strip('{}').split(','):
                k, _, v = part.partition(':')
                if v.strip().isdigit():
                    missing[k.strip()] = missing.get(k.strip(), 0) + int(v)
    if not hands:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
    return hands, arms, missing


def show(want, got, where):
    for s in range(HANDS):
        if want[where][s] == got[where][s]:
            continue
        for k, nm in enumerate(NAMES):
            if want[where][s][k] != got[where][s][k]:
                print('    slot %02X %-6s cartridge %6d   engine %6d'
                      % (FIRST + s, nm, want[where][s][k], got[where][s][k]))


def show_arms(want, got, where):
    for s in range(W.WALKED):
        if want[where][s] == got[where][s]:
            continue
        for k, nm in enumerate(W.NAMES):
            if want[where][s][k] != got[where][s][k]:
                print('    shot %d %-5s cartridge %6d   engine %6d'
                      % (s, nm, want[where][s][k], got[where][s][k]))


def main():
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    places = [a.split('=')[1] for a in sys.argv[1:] if a.startswith('--place=')]
    guns = [int(a.split('=')[1]) for a in sys.argv[1:]
            if a.startswith('--weapon=')]
    letters_only = '--letters' in sys.argv[1:]
    scratch = P.scratch('sat')
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
            face = (base[0x05B2] & 0x80) != 0
            for tag0, made, scripts in cases(face, guns, letters_only):
                pk = [(a, v, play) for a, v in sorted(made.items())]
                for name, pads in sorted(scripts.items()):
                    if only and name not in only:
                        continue
                    total += 1
                    want, warm, ticks = cartridge(state, pads, play, pk)
                    cfg = dict(cfg0)
                    cfg['pads'] = pads
                    cfg['clock_at'] = [t[0] for t in ticks]
                    cfg['noise_at'] = [t[1] for t in ticks]
                    cfg['six_at'] = [t[2] for t in ticks]
                    cfg['step_at'] = [t[3] for t in ticks]
                    cfg['ride_at'] = [t[4] for t in ticks]
                    cfg['new_at'] = [t[5] for t in ticks]
                    for a, v in made.items():
                        if a == 0x05C4:
                            cfg['letters'] = v
                            continue
                        key = {0x0600: 'id', 0x0650: 'omind', 0x0690: 'okind',
                               0x0610: 'oa', 0x0620: 'ob', 0x0630: 'oc',
                               0x0640: 'od', 0x0660: 'opic_lo',
                               0x0670: 'opic_hi', 0x06A0: 'oanim_a',
                               0x06B0: 'oanim_b', 0x06C0: 'oleft',
                               0x06D0: 'oframe', 0x06E0: 'ocool',
                               0x06F0: 'olife', 0x0700: 'wkind'}[a & 0xFFF0]
                        cfg[key] = list(cfg[key])
                        cfg[key][a & 0x0F] = v
                    got, garm, missing = engine(cfg, scratch)
                    for k, v in missing.items():
                        owed[k] = owed.get(k, 0) + v
                    n = min(len(want), len(got), len(warm), len(garm))
                    done = S.finished(ticks, n)
                    keep = W.inside(warm)
                    where = None
                    kind = ''
                    for i in range(n):
                        if not done[i]:
                            continue
                        if want[i] != got[i]:
                            where, kind = i, 'slot'
                            break
                        if W.seen(warm[i], keep[i]) != W.seen(garm[i], keep[i]):
                            where, kind = i, 'shot'
                            break
                    if where is None and len(want) != len(got):
                        where, kind = n, 'length'
                    tag = '%s / %s' % (tag0, name)
                    if where is None:
                        print('%-4s %-32s ok, %d frames' % (label, tag, n))
                        sys.stdout.flush()
                        continue
                    bad += 1
                    print('%-4s %-32s differs on frame %d' % (label, tag, where))
                    if kind == 'slot':
                        show(want, got, where)
                    elif kind == 'shot':
                        show_arms(warm, garm, where)
                    else:
                        print('    cartridge %d frames, engine %d'
                              % (len(want), len(got)))
                    sys.stdout.flush()
        if owed:
            print('not read yet:', owed)
        print('%d of %d scripts differ' % (bad, total))
        return 1 if bad else 0
    finally:
        P.sweep(scratch)
        P.sweep(P.SCRATCH)


if __name__ == '__main__':
    main()
