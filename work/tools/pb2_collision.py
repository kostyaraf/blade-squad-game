"""Power Blade 2 terrain collision: read it out of the ROM, and build new ones.

Everything here is derived from the game's own code; see
`work/re/pb2_collision.md` for the proof and the address citations.

Lookup chain (all of it lives in bank 14 / bank pair 6+7):

    $DDE1  maps bank pair 6/7, then
    $DE23[stage]          7 words in bank 14  -> a word inside pair 6/7
       -> word            the per-stage table of area records
          -> [$9C]        one word per area
             -> record    6 bytes, copied to $7B..$80 by the loop at $DE16

    record[0:2] -> $7B/$7C   tile-number thresholds, $FF terminated
    record[2:4] -> $7D/$7E   terrain TYPE per threshold band (the full byte)
    record[4:6] -> $7F/$80   collision CLASS per threshold band (0..3)

`$7F` feeds the 2-bit-per-16x16-cell cache at `$0680` that the fast collision
path reads; `$7D` feeds the slow path ($F42C) that the terrain-effect routine
in bank 9 ($B316) uses, and it carries the extra states (conveyor, liquid)
that do not survive the 2-bit squeeze.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom

ROM_DEFAULT   = "Power Blade 2 (USA).nes"
COLL_PTR_TBL  = 0xDE23      # bank 14, 7 words, indexed by stage
COLL_BANK     = 6           # LDY #$36 at $DDE3 -> bank 6 at $8000, 7 at $A000
NSTAGES       = 7
TERM          = 0xFF        # threshold-list terminator

# --- the collision buffer at $0680 -----------------------------------------
BUF_BASE = 0x0680
BUF_LEN  = 128              # 2 nametable pages x 16 rows x 4 bytes
PAGE_LEN = 64

# class -> the byte the collision query actually returns ($F5A9 / $DDDD)
CLASS_VALUE = (0x00, 0x01, 0x80, 0x02)

CLASS_NAME = {
    0: "passable",
    1: "ladder",
    2: "solid",
    3: "instant death",
}

# terrain-type byte -> short name.  See pb2_collision.md for the proof.
TYPE_NAME = {
    0x00: "air",
    0x01: "ladder",
    0x02: "instant death",
    0x03: "liquid, deep (sinks you)",
    0x04: "liquid, surface (splash)",
    0x05: "current, pushes right (+0.75/frame)",
    0x06: "current, pushes left (-0.75/frame)",
    0x80: "solid",
    0x87: "solid conveyor, pushes right (+0.5/frame)",
    0x88: "solid conveyor, pushes left (-0.5/frame)",
}


def type_to_class(typ):
    """How the ROM's own $7F table is derived from its $7D table.

    Verified against all 17 distinct table sets in the cartridge.
    """
    if typ & 0x80:
        return 2
    if typ == 0x01:
        return 1
    if typ == 0x02:
        return 3
    return 0


# ---------------------------------------------------------------------------
def lookup(thresholds, values, tile):
    """Bit-exact port of the search at $DCD2-$DCEB.

    `thresholds` may or may not carry its $FF terminator; both work.
    """
    if tile == 0:                       # $DCCE: LDA $10 / BEQ -> class 0
        return 0
    y = 0
    while y < len(thresholds):
        v = thresholds[y]
        if v == TERM:                   # $DCD4
            break
        if v > tile:                    # $DCDC (BCS, after BEQ takes ==)
            break
        y += 1
    y -= 1                              # $DCE6 DEY
    if y < 0:                           # $DCE7 BMI -> 0
        return 0
    return values[y]


def build_tables(tile_to_class):
    """Shortest threshold/value pair that reproduces `tile_to_class`.

    `tile_to_class` maps tile number -> value (0..3 for the class table, or a
    full terrain-type byte for the $7D table); missing tiles mean 0.
    Returns (thresholds, values); `thresholds` ends with $FF.

    The game's decoder is a step function: tiles below the first threshold get
    0, and every threshold starts a band that runs to the next threshold.  So
    the minimal encoding is simply "emit a threshold wherever the value
    changes", starting from an implicit 0.
    """
    full = [int(tile_to_class.get(t, 0)) & 0xFF for t in range(256)]
    if full[0] != 0:
        raise ValueError("tile $00 always reads as class 0 ($DCCE); "
                         "it cannot be given a non-zero value")
    thr, val, cur = [], [], 0
    for t in range(1, 256):
        if full[t] == cur:
            continue
        if t == TERM:
            raise ValueError("tile $FF cannot start a band: $FF terminates "
                             "the threshold list")
        thr.append(t)
        val.append(full[t])
        cur = full[t]
    return bytes(thr + [TERM]), bytes(val)


# ---------------------------------------------------------------------------
class PB2Collision:
    def __init__(self, rom_path=ROM_DEFAULT):
        self.rom  = Rom(rom_path)
        self.b14  = self.rom.bank(14)
        self.data = self.rom.bank(COLL_BANK) + self.rom.bank(COLL_BANK + 1)

    # -- raw access ---------------------------------------------------------
    def _b14w(self, addr):
        o = addr - 0xC000
        return self.b14[o] | (self.b14[o + 1] << 8)

    def _at(self, addr):
        return addr - 0x8000

    def _w(self, addr):
        o = self._at(addr)
        return self.data[o] | (self.data[o + 1] << 8)

    def _bytes(self, addr, n):
        o = self._at(addr)
        return bytes(self.data[o:o + n])

    # -- the pointer chain --------------------------------------------------
    def stage_slot(self, stage):
        """The word in bank 14 that names this stage's area-record table."""
        return self._b14w(COLL_PTR_TBL + stage * 2)

    def area_table(self, stage):
        """(address, [record address per area]).

        The table is self-describing: it runs until the lowest address it
        points at, exactly like every other pointer table in this engine.
        """
        base, ptrs, limit, i = self._w(self.stage_slot(stage)), [], 0xFFFF, 0
        while base + i * 2 < limit:
            p = self._w(base + i * 2)
            limit = min(limit, p)
            ptrs.append(p)
            i += 1
        return base, ptrs

    def record(self, stage, area=0):
        """The 6-byte record that $DE16 copies into $7B..$80."""
        _, ptrs = self.area_table(stage)
        addr = ptrs[area]
        r = self._bytes(addr, 6)
        return dict(addr=addr,
                    thr=r[0] | (r[1] << 8),
                    typ=r[2] | (r[3] << 8),
                    cls=r[4] | (r[5] << 8))

    # -- the two tables -----------------------------------------------------
    def tables(self, stage, area=0):
        """(thresholds, values) -- values are the 2-bit collision classes.

        `thresholds` includes its $FF terminator, so len(thresholds) ==
        len(values) + 1.
        """
        rec = self.record(stage, area)
        n = rec['typ'] - rec['thr']                 # incl. the $FF terminator
        thr = self._bytes(rec['thr'], n)
        assert thr[-1] == TERM, "threshold list is not $FF terminated"
        val = self._bytes(rec['cls'], n - 1)
        return thr, val

    def type_table(self, stage, area=0):
        """The $7D table: the full terrain-type byte per threshold band."""
        rec = self.record(stage, area)
        n = rec['typ'] - rec['thr']
        return self._bytes(rec['typ'], n - 1)

    def tile_class(self, stage, tile, area=0):
        thr, val = self.tables(stage, area)
        return lookup(thr, val, tile)

    def tile_type(self, stage, tile, area=0):
        thr, _ = self.tables(stage, area)
        return lookup(thr, self.type_table(stage, area), tile)

    # -- convenience --------------------------------------------------------
    def sets(self, stage):
        """The distinct table sets a stage uses, and which areas use each."""
        _, ptrs = self.area_table(stage)
        out = []
        for a in range(len(ptrs)):
            rec = self.record(stage, a)
            key = (rec['thr'], rec['typ'], rec['cls'])
            for s in out:
                if s['key'] == key:
                    s['areas'].append(a)
                    break
            else:
                out.append(dict(key=key, areas=[a], rec=rec,
                                thr=self.tables(stage, a)[0],
                                cls=self.tables(stage, a)[1],
                                typ=self.type_table(stage, a)))
        return out

    def ranges(self, stage, area=0):
        """[(lo, hi, terrain type, class)] over all 256 tile numbers."""
        thr, val = self.tables(stage, area)
        typ = self.type_table(stage, area)
        out, lo = [], 0
        cur = (self.tile_type(stage, 0, area), self.tile_class(stage, 0, area))
        for t in range(1, 256):
            k = (lookup(thr, typ, t), lookup(thr, val, t))
            if k != cur:
                out.append((lo, t - 1) + cur)
                lo, cur = t, k
        out.append((lo, 255) + cur)
        return out

    def roundtrip(self, stage, area=0):
        """Rebuild both tables from the decoded mapping and prove identical
        behaviour for all 256 tile numbers."""
        thr, val = self.tables(stage, area)
        typ = self.type_table(stage, area)
        cmap = {t: lookup(thr, val, t) for t in range(256)}
        tmap = {t: lookup(thr, typ, t) for t in range(256)}
        nthr, nval = build_tables(cmap)
        tthr, ttyp = build_tables(tmap)
        ok_c = all(lookup(nthr, nval, t) == cmap[t] for t in range(256))
        ok_t = all(lookup(tthr, ttyp, t) == tmap[t] for t in range(256))
        return dict(ok=ok_c and ok_t,
                    orig_len=len(thr), rebuilt_len=len(nthr),
                    orig_type_len=len(thr), rebuilt_type_len=len(tthr),
                    thresholds=nthr, values=nval,
                    type_thresholds=tthr, types=ttyp)

    # -- the $0680 buffer ---------------------------------------------------
    @staticmethod
    def buf_index(page, ntx, nty):
        """Byte index into $0680 for a nametable pixel position.

        From $F566-$F575:  index = page*$40 | ((y>>4)&15)*4 | (x>>6)
        """
        return (page & 1) * PAGE_LEN + (((nty >> 4) & 15) << 2) + ((ntx >> 6) & 3)

    @staticmethod
    def buf_shift(ntx):
        """Bit position of the 16x16 cell inside its byte ($F58B-$F59B):
        quadrant 0 lives in bits 7-6, quadrant 3 in bits 1-0."""
        return 6 - 2 * ((ntx >> 4) & 3)

    @staticmethod
    def read_cell(buf, page, ntx, nty):
        i = PB2Collision.buf_index(page, ntx, nty)
        return (buf[i] >> PB2Collision.buf_shift(ntx)) & 3

    def build_page(self, tile_grid, stage, area=0, rows=None):
        """64 bytes of collision for one nametable page.

        `tile_grid[row][col]` is a 32-column grid of background tile numbers.
        Each 16x16 cell takes its class from its TOP-LEFT 8x8 tile, which is
        what the two fill loops write ($DB42 uses block rows 0 and 2, $DC00
        skips odd nametable rows via $09 and uses block columns 0 and 2).
        """
        thr, val = self.tables(stage, area)
        rows = rows if rows is not None else min(len(tile_grid), 32)
        out = bytearray(PAGE_LEN)
        for r in range(min(rows // 2, 16)):
            for colq in range(4):
                b = 0
                for q in range(4):
                    t = tile_grid[r * 2][colq * 8 + q * 2]
                    b |= lookup(thr, val, t) << (6 - 2 * q)
                out[r * 4 + colq] = b
        return bytes(out)


# ---------------------------------------------------------------------------
def _fmt(bs):
    return ' '.join('%02X' % b for b in bs)


def verify(rom_path, ram_path, vram_path):
    """Predict the live $0680 buffer from the ROM and diff it.

        work/tools/nesemu <rom> ... -ramdump X.ram -vram X.vram@<frame>
        python3 work/tools/pb2_collision.py <rom> --verify X.ram X.vram
    """
    from pb2_levels import PB2Levels
    from vram import Vram

    c   = PB2Collision(rom_path)
    lv  = PB2Levels(rom_path)
    ram = open(ram_path, 'rb').read()[:0x800]
    v   = Vram(vram_path)

    stage, area = ram[0x53], ram[0x9C]
    axis = ram[0x97]
    print("ramdump: stage $%02X area $%02X camera $%02X:%02X axis $%02X"
          % (stage, area, ram[0x66], ram[0x67], axis))
    rec = c.record(stage, area)
    print("ROM record $%04X: $7B/$7C=$%04X $7D/$7E=$%04X $7F/$80=$%04X"
          % (rec['addr'], rec['thr'], rec['typ'], rec['cls']))
    print("live  $7B/$7C=$%02X%02X $7D/$7E=$%02X%02X $7F/$80=$%02X%02X  -> %s"
          % (ram[0x7C], ram[0x7B], ram[0x7E], ram[0x7D], ram[0x80], ram[0x7F],
             "MATCH" if (ram[0x7B] | ram[0x7C] << 8) == rec['thr']
                     and (ram[0x7D] | ram[0x7E] << 8) == rec['typ']
                     and (ram[0x7F] | ram[0x80] << 8) == rec['cls'] else "MISMATCH"))

    st = lv.stage(stage)
    live = ram[BUF_BASE:BUF_BASE + BUF_LEN]
    # a horizontal area shows 20 tile rows of level, the rest is the HUD
    prows = 20 if axis == 0 else 30
    total = bad = 0
    for page in (0, 1):
        ct = [[v.ciram[page * 1024 + r * 32 + col] for col in range(32)]
              for r in range(30)]
        hit = None
        for si in st['areas'][area] if area < len(st['areas']) else []:
            if si >= len(st['screens']):
                continue
            g = lv.screen_tiles(st, si)
            n = min(len(g), prows)
            if all(g[r][col] == ct[r][col] for r in range(n) for col in range(32)):
                hit = si
                break
        if hit is None:
            print("CIRAM page %d: no screen of this area matches (stale fill)"
                  % page)
            continue
        pred = c.build_page(lv.screen_tiles(st, hit), stage, area, rows=prows)
        got  = live[page * PAGE_LEN:(page + 1) * PAGE_LEN]
        n = (prows // 2) * 4
        diff = [i for i in range(n) if pred[i] != got[i]]
        total += n
        bad += len(diff)
        print("CIRAM page %d = ROM screen $%02X : %d/%d bytes match%s"
              % (page, hit, n - len(diff), n,
                 "" if not diff else "  differ at %s" % diff))
        for r in range(n // 4):
            print("   row %2d  pred %s | live %s"
                  % (r, _fmt(pred[r * 4:r * 4 + 4]), _fmt(got[r * 4:r * 4 + 4])))
    print("TOTAL: %d/%d predicted bytes correct" % (total - bad, total))
    return 0 if bad == 0 and total else 1


def verify_ciram(rom_path, ram_path, vram_path, rows=10):
    """Weaker but axis-independent check: predict $0680 from the tiles that
    are actually sitting in CIRAM.  Proves the tile->class tables and the
    buffer layout without needing to re-derive the camera mapping."""
    from vram import Vram
    c   = PB2Collision(rom_path)
    ram = open(ram_path, 'rb').read()[:0x800]
    v   = Vram(vram_path)
    stage, area = ram[0x53], ram[0x9C]
    thr, val = c.tables(stage, area)
    print("ramdump: stage $%02X area $%02X axis $%02X ; checking %d cell rows"
          % (stage, area, ram[0x97], rows))
    bad = tot = 0
    for i in range(BUF_LEN):
        page, r, colq = i >> 6, (i >> 2) & 15, i & 3
        if r >= rows:
            continue
        b = ram[BUF_BASE + i]
        for q in range(4):
            tot += 1
            got = (b >> (6 - 2 * q)) & 3
            t = v.ciram[page * 1024 + (r * 2) * 32 + colq * 8 + q * 2]
            want = lookup(thr, val, t)
            if got != want:
                bad += 1
                print("  page %d row %2d col %2d: buffer %d, tile $%02X -> %d"
                      % (page, r, colq * 4 + q, got, t, want))
    print("TOTAL: %d/%d cells match" % (tot - bad, tot))
    return 0 if bad == 0 else 1


def main(argv):
    rom = argv[1] if len(argv) > 1 else ROM_DEFAULT
    if '--verify-ciram' in argv:
        i = argv.index('--verify-ciram')
        rows = int(argv[i + 3]) if len(argv) > i + 3 else 10
        return verify_ciram(rom, argv[i + 1], argv[i + 2], rows)
    if '--verify' in argv:
        i = argv.index('--verify')
        return verify(rom, argv[i + 1], argv[i + 2])
    c = PB2Collision(rom)
    allok = True
    for stage in range(NSTAGES):
        base, ptrs = c.area_table(stage)
        print("=" * 74)
        print("stage %d  slot $%04X -> area table $%04X (%d areas)"
              % (stage, c.stage_slot(stage), base, len(ptrs)))
        for s in c.sets(stage):
            rec = s['rec']
            print("  areas %-22s record $%04X" %
                  (','.join(str(a) for a in s['areas']), rec['addr']))
            print("      thresholds $%04X (%2d) : %s"
                  % (rec['thr'], len(s['thr']), _fmt(s['thr'])))
            print("      types      $%04X (%2d) : %s"
                  % (rec['typ'], len(s['typ']), _fmt(s['typ'])))
            print("      classes    $%04X (%2d) : %s"
                  % (rec['cls'], len(s['cls']), _fmt(s['cls'])))
            a = s['areas'][0]
            for lo, hi, typ, cls in c.ranges(stage, a):
                print("        $%02X-$%02X  type $%02X  class %d  %s"
                      % (lo, hi, typ, cls,
                         TYPE_NAME.get(typ, '?') if typ != 0 or cls != 0
                         else 'air'))
            rt = c.roundtrip(stage, a)
            allok &= rt['ok']
            print("        round trip: %s (thresholds %d -> %d, types %d -> %d)"
                  % ("OK" if rt['ok'] else "FAIL",
                     rt['orig_len'], rt['rebuilt_len'],
                     rt['orig_type_len'], rt['rebuilt_type_len']))
    print("=" * 74)
    print("round trip over every area of every stage:", end=' ')
    for stage in range(NSTAGES):
        _, ptrs = c.area_table(stage)
        for a in range(len(ptrs)):
            allok &= c.roundtrip(stage, a)['ok']
    print("OK" if allok else "FAIL")
    return 0 if allok else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv))
