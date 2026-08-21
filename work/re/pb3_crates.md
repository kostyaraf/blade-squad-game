# Breakable blocks in converted Solbrain stages

Solbrain's destructible crates, running on the Power Blade 2 engine.  This is
the implementation note for the design in `pb2_breakables.md` §7.  Read that
document first; this one only records what was actually built, what the
measurements said, and where the two disagree.

## Wiring

`work/tools/crates.py` is a **post-pass over a converted stage**.  It never
touches `sol2pb2.py`.  The whole hook-up is four lines, and they are already in
`work/pb3/mkpb3.py`:

```python
import crates                                       # 1. next to `import sol2pb2`

st, screens, areas, bands = convert(n)
crate_recs = crates.apply(st, screens, areas, bands)  # 2. right after convert()

build.set_area_count(img, world, node, len(areas))
build.set_crates(img, world, node, crate_recs)         # 3. right after it
```

and, for the report line,

```python
print(f"... {sum(len(a) for a in st.pb3_crates):2d} breakable")   # 4.
```

`crates.apply()` does everything: picks the crates, allocates their tiles,
rewrites the affected screens, merges the placement records into
`st.pb3_spawns`, and returns one `$BA42` record list per area, which is exactly
what `build.set_crates` wants.

If the converter is ever restructured so that crate choice has to happen
*before* `tile_map()` runs, the lower-level route is:

```python
crates.plan(st, areas)                  # decide which cells are crates
cls = crates.tile_class(st, mx, my)     # SOFT / SOLID / CRATE, per metatile
recs   = crates.crate_records(st, run, off)   # 4-byte type-$0C placements
remaps = crates.crate_remaps(st, run, off)    # 4-byte $BA42 records
```

`tile_class` is bool-compatible with the current `solid` predicate (`SOFT` is
`0`), so it can be dropped into `tile_map()` as a third bucket above
`first_solid` without disturbing the soft/solid split.

## The measurement that changed the design

`pb2_breakables.md` §7.2 assumes a Solbrain destructible is a **32x32 block**
and specifies Tier B: six engine patches plus a 151-byte routine in bank 11's
free `$BF35-$BFFF`, so that one type-`$0C` object clears a 2x2 group of
collision cells and blanks 16 tiles.

That assumption does not hold.  Across all nine converted stages there are
**585 destructible metatiles and zero full 2x2 groups**; the largest cluster is
a side-by-side pair of two independent metatile ids, each with its own base
form, its own alternate form and its own `$0540` bit.  A Solbrain destructible
is **one 16x16 metatile**, not a 32x32 block.

Consequences:

* Stock `$0C` geometry is already right.  One crate is already one 4-byte
  placement record, one `$0680` cell and four `$0300`-queued tiles.
* Tier-B sites 1, 4, 5 and 6 (anchor `+16`, `$B44F[$0C] = $F0`,
  `$B7DC[$0C] -> $B884`, the bank-11 routine) would clear four cells and give a
  31x31 hitbox to a 16x16 block.  They are **actively wrong** here and were not
  applied.  Bank 11 `$BF35-$BFFF` is still all `$FF`; the spec's blob was never
  assembled or run.

So the object half of the feature needed **no engine patch at all**.  What was
missing was the *redraw* half.

## The real missing piece: `$BA42`

`$8AF0` blanks the crate in CIRAM once.  The moment the camera scrolls the
column off-screen and back, the fill routine redraws it from level data.  Stock
PB2 fixes this with the `$BA42` hook (bank 13): a per-stage list of 4-byte
records `(screen $0179, band $73 & $1E, tile, $3B mask)`, `$FF`-terminated,
reached through the pointer table at `$BAA8`; when a record matches and its
`$3B` bit is set, `$BA9F` substitutes tile `$00`.

Converted stages had no such list, and `$BAA8` is indexed by `$53` (0..6),
which PB3 overloads with worlds — stage 2 of world 1 would pick up stage 2 of
Power Blade 2's crate table.

Fix: move `$BA42`'s head into work RAM, which MMC3 keeps mapped at all times,
and give it a `(world * 7 + stage)` table of its own.

```
$6E00  RT_CRATE   53-byte replacement head
$7300  RT_CRTAB   21 words: (world, stage) -> that stage's per-area pointer table
$7330  RT_CRPOOL  pointer tables and records, packed
$7F00  RT_CREND   overflow assert
```

The head clears `$017A`, returns early on a boss stage (`$79`), and then:

* **world 0** — restores the original stage-2 guard and jumps back to `$BA51`,
  so stock Power Blade 2 behaves bit-identically.
* **converted world** — computes `world * 7 + stage`, loads the stage's area
  pointer table into `$10/$11`, returns if the stage has no crates at all, and
  jumps into `$BA5D`, which indexes that table by the area `$9C` and runs the
  original record scan unchanged.

Assembled (53 bytes at `$6E00`):

```
A9 00 8D 7A 01 A5 79 D0 2B AD 71 60 D0 09 A5 53 C9 02 F0 20 4C 51 BA
0A 0A 0A 38 ED 71 60 18 65 53 0A A8 B9 00 73 85 10 B9 01 73 85 11
05 10 F0 03 4C 5D BA 60
```

Because the converted path never reaches the `$53 == 2` test, **patch site 7 of
§7.2 is unnecessary** and was not applied.

## Patch table

Everything is guarded by an `img.read(...) == <original>` assert before the
write, in the existing `build.py` style.  File offsets include the 16-byte iNES
header.  PB3 keeps PB2 banks 0-13 at the same index, so these offsets are the
same in `PB2.nes` and `PB3.nes`.

| # | bank | CPU addr | base | file off | original | replacement | what |
|---|------|----------|------|----------|----------|-------------|------|
| 1 | 13 | `$BA42` | `$A000` | `$1BA52` | `A9 00 8D 7A 01` | `4C 00 6E EA EA` | `$BA42` head -> `RT_CRATE` |

That is the **only** ROM patch.  Three further reads are asserted but not
written, because the new head jumps back into them and they must not have
moved:

| bank | CPU addr | file off | bytes asserted | why |
|------|----------|----------|----------------|-----|
| 13 | `$BA51` | `$1BA61` | `0A A8 B9 A8 BA` | world-0 re-entry (stage -> `$BAA8`) |
| 13 | `$BA5D` | `$1BA6D` | `A5 9C 0A` | converted re-entry (area -> record list) |

Work-RAM writes (bank 16, the payload copied to `$6000` at boot; PRG file
offset = `16 + 16 * 0x2000 + (addr - $6000)`):

| CPU addr | file off | size | contents |
|----------|----------|------|----------|
| `$6E00` | `$20E10` | 53 | the replacement head, asserted all-zero first |
| `$7300` | `$21310` | 42 | `(world, stage)` pointer table, asserted all-zero first |
| `$7330` | `$21340` | packed | pointer tables + `$FF`-terminated record lists |

Across all nine stages the pool used well under its `$7F00` ceiling; the
`assert pool <= RT_CREND` in `set_crates` is the guard.

## Constraints from §7.2, and how each was met

**The `$3B` byte.**  Eight bits, so at most eight breakables live per area.
`crates.MAX_PER_AREA = 8`.  Candidates are ranked by Chebyshev distance to
`sol2pb2.walkable()`'s reachable set (the `reach.Band` solver), nearest first,
so the ones the player can actually get to survive the cut.  At most one crate
per `(screen, band)` pair is kept, because `$BA42` records key on
`(screen, band, tile)` and two crates in the same cell pair would share a
record.  Vertical areas are skipped entirely (`off is None`).

Cells that lose the draw stay exactly as the converter had them — soft,
walk-through.  A block nobody can break can therefore never wall off a level,
and `sol2pb2.solid_at`, which the reachability solver uses, is untouched.

**The hard-coded tile `$00`.**  `$8B2D`, `$8B32` and `$BA9F` all substitute an
immediate `$00`.  Rather than patch three immediates, the blank tile was
verified: CHR tile 0 is blank in every converted stage and
`remap[(0, False)] == 0`, so index 0 of the converted CHR is already the blank
the engine wants.  **The immediates were left unchanged.**
`crates.check_blank(st)` asserts `st.pb3_chr[:16] == b'\x00' * 16` on every
build, so this cannot rot silently.

**`$0680` solidity.**  `$DCBF` classifies a cell from its tile number against
`first_solid`.  `crates.apply()` allocates fresh tile indices *above*
`first_solid` for each chosen crate's four tiles and copies the graphics across,
so the cell reads back as class 2 / `$80`.  Confirmed at runtime: `$06DD` was
`$80` before the hit.

**Y coordinate — a bug found by the runtime test.**  In a horizontal area an
object's Y is the nametable Y **plus 16**.  The first test poked the crate into
state 2, watched the whole `$8A97` -> `$8AF0` -> `$C8A9`/`$DF21` -> `$8B1E`
chain run correctly, and changed **nothing**: the engine cleared `$06D9` and
wrote PPU `$25A8`, one metatile row too high.  Cross-checked against stock PB2
(§5.2: the stage-3 crate at Y `$80` clears nametable rows 14-15), `crates.py`
now emits byte 2 as `(row * 16 + HUD_Y) & 0xFF` with `HUD_Y = 16`.

> Not fixed here, different owner: `sol2pb2.area_spawns` / `snap_to_floor` use
> `(r - top) * 16` for enemies and the exit, and `entry_byte` puts the player at
> `row * 16 + 15`.  By the same reasoning both are 16 px too high, and that may
> be why a bot cannot walk in a converted stage.

## `crates.py` API

```python
BLANK_TILE = 0            # $8B2D / $8B32 / $BA9F all substitute tile $00
CRATE_TYPE = 0x0C
MAX_PER_AREA = 8          # $3B is one byte
SOFT, SOLID, CRATE = 0, 1, 2
BAND_ROWS = 10            # a horizontal area is 5 blocks = 10 metatile rows
HUD_Y = 16                # object Y = nametable Y + 16 in a horizontal area

crate_cells(st)                 -> frozenset of (mx, my) destructible metatiles
plan(st, areas)                 -> picks the crates; sets st.pb3_crates
choose(st, run, off)            -> that area's chosen crates, cached
                                   dicts: col row bit screen band mx my
chosen_cells(st)                -> set of (mx, my) that became real crates
tile_class(st, mx, my)          -> SOFT / SOLID / CRATE
check_blank(st)                 -> asserts CHR tile 0 is blank
crate_records(st, run, off)     -> [(col, 0x0C, row * 16 + 16, bit), ...]
crate_remaps(st, run, off)      -> [(screen, band, tile, 1 << bit), ...]
apply(st, screens, areas, bands)-> the one-call wiring; returns per-area remaps
```

`crate_records` follows `sol2pb2.area_spawns`'s convention exactly: byte 0 is
the position along the scroll axis in 16-px units, byte 1 the type, byte 2 the
position across the axis in pixels, byte 3 the flags — here the `$3B` bit index,
which is what `$8A97` EORs with.

`crate_remaps` emits **one record per distinct top tile of the cell's two tile
columns**, so one or two records per crate.  PB2's own crates need only one
because all four of their tiles are `$F7`; a converted crate's two columns
usually differ, and `$73 & $1E` is the same for both, so both need a record.

## Runtime proof

Stage-list entry 14 (`SOLBRAIN 8` = world 2, node 2 = Solbrain stage 13),
area 0.  Converter output for that area:

```
records : 04 0C 80 00   0B 0C 80 01   24 0C 80 02   2B 0C 80 03
remaps  : 00 08 63 01   00 08 64 01   00 16 63 02   00 16 64 02
          02 08 63 04   02 08 64 04   02 16 63 08   02 16 64 08
first_solid 56 ; crate tiles $63 $64 (top) $65 $66 (bottom)
```

**The bot cannot walk in any converted Solbrain stage.**  Entries 7-15 were all
swept; the player's x sticks at 16 or crawls to 144-218, while stock PB2
(entry 0) walks normally, so the input harness is fine and the converted levels
are the problem.  Both proofs therefore **poke the state directly, the way §5.2
did**.  No weapon hit was ever landed on a crate by a real player, and that is
the largest gap in this evidence.

### Proof 1 — the crate breaks

```sh
nesemu PB3.nes -input e14.inp -frames 1800 -vram A.vram@1790 -ramdump A.bin
nesemu PB3.nes -input e14.inp -frames 1800 -poke 5A1=02@1750 \
       -vram B.vram@1790 -ramdump B.bin -trace tb.txt \
       -tracefrom 1745 -traceto 1800 -tracepc FFFE-FFFF -watch 0680-06FF
```

`$05A1` is object slot `$15`, the col-4 crate (`Xlo = $48`, `Ylo = $80`).
Poking its state to 2 is exactly the hit path: `$B688`/`$B6F1` do nothing else.

```
WATCH 1750,DF33,62,06DD,00        <- the collision cell goes solid -> 0
$3B      A=00  B=01               <- the object's bit is now set
$06DD    A=80  B=00
4 CIRAM bytes differ
  page1 col8 row14  63 -> 00
  page1 col9 row14  64 -> 00
  page1 col8 row15  65 -> 00
  page1 col9 row15  66 -> 00
```

The trace shows the full chain: `$8A5D` -> `$8A97` (EOR `$3B`) -> `$8AF0` ->
`$C8A9`/`$DF21` -> `$8B1E`, which queues command `$01` at PPU `$25A8` with two
`$00` tiles and an `$FF` terminator.  No attribute byte changed.

### Proof 2 — the block stays gone across a refill

The redraw hook only matters when the column is refilled, so the camera has to
scroll away and back.  Since the bot cannot walk, the player's x (`$04F2`
high, `$0508` low) was poked forward in 16-px steps every 3 frames from 72 to
616 and back, and `$3B` was frozen at `$FF` so every crate in the area counts
as broken.  Control run: identical pokes, no freeze.

```sh
nesemu PB3.nes -input e14.inp -frames 2020 <x pokes> \
       -vram D0.vram@2015 -ramdump D0.bin
nesemu PB3.nes -input e14.inp -frames 2020 <x pokes> -freeze 3B=FF \
       -vram D1.vram@2015 -ramdump D1.bin -trace td2.txt \
       -tracefrom 1800 -traceto 2020 -tracepc BA9F-BAA0
```

```
8 CIRAM bytes differ
  page1 col 8 row10  63 -> 00      page1 col22 row10  63 -> 00
  page1 col 9 row10  64 -> 00      page1 col23 row10  64 -> 00
  page1 col 8 row11  65 -> 00      page1 col22 row11  65 -> 00
  page1 col 9 row11  66 -> 00      page1 col23 row11  66 -> 00
13:BA9F hits: 4
```

Four hits on `$BA9F` — two crates, two tile columns each, exactly the record
count `crate_remaps` emits — and the refilled columns come back blank instead
of `$63/$64/$65/$66`.  The hook works in a converted stage.

Caveat, stated plainly: the poke-walk carried the player over the area boundary,
so this capture is of **area 1**, not area 0.  Area 1's own crates are the ones
at cols 8-9 and 22-23.  That makes it a valid proof of the mechanism on a
converted stage, but it is not the same area as proof 1.

Trace-filter note: `-tracepc` matches an address in **any** bank, and bank 9 is
also mapped at `$A000` much of the time.  An earlier `grep BA9F` counted bank-9
`ADC $0508` instructions as hook substitutions.  All counts above are filtered
on the literal string `13:BA9F`.

## Not verified

* **No real hit.**  Every proof pokes state 2 or freezes `$3B`.  The bot cannot
  walk in a converted Solbrain stage, so no weapon has ever struck one of these
  crates in a running game.  The path from a hit to state 2 (`$B688`/`$B6F1`)
  is stock engine code and unmodified, but it is untested here.
* **Vertical areas** are excluded outright — `choose()` returns nothing when
  `off is None`.  Their crates are simply left as soft tiles.
* **The spec's Tier-B bank-11 routine was never assembled or run.**  It is not
  needed for 16x16 destructibles and it is not in the image.
* **Item drops.**  Stock crates can drop pickups; nothing here configures a
  drop, so converted crates just vanish.
* **Only entry 14 was tested at runtime.**  The other eight converted stages
  build and pass `playtest.py`, but their crates were not individually driven.

## Build status

```
python3 work/pb3/mkpb3.py      # 9 stages, 218 breakables
                               #   5, 3, 75, 10, 7, 23, 8, 79, 8
python3 work/pb3/playtest.py   # 16/16 stages reach gameplay
                               # two players: $27=3 want2p=1 slot5=11  ok
```
