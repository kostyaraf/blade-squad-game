#!/usr/bin/env python3
"""Play every converted area with a search, and report which ones can be won.

A held direction is not a player.  This drives the real engine a third of a
second at a time: from the state the area is in, it tries every button
combination a player would try, keeps the ones that got furthest, and goes on
from there.  An area is won when the engine itself moves on to the next stage.
"""
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '../../tools'))
import probe                                            # noqa: E402
import warp                                             # noqa: E402
import pb2port                                          # noqa: E402

NSOL = 20
STEP = 24                       # frames per decision
STEPS = 60                      # decisions per attempt
BEAM = 4
HOLD = 14                       # frames the jump button is held


def actions(travel, vertical):
    """Everything a player would try from where he stands.

    In a shaft the way out is up or down, and which side of the shaft he has
    to be on is not something the area's own travel direction tells: both
    sides are tried, with and without the climb key and with and without a
    jump.  On a floor the way out is one direction, so the far fewer things
    worth trying are led by it.
    """
    if vertical:
        fwd = 'DOWN' if travel > 0 else 'UP'
        out = [('climb', fwd, ''), ('climb-l', fwd + ',LEFT', ''),
               ('climb-r', fwd + ',RIGHT', ''),
               ('jump', '', 'A'), ('jump-l', 'LEFT', 'A'),
               ('jump-r', 'RIGHT', 'A'),
               ('climb-jump', fwd, 'A'),
               ('cj-l', fwd + ',LEFT', 'A'), ('cj-r', fwd + ',RIGHT', 'A'),
               ('walk-l', 'LEFT', ''), ('walk-r', 'RIGHT', ''),
               ('wait', '', '')]
        return out
    d = 'RIGHT' if travel > 0 else 'LEFT'
    o = 'LEFT' if travel > 0 else 'RIGHT'
    return [('walk', d, ''), ('run-jump', d, 'A'), ('jump', '', 'A'),
            ('back', o, ''), ('back-jump', o, 'A'), ('wait', '', ''),
            ('up', 'UP,' + d, ''), ('down', 'DOWN,' + d, ''),
            ('slide', d + ',DOWN', 'A')]


def _run(state, frame, keys, jump, out_state, ram, tmp):
    inp = os.path.join(tmp, 'a.inp')
    with open(inp, 'w') as f:
        held = ','.join(x for x in (keys, jump) if x) or '-'
        f.write('%d %s\n' % (frame, held))
        if jump:
            f.write('%d %s\n' % (frame + HOLD, keys or '-'))
    last = frame + STEP
    subprocess.run([warp.EMU, warp.ROM, '-loadstate', state, '-input', inp,
                    '-frames', str(last + 1), '-savestate',
                    '%s@%d' % (out_state, last), '-ramdump', ram],
                   check=True, capture_output=True)
    d = open(ram, 'rb').read()
    return {'x': (d[0x80] | (d[0x81] << 8)) // 16,
            'y': (d[0x82] | (d[0x83] << 8)) // 16,
            'stage': d[0x55], 'hp': d[0x5C5], 'mode': d[0x02]}


def base_state(st, tmp):
    """The area, loaded and under the player's control."""
    boot = warp._boot(warp.SCRATCH)
    out = os.path.join(tmp, 'base.st')
    ram = os.path.join(tmp, 'base.ram')
    at = probe.E + 10 + probe.CONTROL
    subprocess.run([warp.EMU, warp.ROM, '-loadstate', boot, '-frames',
                    str(at + 1), '-poke', '0055=%02X@%d' % (st, probe.E + 5),
                    '-poke', '0002=35@%d' % (probe.E + 6),
                    '-savestate', '%s@%d' % (out, at), '-ramdump', ram],
                   check=True, capture_output=True)
    d = open(ram, 'rb').read()
    return out, at, {'x': (d[0x80] | (d[0x81] << 8)) // 16,
                     'y': (d[0x82] | (d[0x83] << 8)) // 16,
                     'stage': d[0x55], 'hp': d[0x5C5], 'mode': d[0x02]}


def play(st, area, tmp, steps=STEPS, verbose=False):
    os.makedirs(tmp, exist_ok=True)
    base, frame, start = base_state(st, tmp)
    if start['stage'] != st:
        return {'ok': False, 'why': 'did not load', 'best': 0, 'path': []}
    axis = 'y' if area.vertical else 'x'
    sign = 1 if area.travel > 0 else -1
    acts = actions(area.travel, area.vertical)
    beam = [{'st': base, 'f': frame, 'p': 0, 'r': start, 'path': [], 'n': 0}]
    best = 0
    # Where he has already been.  Without this the search stands still: in a
    # shaft nothing a step can do moves him towards the way out, every attempt
    # scores the same, and the same three squares win the tie for ever.
    been = {(start['x'] // 16, start['y'] // 16)}
    for step in range(steps):
        cand = []
        for bi, b in enumerate(beam):
            for ai, (name, keys, jump) in enumerate(acts):
                s = os.path.join(tmp, 's%d_%d_%d.st' % (step, bi, ai))
                ram = os.path.join(tmp, 's%d_%d_%d.ram' % (step, bi, ai))
                r = _run(b['st'], b['f'], keys, jump, s, ram, tmp)
                if r['stage'] != st:
                    return {'ok': True, 'why': 'out -> stage %d' % r['stage'],
                            'best': best, 'path': b['path'] + [name],
                            'steps': step + 1}
                if r['hp'] == 0:
                    continue
                p = (r[axis] - start[axis]) * sign
                cand.append({'st': s, 'f': b['f'] + STEP, 'p': p, 'r': r,
                             'path': b['path'] + [name], 'n': ai})
        if not cand:
            return {'ok': False, 'why': 'died', 'best': best,
                    'path': beam[0]['path']}
        cand.sort(key=lambda c: ((c['r']['x'] // 16, c['r']['y'] // 16) in been,
                                 -c['p']))
        seen, beam = set(), []
        for c in cand:                          # keep distinct spots
            k = (c['r']['x'] // 8, c['r']['y'] // 8)
            if k in seen:
                continue
            seen.add(k)
            been.add((c['r']['x'] // 16, c['r']['y'] // 16))
            beam.append(c)
            if len(beam) == BEAM:
                break
        best = max(best, beam[0]['p'])
        if verbose:
            print('   %2d %-10s x=%4d y=%4d best=%d'
                  % (step, beam[0]['path'][-1], beam[0]['r']['x'],
                     beam[0]['r']['y'], best))
    return {'ok': False, 'why': 'ran out of time', 'best': best,
            'path': beam[0]['path']}


def main():
    only = [int(x) for x in sys.argv[1:] if x.isdigit()]
    verbose = '-v' in sys.argv
    areas, _ = pb2port.build()
    tmp = '/tmp/pb3/auto'
    shutil.rmtree(tmp, ignore_errors=True)
    won = []
    lost = []
    for i, a in enumerate(areas):
        st = NSOL + i
        if only and st not in only:
            continue
        w, h, _c = a.grid
        ext = (h if a.vertical else w) * 16
        r = play(st, a, tmp, verbose=verbose)
        pct = min(100, r['best'] * 100 // max(1, ext))
        (won if r['ok'] else lost).append(st)
        print('%2d %-9s %-4s %5dpx  %-22s got %3d%%  %s'
              % (st, a.name, 'vert' if a.vertical else 'horz', ext, r['why'],
                 pct, ' '.join(r['path'][:14])), flush=True)
        shutil.rmtree(tmp, ignore_errors=True)
    print('%d won, %d lost: %s' % (len(won), len(lost),
                                   ' '.join(str(x) for x in lost)))


if __name__ == '__main__':
    main()
