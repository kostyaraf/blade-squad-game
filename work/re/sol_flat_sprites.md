# Solbrain: the two flat sprite emitters

Target ROM: `Tokkyuu Shirei Solbrain (Japan).nes` — MMC3, 128 KB PRG, 128 KB CHR.

The hero and every object in the `$0600` pool are drawn by the *picture composer*
`$C009` -> `$F3F0`: a numbered picture, a script of steps and tiles, flips, a CHR
bank. The other two pools — the shot pool at `$0780` (bank 3) and the weapon pool
at `$0700` (bank 13) — never call it. They call one of two much smaller routines
that put a fixed tile straight into the sprite table. This file is the full
account of those two and of the frame reset they share.

---

## 1. The table cursors

Four zero-page bytes carry the drawing from one sprite to the next.

| byte  | meaning                                                    |
|-------|------------------------------------------------------------|
| `$69` | where both cursors started this frame                      |
| `$6A` | how many sprites have been written                         |
| `$6B` | which end goes next (bit 0)                                |
| `$6C` | the forward cursor, an offset into `$0200`                 |
| `$6D` | the backward cursor                                        |

The table is written from both ends at once and which end alternates every
sprite. That is not tidiness: the console draws only the first eight sprites it
finds on a scanline, so shuffling which sprite sits where makes the dropped one
change from frame to frame instead of always being the same arm.

`$0200..$021F` (entries 0..7) belongs to the bar at the bottom of the screen.
Neither cursor ever goes below `$20`.

## 2. `$C72D` — the top of the frame (bank 14)

```
$6B = $00                       ; the frame counter decides which end goes first
$6A = 0
$69 = $69 + $50                 ; and if that leaves it below $20, + $E0
$6C = $69
$6D = $6C - 1                   ; or $FF when that would fall below $20
for a = $0220 to $02F0 step $10 ; and the same four bytes into each $x4
    [a] = $F7                   ; the down byte of an unused sprite
```

Only the *down* byte of each entry is parked at `$F7`; the other three are left
holding last frame's values and are overwritten as sprites are written.

Moving `$69` on by `$50` every frame is what makes the flicker even: a sprite
that was written late this frame is written early the next.

## 3. `$C01B` -> `$E554` (bank 15) — two sprites side by side

In:

* `$90:$91` x and `$92:$93` y, in sixteenths of a pixel, **already less the
  camera**
* `$9E` the left tile, `$9F` the right tile
* `A` the left attribute, `Y` the right attribute

`#$0080` comes off both axes (half of the two-sprite box), then both are shifted
four down to whole pixels. If either high byte survives the shift the pair is off
the picture and nothing is drawn.

Otherwise `$6B` is bumped and its bit 0 picks the end. Forward: two entries at
`$6C`, the second eight pixels to the right, the cursor wrapping to `#$30` when
it runs off the top of the table. Backward: the same at `$6D`, with a floor of
`#$20` below which the cursor jumps to `#$FF` — and the backward end is skipped
entirely once `$6A >= #$3A`.

`$6A` is **not** bumped by either emitter. Only the picture composer counts.

## 4. `$C030` -> `$EA0E` (bank 15) — one sprite

The same, with three differences: `#$0040` comes off both axes instead of
`#$0080`, the tile is in `Y` and the attribute in `A`, and the backward floor is
`#$30` instead of `#$20`.

## 5. Where they are called

```
bank  3, the pair:  AF0E B44E B48F B4FB B561 B5D3 B628 B785 B93A B9E6 BB90
                    BB9B BBE3 BC44
bank  3, the one:   B4B9 B641 B73D B74F B892 B8E2 BA4B BA59 BB78 BC51 BD4C
bank 13, the pair:  B3EB B446 B4B1 B58F B5FB B615 B769
bank 13, the one:   B285 B429
bank  1, the one:   B59A                       (not either pool)
```

Neither pool ever calls `$C009`. Bank 13 does once, at `$A564`, and that is not
the weapon pool.

## 6. The place, and what happens when it will not fit

Before the emitter the four scratch bytes are filled by one of three routines.

* **`$BCF7`** (bank 3, the shot pool) — x and y less the camera; if either high
  byte comes out `>= $10` the slot is given up (`$BD4F` writes `$00` into
  `$0780,X`) and the routine returns. It returns to the *behaviour*, which is
  free to carry on: of the twenty eight behaviours that draw after it, only four
  ask whether the slot survived — `$B54A`, `$B567`, `$BB6E`, `$BD2D`. The other
  twenty four draw anyway, at whatever the scratch is left holding. Note also
  that the low byte of each axis is stored *before* the high byte is tested, so
  a slot given up here leaves half a place behind it.
* **`$BCDF`** (bank 3) — the same, except a y that comes out above the screen
  (borrow) is kept instead of being rejected.
* **`$B595`** (bank 13, the weapon pool) — the same shape as `$BCF7`, giving the
  slot up through `$B5BC`.
* **`$B76F`** (bank 13) — x and y less the camera and nothing given up at all.
  Only the ring that turns about the satellite uses it.

## 7. The tiles, pool by pool

The weapon pool (bank 13):

| site    | behaviour                     | drawn as                                       |
|---------|-------------------------------|------------------------------------------------|
| `$B3EB` | bounces off the walls         | pair `$51`/`$01`,`$C1` or `$53`/`$02`,`$C2` by `$0C & 2` |
| `$B429` | goes straight on              | one `$55`, attr `$41` or `$01` by `$0C & 4`    |
| `$B446` | carried, count still running  | pair `$57`,`$57` / `$01`,`$C1` (the puff)      |
| `$B4B1` | carried, count out            | pair out of `$59 $5B $5D $5F` by its heading   |
| `$B58F` | widening, crawling            | the puff by `$0C & 2`, else pair `$55` `$02`,`$C2` |
| `$B5FB` | spinning outwards             | pair `$49` or `$4B` / `$02`,`$42` by its life  |
| `$B615` | thrown, and coming back       | pair `$5D` or `$5F` / `$02`,`$C2` by `$0C & 4` |
| `$B769` | the ring about the satellite  | pair `$55`/`$01`,`$41` or `$57`/`$02`,`$42`    |
| `$B285` | the slash                     | a column of `$FF`, then `$FD`, topped with `$FB` |

The slash is the odd one: one slot stands for a whole row of sprites drawn one
above the other, and `$B23B` walks the row by letting the carry of `$B26C`'s add
run on into the next turn's subtraction. The row is cut off at the lift height
the stage keeps in `$75`.

The shot pool's own map is the same shape and is written out in the port
(`game/src/sol_shots.gd`), site by site, against these addresses.

## Restored object-pool exception: `$AED9` (2026-10-03)

The `$0600` pool also has a direct flat emitter: types `$0E/$0C` call
`$AED9` from `$AC75/$AE7B`. Their numbered picture `$01B2` intentionally
has CHR `$FF`; it supplies contact metadata but no OAM. `$AED9` uses the
pre-movement screen coordinates `$5C..$5F`, body tile `$B1`, tail
`$B3 + (Y & 2)`, and attributes `$02` or mirrored `$42`. Falling passes
`Y=$FF`; hovering passes the frame counter. `$AF0E` emits the pair through
`$C01B`. Both calls now share the live level's `SolObjects.table`.

`verify_pb3_hatch_render.py` compares original NES RAM immediately before
`$AED9` and at `$AF11`, including the entire OAM and its cursors.
