#!/usr/bin/env python3
"""Export Power Blade 2's levels.

Everything keeps the shape the ROM gave it -- blocks of 4x4 tiles, screens of
8 blocks across, an area as an ordered list of screens.  The engine walks the
same chain the console walked, which is what makes the result checkable: a
picture built from this data can be laid over a screenshot of the real game.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, outdir, write_json, TOOLS            # noqa: E402
sys.path.insert(0, TOOLS)
from pb2_levels import PB2Levels, NSTAGES                        # noqa: E402
from pb2_collision import PB2Collision                           # noqa: E402
from pb2_palettes import PB2Palettes                             # noqa: E402
import pb2_spawns                                                # noqa: E402

# The five ways a tile can behave, named by the byte the engine keeps in its
# terrain buffer (see work/re/pb2_collision.md).
TERRAIN = {0x00: 'air', 0x01: 'ladder', 0x02: 'spike', 0x03: 'deep',
           0x04: 'surface', 0x05: 'flow_right', 0x06: 'flow_left',
           0x80: 'solid', 0x87: 'belt_right', 0x88: 'belt_left'}


def collision_map(coll, stage, area):
    """Terrain byte for every tile number, as a flat 256-entry list.

    The engine answers this question with a threshold search at run time; a
    list of 256 answers says exactly the same thing and costs nothing to read.
    """
    return [coll.tile_type(stage, t, area) for t in range(256)]


def collision_classes(coll, stage, area):
    """Collision class 0..3 for every tile number.

    This is what the player physics actually reads: the console keeps two bits
    per 16x16 cell in its buffer at $0680 and turns them back into a byte
    through the table at $F5A9 -- air, ladder, wall, hazard.  The class of a
    cell is the class of its TOP-LEFT 8x8 tile.
    """
    return [coll.tile_class(stage, t, area) for t in range(256)]


# $D6CD, read by $D6BC: for each stage, the number of areas that are walked
# through.  When the door's own count reaches it there is no next area and the
# stage's boss room is opened instead.
LAST_AREA = [7, 8, 7, 7, 10, 14, 12]


def export():
    lv = PB2Levels(ROM_PB2)
    coll = PB2Collision(ROM_PB2)
    pal = PB2Palettes(ROM_PB2)
    rom = pb2_spawns.Rom()
    d = outdir('pb2', 'levels')
    index = []
    for s in range(NSTAGES):
        st = lv.stage(s)
        _tbl, spawn_areas = pb2_spawns.stage_lists(rom, s)
        n_areas = min(len(st['areas']), pal.n_areas(s))
        areas = []
        for a in range(n_areas):
            rec = pal.area_record(s, a)
            spawns = [dict(along=r[0], type=r[1], across=r[2], flags=r[3])
                      for r in (spawn_areas[a][1] if a < len(spawn_areas) else [])]
            areas.append(dict(
                screens=st['areas'][a],
                vertical=rec[0] & 1,
                music=rec[1],
                cam_screen=rec[3], cam_sub=rec[4],
                cam_last=rec[5], cam_last_sub=rec[6],
                # $F04C: where the walk-on stands the hero when the area is
                # opened -- on the first step of a stage, through a door, and
                # again every time he is brought back after a death.
                start=pal.area_start(s, a),
                # $8551: where the door at the end of this area is drawn open.
                door=pal.area_door(s, a),
                chr=pal.area_chr_full(s, a),
                chr_bg_phases=pal.area_bg_chr_phases(s, a),
                palette=pal.area_palette(s, a),
                terrain=collision_map(coll, s, a),
                terrain_class=collision_classes(coll, s, a),
                spawns=spawns,
            ))
        obj = dict(
            stage=s,
            blocks=[list(b) for b in st['blocks']],     # 4x4 tiles, row major
            attributes=st['collision'],                 # one attribute byte per block
            screens=[dict(w=sc['w'], h=sc['h'], blocks=sc['data'])
                     for sc in st['screens']],
            areas=areas,
        )
        size = write_json(os.path.join(d, 'stage%d.json' % s), obj)
        index.append(dict(stage=s, areas=len(areas), screens=len(st['screens']),
                          blocks=st['nblocks'],
                          # $D6CD: how many areas are walked before the boss.
                          # The door at the end of the last one does not open
                          # another area, it opens the boss room.
                          walk=LAST_AREA[s],
                          # $843D: where the thing of type $03 draws the way
                          # into the boss's room at the end of the stage.
                          boss_door=pal.boss_door(s)))
        print('stage %d  %3d blocks  %2d screens  %2d areas  %6d bytes'
              % (s, st['nblocks'], len(st['screens']), len(areas), size))
    write_json(os.path.join(d, 'index.json'),
               dict(stages=index,
                    terrain_names={'%02X' % k: v for k, v in TERRAIN.items()},
                    # $F5A9: what the two cached bits mean to the physics
                    class_bytes=[0x00, 0x01, 0x80, 0x02]))


if __name__ == '__main__':
    export()
