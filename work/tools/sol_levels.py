#!/usr/bin/env python3
"""Standalone level decoder for `Tokkyuu Shirei Solbrain (Japan)` (NES, MMC3).

Everything here is derived from the game's own code; see
work/re/sol_level_format.md for the ROM address that proves each rule.

Quick reference of the data path (all addresses are CPU addresses):

    $55                        = stage index, 0..19
    $C965 + stage              = even PRG bank of the 16K pair holding the
                                 stage's level data          (code $E6C7)
    $E6E0 + stage*2            = pointer to the 20-byte area header  ($E6CF)
    area header byte 0         = byte offset into the tileset table  ($E642)
    $800D + that offset        = 12 bytes of pointers:
                                 +0 quad table   -> zp $10/$11
                                 +2 block table  -> zp $12/$13
                                 +4 screen table -> zp $14/$15
                                 +6 room map     -> zp $1E/$1F
                                 +8 prop table   -> zp $16/$17
                                 +10 alt table   -> zp $18/$19

    room index  = (camY>>12)*16 + (camX>>12)          ($EFA0 / $D09C)
    screen      = roommap[room index]
    block       = screens[screen*64 + blockrow*8 + blockcol]   (row major 8x8)
    metatile    = blocks[block*4 + halfX*2 + halfY]            (column major 2x2)
    tile        = quads[metatile*4 + tileX*2 + tileY]          (column major 2x2)
    property    = props[metatile]      bit7,6 = palette, bit5 = has alt state,
                                       bits4..0 = collision class
    if (prop & $20) and $0540[m>>3] & ($80>>(m&7)):  metatile = alt[metatile]

World coordinates everywhere in the engine are pixels*16 (16 sub-units per
pixel); one room is 256x256 px = 8x8 blocks = 16x16 metatiles = 32x32 tiles.

Usage:
    sol_levels.py ROM                       -> all 20 stages as JSON on stdout
    sol_levels.py ROM --stage 3             -> one stage
    sol_levels.py ROM --outdir DIR          -> DIR/stage_NN.json each
    sol_levels.py ROM --verify DUMP [DUMP..] -> check against `nesemu -vram`
                                                dumps: tile numbers, palettes,
                                                CHR bank and palette
    sol_levels.py ROM --render DUMP PREFIX   -> PREFIX_game.png (from the real
                                                CIRAM) and PREFIX_rom.png (from
                                                ROM level data only), plus the
                                                count of differing sub-pixels
"""
import json
import struct
import sys

# ---------------------------------------------------------------------------
# ROM access
# ---------------------------------------------------------------------------


class Rom:
    def __init__(self, path):
        raw = open(path, 'rb').read()
        assert raw[:4] == b'NES\x1a', 'not an iNES image'
        self.prg_n, self.chr_n = raw[4], raw[5]
        self.prg = raw[16:16 + self.prg_n * 16384]
        self.chr = raw[16 + self.prg_n * 16384:][:self.chr_n * 8192]

    def bank(self, i):
        """One 8K PRG bank."""
        return self.prg[i * 8192:(i + 1) * 8192]

    def pair(self, even):
        """A 16K bank pair as it appears at $8000-$BFFF."""
        return self.bank(even) + self.bank(even + 1)

    def fixed(self):
        """Banks 14+15 as they appear at $C000-$FFFF."""
        return self.bank(14) + self.bank(15)


# ---------------------------------------------------------------------------
# constants proved in the disassembly
# ---------------------------------------------------------------------------

N_STAGES = 20
STAGE_BANK_TBL = 0xC965      # $C965 + stage  -> even PRG bank      (code $E6C9)
STAGE_HDR_PTRS = 0xE6E0      # $E6E0 + 2*stage -> area header ptr   (code $E6D3)
AREA_HDR_LEN = 20            # bytes consumed by $E708..$E777
TILESET_TBL = 0x800D         # in the stage's bank pair             (code $E647)
TILESET_REC = 12
PAL_BANK_PAIR = 10           # palettes live in PRG pair 10/11      (measured)
OBJ_BANK_PAIR = 8            # object lists live in PRG pair 8/9    (code $AE86)
OBJ_STAGE_TBL = 0xAFAD       # $AFAD + 4*stage                      (code $AE86)
BITMASK_TBL = 0xD136         # $80,$40,..,$01                       (code $D132)

ROOM_PX = 256                # one room is 256x256 px               ($EFA0)
PLAYFIELD_H = 224            # scanlines the level owns; 16 are status bar
UNITS_PER_PX = 16            # world coords are pixels*16           ($EA9C)

# names for the collision-class bits, from the code that tests them
COLLISION_BITS = {
    0x10: 'solid',        # $8DC5 BMI  (bit7 of prop<<3)
    0x08: 'mod3',         # $8DC9 CMP #$60 / $A3B7 AND #$40
    0x04: 'passable',     # $8DCD AND #$20
    0x02: 'flag1',
    0x01: 'flag0',
}


class Bank:
    """A 16K PRG pair addressed with CPU addresses $8000-$BFFF."""

    def __init__(self, data, base=0x8000):
        self.data = data
        self.base = base

    def __getitem__(self, addr):
        return self.data[addr - self.base]

    def word(self, addr):
        return self[addr] | self[addr + 1] << 8

    def slice(self, addr, n):
        return self.data[addr - self.base:addr - self.base + n]


# ---------------------------------------------------------------------------
# the decoder
# ---------------------------------------------------------------------------


class Stage:
    def __init__(self, rom, stage):
        self.rom = rom
        self.stage = stage
        fixed = Bank(rom.fixed(), 0xC000)

        # $E6C7: LDX $55 / LDA $C965,X / JSR $C92C   -> even bank of the pair
        self.bank_pair = fixed[STAGE_BANK_TBL + stage]
        # $E6CF: LDA $55 / ASL / TAY / LDA $E6E0,Y   -> area header pointer
        self.hdr_addr = fixed.word(STAGE_HDR_PTRS + stage * 2)
        hdr = fixed.slice(self.hdr_addr, AREA_HDR_LEN)
        self.header_bytes = list(hdr)

        lvl = Bank(rom.pair(self.bank_pair))
        self.lvl = lvl

        # ---- area header fields, in the order $E708 reads them --------------
        self.tileset_index = hdr[0]                 # $E644 -> X
        self.start_x = hdr[1] | hdr[2] << 8         # $80/$81  ($E70C)
        self.start_y = hdr[3] | hdr[4] << 8         # $82/$83  ($E71D)
        self.cam_x_min = hdr[5] << 8                # $38/$39  ($E730)
        self.cam_x_end = hdr[6] << 8                # $3A/$3B  ($E735)
        self.cam_y_min = hdr[7] << 8                # $3C/$3D  ($E73A)
        self.cam_y_end = hdr[8] << 8                # $3E/$3F  ($E73F)
        self.palette_ptr = hdr[9] | hdr[10] << 8    # $20/$21  ($E744)
        self.chr_banks = list(hdr[11:17])           # $40..$45 ($E74E..$E767)
        self.unknown_17_18 = [hdr[17], hdr[18]]     # -> $92/$93, immediately
        self.music = hdr[19]                        # compared with $2E ($E776)

        # ---- tileset record -------------------------------------------------
        t = TILESET_TBL + self.tileset_index
        self.p_quads = lvl.word(t + 0)      # -> $10/$11
        self.p_blocks = lvl.word(t + 2)     # -> $12/$13
        self.p_screens = lvl.word(t + 4)    # -> $14/$15
        self.p_roommap = lvl.word(t + 6)    # -> $1E/$1F
        self.p_props = lvl.word(t + 8)      # -> $16/$17
        self.p_alt = lvl.word(t + 10)       # -> $18/$19

        self._size_tables()
        self._read_tables()
        self._read_palette()
        self._read_objects()

    # -- table extents ------------------------------------------------------
    # The tables are stored back to back, so the distance to the next pointer
    # above a table gives its length exactly.  Where no pointer follows we
    # fall back on the largest index actually referenced.
    def _next_ptr_above(self, addr):
        cands = [p for p in (self.p_quads, self.p_blocks, self.p_screens,
                             self.p_roommap, self.p_props, self.p_alt)
                 if p > addr]
        return min(cands) if cands else None

    def _size_tables(self):
        nxt = self._next_ptr_above(self.p_roommap)
        n = min(256, nxt - self.p_roommap) if nxt else 256
        self.roommap_len = n
        self.roommap_rows = min(16, -(-n // 16))   # partial last row counts

        nxt = self._next_ptr_above(self.p_screens)
        self.n_screens = (nxt - self.p_screens) // 64 if nxt else None

        nxt = self._next_ptr_above(self.p_quads)
        self.n_metatiles = (nxt - self.p_quads) // 4 if nxt else None

        nxt = self._next_ptr_above(self.p_props)
        n = (nxt - self.p_props) if nxt else None
        if n and (self.n_metatiles is None or n < self.n_metatiles):
            self.n_metatiles = n

    def _read_tables(self):
        lvl = self.lvl

        # room map: 16 wide, indexed room = (roomY*16 + roomX)   ($EFA0/$D09C)
        self.room_map = []
        for y in range(16):
            row = []
            for x in range(16):
                i = y * 16 + x
                row.append(lvl[self.p_roommap + i] if i < self.roommap_len
                           else None)
            self.room_map.append(row)

        ns = self.n_screens
        if ns is None:
            ns = max(v for r in self.room_map for v in r if v is not None) + 1
            self.n_screens = ns
        # screens: 64 bytes, row major 8 columns x 8 rows of block ids
        self.screens = []
        for s in range(ns):
            g = lvl.slice(self.p_screens + s * 64, 64)
            self.screens.append([list(g[r * 8:r * 8 + 8]) for r in range(8)])

        nb = max((b for scr in self.screens for row in scr for b in row),
                 default=0) + 1
        self.n_blocks = nb
        # blocks: 4 bytes, column major 2x2 of metatile ids
        self.blocks = [list(lvl.slice(self.p_blocks + b * 4, 4))
                       for b in range(nb)]

        nm = max((m for blk in self.blocks for m in blk), default=0) + 1
        if self.n_metatiles is None or self.n_metatiles < nm:
            self.n_metatiles = nm
        nm = self.n_metatiles
        # metatiles: 4 tiles column major, plus property and alternate id
        self.quads = [list(lvl.slice(self.p_quads + m * 4, 4))
                      for m in range(nm)]
        self.props = [lvl[self.p_props + m] for m in range(nm)]
        self.alt = [lvl[self.p_alt + m] for m in range(nm)]

    def _read_palette(self):
        pb = Bank(self.rom.pair(PAL_BANK_PAIR))
        self.palette = list(pb.slice(self.palette_ptr, 32))

    # -- object / enemy placement ------------------------------------------
    def _read_objects(self):
        ob = Bank(self.rom.pair(OBJ_BANK_PAIR))
        e = OBJ_STAGE_TBL + self.stage * 4
        self.obj_room_tbl = ob.word(e)       # -> $9A/$9B, indexed by room id
        self.obj_group_tbl = ob.word(e + 2)  # -> $9C/$9D, 4 bytes per group

        # Every stage's two pointers are packed into one region, so the next
        # pointer above a table bounds it.  Without that bound the room table
        # runs into the neighbouring stage's data and invents rooms.
        allp = sorted({ob.word(OBJ_STAGE_TBL + k * 4 + o)
                       for k in range(N_STAGES) for o in (0, 2)})
        def limit(a, default):
            nxt = [p for p in allp if p > a]
            return min(nxt[0] - a, default) if nxt else default
        # A room id cannot exceed the room map itself, and that bound is what
        # separates a shared room table from the neighbouring list data.
        self.obj_room_tbl_len = min(limit(self.obj_room_tbl, 256),
                                    self.roommap_len, 256)
        # The group table is a run of 4-byte records; it ends at the first
        # record that cannot be one (count out of range, or a list pointer
        # outside the 16K window).
        n = 0
        cap = limit(self.obj_group_tbl, 1024) // 4
        while n < cap:
            ge = self.obj_group_tbl + n * 4
            c, lp = ob[ge], ob.word(ge + 2)
            if not (0 < c <= 64 and 0x8000 <= lp and lp + c * 6 <= 0xC000):
                break
            n += 1
        self.n_object_groups = n
        self.obj_group_tbl_len = n * 4

        self.room_objects = {}
        self.object_groups = {}
        for room in range(self.obj_room_tbl_len):
            g = ob[self.obj_room_tbl + room]
            if g == 0xFF:
                continue
            self.room_objects[room] = g
            if g in self.object_groups:
                continue
            ge = self.obj_group_tbl + g * 4
            if g >= self.n_object_groups:
                # Some stages share a room table with a sibling stage that has
                # more groups; ids past this stage's table are that sibling's.
                self.object_groups[g] = dict(table_addr='$%04X' % ge,
                                             out_of_range=True)
                continue
            count = ob[ge]
            listp = ob.word(ge + 2)
            # The group table is only as long as the stage actually uses; a
            # couple of stages share a room table with a sibling stage that
            # has more groups, so entries past the end are neighbouring data.
            bad = not (0 < count <= 64 and 0x8000 <= listp
                       and listp + count * 6 <= 0xC000)
            rec = dict(count=count, unknown1=ob[ge + 1],
                       table_addr='$%04X' % ge, list_addr='$%04X' % listp)
            if bad:
                rec['suspect'] = True          # not decoded: see the .md
                self.object_groups[g] = rec
                continue
            objs = []
            for k in range(count):
                r = ob.slice(listp + k * 6, 6)
                objs.append(dict(
                    kind=r[0] & 0x3F,          # index into the $0560 flags
                    dir_gate=(r[0] >> 6) & 3,  # $AEDF AND #$C0
                    param=r[1],
                    x=r[2] | r[3] << 8,
                    y=r[4] | r[5] << 8,
                    x_px=(r[2] | r[3] << 8) / UNITS_PER_PX,
                    y_px=(r[4] | r[5] << 8) / UNITS_PER_PX,
                    raw=['%02X' % b for b in r],
                ))
            rec['objects'] = objs
            self.object_groups[g] = rec

    # -- metatile resolution -------------------------------------------------
    def resolve(self, m, flags=None):
        """Apply the alternate-state substitution ($F056..$F065, $D0FF..$D113).

        `flags` is the game's $0540..$055F bitmap; the level loader fills it
        with $FF ($E77E), which is the state a freshly entered stage is in.
        """
        p = self.props[m]
        if p & 0x20:
            if flags is None:
                on = True
            else:
                on = bool(flags[m >> 3] & (0x80 >> (m & 7)))
            if on:
                return self.alt[m]
        return m

    # -- world queries -------------------------------------------------------
    def screen_at(self, room_x, room_y):
        if not (0 <= room_x < 16 and 0 <= room_y < 16):
            return None
        return self.room_map[room_y][room_x]

    def block_at(self, bx, by):
        """`bx`,`by` in 32x32-pixel block units over the whole 16x16 room grid."""
        s = self.screen_at(bx // 8, by // 8)
        if s is None or s >= len(self.screens):
            return None
        return self.screens[s][by % 8][bx % 8]

    def metatile_at(self, mx, my, flags=None):
        """`mx`,`my` in 16x16-pixel metatile units."""
        b = self.block_at(mx // 2, my // 2)
        if b is None or b >= len(self.blocks):
            return None
        m = self.blocks[b][(mx % 2) * 2 + (my % 2)]
        return self.resolve(m, flags)

    def tile_at(self, tx, ty, flags=None):
        """`tx`,`ty` in 8x8-pixel tile units.  Returns the CHR tile number."""
        m = self.metatile_at(tx // 2, ty // 2, flags)
        if m is None or m >= len(self.quads):
            return None
        return self.quads[m][(tx % 2) * 2 + (ty % 2)]

    def palette_at(self, mx, my, flags=None):
        m = self.metatile_at(mx, my, flags)
        return None if m is None else self.props[m] >> 6

    def collision_at(self, mx, my, flags=None):
        m = self.metatile_at(mx, my, flags)
        return None if m is None else self.props[m] & 0x1F

    # -- extents -------------------------------------------------------------
    def used_rooms(self):
        """Rooms that are part of the playable level.

        Seeds are the player's start room (area header b1..b4) and every room
        the object table names a group for (that table is indexed by exactly
        the same room id -- see $93B5 building $05EB and $AE9A reading it).
        From those we flood-fill 4-connected through room-map cells that hold
        a valid non-zero screen id.  Screen id 0 is the blank filler that the
        unused parts of the 16-wide map are padded with.
        """
        def ok(x, y):
            if not (0 <= x < 16 and 0 <= y < 16):
                return False
            s = self.room_map[y][x]
            return bool(s) and s < len(self.screens)

        seeds = {(room & 0x0F, room >> 4) for room in self.room_objects}
        seeds.add((self.start_x >> 12, self.start_y >> 12))
        seen = set(seeds)
        stack = [p for p in seeds]
        while stack:
            x, y = stack.pop()
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if (nx, ny) not in seen and ok(nx, ny):
                    seen.add((nx, ny))
                    stack.append((nx, ny))
        return seen

    def bbox(self):
        rooms = self.used_rooms()
        xs = [r[0] for r in rooms]
        ys = [r[1] for r in rooms]
        return min(xs), min(ys), max(xs), max(ys)

    # -- grids ---------------------------------------------------------------
    def grids(self, flags=None):
        x0, y0, x1, y1 = self.bbox()
        w_rooms, h_rooms = x1 - x0 + 1, y1 - y0 + 1
        tw, th = w_rooms * 32, h_rooms * 32
        mw, mh = w_rooms * 16, h_rooms * 16
        tiles, pal, coll, meta = [], [], [], []
        for ty in range(th):
            row = []
            for tx in range(tw):
                t = self.tile_at(x0 * 32 + tx, y0 * 32 + ty, flags)
                row.append(0 if t is None else t)
            tiles.append(''.join('%02X' % v for v in row))
        for my in range(mh):
            rp, rc, rm = [], [], []
            for mx in range(mw):
                m = self.metatile_at(x0 * 16 + mx, y0 * 16 + my, flags)
                if m is None:
                    rp.append(0)
                    rc.append(0)
                    rm.append(0)
                else:
                    rp.append(self.props[m] >> 6)
                    rc.append(self.props[m] & 0x1F)
                    rm.append(m)
            pal.append(''.join('%X' % v for v in rp))
            coll.append(''.join('%02X' % v for v in rc))
            meta.append(''.join('%02X' % v for v in rm))
        return dict(
            origin_room=[x0, y0],
            origin_px=[x0 * ROOM_PX, y0 * ROOM_PX],
            tile_w=tw, tile_h=th,
            tiles=tiles,           # one hex byte per 8x8 tile
            metatile_w=mw, metatile_h=mh,
            metatiles=meta,        # one hex byte per 16x16 metatile
            palettes=pal,          # one hex nibble (0-3) per 16x16 metatile
            collision=coll,        # one hex byte per 16x16 metatile
        )

    # -- serialisation -------------------------------------------------------
    def to_json(self):
        x0, y0, x1, y1 = self.bbox()
        return dict(
            stage=self.stage,
            prg_bank_pair=[self.bank_pair, self.bank_pair + 1],
            area_header=dict(
                addr='$%04X' % self.hdr_addr,
                raw=['%02X' % b for b in self.header_bytes],
                tileset_index=self.tileset_index,
                player_start=dict(x=self.start_x, y=self.start_y,
                                  x_px=self.start_x / UNITS_PER_PX,
                                  y_px=self.start_y / UNITS_PER_PX),
                camera_x=dict(min=self.cam_x_min, world_end=self.cam_x_end,
                              min_px=self.cam_x_min / UNITS_PER_PX,
                              max_px=(self.cam_x_end - 0x1000) / UNITS_PER_PX),
                camera_y=dict(min=self.cam_y_min, world_end=self.cam_y_end,
                              min_px=self.cam_y_min / UNITS_PER_PX,
                              max_px=(self.cam_y_end - 0x1000) / UNITS_PER_PX),
                palette_ptr='$%04X' % self.palette_ptr,
                chr_banks=self.chr_banks,
                music=self.music,
                bytes_17_18=self.unknown_17_18,
            ),
            chr=dict(
                bg_pattern_table=0x0000,
                mmc3_r0=self.chr_banks[0], mmc3_r1=self.chr_banks[1],
                bg_1k_banks=[self.chr_banks[0] & 0xFE,
                             (self.chr_banks[0] & 0xFE) + 1,
                             self.chr_banks[1] & 0xFE,
                             (self.chr_banks[1] & 0xFE) + 1],
                note='R1 ($0800-$0FFF) is re-written every few frames by the '
                     'per-stage scroll script in PRG pair 8/9; the header '
                     'value is the initial one.',
            ),
            palette=['%02X' % c for c in self.palette],
            tileset=dict(
                index=self.tileset_index,
                quads='$%04X' % self.p_quads,
                blocks='$%04X' % self.p_blocks,
                screens='$%04X' % self.p_screens,
                room_map='$%04X' % self.p_roommap,
                props='$%04X' % self.p_props,
                alt='$%04X' % self.p_alt,
                n_screens=self.n_screens,
                n_blocks=self.n_blocks,
                n_metatiles=self.n_metatiles,
                room_map_rows=self.roommap_rows,
            ),
            room_grid=dict(
                width=16, height=16,
                room_px=ROOM_PX,
                bbox_rooms=[x0, y0, x1, y1],
                map=[['%02X' % v if v is not None else None for v in row]
                     for row in self.room_map],
                used=sorted('%X%X' % (y, x) for x, y in self.used_rooms()),
            ),
            screens=[[['%02X' % b for b in row] for row in s]
                     for s in self.screens],
            blocks=[['%02X' % m for m in b] for b in self.blocks],
            metatiles=[dict(id=m,
                            tiles=['%02X' % t for t in self.quads[m]],
                            prop='%02X' % self.props[m],
                            palette=self.props[m] >> 6,
                            has_alt=bool(self.props[m] & 0x20),
                            collision='%02X' % (self.props[m] & 0x1F),
                            collision_names=[n for bit, n in
                                             COLLISION_BITS.items()
                                             if self.props[m] & bit],
                            alt='%02X' % self.alt[m])
                       for m in range(self.n_metatiles)],
            objects=dict(
                room_table='$%04X' % self.obj_room_tbl,
                room_table_len=self.obj_room_tbl_len,
                group_table='$%04X' % self.obj_group_tbl,
                group_count=self.n_object_groups,
                room_to_group={'%02X' % r: '%02X' % g
                               for r, g in sorted(self.room_objects.items())},
                groups={'%02X' % g: v
                        for g, v in sorted(self.object_groups.items())},
            ),
            grids=self.grids(),
        )


# ---------------------------------------------------------------------------
# verification against a `nesemu -vram` dump
# ---------------------------------------------------------------------------


class VramDump:
    """Minimal reader for the PB3VRAM1 dumps produced by work/tools/nesemu."""

    def __init__(self, path):
        d = open(path, 'rb').read()
        assert d[:8] == b'PB3VRAM1'
        self.frame = struct.unpack_from('<I', d, 8)[0]
        self.ciram = d[12:12 + 2048]
        self.pal = d[2060:2060 + 32]
        self.chr_banks = list(struct.unpack_from('<8H', d, 2348))
        self.mirror = d[2364]
        self.ppuctrl = d[2365]
        self.vreg = struct.unpack_from('<H', d, 2367)[0]
        self.fine_x = d[2369]
        self.ram = d[2382 + 240 * 16: 2382 + 240 * 16 + 2048]

    def nt_page(self, nt):
        if self.mirror == 0:            # horizontal
            return (0, 0, 1, 1)[nt]
        if self.mirror == 1:            # vertical
            return (0, 1, 0, 1)[nt]
        return nt & 1

    def nt_byte(self, nt, tx, ty):
        return self.ciram[self.nt_page(nt) * 1024 + ty * 32 + tx]

    def attr(self, nt, tx, ty):
        b = self.ciram[self.nt_page(nt) * 1024 + 0x3C0 + (ty // 4) * 8 + tx // 4]
        return (b >> ((((ty & 2)) + ((tx & 2) >> 1)) * 2)) & 3


def verify(rom, dump_path, verbose=True):
    v = VramDump(dump_path)
    stage = v.ram[0x55]
    st = Stage(rom, stage)
    flags = v.ram[0x540:0x560]
    cam_x = v.ram[0x30] | v.ram[0x31] << 8
    cam_y = v.ram[0x32] | v.ram[0x33] << 8
    cx, cy = cam_x // UNITS_PER_PX, cam_y // UNITS_PER_PX

    # 256x240 px of screen: 32 tile columns, plus one more only when the
    # camera sits mid-tile.  The extra column is off-screen otherwise and the
    # engine leaves it stale, so comparing it would be meaningless.
    ncol = 32 + (1 if cx % 8 else 0)
    nacol = 16 + (1 if cx % 16 else 0)
    # The level occupies the top 224 scanlines; the 16 below are the status
    # bar, which the engine draws with its own scroll into the nametable rows
    # the 30-row window has wrapped past.
    nrow = (cy + PLAYFIELD_H - 1) // 8 - cy // 8 + 1
    narow = (cy + PLAYFIELD_H - 1) // 16 - cy // 16 + 1
    bad_t = bad_a = tot_t = tot_a = 0
    first = []
    for R in range(cy // 8, cy // 8 + nrow):
        for C in range(cx // 8, cx // 8 + ncol):
            want = st.tile_at(C, R, flags)
            got = v.nt_byte((C >> 5) & 1, C & 31, R % 30)
            tot_t += 1
            if want != got:
                bad_t += 1
                if len(first) < 8:
                    first.append(('tile', C, R, want, got))
    # attributes: one entry per 16x16, but the nametable stores 32x32 cells;
    # compare at 16x16 granularity through the attribute lookup
    for R in range(cy // 16, cy // 16 + narow):
        for C in range(cx // 16, cx // 16 + nacol):
            want = st.palette_at(C, R, flags)
            tx, ty = (C * 2) & 31, (R * 2) % 30
            got = v.attr((C * 2 >> 5) & 1, tx, ty)
            tot_a += 1
            if want != got:
                bad_a += 1
                if len(first) < 16:
                    first.append(('attr', C, R, want, got))

    pal_ok = list(v.pal[:16]) == st.palette[:16]
    res = dict(dump=dump_path, frame=v.frame, stage=stage,
               camera_px=[cx, cy],
               tiles_checked=tot_t, tiles_wrong=bad_t,
               attrs_checked=tot_a, attrs_wrong=bad_a,
               bg_palette_matches=pal_ok,
               chr_r0_matches=(v.chr_banks[0] == (st.chr_banks[0] & 0xFE)),
               samples=first)
    if verbose:
        print(json.dumps(res, indent=1))
    return res


# ---------------------------------------------------------------------------
# rendering (proof by picture)
# ---------------------------------------------------------------------------


def synth_ciram(rom, dump_path):
    """Rebuild the visible part of CIRAM purely from ROM level data.

    Only rows that the level engine owns are replaced.  The 2 nametable rows
    outside the 30-row scrolling window carry the status bar, which is not
    level data, so those are left as the dump has them.
    """
    v = VramDump(dump_path)
    st = Stage(rom, v.ram[0x55])
    flags = v.ram[0x540:0x560]
    cam_x = (v.ram[0x30] | v.ram[0x31] << 8) // UNITS_PER_PX
    cam_y = (v.ram[0x32] | v.ram[0x33] << 8) // UNITS_PER_PX
    ci = bytearray(v.ciram)
    R0, C0 = cam_y // 8, cam_x // 8
    # 32 tile columns cover the screen; a 33rd is only visible when the camera
    # sits mid-tile, and off-screen the engine leaves that column stale.
    ncol = 32 + (1 if cam_x % 8 else 0)
    nrow = (cam_y + PLAYFIELD_H - 1) // 8 - R0 + 1
    for dr in range(nrow):
        R = R0 + dr
        for dc in range(ncol):
            C = C0 + dc
            t = st.tile_at(C, R, flags)
            if t is None:
                continue
            page = v.nt_page((C >> 5) & 1)
            ci[page * 1024 + (R % 30) * 32 + (C & 31)] = t
    # attributes: one quadrant at a time, because an attribute byte can
    # straddle the 30-row wrap and then describes two very distant world rows
    for dr in range(nrow):
        R = R0 + dr
        ntrow = R % 30
        for dc in range(ncol):
            C = C0 + dc
            if (C & 1) or (R & 1):
                continue                       # one write per 16x16 quadrant
            p = st.palette_at(C // 2, R // 2, flags)
            if p is None:
                continue
            ntcol = C & 31
            page = v.nt_page((C >> 5) & 1)
            off = page * 1024 + 0x3C0 + (ntrow // 4) * 8 + ntcol // 4
            sh = ((ntrow & 2) + ((ntcol & 2) >> 1)) * 2
            ci[off] = (ci[off] & ~(3 << sh)) | (p << sh)
    return v, st, bytes(ci)


def render_frame(rom, dump_path, out_prefix):
    """Draw the frame twice -- once from the real CIRAM, once from ROM data.

    Uses work/tools/vram.py's own PPU renderer for both, with sprites off, so
    the only difference between the two images is where the tile numbers and
    attributes came from.
    """
    sys.path.insert(0, __file__.rsplit('/', 1)[0])
    import vram as vram_mod
    v, st, ci = synth_ciram(rom, dump_path)
    ref = vram_mod.Vram(dump_path)
    chrom = rom.chr
    a = vram_mod.render(ref, chrom, sprites=False)
    ref.ciram = ci
    b = vram_mod.render(ref, chrom, sprites=False)
    vram_mod.write_png(out_prefix + '_game.png', a, 256, 240)
    vram_mod.write_png(out_prefix + '_rom.png', b, 256, 240)
    # compare only the 224 scanlines the level engine owns (the rest is HUD)
    diff = sum(1 for i in range(PLAYFIELD_H * 256 * 3) if a[i] != b[i])
    print(json.dumps(dict(dump=dump_path, frame=v.frame, stage=v.ram[0x55],
                          differing_subpixels_in_playfield=diff,
                          game=out_prefix + '_game.png',
                          rom=out_prefix + '_rom.png')))
    return diff


# ---------------------------------------------------------------------------


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 1
    rom = Rom(argv[1])
    args = argv[2:]

    if '--verify' in args:
        for p in args[args.index('--verify') + 1:]:
            if p.startswith('--'):
                break
            verify(rom, p)
        return 0
    if '--render' in args:
        i = args.index('--render')
        render_frame(rom, args[i + 1], args[i + 2])
        return 0

    stages = range(N_STAGES)
    if '--stage' in args:
        stages = [int(args[args.index('--stage') + 1], 0)]

    if '--outdir' in args:
        import os
        d = args[args.index('--outdir') + 1]
        os.makedirs(d, exist_ok=True)
        for s in stages:
            with open(os.path.join(d, 'stage_%02d.json' % s), 'w') as f:
                json.dump(Stage(rom, s).to_json(), f, indent=1)
            print('wrote %s/stage_%02d.json' % (d, s))
        return 0

    out = [Stage(rom, s).to_json() for s in stages]
    json.dump(out[0] if len(out) == 1 else out, sys.stdout, indent=1)
    print()
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
