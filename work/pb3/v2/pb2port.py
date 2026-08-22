#!/usr/bin/env python3
"""Power Blade 2's levels, re-expressed in Tokkyuu Shirei Solbrain's format.

Why this direction: `docs/e0_geometry.md`.  Every Power Blade 2 metatile fits
(100.00 %); the other way round loses 81 %.

What one Power Blade 2 *area* becomes: one Solbrain *stage*.  Both are "one
header, one set of camera bounds, one CHR set", so the unit is the same.
Seven stages of 7..14 areas give 63 of them.

The six tables Solbrain's level loader wants (`$E642`) are built per **tileset
group** -- the set of areas of one Power Blade 2 stage that share a background
CHR set.  Areas in a group share quads/props/blocks/screens and differ only in
their room map, which is what keeps the whole conversion inside 30 KB.

Geometry notes that are not obvious:

* A horizontal Power Blade 2 screen is 256x160 px; a Solbrain room is 256x256
  and 224 px of it are on screen.  The 10 metatile rows are therefore placed at
  room rows 4..13, so the floor lands on the bottom of the screen and the added
  64 px are sky above.  Rows 0..3 repeat the area's top row and rows 14..15
  repeat its bottom row, so no new metatile is invented.
* A vertical Power Blade 2 screen holds 8 blocks but only 240 px are ever
  drawn, so the metatile grid of consecutive screens is offset by 16 px
  (`docs/e0_geometry.md` §2.3).  The 15-row-per-screen packing here is that
  same repack.
* Camera bounds are only high bytes (`$E730`-`$E73F`), 16 px per unit, and the
  engine clamps the camera to `edge - 256 px`.  So the right/bottom edge byte
  is (content + 32 px) / 16 for the far edge to be reachable.

Terrain.  Power Blade 2 has nine terrain types (`work/re/pb2_collision.md`);
Solbrain's 5-bit class field holds them, but its engine only acts on four of
them by itself.  The mapping below picks, for every type Solbrain does not
know, a class value the engine provably ignores -- `(class<<3) & $E0` in
{`$00`, `$20`, `$60`} never reaches `$9FA5` or `$963D` (`13:$A194`,
`13:$A232`) -- so PB3's own runtime is the only thing that acts on them.

| PB2 type | Solbrain class | who acts |
|---|---|---|
| air | `$00` | nobody |
| ladder | `$0C` | PB3 runtime |
| instant death | `$08` | the engine's own hurt terrain (`$9FA5`) |
| deep liquid | `$0D` | PB3 runtime |
| liquid surface | `$0E` | PB3 runtime |
| current right | `$0F` | PB3 runtime |
| current left | `$07` | PB3 runtime |
| solid | `$10` | the engine |
| conveyor right | `$16` | the engine's own conveyor (`$963D`) |
| conveyor left | `$17` | the engine |
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
sys.path.insert(0, os.path.join(ROOT, 'work/tools'))

import e0_fit
import reach
import pb2_palettes
import pb2_collision

PB2_ROM = os.path.join(ROOT, 'Power Blade 2 (USA).nes')
SOL_ROM = os.path.join(ROOT, 'Tokkyuu Shirei Solbrain (Japan).nes')

N_STAGES = 7

# --- terrain -----------------------------------------------------------------
CLS_AIR      = 0x00
CLS_LADDER   = 0x0C
CLS_HURT     = 0x08
CLS_WATER    = 0x0D
CLS_SURF     = 0x0E
CLS_CUR_R    = 0x0F
CLS_CUR_L    = 0x07
CLS_SOLID    = 0x10
CLS_CONV_R   = 0x16
CLS_CONV_L   = 0x17

TYPE_TO_CLASS = {
    0x00: CLS_AIR,
    0x01: CLS_LADDER,
    0x02: CLS_HURT,
    0x03: CLS_WATER,
    0x04: CLS_SURF,
    0x05: CLS_CUR_R,
    0x06: CLS_CUR_L,
    0x80: CLS_SOLID,
    0x87: CLS_CONV_R,
    0x88: CLS_CONV_L,
}

# Power Blade 2's own background CHR, copied into PB3 as one contiguous run so
# that the three animation phases stay consecutive 2 K units.
PB2_CHR_LO = 64
PB2_CHR_HI = 127
PB2_CHR_N = PB2_CHR_HI - PB2_CHR_LO + 1

# Object types whose meaning is proven in work/re/pb2_spawns.md.
OBJ_CAPSULE = 0x02          # permanent power-up capsule
OBJ_BOSSDOOR = 0x03         # go to the boss stage
OBJ_EXIT = 0x04             # go to the next area
OBJ_CRATE = 0x0C            # destructible block

BLANK = ((0, 0, 0, 0), 0, 0, 0)


class Tileset:
    """The five packed tables one group of areas shares."""

    def __init__(self, key):
        self.key = key
        self.mt_ids = {BLANK: 0}
        self.mts = [BLANK]
        self.blk_ids = {}
        self.scr_ids = {}
        self.blocks = []
        self.screens = []
        # id 0 of every table has to be the blank one: the room map pads unused
        # cells of the 16-wide grid with screen 0 ($EFB0).
        self._blk((0, 0, 0, 0))
        self._scr(tuple([0] * 64))

    def mid(self, cell):
        c = cell or BLANK
        if c not in self.mt_ids:
            self.mt_ids[c] = len(self.mts)
            self.mts.append(c)
        return self.mt_ids[c]

    def _blk(self, key):
        if key not in self.blk_ids:
            self.blk_ids[key] = len(self.blocks)
            self.blocks.append(key)
        return self.blk_ids[key]

    def _scr(self, key):
        if key not in self.scr_ids:
            self.scr_ids[key] = len(self.screens)
            self.screens.append(key)
        return self.scr_ids[key]

    def add_room(self, cells):
        """`cells(mx, my)` over a 16x16 metatile room -> screen id."""
        scr = []
        for by in range(8):
            for bx in range(8):
                mx, my = bx * 2, by * 2
                key = (self.mid(cells(mx, my)), self.mid(cells(mx, my + 1)),
                       self.mid(cells(mx + 1, my)), self.mid(cells(mx + 1, my + 1)))
                scr.append(self._blk(key))
        return self._scr(tuple(scr))

    # -- emitted bytes -------------------------------------------------------
    def quad_bytes(self):
        out = bytearray()
        for c in self.mts:
            out += bytes(c[0])              # [TL, BL, TR, BR]
        return bytes(out)

    def prop_bytes(self):
        out = bytearray()
        for c in self.mts:
            out.append((c[1] << 6) | (TYPE_TO_CLASS[c[3]] & 0x1F))
        return bytes(out)

    def block_bytes(self):
        out = bytearray()
        for b in self.blocks:
            out += bytes(b)                 # [LT, LB, RT, RB]
        return bytes(out)

    def screen_bytes(self):
        out = bytearray()
        for s in self.screens:
            out += bytes(s)
        return bytes(out)

    def check(self):
        return (len(self.mts) <= 256 and len(self.blocks) <= 256
                and len(self.screens) <= 256
                and max(t for c in self.mts for t in c[0]) < 256)


class Area:
    """One converted Power Blade 2 area = one PB3 stage."""

    def __init__(self, st, ai):
        self.st, self.ai = st, ai
        self.tileset = None
        self.roommap = b''
        self.rooms_w = self.rooms_h = 0
        self.start = (0, 0)                 # pixels
        self.edge_x = self.edge_y = 0       # header bytes 6 and 8
        self.palette = b''
        self.chr_r0 = 0
        self.anim = (0, 0, 0)               # the three R1 values
        self.music = 1
        self.vertical = False
        self.travel = 1                     # +1 = forward along the axis
        self.exits = []                     # (kind, coord_px, target_stage)
        self.grid = None                    # (w, h, cells), kept for tools

    @property
    def name(self):
        return 'PB2 %d-%d' % (self.st, self.ai)


def _pack_area(area, cells, w, h, ts):
    """Lay the metatile grid out into rooms and build the room map."""
    if area.vertical:
        rw, rh = 1, -(-h // 16)
    else:
        rw, rh = -(-w // 16), 1

    def cell(mx, my):
        if area.vertical:
            if 0 <= my < h and 0 <= mx < w:
                return cells[my][mx]
            return BLANK
        # horizontal: the 10 rows sit at 4..13, top and bottom rows repeat
        y = min(max(my - 4, 0), h - 1)
        if 0 <= mx < w:
            return cells[y][mx]
        return BLANK

    rm = bytearray(rh * 16)
    for ry in range(rh):
        for rx in range(rw):
            sid = ts.add_room(lambda mx, my, rx=rx, ry=ry:
                              cell(rx * 16 + mx, ry * 16 + my))
            rm[ry * 16 + rx] = sid
    area.roommap = bytes(rm)
    area.rooms_w, area.rooms_h = rw, rh


def _fit(cells, want, w, have):
    """Trim or pad the metatile grid to `want` rows."""
    del cells[want:]
    while len(cells) < want:
        cells.append([BLANK] * w)
    return want


def _standing_spot(area, cells, w, h):
    """The first spot with solid ground and headroom, starting from the end of
    the scroll axis the player enters by.

    Returns (x_px, y_px) of the player's feet, in room coordinates.
    """
    def solid(mx, my):
        c = cells[my][mx] if 0 <= my < h and 0 <= mx < w else BLANK
        return TYPE_TO_CLASS[c[3]] & 0x10

    def stands(mx, my):
        return (solid(mx, my) and my >= 2
                and not solid(mx, my - 1) and not solid(mx, my - 2))

    if area.vertical:
        rows = range(2, h) if area.travel > 0 else range(h - 1, 1, -1)
        outer, inner = rows, range(1, w - 1)
        best = next(((mx, my) for my in outer for mx in inner
                     if stands(mx, my)), None)
    else:
        cols = range(1, w - 1) if area.travel > 0 else range(w - 2, 0, -1)
        best = next(((mx, my) for mx in cols for my in range(2, h)
                     if stands(mx, my)), None)
    if not best:
        best = (2, h - 1)
    mx, my = best
    # `my` is the solid row he stands on, so its top edge is ground level.  The
    # engine holds a player by his middle, not his feet, so he is put one
    # metatile higher and left to drop the last few pixels the way every
    # Solbrain level starts.
    if area.vertical:
        return mx * 16 + 8, (my - 1) * 16
    return mx * 16 + 8, (my + 3) * 16          # the 4-row shift, less one


def _exit_targets(st, ai, n_areas):
    """Where Power Blade 2's own exit objects lead (work/re/pb2_spawns.md 5.2).

    `$04` steps to the next area, and on the last area of a stage it enters the
    boss stage (stage 6) at area `$53`, or area 0 when `$53` is 5.  `$03` enters
    the boss stage at area `$53 + 6`.
    """
    if ai + 1 < n_areas:
        nxt = (st, ai + 1)
    else:
        nxt = (6, 0 if st == 5 else st)
    return nxt, (6, st + 6)


def build():
    r = e0_fit.PB2Reader(PB2_ROM)
    pal = pb2_palettes.PB2Palettes(PB2_ROM)
    sol = open(SOL_ROM, 'rb').read()

    # Solbrain's own sprite palette, so its HUD and the two heroes keep their
    # colours; only the background half comes from Power Blade 2.
    sol_prg = sol[16:16 + 16 * 0x2000]
    sol_pal0 = sol_prg[10 * 0x2000 + 0x0040:10 * 0x2000 + 0x0060]

    spawns = {(st, ai): recs
              for st in range(N_STAGES)
              for ai, recs in enumerate(e0_fit.pb2_spawn_lists(r.spawn_rom, st))}

    groups = {}
    areas = []
    for st in range(N_STAGES):
        n = len(r.lv.stage(st)['areas'])
        for ai in range(n):
            phases = pal.area_bg_chr_phases(st, ai)
            key = (st, tuple(tuple(p) for p in phases))
            ts = groups.get(key)
            if ts is None:
                ts = groups[key] = Tileset(key)
            a = Area(st, ai)
            a.tileset = ts
            rec = pal.area_record(st, ai)
            a.vertical = rec[0] == 1
            a.travel = 1 if (rec[3] * 256 + rec[4]) == 0 else -1
            a.music = 1 + (st % 6)
            w, h, cells = r.area_grid(st, ai)
            # Power Blade 2 sizes an area by its camera limit, not by how many
            # screens it links: the last screen is often only half used.  The
            # camera limit plus one window is the real extent, and the rest of
            # the grid is padding that would otherwise become walkable
            # emptiness.  The window is 256 px wide but only 176 px tall --
            # Power Blade 2 spends the bottom 64 px of the screen on its
            # status bar, so a vertical area is that much shorter than it
            # looks.  Both formulas were checked against every area: they land
            # exactly on the last non-empty column, and never short of the
            # last non-empty row.
            span = (rec[5] * 256 + rec[6] + (176 if a.vertical else 256)) // 16
            if a.vertical:
                h = _fit(cells, span, w, h)
                while h > 1 and all(c == BLANK for c in cells[h - 1]):
                    h -= 1
                del cells[h:]
            else:
                w = span
                for row in cells:
                    del row[w:]
                    row.extend([BLANK] * (w - len(row)))
            a.grid = (w, h, cells)
            # Which way through the area?  The starting camera says so for the
            # areas that scroll, but six of Power Blade 2's rooms are a single
            # screen wide and their camera never moves, so it says nothing.
            # The exit object does: you leave by one end, so you came in by the
            # other.  Where both agree this changes nothing.
            ext = (h if a.vertical else w) * 16
            ex = [pos * 16 for pos, typ, _a, _f in spawns.get((st, ai), ())
                  if typ == OBJ_EXIT]
            if ex:
                a.travel = -1 if ex[0] * 2 < ext else 1
            _pack_area(a, cells, w, h, ts)
            a.chr_r0 = phases[0][0]
            a.anim = tuple(p[2] for p in phases)
            p32 = bytearray(pal.area_palette(st, ai))
            p32[16:32] = sol_pal0[16:32]
            a.palette = bytes(p32)
            # camera bounds are 16 px per unit and the engine clamps to
            # `edge - 256 px`, so the edge is simply the extent in 16 px units
            if a.vertical:
                a.edge_x = 16                       # camera pinned to x = 0
                a.edge_y = h
            else:
                a.edge_x = w
                a.edge_y = 16                       # camera pinned to y = 0
            a.start = _standing_spot(a, cells, w, h)
            areas.append(a)

    _add_exits(r, areas)
    _clamp_exits(areas)
    order = _index(areas)
    for a in areas:
        a.exits = [(k, c, order[t]) for k, c, t in a.exits if t in order]
    tilesets = list(groups.values())
    for ts in tilesets:
        assert ts.check(), 'tileset %s over a byte-wide limit' % (ts.key,)
    return areas, tilesets


def _index(areas):
    return {(a.st, a.ai): i for i, a in enumerate(areas)}


CLIMBABLE = {0x01, 0x03, 0x04}          # ladder, deep liquid, liquid surface


class Walk(reach.Band):
    """One converted area's collision as the cartridge lays it out -- room
    padding, the four-row shift and all -- with the two moves the PB3 runtime
    adds to the engine: a ladder is climbed, and liquid is swum up through."""

    def __init__(self, a):
        self.a = a
        w, h, cells = a.grid
        self.cells, self.gw, self.gh = cells, w, h
        self.w = a.rooms_w * 16
        self.h = a.rooms_h * 16
        self.solid = self._solid

    def type_at(self, c, r):
        if self.a.vertical:
            if not (0 <= r < self.gh and 0 <= c < self.gw):
                return None
            return self.cells[r][c][3]
        if not 0 <= c < self.gw:
            return None
        return self.cells[min(max(r - 4, 0), self.gh - 1)][c][3]

    def _solid(self, c, r):
        t = self.type_at(c, r)
        return t is None or bool(t & 0x80)

    def grounded(self, c, r):
        if reach.Band.grounded(self, c, r):
            return True
        return self.type_at(c, r) in CLIMBABLE and self.free(c, r)

    def _steps(self, c, r):
        for s in reach.Band._steps(self, c, r):
            yield s
        if self.type_at(c, r) in CLIMBABLE or self.type_at(c, r - 1) in CLIMBABLE:
            for d in (-1, 1):
                if self.free(c, r + d):
                    yield (c, r + d)

    def spots(self):
        return self.reachable(self.a.start[0] // 16, self.a.start[1] // 16)


def _clamp_exits(areas):
    """An exit object sits exactly where Power Blade 2 put it, and in some
    areas that is inside the wall at the far end: the player walks up to the
    wall and the plane behind it never fires.  Each plane is moved back to the
    last line of the room that has anywhere to stand at all -- geometry only,
    so a hard jump on the way does not shorten the level."""
    for a in areas:
        w, h, cells = a.grid
        walk = Walk(a)
        n = h if a.vertical else w
        lines = [i for i in range(n)
                 if any(walk.grounded(i if not a.vertical else c,
                                      r if not a.vertical else i)
                        for c, r in (((i, r) for r in range(h)) if not a.vertical
                                     else ((c, i) for c in range(w))))]
        if not lines:
            continue
        far = max(lines) if a.travel > 0 else min(lines)
        out = []
        for kind, coord, target in a.exits:
            u = coord // 16
            if kind == 'plane' and ((a.travel > 0 and u > far)
                                    or (a.travel < 0 and u < far)):
                coord = far * 16
            out.append((kind, coord, target))
        a.exits = out


def _add_exits(r, areas):
    """Turn Power Blade 2's exit objects into plane / proximity triggers."""
    lists = {st: e0_fit.pb2_spawn_lists(r.spawn_rom, st) for st in range(N_STAGES)}
    by = {(a.st, a.ai): a for a in areas}
    for st in range(N_STAGES):
        n = len([a for a in areas if a.st == st])
        for ai, recs in enumerate(lists[st]):
            a = by.get((st, ai))
            if a is None:
                continue
            nxt, boss = _exit_targets(st, ai, n)
            for pos, typ, across, flags in recs:
                if typ == OBJ_EXIT:
                    a.exits.append(('plane', pos * 16, nxt))
                elif typ == OBJ_BOSSDOOR:
                    a.exits.append(('near', pos * 16, boss))
        # An area with no exit record of its own still has to lead somewhere.
        for ai in range(n):
            a = by[(st, ai)]
            if not a.exits:
                nxt, _ = _exit_targets(st, ai, n)
                w, h, _c = a.grid
                far = (h * 16) if a.vertical else (w * 16)
                a.exits.append(('plane', far - 24 if a.travel > 0 else 24, nxt))


def chr_banks():
    """Power Blade 2's background CHR, ready to append to PB3's."""
    d = open(PB2_ROM, 'rb').read()
    n = d[4] * 16384
    chr_ = d[16 + n:]
    return [chr_[b * 1024:(b + 1) * 1024]
            for b in range(PB2_CHR_LO, PB2_CHR_HI + 1)]


def main():
    areas, tilesets = build()
    print('areas %d, tilesets %d' % (len(areas), len(tilesets)))
    tot = 0
    for ts in tilesets:
        sz = (len(ts.quad_bytes()) + len(ts.prop_bytes())
              + len(ts.block_bytes()) + len(ts.screen_bytes()))
        tot += sz
        print('  tileset stage %d  mt %3d blk %3d scr %3d  %5d bytes'
              % (ts.key[0], len(ts.mts), len(ts.blocks), len(ts.screens), sz))
    rm = sum(len(a.roommap) for a in areas)
    print('tileset bytes %d, room maps %d, headers %d, palettes %d -> %d'
          % (tot, rm, 20 * len(areas), 32 * len(areas),
             tot + rm + 20 * len(areas) + 32 * len(areas)))
    for a in areas[:10]:
        print('  %-9s %s rooms %dx%d start %s edge %d/%d exits %s'
              % (a.name, 'V' if a.vertical else 'H', a.rooms_w, a.rooms_h,
                 a.start, a.edge_x, a.edge_y, a.exits))


if __name__ == '__main__':
    main()


# ===========================================================================
# Laying the converted areas out into 16 KB PRG pairs.
# ===========================================================================
#
# One pair holds whole tileset groups: an area's room map has to sit in the
# same bank pair as the quads/blocks/screens it indexes, because only one pair
# is mapped while a level is on screen.  Two byte-wide limits set the shape:
#
# * header byte 0 is a *byte* offset into the pair's table of 12-byte tileset
#   records ($E647 `LDA $800D,X`), so a pair holds at most 21 areas;
# * everything else is pointers, so the only other limit is the 16 KB itself.

PAIR_SIZE = 0x4000
PAIR_BASE = 0x8000
MAX_RECS = 21                       # (255 - 11) // 12
HDR_LEN = 36                        # 20 the engine reads + 16 of ours
SOL_TAIL = (0xD2, 0xE9)             # header bytes 17,18, the same in all 20


def _group_areas(areas, tilesets):
    by = {}
    for a in areas:
        by.setdefault(id(a.tileset), []).append(a)
    return [(ts, by[id(ts)]) for ts in tilesets]


def _group_size(ts, lst):
    return (len(ts.quad_bytes()) + len(ts.prop_bytes())
            + len(ts.block_bytes()) + len(ts.screen_bytes())
            + sum(len(a.roommap) + HDR_LEN + 32 + 12 for a in lst))


def pack_pairs(areas, tilesets):
    """First-fit-decreasing groups into pairs.  Returns a list of lists of
    (tileset, [area, ...])."""
    bins = []
    for ts, lst in sorted(_group_areas(areas, tilesets),
                          key=lambda g: -_group_size(*g)):
        sz = _group_size(ts, lst)
        for b in bins:
            if b['size'] + sz <= PAIR_SIZE and b['n'] + len(lst) <= MAX_RECS:
                b['g'].append((ts, lst)); b['size'] += sz; b['n'] += len(lst)
                break
        else:
            bins.append({'g': [(ts, lst)], 'size': sz + 13, 'n': len(lst)})
    return [b['g'] for b in bins]


def emit_pair(groups, bank, chr_first, stage_of):
    """Build one 16 KB pair.  `bank` is its own (even) physical PRG bank, which
    byte 0 has to carry -- `14:$C992` reads it back to restore the mapping.
    `stage_of(area)` gives the PB3 stage number, for the exit targets.

    Returns (bytes, {area: header CPU address}).
    """
    n = sum(len(l) for _ts, l in groups)
    assert n <= MAX_RECS, n
    buf = bytearray(PAIR_SIZE)
    buf[0] = bank
    pos = 13 + n * 12                       # tileset records come first
    ptr = {}                                # what each blob got

    def blob(data):
        nonlocal pos
        at = pos
        buf[at:at + len(data)] = data
        pos += len(data)
        return PAIR_BASE + at

    for ts, _lst in groups:
        ptr[('q', id(ts))] = blob(ts.quad_bytes())
        ptr[('p', id(ts))] = blob(ts.prop_bytes())
        ptr[('b', id(ts))] = blob(ts.block_bytes())
        ptr[('s', id(ts))] = blob(ts.screen_bytes())

    hdr_at = {}
    rec = 0
    for ts, lst in groups:
        for a in lst:
            rm = blob(a.roommap)
            pal = blob(a.palette)
            o = 13 + rec * 12
            for i, v in enumerate((ptr[('q', id(ts))], ptr[('b', id(ts))],
                                   ptr[('s', id(ts))], rm,
                                   ptr[('p', id(ts))], ptr[('p', id(ts))])):
                buf[o + 2 * i] = v & 0xFF
                buf[o + 2 * i + 1] = v >> 8
            hdr_at[a] = blob(_header(a, rec * 12, pal, chr_first, stage_of))
            rec += 1
    assert pos <= PAIR_SIZE, pos
    return bytes(buf), hdr_at, pos


def _chr(v, chr_first):
    assert PB2_CHR_LO <= v <= PB2_CHR_HI, v
    return v - PB2_CHR_LO + chr_first


def _header(a, rec_off, pal, chr_first, stage_of):
    x, y = a.start
    h = bytearray(HDR_LEN)
    h[0] = rec_off
    h[1], h[2] = (x % 16) * 16, x // 16
    h[3], h[4] = (y % 16) * 16, y // 16
    h[5], h[6] = 0, a.edge_x
    h[7], h[8] = 0, a.edge_y
    h[9], h[10] = pal & 0xFF, pal >> 8
    h[11] = _chr(a.chr_r0, chr_first)        # R0, 2 KB
    h[12] = _chr(a.anim[0], chr_first)       # R1, 2 KB, animated
    h[13], h[14] = 0x40, 0x56                # R2/R3: the hero, swapped per pose
    h[15], h[16] = 0x70, 0x00                # R4/R5: Solbrain's own sprite art
    h[17], h[18] = SOL_TAIL
    h[19] = a.music
    # --- PB3's own 16 bytes -------------------------------------------------
    h[20] = _chr(a.anim[0], chr_first)       # animation base for R1
    h[21] = (1 if a.vertical else 0) | (2 if a.travel < 0 else 0) \
            | (4 if len(a.anim) > 1 else 0)
    h[22] = min(len(a.exits), 3)
    for i, (kind, coord, target) in enumerate(a.exits[:3]):
        o = 24 + i * 4
        h[o] = 0 if kind == 'plane' else 1
        h[o + 1] = min(coord // 16, 255)
        h[o + 2] = stage_of(target)
    return bytes(h)
