#!/usr/bin/env python3
"""E0 / measurement A (docs/ver2_spec.md 2.3): does either engine's level
format hold the *other* game's levels without loss?

Counting only -- no ROM is built.  Everything is read straight out of the two
stock cartridges with the rippers that are already proven against live VRAM
(work/tools/pb2_levels.py, work/tools/pb2_collision.py, work/tools/sol_levels.py).

Facts this script relies on, each with the ROM address that proves it (see
work/re/*.md):

  Power Blade 2
    block   32x32 px = 4x4 tiles, 16 bytes row major          ($DBDE)
    screen  8 blocks wide, 5 blocks tall (horizontal, 256x160)
                          or 8 blocks tall (vertical, 256x256) ($DB42/$DBDE)
    area    ordered list of screen indices, camera on ONE axis ($E0B9)
    area index $66 is masked with #$0F  -> at most 16 screens   ($DFB4)
    vertical screens show only 240 of their 256 px             ($EAA5, latch $AF)
    collision: per 16x16 cell, taken from that cell's TOP-LEFT 8x8 tile
               number through one ascending threshold table per area
                                                               ($DCBF, $F566)
    placed objects: 4-byte records, unlimited per area, but only
               8 live slots $0E..$15                           ($E4B1 CPX #$16)
    destructible background: 8 bits per area ($3B)             ($8A87/$8A9B)
    next area is always area+1                                 ($86F0 INC $9C)

  Solbrain
    room    256x256 px = 8x8 blocks; room id = roomY*16+roomX  ($EFA0)
    block   32x32 px = 2x2 metatiles, 4 bytes column major     ($D0D6)
    metatile 16x16 px = 2x2 tiles, 4 bytes column major        ($F031)
    props[m] bit7,6 palette / bit5 has-alt / bits4..0 class    ($D0FF)
    alt metatiles = destructible/switchable scenery, 32-byte
               RAM bitmap over metatile IDS                    ($D101/$0540)
    objects: 6-byte records, grouped by room, count byte 1..64 ($AE7C)
    enemy slots $00..$0B = 12                                  ($CE1D LDX #$0B)

Usage:
    e0_fit.py                 full report on stdout
    e0_fit.py --png DIR       also render the proof PNGs into DIR
    e0_fit.py --verify        parser sanity check against nesemu -vram dumps
"""
import os
import sys

_d = os.path.dirname(os.path.abspath(__file__))
# PIL is imported before work/tools joins sys.path, so that no file here can
# shadow a standard module it needs.  (What used to shadow one, dis.py, is now
# disasm.py; the order is kept because the trap is easy to lay again.)
sys.path[:] = [p for p in sys.path if os.path.abspath(p or '.') != _d]
try:
    from PIL import Image, ImageDraw
except Exception:                                    # rendering is optional
    Image = ImageDraw = None
sys.path.insert(0, _d)

import pb2_collision                                  # noqa: E402
import pb2_levels                                     # noqa: E402
import pb2_spawns                                     # noqa: E402
import sol_levels                                     # noqa: E402

PB2_ROM = "Power Blade 2 (USA).nes"
SOL_ROM = "Tokkyuu Shirei Solbrain (Japan).nes"

# ---- format constants, all proven above -----------------------------------
PB2_SCREEN_W_BLOCKS = 8
PB2_H_SCREEN_H_BLOCKS = 5          # 256x160 horizontal area screen
PB2_V_SCREEN_H_BLOCKS = 8          # 256x256 vertical area screen (240 drawn)
PB2_V_SCREEN_DRAWN_PX = 240        # bottom 16 px of a vertical screen never shown
PB2_MAX_SCREENS_PER_AREA = 16      # $DFB4 masks $66 with #$0F
PB2_OBJ_SLOTS = 8                  # $0E..$15
PB2_BREAK_BITS = 8                 # $3B
PB2_BG_TILES = 256                 # R2..R5, 4 x 1 KB at $1000

SOL_ROOM_MT = 16                   # metatiles per room side
SOL_ROOM_PX = 256
SOL_GRID_W = 16                    # room map is 16 wide
SOL_GRID_H = 16
SOL_MAX_METATILES = 256            # metatile id is a byte in the block table
SOL_MAX_BLOCKS = 256               # block id is a byte in the screen table
SOL_MAX_SCREENS = 256              # screen id is a byte in the room map
SOL_OBJ_SLOTS = 12                 # $00..$0B
SOL_ALIVE_FLAGS = 64               # $0560, kind = record byte0 & $3F
SOL_MAX_OBJ_PER_GROUP = 64         # count byte, $AE7C decoder bound


def pb2_spawn_lists(rom, stage):
    """Object placement lists, one per area (pb2_spawns.md 1.1).

    The area count comes from $D6CD in bank 14 (the table $D6BC compares $9C
    against), not from the "table ends where the first list starts" heuristic:
    on stage 5 the area-0 list is stored *after* all the others, which makes
    that heuristic claim 192 areas and walk work/tools/pb2_spawns.py off the
    end of the bank.  Each list is additionally bounded by the next pointer
    above it.
    """
    n_areas = rom.bank(14)[0xD6CD - 0xC000 + stage]
    p = rom.pair(6)
    tbl = rom.pw(p, rom.w15(0xE515 + stage * 2))
    first = rom.pw(p, tbl)
    n_areas = min(n_areas, (first - tbl) // 2) if first > tbl else n_areas
    ptrs = [rom.pw(p, tbl + a * 2) for a in range(n_areas)]
    out = []
    for a, addr in enumerate(ptrs):
        stop = min([q for q in ptrs + [0xC000] if q > addr] or [0xC000])
        recs = []
        while addr + 4 <= stop:
            b = [rom.pb(p, addr + k) for k in range(4)]
            if b[0] == 0xFF:
                break
            recs.append(tuple(b))
            addr += 4
        out.append(recs)
    return out


def pct(a, b):
    return 0.0 if not b else 100.0 * a / b


# ===========================================================================
# Solbrain source inventory
# ===========================================================================
class SolStageInfo:
    def __init__(self, rom, s):
        st = sol_levels.Stage(rom, s)
        self.st = st
        self.stage = s
        self.rooms = set(st.used_rooms())
        self.n_rooms = len(self.rooms)
        self.src_mt = self.n_rooms * SOL_ROOM_MT * SOL_ROOM_MT

        # ---- room topology -------------------------------------------------
        # Two rooms are treated as connected only if the player can actually
        # cross the border between them: at least one 16-px lane where the
        # metatile is non-solid (props bit 4 clear, $8DC5) on both sides.
        R = self.rooms
        self.open_h, self.open_v = {}, {}
        for (x, y) in R:
            if (x + 1, y) in R:
                self.open_h[(x, y)] = sum(
                    1 for my in range(16)
                    if not self._solid(x * 16 + 15, y * 16 + my)
                    and not self._solid((x + 1) * 16, y * 16 + my))
            if (x, y + 1) in R:
                self.open_v[(x, y)] = sum(
                    1 for mx in range(16)
                    if not self._solid(x * 16 + mx, y * 16 + 15)
                    and not self._solid(x * 16 + mx, (y + 1) * 16))
        self.adj = {r: set() for r in R}
        for (x, y), n in self.open_h.items():
            if n:
                self.adj[(x, y)].add((x + 1, y))
                self.adj[(x + 1, y)].add((x, y))
        for (x, y), n in self.open_v.items():
            if n:
                self.adj[(x, y)].add((x, y + 1))
                self.adj[(x, y + 1)].add((x, y))
        self.edges_h = sum(1 for v in self.open_h.values() if v)
        self.edges_v = sum(1 for v in self.open_v.values() if v)
        self.edges_h_map = len(self.open_h)
        self.edges_v_map = len(self.open_v)
        self.junction = 0          # room with an X neighbour AND a Y neighbour
        self.deg3 = 0              # room with 3+ neighbours: no 1-D chain can hold it
        self.only_x = 0            # must live in a horizontal PB2 area
        for (x, y) in R:
            a = self.adj[(x, y)]
            nx = ((x + 1, y) in a) + ((x - 1, y) in a)
            ny = ((x, y + 1) in a) + ((x, y - 1) in a)
            if nx and ny:
                self.junction += 1
            if nx + ny >= 3:
                self.deg3 += 1
            if nx and not ny:
                self.only_x += 1
        self.max_run_h = self._max_run(True)
        self.max_run_v = self._max_run(False)
        self.is_path = self._is_path()

        # ---- per-cell scan -------------------------------------------------
        # tl_tile -> {class -> cell count};  class = props & $1F, solid = bit 4
        self.tl = {}
        self.cells = 0
        self.tiles_used = set()          # every 8x8 tile number that appears
        self.blocks_used = set()
        self.mt_used = set()
        self.alt_cells = 0               # cells whose metatile has an alt form
        self.alt_mts = set()
        for (rx, ry) in sorted(R):
            for by in range(8):
                for bx in range(8):
                    b = st.block_at(rx * 8 + bx, ry * 8 + by)
                    if b is not None:
                        self.blocks_used.add(b)
            for my in range(SOL_ROOM_MT):
                for mx in range(SOL_ROOM_MT):
                    MX, MY = rx * SOL_ROOM_MT + mx, ry * SOL_ROOM_MT + my
                    m = self._raw_mt(MX, MY)
                    if m is None:
                        continue
                    self.cells += 1
                    forms = [m]
                    if st.props[m] & 0x20:
                        self.alt_cells += 1
                        self.alt_mts.add(m)
                        a = st.alt[m]
                        if a < len(st.props):
                            forms.append(a)
                    for k, f in enumerate(forms):
                        self.mt_used.add(f)
                        q = st.quads[f]
                        self.tiles_used.update(q)
                        cls = st.props[f] & 0x1F
                        d = self.tl.setdefault(q[0], {})
                        # weight only the form that is on screen on entry
                        # ($E77E fills $0540 with $FF -> the alt form shows)
                        w = 1 if (len(forms) == 1 or k == len(forms) - 1) else 0
                        d[cls] = d.get(cls, 0) + w

        # ---- collision-model conflicts ------------------------------------
        # PB2 has ONE tile-number -> class function per area, so a tile number
        # that Solbrain uses with two different classes cannot be served.
        self.conflict_tiles = 0
        self.conflict_solid_tiles = 0
        self.lost_cells = 0              # cells a majority vote gets wrong
        self.lost_cells_solid = 0
        self.slots_needed = 0            # tile numbers needed if we duplicate
        for t, d in self.tl.items():
            tot = sum(d.values())
            if len(d) > 1:
                self.conflict_tiles += 1
                self.lost_cells += tot - max(d.values())
            sd = {}
            for cls, n in d.items():
                sd[bool(cls & 0x10)] = sd.get(bool(cls & 0x10), 0) + n
            if len(sd) > 1:
                self.conflict_solid_tiles += 1
                self.lost_cells_solid += sum(sd.values()) - max(sd.values())
            self.slots_needed += max(1, len(d))
        # tiles that only ever appear away from a metatile's top-left corner
        # need one slot each as well
        self.slots_needed += len(self.tiles_used - set(self.tl))

        # ---- objects -------------------------------------------------------
        self.obj_per_room = {}
        for room, g in st.room_objects.items():
            grp = st.object_groups.get(g) or {}
            self.obj_per_room[room] = len(grp.get('objects', ()))
        self.obj_total = sum(self.obj_per_room.values())
        self.obj_max_room = max(self.obj_per_room.values(), default=0)

    def _raw_mt(self, mx, my):
        st = self.st
        b = st.block_at(mx // 2, my // 2)
        if b is None or b >= len(st.blocks):
            return None
        m = st.blocks[b][(mx % 2) * 2 + (my % 2)]
        return m if m < len(st.props) else None

    def _is_path(self):
        """Can every connected component of the room graph be walked as one
        open chain?

        PB2's areas are a strictly linear sequence -- the exit object does
        INC $9C ($86F0) -- so a component that branches (a room with 3+ exits)
        or closes a loop cannot be laid out at all, however the geometry is cut.
        """
        seen = set()
        self.components = 0
        self.branch_rooms = sum(1 for r in self.rooms if len(self.adj[r]) > 2)
        self.cycles = 0
        ok = True
        for r0 in sorted(self.rooms):
            if r0 in seen:
                continue
            self.components += 1
            comp, stack = {r0}, [r0]
            while stack:
                r = stack.pop()
                for q in self.adj[r]:
                    if q not in comp:
                        comp.add(q)
                        stack.append(q)
            seen |= comp
            e = sum(len(self.adj[r]) for r in comp) // 2
            if e > len(comp) - 1:              # more edges than a tree: a loop
                self.cycles += 1
                ok = False
            if any(len(self.adj[r]) > 2 for r in comp):
                ok = False
        return ok

    def _solid(self, mx, my):
        c = self.st.collision_at(mx, my)
        return bool(c is not None and c & 0x10)

    def _max_run(self, horizontal):
        best = 0
        for (x, y) in self.rooms:
            prev = (x - 1, y) if horizontal else (x, y - 1)
            if prev in self.adj[(x, y)]:
                continue
            n, cx, cy = 1, x, y
            while True:
                nxt = (cx + 1, cy) if horizontal else (cx, cy + 1)
                if nxt not in self.adj[(cx, cy)]:
                    break
                n += 1
                cx, cy = nxt
            best = max(best, n)
        return best

    # ---- what survives a conversion into the Power Blade 2 format ----------
    def kept_all_horizontal(self):
        """ver1's policy: every room becomes a 256x160 horizontal strip."""
        return self.n_rooms * SOL_ROOM_MT * (PB2_H_SCREEN_H_BLOCKS * 2)

    def kept_axis_optimal(self):
        """Upper bound: a room keeps all 256 metatiles unless it is forced
        into a horizontal area, i.e. unless it has an X neighbour and no Y
        neighbour.  Connectivity is NOT preserved by this bound."""
        return ((self.n_rooms - self.only_x) * 256
                + self.only_x * SOL_ROOM_MT * (PB2_H_SCREEN_H_BLOCKS * 2))


# ===========================================================================
# Power Blade 2 source inventory
# ===========================================================================
class PB2Reader:
    def __init__(self, path=PB2_ROM):
        self.lv = pb2_levels.PB2Levels(path)
        self.col = pb2_collision.PB2Collision(path)
        self.spawn_rom = pb2_spawns.Rom(path)
        self.b15 = self.lv.rom.bank(15)
        self.pair67 = self.lv.rom.bank(6) + self.lv.rom.bank(7)

    # area record chain: $E2BC[stage] (bank 15) -> word in pair 6/7 ->
    # [$9C]*2 -> 14-byte record; byte 0 = scroll axis  (pb2_area_records.md)
    def _w15(self, a):
        return self.b15[a - 0xE000] | self.b15[a - 0xE000 + 1] << 8

    def _w67(self, a):
        return self.pair67[a - 0x8000] | self.pair67[a - 0x8000 + 1] << 8

    def area_axis(self, stage, area):
        tbl = self._w67(self._w15(0xE2BC + stage * 2))
        rec = self._w67(tbl + area * 2)
        return self.pair67[rec - 0x8000]          # 0 = horizontal, 1 = vertical

    def area_grid(self, stage, area):
        """The area as a grid of 16x16 metatiles.

        Returns (w, h, cells) where cells[my][mx] is
        (quad, palette, pb2_class, pb2_type) or None.
        `quad` is in Solbrain's order [TL, BL, TR, BR].
        """
        st = self.lv.stage(stage)
        idxs = [i for i in st['areas'][area] if i < len(st['screens'])]
        if not idxs:
            return 0, 0, []
        vert = self.area_axis(stage, area) == 1
        thr, val = self.col.tables(stage, area)
        typs = self.col.type_table(stage, area)

        def screen_tile(si, tr, tc):
            s = st['screens'][si]
            b = s['data'][(tr // 4) * PB2_SCREEN_W_BLOCKS + (tc // 4)]
            if b >= st['nblocks']:
                return 0, 0
            return st['blocks'][b][(tr % 4) * 4 + (tc % 4)], st['collision'][b]

        if vert:
            # a vertical screen contributes 240 drawn px = 15 metatile rows
            w, h = 16, 15 * len(idxs)
        else:
            w, h = 16 * len(idxs), PB2_H_SCREEN_H_BLOCKS * 2

        cells = []
        for my in range(h):
            row = []
            for mx in range(w):
                if vert:
                    si, tr, tc = idxs[my // 15], (my % 15) * 2, mx * 2
                else:
                    si, tr, tc = idxs[mx // 16], my * 2, (mx % 16) * 2
                tl, att = screen_tile(si, tr, tc)
                bl, _ = screen_tile(si, tr + 1, tc)
                tr_, _ = screen_tile(si, tr, tc + 1)
                br, _ = screen_tile(si, tr + 1, tc + 1)
                # attribute byte: 2 bits per 16x16 quadrant, row major
                q = ((tr % 4) // 2) * 2 + ((tc % 4) // 2)
                pal = (att >> (q * 2)) & 3
                cls = pb2_collision.lookup(thr, val, tl)
                typ = pb2_collision.lookup(thr, typs, tl)
                row.append(((tl, bl, tr_, br), pal, cls, typ))
            cells.append(row)
        return w, h, cells


def pack_into_solbrain(w, h, cells):
    """Re-express a metatile grid in Solbrain's tables and count them.

    Pads the grid out to whole 16x16-metatile rooms, then derives the metatile,
    block (2x2 metatiles) and screen (8x8 blocks) tables the way the engine
    reads them.  Returns a dict of counts to compare against the byte-wide id
    limits of the format.
    """
    rw = -(-w // SOL_ROOM_MT)
    rh = -(-h // SOL_ROOM_MT)
    BLANK = ((0, 0, 0, 0), 0, 0, 0)

    mt_ids, mts = {}, []

    def mid(c):
        c = c or BLANK
        if c not in mt_ids:
            mt_ids[c] = len(mts)
            mts.append(c)
        return mt_ids[c]

    def cell(mx, my):
        if my < h and mx < w:
            return cells[my][mx]
        return BLANK

    blk_ids, screens = {}, {}
    for ry in range(rh):
        for rx in range(rw):
            scr = []
            for by in range(8):
                for bx in range(8):
                    mx, my = rx * 16 + bx * 2, ry * 16 + by * 2
                    # block = 4 metatiles, column major [LT, LB, RT, RB]
                    key = (mid(cell(mx, my)), mid(cell(mx, my + 1)),
                           mid(cell(mx + 1, my)), mid(cell(mx + 1, my + 1)))
                    if key not in blk_ids:
                        blk_ids[key] = len(blk_ids)
                    scr.append(blk_ids[key])
            screens.setdefault(tuple(scr), len(screens))
    tiles = {t for c in mts for t in c[0]}
    return dict(rooms_w=rw, rooms_h=rh, rooms=rw * rh,
                metatiles=len(mts), blocks=len(blk_ids), screens=len(screens),
                tiles=len(tiles),
                types={c[3] for c in mts})


# ===========================================================================
# report
# ===========================================================================
def direction_a(sol_rom, out):
    p = out.append
    p("")
    p("=" * 100)
    p("DIRECTION A -- Solbrain levels expressed in the Power Blade 2 format")
    p("=" * 100)
    p("")
    p("src mt   = metatiles (16x16) in the stage's used rooms = rooms * 256")
    p("keptH    = kept if every room becomes a PB2 horizontal screen (256x160) -- ver1's policy")
    p("keptMIX  = upper bound, room keeps 256 unless it must go into a horizontal area")
    p("2Djunc   = used rooms that have an X neighbour AND a Y neighbour")
    p("deg3+    = used rooms with 3 or more neighbours (no 1-D chain can hold them)")
    p("runH/V   = longest straight room run; a PB2 area holds at most 16 screens ($DFB4)")
    p("edgeH/V  = room borders the player can actually cross (a 16-px lane that is")
    p("           non-solid on both sides); neighbours in the room map that are")
    p("           walled off do not count")
    p("1-D chain? = every connected component of that graph is an open chain, the")
    p("           only shape PB2's linear area sequence ($86F0 INC $9C) can hold")
    p("")
    hdr = ("st rooms  src mt  keptH    %    keptMIX    %   2Djunc deg3+ runH runV "
           "edgeH edgeV  1-D chain?")
    p(hdr)
    p("-" * len(hdr))
    tot = dict(src=0, kh=0, km=0, rooms=0, junc=0, deg3=0, ex=0, ey=0)
    infos = []
    for s in range(sol_levels.N_STAGES):
        i = SolStageInfo(sol_rom, s)
        infos.append(i)
        kh, km = i.kept_all_horizontal(), i.kept_axis_optimal()
        p("%2d %5d %7d %6d %6.1f %8d %6.1f %6d %5d %4d %4d %5d %5d  %s"
          % (s, i.n_rooms, i.src_mt, kh, pct(kh, i.src_mt), km,
             pct(km, i.src_mt), i.junction, i.deg3, i.max_run_h, i.max_run_v,
             i.edges_h, i.edges_v, "yes" if i.is_path else "NO"))
        tot['src'] += i.src_mt
        tot['kh'] += kh
        tot['km'] += km
        tot['rooms'] += i.n_rooms
        tot['junc'] += i.junction
        tot['deg3'] += i.deg3
        tot['ex'] += i.edges_h
        tot['ey'] += i.edges_v
    p("-" * len(hdr))
    p("ALL %5d %7d %6d %6.1f %8d %6.1f %6d %5d %4s %4s %5d %5d"
      % (tot['rooms'], tot['src'], tot['kh'], pct(tot['kh'], tot['src']),
         tot['km'], pct(tot['km'], tot['src']), tot['junc'], tot['deg3'],
         '', '', tot['ex'], tot['ey']))
    p("")
    p("2D junction rooms: %d of %d used rooms = %.1f%%  (stages with any: %d/20)"
      % (tot['junc'], tot['rooms'], pct(tot['junc'], tot['rooms']),
         sum(1 for i in infos if i.junction)))
    p("rooms needing 3+ exits: %d = %.1f%%  (stages with any: %d/20)"
      % (tot['deg3'], pct(tot['deg3'], tot['rooms']),
         sum(1 for i in infos if i.deg3)))
    p("PB2 areas are a strictly linear chain: the area-exit object does "
      "INC $9C ($86F0), and there are 52 exit records for 53 areas.")
    p("")
    path = [i for i in infos if i.is_path]
    p_src = sum(i.src_mt for i in path)
    p_kept = sum(i.kept_axis_optimal() for i in path)
    p("Stages whose room graph is only open chains (the one shape a PB2 area")
    p("sequence can hold): %d of 20, %d of %d rooms = %.1f%%."
      % (len(path), sum(i.n_rooms for i in path), tot['rooms'],
         pct(sum(i.n_rooms for i in path), tot['rooms'])))
    p("  -> %s" % ", ".join(str(i.stage) for i in path))
    p("Metatiles that survive at all = keptMIX summed over ONLY those stages:")
    p("  %d of %d = %.1f%%   (the other %.1f%% belongs to stages PB2 cannot lay"
      % (p_kept, tot['src'], pct(p_kept, tot['src']),
         100 - pct(p_src, tot['src'])))
    p("   out, because their rooms branch or close a loop)")

    p("")
    p("-- collision model: PB2 classifies a 16x16 cell by its TOP-LEFT 8x8 tile"
      " number ($DCBF, build_page) --")
    p("")
    hdr = ("st  cells  tiles  TLtiles  conflict  conflictSOLID  lostCells   %    "
           "lostSOLID   %    slots(<=256)")
    p(hdr)
    p("-" * len(hdr))
    tc = dict(cells=0, lost=0, lsol=0, conf=0, csol=0, over=0)
    for i in infos:
        over = i.slots_needed > PB2_BG_TILES
        tc['over'] += over
        p("%2d %6d %6d %8d %9d %14d %10d %5.2f %10d %5.2f %8d%s"
          % (i.stage, i.cells, len(i.tiles_used), len(i.tl),
             i.conflict_tiles, i.conflict_solid_tiles,
             i.lost_cells, pct(i.lost_cells, i.cells),
             i.lost_cells_solid, pct(i.lost_cells_solid, i.cells),
             i.slots_needed, "  OVER" if over else ""))
        tc['cells'] += i.cells
        tc['lost'] += i.lost_cells
        tc['lsol'] += i.lost_cells_solid
        tc['conf'] += i.conflict_tiles
        tc['csol'] += i.conflict_solid_tiles
    p("-" * len(hdr))
    p("ALL %6d %6s %8s %9d %14d %10d %5.2f %10d %5.2f  stages over 256 tiles: %d"
      % (tc['cells'], '', '', tc['conf'], tc['csol'], tc['lost'],
         pct(tc['lost'], tc['cells']), tc['lsol'],
         pct(tc['lsol'], tc['cells']), tc['over']))
    p("")
    p("`slots` = 8x8 tile numbers PB2 would need if every conflict is resolved")
    p("by duplicating the tile pattern.  PB2 has 256 background tiles per area")
    p("(R2..R5, 4 x 1 KB at $1000).")

    p("")
    p("-- Power Blade 2 table budget for the same data --")
    p("")
    p("A Solbrain room (8x8 blocks) is exactly one PB2 *vertical* screen")
    p("(64 bytes of block ids); a Solbrain block (2x2 metatiles = 4x4 tiles)")
    p("is exactly one PB2 block (16 bytes) plus its 1 attribute byte.")
    p("")
    hdr = ("st  rooms->PB2 screens (<=256)  blocks (<=256)  tiles (<=256)  "
           "longest V run (<=15)  fits")
    p(hdr)
    p("-" * len(hdr))
    nfit = 0
    for i in infos:
        fits = (i.n_rooms <= 256 and len(i.blocks_used) <= 256
                and i.slots_needed <= PB2_BG_TILES and i.max_run_v <= 15)
        nfit += fits
        p("%2d %26d %15d %14d %21d  %s"
          % (i.stage, i.n_rooms, len(i.blocks_used), i.slots_needed,
             i.max_run_v, "yes" if fits else "NO"))
    p("-" * len(hdr))
    p("stages whose TABLES fit PB2: %d/20 -- the tables were never the problem."
      % nfit)

    p("")
    p("-- destructible scenery and objects --")
    p("")
    hdr = ("st  altCells  altMetatiles  PB2bits  objTotal  objMaxRoom  "
           "PB2 obj slots")
    p(hdr)
    p("-" * len(hdr))
    ta = dict(cells=0, mts=0, obj=0)
    for i in infos:
        p("%2d %9d %13d %8d %9d %11d %13d"
          % (i.stage, i.alt_cells, len(i.alt_mts), PB2_BREAK_BITS,
             i.obj_total, i.obj_max_room, PB2_OBJ_SLOTS))
        ta['cells'] += i.alt_cells
        ta['mts'] += len(i.alt_mts)
        ta['obj'] += i.obj_total
    p("-" * len(hdr))
    p("ALL %9d %13d %8s %9d" % (ta['cells'], ta['mts'], '', ta['obj']))
    p("")
    p("PB2 tracks broken blocks in the 8 bits of $3B, per area ($8A87/$8A9B),")
    p("and every breakable also needs a type-$0C object, which competes for the")
    p("same 8 object slots $0E..$15 ($E4B1).")
    return infos


def direction_b(out):
    p = out.append
    r = PB2Reader()
    p("")
    p("=" * 100)
    p("DIRECTION B -- Power Blade 2 levels expressed in the Solbrain format")
    p("=" * 100)
    p("")
    p("Unit of conversion is one PB2 area -> one Solbrain area (both own exactly")
    p("one camera-bounds header and one CHR set).  Limits checked:")
    p("  metatiles <= %d (id is a byte in the block table, $D0D6)" % SOL_MAX_METATILES)
    p("  blocks    <= %d (id is a byte in the screen table, $D0C4)" % SOL_MAX_BLOCKS)
    p("  screens   <= %d (id is a byte in the room map, $EFB0)" % SOL_MAX_SCREENS)
    p("  rooms fit in the 16x16 room grid ($EFA0: room = roomY*16 + roomX)")
    p("  background tiles <= 256 (R0+R1 = 2 x 2 KB at $0000, $E74E)")
    p("")
    hdr = ("st ar ax scr  src mt  rooms(WxH)  metatiles  blocks  screens  tiles"
           "  types  fits")
    p(hdr)
    p("-" * len(hdr))
    tot = dict(src=0, ok=0, areas=0)
    worst = dict(metatiles=0, blocks=0, screens=0, tiles=0)
    per_stage = {}
    for s in range(pb2_levels.NSTAGES):
        st = r.lv.stage(s)
        for a in range(len(st['areas'])):
            w, h, cells = r.area_grid(s, a)
            if not cells:
                continue
            src = w * h
            k = pack_into_solbrain(w, h, cells)
            fits = (k['metatiles'] <= SOL_MAX_METATILES
                    and k['blocks'] <= SOL_MAX_BLOCKS
                    and k['screens'] <= SOL_MAX_SCREENS
                    and k['rooms_w'] <= SOL_GRID_W and k['rooms_h'] <= SOL_GRID_H
                    and k['tiles'] <= 256)
            ax = 'V' if r.area_axis(s, a) == 1 else 'H'
            p("%2d %2d %2s %3d %7d %6dx%-4d %10d %7d %8d %6d %6d  %s"
              % (s, a, ax, len(st['areas'][a]), src, k['rooms_w'], k['rooms_h'],
                 k['metatiles'], k['blocks'], k['screens'], k['tiles'],
                 len(k['types']), "yes" if fits else "NO"))
            tot['src'] += src
            tot['areas'] += 1
            if fits:
                tot['ok'] += src
            for key in worst:
                worst[key] = max(worst[key], k[key])
            per_stage.setdefault(s, []).append((src, fits, k))
    p("-" * len(hdr))
    p("ALL       %8d metatiles in %d areas; representable %d = %.2f%%"
      % (tot['src'], tot['areas'], tot['ok'], pct(tot['ok'], tot['src'])))
    p("worst case over all areas: metatiles %d/%d, blocks %d/%d, screens %d/%d,"
      " tiles %d/256"
      % (worst['metatiles'], SOL_MAX_METATILES, worst['blocks'], SOL_MAX_BLOCKS,
         worst['screens'], SOL_MAX_SCREENS, worst['tiles']))
    p("")
    p("Per stage (a PB2 stage becomes several Solbrain areas):")
    hdr = "st areas  src mt  metatiles(sum)  blocks(sum)  screens(sum)  all fit"
    p(hdr)
    p("-" * len(hdr))
    for s, rows in sorted(per_stage.items()):
        p("%2d %5d %7d %15d %12d %13d  %s"
          % (s, len(rows), sum(x[0] for x in rows),
             sum(x[2]['metatiles'] for x in rows),
             sum(x[2]['blocks'] for x in rows),
             sum(x[2]['screens'] for x in rows),
             "yes" if all(x[1] for x in rows) else "NO"))
    p("")

    # ---- object lists ------------------------------------------------------
    p("-- objects --")
    hdr = "st areas  records  max/area  PB2 live slots  Solbrain room groups need"
    p(hdr)
    p("-" * len(hdr))
    for s in range(pb2_levels.NSTAGES):
        areas = pb2_spawn_lists(r.spawn_rom, s)
        n = [len(recs) for recs in areas]
        p("%2d %5d %8d %9d %15d %s"
          % (s, len(areas), sum(n), max(n) if n else 0, PB2_OBJ_SLOTS,
             "<= %d/group, 6-byte records" % SOL_MAX_OBJ_PER_GROUP))
    p("")
    p("")
    p("-- destructible background, PB2 -> Solbrain --")
    p("")
    p("PB2 marks a broken block with one of the 8 bits of $3B, per area, and the")
    p("hitbox is object type $0C ($8A5D).  Solbrain switches a metatile ID, not a")
    p("map cell ($D101/$0540), so keeping PB2's per-instance behaviour costs one")
    p("private metatile ID per breakable.")
    hdr = "st  type-$0C records  max/area  extra metatile IDs needed (worst area)"
    p(hdr)
    p("-" * len(hdr))
    for s in range(pb2_levels.NSTAGES):
        areas = pb2_spawn_lists(r.spawn_rom, s)
        n = [sum(1 for rec in recs if rec[1] == 0x0C) for recs in areas]
        p("%2d %17d %9d %30d" % (s, sum(n), max(n) if n else 0, max(n) if n else 0))
    p("")
    p("PB2 record = 4 bytes: position ALONG the scroll axis in 16-px units,")
    p("type, position ACROSS the axis in pixels, flags ($E4BD).  Solbrain record")
    p("= 6 bytes with full 16-bit X and Y ($AE7C), so it holds a PB2 record with")
    p("room to spare.  Objects live 12 at a time in Solbrain ($CE1D) against 8 in")
    p("PB2 ($E4B1), and Solbrain has 64 'alive' flags per stage ($0560).")
    return r


def geometry_checks(out, r):
    p = out.append
    p("")
    p("=" * 100)
    p("THE SPECIFIC QUESTIONS FROM 2.2 / 2.3")
    p("=" * 100)
    p("")
    p("1) block size: PB2 block = 32x32 px = 4x4 tiles, 16 bytes ($DBDE);")
    p("   Solbrain block = 32x32 px = 2x2 metatiles, 4 bytes ($D0D6).")
    p("   SAME PIXEL SIZE.  PB2 stores the 16 tiles flat, Solbrain stores them")
    p("   through a metatile indirection -- a repack, not a loss.")
    p("")
    p("2) does a PB2 horizontal screen (5 blocks = 160 px) fit a Solbrain room")
    p("   (8 blocks = 256 px)?  Yes: 5 <= 8, 3 block rows of padding.")
    p("   Camera Y is clamped by area-header bytes 7/8, which are HIGH BYTES")
    p("   only ($E73A/$E73F, $3C/$3E are forced to 0), so the clamp is in whole")
    p("   256-px steps: the padding is visible unless it is authored as scenery.")
    p("   PB2 shows 176 scanlines of playfield ($AE=1 -> IRQ latch $AF);")
    p("   Solbrain shows 224.  NOT a data loss.")
    p("")
    p("3) PB2 vertical areas: a screen holds 8 blocks (256 px) of data but only")
    p("   240 px are ever drawn ($EAA5).  240 is not a multiple of 32, so the")
    p("   32-px block grid of consecutive vertical screens is offset by 16 px.")
    p("   16 px alignment (the metatile grid) is preserved, so re-packing into")
    p("   Solbrain blocks costs new block records, not geometry.")
    p("")
    # longest PB2 area, in screens, and its width in rooms
    longest = 0
    for s in range(pb2_levels.NSTAGES):
        st = r.lv.stage(s)
        for a in st['areas']:
            longest = max(longest, len(a))
    p("4) longest PB2 area found: %d screens (format cap is %d, $DFB4 masks $66"
      % (longest, PB2_MAX_SCREENS_PER_AREA))
    p("   with #$0F).  The Solbrain room grid is %d wide, so a %d-screen"
      % (SOL_GRID_W, longest))
    p("   horizontal area fits one room row.")
    p("")
    p("5) the reverse cap: a Solbrain room chain of R rooms is R*256 px.  A PB2")
    p("   horizontal area covers at most 16*256 = 4096 px, a PB2 vertical area")
    p("   at most 16*240 = 3840 px, so a vertical chain of more than 15 rooms")
    p("   cannot be expressed at all.")


def render_pngs(outdir, sol_rom, r):
    if Image is None:
        print("PIL not available -- skipping PNGs", file=sys.stderr)
        return []
    os.makedirs(outdir, exist_ok=True)
    made = []

    # ---- Solbrain rooms, entirely from ROM --------------------------------
    NES = _nes_pal()
    picks = []
    for stage in (0, 15):
        st = sol_levels.Stage(sol_rom, stage)
        rooms = sorted(st.used_rooms(), key=lambda r: (r[1], r[0]))
        start = (st.start_x >> 12, st.start_y >> 12)
        want = [start] + [rooms[len(rooms) // 2], rooms[-1]]
        for room in want[:2 if stage else 3]:
            if room in picks or room not in st.used_rooms():
                continue
            picks.append(room)
            img = Image.new('RGB', (256, 256), (0, 0, 0))
            px = img.load()
            tiles = _sol_chr(sol_rom, st.chr_banks)
            pal = st.palette[:16]
            for ty in range(32):
                for tx in range(32):
                    t = st.tile_at(room[0] * 32 + tx, room[1] * 32 + ty)
                    if t is None:
                        continue
                    pl = st.palette_at(room[0] * 16 + tx // 2,
                                       room[1] * 16 + ty // 2) or 0
                    g = tiles[t]
                    for y in range(8):
                        a, b = g[y], g[y + 8]
                        for x in range(8):
                            v = ((a >> (7 - x)) & 1) | (((b >> (7 - x)) & 1) << 1)
                            px[tx * 8 + x, ty * 8 + y] = NES[pal[pl * 4 + v] & 0x3F]
            d = ImageDraw.Draw(img, 'RGBA')
            for my in range(16):
                for mx in range(16):
                    c = st.collision_at(room[0] * 16 + mx, room[1] * 16 + my)
                    if c is not None and c & 0x10:
                        d.rectangle([mx * 16, my * 16, mx * 16 + 15, my * 16 + 15],
                                    outline=(255, 0, 0, 160))
            # the 160-px band Power Blade 2 would keep out of this room
            d.rectangle([0, 0, 255, 159], outline=(0, 255, 255, 255), width=2)
            f = os.path.join(outdir, 'sol_s%02d_room_%d_%d.png'
                             % (stage, room[0], room[1]))
            img.save(f)
            made.append(f)
        picks = []

    # ---- Solbrain stage maps with the 160-px band PB2 would keep ----------
    for stage in (0, 1):
        st = sol_levels.Stage(sol_rom, stage)
        info = SolStageInfo(sol_rom, stage)
        x0, y0, x1, y1 = st.bbox()
        W, H = (x1 - x0 + 1) * 256, (y1 - y0 + 1) * 256
        tiles = _sol_chr(sol_rom, st.chr_banks)
        pal = st.palette[:16]
        img = Image.new('RGB', (W, H), (0, 0, 0))
        px = img.load()
        for (rx, ry) in sorted(st.used_rooms()):
            for ty in range(32):
                for tx in range(32):
                    t = st.tile_at(rx * 32 + tx, ry * 32 + ty)
                    if t is None:
                        continue
                    pl = st.palette_at(rx * 16 + tx // 2, ry * 16 + ty // 2) or 0
                    g = tiles[t]
                    ox, oy = (rx - x0) * 256 + tx * 8, (ry - y0) * 256 + ty * 8
                    for y in range(8):
                        a, b = g[y], g[y + 8]
                        for x in range(8):
                            v = ((a >> (7 - x)) & 1) | (((b >> (7 - x)) & 1) << 1)
                            px[ox + x, oy + y] = NES[pal[pl * 4 + v] & 0x3F]
        d = ImageDraw.Draw(img, 'RGBA')
        for (rx, ry) in sorted(st.used_rooms()):
            ox, oy = (rx - x0) * 256, (ry - y0) * 256
            # what a PB2 horizontal screen keeps out of this room: 160 of 256 px
            d.rectangle([ox + 96, oy, ox + 255, oy + 255], fill=(0, 0, 0, 130))
            d.rectangle([ox, oy, ox + 255, oy + 159], outline=(0, 255, 255, 255),
                        width=3)
            n = len(info.adj[(rx, ry)])
            col = (255, 0, 0, 255) if n > 2 else (255, 255, 0, 255)
            d.ellipse([ox + 118, oy + 118, ox + 138, oy + 138], fill=col)
            for q in info.adj[(rx, ry)]:
                d.line([(ox + 128, oy + 128),
                        ((q[0] - x0) * 256 + 128, (q[1] - y0) * 256 + 128)],
                       fill=(255, 255, 255, 220), width=5)
        img = img.resize((W // 3, H // 3), Image.LANCZOS)
        f = os.path.join(outdir, 'sol_s%02d_map.png' % stage)
        img.save(f)
        made.append(f)

    # ---- Power Blade 2 screens --------------------------------------------
    dump = os.environ.get('PB2_VRAM')
    banks = pal = None
    if dump and os.path.exists(dump):
        import vram
        v = vram.Vram(dump)
        banks = list(v.chr_scan[100])
        pal = list(v.scan[100]['pal'])
    if banks is None:
        print("no PB2_VRAM dump: PB2 screens need the live CHR bank / palette "
              "(R2/R3 come from the animated table $EF3F) -- skipped",
              file=sys.stderr)
        return made
    chrom = _pb2_chr(PB2_ROM)
    lv = r.lv
    for stage, ai, si in ((0, 0, 0), (0, 0, 2), (0, 1, 0x12)):
        st = lv.stage(stage)
        if si >= len(st['screens']):
            continue
        g = lv.screen_tiles(st, si)
        H = len(g)
        img = Image.new('RGB', (256, H * 8), (0, 0, 0))
        px = img.load()
        s = st['screens'][si]
        for row in range(H):
            for col in range(32):
                t = g[row][col]
                b = s['data'][(row // 4) * 8 + (col // 4)]
                att = st['collision'][b] if b < st['nblocks'] else 0
                q = ((row % 4) // 2) * 2 + ((col % 4) // 2)
                pl = (att >> (q * 2)) & 3
                bank = banks[((t >> 6) & 3) + 4]
                off = bank * 1024 + (t & 0x3F) * 16
                for y in range(8):
                    lo, hi = chrom[off + y], chrom[off + 8 + y]
                    for x in range(8):
                        vv = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
                        c = pal[0] if vv == 0 else pal[pl * 4 + vv]
                        px[col * 8 + x, row * 8 + y] = NES[c & 0x3F]
        d = ImageDraw.Draw(img, 'RGBA')
        thr, val = r.col.tables(stage, ai)
        for row in range(0, H, 2):
            for col in range(0, 32, 2):
                if pb2_collision.lookup(thr, val, g[row][col]) == 2:
                    d.rectangle([col * 8, row * 8, col * 8 + 15, row * 8 + 15],
                                outline=(255, 0, 0, 160))
        f = os.path.join(outdir, 'pb2_s%d_screen%02d.png' % (stage, si))
        img.save(f)
        made.append(f)
    return made


def _nes_pal():
    import vram
    return [((c >> 16) & 255, (c >> 8) & 255, c & 255) for c in vram.NES_PAL]


def _sol_chr(rom, banks):
    out = []
    for kb in (banks[0] & 0xFE, (banks[0] & 0xFE) + 1,
               banks[1] & 0xFE, (banks[1] & 0xFE) + 1):
        base = kb * 0x400
        for t in range(64):
            out.append(rom.chr[base + t * 16: base + t * 16 + 16])
    return out


def _pb2_chr(path):
    raw = open(path, 'rb').read()
    prg = raw[4] * 16384
    return raw[16 + prg:]


# ===========================================================================
def verify(out):
    """Numeric proof that both parsers read the stock ROMs correctly."""
    p = out.append
    import glob
    import vram
    p("")
    p("=" * 100)
    p("PARSER VERIFICATION against nesemu -vram dumps")
    p("=" * 100)
    sol_rom = sol_levels.Rom(SOL_ROM)
    for f in sorted(glob.glob(os.environ.get('SOL_VRAM_GLOB', '/tmp/sol/[ap]*.bin'))):
        try:
            res = sol_levels.verify(sol_rom, f, verbose=False)
        except Exception as e:                        # not a vram dump
            p("  %-28s skipped (%s)" % (os.path.basename(f), e))
            continue
        p("  solbrain %-14s stage %2d  tiles %5d wrong %d  attrs %4d wrong %d"
          % (os.path.basename(f), res['stage'], res['tiles_checked'],
             res['tiles_wrong'], res['attrs_checked'], res['attrs_wrong']))
    d = os.environ.get('PB2_VRAM')
    if d and os.path.exists(d):
        v = vram.Vram(d)
        lv = pb2_levels.PB2Levels(PB2_ROM)
        stage, area, cam = v.ram[0x53], v.ram[0x9C], v.ram[0x66]
        st = lv.stage(stage)
        si = st['areas'][area][cam]
        g = lv.screen_tiles(st, si)
        best = None
        for page in (0, 1):
            for yoff in range(30):
                bad = sum(1 for L in range(len(g)) for c in range(32)
                          if g[L][c] != v.nt_byte(page, c, (yoff + L) % 30))
                if best is None or bad < best[2]:
                    best = (page, yoff, bad)
        p("  powerblade2 %-11s stage %d area %d camera screen %d -> screen $%02X"
          % (os.path.basename(d), stage, area, cam, si))
        p("               decoded %dx32 tiles land on CIRAM nametable %d rows "
          "%d..%d with %d mismatches of %d"
          % (len(g), best[0], best[1], best[1] + len(g) - 1, best[2],
             len(g) * 32))


def main(argv):
    outdir = None
    if '--png' in argv:
        outdir = argv[argv.index('--png') + 1]
    out = []
    sol_rom = sol_levels.Rom(SOL_ROM)
    out.append("E0 measurement A -- level-format capacity, both directions")
    out.append("ROMs: %s / %s" % (PB2_ROM, SOL_ROM))
    verify(out)
    direction_a(sol_rom, out)
    r = direction_b(out)
    geometry_checks(out, r)
    print("\n".join(out))
    if outdir:
        made = render_pngs(outdir, sol_rom, r)
        for f in made:
            print("wrote", f, file=sys.stderr)


if __name__ == '__main__':
    main(sys.argv[1:])
