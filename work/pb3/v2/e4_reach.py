#!/usr/bin/env python3
"""Can the exit be reached on foot?  A verdict on geometry alone.

The search that plays the areas for real is the truth, but it gives up when it
runs out of time, and then there is no telling whether the level is impossible
or the search was.  This walks the same collision the cartridge holds -- every
standing spot the player can get to by walking, falling and jumping -- and says
whether any of them is past the plane the area's exit sits on.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '../../tools'))
import pb2port                                          # noqa: E402

NSOL = 20


def verdict(a):
    w = pb2port.Walk(a)
    x, y = a.start
    c0, r0 = x // 16, y // 16               # world rows: the band's own shift
    spots = w.reachable(c0, r0)
    if not spots:
        return None, 0, set()
    out = []
    for kind, coord, _t in a.exits:
        u = coord // 16
        if a.vertical:
            hit = [s for s in spots if (s[1] >= u if a.travel > 0 else s[1] <= u)]
        else:
            hit = [s for s in spots if (s[0] >= u if a.travel > 0 else s[0] <= u)]
        out.append((kind, u, len(hit)))
    return out, len(spots), spots


def main():
    only = [int(x) for x in sys.argv[1:]]
    areas, _ = pb2port.build()
    bad = []
    for i, a in enumerate(areas):
        st = NSOL + i
        if only and st not in only:
            continue
        ex, n, _s = verdict(a)
        if ex is None:
            bad.append(st)
            print('%2d %-9s NOWHERE TO STAND at %s' % (st, a.name, a.start))
            continue
        ok = any(h for _k, _u, h in ex)
        if not ok:
            bad.append(st)
        print('%2d %-9s %-4s %4d spots  exits %s  %s'
              % (st, a.name, 'vert' if a.vertical else 'horz', n,
                 ' '.join('%s@%d:%d' % e for e in ex),
                 'ok' if ok else 'UNREACHABLE'))
    print('%d of %d areas cannot be finished on geometry: %s'
          % (len(bad), len(areas), ' '.join(str(x) for x in bad)))


if __name__ == '__main__':
    main()
