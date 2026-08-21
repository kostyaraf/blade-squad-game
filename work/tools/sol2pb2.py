"""Convert a Solbrain stage into Power Blade 2's level format.

The two games agree on the unit that matters: a block is 32x32 pixels and a
room/screen is 8 blocks across.  Palettes line up as well -- Solbrain stores
one palette per 16x16 metatile and Power Blade 2's per-block attribute byte
holds four 16x16 selectors -- so the artwork carries over unchanged.

The one real mismatch is height.  A Solbrain room is 8 blocks (256 px) tall,
but a Power Blade 2 horizontally scrolling area shows 5 blocks (160 px), the
rest of the screen being the status panel.  So a horizontal run of rooms is
cropped to the 5-block band that actually holds the level: the band is chosen
per area, not per room, so the floor stays continuous across the whole run.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sol_levels
from pb2_pack import Screen, pack

SOL = "Tokkyuu Shirei Solbrain (Japan).nes"
SOLID = 0x10                      # props bit 4, proven in sol_level_format.md


import reach


def base_metatile(st, mx, my):
    """The metatile before the alt substitution -- Solbrain's own `resolve` hands
    back the alt form, because the level loader fills the $0540 bitmap with $FF
    on entry."""
    b = st.block_at(mx // 2, my // 2)
    if b is None or b >= len(st.blocks):
        return None
    return st.blocks[b][(mx % 2) * 2 + (my % 2)]


def breakable(st, mx, my):
    """A destructible crate: the base metatile has an alt form, and its own
    collision class passes the punch test at $B9E7 -- class < $0C and
    class & 3 >= 2.  The alt form is solid and is what the player meets, so
    until PB3 can break these they must not be solid: they stand exactly where
    Solbrain expects the player to smash through, and left solid they wall the
    level off."""
    m = base_metatile(st, mx, my)
    if m is None or m >= len(st.props):
        return False
    p = st.props[m]
    if not p & 0x20:
        return False
    c = p & 0x1F
    return c < 0x0C and (c & 3) >= 2


def solid_at(st, mx, my):
    """Solid as PB3 sees it: Solbrain's collision minus the crates."""
    c = st.collision_at(mx, my)
    return bool(c is not None and c & SOLID) and not breakable(st, mx, my)


# --- picking the 5-block band ----------------------------------------------
def surface_rows(st, rooms):
    """Where the player can actually stand, as a count per block row 0..7.

    A standable surface is an empty 16x16 metatile with a solid one directly
    below it.  Summed over a run of rooms this points straight at the band the
    level is played in, which the old "lots of empty space" heuristic did not:
    an empty sky scores highest on empty space and lowest on playability."""
    rows = [0] * 8
    for rx, ry in rooms:
        for mx in range(rx * 16, rx * 16 + 16):
            for my in range(ry * 16, ry * 16 + 16):
                if solid_at(st, mx, my):
                    continue
                if solid_at(st, mx, my + 1):
                    rows[(my - ry * 16) // 2] += 1
    return rows


def interest_rows(st, rooms):
    """Block rows Solbrain itself puts something at: the player start and the
    stage's own object placements.  These are the rows that must survive."""
    rows = [0] * 8
    want = set(rooms)
    def mark(x_px, y_px, w):
        rx, ry = int(x_px) // 256, int(y_px) // 256
        if (rx, ry) in want:
            rows[(int(y_px) % 256) // 32] += w
    mark(st.start_x / 16, st.start_y / 16, 12)
    for room, g in st.room_objects.items():
        grp = st.object_groups.get(g) or {}
        for o in grp.get('objects', ()):
            mark(o['x_px'], o['y_px'], 4)
    return rows


def solid_rows(st, rooms):
    rows = [0] * 8
    for rx, ry in rooms:
        for mx in range(rx * 16, rx * 16 + 16):
            for my in range(ry * 16, ry * 16 + 16):
                if solid_at(st, mx, my):
                    rows[(my - ry * 16) // 2] += 1
    return rows


def band_score(st, rooms, off, surf=None, want=None, sol=None):
    surf = surf if surf is not None else surface_rows(st, rooms)
    want = want if want is not None else interest_rows(st, rooms)
    sol = sol if sol is not None else solid_rows(st, rooms)
    # only the first four rows are room for the player: whatever he stands on
    # has to be inside the band too, or the level is sliced off its own floor
    keep = range(off, off + 4)
    return (sum(want[r] for r in keep) * 8
            + sum(surf[r] for r in keep)
            + sol[off + 4] // 2)


def band_grid(st, rooms, off):
    """The area exactly as Power Blade 2 will present it: ten metatile rows,
    one column per metatile of the run, solid where the engine says solid."""
    top = rooms[0][1] * 16 + off * 2
    cols = [rx * 16 + k for rx, ry in rooms for k in range(16)]
    return reach.Band(lambda c, r: solid_at(st, cols[c], top + r), len(cols), 10)


def entry_cell(b):
    """Where the player lands when the area opens: Power Blade 2 puts him at
    the left edge, so it is the first column with any floor in it."""
    for c in range(b.w):
        for r in range(1, b.h):
            if b.grounded(c, r):
                return c, r
    return None


def walkable(st, rooms, off):
    b = band_grid(st, rooms, off)
    cell = entry_cell(b)
    return b, (b.reachable(*cell) if cell else set())


def best_band(st, rooms, seam=None):
    """Which 160-pixel slice of the 256-pixel rooms the area is cut from.

    Scoring a slice by how much scenery it holds is what produced areas that
    look right and cannot be crossed -- a floor-to-ceiling pillar is scenery
    too.  So the slice is chosen by walking it: the one the player can cover
    most of, and that lets him reach the room where this area hands over to the
    next, wins.  The old scenery score only breaks ties."""
    surf, want = surface_rows(st, rooms), interest_rows(st, rooms)
    sol = solid_rows(st, rooms)

    def score(off):
        _, seen = walkable(st, rooms, off)
        near = 0
        if seam is not None and seen:
            near = int(any(seam * 16 <= c < seam * 16 + 16 for c, _ in seen))
        return (near, len(seen), band_score(st, rooms, off, surf, want, sol))

    return max(range(4), key=score)


def far_enough(cell, entry):
    """The exit's hitbox reaches 22 pixels sideways and 26 up and down from the
    player, so anything closer than three metatiles fires the moment the area
    opens -- the player never sees it, he just falls through to the next one."""
    return abs(cell[0] - entry[0]) >= 3 or abs(cell[1] - entry[1]) >= 3


def pick_exit(seen, entry, room_of, seam):
    """Of the metatiles the player can reach, the exit goes on the one in the
    handover room that is furthest from where he came in -- so crossing the
    area is what ends it."""
    ok = [p for p in seen if far_enough(p, entry)]
    if not ok:
        return None
    here = [p for p in ok if room_of(p) == seam]
    return max(here or ok,
               key=lambda p: (abs(p[0] - entry[0]) + abs(p[1] - entry[1])))


def exit_spot(st, rooms, off, seam):
    """Where this area's exit stands: in the room where it touches the next
    area, but on a metatile the player can actually get to.  An exit behind a
    wall is the same as no exit at all."""
    b, seen = walkable(st, rooms, off)
    entry = entry_cell(b)
    if not seen or entry is None:
        return None
    return pick_exit(seen, entry, lambda p: p[0] // 16, seam)


# --- exact collision by tile renumbering -----------------------------------
#
# Power Blade 2 decides whether an 8x8 tile is solid from its tile *number*,
# while Solbrain decides it per 16x16 metatile.  A tile number that Solbrain
# uses both ways therefore cannot be translated -- the old majority vote got
# up to 3.8% of a stage's tiles wrong, which is the difference between a floor
# and a hole.  But no Solbrain stage uses more than 159 of the 256 tile
# numbers, so every (tile, solid) pair can simply get a number of its own:
# non-solid pairs first, solid ones after, and the collision table is then a
# single threshold.  The stage's four background CHR banks are rebuilt to
# match.
def tile_map(st):
    pairs = set()
    for rx, ry in st.used_rooms():
        for tx in range(rx * 32, rx * 32 + 32):
            for ty in range(ry * 32, ry * 32 + 32):
                t = st.tile_at(tx, ty)
                if t is None:
                    continue
                pairs.add((t, solid_at(st, tx // 2, ty // 2)))
    soft = sorted(t for t, sld in pairs if not sld)
    hard = sorted(t for t, sld in pairs if sld)
    if len(soft) + len(hard) > 256:
        raise ValueError(f"{len(soft) + len(hard)} (tile, solid) pairs, "
                         "the pattern table holds 256")
    remap = {}
    order = []
    for t in soft:
        remap[(t, False)] = len(order); order.append(t)
    first_solid = len(order)
    for t in hard:
        remap[(t, True)] = len(order); order.append(t)
    return remap, order, first_solid


def chr_window(rom, st, order):
    """The stage's own 4 KB background pattern table, tile `i` being the
    Solbrain tile `order[i]` from its own two 2 KB banks."""
    b = st.chr_banks
    src = b''.join(rom.chr[k * 0x400: (k + 1) * 0x400]
                   for k in (b[0] & 0xFE, (b[0] & 0xFE) + 1,
                             b[1] & 0xFE, (b[1] & 0xFE) + 1))
    out = bytearray(0x1000)
    for i, t in enumerate(order):
        out[i * 16:i * 16 + 16] = src[t * 16:t * 16 + 16]
    return bytes(out)


def exact_collision(first_solid):
    """The three parallel lists $DCBF walks, for "everything from `first_solid`
    upwards is solid"."""
    return bytes((first_solid, 0xFF)), bytes((0x80,)), bytes((0x02,))


# --- one room -> one screen -------------------------------------------------
def room_screen(st, rx, ry, off=0, hb=8, remap=None):
    def tile(tx, ty):
        t = st.tile_at(tx, ty)
        if t is None:
            return 0
        if remap is None:
            return t
        return remap[(t, solid_at(st, tx // 2, ty // 2))]
    tiles = [[tile(rx * 32 + tx, (ry * 8 + off) * 4 + ty)
              for tx in range(32)] for ty in range(hb * 4)]
    attrs = [[0] * 8 for _ in range(hb)]
    for br in range(hb):
        for bc in range(8):
            v = 0
            for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                p = st.palette_at(rx * 16 + bc * 2 + dx,
                                  (ry * 8 + off + br) * 2 + dy)
                v |= (p or 0) << (q * 2)
            attrs[br][bc] = v
    return Screen(tiles, attrs)


# --- one column of rooms -> a vertical area ---------------------------------
#
# A vertical Power Blade 2 area shows 240 pixels per screen while a Solbrain
# room is 256 tall (see work/re/pb2_vertical_areas.md).  Rather than pad the
# column and leave the player a strip of nothing to fall through, one 16-pixel
# metatile row of every room is left out -- and in a shaft, which is what
# vertical areas are for, there is nearly always a row that simply repeats the
# one above it, so the cut is invisible.
def room_rows(st, rx, ry):
    """The room's sixteen metatile rows, each as its 64 tile numbers."""
    out = []
    for j in range(16):
        my = ry * 16 + j
        out.append(tuple(st.tile_at(rx * 32 + tx, my * 2 + sub) or 0
                         for sub in (0, 1) for tx in range(32)))
    return out


def drop_row(st, rx, ry):
    """Which metatile row of the room to leave out of a vertical area."""
    rows = room_rows(st, rx, ry)
    for j in range(15, 0, -1):              # a row that repeats the one above
        if rows[j] == rows[j - 1]:
            return j
    # nothing repeats: give up the row that differs least from its neighbour
    return min(range(1, 16),
               key=lambda j: sum(a != b for a, b in zip(rows[j], rows[j - 1])))


def column_rows(st, run):
    """The column's metatile rows in Solbrain coordinates, fifteen per room, in
    the order a vertical area will show them."""
    out = []
    for rx, ry in run:
        skip = drop_row(st, rx, ry)
        out += [ry * 16 + j for j in range(16) if j != skip]
    return out


def vert_screen(st, rx, rows, remap=None):
    """One screen of a vertical area: the fifteen metatile rows it shows plus
    the one below them, which is data the engine keeps but never draws."""
    def tile(tx, ty):
        t = st.tile_at(tx, ty)
        if t is None:
            return 0
        return t if remap is None else remap[(t, solid_at(st, tx // 2, ty // 2))]
    tiles = []
    for my in rows:
        for sub in (0, 1):
            tiles.append([tile(rx * 32 + tx, my * 2 + sub) for tx in range(32)])
    attrs = [[0] * 8 for _ in range(8)]
    for br in range(8):
        for bc in range(8):
            v = 0
            for q, (dy, dx) in enumerate(((0, 0), (0, 1), (1, 0), (1, 1))):
                p = st.palette_at(rx * 16 + bc * 2 + dx, rows[br * 2 + dy])
                v |= (p or 0) << (q * 2)
            attrs[br][bc] = v
    return Screen(tiles, attrs)


def vert_area(st, run, remap=None):
    """A whole column: one screen per room, in top-to-bottom order."""
    rows = column_rows(st, run)
    out = []
    for k in range(len(run)):
        window = rows[k * 15: k * 15 + 16]
        while len(window) < 16:             # the last screen's unseen row
            window.append(window[-1])
        out.append(vert_screen(st, run[0][0], window, remap))
    return out


def vert_grid(st, run):
    """The column's collision as reach.Band sees it: sixteen metatile columns
    and fifteen rows per room, matching what the area really shows."""
    rows = column_rows(st, run)
    rx = run[0][0]
    return reach.Band(lambda c, r: solid_at(st, rx * 16 + c, rows[r]),
                      16, len(rows))


def vert_area_record(n_screens, chr_r0, chr_r1, chr_r4, chr_r5, pal_a, pal_b):
    """The vertical twin of `area_record`.  $73 is derived, not free: with the
    camera at the top ($66/$67 = 0) it is (0 >> 3) + 26 mod 30 = $1A, which is
    what every stock vertical area with a zero camera has.  The limit is the
    bottom of the last screen, and $FC tracks $67."""
    return bytes((
        0x01,               # $97   vertical
        0x01,               # $AE   plain raster mode
        0x1A,               # $73   nametable fill row
        0x00, 0x00,         # $66/$67  camera at the top
        n_screens - 1, 0x40,  # $59/$5A  camera limit = N*240 - 176
        chr_r0, chr_r1, chr_r4, chr_r5,
        0x00,               # $FC   = $67
        pal_a, pal_b,
    ))


# --- carving the room grid into areas --------------------------------------
def runs(st):
    """Maximal left-to-right runs of used rooms, one per room-map row."""
    used = st.used_rooms()
    rows = {}
    for x, y in used:
        rows.setdefault(y, set()).add(x)
    out = []
    for y in sorted(rows):
        xs = rows[y]
        run = []
        for x in range(min(xs), max(xs) + 2):
            if x in xs:
                run.append((x, y))
            elif run:
                out.append(run)
                run = []
        if run:
            out.append(run)
    return out


def area_record(n_screens, chr_r0, chr_r1, chr_r4, chr_r5, pal_a, pal_b):
    """The 14 bytes $E272-$E2B8 reads.  Horizontal areas are regular: the
    camera starts at the left edge and its limit is simply screens-1, which
    is exactly what every stock horizontal area does."""
    return bytes((
        0x00,               # $97   horizontal
        0x01,               # $AE
        0x00,               # $73
        0x00, 0x00,         # $66/$67  camera start
        n_screens - 1, 0x00,  # $59/$5A  camera limit
        chr_r0, chr_r1, chr_r4, chr_r5,
        0xE0,               # $FC
        pal_a, pal_b,
    ))


def collision_tables(st):
    """Solbrain marks solidity per 16x16 metatile; Power Blade 2 classifies by
    8x8 tile number.  Across a stage a tile is used solid or not solid almost
    without exception (0-3% of placements disagree), so a majority vote per
    tile number reproduces the level's geometry, and the engine's step
    function then compresses to a few dozen runs.

    Returns (thresholds, types, classes) in the shape $DCBF walks: thresholds
    ascending and $FF-terminated, one type/class per run."""
    vote = {}
    for rx, ry in st.used_rooms():
        for mx in range(rx * 16, rx * 16 + 16):
            for my in range(ry * 16, ry * 16 + 16):
                s = solid_at(st, mx, my)
                for dx in range(2):
                    for dy in range(2):
                        t = st.tile_at(mx * 2 + dx, my * 2 + dy)
                        if t is None:
                            continue
                        v = vote.setdefault(t, [0, 0])
                        v[s] += 1
    solid = [0] * 256
    for t, (no, yes) in vote.items():
        solid[t] = 1 if yes > no else 0

    thr, typ, cls = [], [], []
    for t in range(1, 255):                 # tile 0 is always empty; $FF ends
        if solid[t] != solid[t - 1]:
            thr.append(t)
            typ.append(0x80 if solid[t] else 0x00)
            cls.append(0x02 if solid[t] else 0x00)
    thr.append(0xFF)
    return bytes(thr), bytes(typ), bytes(cls)


# --- objects ----------------------------------------------------------------
#
# Power Blade 2 spawns from a 4-byte record per object (work/re/pb2_spawns.md):
# byte 0 = column along the scroll axis in 16-px units, byte 1 = type,
# byte 2 = the across-axis pixel, byte 3 = flags.  Type $04 is the area exit.
#
# Which types can be used is decided by the CHR: a converted area maps Power
# Blade 2's R4=$19 / R5=$13 enemy banks, which is what its stage 0 areas 0-2
# use, so only the types those areas place have their tiles in the pattern
# table.  Everything Solbrain places is mapped onto that set.
PB2_EXIT = 0x04
# A horizontal area's playfield starts 16 pixels down, under the status bar, so
# an object's sprite Y is its metatile row plus one row (work/re/pb3_crates.md).
HUD_Y = 16
PB2_ENEMIES = (0x2C, 0x17, 0x13, 0x12, 0x23, 0x1D, 0x29, 0x1E)

# Solbrain object type -> the closest Power Blade 2 type, matched behaviour
# for behaviour from both engines' object tables (work/re/sol_enemy_types.md).
# Only types whose tiles live in the CHR banks a converted area maps (R4=$19,
# R5=$13) are usable, which is what limits the right-hand side to eleven.
SOL_TO_PB2 = {
    0x17: 0x2C, 0x18: 0x2C, 0x16: 0x2C, 0x19: 0x2C,   # ground soldiers
    0x03: 0x13, 0x29: 0x12, 0x1F: 0x12,               # flyers and hoverers
    0x02: 0x17, 0x2D: 0x22, 0x28: 0x22,               # small ground fillers
    0x2C: 0x23, 0x13: 0x23, 0x1D: 0x23,               # heavy ground robots
    0x23: 0x1D, 0x24: 0x1D, 0x22: 0x1D,               # fixed guns
    0x26: 0x1D, 0x04: 0x1D,                           # ... and fixed props
    0x06: 0x1E, 0x1B: 0x1E,                           # tall fixed structures
    0x27: 0x29, 0x20: 0x29, 0x21: 0x29,               # burning and pushing
    0x25: 0x07, 0x1E: 0x07,                           # things that drop
}
# $00 $01 $07 $14 are Solbrain's invisible markers: the handler is an RTS and
# the metasprite record says "never drawn", so they have no hitbox and cannot
# be hit or hurt anyone.  Power Blade 2 has nothing that does nothing, so they
# are dropped rather than substituted.
SOL_DROP = (0x00, 0x01, 0x07, 0x14)


def stage_objects(st):
    """Solbrain's whole object list for the stage.

    A group is a sliding window into one continuous run of records -- entering
    a room moves the window along -- so the level's full set is the union of
    the windows, deduplicated on the record itself."""
    seen, out = set(), []
    for g in st.object_groups.values():
        for o in g.get('objects') or ():
            k = tuple(o['raw'])
            if k in seen:
                continue
            seen.add(k)
            out.append(o)
    out.sort(key=lambda o: (o['x_px'], o['y_px']))
    return out


def snap_to_floor(st, x_px, y_px, ry, off, reach=6):
    """Solbrain spawns an object through its own placement rules; Power Blade 2
    drops it straight in as a free-standing sprite.  Pull it out of whatever
    block it would otherwise be buried in and stand it on the nearest floor,
    which is what stops enemies appearing inside walls.  Returns the pixel Y
    inside the area's 160-pixel band, or None if there is no room at all."""
    mx = int(x_px) // 16
    top = ry * 16 + off * 2             # the band's first metatile row
    lo, hi = top, top + 9               # 5 blocks of 32 px = 10 metatile rows

    def solid(r):
        return solid_at(st, mx, r)

    my = min(max(int(y_px) // 16, lo), hi)
    for d in range(reach + 1):          # first choice: a spot with floor under it
        for r in (my + d, my - d):
            if lo <= r <= hi and not solid(r) and (r == hi or solid(r + 1)):
                return (r - top) * 16 + HUD_Y
    for d in range(reach + 1):          # failing that, at least not inside a wall
        for r in (my - d, my + d):
            if lo <= r <= hi and not solid(r):
                return (r - top) * 16 + HUD_Y
    return None


def area_spawns(st, run, off, exit_cell=None):
    """One area's placement list: Solbrain's own objects, moved into the area's
    own coordinates, plus the exit that carries the player to the next area."""
    where = {rc: i for i, rc in enumerate(run)}
    recs = []
    for o in stage_objects(st):
        rx, ry = int(o['x_px']) // 256, int(o['y_px']) // 256
        i = where.get((rx, ry))
        if i is None or o['param'] in SOL_DROP:
            continue
        x = i * 256 + (int(o['x_px']) - rx * 256)
        y = snap_to_floor(st, o['x_px'], o['y_px'], ry, off)
        if y is None or x // 16 > 0xFE:
            continue
        recs.append((x // 16, SOL_TO_PB2.get(o['param'], 0x17),
                     y & 0xFF, 0x80 if o['dir_gate'] else 0x00))
    if exit_cell is not None:
        # The exit stands where the walk says it can be reached, near the seam
        # with the next area -- see `exit_spot`.
        c, r = exit_cell
        recs.append((min(c, 0xFE), PB2_EXIT, (r * 16 + HUD_Y) & 0xFF, 0x00))
    recs.sort(key=lambda r: r[0])
    out = bytearray()
    for r in recs:
        out += bytes(r)
    out += b'\xFF'
    return bytes(out)


def carve(st):
    """Every room, assigned to either a horizontal area or a vertical one.

    A row-run of two or more rooms plays as a horizontal area.  A room that is
    alone in its row-run is part of a shaft, and a shaft plays far better as a
    vertical area: vertical scrolling shows 240 of the room's 256 pixels
    instead of the 160 a horizontal band can spare, and it is the axis the
    player is actually travelling along.  Single rooms stacked in the same
    column join into one such area."""
    singles, wide = [], []
    for run in runs(st):
        (singles if len(run) == 1 else wide).append(run)
    cols = {}
    for run in singles:
        x, y = run[0]
        cols.setdefault(x, []).append(y)
    out = [('h', r) for r in wide]
    for x in sorted(cols):
        ys = sorted(cols[x])
        i = 0
        while i < len(ys):
            j = i
            while j + 1 < len(ys) and ys[j + 1] == ys[j] + 1:
                j += 1
            out.append(('v', [(x, y) for y in ys[i:j + 1]]))
            i = j + 1
    return out


def run_adjacency(all_runs):
    """Which runs touch which.  Two runs in the same row never touch -- there is
    a gap between them by construction -- so every link here is a room sitting
    directly above or below a room of the other run, and that room is exactly
    where the player can walk from one area into the next."""
    idx = {}
    for i, run in enumerate(all_runs):
        for rc in run:
            idx[rc] = i
    adj = {i: {} for i in range(len(all_runs))}
    for i, run in enumerate(all_runs):
        for (x, y) in run:
            for n in ((x, y - 1), (x, y + 1), (x - 1, y), (x + 1, y)):
                j = idx.get(n)
                if j is not None and j != i:
                    adj[i].setdefault(j, (x, y))
    return adj


def ordered_runs(st):
    """The order Power Blade 2 will chain the areas in, plus the seam room each
    area hands over at.

    Area 0 is forced: the engine always drops the player there, so it has to be
    the piece holding Solbrain's own start.  After that the order follows the
    level's own shape -- a depth-first walk over rooms that actually touch --
    instead of reading order, so leaving an area lands the player where the
    level really continues.  Pieces the walk cannot reach are appended at the
    end."""
    pieces = carve(st)
    if not pieces:
        return pieces, []
    all_runs = [rooms for _, rooms in pieces]
    adj = run_adjacency(all_runs)
    home = (int(st.start_x / 16) // 256, int(st.start_y / 16) // 256)
    start = next((i for i, run in enumerate(all_runs) if home in run), 0)
    order, seen = [], set()
    for root in [start] + list(range(len(all_runs))):
        if root in seen:
            continue
        stack = [root]
        while stack:
            i = stack.pop()
            if i in seen:
                continue
            seen.add(i)
            order.append(i)
            stack.extend(sorted(adj[i], reverse=True))
    links = [adj[a].get(b) for a, b in zip(order, order[1:])] + [None]
    return [pieces[i] for i in order], links


def vert_spawns(st, run, exit_cell=None):
    """A vertical area's placement list.  The axes swap: byte 0 is the row the
    camera scrolls past, byte 2 is the pixel X across the screen."""
    rows = column_rows(st, run)
    where = {my: i for i, my in enumerate(rows)}
    rx = run[0][0]
    recs = []
    for o in stage_objects(st):
        ox, oy = int(o['x_px']), int(o['y_px'])
        if ox // 256 != rx or o['param'] in SOL_DROP:
            continue
        r = where.get(oy // 16)
        if r is None:                       # the row this room had to give up
            continue
        recs.append((r, SOL_TO_PB2.get(o['param'], 0x17),
                     (ox % 256) & 0xFF, 0x80 if o['dir_gate'] else 0x00))
    if exit_cell is not None:
        c, r = exit_cell
        recs.append((min(r, 0xFE), PB2_EXIT, (c * 16) & 0xFF, 0x00))
    recs.sort(key=lambda t: t[0])
    out = bytearray()
    for t in recs:
        out += bytes(t)
    return bytes(out) + b'\xFF'


def entry_byte(cell, hud=True):
    """The per-area player start Power Blade 2 keeps in its own table: high
    nibble = screen Y / 16, low nibble = screen X / 16.  The engine turns it
    back into ($04C6, $0508) = ((b & $F0) | $0F, (b & $0F) * 16), so a cell the
    walk found is expressible exactly as long as it is on the first screen.
    `hud` adds the status bar's row, the same offset every other object gets."""
    if cell is None:
        return 0x8E
    c, r = cell
    if hud:
        r += 1
    return ((min(r, 15) & 0x0F) << 4) | (min(c, 15) & 0x0F)


def split_run(st, run, depth=0):
    """Cut a run of rooms where its band stops being walkable.

    One row of rooms becomes one Power Blade 2 area, and that area is a
    160-pixel slice of rooms that are 256 pixels tall -- so a run can easily
    contain a wall the slice has no way past, with the rest of the row sitting
    behind it as level the player never gets to see.  Cutting at the wall turns
    it into a handover instead: the part he can walk becomes its own area, and
    what is left becomes the next one, with its own slice chosen for its own
    rooms."""
    if len(run) < 2 or depth > 8:
        return [run]
    off = best_band(st, run, len(run) - 1)
    _, seen = walkable(st, run, off)
    got = {c // 16 for c, _ in seen}
    n = 0
    while n < len(run) and n in got:
        n += 1
    if n == 0 or n >= len(run):
        return [run]
    return [run[:n]] + split_run(st, run[n:], depth + 1)


def vert_exit_spot(st, run, seam):
    """Where a vertical area's exit stands: on the seam room, but on a metatile
    the walk down the shaft can actually reach."""
    b = vert_grid(st, run)
    cell = vert_entry(b)
    seen = b.reachable(*cell) if cell else set()
    if not seen:
        return None
    return pick_exit(seen, cell, lambda p: p[1] // 15, seam)


def vert_entry(b):
    """Where the player is dropped into a shaft: the highest floor in it."""
    for r in range(1, b.h):
        for c in range(b.w):
            if b.grounded(c, r):
                return c, r
    return None


def convert(stage, rom=SOL):
    r = sol_levels.Rom(rom)
    st = sol_levels.Stage(r, stage)
    remap, order, first_solid = tile_map(st)
    st.pb3_remap = remap
    st.pb3_chr = chr_window(r, st, order)
    st.pb3_collision = exact_collision(first_solid)
    walk, links = ordered_runs(st)
    # each walkable stretch of a horizontal run is its own area; the last one
    # hands over at the seam the walk found, the others at their own end.  A
    # vertical area is never split -- the whole shaft is visible in it.
    pieces, seams = [], []
    for (kind, rooms), link in zip(walk, links):
        subs = split_run(st, rooms) if kind == 'h' else [rooms]
        for k, sub in enumerate(subs):
            # a lone room is 256 pixels wide either way, so the vertical form
            # is strictly better: it shows 240 of its 256 pixels instead of 160
            pieces.append(('v' if len(sub) == 1 else kind, sub))
            seams.append(len(sub) - 1 if k + 1 < len(subs)
                         else (sub.index(link) if link in sub else len(sub) - 1))
    st.pb3_runs = [rooms for _, rooms in pieces]
    st.pb3_kinds = [kind for kind, _ in pieces]
    st.pb3_seams = seams
    screens, areas, bands, spawns, entries = [], [], [], [], []
    for i, ((kind, rooms), seam) in enumerate(zip(pieces, seams)):
        last = i + 1 == len(pieces)         # the last area has nowhere to go
        if kind == 'v':
            ids = []
            for scr in vert_area(st, rooms, remap):
                ids.append(len(screens))
                screens.append(scr)
            # the engine prefetches one screen past the camera limit, so the
            # list carries a spare entry it can read there without harm
            ids.append(ids[-1])
            areas.append(ids)
            bands.append(None)
            ex = None if last else vert_exit_spot(st, rooms, seam)
            spawns.append(vert_spawns(st, rooms, ex))
            entries.append(entry_byte(vert_entry(vert_grid(st, rooms))))
        else:
            off = best_band(st, rooms, seam)
            ids = []
            for rx, ry in rooms:
                ids.append(len(screens))
                screens.append(room_screen(st, rx, ry, off, hb=5, remap=remap))
            areas.append(ids)
            bands.append(off)
            ex = None if last else exit_spot(st, rooms, off, seam)
            spawns.append(area_spawns(st, rooms, off, ex))
            entries.append(entry_byte(entry_cell(band_grid(st, rooms, off))))
    st.pb3_spawns, st.pb3_entries = spawns, entries
    return st, screens, areas, bands


if __name__ == '__main__':
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    st, screens, areas, bands = convert(n)
    blob, ptrs = pack(screens, areas)
    print(f"solbrain stage {n}: {len(screens)} screens, {len(areas)} areas")
    for i, (a, b) in enumerate(zip(areas, bands)):
        print(f"   area {i}: {len(a)} screens, band rows {b}..{b+4}")
    print(f"  packed {len(blob)} bytes  attr=${ptrs[0]:04X} block=${ptrs[1]:04X} "
          f"area=${ptrs[2]:04X} screen=${ptrs[3]:04X}")
    print(f"  {len(st.pb3_remap)} tile numbers, solid from "
          f"{st.pb3_collision[0][0]} up")
    print("  objects per area: " +
          " ".join(str(len(x) // 4) for x in st.pb3_spawns))
    print(f"  solbrain CHR header: {st.chr_banks}")
