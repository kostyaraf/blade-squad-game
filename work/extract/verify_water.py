#!/usr/bin/env python3
"""Э3.2i acceptance: the water and the lava that rise.

Five sorts of area carry water or lava that moves while the level is played,
and each moves it its own way ($D13B, $D18D, $D1AD, $D1CD, all under $CED2).
The engine is told nothing but the two the level itself decides -- the picture
count $1C and whether the level is being played ($27) -- and must answer with
the line the water has climbed to ($29), the screen's own drawing point ($FC)
and which way the two are going ($20), picture for picture.
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

GODOT = V.GODOT
GAME = V.GAME
FRAMES = 600
# The five sorts of area that have such water; every other sort has none and
# $29 stands where the area's record left it.
KINDS = (0x04, 0x06, 0x08, 0x09, 0x0A)


def _played(rows, stage, area):
    """The longest run of pictures in which the level is being played.

    The water only moves while the level itself is on its fifth step ($1A) and
    the game is in its ordinary mode ($27); an area opened out of turn is often
    neither for a while, and in one area ($1:5) it never is at all.
    """
    best = []
    run = []
    for r in rows:
        if r['mode'] == 3 and r['w_live'] == 5 \
                and (r['stage'], r['area']) == (stage, area):
            run.append(r)
        else:
            run = []
        if len(run) > len(best):
            best = list(run)
    return best


_LEVELS = {}


def area_record(stage, area):
    """The area's own record, as the extractor wrote it down."""
    if stage not in _LEVELS:
        path = os.path.join(ROOT, 'game', 'data', 'pb2', 'levels',
                            'stage%d.json' % stage)
        _LEVELS[stage] = json.load(open(path))['areas']
    rec = _LEVELS[stage]
    return rec[area] if area < len(rec) else None


def areas():
    """Every area of the game whose sort has water that moves."""
    out = []
    for stage, area in V.areas_from_index():
        rec = area_record(stage, area)
        if rec is not None and int(rec.get('kind', 0)) in KINDS:
            out.append((stage, area))
    return out


def check(stage, area, tmp):
    spot = V.settled_spot(stage, area)
    # $1A := 5 -- the step of the level that plays it.  Three of these areas
    # are ones the game only ever enters at the end of a stage, and opened out
    # of turn they sit in the steps that follow the level instead ($1A nine to
    # eleven), in which the water is never asked to move at all.  Writing the
    # playing step before the run begins is the same door the areas themselves
    # are opened by.
    rows = pb2_trace.trace([(2, '-')], FRAMES, stage=stage, area=area,
                           spot=spot, pokes=((0x1A, 5),))
    # The longest stretch of the recording in which the level is really being
    # played, and not the prefix of it: an area opened out of turn often runs
    # its own opening first, and the water stands still through that.
    rows = _played(rows[1:], stage, area)
    if len(rows) < 8:
        return None, 'not ordinary play'
    start, rest = rows[0], rows[1:]
    cfg = {'stage': stage, 'area': area,
           'water': start['w_line'], 'flow': start['w_flow'],
           'draw': start['w_draw'], 'still': start['w_still'],
           'grip': start['w_grip'],
           'frames': [{'clock': r['clock'], 'mode': r['mode'],
                       'live': r['w_live']} for r in rest]}
    path = os.path.join(tmp, 'water.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([GODOT, '--path', GAME, '--headless', '--',
                        '--water=' + path], capture_output=True, text=True,
                       timeout=V.ENGINE_WAIT)
    got = []
    for line in r.stdout.split('\n'):
        f = line.strip().split(' ')
        if len(f) == 3 and f[0].isdigit():
            got.append([int(x) for x in f])
    if not got:
        return None, 'the engine said nothing'
    bad = []
    for i, want in enumerate(rest):
        if i >= len(got):
            break
        mine = got[i]
        theirs = [want['w_line'], want['w_draw'], want['w_flow']]
        for n, name in enumerate(('line', 'draw', 'flow')):
            # The screen's own drawing point is only the water's business in a
            # kind four area, where the two turn each other round ($D14D).
            # Everywhere else it follows the scrolling, which is not this.
            if name == 'draw' and int(area_record(stage, area)['kind']) != 4:
                continue
            if mine[n] != theirs[n]:
                bad.append('    picture %d  %-4s engine %3d  cartridge %3d'
                           % (i + 1, name, mine[n], theirs[n]))
        if bad:
            return None, 'the water parted from the cartridge\n' \
                + '\n'.join(bad[:6])
    return len(rest), None


def main():
    tmp = pb2_trace.P.scratch('water')
    ran = bad = 0
    for stage, area in areas():
        rec = area_record(stage, area)
        steps, why = check(stage, area, tmp)
        ran += 1
        if why is not None:
            if why == 'not ordinary play':
                ran -= 1
                print('%d:%-2d kind %2d  left out -- not ordinary play'
                      % (stage, area, int(rec['kind'])))
                continue
            bad += 1
            print('%d:%-2d kind %2d  FAILED -- %s'
                  % (stage, area, int(rec['kind']), why))
        else:
            print('%d:%-2d kind %2d  ok   %d pictures'
                  % (stage, area, int(rec['kind']), steps))
    print('%d of %d areas differ' % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
