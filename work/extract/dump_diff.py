#!/usr/bin/env python3
"""Show the frames around the first disagreement, side by side."""
import json
import os
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'tools'))
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402


def main():
    name = sys.argv[1]
    at = int(sys.argv[2])
    span = int(sys.argv[3]) if len(sys.argv) > 3 else 8
    stage, area = 0, 0
    spot = None
    seed = 7
    for a in sys.argv[4:]:
        if a.startswith('--area='):
            stage, area = (int(x) for x in a.split('=')[1].split(':'))
            seed = 7 + 31 * (stage * 16 + area)
            spot = V.spot_for(stage, area)
    scripts = dict(V.SCRIPTS + V.random_scripts(40, seed))
    rows = pb2_trace.trace(scripts[name], V.FRAMES, stage=stage, area=area,
                           spot=spot)
    start = rows[0]
    for i, r in enumerate(rows):
        if (r['area'] != start['area'] or r['stage'] != start['stage']
                or r['mode'] != start['mode']):
            rows = rows[:i]
            break
    cfg = dict(
        stage=start['stage'], area=start['area'],
        x=V.s24(start['xh'], start['xp'], start['xf']),
        y=V.s24(start['yh'], start['yp'], start['yf']),
        cam=start['cam'], state=start['state'], sub=start['sub'],
        pose=start['pose'], face_left=bool(start['face'] & 0x40),
        fall=start['fall'],
        frames=[dict(pad=r['pad'], hit=r['hit'], cam=r['cam'],
                     shots=r['shots'], lim=r['lim'])
                for r in rows[1:]],
    )
    got = V.run_engine(cfg, os.path.join(tempfile.mkdtemp(), 'r.json'))
    for i in range(max(0, at - span), min(len(rows) - 1, at + span)):
        r = rows[i + 1]
        g = got[i] if i < len(got) else [0] * 8
        print('%3d pad=%02X hit=%02X cam=%4d shots=%d | '
              'game x=%8.3f y=%8.3f vx=%7.3f vy=%7.3f st=%02X sub=%2d p=%02X'
              % (i + 1, r['pad'], r['hit'], r['cam'], r['shots'],
                 V.s24(r['xh'], r['xp'], r['xf']) / 256.0,
                 V.s24(r['yh'], r['yp'], r['yf']) / 256.0,
                 r['vx'] / 256.0, r['vy'] / 256.0, r['state'], r['sub'],
                 r['pose']))
        print('                                    | '
              'engn x=%8.3f y=%8.3f vx=%7.3f vy=%7.3f st=%02X sub=%2d p=%02X'
              % (g[0] / 256.0, g[1] / 256.0, g[2] / 256.0, g[3] / 256.0,
                 g[4], g[5], g[6]))


if __name__ == '__main__':
    main()
