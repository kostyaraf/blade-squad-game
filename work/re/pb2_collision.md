# Power Blade 2 — terrain collision

Everything here is decoded from `Power Blade 2 (USA).nes` (MMC3, 16 PRG banks)
and cross-checked against live RAM from the emulator. `work/tools/pb2_collision.py`
is the executable version of this document.

Collision is a **two-stage** system:

1. A per-area **tile → terrain lookup**: a `$FF`-terminated step function over the
   raw background tile number, giving a full **terrain type byte** and a 2-bit
   **collision class**. Tables live in bank pair 6/7.
2. A 128-byte **class cache at `$0680`**, filled as the camera scrolls, holding
   2 bits per 16x16 pixel cell for the two on-screen nametable pages. This is
   what the player physics actually reads, 99% of the time.

---

## 1. The pointer chain

`$DDE1` (bank 14) maps bank pair 6/7 and then walks the chain:

```
$DDE1  LDA $79 / BNE +   -> A = 6 (a fixed "menu/intro" slot) else A = $53 (stage)
$DDE3  LDY #$36 / JSR $ECA7          ; bank pair 6/7 at $8000-$BFFF
       Y = A*2
$DE23[stage]      7 words, in bank 14           -> a word in bank pair 6/7
   -> word        the per-stage area-record table
      -> [$9C]*2  one word per area                 ($9C = area index)
         -> record, 6 bytes
```

`$DE23` (bank 14) is:

```
$DE23:  1F 80  21 80  23 80  25 80  27 80  29 80  2B 80
        ^stage0 ^1     ^2     ^3     ^4     ^5     ^6
```

i.e. the seven area-record tables are pointed at by `$801F`, `$8021`, ... `$802B`
in bank pair 6/7.

The 6-byte record is copied byte by byte into zero page by the loop at `$DE16`
(`LDA ($08),Y / STA $7B,X`):

| off | dest | meaning |
|-----|------|---------|
| 0-1 | `$7B`/`$7C` | pointer to the **threshold list** — tile numbers, ascending, `$FF` terminated |
| 2-3 | `$7D`/`$7E` | pointer to the **terrain type** bytes, one per threshold band |
| 4-5 | `$7F`/`$80` | pointer to the **collision class** bytes (0-3), one per threshold band |

All three lists are stored contiguously and in that order, so
`len = ($7D) - ($7B)` gives the threshold-list length including its terminator,
and the two value lists are one shorter. `pb2_collision.py` uses exactly this.

### The lookup, `sub_DCBF` at `$DCBF` (bank 14)

```
$DCCE  LDA $10 / BEQ ...        ; tile 0 short-circuits to class 0, always
$DCD2  LDY #$00
$DCD4  LDA ($7B),Y / CMP #$FF / BEQ out      ; terminator
$DCDC  CMP $10 / BEQ next / BCS out          ; advance while entry <= tile
$DCE4  INY / BNE loop
$DCE6  DEY / BMI class0                      ; step back to the owning band
$DCE9  LDA ($7F),Y                           ; the class
```

The class is then shifted into position for its 16x16 quadrant (`$0B`) by
`sub_CB01` (4x ASL) / `sub_CB03` (2x ASL) and merged into `$0680,Y` with
`AND #$3F / #$CF / #$F3 / #$FC` followed by `ORA`.

The parallel lookup that returns the **full type byte** through `($7D),Y` is the
slow path at `$F42C` (bank 15); it re-derives the tile from level data instead of
reading the cache.

**Engine bug worth knowing:** the slow path's copy of the search (`$F4F5`) has
**no `$FF` terminator check**. A tile number of `$FF` walks off the end of the
threshold list. Tile `$FF` must never appear in level data. `build_tables()`
refuses to emit a band starting at `$FF`.

---

## 2. Class values and terrain types

`$F5A9` (bank 15) / `$DDDD` (bank 14) is the class → returned-byte table:

```
class:  0     1     2     3
byte:  $00   $01   $80   $02
```

so the fast path returns the same byte vocabulary as the slow path, just
collapsed. The class column in every cartridge table is derivable from the type
column by this rule (verified on all 17 distinct table sets in the ROM):

```
if type & $80: class = 2      # solid
elif type == $01: class = 1   # ladder
elif type == $02: class = 3   # death
else: class = 0               # passable
```

### Meaning of every value

Probe geometry first: `$B316` (bank 9) picks a probe list via `$B4D6[$0442]` and
`$B514`/`$B51A`; the lists at `$B520/$B530/$B540/$B550/$B560` are 8 (dx,dy)
pairs — dy `+1` feet, `-4` ankles, `-14` waist, `-30` head, each as a left(`-6`)
/ right(`+5`) pair. Results are stored **reversed** (`LDY $0B / STA $0000,Y /
DEC $0B`, starting `$0B = 7`), so `$00/$01` = head, `$02/$03` = waist,
`$04/$05` = ankles, `$06/$07` = feet.

| type | class | meaning | proving code |
|---|---|---|---|
| `$00` | 0 | **air** — nothing happens | `$F5A9[0] = $00` |
| `$01` | 1 | **ladder / climbable** | bank 8 `$938D`/`$93C7`/`$93EE`: probe at (0, `-$16`), `CMP #$01`, plus `$4A AND #$08` (UP held) → `JMP $9491` enters climb state. `$94F1`/`$94FF` keep climbing while (0,`-$14`)/(0,`-$18`) still read `$01`. `$A003`/`$A00E` are the side probes. `$9581` treats `$01` underfoot as standable ground (`JSR $9EFE`). |
| `$02` | 3 | **instant death** | bank 9 `$B38C`/`$B39E`/`$B3A8`/`$B3B2`/`$B3C0`/`$B3CE` all funnel to `$B3F5`: `LDA #$00 / STA $049A`. `$049A` is player HP (0-`$10`, see `work/re/pb2_suits.md`). |
| `$03` | 0 | **deep liquid** — sink, heavy drag, drown | feet probes `$B3DC`/`$B3F0` → `$B44E`: sets `$05A2 = $80` (speed divisor, halves movement twice at `$B1CA`-`$B1DD`); `$B462 JSR $B1AA` with inline `00 20` pushes Y down (sinking); `$B467` if `$04C6 >= $D0` then `$049A = 0` (drown at the bottom); `$B473` sets `$0668 |= $40`. |
| `$04` | 0 | **liquid surface** — drag + splash | head probe `$B390` → `$05A2 = $40` and `JSR $B675` spawning object type `$4F` (the splash). Waist probes `$B3A4`/`$B3AE` → `$B4AF`, `$05A2 = $40` only. |
| `$05` | 0 | **current, pushes RIGHT** | `$B3B8`/`$B3C6` → `$B416` → `$B494`: `JSR $B203` with inline argument `00 C0` = **+$00C0 = +0.75/frame** added to the horizontal accumulator `$05E4:$05CE`. Skipped when `$9A == 2`. |
| `$06` | 0 | **current, pushes LEFT** | `$B3BC`/`$B3CA` → `$B410` → `$B482`: inline `FF 40` = **-$00C0 = -0.75/frame**. |
| `$80` | 2 | **solid** | `$F5A9[2] = $80`; every caller tests bit 7 with `BMI` — `$FBC1`, `$FC05`, `$91D7`, `$9E54`. |
| `$87` | 2 | **solid conveyor, pushes RIGHT** | `$B3D4` → `$B42D` → `$B48E`: inline `00 80` = **+0.5/frame**. |
| `$88` | 2 | **solid conveyor, pushes LEFT** | `$B3D8` → `$B43A` → `$B47C`: inline `FF 80` = **-0.5/frame**. |

The inline-argument convention is `$B116` (pops the return address, reads Y bytes
after the `JSR`, resumes past them) + `$B130`.

Horizontal motion chain, for the conveyor/current claims:
`$B203`/`$B1FA` add a signed 16-bit delta into the **acceleration** pair
`$0560:$0576`, which `$B20B` integrates into the horizontal speed accumulator
`$05E4:$05CE`. This mirrors the vertical chain exactly: `$B21A` feeds
`$0534:$054A`, which `$B1B7`→`$B1C8` integrates (through the `$05A2` divisor)
into the Y position `$04B0:$04C6:$04DC`. `$A056` (`LDA $05E4 / ORA $05CE / BEQ`)
is the "am I moving horizontally" test, and `$A06F` (`LDA $0560 / BMI`) picks the
friction direction — both consistent with a signed horizontal velocity.

Level-layout corroboration (ASCII class maps of stage 0 screens rendered from
ROM level data):

* screen 8 — type `$01` forms a 1-tile-wide, 8-tile-tall vertical column hanging
  off a platform. That is a ladder.
* screens 5/6/16 — type `$02` forms full-width 2-row bands at the very top
  (lethal ceiling) and the very bottom under the platforms (bottomless pit).
* screens 5/16 — `$87`/`$88` are single rows sitting directly on top of solid
  platforms. Factory-floor conveyor belts.

---

## 3. The `$0680` cache

**128 bytes, `$0680`-`$06FF`.** Two nametable pages of 64 bytes each; each page is
16 rows of 4 bytes; each byte is 4 cells of 2 bits. One cell = 16x16 pixels, so a
page covers 256x256 px — a full nametable.

```
index = page*$40 + ((y >> 4) & 15)*4 + ((x >> 6) & 3)
shift = 6 - 2*((x >> 4) & 3)          # quadrant 0 in bits 7-6, quadrant 3 in bits 1-0
class = ($0680 + index) >> shift & 3
```

* `page` comes from `$F5A7[($FF EOR $10) & 1]`, i.e. 0 or `$40`.
* `y` is the **nametable** pixel row. For horizontal areas the reader at
  `$F535`-`$F54A` starts from `$E0` when `$97 == 0` (`$FC` otherwise) and the
  `CMP #$F0 / ADC #$0F` carry path makes it exactly `world_y - $10` — the 16-pixel
  HUD band at the top of the screen is not part of the collision grid.
* The shift order is confirmed by the writer's own masks `$3F/$CF/$F3/$FC` and by
  `sub_CB01` (4x ASL) / `sub_CB03` (2x ASL).

**Which tile of the 16x16 cell decides the class:** the **top-left** tile
(dx = 0, dy = 0). This was established empirically — predicting `$0680` from live
CIRAM matched 320/320 cells on stage 0 and stage 3, and 500/512 on stage 2 when
extended into the HUD band (all 12 misses are HUD rows the fill never touches).
*Not verified statically:* I could not reconcile the column-fill index arithmetic
at `$DB07`-`$DB30` with the reader's formula; my derivation produced nonsense
indices (4/5/68/69). The empirical rule holds on every sample tested but the
writer-side proof is missing.

**Fast vs slow path.** `$F52C` (bank 15) / `$DD8B` (bank 14) read the cache and
return the 2-bit class expanded through `$F5A9`. `$F42C` re-derives the tile from
level data and returns the **full type byte** — that is why conveyors, ladders,
currents and liquid work at all: the cache alone cannot distinguish `$80` from
`$87`, or `$00` from `$04`.

---

## 4. Everything else that contributes to collision

* **Per-level tile remap hook, `$DF85`.** Saves A/Y to `$0177`/`$0178`, maps bank
  pair 12/13 (`LDY #$3C`), calls `$8006`, restores A from `$0177`. The level's own
  bank can therefore rewrite a tile number *before* both drawing and the collision
  lookup. (`$DF9D` is the sibling that blanks a tile when `$017A != 0`; it does
  **not** feed collision.)
* **Runtime cell patches.** `$DF21` (trampoline `$C8A9`) clears one 16x16 cell to
  class 0 using masks `$DF34 = 3F CF F3 FC`; `$DF38` (trampoline `$C8AC`) sets it
  to class 2 using `$DF4E = 80 20 08 02`. Callers: bank 10 `$8AF9`, bank 11
  `$A3EB` (clear), bank 11 `$A3F4` (set). Destructible blocks and opening doors.
* **Area-mode synthesised terrain.** `$87` is area-record byte 1 (`$AE`, stored at
  `$CEAB`). At `$B348`-`$B37C`, modes `$06`/`$08`/`$0A` **fabricate** type `$02`
  (death) or `$04` (liquid) by comparing the probe's world Y (`$11`) against `$29`,
  a per-mode constant set in bank 14 at `$D837` (`$08`), `$D85B` (`$8F`),
  `$D873` (`$7F`), `$D88E` (`$2F`), `$D89E` (`$90`). This is the rising-lava /
  water-level / instant-death-ceiling mechanic and it bypasses the tile tables
  entirely. `$F39B`/`$ABED` additionally dispatch a `$87`-indexed camera-clamp
  handler (tables at `$F3AA`/`$F3BA` and `$ABFC`/`$AC0C`).
* **Not collision:** the per-block byte reached through `$75`/`$76` is the PPU
  **attribute** byte — `$DC73` writes `($75),Y` straight to PPU `$23C0`.
  `pb2_levels.py` names that field `collision`; the name is wrong.

---

## 5. The tables, for every stage

Lengths in the header row include the `$FF` terminator for thresholds. Areas that
share a record are grouped. Addresses are bank pair 6/7 CPU addresses.

### Stage 0 — area-record table `$AE36`, 7 slots

| areas | record | thresholds `$7B` | terrain types `$7D` | classes `$7F` |
|---|---|---|---|---|
| 0,2,4,6 | `$AE44` | `$AE50` (10) `5B 80 92 9B A1 A2 A9 B0 D9 FF` | `$AE5A` (9) `80 00 04 03 01 87 88 80 02` | `$AE63` (9) `02 00 00 00 01 02 02 02 03` |
| 1,3,5 | `$AE4A` | `$AE6C` (10) `38 80 92 9B A1 A2 A9 B0 D9 FF` | `$AE76` (9) `80 00 04 03 01 87 88 80 02` | `$AE7F` (9) `02 00 00 00 01 02 02 02 03` |

areas 0,2,4,6:

```
  $00-$5A  type $00  class 0  air
  $5B-$7F  type $80  class 2  solid
  $80-$91  type $00  class 0  air
  $92-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```
areas 1,3,5:

```
  $00-$37  type $00  class 0  air
  $38-$7F  type $80  class 2  solid
  $80-$91  type $00  class 0  air
  $92-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```

### Stage 1 — area-record table `$AE88`, 8 slots

| areas | record | thresholds `$7B` | terrain types `$7D` | classes `$7F` |
|---|---|---|---|---|
| 0,1,6,7 | `$AE98` | `$AEA4` (10) `45 80 92 9B A1 A2 A9 B0 D9 FF` | `$AEAE` (9) `80 00 04 03 01 87 88 80 02` | `$AEB7` (9) `02 00 00 00 01 02 02 02 03` |
| 2,3,4,5 | `$AE9E` | `$AEC0` (10) `49 80 92 9B A1 A2 A9 B0 D9 FF` | `$AECA` (9) `80 00 04 03 01 87 88 80 02` | `$AED3` (9) `02 00 00 00 01 02 02 02 03` |

areas 0,1,6,7:

```
  $00-$44  type $00  class 0  air
  $45-$7F  type $80  class 2  solid
  $80-$91  type $00  class 0  air
  $92-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```
areas 2,3,4,5:

```
  $00-$48  type $00  class 0  air
  $49-$7F  type $80  class 2  solid
  $80-$91  type $00  class 0  air
  $92-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```

### Stage 2 — area-record table `$AEDC`, 7 slots

| areas | record | thresholds `$7B` | terrain types `$7D` | classes `$7F` |
|---|---|---|---|---|
| 0,3,5 | `$AEF6` | `$AF31` (9) `59 80 85 8D 95 9D C9 CB FF` | `$AF3A` (8) `80 00 04 05 06 80 01 02` | `$AF42` (8) `02 00 00 00 00 02 01 03` |
| 1 | `$AEF0` | `$AF15` (10) `59 80 93 9B A1 A2 A9 B0 D9 FF` | `$AF1F` (9) `80 00 04 03 01 87 88 80 02` | `$AF28` (9) `02 00 00 00 01 02 02 02 03` |
| 2,4,6 | `$AEEA` | `$AEFC` (9) `40 80 85 8D 95 9D C9 CB FF` | `$AF05` (8) `80 00 04 05 06 80 01 02` | `$AF0D` (8) `02 00 00 00 00 02 01 03` |

areas 0,3,5:

```
  $00-$58  type $00  class 0  air
  $59-$7F  type $80  class 2  solid
  $80-$84  type $00  class 0  air
  $85-$8C  type $04  class 0  liquid, surface (splash)
  $8D-$94  type $05  class 0  current, pushes right (+0.75/frame)
  $95-$9C  type $06  class 0  current, pushes left (-0.75/frame)
  $9D-$C8  type $80  class 2  solid
  $C9-$CA  type $01  class 1  ladder
  $CB-$FF  type $02  class 3  instant death
```
areas 1:

```
  $00-$58  type $00  class 0  air
  $59-$7F  type $80  class 2  solid
  $80-$92  type $00  class 0  air
  $93-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```
areas 2,4,6:

```
  $00-$3F  type $00  class 0  air
  $40-$7F  type $80  class 2  solid
  $80-$84  type $00  class 0  air
  $85-$8C  type $04  class 0  liquid, surface (splash)
  $8D-$94  type $05  class 0  current, pushes right (+0.75/frame)
  $95-$9C  type $06  class 0  current, pushes left (-0.75/frame)
  $9D-$C8  type $80  class 2  solid
  $C9-$CA  type $01  class 1  ladder
  $CB-$FF  type $02  class 3  instant death
```

### Stage 3 — area-record table `$AF4A`, 7 slots

| areas | record | thresholds `$7B` | terrain types `$7D` | classes `$7F` |
|---|---|---|---|---|
| 0,6 | `$AF58` | `$AF6A` (9) `27 80 A4 BE C8 D2 DA FB FF` | `$AF73` (8) `80 00 04 05 06 01 80 02` | `$AF7B` (8) `02 00 00 00 00 01 02 03` |
| 1,2,3,4 | `$AF5E` | `$AF83` (9) `39 80 A4 BE C8 D2 DA FB FF` | `$AF8C` (8) `80 00 04 05 06 01 80 02` | `$AF94` (8) `02 00 00 00 00 01 02 03` |
| 5 | `$AF64` | `$AF9C` (9) `27 80 85 8D 95 9D C8 CB FF` | `$AFA5` (8) `80 00 04 05 06 80 01 02` | `$AFAD` (8) `02 00 00 00 00 02 01 03` |

areas 0,6:

```
  $00-$26  type $00  class 0  air
  $27-$7F  type $80  class 2  solid
  $80-$A3  type $00  class 0  air
  $A4-$BD  type $04  class 0  liquid, surface (splash)
  $BE-$C7  type $05  class 0  current, pushes right (+0.75/frame)
  $C8-$D1  type $06  class 0  current, pushes left (-0.75/frame)
  $D2-$D9  type $01  class 1  ladder
  $DA-$FA  type $80  class 2  solid
  $FB-$FF  type $02  class 3  instant death
```
areas 1,2,3,4:

```
  $00-$38  type $00  class 0  air
  $39-$7F  type $80  class 2  solid
  $80-$A3  type $00  class 0  air
  $A4-$BD  type $04  class 0  liquid, surface (splash)
  $BE-$C7  type $05  class 0  current, pushes right (+0.75/frame)
  $C8-$D1  type $06  class 0  current, pushes left (-0.75/frame)
  $D2-$D9  type $01  class 1  ladder
  $DA-$FA  type $80  class 2  solid
  $FB-$FF  type $02  class 3  instant death
```
areas 5:

```
  $00-$26  type $00  class 0  air
  $27-$7F  type $80  class 2  solid
  $80-$84  type $00  class 0  air
  $85-$8C  type $04  class 0  liquid, surface (splash)
  $8D-$94  type $05  class 0  current, pushes right (+0.75/frame)
  $95-$9C  type $06  class 0  current, pushes left (-0.75/frame)
  $9D-$C7  type $80  class 2  solid
  $C8-$CA  type $01  class 1  ladder
  $CB-$FF  type $02  class 3  instant death
```

### Stage 4 — area-record table `$AFB5`, 10 slots

| areas | record | thresholds `$7B` | terrain types `$7D` | classes `$7F` |
|---|---|---|---|---|
| 0,1,2,3,4 | `$AFC9` | `$AFD5` (9) `5B 80 A4 BE C8 D2 DA F9 FF` | `$AFDE` (8) `80 00 04 05 06 01 80 02` | `$AFE6` (8) `02 00 00 00 00 01 02 03` |
| 5,6,7,8,9 | `$AFCF` | `$AFEE` (9) `3C 80 A4 BE C8 D2 DA F9 FF` | `$AFF7` (8) `80 00 04 05 06 01 80 02` | `$AFFF` (8) `02 00 00 00 00 01 02 03` |

areas 0,1,2,3,4:

```
  $00-$5A  type $00  class 0  air
  $5B-$7F  type $80  class 2  solid
  $80-$A3  type $00  class 0  air
  $A4-$BD  type $04  class 0  liquid, surface (splash)
  $BE-$C7  type $05  class 0  current, pushes right (+0.75/frame)
  $C8-$D1  type $06  class 0  current, pushes left (-0.75/frame)
  $D2-$D9  type $01  class 1  ladder
  $DA-$F8  type $80  class 2  solid
  $F9-$FF  type $02  class 3  instant death
```
areas 5,6,7,8,9:

```
  $00-$3B  type $00  class 0  air
  $3C-$7F  type $80  class 2  solid
  $80-$A3  type $00  class 0  air
  $A4-$BD  type $04  class 0  liquid, surface (splash)
  $BE-$C7  type $05  class 0  current, pushes right (+0.75/frame)
  $C8-$D1  type $06  class 0  current, pushes left (-0.75/frame)
  $D2-$D9  type $01  class 1  ladder
  $DA-$F8  type $80  class 2  solid
  $F9-$FF  type $02  class 3  instant death
```

### Stage 5 — area-record table `$B007`, 14 slots

| areas | record | thresholds `$7B` | terrain types `$7D` | classes `$7F` |
|---|---|---|---|---|
| 0 | `$B02F` | `$B061` (10) `56 80 93 9B A1 A2 A9 B0 D9 FF` | `$B06B` (9) `80 00 04 03 01 87 88 80 02` | `$B074` (9) `02 00 00 00 01 02 02 02 03` |
| 1,3,7,9,11,13 | `$B023` | `$B035` (8) `45 80 AC B2 B8 F5 F7 FF` | `$B03D` (7) `80 00 03 04 80 01 02` | `$B044` (7) `02 00 00 00 02 01 03` |
| 2,4,5,6,8,10,12 | `$B029` | `$B04B` (8) `48 80 AC B2 B8 F5 F7 FF` | `$B053` (7) `80 00 03 04 80 01 02` | `$B05A` (7) `02 00 00 00 02 01 03` |

areas 0:

```
  $00-$55  type $00  class 0  air
  $56-$7F  type $80  class 2  solid
  $80-$92  type $00  class 0  air
  $93-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```
areas 1,3,7,9,11,13:

```
  $00-$44  type $00  class 0  air
  $45-$7F  type $80  class 2  solid
  $80-$AB  type $00  class 0  air
  $AC-$B1  type $03  class 0  liquid, deep (sinks you)
  $B2-$B7  type $04  class 0  liquid, surface (splash)
  $B8-$F4  type $80  class 2  solid
  $F5-$F6  type $01  class 1  ladder
  $F7-$FF  type $02  class 3  instant death
```
areas 2,4,5,6,8,10,12:

```
  $00-$47  type $00  class 0  air
  $48-$7F  type $80  class 2  solid
  $80-$AB  type $00  class 0  air
  $AC-$B1  type $03  class 0  liquid, deep (sinks you)
  $B2-$B7  type $04  class 0  liquid, surface (splash)
  $B8-$F4  type $80  class 2  solid
  $F5-$F6  type $01  class 1  ladder
  $F7-$FF  type $02  class 3  instant death
```

### Stage 6 — area-record table `$B07D`, 11 slots

| areas | record | thresholds `$7B` | terrain types `$7D` | classes `$7F` |
|---|---|---|---|---|
| 0,2,3,6,7,8 | `$B093` | `$B0A5` (10) `45 80 92 9B A1 A2 A9 B0 D9 FF` | `$B0AF` (9) `80 00 04 03 01 87 88 80 02` | `$B0B8` (9) `02 00 00 00 01 02 02 02 03` |
| 1,9 | `$B099` | `$B0C1` (9) `45 80 A4 BE C8 D2 DA FB FF` | `$B0CA` (8) `80 00 04 05 06 01 80 02` | `$B0D2` (8) `02 00 00 00 00 01 02 03` |
| 4,5,10 | `$B09F` | `$B0DA` (10) `56 80 92 9B A1 A2 A9 B0 D9 FF` | `$B0E4` (9) `80 00 04 03 01 87 88 80 02` | `$B0ED` (9) `02 00 00 00 01 02 02 02 03` |

areas 0,2,3,6,7,8:

```
  $00-$44  type $00  class 0  air
  $45-$7F  type $80  class 2  solid
  $80-$91  type $00  class 0  air
  $92-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```
areas 1,9:

```
  $00-$44  type $00  class 0  air
  $45-$7F  type $80  class 2  solid
  $80-$A3  type $00  class 0  air
  $A4-$BD  type $04  class 0  liquid, surface (splash)
  $BE-$C7  type $05  class 0  current, pushes right (+0.75/frame)
  $C8-$D1  type $06  class 0  current, pushes left (-0.75/frame)
  $D2-$D9  type $01  class 1  ladder
  $DA-$FA  type $80  class 2  solid
  $FB-$FF  type $02  class 3  instant death
```
areas 4,5,10:

```
  $00-$55  type $00  class 0  air
  $56-$7F  type $80  class 2  solid
  $80-$91  type $00  class 0  air
  $92-$9A  type $04  class 0  liquid, surface (splash)
  $9B-$A0  type $03  class 0  liquid, deep (sinks you)
  $A1-$A1  type $01  class 1  ladder
  $A2-$A8  type $87  class 2  solid conveyor, pushes right (+0.5/frame)
  $A9-$AF  type $88  class 2  solid conveyor, pushes left (-0.5/frame)
  $B0-$D8  type $80  class 2  solid
  $D9-$FF  type $02  class 3  instant death
```

---

## 6. Verification

All commands run from the repo root.

```sh
# a normal boot into stage 1 area 0
./work/tools/nesemu "Power Blade 2 (USA).nes" -input /tmp/boot.inp -frames 1500 \
    -ramdump /tmp/pb3c/s1.ram -vram /tmp/pb3c/s1.vram@1499

# a savestate just before the stage is chosen, so other stages can be forced
./work/tools/nesemu "Power Blade 2 (USA).nes" -input /tmp/boot.inp -frames 620 \
    -savestate /tmp/pb3c/pre.st@605
for NN in 01 02 03 04; do
  ./work/tools/nesemu "Power Blade 2 (USA).nes" -loadstate /tmp/pb3c/pre.st \
      -input /tmp/boot.inp -freeze 53=$NN -frames 1600 \
      -ramdump /tmp/pb3c/h$NN.ram -vram /tmp/pb3c/h$NN.vram@1599
done

python3 work/tools/pb2_collision.py "Power Blade 2 (USA).nes"
python3 work/tools/pb2_collision.py "Power Blade 2 (USA).nes" \
    --verify       /tmp/pb3c/s1.ram  /tmp/pb3c/s1.vram
python3 work/tools/pb2_collision.py "Power Blade 2 (USA).nes" \
    --verify-ciram /tmp/pb3c/h02.ram /tmp/pb3c/h02.vram 10
```

Results:

* **Pointer chain** — `$7B/$7C`, `$7D/$7E`, `$7F/$80` in live RAM matched the ROM
  record byte for byte on stages 0, 1, 2, 3 and 4.
* **ROM level data → predicted `$0680`** — stage 0 (area 0, camera `$02:00`)
  40/40 bytes exact; stage 1 40/40; stage 3 40/40; stage 4 40/40.
* **Live CIRAM tiles → predicted `$0680`** — stage 0 320/320 cells, stage 3
  320/320, stage 2 (a vertical area) 320/320 over rows 0-9 and 500/512 over rows
  0-15, the 12 misses being the HUD band the fill never writes.
* **Round trip** — `pb2_collision.py <rom>` prints
  `round trip over every area of every stage: OK`. Rebuilt **class** tables are
  shorter (10 thresholds → 6) because adjacent bands share a class; rebuilt
  **type** tables come out the same length as the cartridge's, proving the
  original `$7D` tables are already minimal.

### Unverified / open

* The top-left-tile rule for a 16x16 cell is empirical (see §3); the writer-side
  index arithmetic at `$DB07`-`$DB30` was not reconciled.
* Only stages 0-4 were reached in the emulator. Stages 5 and 6 are decoded from
  ROM only.
* `$0442` (which selects the probe list) and `$9A` (which gates the `$05`/`$06`
  currents) were not traced to their producers.
* `work/re/pb2_level_format.md` lists stale area counts for stages 2 and 5 (14 and
  30); the real counts are 7 and 14, which is what the area-record tables here
  agree with.
