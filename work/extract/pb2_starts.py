#!/usr/bin/env python3
"""Where the engine may put the hero when an area is opened on its own.

The cartridge only ever enters an area from the one before it, and where it
stands him is the business of the walk-on code that Э3.1 has still to bring
over.  Until then a playable build has to start him somewhere, and the honest
somewhere is the one the acceptance checks already use: `settled_spot` walks
the places on the screen the area opens on, nearest the middle first, and keeps
the first at which a hero left alone for sixty pictures neither falls nor is
hurt.  So this is not the cartridge's own doorway -- it is a place in the room
that the cartridge itself proves is a place to stand.

Area nought of stage nought is the exception: that one the game really does
open by itself, so its own numbers are taken.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402
from common import outdir, write_json                        # noqa: E402


def export():
    out = {}
    for stage, area in V.areas_from_index():
        row = pb2_trace.trace([(2, '-')], 4, stage=stage, area=area)[0]
        key = '%d:%d' % (stage, area)
        if (stage, area) == (0, 0):
            out[key] = dict(x=row['xp'], y=row['yp'], cam=row['cam'],
                            own=True)
            continue
        spot = V.settled_spot(stage, area)
        if spot is None:
            continue
        out[key] = dict(x=spot[0], y=spot[1], cam=row['cam'], own=False)
        sys.stderr.write('%s %s\n' % (key, out[key]))
    write_json(os.path.join(outdir('pb2'), 'starts.json'), out)
    return out


if __name__ == '__main__':
    export()
