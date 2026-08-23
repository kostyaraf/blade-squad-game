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
DRAG = 2400
PIN_ALONG = (0x0508, 0xE0, 0x00)   # $0508 -- his place across the screen
PIN_DOWN = (0x04C6, 0xC0, 0x20)    # $04C6 -- and down it


def run_engine(cfg, path):
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                        '--spawns=' + path], capture_output=True, text=True)
    out = []
    for line in r.stdout.split('\n'):
        line = line.strip()
        if '|' not in line:
            continue
        cam, _, rest = line.partition('|')
        if not cam.isdigit():
            continue
        born = [] if rest == '-' else [tuple(int(x) for x in p.split(':'))
                                       for p in rest.split()]
        out.append((int(cam), sorted(born)))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def script_for(rows, stage, area, spot, script):
    """What the engine is told: where the things already are, and one line per
    step -- the hero's place on the screen, which the view follows, and the
    slots the cartridge emptied."""
    start = rows[0]
    vertical = V.Area(stage, area).vertical
    frames = []
    for r in rows[1:]:
        here = r['see_y'] if vertical else r['see_x']
        frames.append({'screen': here, 'died': r['died'],
                       'taken': r['taken']})
    return dict(
        stage=stage, area=area,
        cam=start['cam'],
        cam_pend=start['pend'] - 256 if start['pend'] > 127 else start['pend'],
        clock=start['clock'],
        shift_before=start['shift'],
        # Read where the comparison begins, not where the run does.
        slots=pb2_trace.objects(stage, area, spot, script=script,
                                upto=start['frame']),
        frames=frames,
    )


def want(rows):
    """Where the view stood and what the cartridge put out, one per step."""
    out = []
    for r in rows[1:]:
        out.append((r['cam'],
                    sorted((b['slot'], b['type'], b['rec'], b['x'], b['y'])
                           for b in r['born'] if 'rec' in b)))
    return out


def check(name, script, stage, area, tmp, spot, frames, drag=False):
    P = pb2_trace.P
    P.ROMPOKE = list(P.IMMORTAL) if drag else []
    if drag:
        pin, far, near = (PIN_DOWN if V.Area(stage, area).vertical
                          else PIN_ALONG)
        P.FREEZE = [(pin, far, 0), (pin, near, P.IN_LEVEL + frames // 2)]
    else:
        P.FREEZE = []
    try:
        return _check(script, stage, area, tmp, spot, frames)
    finally:
        P.ROMPOKE = []
        P.FREEZE = []


def _check(script, stage, area, tmp, spot, frames):
    rows = V.logic_frames(V.ordinary(pb2_trace.trace(
        script, frames, stage=stage, area=area, spot=spot)))
    rows = rows[:-1][V.SETTLE:]
    if len(rows) < 2:
        return 0, 0, None
    w = want(rows)
    got = run_engine(script_for(rows, stage, area, spot, script),
                     os.path.join(tmp, 's.json'))
    for i, expect in enumerate(w):
        have = got[i] if i < len(got) else None
        if have != expect:
            return None, None, (i + 1, expect, have)
    return len(w), sum(len(x[1]) for x in w), None


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
    tmp = pb2_trace.P.scratch('spawnverify')
    ran = bad = steps = births = 0
    for stage, area in targets:
        spot = V.spot_for(stage, area)
        if spot is None or not V.settled(stage, area, spot):
            continue
        # The scan is a walk of the level's list, so what tests it is the view
        # travelling far.  The button scripts are short, but the four that only
        # lean on one direction are given as long as the whole area takes.
        scripts = [(n, s, V.FRAMES, False) for n, s in
                   V.random_scripts(n_random, seed + 31 * (stage * 16 + area))]
        scripts.append(('drag', [(0, '-')], DRAG, True))
        for name, script, frames, drag in scripts:
            ran += 1
            n, b, diff = check(name, script, stage, area, tmp, spot, frames,
                               drag)
            label = '%d:%-2d %-12s' % (stage, area, name)
            if diff is None:
                steps += n
                births += b
                print('%s ok   %d steps %d born' % (label, n, b))
            else:
                bad += 1
                print('%s DIFF at step %d' % (label, diff[0]))
                print('    game   %s' % (diff[1],))
                print('    engine %s' % (diff[2],))
            sys.stdout.flush()
    pb2_trace.P.sweep(tmp)
    print('%d of %d scripts differ, %d steps, %d births matched'
          % (bad, ran, steps, births))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
