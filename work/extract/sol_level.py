#!/usr/bin/env python3
"""Export Solbrain's levels.

Solbrain lays a stage out as a 16x16 grid of rooms, each room 256x256 px, and
builds the picture through four levels of indirection: room -> screen ->
block -> metatile -> tile.  All four are kept, because the game's own
destructible scenery works by swapping one metatile for another and only
makes sense in those terms.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_SOL, outdir, write_json, TOOLS            # noqa: E402
sys.path.insert(0, TOOLS)
import sol_levels as S                                           # noqa: E402


def stage_obj(st):
    rooms = [[(None if v is None else v) for v in row] for row in st.room_map]
    groups, missing = {}, []
    for g, v in st.object_groups.items():
        if 'objects' not in v:
            # The decoder could not follow this group's pointer.  Say so
            # rather than exporting an empty room that looks finished.
            missing.append(g)
            continue
        groups[str(g)] = [dict(kind=o['kind'], gate=o['dir_gate'],
                               param=o['param'], x=o['x'], y=o['y'])
                          for o in v['objects']]
    return dict(
        stage=st.stage,
        start=dict(x=st.start_x, y=st.start_y),
        camera=dict(x_min=st.cam_x_min, x_end=st.cam_x_end,
                    y_min=st.cam_y_min, y_end=st.cam_y_end),
        chr=list(st.chr_banks),
        music=st.music,
        palette=list(st.palette),
        # metatile -> the four 8x8 tiles, stored column major (tileX*2+tileY)
        quads=[list(q) for q in st.quads],
        # bit7,6 palette; bit5 has an alternate state; bits4..0 collision
        props=list(st.props),
        alt=list(st.alt),
        # block -> four metatiles, column major (halfX*2 + halfY)
        blocks=[list(b) for b in st.blocks],
        # screen -> 8x8 blocks, row major
        screens=[[list(row) for row in s] for s in st.screens],
        rooms=rooms,
        room_objects={str(k): v for k, v in st.room_objects.items()},
        object_groups=groups,
        object_groups_unread=missing,
    )


def export():
    rom = S.Rom(ROM_SOL)
    d = outdir('sol', 'levels')
    index = []
    for s in range(S.N_STAGES):
        st = S.Stage(rom, s)
        used = len(st.used_rooms())
        obj = stage_obj(st)
        size = write_json(os.path.join(d, 'stage%d.json' % s), obj)
        index.append(dict(stage=s, rooms=used, screens=st.n_screens,
                          blocks=st.n_blocks, metatiles=st.n_metatiles,
                          object_groups_unread=len(obj['object_groups_unread'])))
        miss = obj['object_groups_unread']
        print('stage %2d  %3d metatiles  %3d blocks  %2d screens  %2d rooms  %6d bytes%s'
              % (s, st.n_metatiles, st.n_blocks, st.n_screens, used, size,
                 '   UNREAD object groups: %s' % miss if miss else ''))
    write_json(os.path.join(d, 'index.json'),
               dict(stages=index, room_px=S.ROOM_PX,
                    units_per_px=S.UNITS_PER_PX,
                    collision_bits={str(k): v
                                    for k, v in S.COLLISION_BITS.items()}))


if __name__ == '__main__':
    export()
