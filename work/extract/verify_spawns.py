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
# They are a table of their own, the last one the extractor found, and none of
# them is reached by walking.  A door does it, and a door writes two bytes:
# $79, which tells the whole game to read the last table whatever stage it is
# in, and $9C, the room.  The ordinary door at the end of the last walked area
# opens the middle boss's room and leaves $9C at the stage's own number
# ($86F7); the boss door at the end of the stage opens the end boss's and puts
# $9C six higher ($84FE).  What neither of them touches is $53: the stage the
# hero came from stands, and that is what the boss itself reads to know which
# of the twelve it is -- $8737 adds $50 to the room, $87C3 adds $56 to the
# stage.  So a room opened behind the game's back has to be given all three,
# and the number the room is filed under is not the number the cartridge wants
# in $53.
#
# There is one thing left that walking-on would have done and this does not:
# standing the hero up in the room.  Left alone, a room opened out of turn
# notices within a second and loads itself the way it means to be loaded -- the
# hero comes in at the door, the meter fills, and by three hundred frames on it
# is being played.  So the run starts there instead of at the usual frame, the
# four bytes the walking-on would have written are written anyway, and the hero
# is made unkillable -- a boss room being the one place where he would not last
# a run out, and that has to hold while the savestate is being made as well,
# three hundred frames of a boss swinging at a hero who is not being told to
# move, hence `patch=True`.  He is left where the game put him: there is no
# picking a spot in a room the door leads into.
BOSS_WAIT = 300

BOSS_POKES = ((0x27, 0x03),                          # $27 -- ordinary play
              (pb2_trace.P.field(7), 0x10),          # $049A -- a full bar
              (pb2_trace.P.field(18), 0x04),         # $058C -- on his feet
              (pb2_trace.P.field(1), 0x00))          # $0416 -- nothing owed

# How many rooms hold a middle boss: after those the rooms hold end bosses, and
# the stage a room belongs to starts over from nought ($84FE against $86F7).
BOSS_MID = 6


def boss_early(area):
    """$53 and $79 as the door would have left them for this room."""
    return ((0x53, area % BOSS_MID), (0x79, 0x01))


def boss_stage():
    """Which table holds the boss rooms: the last one, and nothing walks it."""
    path = os.path.join(ROOT, 'game', 'data', 'pb2', 'levels', 'index.json')
    return json.load(open(path))['stages'][-1]['stage']


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
        if len(parts) != 6 or not parts[0].isdigit():
            continue
        cam, rest, gone, agree, wrong, ride = parts
        born = [] if rest == '-' else [tuple(int(x) for x in p.split(':'))
                                       for p in rest.split()]
        culled = [] if gone == '-' else [int(x) for x in gone.split()]
        # The boxes the level declared solid this step and how far it is
        # carrying him, as the last sweep of the step left them.
        px, py, boxes = ride.split(',')
        solids = [] if boxes == '-' else [[int(x) for x in b.split(':')]
                                          for b in boxes.split()]
        out.append(((int(cam), sorted(born), sorted(culled)),
                    tuple(int(x) for x in agree.split('/')),
                    [] if wrong == '-' else sorted(wrong.split()),
                    (solids, [int(px), int(py)])))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def script_for(rows, stage, area, spot, script, pokes=(), first=None,
               patch=False, early=()):
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
    # A copy of the table is only taken where the view is moved off it, and a
    # room the view never moves in gives the first step no copy at all.  The
    # first one there is stands in for it: where the hero is looked at here is
    # only the seed of a number that every step after says again.
    hero = next((r['whole'][-1][0] for r in rows if r['whole']), None)
    here = 0 if hero is None else (hero[9] if vertical else hero[12])
    for r in rows[1:]:
        whole = []
        for tbl in r['whole']:
            d = []
            for n, row in enumerate(tbl):
                if row != prev[n]:
                    d.append([n] + row)
                    prev[n] = row
            whole.append(d)
        # $D3CA and $D3D2 -- where the view was told to look.  A room the
        # view never has to move in is never told, and the sample is empty;
        # the last answer stands, as it does on the cartridge.
        seen = r['see_y'] if vertical else r['see_x']
        if seen is not None:
            here = seen
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
                       'helds': r['helds'], 'colours': r['colours'],
                       'waters': r['waters'], 'draws': r['draws'],
                       'cams': r['cams'],
                       'culled': sorted(r['culled']),
                       'got': r['got'], 'done': r['done']})
    slots, rings = pb2_trace.objects(stage, area, spot, first=first,
                                     script=script, upto=start['frame'],
                                     pokes=pokes, patch=patch, early=early,
                                     rings=True)
    return dict(
        stage=stage, area=area,
        # $53 -- the stage the room belongs to, which is not the table it is
        # built out of.  `boss_early` pokes the cartridge with the same number.
        came=dict(early).get(0x53, stage),
        cam=start['cam'],
        cam_pend=start['pend'] - 256 if start['pend'] > 127 else start['pend'],
        clock=start['clock'],
        shift_before=start['shift'],
        # Read where the comparison begins, not where the run does.
        slots=slots,
        rings=rings,
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
          gates=False, boss=False):
    P = pb2_trace.P
    first = P.IN_LEVEL + (BOSS_WAIT if boss else 0)
    pokes = BOSS_POKES if boss else ()
    early = boss_early(area) if boss else ()
    P.ROMPOKE = list(P.IMMORTAL) if drag or boss else []
    if drag:
        pin, far, near = (PIN_DOWN if V.Area(stage, area).vertical
                          else PIN_ALONG)
        P.FREEZE = [(pin, far, 0), (pin, near, first + frames // 2)]
    else:
        P.FREEZE = []
    if gates:
        P.FREEZE = P.FREEZE + GATES
    try:
        return _check(script, stage, area, tmp, spot, frames, pokes, first,
                      boss, early)
    finally:
        P.ROMPOKE = []
        P.FREEZE = []


def _check(script, stage, area, tmp, spot, frames, pokes=(), first=None,
           patch=False, early=()):
    rows = V.logic_frames(V.ordinary(pb2_trace.trace(
        script, frames, stage=stage, area=area, spot=spot, pokes=pokes,
        first=first, patch=patch, early=early)))
    rows = rows[:-1][V.SETTLE:]
    if len(rows) < 2:
        return 0, (0, 0, 0, 0, 0), None
    w = want(rows)
    got = run_engine(script_for(rows, stage, area, spot, script, pokes,
                                first, patch, early),
                     os.path.join(tmp, 's.json'))
    agree = [0, 0, 0]
    ride = _ride(rows, got)
    if ride[2] is not None:
        return None, None, ride[2]
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
                    agree[0], agree[1], agree[2], ride[0], ride[1]), None


# Э3.4: what the level says about the hero himself -- $011F and the boxes at
# $0120..$0150, the two pushes $063C and $0652.  The things take their turn
# first ($800C) and his own update reads what they left ($8E15) and then wipes
# it, so both belong to the one step; `rows[0]` is what the engine was stood
# on, so its line for step `i` is the cartridge's row `i + 1`.
#
# A step in which the cartridge's hero update never ran has nothing to say
# about them and is passed over.
def _ride(rows, got):
    seen = held = 0
    for i, line in enumerate(got):
        if i + 1 >= len(rows) or len(line) < 4:
            break
        r = rows[i + 1]
        if r['solids'] is None:
            continue
        seen += 1
        mine, push = line[3]
        theirs = [list(b) for b in r['solids']]
        # A frame in which the cartridge wrote nothing to the two pushes is a
        # frame in which they were already nought: the log only carries what
        # changed, so nothing seen means nought.
        cart = [r['push'][0] or 0, r['push'][1] or 0]
        if mine != theirs or push != cart:
            return seen, held, (i + 1,
                                'solid %s push %s' % (theirs, cart),
                                'solid %s push %s' % (mine, push))
        if theirs or push != [0, 0]:
            held += 1
    return seen, held, None


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
    ride_seen = ride_held = 0
    for stage, area in targets:
        here = stage == boss
        spot = None if here else V.settled_spot(stage, area)
        if spot is None and not here:
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
                               drag, gates, here)
            label = '%d:%-2d %-12s' % (stage, area, name)
            if diff is None:
                steps += n
                births += b[0]
                culls += b[1]
                same += b[2]
                seen += b[3]
                mine += b[4]
                ride_seen += b[5]
                ride_held += b[6]
                print('%s ok   %d steps %d born %d swept%s%s'
                      % (label, n, b[0], b[1],
                         '' if not b[4] else ' %d judged' % b[4],
                         '' if not b[6] else ' %d carried' % b[6]))
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
    print('the boxes the level declared solid and the two pushes agreed on '
          '%d steps, %d of which the level had hold of him'
          % (ride_seen, ride_held))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
