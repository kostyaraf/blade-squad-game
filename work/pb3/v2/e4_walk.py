#!/usr/bin/env python3
"""Walk every converted area and report what happened.

Not a substitute for playing them -- a script cannot climb a shaft -- but it
finds the three failures that make an area unusable: the hero cannot move at
all, the hero falls out of the world, or the hero is hurt by standing still.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '../../tools'))
import probe                                            # noqa: E402
import pb2port                                          # noqa: E402

NSOL = 20
FRAMES = 700


def script(area):
    """Hold the way out, and jump often enough to clear a ledge.

    A shaft cannot be climbed by a script, so a vertical area is walked both
    ways instead, with UP or DOWN held so that any ladder is taken.
    """
    if area.vertical:
        lean = 'UP' if area.travel < 0 else 'DOWN'
        ways = [lean + ',RIGHT', lean + ',LEFT']
    else:
        ways = ['RIGHT' if area.travel > 0 else 'LEFT']
    out = []
    half = (FRAMES - probe.CONTROL) // len(ways)
    for n, key in enumerate(ways):
        base = probe.CONTROL + n * half
        out.append((base, key))
        for f in range(base + 30, base + half, 45):
            out.append((f, key + ',A'))
            out.append((f + 12, key))
            # and a slide, for the corridors Power Blade 2 built one block high
            out.append((f + 22, key + ',DOWN'))
            out.append((f + 25, key + ',DOWN,A'))
            out.append((f + 29, key))
    return sorted(out)


def main():
    scratch = sys.argv[1] if len(sys.argv) > 1 else '/tmp/pb3'
    only = [int(x) for x in sys.argv[2:]]
    areas, _ = pb2port.build()
    bad = 0
    for i, a in enumerate(areas):
        st = NSOL + i
        if only and st not in only:
            continue
        w, h, _c = a.grid
        ext = (h if a.vertical else w) * 16
        axis = '0083-0083' if a.vertical else '0081-0081'
        r = probe.go(st, script(a), FRAMES, scratch, tag='walk', watch=axis)
        first = probe.E + 10 + probe.CONTROL
        v = [v for f, _a, v in r['watch'] if f >= first]
        span = (max(v) - min(v)) * 16 if v else 0
        notes = []
        left = r['stage'] != st
        if left:
            notes.append('out -> stage %d' % r['stage'])
        elif span * 4 < ext:
            notes.append('only %d%% of the way' % (span * 100 // ext))
        if r['hp'] == 0:
            notes.append('dead')
        elif r['hp'] < 8:
            notes.append('hp %d' % r['hp'])
        good = left or (span * 4 >= ext)
        if not good:
            bad += 1
        if not notes:
            notes.append('ok')
        print('%2d %-9s %-4s %5dpx  went %4dpx  end (%4d,%4d)  %s'
              % (st, a.name, 'vert' if a.vertical else 'horz', ext, span,
                 r['x'], r['y'], ', '.join(notes)))
    print('%d of %d areas need a look' % (bad, len(areas)))


if __name__ == '__main__':
    main()
