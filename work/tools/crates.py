"""Solbrain's destructible blocks, as Power Blade 2 type-$0C breakables.

Everything the converter needs in order to turn a Solbrain destructible block
into a Power Blade 2 breakable is here; `sol2pb2` is left alone on purpose.
See `work/re/pb3_crates.md` for the wiring and the engine patches, and
`work/re/pb2_breakables.md` for how the engine mechanism itself works.

The one fact that decides the whole design: **a Solbrain destructible is one
16x16 metatile, not a 32x32 block.**  Solbrain gives every single instance its
own metatile id -- that is how its per-metatile `$0540` bitmap remembers which
one was smashed -- and the id's `alt` form is the intact block.  Measured over
all nine converted stages, 585 destructible metatiles form 0 full 2x2 groups;
the largest group is a side-by-side pair, and even those are two independent
ids with independent bits.  Power Blade 2's stock type `$0C` already covers
exactly one 16x16 cell, so the geometry needs no engine change at all
(`pb2_breakables.md` §7.2 "Tier A"), and one crate is already one placement
record.

What *is* missing for a converted stage is the `$BA42` half: the redraw hook
that keeps a smashed block smashed while the camera refills its column.  Its
tables are hard-wired to Power Blade 2's own seven stages, so PB3 gives it new
ones in work RAM -- see `build.crates_code` / `build.set_crates`.

Constraints this module enforces, all from `pb2_breakables.md`:

* `$3B` is **eight bits per area**, so at most 8 breakables per area
  (`MAX_PER_AREA`); the ones nearest the player's route win.
* A `$BA42` record has no coordinate across the scroll axis, so it blanks
  *every* 16-px pair in its (screen, band) whose leading tile matches.  Two
  breakables in the same screen and the same 16-px column would therefore
  smash each other, so only one per (screen, band, tile) is ever chosen.
* The replacement tile is hard-coded `$00` at `$8B2D`/`$8B32` and `$BA9F`.
  Tile 0 of a converted stage's pattern table is blank -- `check_blank`
  asserts it -- so the immediates are left as they are.
* The `$0680` collision cache has to hold class 2 for an intact block, which
  it gets from the tile number: `tile_class` puts a chosen block's tiles in
  their own band above `first_solid`, so `$DCBF` calls them solid.  A block
  that was *not* chosen keeps today's behaviour and stays walk-through, so a
  level can never be walled off by a breakable nobody can break.
* Only horizontal areas are used.  In a vertical area the mapping from a row
  to a `$BA42` band is unproven (`pb2_breakables.md` §3, UNRESOLVED).
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sol2pb2

# --- what the converter has to know ----------------------------------------
BLANK_TILE = 0          # $8B2D/$8B32/$BA9F all substitute tile $00
CRATE_TYPE = 0x0C       # the engine's breakable-block object type
MAX_PER_AREA = 8        # $3B is one byte, one bit per breakable

SOFT, SOLID, CRATE = 0, 1, 2        # the three tile classes `tile_map` needs

BAND_ROWS = 10          # a horizontal area is 5 blocks = 10 metatile rows

# In a horizontal area an object's Y is the nametable Y **plus 16**: $DF52
# turns an object Y into a cell with `$E0 + y` and the 240-vs-256 wrap, and
# measured against a converted stage 13 that lands the top nametable row at
# object Y 16, not 0.  (Cross-checks against stock Power Blade 2: the stage 3
# crate placed at Y $80 clears nametable rows 14-15 = nametable Y 112-127 --
# `pb2_breakables.md` §5.2.)  Everything the converter draws starts at
# nametable Y 0, so a block on band row `r` is at object Y `r * 16 + 16`.
HUD_Y = 16


def crate_cells(st):
    """Every destructible 16x16 metatile in the stage, as (mx, my)."""
    got = getattr(st, '_crate_all', None)
    if got is None:
        got = set()
        for rx, ry in st.used_rooms():
            for mx in range(rx * 16, rx * 16 + 16):
                for my in range(ry * 16, ry * 16 + 16):
                    if sol2pb2.breakable(st, mx, my):
                        got.add((mx, my))
        st._crate_all = got = frozenset(got)
    return got


# --- choosing which ones become breakable ----------------------------------
def _key(run, off):
    return (tuple(run), off)


def choose(st, run, off):
    """The breakables of one horizontal area, already capped and sorted.

    Returns a list of dicts, one per chosen block, in placement order (which is
    the order Power Blade 2's placement scan wants), with the `$3B` bit index
    already assigned:

        col     metatile column inside the area, 0-based  -> record byte 0
        row     metatile row inside the 5-block band, 0-9
        bit     0..7, the `$3B` bit
        screen  index of the room inside the area         -> remap byte 0
        band    tile column inside that room, even        -> remap byte 1
        mx, my  the Solbrain metatile the block came from
    """
    cache = st.__dict__.setdefault('_crate_plan', {})
    k = _key(run, off)
    if k in cache:
        return cache[k]
    cache[k] = out = _choose(st, run, off)
    return out


def _choose(st, run, off):
    if off is None:                 # a vertical area: see the module docstring
        return []
    cells = crate_cells(st)
    if not cells:
        return []
    top = run[0][1] * 16 + off * 2
    cand = []
    for i, (rx, ry) in enumerate(run):
        for k in range(16):
            mx = rx * 16 + k
            for r in range(BAND_ROWS):
                my = top + r
                if (mx, my) in cells:
                    cand.append(dict(col=i * 16 + k, row=r, screen=i,
                                     band=(k * 2) & 0x1E, mx=mx, my=my))
    if not cand:
        return []

    # ... how far is each one from somewhere the player actually stands?
    _, seen = sol2pb2.walkable(st, run, off)
    def far(c):
        if not seen:
            return 0
        return min(max(abs(sc - c['col']), abs(sr - c['row'])) for sc, sr in seen)

    # one per (screen, band): a $BA42 record has no across-axis coordinate, so
    # two blocks sharing a 16-px column of a screen would blank each other
    best = {}
    for c in cand:
        if c['col'] > 0xFE:
            continue
        s = (c['screen'], c['band'])
        if s not in best or far(c) < far(best[s]):
            best[s] = c
    picked = sorted(best.values(), key=far)[:MAX_PER_AREA]
    picked.sort(key=lambda c: (c['col'], c['row']))
    for bit, c in enumerate(picked):
        c['bit'] = bit
    return picked


def plan(st, areas):
    """Run `choose` over every area of a stage and remember the result.

    `areas` is a list of (kind, rooms, off); a vertical area contributes
    nothing.  Must be called before `tile_map`, because that is what asks
    `tile_class` which cells are breakable.  Returns the per-area lists."""
    out = []
    for kind, rooms, band in areas:
        out.append(choose(st, rooms, band if kind == 'h' else None))
    st.pb3_crates = out
    st._crate_chosen = frozenset((c['mx'], c['my']) for a in out for c in a)
    return out


def chosen_cells(st):
    """The metatiles `plan` turned into real breakables."""
    return getattr(st, '_crate_chosen', frozenset())


# --- the tile-numbering hook ------------------------------------------------
def tile_class(st, mx, my):
    """`SOFT`, `SOLID` or `CRATE` for one 16x16 metatile.

    A drop-in for `sol2pb2.solid_at` inside `tile_map`, `room_screen` and
    `vert_screen`: `SOFT`/`SOLID` are 0/1, so they compare equal to the
    `False`/`True` those places used before.  `CRATE` is the third class, and
    it exists so a chosen block gets tile numbers of its own -- numbers that
    are solid to `$DCBF` and that no ordinary scenery shares, which is what
    makes a `$BA42` record safe to key on the tile alone."""
    if (mx, my) in chosen_cells(st):
        return CRATE
    return SOLID if sol2pb2.solid_at(st, mx, my) else SOFT


def check_blank(st):
    """`$8B2D`, `$8B32` and `$BA9F` all write tile `$00`, so tile 0 of the
    stage's rebuilt pattern table has to be empty.  It always is: Solbrain
    tile 0 is blank and is the lowest non-solid tile number every stage uses,
    so `tile_map` hands it index 0.  Checked rather than assumed."""
    assert st.pb3_chr[:16] == b'\x00' * 16, \
        "tile 0 of the converted CHR is not blank -- change the $00 " \
        "immediates at $8B2D/$8B32 (bank 10) and $BA9F+1 (bank 13)"
    return True


# --- the two record lists ---------------------------------------------------
def crate_records(st, run, off):
    """One area's type-`$0C` placement records, 4 bytes each.

    Same convention as `sol2pb2.area_spawns`: byte 0 = position along the
    scroll axis in 16-px units, byte 1 = the object type, byte 2 = position
    across the axis in pixels, byte 3 = flags -- which for a `$0C` is the
    `$3B` bit *index*, 0-7 (`$8A80`: `LDA $049A,X / TAY / LDA $BE36,Y`).

    `HUD_Y` is the reason byte 2 is not simply `row * 16`: see its comment."""
    return [(c['col'], CRATE_TYPE, (c['row'] * 16 + HUD_Y) & 0xFF, c['bit'])
            for c in choose(st, run, off)]


def crate_remaps(st, run, off):
    """One area's `$BA42` records, 4 bytes each, in the order `$BA76` scans.

    byte 0 = `$0179`, the screen index inside the area;
    byte 1 = `$73 & $1E`, the 16-px band along the scroll axis, in tiles;
    byte 2 = the tile number to substitute, matched against the leading tile
             of the pair;
    byte 3 = the `$3B` **mask** (`$01`, `$02`, `$04`, ...), not the index.

    A horizontal area is filled one tile column at a time, so the leading tile
    of a pair is always its top one, and `$73 & $1E` is the same for both
    columns of a 16x16 cell.  The cell's two top tiles therefore both key the
    same band, and each needs its own record unless they carry the same
    number -- Power Blade 2's own breakables get away with one record per cell
    only because all four of their tiles are the same tile ($F7 on stage 3,
    see `pb2_breakables.md` §5.2).  So: one or two records per block.

    The list still needs its `$FF` terminator, which `build.set_crates`
    appends."""
    remap = st.pb3_remap
    out = []
    for c in choose(st, run, off):
        seen = []
        for dx in (0, 1):                  # the two columns of the cell
            t = remap[(st.tile_at(c['mx'] * 2 + dx, c['my'] * 2), CRATE)]
            if t not in seen:
                seen.append(t)
                out.append((c['screen'], c['band'], t, 1 << c['bit']))
    return out


# --- one-call wiring --------------------------------------------------------
#
# `apply` does after `convert` what `tile_class` would have done inside it, so
# that `sol2pb2` needs no edit at all: it hands the chosen blocks tile numbers
# of their own at the top of the stage's pattern table (above `first_solid`,
# so `$DCBF` calls them solid), copies their graphics into the spare CHR,
# rewrites those cells in the screens that hold them, and appends the type
# `$0C` placement records.  The `## Wiring` section of work/re/pb3_crates.md
# spells out the alternative -- doing it inside `convert` through
# `tile_class` -- for whenever `sol2pb2` is next opened anyway.

def _src_window(st):
    """The stage's own 4 KB of Solbrain background CHR, tile-number indexed --
    the same window `sol2pb2.chr_window` copies out of."""
    import sol_levels
    r = sol_levels.Rom(sol2pb2.SOL)
    b = st.chr_banks
    return b''.join(r.chr[k * 0x400: (k + 1) * 0x400]
                    for k in (b[0] & 0xFE, (b[0] & 0xFE) + 1,
                              b[1] & 0xFE, (b[1] & 0xFE) + 1))


def _tile(st, tx, ty):
    return st.tile_at(tx, ty) or 0


def apply(st, screens, areas, bands):
    """Make the chosen blocks breakable in an already converted stage.

    Returns one list of `$BA42` records per area, ready for
    `build.set_crates`.  `st.pb3_chr`, `st.pb3_remap` and `st.pb3_spawns` are
    updated in place, as are the `Screen`s that hold a block."""
    kinds = getattr(st, 'pb3_kinds', ['h'] * len(st.pb3_runs))
    plan(st, list(zip(kinds, st.pb3_runs, bands)))
    check_blank(st)

    # --- tile numbers of their own, and the CHR to go with them ------------
    src = _src_window(st)
    chr_ = bytearray(st.pb3_chr)
    nxt = max(st.pb3_remap.values()) + 1
    for i, (run, off) in enumerate(zip(st.pb3_runs, bands)):
        for c in choose(st, run, off):
            for dy in (0, 1):
                for dx in (0, 1):
                    t = _tile(st, c['mx'] * 2 + dx, c['my'] * 2 + dy)
                    if (t, CRATE) in st.pb3_remap:
                        continue
                    assert nxt < 256, "no room left in the pattern table"
                    st.pb3_remap[(t, CRATE)] = nxt
                    chr_[nxt * 16: nxt * 16 + 16] = src[t * 16: t * 16 + 16]
                    nxt += 1
    st.pb3_chr = bytes(chr_)

    # --- draw them with those numbers --------------------------------------
    for i, (run, off) in enumerate(zip(st.pb3_runs, bands)):
        for c in choose(st, run, off):
            rx, ry = run[c['screen']]
            scr = screens[areas[i][c['screen']]]
            tx0, ty0 = c['mx'] * 2 - rx * 32, c['my'] * 2 - (ry * 8 + off) * 4
            for dy in (0, 1):
                for dx in (0, 1):
                    t = _tile(st, c['mx'] * 2 + dx, c['my'] * 2 + dy)
                    scr.tiles[ty0 + dy][tx0 + dx] = st.pb3_remap[(t, CRATE)]

    # --- the two record lists ----------------------------------------------
    out = []
    for i, (run, off) in enumerate(zip(st.pb3_runs, bands)):
        recs = crate_records(st, run, off)
        if recs:
            st.pb3_spawns[i] = _merge(st.pb3_spawns[i], recs)
        out.append(crate_remaps(st, run, off))
    return out


def _merge(blob, recs):
    """Add placement records to an area's `$FF`-terminated list, keeping it
    sorted on byte 0 the way the engine's scan expects."""
    old = [tuple(blob[i:i + 4]) for i in range(0, len(blob) - 1, 4)]
    all_ = sorted(old + [tuple(r) for r in recs], key=lambda r: r[0])
    return b''.join(bytes(r) for r in all_) + b'\xFF'


if __name__ == '__main__':
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    st, screens, areas, bands = sol2pb2.convert(n)
    remaps = apply(st, screens, areas, bands)
    print(f"solbrain stage {n}: {len(crate_cells(st))} destructible metatiles, "
          f"{sum(len(a) for a in st.pb3_crates)} made breakable")
    for i, a in enumerate(st.pb3_crates):
        if a:
            print(f"   area {i:2d}: " + "  ".join(
                "%02X %02X %02X %02X" % r
                for r in crate_records(st, st.pb3_runs[i], bands[i])))
            print("             remap " + "  ".join(
                "%02X %02X %02X %02X" % r for r in remaps[i]))
