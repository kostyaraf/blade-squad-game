#!/usr/bin/env python3
"""Assemble the full PB3 cartridge.

The engine indexes fifteen different tables with the stage number, so the
stage number stays what it always was: 0..6.  Extra levels arrive as extra
*worlds* instead -- the map screen gains an up/down axis, and changing world
swaps the level tables the engine reads, which live in work RAM.

    world 0   Power Blade 2, untouched
    world 1   Solbrain stages 1-5, converted
    world 2   Solbrain stages 6, 7, 14, 16, converted
"""
import sys, os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'work/pb3'))
sys.path.insert(0, os.path.join(ROOT, 'work/tools'))
import build
from sol2pb2 import convert, area_record, vert_area_record
from pb2_pack import pack
import crates

WORLDS = {1: [0, 1, 2, 3, 4],
          2: [5, 6, 13, 15]}
FIRST_BANK = 18                     # payload is 16/17; levels take pairs upward
# Every converted stage gets its own 4 KB background pattern table, built so
# that a tile number means exactly one collision class (see sol2pb2.tile_map).
# Solbrain's raw CHR is no longer read at run time, so its half of the cartridge
# is free to hold these.
FIRST_CHR = 128


def main(out=os.path.join(ROOT, 'work/build/PB3.nes')):
    img = build.add_runtime(build.build())
    bank, chr_base = FIRST_BANK, FIRST_CHR
    for world in sorted(WORLDS):
        for node, n in enumerate(WORLDS[world]):
            st, screens, areas, bands = convert(n)
            # Solbrain's destructible blocks, as Power Blade 2 breakables
            # (work/re/pb3_crates.md)
            crate_recs = crates.apply(st, screens, areas, bands)
            # a vertical area's screen list carries one spare entry for the
            # engine's prefetch, so its screen count is one less than the list
            recs = [(vert_area_record(len(a) - 1, chr_base // 2,
                                      (chr_base + 2) // 2, 0x19, 0x13,
                                      0x80 | node, 0x70) if k == 'v' else
                     area_record(len(a), chr_base // 2, (chr_base + 2) // 2,
                                 0x19, 0x13, 0x80 | node, 0x70))
                    for k, a in zip(st.pb3_kinds, areas)]
            blob, _ = pack(screens, areas, recs, collision=st.pb3_collision,
                           spawns=st.pb3_spawns, entries=st.pb3_entries)
            img.put_chr(chr_base, st.pb3_chr)
            build.add_level(img, blob, bank)
            build.set_stage(img, world, node, bank)
            build.set_palette(img, world, node, st.palette[:16])
            build.set_area_count(img, world, node, len(areas))
            build.set_crates(img, world, node, crate_recs)
            print(f"world {world} node {node} <- solbrain stage {n:2d}  bank {bank:2d}  "
                  f"{len(screens):3d} screens  {len(areas):2d} areas  {len(blob):5d} bytes"
                  f"  chr {chr_base}..{chr_base + 3}"
                  f"  {sum(len(a) for a in st.pb3_crates):2d} breakable")
            bank += 2
            chr_base += 4
    build.write(img, out)
    return img


if __name__ == '__main__':
    main(*sys.argv[1:])
