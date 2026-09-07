#!/usr/bin/env python3
"""Э3.2a acceptance: the engine must put the level's things out as the
cartridge does.

The list of what stands where is data; what has to be matched is the walk of
that list -- which record comes alive on which step, in which of the eight
slots, and at what place on the screen.  The engine is given the same buttons
and the same deaths (it has no minds for the things yet, so nothing it puts out
would ever die on its own) and must answer with the same births.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402


# What tests the scan is the view travelling, and the surest way to make it
# travel is to stop asking the hero to walk and simply pin him to one edge of
# the screen: the view chases him there and keeps going until the area ends.
# Pinned to the far edge for the first half of the run and to the near one for
# the second, it goes out and comes back, so both edges of the scan are tried.
#
# He is made unkillable for these runs as well -- a pit or a hit would end the
# walk half way.  None of it touches what is being compared: the engine is told
# where he was, it does not work it out.
#
# Down a level he may not be pinned to the very bottom: at $E0 the game decides
# he has left the picture and stops running the level at all ($D0BB sees $4E
# set and returns before the view is ever driven).  $C0 is as far down as it
# takes him and still plays.

# --- the boss rooms -------------------------------------------------------
#
# The ten of them are a table of their own, the last one the extractor found,
# and `V.settled_spot` throws every one of them out: it asks that the game be
# in play mode ($27 = 3) for the whole minute it watches, and a boss room
# begins with the meter filling ($27 = 4).  So the same question is asked here
# with the looser answer the cartridge itself uses -- $8003 runs the level's
# frame for anything under five -- and the hero is allowed to be hurt, which
# in a boss room is the point.


def boss_stage():
    """Which table holds the boss rooms: the last one, and nothing walks it."""
    path = os.path.join(ROOT, 'game', 'data', 'pb2', 'levels', 'index.json')
    return json.load(open(path))['stages'][-1]['stage']


# A room opened behind the game's back does not put the hero in it: five of
# the six rooms in the middle hand slot zero over already dead ($049A nought,
# $058C at $22 -- the fall of a man who has lost), and all four at the end
# leave the game in mode 2, where the level runs but the hero is not driven.
# Both are the same thing: the cartridge only ever walks into these rooms out
# of the area before them, and the walking-on is what sets the hero up.
#
# So the four bytes that walk-on would have written are written here instead --
# the mode, his health, his stance and his mark -- three frames before the run
# takes control.  Nothing else is touched; what is being compared is the
# things, and the hero is only there to be somewhere for them to aim at.
BOSS_POKES = ((0x27, 0x03),                          # $27 -- ordinary play
              (pb2_trace.P.field(7), 0x10),          # $049A -- a full bar
              (pb2_trace.P.field(18), 0x04),         # $058C -- on his feet
              (pb2_trace.P.field(1), 0x00))          # $0416 -- nothing owed


def _boss_settled(stage, area, spot):
    rows = pb2_trace.trace([(2, '-')], 60, stage=stage, area=area, spot=spot,
                           pokes=BOSS_POKES)
    if any(r['mode'] >= 5 for r in rows):            # $8003 -- CMP #$05 / BCS
        return False
    if rows[0]['alive'] == 0:
        return False
    return all(r['sub'] == 4 and r['state'] == 0 for r in rows[-20:])


_BOSS_SPOTS = {}


def boss_spot(stage, area, tries=16):
    key = (stage, area)
    if key not in _BOSS_SPOTS:
        cam = pb2_trace.trace([(2, '-')], 2, stage=stage, area=area,
                              pokes=BOSS_POKES)[0]['cam']
        found = None
        for spot in V.Area(stage, area).spots_on_screen(cam)[:tries]:
            if _boss_settled(stage, area, spot):
                found = spot
                break
        _BOSS_SPOTS[key] = found
    return _BOSS_SPOTS[key]


DRAG = 2400
PIN_ALONG = (0x0508, 0xE0, 0x00)   # $0508 -- his place across the screen
PIN_DOWN = (0x04C6, 0xC0, 0x20)    # $04C6 -- and down it


def run_engine(cfg, path):
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--spawns=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped -- a script that will not '
                         'parse leaves it running\n')
        return []
    out = []
    for line in r.stdout.split('\n'):
        line = line.strip()
        if '|' not in line:
            continue
        parts = line.split('|')
        if len(parts) != 5 or not parts[0].isdigit():
            continue
        cam, rest, gone, agree, wrong = parts
        born = [] if rest == '-' else [tuple(int(x) for x in p.split(':'))
                                       for p in rest.split()]
        culled = [] if gone == '-' else [int(x) for x in gone.split()]
        out.append(((int(cam), sorted(born), sorted(culled)),
                    tuple(int(x) for x in agree.split('/')),
                    [] if wrong == '-' else sorted(wrong.split())))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def script_for(rows, stage, area, spot, script, pokes=()):
    """What the engine is told: where the things already are, and one line per
    step -- the hero's place on the screen, which the view follows, and the
    slots the cartridge emptied."""
    start = rows[0]
    vertical = V.Area(stage, area).vertical
    frames = []
    # The whole table is twenty-two places of twenty-nine bytes, and handing
    # all of it over on every step of a two thousand step run is six megabytes
    # of nothing much: on a given step a handful of places change and the rest
    # stand still.  So only the places that differ from the last hand-over are
    # sent, each as its number followed by its twenty-nine bytes.  The engine
    # keeps the same running copy, so what it holds is always the whole truth.
    prev = [[0] * pb2_trace.FIELDS for _ in range(pb2_trace.SLOTS)]
    for r in rows[1:]:
        whole = []
        for tbl in r['whole']:
            d = []
            for n, row in enumerate(tbl):
                if row != prev[n]:
                    d.append([n] + row)
                    prev[n] = row
            whole.append(d)
        here = r['see_y'] if vertical else r['see_x']
        # Only the deaths the engine cannot yet reach on its own are told to
        # it; the sweep's own it must find, and what it finds is compared.
        told = [n for n in r['died'] if n not in r['culled']]
        # Where everything stood when the sweep looked.  The engine has no minds
        # for the things yet, so anything that moves itself it cannot place --
        # what is being compared here is the sweep's answer, not the places, and
        # a wrong place would only ask it a question the cartridge never asked.
        # How often it had the place right anyway is counted and reported.
        frames.append({'screen': here, 'died': told, 'taken': r['taken'],
                       'whole': whole, 'shifts': r['shifts'],
                       'turns': r['turns'], 'seeds': r['seeds'],
                       'suits': r['suits'], 'ticks': r['ticks'],
                       'helds': r['helds'],
                       'waters': r['waters'], 'draws': r['draws'],
                       'cams': r['cams'],
                       'culled': sorted(r['culled']),
                       'got': r['got'], 'done': r['done']})
    return dict(
        stage=stage, area=area,
        cam=start['cam'],
        cam_pend=start['pend'] - 256 if start['pend'] > 127 else start['pend'],
        clock=start['clock'],
        shift_before=start['shift'],
        # Read where the comparison begins, not where the run does.
        slots=pb2_trace.objects(stage, area, spot, script=script,
                                upto=start['frame'], pokes=pokes),
        frames=frames,
    )


def want(rows):
    """Where the view stood and what the cartridge put out, one per step."""
    out = []
    for r in rows[1:]:
        out.append((r['cam'],
                    sorted((b['slot'], b['type'], b['rec'], b['x'], b['y'])
                           for b in r['born'] if 'rec' in b),
                    sorted(r['culled'])))
    return out


# Neither gate on the way to a slot ($E523, $E559) ever says no in an area
# walked once from a standing start: nothing has been picked up and nothing
# has been killed, so both lists are empty and the gates are never on trial.
# So one run of each area is made with the lists held full: every one of the
# sixteen collectables taken, and the first few records of the area already
# given out.  The engine is told the same lists, and must drop the same
# records the cartridge drops.
#
# The list may only be five long.  Nothing bounds it in the cartridge -- $B757
# writes at $0172 and counts up -- but the cartridge also keeps other things
# from $0177 on ($DF8B, $DFA0, $DFA3 and $E0BE all write there), so a longer
# list would be held over memory that is in use, and what the scan read would
# depend on which ran first.  $0172 to $0176 nothing else touches.
NDONE = 5
GATES = ([(0x2B, 0xFF, 0), (0x2C, 0xFF, 0), (0x0171, NDONE, 0)]
         + [(0x0172 + i, i + 1, 0) for i in range(NDONE)])


def check(name, script, stage, area, tmp, spot, frames, drag=False,
          gates=False, pokes=()):
    P = pb2_trace.P
    P.ROMPOKE = list(P.IMMORTAL) if drag else []
    if drag:
        pin, far, near = (PIN_DOWN if V.Area(stage, area).vertical
                          else PIN_ALONG)
        P.FREEZE = [(pin, far, 0), (pin, near, P.IN_LEVEL + frames // 2)]
    else:
        P.FREEZE = []
    if gates:
        P.FREEZE = P.FREEZE + GATES
    try:
        return _check(script, stage, area, tmp, spot, frames, pokes)
    finally:
        P.ROMPOKE = []
        P.FREEZE = []


def _check(script, stage, area, tmp, spot, frames, pokes=()):
    rows = V.logic_frames(V.ordinary(pb2_trace.trace(
        script, frames, stage=stage, area=area, spot=spot, pokes=pokes)))
    rows = rows[:-1][V.SETTLE:]
    if len(rows) < 2:
        return 0, 0, None
    w = want(rows)
    got = run_engine(script_for(rows, stage, area, spot, script, pokes),
                     os.path.join(tmp, 's.json'))
    agree = [0, 0, 0]
    for i, expect in enumerate(w):
        have = got[i][0] if i < len(got) else None
        if have != expect:
            return None, None, (i + 1, expect, have)
        # A type the engine drives itself has to answer field for field.  The
        # line says place, field, what the engine said, what the cartridge did.
        if got[i][2]:
            return None, None, (i + 1, 'the same', got[i][2])
        agree[0] += got[i][1][0]
        agree[1] += got[i][1][1]
        agree[2] += got[i][1][2]
    return len(w), (sum(len(x[1]) for x in w),
                    sum(len(x[2]) for x in w),
                    agree[0], agree[1], agree[2]), None


def main():
    n_random = 4
    seed = 7
    targets = V.areas_from_index()
    for a in sys.argv[1:]:
        if a.startswith('--random='):
            n_random = int(a.split('=')[1])
        elif a.startswith('--seed='):
            seed = int(a.split('=')[1])
        elif a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
    boss = boss_stage()
    tmp = pb2_trace.P.scratch('spawnverify')
    ran = bad = steps = births = culls = 0
    same = seen = mine = 0
    for stage, area in targets:
        spot = (boss_spot(stage, area) if stage == boss
                else V.settled_spot(stage, area))
        if spot is None:
            continue
        # The scan is a walk of the level's list, so what tests it is the view
        # travelling far.  The button scripts are short, but the four that only
        # lean on one direction are given as long as the whole area takes.
        scripts = [(n, s, V.FRAMES, False) for n, s in
                   V.random_scripts(n_random, seed + 31 * (stage * 16 + area))]
        scripts.append(('drag', [(0, '-')], DRAG, True, False))
        scripts.append(('drag-gated', [(0, '-')], DRAG, True, True))
        scripts = [s if len(s) == 5 else s + (False,) for s in scripts]
        for name, script, frames, drag, gates in scripts:
            ran += 1
            n, b, diff = check(name, script, stage, area, tmp, spot, frames,
                               drag, gates,
                               BOSS_POKES if stage == boss else ())
            label = '%d:%-2d %-12s' % (stage, area, name)
            if diff is None:
                steps += n
                births += b[0]
                culls += b[1]
                same += b[2]
                seen += b[3]
                mine += b[4]
                print('%s ok   %d steps %d born %d swept%s'
                      % (label, n, b[0], b[1],
                         '' if not b[4] else ' %d judged' % b[4]))
            else:
                bad += 1
                print('%s DIFF at step %d' % (label, diff[0]))
                print('    game   %s' % (diff[1],))
                print('    engine %s' % (diff[2],))
            sys.stdout.flush()
    pb2_trace.P.sweep(tmp)
    print('%d of %d scripts differ, %d steps, %d births and %d sweeps '
          'matched' % (bad, ran, steps, births, culls))
    if seen:
        print('the engine had the place right by itself for %d of %d '
              '(%.1f%%) -- the rest move themselves and have no minds yet'
              % (same, seen, 100.0 * same / seen))
    print('%d turns were the engine\'s own and every field of them agreed'
          % mine)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
