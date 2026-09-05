#!/usr/bin/env python3
"""Э3.1 acceptance: the door at the end of an area, and what it opens.

The cartridge is played until the door of the area has been put out, and then
the door is made to open where it stands -- the same two bytes $B5A5 writes
when the hero walks into it.  From there the engine is given the same table,
step by step, and has to drive the door itself: six steps, thirty-two frames of
opening, eight rows of doorway, thirty-two frames of closing, and at the end
the level told to build itself again.

What is judged is every field of the door on every step, and then the four
things the closing decides: which area is opened, whether it is a boss room,
where the hero is stood in it and where the view begins.  A single byte of
difference is a failure.

Run with no arguments it walks every area that has a door.
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
import verify_spawns as S                                    # noqa: E402
from pb2_palettes import PB2Palettes                         # noqa: E402
from common import ROM_PB2                                   # noqa: E402

DOOR = 0x04
# How long the walk that finds the door is given, and how long the run that
# opens it: the opening alone is a hundred and thirty frames, and the level
# takes another sixty to come back.
FIND = 2400
# The opening alone is a hundred and thirty frames, and the level takes
# another sixty to come back; this is what a run is given past the touch.
PLAY = 260
# The door is opened a few steps after it has been put out, so that the engine
# has seen it stand there first.
AFTER = 8
# ...and never before the run has settled: the first eight steps of a trace are
# thrown away, and a touch inside them would leave nothing to compare.
MIN_OPEN = 40


def find_door(stage, area, spot):
    """The step the door of this area was first seen waiting on, and its place.

    Nothing the buttons can do reaches it in the time a study run has -- it is
    at the far end of the area -- so the hero is pinned against one edge and
    the view chases him the whole way.

    Only the part of the walk that is still this area counts: pinned against
    the far edge the hero usually walks into the door himself, and everything
    after that belongs to the next area and to a different door.
    """
    P = pb2_trace.P
    P.ROMPOKE = list(P.IMMORTAL)
    pin, far, _near = (S.PIN_DOWN if V.Area(stage, area).vertical
                       else S.PIN_ALONG)
    # Which edge the area runs towards is not written down anywhere; both are
    # tried and the first that finds the door is kept.
    for held in (0x20, far):
        P.FREEZE = [(pin, held, 0)]
        try:
            rows = pb2_trace.trace([(0, '-')], FIND, stage=stage, area=area,
                                   spot=spot)
        finally:
            P.FREEZE = []
        for r in rows:
            if r['area'] != area:
                break
            if not r['whole']:
                continue
            for n, row in enumerate(r['whole'][0]):
                if row[0] == DOOR and row[18] == 0x01:
                    P.ROMPOKE = []
                    return r['frame'], n, held
    P.ROMPOKE = []
    return None, None, None


def played(stage, area, spot, seen, slot, held):
    """The run in which the door is opened, up to and including the step the
    level is told to build itself again.

    Two things have to be held still to get there.  The pinning that walked the
    view to the door is kept until the door is opened: let go of any sooner and
    the view slides back, the door goes out with it and its place is taken by
    something else.  And the door itself is held waiting -- its box and its
    step written back at the head of every frame -- because the pinned hero is
    standing in it and would otherwise open it himself, before the run has
    settled enough to have anything to compare.
    """
    P = pb2_trace.P
    P.ROMPOKE = list(P.IMMORTAL)
    pin, _far, _near = (S.PIN_DOWN if V.Area(stage, area).vertical
                        else S.PIN_ALONG)
    first = pb2_trace.P.IN_LEVEL
    open_at = max(seen + AFTER, MIN_OPEN)
    P.FREEZE = [(pin, held, 0, first + open_at),
                (0x0416 + slot, 0x10, first + seen, first + open_at - 1),
                (0x058C + slot, 0x01, first + seen, first + open_at - 1)]
    try:
        rows = V.logic_frames(pb2_trace.trace(
            [(0, '-')], open_at + PLAY, stage=stage, area=area, spot=spot,
            during=((0x0416 + slot, 0x80, open_at),
                    (0x058C + slot, 0x02, open_at))))
    finally:
        P.FREEZE = []
        P.ROMPOKE = []
    return rows


def cut(rows, area):
    """From the settled start to the step in which the next area was opened.

    The whole of the opening is one step of the game: $0110 stands still from
    the moment the door is touched until the new area is playing, so the
    hundred and thirty frames of it are one line with a hundred and thirty
    tables in it.
    """
    rows = rows[:-1][V.SETTLE:]
    for i, r in enumerate(rows):
        if r['area'] != area:
            return rows[:i + 1]
    return None


def touched(rows, slot):
    """Which table of the run is the last before the door was made to open.

    The cartridge's own touch lands between one table and the next -- the
    sweep runs at $CF08 and the table is written down after it -- so what the
    engine is told is the table after whose turn the door was touched.
    """
    n = 0
    for r in rows[1:]:
        for tbl in r['whole']:
            if tbl[slot][0] == DOOR and tbl[slot][18] == 0x02:
                return n - 1
            n += 1
    return None


def run_engine(cfg, path):
    open(path, 'w').write(json.dumps(cfg))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--spawns=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return None, None
    steps = []
    end = None
    for line in r.stdout.split('\n'):
        line = line.strip()
        if '|' not in line:
            continue
        parts = line.split('|')
        if len(parts) == 8 and parts[0] == '-1':
            end = tuple(int(x) for x in parts[1:])
        elif len(parts) == 5 and parts[0].isdigit():
            steps.append([] if parts[4] == '-' else sorted(parts[4].split()))
    if not steps:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return steps, end


FIELD = ['type', 'mark', 'bits', 'kind', 'anim', 'step', 'rec', 'life',
         'yhi', 'y', 'yfr', 'xhi', 'x', 'xfr', 'vy', 'vyfr', 'vx', 'vxfr',
         'state', 'hold', 'stun', 'self', 'count', 'keep', 'keep2', 'push',
         'ang', 'recb', 'ground']


def show(where, told):
    # The engine puts a word about where the hero and the thing stood at the
    # end of the list; it is not a difference and has no fields to name.
    if told.count(':') != 3:
        return '    step %s  %s' % (where, told)
    slot, field, mine, theirs = told.split(':')
    n, kind = slot.split('/')
    return ('    step %s  slot %s (type %s)  %-6s engine %s  cartridge %s'
            % (where, n, kind, FIELD[int(field)], mine, theirs))


def check(stage, area, tmp, pal):
    spot = V.settled_spot(stage, area)
    if spot is None:
        return None, 'not played out of turn'
    seen, slot, held = find_door(stage, area, spot)
    if seen is None:
        return None, 'the door was never put out'
    rows = played(stage, area, spot, seen, slot, held)
    rows = cut(rows, area)
    if rows is None or len(rows) < 4:
        return None, 'the door never opened'
    at = touched(rows, slot)
    if at is None or at < 0:
        return None, 'the touch fell outside the run'
    cfg = S.script_for(rows, stage, area, spot, [(0, '-')])
    cfg['touch'] = [[at, slot]]
    steps, end = run_engine(cfg, os.path.join(tmp, 'f.json'))
    if steps is None:
        return None, 'the engine said nothing'
    for i, wrong in enumerate(steps):
        if wrong:
            return None, ('the door parted from the cartridge\n'
                          + '\n'.join(show(i + 1, w) for w in wrong[:8]))
    if end is None:
        return None, 'the engine never opened the next area'
    # What the cartridge did: the last step of the run is the one that told the
    # level to build itself, and a few steps later it stands him in the new one.
    last = rows[-1]
    to_stage = stage
    want_area = last['area']
    got_stage, got_area, got_boss, gx, gy, gface, gcam = end
    if got_boss:
        to_stage = 6
    if (got_stage, got_area) != (to_stage, want_area):
        return None, ('the next area parted: engine %d:%d, cartridge %d:%d'
                      % (got_stage, got_area, to_stage, want_area))
    st = pal.area_start(to_stage, want_area)
    rec = pal.area_record(to_stage, want_area)
    cam = (rec[3] << 8) | rec[4]
    if (gx, gy, gface, gcam) != (st['x'], st['y'], st['face'], cam):
        return None, ('the walk-on parted: engine %d,%d face %d view %d; '
                      'cartridge %d,%d face %d view %d'
                      % (gx, gy, gface, gcam,
                         st['x'], st['y'], st['face'], cam))
    return len(steps), None


def has_door(stage, area):
    d = json.load(open(os.path.join(
        ROOT, 'game', 'data', 'pb2', 'levels', 'stage%d.json' % stage)))
    return any(r['type'] == DOOR for r in d['areas'][area]['spawns'])


def main():
    pal = PB2Palettes(ROM_PB2)
    targets = []
    for a in sys.argv[1:]:
        if a.startswith('--areas='):
            targets = [tuple(int(x) for x in p.split(':'))
                       for p in a.split('=')[1].split(',')]
    if not targets:
        targets = [(s, a) for s, a in V.areas_from_index()
                   if has_door(s, a)]
    tmp = pb2_trace.P.scratch('flow')
    ran = bad = left = 0
    for stage, area in targets:
        steps, why = check(stage, area, tmp, pal)
        if why is not None and why in ('not played out of turn',
                                       'the door was never put out'):
            print('%d:%d  %s -- left out' % (stage, area, why))
            left += 1
            continue
        ran += 1
        if why is not None:
            bad += 1
            print('%d:%d  FAILED -- %s' % (stage, area, why))
        else:
            print('%d:%d  ok   %d steps to the next area' % (stage, area,
                                                             steps))
    print('%d of %d areas differ; %d left out' % (bad, ran, left))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
