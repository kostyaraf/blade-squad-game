# Power Blade 2 — vertical (`$97 = 1`) areas, complete specification

Scope: everything the engine needs to run an area whose scroll axis is vertical,
proven from bank 14/15 disassembly (`work/re/b14.asm`, `work/re/b15.asm`) and
from live captures of the stock ROM.

Prerequisites assumed, not re-derived: `work/re/pb2_area_records.md` (the
`$E2BC` → area-record chain and the 14-byte field map) and
`work/re/pb2_level_format.md` (blocks / screens / area lists).

---

## 0. Summary of the answers

| # | Field | Answer |
|---|-------|--------|
| 1 | `$73` | Nametable row (0..29) where the initial fill starts = four rows above the camera top. **`$73 = (($67 >> 3) + 26) mod 30`**. Derived, not free. |
| 2 | `$66`/`$67` | Camera **top** edge, mixed radix: `$66` = index into the screen list (240 px each), `$67` = 0..239 within it. Absolute Y = `$66*240 + $67`. Top of area = `(0,0)`; bottom = exactly the limit. |
| 3 | `$59`/`$5A` | The **maximum** camera Y in the same units. Minimum is hard-coded 0. For an area that uses all N screens: `$59 = N-1`, `$5A = $40` (= `N*240 - 176`). |
| 4 | `$FC` | The raw PPU Y scroll written to `$2005`. In a vertical area it is kept identical to `$67` forever. Record byte 11 must equal record byte 4. |
| 5 | `$AE` | Copied to `$87`; selects the raster/IRQ mode (split scanline + handler), the parallax strips, and the synthesised-terrain modes. **`$01` = plain**, used by 21 of the 24 stock vertical areas. |
| 6 | Screen list | Ordered **top → bottom**, index 0 topmost. Each entry occupies **240 visible px**, although a vertical screen is 64 bytes = 256 px of data: the bottom 16 px are never drawn. |
| 7 | Player entry | **Not in the record.** A separate table at `$F0A4[stage]`, one byte per area. Camera then follows the player with a dead zone at screen Y 96..103. |
| 8 | Other per-axis state | 10 `$97` branch points, listed in §9. Mirroring is *always* vertical; `$FD` (X scroll) is forced to 0; the whole area lives in one wrapping 240-px nametable page. |

---

## 1. Geometry: one 240-pixel page that wraps

`sub_EC11` (bank 15) ends with

```
EC56  A9 00       LDA #$00
EC58  8D 00 A0    STA $A000        ; MMC3 mirroring = 0 = VERTICAL
```

and the same store appears at `$E60B` and `$ECA3`. Mirroring is never taken
from the area record. Vertical mirroring aliases `$2000 ≡ $2800` and
`$2400 ≡ $2C00`, so a **vertical** scroll has only **one** 30-row page
available, and it wraps at 240 px.

Every counter in the engine agrees:

* `$67` (camera sub-position) wraps at `#$F0` = 240 — `sub_DAAB`:
  `INC $67 / CMP #$F0 / BNE + / INC $66 / $67 = 0`.
* `$FC` (PPU scroll Y) wraps at `#$F0` in lockstep.
* `$73`/`$74` (nametable row, fill-row counter) wrap at `#$1E` = 30.

Per-scanline PPU `v` capture from a live vertical area (stage 5 area 0, camera
at Y = 151) shows nametable 0 with coarse-Y running 151→239 for scanlines
0..88, then nametable **2** with coarse-Y 0 from scanline 89 — i.e. the
hardware wrap of a single page, exactly as predicted.

**The visible playfield is 176 px, not 240.** `$EAA5`/`$EB1A` pick the MMC3 IRQ
latch from `$87` (= `$AE`); for `$87 = 1` the latch is `$AF` = 175, so the split
fires after 176 scanlines and the bottom 64 scanlines show the HUD out of
nametable 1 (`$2400`). The 64 px of the wrapping page below the camera window
are therefore an off-screen prefetch buffer, never displayed.

Mapping, used everywhere below:

```
absolute level pixel Y  =  $66 * 240 + $67
absolute tile row  a    ->  screen  a div 30 ,  row within screen  a mod 30
                            nametable row = a mod 30   (same number)
```

The engine computes `$66*240 + $67` literally, at `$E3F3` (spawn scan) and at
`$FDAC`/`$FE28` (object world↔screen conversion):

```
$DFB4  $A3 = (($66 & 15) << 4) | ($67 >> 4)
$E3F3  $08 = $A3 - ($A3 >> 4)          = $66*15 + $67/16   (16-px row index)
       $09/$0A = $A3*256 + $67 - (($66*16) & $FF) = $66*240 + $67
```

### Screens are 256 px of data but only 240 px are drawn

`sub_DBDE` (row fill) computes the screen byte index as

```
DBDE  ... PPUADDR = $2000 + $73*32
      $08 = ($73 & $1C) << 1        ; = ($73 >> 2 & 7) * 8   -> block row 0..7
      $02 = ($73 & 3) << 2          ; tile sub-row 0..3 inside the block
```

with `$73` bounded to 0..29. `$73 = 28,29` give block row 7, sub-rows 0 and 1.
**Block row 7 is only ever drawn as its top 16 px; the bottom 16 px of every
vertical screen is dead data.** For the Solbrain port this is the single most
important constraint: a 256×256 room loses its bottom 16 px, and its bottom
block row is rendered half height.

Verification: an offline model of the initial fill (rows `$73` … `$73+29`
walking the screen list, wrapping at 30) reproduced the live nametable
**960/960 bytes** on all six sampled vertical areas, and the steady-state
sliding window `[camrow-4, camrow+25]` reproduced **960/960** on three
mid-scroll captures. Any other screen height fails immediately.

---

## 2. Q1 — `$73`

`$E093` (reached from the vertical init `$E04F`):

```
E093  A5 73    LDA $73
E095  38       SEC
E096  E9 04    SBC #$04
E098  90 03    BCC loc_E09D       ; $73 < 4  -> start from screen $66-1
E09A  4C B7 E0 JMP loc_E0B7       ; $73 >= 4 -> start from screen $66
E09D  A5 66    LDA $66 / SEC / SBC #$01 / JMP loc_E0B9
```

and the fill loop `$E1BA`:

```
E1BA  JSR $DBDE          ; one row of tiles
E1BD  JSR $DC73          ; the matching attributes
E1C0  INC $73
E1C2  LDA $73 / CMP #$1E / BNE E1CF
E1C8  LDA #$00 / STA $73 / JSR sub_E10C     ; row wrapped -> advance the screen
E1CF  INC $74 / LDA $74 / CMP #$1E / BEQ done
```

So `$73` is the **nametable row the fill starts at**, and it is filled for 30
consecutive rows (`$74` counts to 30). The `SBC #$04` says the fill begins
**four rows (32 px) above the camera top**: the engine keeps a 32-px margin
above and 32 px below the 176-px window (32 + 176 + 32 = 240).

Therefore

```
$73 = ((camera_top_pixel / 8) - 4) mod 30
    = ((($67 >> 3) + 26) mod 30)          # $67 is 0..239, so $67>>3 is 0..29
```

**Checked against all 24 stock vertical records: 24/24 exact.** All 39
horizontal records have `$73 = 0`.

Worked examples:

| area | `$67` | `$67>>3` | `+26 mod 30` | record `$73` |
|------|-------|----------|--------------|--------------|
| stage 1 area 1 | `$00` = 0   | 0  | 26 = `$1A` | `$1A` ✓ |
| stage 0 area 1 | `$90` = 144 | 18 | 44 mod 30 = 14 = `$0E` | `$0E` ✓ |
| stage 0 area 3 | `$E0` = 224 | 28 | 54 mod 30 = 24 = `$18` | `$18` ✓ |
| stage 2 area 3 | `$40` = 64  | 8  | 34 mod 30 = 4 = `$04` | `$04` ✓ |
| stage 5 area 0 | `$00` = 0   | 0  | 26 = `$1A` | `$1A` ✓ |

Only four distinct values occur in the ROM (`$1A, $0E, $18, $04`) because only
four distinct entry `$67` values occur (`$00, $90, $E0, $40`).

The maintenance rule matches: `sub_DAAB` does `INC $73` per pixel scrolled with
`if $73 == $1E then $73 = 0`; `sub_DA52` does `DEC $73` with `$FF → $1D`.

---

## 3. Q2 — `$66` / `$67`

`$66` and `$67` are the camera's **top edge** on the scroll axis, in mixed
radix: `$66` counts whole screens of **240** px, `$67` is the remainder 0..239.
`$66` is used directly as the index into the area's screen list — `$E0B9`:

```
E0B9  ... TAY ; LDA ($02),Y      ; $02/$03 = area list, Y = camera screen
      ...     ; $70/$71 = screen_table[that index]
```

Stock areas start either at the very top `(0, 0)` or at exactly the camera
limit `($59, $5A)` (climb-up areas). Both patterns occur; nothing in between.

| area | start `$66/$67` | = px | limit `$59/$5A` | = px | entry |
|------|-----------------|------|-----------------|------|-------|
| stage 0 area 1 | `00 90` | 144 | `00 90` | 144 | bottom |
| stage 1 area 1 | `00 00` | 0   | `01 40` | 304 | top |
| stage 2 area 0 | `01 E0` | 464 | `01 E0` | 464 | bottom |
| stage 2 area 3 | `03 40` | 784 | `03 40` | 784 | bottom |
| stage 3 area 5 | `00 00` | 0   | `00 90` | 144 | top |
| stage 5 area 0 | `00 00` | 0   | `04 00` | 960 | top |

Live confirmation (`shots/vertical/s0a1_entry.png`,
`s2a0_entry.png`, `s2a3_entry.png`, `s3a5_entry.png`,
`s5a0_descending.png`): entry RAM matches the record byte for byte in all six
cases, and each screenshot shows a real, playable shaft.

---

## 4. Q3 — `$59` / `$5A`

Same units as `$66/$67`; this is the **maximum** (bottom-most) camera position.
`sub_DAAB` (scroll down) opens with the clamp:

```
DAAB  LDA $67 / CMP $5A / BNE go
      LDA $66 / CMP $59 / BNE go
      $60 = 0 ; $21 = 0 ; RTS          ; hard stop, no scroll this frame
```

The minimum is **not** a variable — `sub_DA52` (scroll up) stops when
`$66 | $67 == 0`, i.e. hard-coded absolute Y = 0. So the camera range is
`0 .. $59*240 + $5A`, and the visible level extent is
`0 .. $59*240 + $5A + 176`.

Span in screens is therefore implied but not stored. For an area whose N
screens are all fully used:

```
camera_max = N*240 - 176 = (N-1)*240 + 64   ->   $59 = N-1,  $5A = $40
```

Stock precedents for exactly that value: stage 1 areas 1/4/6 and stage 3 area 1
(N = 2 → `01 40`), and stage 3 area 3 (N = 4 → `03 40`).

Many stock areas set a *smaller* limit than their screen count allows, because
the bottom of the last screen is padding — e.g. stage 0 area 1 has 2 screens
(480 px) but a limit of 144, so only 320 px are reachable. **`$59/$5A` is a free
authored constant, not a function of the list length.** Five of the six sampled
areas satisfy `limit = authored_content_height - 176` exactly; stage 5 area 0
is 64 px short of that, and it is a uniformly repeating shaft where the
difference is invisible.

### Runtime proof

Forced descent by pinning the player low (`-freeze 4C6=B0`) and watching
`$0059-$00FC`:

* stage 3 area 5 — camera climbed and stopped dead at `$66=$00, $67=$90` (144),
  exactly the record limit. `shots/vertical/s3a5_at_camera_limit.png`.
* stage 5 area 0 — stopped at `$66=$04, $67=$00` (960), exactly the record
  limit. `shots/vertical/s5a0_at_camera_limit.png`.

Both then held for hundreds of frames with `$67` frozen while the player kept
falling, which is the `$60 = 0` path above.

### The `$59+1` prefetch hazard (important for synthesised areas)

While scrolling down, `sub_DAAB` refills a row every 8 px and picks the source
screen with `loc_E0FD`:

```
E0FD  JSR sub_E11C
E100  LDA $67 / CLC / ADC #$DF      ; carry set iff $67 >= $21 (33)
E105  LDA $66 / ADC #$00            ; screen = $66 + ($67 >= 33)
E109  JMP loc_E0B9
```

So once `$67 >= 33` the engine reads **screen-list entry `$66 + 1`** to fill the
off-screen buffer. At the limit `$66 = $59`, so if `$5A >= 39` (the first
`$67 & 7 == 7` trigger at or above 33) the engine reads `area_list[$59 + 1]` —
one byte past a "full" list.

The stock ROM relies on this being harmless: the area lists are laid out
consecutively, so `area_list[$59+1]` is the first screen of the *next* area,
a valid index whose tiles land only in the invisible bottom 64 px. Stage 3
area 3 (`$59=3`, `$5A=$40`, 4 screens `15 16 17 18`) does exactly this — the
following byte is `$08`, the next area's first screen.

Stage 5 area 0 shows the alternative: 5 screens `1F 1F 1F 1F 1F` followed by
`$A9` (code, not a screen index), and it sets `$5A = $00`. With `$5A = 0` the
camera stops the instant `$66` reaches 4, so index 5 is never fetched.

**Rule for synthesised areas:** either (a) append one extra valid screen index
after the list, or (b) keep `$5A <= $26` (38) so the prefetch never crosses.
Option (a) matches stock and costs one byte; option (b) costs 26 px of reach.

The upward equivalent `loc_E0EE` (`screen = $66 - ($67 < $17)`) can only reach
index −1 when `$66 = 0`, and the camera is clamped at 0 before that, so there is
no top-side hazard.

---

## 5. Q4 — `$FC`

`$FC` is the value written to `$2005` as the vertical scroll, every frame, by
`sub_EB4E`:

```
EB4E  LDA $2002
      LDA #$20 / STA $2006 / LDA #$00 / STA $2006
      LDA $FD / STA $2005          ; X scroll
      LDA $FC / STA $2005          ; Y scroll
      LDA $FF / ORA #$80 / STA $2000
```

For a vertical area it is maintained pixel-for-pixel alongside `$67`, with the
same 240 wrap:

```
sub_DAAB (down)   INC $67 / CMP #$F0 / BNE + / INC $66 / $67 = 0
                  ... INC $94 / INC $FC / CMP #$F0 / BNE + / $FC = 0
sub_DA52 (up)     DEC $67 / CMP #$FF / BNE + / $67 = $EF / DEC $66
                  ... DEC $FC / CMP #$FF / BNE + / $FC = $EF
```

Both start equal (from record bytes 4 and 11) and are stepped identically, so
they stay equal forever. **In all 24 stock vertical records, byte 11 == byte 4.**
The record carries both only because the horizontal path needs them to differ:
there `$67` is the camera low byte wrapping at 256 while `$FC` is the constant
`$E0` that positions the 176-px window inside the 240-px page.

`$FC` is also the origin for the collision-cache Y walk — `$DF5B` / `$F535`:

```
      LDX $97 / BEQ + / LDA $FC / JMP ++
   +  LDA #$E0
   ++ ... CLC ADC dy / CMP #$F0 / BCC + / ADC #$0F     ; mod-240 wrap
      page = ($FF EOR $10) & 1
```

so getting `$FC` wrong desynchronises collision from the visible tiles.

---

## 6. Q5 — `$AE`

`$AE` is copied to `$87` once the fill completes — `$CEA3`:

```
CEA3  LDA #$00 / STA $FD          ; X scroll forced to 0 for the area
      LDA $AE  / STA $87
      LDA #$01 / STA $8A
      JMP $E3B5                   ; load the spawn list
```

`$87` then drives three things.

**(a) The raster split.** `$EAC4`..`$EB1A` map `$87` to an MMC3 IRQ latch and to
a handler from the word table at `$E65B` (index `$87*2`):

| `$87` | latch | split scanline | handler |
|-------|-------|----------------|---------|
| 1 | `$AF` (175) | 176 | `$E677` |
| 2 | `$87` (135) | 136 | `$E679` |
| 3 | `$80` (128) | 129 | `$E67B` |
| 4,5,6,8,9,`$0A`,`$0B` | `$29` (41) | 42 | `$E67D`,`$E683`,`$E68B`,`$E683`,`$E68B`,`$E697`,`$E683` |
| 7 | `$8F` (143) | 144 | `$E693` |
| `$0C` | `$6C` (108) | 109 | `$E69D` |
| default | `$AF` | 176 | — |

**(b) Parallax / animated strips.** `sub_DEBC`, called once per scrolled pixel
from `sub_DAAB`, tests `$87 == 5` (`$DE7C`) and `$87 == 8` (`$DEBC`) to shift a
background band.

**(c) Synthesised terrain.** `$B348` treats `$87` values `$06`, `$08`, `$0A` as
"everything below the world Y in `$29` is death / liquid" — the rising-lava and
water areas (see `work/re/pb2_collision.md`).

Distribution over the 24 stock vertical areas: **`$01` × 21**, `$08` × 2
(stage 1 areas 1 and 6), `$05` × 1 (stage 0 area 5).

**`$AE = $01` is the correct default for a synthesised area.** It gives the
plain 176-px playfield with the standard HUD split and no special terrain.

---

## 7. Q6 — the screen list

**Order is top → bottom.** Index 0 is the topmost screen; `$66` counts down the
list as the camera descends (`INC $66` in `sub_DAAB`, `DEC $66` in `sub_DA52`).

Proof beyond the code: for stage 0 area 1, stage 2 area 0 and stage 2 area 3 —
areas whose two contributing screens have visibly different tile content — an
offline renderer that stacks the list top-first reproduced the live nametable
**960/960 bytes**. Stacking bottom-first produces a mismatch on the first
differing row. Offline area maps: `shots/vertical/s0a1_area_map.png`,
`s2a0_area_map.png`, `s2a3_area_map.png`, `s3a5_area_map.png`,
`s5a0_area_map.png` (renderer: `work/tools/pb2_vmap.py`, 240 px per screen,
engine-true).

**Length.** Stock vertical areas use 2 to 5 screens. The engine has no length
field at all — it indexes `area_list[$66]` and relies on `$59` to bound `$66`.
Practical ceiling: `$DFB4` computes `$A3 = (($66 & 15) << 4) | ($67 >> 4)`,
which wraps after 16 screens and would break enemy spawning, and the spawn
list's position byte (16-px units, 15 per screen) tops out at 255 → 17 screens.
**Keep N ≤ 16.**

**Vertical extent per entry: 240 displayed px** (30 tile rows) out of 64 bytes =
8 block rows = 256 px of data. See §1 — the bottom block row is drawn at half
height and the last 16 px never appear.

Worked screen lists (offset in the stacked area, in pixels):

```
stage 0 area 1  N=2  [12 13]           screen 0: y 0..239   screen 1: y 240..479
stage 2 area 0  N=4  [0E 0F 10 1A]     0..239, 240..479, 480..719, 720..959
stage 2 area 3  N=5  [14 15 16 17 1A]  ... 960..1199
stage 3 area 5  N=2  [19 1A]
stage 5 area 0  N=5  [1F 1F 1F 1F 1F]  a repeating shaft
```

---

## 8. Q7 — player placement and camera behaviour

### Entry position is NOT in the 14-byte record

`sub_F04C` (bank 15), table `$F0A4`:

```
F04C  LDA #$06 / LDY $79 / BNE + / LDA $53      ; $53 = stage (or 6 in the boss path)
   +  ASL A / TAY
F056  LDA $F0A4,Y / STA $00
      LDA $F0A5,Y / STA $01                     ; -> per-stage byte list
F060  LDY $9C / LDA ($00),Y / STA $02           ; $9C = area index -> ONE byte
F066  LDA $02 / AND #$F0 / ORA #$0F / STA $04C6 ; screen Y = (b & $F0) | $0F
F083  LDA $02 / ASL A x4 / AND #$F0 / STA $0508 ; screen X = (b & $0F) * 16
F08C  CMP #$80 / ...  $042C bit 6 = facing
```

```
$F0A4 = B2 F0  B9 F0  C1 F0  C8 F0  CF F0  D9 F0  E7 F0     ; 7 stages
$F0B2: 8E 8E 82 82 8E 6D 82
$F0B9: 82 72 8E 8E 5E 6E 7E 82
$F0C1: 82 32 82 82 8E 8E 82
$F0C8: 82 32 82 82 4E 3E 83
$F0CF: 8E 8E 8E 8E 8E 3E 32 82 32 82
$F0D9: 28 28 32 82 32 8E 4E 8E 4E 8E 4E ...
```

One byte per area: high nibble = entry screen Y / 16, low nibble = entry screen
X / 16. Note the position is a **screen** position (0..255 within the visible
page), not a level position — the player is placed relative to the camera the
record just established.

Verified against live RAM at area entry:

| area | byte | `$04C6` (screen Y) | `$0508` (screen X) |
|------|------|--------------------|--------------------|
| stage 0 area 1 | `$8E` | `$8F` | `$E0` |
| stage 2 area 0 | `$82` | `$8F` | `$20` |
| stage 2 area 3 | `$82` | `$8F` | `$20` |
| stage 3 area 5 | `$3E` | `$3F` | `$E0` |
| stage 5 area 0 | `$28` | `$2F` | `$80` |

Consequence for entry-at-top areas: the camera is at 0 and the entry byte puts
the player near the top of the shaft (`$28` → screen Y `$2F` = 47). For
entry-at-bottom areas the camera is at the limit and the byte is around `$8E`
(screen Y `$8F` = 143), near the floor. **Both bytes must be authored together
with the record** or the player spawns inside geometry.

### Camera follow

`$D3B8`:

```
D3CA  LDA $0508 ; LDX $97 ; BEQ +      ; horizontal: player screen X
D3D1  INY ; LDA $04C6                  ; vertical:   player screen Y
   +  CMP $D404,Y / ... thresholds
$D404: 90 68 70 60 6F 5F
       far  = $D404[Y]  ->  horiz $90 (144)   vert $68 (104)
       near = $D406[Y]  ->  horiz $70 (112)   vert $60 (96)
       back = $D408[Y]  ->  horiz $6F (111)   vert $5F (95)
$60 = signed pixels to scroll this frame, magnitude capped by $0116
```

So in a vertical area the camera keeps the player's screen Y inside the **dead
zone 96..103**: below 104 it scrolls down, above 96 it scrolls up, at up to
`$0116` px per frame, then clamped to `[0, $59*240+$5A]` by `sub_DA52` /
`sub_DAAB`. Confirmed by a long descent trace of stage 5 area 0 — `$04C6`
oscillates in 96..104 the whole way down while `$66/$67` climb monotonically.

---

## 9. Q8 — everything else that differs from `$97 = 0`

| site | horizontal (`$97 = 0`) | vertical (`$97 = 1`) |
|------|------------------------|----------------------|
| `$DFE6` | init `$E000` | init `$E04F` |
| `$DFF0` | fill loop `$E165` (column, `$DB42`) | fill loop `$E1BA` (row, `$DBDE`) |
| `$D97E` / `$D98E` | scroll step `$D9F1` / `$D99E` | scroll step `$DA52` (up) / `$DAAB` (down) |
| `$D32A` | toggles the `$FF` nametable-select bit and sets up `$72` when entering an area | **branches straight to `$D346`** — no toggle, `$FF` stays `$A8`, one page only |
| `$D34D` | shifts object X (`$0508`/`$04F2`) by `$94` | shifts object Y (`$04C6`/`$04B0`) by `$94` |
| `$DF5B`, `$F535` | collision-cache origin = constant `$E0` | origin = `$FC`, mod-240 wrap |
| `$E3F3` | spawn key = camera X | spawn key = `$66*15 + $67/16`, world Y = `$66*240 + $67` |
| `$E4DB` | spawn record byte 0 → X, byte 2 → Y | byte 0 → Y, byte 2 → X (swapped) |
| `$FD20`, `$FDAC`, `$FDF0`, `$FE08`, `$FE28` | 256 radix on X | 240 radix on Y |
| `$E093` | n/a | `$73 < 4` selects screen `$66-1` |
| `$E10C` | n/a | after a row wrap, screen = `$66 + ($67 >= $20)` |

Not per-axis, but per-area and worth stating:

* **Mirroring** is written as vertical (`$A000 = 0`) unconditionally at `$E60B`,
  `$EC58`, `$ECA3`. Nothing to author.
* **`$FD` (X scroll) is forced to 0** at `$CEA3` on every area entry. A vertical
  area is always horizontally aligned to the page.
* **CHR** — `sub_EC11`:
  ```
  EC15  STY $8000 / LDA $42 / ASL A / STA $8001    ; R0 (2 KB @ $0000) = $42 * 2
  EC24            / LDA $43 / ASL A / STA $8001    ; R1 (2 KB @ $0800) = $43 * 2
  EC2A            / $44 -> R2 , $45 -> R3          ; NOT from the record
  EC46            / LDA $46 / STA $8001            ; R4 (1 KB) raw
  EC51            / LDA $47 / STA $8001            ; R5 (1 KB) raw
  ```
  `$44`/`$45` come from `$EF03` reading `$EF3F[$0442]` — the animated background
  tile cycle, chosen per stage, not per area.
* **Palettes** `$016D`/`$016E` are applied at `$CEB4`.

---

## 10. Method and honesty notes

Static work: `work/re/b14.asm`, `work/re/b15.asm`, decoded with
`work/tools/m6502.py`. Level data decoded with `work/tools/pb2_levels.py`.

Dynamic work used `work/tools/nesemu`. Reaching an arbitrary vertical area
directly is impractical by input alone, so:

1. A clean boot was run to frame 1020 (just before level load) and saved:
   `-savestate pre.sav@1020`.
2. Each area was then entered with
   `-loadstate pre.sav -freeze 53=<stage> -freeze 9C=<area>` — i.e. **the stage
   number `$53` and area index `$9C` were forced.** This is a shortcut and is
   stated plainly here.
3. Sanity check that the shortcut produces real areas: for every one of the six
   sampled areas the RAM at entry (`$97,$AE,$73,$66,$67,$59,$5A,$42,$43,$46,
   $47,$FC,$016D,$016E`) matched the ROM record byte for byte, the nametable
   matched the offline decode 960/960, the player spawned on solid ground, and
   the shaft renders and plays normally. See the entry screenshots in
   `work/re/shots/vertical/`.

   (An earlier attempt that froze `$53` from frame 0 broke the boot — all six
   areas came back with `$97 = 0` and zeroed state. That data was discarded.)

4. Field traces used `-trace FILE -tracefrom 999999 -watch 0059-00FC` and were
   filtered offline. Note `-watch` is **not** repeatable — only the last flag is
   honoured — and its output goes into the trace file, not stdout.

Things that are **not** statically knowable and the empirical answer used:

* **`$59/$5A` is authored, not derived.** There is no ROM field giving the
  screen count, and five of six sampled areas have `limit + 176 = content
  height` while one (stage 5 area 0) is 64 px short. The recommended constant
  `$59 = N-1, $5A = $40` is the "content fills all N screens" case and has five
  exact stock precedents (stage 1 areas 1/4/6, stage 3 areas 1/3). Established
  by rendering each area's stacked screen list and measuring where the authored
  content stops, then confirming at runtime that the camera halts exactly at
  `$59*240 + $5A` (forced-descent captures, §4).
* **`$AE` has no formula.** It is a mode selector; `$01` is the plain mode and
  the only safe default. Established by histogram over all 24 stock vertical
  records plus the `$EAC4` latch table.
* **One rendered capture failed**: `s0a1_area_map.png`'s sibling for stage 1
  area 1 came out black because the palette sampled from scanline 10 of that
  particular VRAM dump was unusable. It was not needed — the nametable byte
  comparison for that area passed 960/960 independently of palette.

---

## 11. What the rest of the level blob must satisfy

Beyond the 14-byte record:

1. **Screen table.** Every screen the area references must be 64 bytes
   (8 blocks wide × 8 blocks tall, row major). `pb2_levels.py` infers the size
   from the gap to the next screen pointer, so lay vertical screens out with a
   64-byte stride and do not interleave 40-byte (horizontal) screens between
   them without keeping the pointers sorted.
2. **Area list.** A run of one-byte screen indices, **top first**. Place it in
   the area-pointer table for the stage. Append one extra valid screen index
   after the last entry (see §4) unless `$5A <= $26`.
3. **Bottom 16 px of every screen is invisible.** Author the floor at block row
   7 knowing only its top half renders — or, better, leave block row 7 as solid
   fill and treat block rows 0..6 as the usable 224 px.
4. **Collision classes** — one byte per block via the `$DE31` table; the
   synthesised area needs entries for every block it uses.
5. **Attributes** — one byte per block via the same `$75/$76` table.
6. **Spawn list** (`$E3B5` → `$E515[stage]`): byte 0 is the position along the
   scroll axis in 16-px units counted **15 per screen** (`$66*15 + $67/16`),
   ascending, terminated by `$FF`; byte 2 is the across-axis pixel; type `$04`
   is "advance to the next area" (`INC $9C`). An area with no `$04` object and
   no boss is a dead end. See `work/re/pb2_spawns.md`.
7. **Player entry byte** in the `$F0A4[stage]` list at index `$9C` (§8).
8. **Palette sets** `$016D`/`$016E` must index real palette records.

### Mapping a 256×256 Solbrain room

A Solbrain room is exactly one PB2 vertical screen in width and block count
(8×8 blocks of 32×32 px). The only loss is vertical: **the bottom 16 px are
never drawn and the last block row renders at half height.** Options:

* Accept it — put a 32-px-thick floor in block row 7 and let the bottom half be
  clipped; visually identical.
* Or shift the room contents up 16 px and pad the top, if the room's bottom
  16 px carry meaning.

Stacking N rooms gives a shaft of `N*240` displayed px (not `N*256`), so
vertical distances shrink by 6.25 % relative to the source.

---

## 12. The record builder

```python
def vertical_area_record(n_screens, chr_r0, chr_r1, chr_r4, chr_r5,
                         pal_a, pal_b, enter_at_top=True):
    """Returns the 14 bytes for a synthesised vertical area of n_screens.

    n_screens : length of the area's screen list (top-to-bottom order).
                Keep <= 16: $DFB4 masks $66 with 15 when building the spawn key.
    chr_r0    : record value for MMC3 R0 (2 KB @ PPU $0000). The engine writes
                it DOUBLED, so this is the 2 KB-bank index, R0 = chr_r0 * 2.
    chr_r1    : likewise for R1 (2 KB @ PPU $0800), R1 = chr_r1 * 2.
    chr_r4    : MMC3 R4 (1 KB @ PPU $1000), written raw.
    chr_r5    : MMC3 R5 (1 KB @ PPU $1400), written raw.
                R2/R3 are NOT in the record; they come from $EF3F[$0442].
    pal_a/b   : palette set indices -> $016D / $016E, applied at $CEB4.
    enter_at_top : True  -> camera starts at absolute Y 0 (descend the shaft)
                   False -> camera starts at the limit (climb the shaft)

    Assumes the area's content fills all n_screens. If the bottom of the last
    screen is padding, lower `limit` by hand; $59/$5A is a free authored
    constant, the engine derives nothing from the list length.
    """
    assert 1 <= n_screens <= 16

    # Visible playfield is 176 px ($AE=1 -> MMC3 IRQ latch $AF -> split at
    # scanline 176). Each screen contributes 240 displayed px, not 256.
    limit = n_screens * 240 - 176          # bottom-most camera top edge, in px
    y0 = 0 if enter_at_top else limit      # starting camera top edge, in px

    b66, b67 = divmod(y0, 240)             # mixed radix: screens of 240 px
    b59, b5a = divmod(limit, 240)

    return bytes([
        0x01,                   # 0  -> $97    scroll axis: 1 = vertical
        0x01,                   # 1  -> $AE    raster mode; 1 = plain
                                #              (21 of 24 stock vertical areas),
                                #              IRQ latch $AF, no parallax,
                                #              no synthesised death/liquid band
        ((b67 >> 3) + 26) % 30, # 2  -> $73    first nametable row of the fill,
                                #              4 rows (32 px) above the camera
                                #              top, mod 30. Derived, never free.
        b66,                    # 3  -> $66    camera screen index (240 px each)
        b67,                    # 4  -> $67    camera pixel within that screen
        b59,                    # 5  -> $59    camera limit, screen index
        b5a,                    # 6  -> $5A    camera limit, pixel (0x40 when
                                #              the content fills all screens).
                                #              Minimum camera is hard-coded 0.
        chr_r0,                 # 7  -> $42    R0 = chr_r0 * 2  ($EC1B)
        chr_r1,                 # 8  -> $43    R1 = chr_r1 * 2  ($EC27)
        chr_r4,                 # 9  -> $46    R4 raw           ($EC4B)
        chr_r5,                 # 10 -> $47    R5 raw           ($EC54)
        b67,                    # 11 -> $FC    PPU $2005 Y scroll. For a
                                #              vertical area it must equal $67:
                                #              both are stepped in lockstep and
                                #              wrap at 240. True in all 24 stock
                                #              vertical records.
        pal_a,                  # 12 -> $016D  palette set A
        pal_b,                  # 13 -> $016E  palette set B
    ])


# Companion data that is NOT in the record and must be emitted separately:
#
#   area list        : n_screens bytes, screen indices, TOP FIRST, plus one
#                      extra valid index after the end (the engine prefetches
#                      area_list[$59+1] into the off-screen buffer whenever
#                      $5A >= 39).
#   player entry     : one byte in the $F0A4[stage] list at index $9C:
#                      high nibble = screen Y / 16, low nibble = screen X / 16.
#                      Engine: $04C6 = (b & $F0) | $0F, $0508 = (b & $0F) * 16.
#                      Use ~0x28 when entering at the top, ~0x8E at the bottom.
#   spawn list       : byte 0 = 16-px row, counted 15 per screen
#                      ($66*15 + $67/16), ascending, $FF terminator;
#                      include a type $04 object to leave the area.
#   collision bytes  : one per block, via the $DE31 table.
#   attribute bytes  : one per block, via the $75/$76 table.
def player_entry_byte(screen_x, screen_y):
    """screen_x/screen_y are 0..255 within the visible page."""
    return ((screen_y // 16) << 4) | (screen_x // 16)
```

Sanity check against the ROM. Feeding each stock full-height area's own CHR
and palette bytes back through `vertical_area_record` reproduces its record:

```
stage 1 area 4  N=2 top     14/14 bytes identical
stage 3 area 1  N=2 top     14/14 bytes identical
stage 3 area 3  N=4 bottom  14/14 bytes identical
stage 1 area 1  N=2 top     13/14 - differs only in byte 1, $AE = $08 (parallax mode)
stage 1 area 6  N=2 top     13/14 - differs only in byte 1, $AE = $08 (parallax mode)
```

The remaining stock vertical areas differ only in `$59/$5A` (and the `$66/$67`,
`$73`, `$FC` that follow from an entry at a hand-lowered limit), because their
last screen is partly padding. Examples:

```
stage 5 area 0  N=5 top     13/14 - $5A = $00 instead of $40 (limit 64 px short;
                                    also avoids the $59+1 prefetch, see s4)
stage 2 area 3  N=5 bottom  12/14 - $59 = $03 instead of $04 (limit one screen short)
stage 0 area 1  N=2 bottom   8/14 - limit 144 instead of 304 (bottom screen mostly padding)
```

That is the expected outcome: `$59/$5A` is authored, not derived (§4). Pass an
explicit limit whenever the content does not fill all `n_screens`.
