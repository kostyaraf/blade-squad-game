"""Decode Power Blade 2 level geometry straight out of the ROM.

Format, proven against the running game (screen 2 of stage 0 reproduces
CIRAM page 1 rows 0-19 byte for byte):

  bank pair per stage   $DFD8[stage] & $0F
  four pointer tables   $DE31 $DE3F $DE4D $DE5B, 7 words each, indexed by
                        stage.  Each word is the ADDRESS of a word inside the
                        level bank pair, so there are two indirections.

      p1  collision classes   one byte per block
      p2  block definitions   16 bytes = 4x4 tile numbers, ROW major
                              (byte r*4+c), 32x32 px            ($6C/$6D)
      p3  area table          one word per area -> a list of screen indices
      p4  screen table        one word per screen -> screen data ($70/$71)

  A screen is 8 blocks wide, row major.  Its height is 5 blocks (40 bytes,
  256x160 px, horizontally scrolling areas) or 8 blocks (64 bytes, 256x256 px,
  vertically scrolling areas); the size is the gap to the next screen pointer.

  Row builder  $DBDE: PPUADDR = $2000 + $73*32, screen[($73>>2 &7)*8 + bc],
                      block bytes ($73&3)*4 .. +3   -> 32 tiles
  Col builder  $DB42: screen[...] stepping 8, block bytes ($73&3)+0,4,8,12
  Screen pick  $E0B9: A = camera screen; area_list[A] -> screen index;
                      $70/$71 = screen_table[idx]
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom

STAGE_PAIR_TBL = 0xDFD8
PTR_TABLES     = (0xDE31, 0xDE3F, 0xDE4D, 0xDE5B)
NSTAGES        = 7
BLOCK_BYTES    = 16
SCREEN_W       = 8               # blocks across, always


class PB2Levels:
    def __init__(self, path="Power Blade 2 (USA).nes"):
        self.rom = Rom(path)
        self.b14 = self.rom.bank(14)

    def _b14(self, addr, n=1):
        o = addr - 0xC000
        return self.b14[o:o + n]

    def stage_pair(self, stage):
        return self._b14(STAGE_PAIR_TBL + stage, 1)[0] & 0x0F

    def stage_pointers(self, stage):
        pair = self.stage_pair(stage)
        data = self.rom.bank(pair) + self.rom.bank(pair + 1)     # $8000-$BFFF
        def word(a):
            o = a - 0x8000
            return data[o] | (data[o + 1] << 8)
        out = []
        for t in PTR_TABLES:
            slot = self._b14(t + stage * 2, 2)
            out.append(word(slot[0] | (slot[1] << 8)))
        return pair, data, out

    # -- one stage -----------------------------------------------------------
    def stage(self, stage):
        pair, data, (p_coll, p_block, p_area, p_scr) = self.stage_pointers(stage)
        at = lambda a: a - 0x8000
        w  = lambda a: data[at(a)] | (data[at(a) + 1] << 8)

        nblocks = (p_block and (p_scr - p_block) // BLOCK_BYTES) or 0
        blocks  = [data[at(p_block) + i * 16: at(p_block) + i * 16 + 16]
                   for i in range(nblocks)]
        coll    = list(data[at(p_coll): at(p_coll) + nblocks])

        # A pointer table runs until the LOWEST address it points at, so grow
        # it one entry at a time and stop as soon as the table would collide
        # with the data it references.
        def table(base):
            out, limit = [], 0xFFFF
            while base + len(out) * 2 < limit:
                v = w(base + len(out) * 2)
                if not 0x8000 <= v < 0xC000:
                    break
                limit = min(limit, v)
                out.append(v)
            return out
        sptr = table(p_scr)
        aptr = table(p_area)

        # screen sizes come from the gaps; the last screen ends where the area
        # table begins (the two regions are laid out back to back)
        bounds = sorted(sptr) + [p_area]
        size   = {}
        for i, a in enumerate(sorted(sptr)):
            size[a] = bounds[i + 1] - a
        screens = []
        for a in sptr:
            # only two sizes exist; a bigger gap just means unused padding
            n = 40 if size[a] < 64 else 64
            screens.append(dict(addr=a, w=SCREEN_W, h=n // SCREEN_W,
                                data=list(data[at(a):at(a) + n])))

        # area lists: consecutive, the last one ends at the end of the region
        area_end = self._region_end(stage, p_area)
        abounds  = sorted(aptr) + [area_end]
        alists   = []
        for a in aptr:
            i = abounds.index(a)
            lst = list(data[at(a):at(abounds[i + 1])])
            # the list that happens to sit last in the bank has no following
            # pointer to bound it, so stop at the first impossible screen index
            for k, v in enumerate(lst):
                if v >= len(sptr):
                    lst = lst[:k]
                    break
            alists.append(lst[:16])

        return dict(stage=stage, pair=pair, data=data,
                    p_coll=p_coll, p_block=p_block, p_area=p_area, p_scr=p_scr,
                    nblocks=nblocks, blocks=blocks, collision=coll,
                    screens=screens, areas=alists)

    def _region_end(self, stage, p_area):
        """The area lists run to the start of the next stage's data in the
        same bank pair, or to $C000 for the last stage in a pair."""
        pair = self.stage_pair(stage)
        cands = [0xC000]
        for s in range(NSTAGES):
            if self.stage_pair(s) != pair:
                continue
            _, _, ptrs = self.stage_pointers(s)
            cands += [p for p in ptrs if p > p_area]
        return min(cands)

    # -- rendering -----------------------------------------------------------
    def screen_tiles(self, st, si):
        """32 x (h*4) tile numbers: grid[row][col]."""
        s = st['screens'][si]
        grid = [[0] * 32 for _ in range(s['h'] * 4)]
        for br in range(s['h']):
            for bc in range(SCREEN_W):
                b = s['data'][br * SCREEN_W + bc]
                blk = st['blocks'][b] if b < st['nblocks'] else bytes(16)
                for r in range(4):
                    for c in range(4):
                        grid[br * 4 + r][bc * 4 + c] = blk[r * 4 + c]
        return grid

    def area_tiles(self, st, ai):
        """One area laid out left to right (horizontal) as a tile grid."""
        idxs = st['areas'][ai]
        parts = [self.screen_tiles(st, i) for i in idxs if i < len(st['screens'])]
        if not parts:
            return []
        h = max(len(p) for p in parts)
        return [sum((p[r] if r < len(p) else [0] * 32 for p in parts), [])
                for r in range(h)]


if __name__ == '__main__':
    lv = PB2Levels(sys.argv[1] if len(sys.argv) > 1 else "Power Blade 2 (USA).nes")
    for s in range(NSTAGES):
        st = lv.stage(s)
        hs = sorted({sc['h'] for sc in st['screens']})
        print(f"stage {s}: pair {st['pair']:2d} "
              f"coll=${st['p_coll']:04X} blocks=${st['p_block']:04X}({st['nblocks']}) "
              f"screens=${st['p_scr']:04X}({len(st['screens'])}, heights {hs}) "
              f"areas=${st['p_area']:04X}({len(st['areas'])})")
        for i, a in enumerate(st['areas']):
            print(f"    area {i}: {len(a)} screens {[f'{x:02X}' for x in a]}")
