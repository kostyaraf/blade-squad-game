#!/usr/bin/env python3
"""Э6.3.6 acceptance, part two: the water that swings must be heard swinging.

One place asks: `$D1E0`, `$25`, inside `$D1CD` -- and only for a kind six
area.  Kind nine swings on the same routine but jumps past the asking at
`$D1D5`, so its water moves in silence.  `$1C AND #$17` covers four bits, not
five, so the asking falls on one picture in sixteen and not in twenty-four.

The harness is `verify_water`': the engine is told nothing but the picture
count and whether the level is being played, and must answer with the line the
water has climbed to.  Here it must also ask for what the cartridge asked for,
picture for picture.  `$25` is asked for nowhere else in the game, so the
stream is picked apart by the number alone.
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
import verify_water as W                                     # noqa: E402

MINE = {0x25}
# The two sorts that swing: six is heard, nine is not.
SWING = (0x06, 0x09)


def _say(nums):
    return ' '.join('%02X' % n for n in nums) or '-'


def check(stage, area, tmp):
    spot = V.settled_spot(stage, area)
    # $1A held at five and $27 at three -- the level's own step that plays it,
    # and ordinary play.  An area opened out of turn walks out of both after
    # thirty pictures or so, and the water only moves while it is in them: the
    # one kind six area in the game ($1:5) gives two askings that way and
    # sixteen this.  Neither byte is the water's own, and both are handed to
    # the engine out of the recording, so holding them changes nothing about
    # what is on trial.
    pb2_trace.P.FREEZE = [(0x1A, 5, pb2_trace.P.IN_LEVEL),
                          (0x27, 3, pb2_trace.P.IN_LEVEL)]
    try:
        rows = pb2_trace.trace([(2, '-')], W.FRAMES, stage=stage, area=area,
                               spot=spot, pokes=((0x1A, 5),))
    finally:
        pb2_trace.P.FREEZE = []
    rows = W._played(rows[1:], stage, area)
    if len(rows) < 8:
        return None, 0, 'not ordinary play'
    start, rest = rows[0], rows[1:]
    cfg = {'stage': stage, 'area': area, 'noise': True,
           'water': start['w_line'], 'flow': start['w_flow'],
           'draw': start['w_draw'], 'still': start['w_still'],
           'grip': start['w_grip'],
           'frames': [{'clock': r['clock'], 'mode': r['mode'],
                       'live': r['w_live']} for r in rest]}
    path = os.path.join(tmp, 'wave.json')
    open(path, 'w').write(json.dumps(cfg))
    r = subprocess.run([W.GODOT, '--path', W.GAME, '--headless', '--',
                        '--water=' + path], capture_output=True, text=True,
                       timeout=V.ENGINE_WAIT)
    got = []
    for line in r.stdout.split('\n'):
        head, bar, say = line.strip().partition('|')
        if not bar or not head.split():
            continue
        f = head.split()
        if len(f) != 3 or not f[0].isdigit():
            continue
        got.append((int(f[0]),
                    [] if say.strip() == '-'
                    else [int(x, 16) for x in say.split()]))
    if not got:
        sys.stderr.write(r.stdout[-2000:] + r.stderr[-2000:])
        return None, 0, 'the engine said nothing'
    judged = 0
    for i, want in enumerate(rest):
        if i >= len(got):
            break
        line, said = got[i]
        if line != want['w_line']:
            return None, judged, ('the water itself parted at picture %d: '
                                  'engine %d, cartridge %d'
                                  % (i + 1, line, want['w_line']))
        theirs = [n for n, _s, _b, _sl in want['asks'] if n in MINE]
        mine = [n for n in said if n in MINE]
        judged += len(theirs)
        if theirs != mine:
            return None, judged, ('the sound parted at picture %d: engine %s, '
                                  'cartridge %s'
                                  % (i + 1, _say(mine), _say(theirs)))
    return len(got), judged, None


def main():
    targets = []
    for stage, area in V.areas_from_index():
        rec = W.area_record(stage, area)
        if rec is not None and int(rec.get('kind', 0)) in SWING:
            targets.append((stage, area, int(rec['kind'])))
    for a in sys.argv[1:]:
        if a.startswith('--areas='):
            want = {tuple(int(x) for x in p.split(':'))
                    for p in a.split('=')[1].split(',')}
            targets = [t for t in targets if (t[0], t[1]) in want]
    tmp = pb2_trace.P.scratch('wavenoise')
    ran = bad = steps = judged = 0
    try:
        for stage, area, kind in targets:
            n, said, why = check(stage, area, tmp)
            if why == 'not ordinary play':
                print('%d:%-2d kind %d  not played out of turn -- left out'
                      % (stage, area, kind))
                continue
            ran += 1
            if why is not None:
                bad += 1
                print('%d:%-2d kind %d  FAILED -- %s'
                      % (stage, area, kind, why))
            else:
                steps += n
                judged += said
                print('%d:%-2d kind %d  ok   %d pictures, %d judged'
                      % (stage, area, kind, n, said))
            sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d pictures, %d requests of the water judged' % (steps, judged))
    print('%d of %d areas differ from what the cartridge asked for'
          % (bad, ran))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
