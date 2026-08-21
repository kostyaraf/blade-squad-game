# Power Blade 2 — palettes and CHR banks

Everything below is decoded straight out of `Power Blade 2 (USA).nes` and
verified against the running game (see "Verification" at the end).
Module: `work/tools/pb2_palettes.py`.

## 0. Correction to an earlier assumption

`$44`/`$45` (MMC3 R2/R3) are **not** part of the background pattern table.
During play PPUCTRL is `$A9`:

| bit | value | meaning |
|-----|-------|---------|
| 4 | 0 | **background pattern table = `$0000`** |
| 5 | 1 | 8x16 sprites (a sprite tile picks its half with tile bit 0) |
| 3 | 1 | ignored, because sprites are 8x16 |

So the background comes from **R0/R1**, the two 2 KB banks the area record
supplies (bytes 7 and 8, written `*2`).  `$1000-$1FFF` is the *player*
(R2/R3) and *object* (R4/R5) half.  `$EF3F` picks the player's animation
bank, not a background bank.  What actually animates the background is a
separate, previously undocumented hook on **R1** — section 5.

## 1. Where `$016D` / `$016E` come from and what they do

`$E272`-`$E2B8` fills the area record; the last two bytes are the selectors:

```
area record byte 12 -> $016D    palette set A   (whole 32-byte palette)
area record byte 13 -> $016E    palette set B   (ONE sub-palette -> slot 7)
```

`$CEC0` (bank 14, state `$1A` = 4) runs the load:

```
CEC0  AD 6D 01  LDA $016D
CEC3  20 1C ED  JSR $ED1C     ; -> bank0 $801B -> $8044   build all 8 slots
CEC7  AD 6E 01  LDA $016E
CECA  A2 07     LDX #$07
CECC  20 30 ED  JSR $ED30     ; -> bank0 $801E -> $8080   overwrite slot 7
CECF  4C E4 D8  JMP $D8E4
D8E4  A5 9A     LDA $9A       ; suit 0..4
D8E7  69 3D     ADC #$3D
D8E9  A2 05     LDX #$05
D8EB  20 30 ED  JSR $ED30     ; overwrite slot 5 with the suit palette
D8EE  4C 48 ED  JMP $ED48     ; -> bank0 $8021 -> $80AB   upload
```

`$ED1C`/`$ED30`/`$ED48` are just bank-switch wrappers: `LDY #$30` ->
`$ECA7`/`$ECAB` masks with `#$0F` -> **PRG bank 0 at `$8000`**, so every
palette table lives in bank 0.

### Tables (all in PRG bank 0)

| what | address | entries | entry size | data it points at |
|------|---------|---------|-----------|--------------------|
| palette-set-A pointer table | `$811F` | **47** | 2 (word) | `$817D`-`$82F4` |
| palette-set-A body | `$817D` | 47 | 8 bytes | 8 sub-palette indices, one per `$3F00` slot |
| sub-palette pointer LO | `$82F5` | **136** | 1 | — |
| sub-palette pointer HI | `$837D` | **136** | 1 | `$8405`-`$859C` |
| sub-palette body | `$8405` | 136 | 3 bytes | colours 1,2,3 of one slot |

Every table's length is *implied*, not stored: a pointer table runs until the
lowest address it points at (`$811F` stops at `$817D`), and LO/HI counts are
just `$837D - $82F5 = 136`.  There is no terminator and no bounds check
anywhere.

Colour 0 of every slot is **not** in ROM — `$8066` and `$8096` push a literal
`#$0F` before each 3-byte group, so all eight slots always start `$0F`.

### The build routines

```
$8044  (set A)  $93 = A ; Y = A*2
                $08/$09 = word $811F+Y            ; -> 8 sub-palette indices
                X = 0
                for $0A = 0..7:
                    Y = ($08),$0A                 ; sub-palette index
                    $0B/$0C = $82F5[Y] / $837D[Y]
                    store $0F, then ($0B),0..2    ; via $80A6: STA $03E0,X / INX

$8080  (set B)  $08 = A (sub-palette index), $09 = X (slot 0..7)
                $0B/$0C = $82F5[A] / $837D[A]
                X = $09 * 4
                store $0F, then ($0B),0..2
```

### Where the 32 bytes end up

`$80A6` writes to the RAM buffer at **`$03E0`-`$03FF`**.
`$80AB` queues it to the PPU:

```
$80AB  JSR $C840          ; -> $CD18: append $01 to the VBlank queue at $0300
       append $00, $3F    ; PPU address $3F00
       append $03E0..$03FF (32 bytes)
       JSR $C846          ; -> $CD09: append $FF (end of block)
       JSR $C840          ; append $01
       append the 7 bytes at $8118: 00 3F FF 01 00 00 FF
                          ; = an empty $3F00 block + an empty $0000 block,
                          ;   i.e. park PPUADDR away from the palette
```

The queue lives at `$0300`, `$1F` is its write pointer, `$CD0B` appends a byte.
Format: `$01`, addr-lo, addr-hi, data..., `$FF`.

### Fading

`$8003` -> `$80D9` (called from `$ED11`) is the fade-out.  Every 16th frame
(`$1C & $0F == 0`) it walks the 32-byte buffer and, for each entry, either
leaves `$0F` alone, subtracts `$10` (one luminance step) or clamps to `$0F`,
then re-uploads with `$80AB`.  It works on the buffer, so a faded palette is
still the same palette set.

## 2. Every palette set

`palette_set_a(i)` — 32 NES colour indices, in `$3F00` order
(`bg0 bg1 bg2 bg3 | spr0 spr1 spr2 spr3`).
The `sub=` column is the 8 sub-palette indices the set is made of.

| # | addr | sub-palette indices | 32 bytes at `$3F00` |
|---|------|--------------------|----------------------|
| A00 | $817D | 16 17 18 19 62 0F 10 07 | `0F 21 15 10 0F 21 11 20 0F 3C 2C 20 0F 38 27 20 0F 15 25 35 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A01 | $8185 | 00 01 04 05 0E 0F 10 07 | `0F 27 16 38 0F 17 06 38 0F 1A 08 39 0F 18 06 36 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A02 | $818D | 00 01 02 03 0E 0F 10 07 | `0F 27 16 38 0F 17 06 38 0F 11 01 23 0F 1A 08 39 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A03 | $8195 | 06 07 08 09 0A 0B 0C 0D | `0F 00 10 20 0F 07 18 27 0F 07 18 37 0F 01 11 21 0F 0F 18 37 0F 0F 22 31 0F 0F 16 36 0F 20 28 18` |
| A04 | $819D | 00 11 12 13 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 1C 0C 3C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A05 | $81A5 | 00 11 12 14 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 18 08 28 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A06 | $81AD | 00 11 15 13 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 15 05 35 0F 1C 0C 3C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A07 | $81B5 | 00 1A 1B 1C 0E 0F 10 07 | `0F 27 16 38 0F 1C 0C 2C 0F 16 06 36 0F 1A 0A 3A 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A08 | $81BD | 00 1D 1E 1F 0E 0F 10 07 | `0F 27 16 38 0F 08 0F 18 0F 10 00 20 0F 19 09 29 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A09 | $81C5 | 00 20 21 22 0E 0F 10 07 | `0F 27 16 38 0F 04 0F 14 0F 11 01 31 0F 06 0F 16 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A10 | $81CD | 00 1D 23 24 0E 0F 10 07 | `0F 27 16 38 0F 08 0F 18 0F 10 00 20 0F 13 03 23 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A11 | $81D5 | 00 01 25 26 0E 0F 10 07 | `0F 27 16 38 0F 17 06 38 0F 12 11 31 0F 15 04 34 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A12 | $81DD | 00 27 28 29 0E 0F 10 07 | `0F 27 16 38 0F 00 00 20 0F 0B 0F 1B 0F 1C 0F 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A13 | $81E5 | 00 2A 2B 2C 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 14 04 24 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A14 | $81ED | 00 2A 2B 2D 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A15 | $81F5 | 00 2A 2E 2F 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 2B 1B 3B 0F 27 17 37 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A16 | $81FD | 00 2A 2B 49 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 15 05 25 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A17 | $8205 | 00 30 31 32 0E 0F 10 07 | `0F 27 16 38 0F 27 16 36 0F 15 05 25 0F 1C 0C 21 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A18 | $820D | 00 33 31 34 0E 0F 10 07 | `0F 27 16 38 0F 2B 1B 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A19 | $8215 | 00 35 31 34 0E 0F 10 07 | `0F 27 16 38 0F 28 18 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A20 | $821D | 00 36 37 38 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 16 06 26 0F 1B 0B 2B 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A21 | $8225 | 39 3A 3B 3C 62 0F 10 07 | `0F 37 27 20 0F 27 17 30 0F 15 15 15 0F 37 37 37 0F 15 25 35 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A22 | $822D | 00 42 43 44 0E 0F 10 07 | `0F 27 16 38 0F 16 05 25 0F 11 01 22 0F 14 04 34 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A23 | $8235 | 00 42 34 45 0E 0F 10 07 | `0F 27 16 38 0F 16 05 25 0F 1C 0C 2C 0F 1A 0A 2A 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A24 | $823D | 00 42 46 36 0E 0F 10 07 | `0F 27 16 38 0F 16 05 25 0F 13 03 23 0F 10 00 20 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A25 | $8245 | 00 42 38 37 0E 0F 10 07 | `0F 27 16 38 0F 16 05 25 0F 1B 0B 2B 0F 16 06 26 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A26 | $824D | 00 48 49 4A 0E 0F 10 07 | `0F 27 16 38 0F 18 08 28 0F 15 05 25 0F 11 01 21 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A27 | $8255 | 00 4B 4C 4D 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 1B 0B 2B 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A28 | $825D | 00 4B 4E 4D 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 13 03 23 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A29 | $8265 | 00 4B 4F 4D 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A30 | $826D | 00 4B 49 4D 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A31 | $8275 | 00 4B 4D 4C 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 1C 0C 2C 0F 1B 0B 2B 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A32 | $827D | 00 4B 48 4D 0E 0F 10 07 | `0F 27 16 38 0F 10 00 20 0F 18 08 28 0F 1C 0C 2C 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A33 | $8285 | 51 52 53 54 0E 0F 10 07 | `0F 28 37 20 0F 34 24 16 0F 28 37 34 0F 28 37 12 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A34 | $828D | 84 85 56 57 60 61 61 61 | `0F 28 37 30 0F 15 12 28 0F 31 0F 0F 0F 28 37 31 0F 0F 37 28 0F 31 31 31 0F 31 31 31 0F 31 31 31` |
| A35 | $8295 | 51 55 58 55 60 61 10 07 | `0F 28 37 20 0F 28 37 0F 0F 0F 31 0F 0F 28 37 0F 0F 0F 37 28 0F 31 31 31 0F 0F 15 20 0F 07 18 27` |
| A36 | $829D | 51 55 59 55 60 61 10 07 | `0F 28 37 20 0F 28 37 0F 0F 0F 0F 31 0F 28 37 0F 0F 0F 37 28 0F 31 31 31 0F 0F 15 20 0F 07 18 27` |
| A37 | $82A5 | 51 5A 5B 54 0E 0F 10 07 | `0F 28 37 20 0F 37 14 12 0F 28 37 14 0F 28 37 12 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A38 | $82AD | 5C 5D 5E 5F 0E 0F 10 07 | `0F 1A 2A 20 0F 1A 2A 15 0F 1A 2A 3A 0F 19 29 12 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A39 | $82B5 | 51 54 54 54 0E 0F 10 07 | `0F 28 37 20 0F 28 37 12 0F 28 37 12 0F 28 37 12 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A40 | $82BD | 51 55 56 57 60 61 10 07 | `0F 28 37 20 0F 28 37 0F 0F 31 0F 0F 0F 28 37 31 0F 0F 37 28 0F 31 31 31 0F 0F 15 20 0F 07 18 27` |
| A41 | $82C5 | 67 68 69 6A 63 64 65 66 | `0F 10 00 20 0F 0F 01 22 0F 22 23 24 0F 10 00 0F 0F 0F 17 37 0F 0F 22 31 0F 0F 16 36 0F 0F 0F 30` |
| A42 | $82CD | 67 6B 6C 6D 63 64 65 66 | `0F 10 00 20 0F 01 22 23 0F 23 24 25 0F 10 00 01 0F 0F 17 37 0F 0F 22 31 0F 0F 16 36 0F 0F 0F 30` |
| A43 | $82D5 | 67 6C 6E 6F 63 64 65 66 | `0F 10 00 20 0F 23 24 25 0F 25 37 27 0F 10 00 23 0F 0F 17 37 0F 0F 22 31 0F 0F 16 36 0F 0F 0F 30` |
| A44 | $82DD | 67 80 81 82 63 64 65 66 | `0F 10 00 20 0F 33 34 35 0F 35 36 37 0F 10 00 33 0F 0F 17 37 0F 0F 22 31 0F 0F 16 36 0F 0F 0F 30` |
| A45 | $82E5 | 84 85 56 57 0E 0F 10 07 | `0F 28 37 30 0F 15 12 28 0F 31 0F 0F 0F 28 37 31 0F 0F 11 20 0F 0F 17 38 0F 0F 15 20 0F 07 18 27` |
| A46 | $82ED | 87 87 87 87 87 87 87 87 | `0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F` |

### Sub-palettes (what `$016E` indexes, and what set A is assembled from)

136 entries, `$8405` + i*3 in practice (the pointer tables are not perfectly
ordered, so always go through `$82F5`/`$837D`).  Shown as the 4 bytes that
land in a `$3F00` slot, i.e. with the implicit `$0F` in front.

| # | addr | slot | # | addr | slot | # | addr | slot | # | addr | slot |
|---|------|------|---|------|------|---|------|------|---|------|------|
| B000 | $8405 | `0F 27 16 38` | B001 | $8408 | `0F 17 06 38` | B002 | $840B | `0F 11 01 23` | B003 | $840E | `0F 1A 08 39` |
| B004 | $8411 | `0F 1A 08 39` | B005 | $8414 | `0F 18 06 36` | B006 | $8417 | `0F 00 10 20` | B007 | $841A | `0F 07 18 27` |
| B008 | $841D | `0F 07 18 37` | B009 | $8420 | `0F 01 11 21` | B010 | $8423 | `0F 0F 18 37` | B011 | $8426 | `0F 0F 22 31` |
| B012 | $8429 | `0F 0F 16 36` | B013 | $842C | `0F 20 28 18` | B014 | $842F | `0F 0F 11 20` | B015 | $8432 | `0F 0F 17 38` |
| B016 | $8435 | `0F 0F 15 20` | B017 | $8438 | `0F 10 00 20` | B018 | $843B | `0F 12 02 22` | B019 | $843E | `0F 1C 0C 3C` |
| B020 | $8441 | `0F 18 08 28` | B021 | $8444 | `0F 15 05 35` | B022 | $8447 | `0F 21 15 10` | B023 | $844A | `0F 21 11 20` |
| B024 | $844D | `0F 3C 2C 20` | B025 | $8450 | `0F 38 27 20` | B026 | $8453 | `0F 1C 0C 2C` | B027 | $8456 | `0F 16 06 36` |
| B028 | $8459 | `0F 1A 0A 3A` | B029 | $845C | `0F 08 0F 18` | B030 | $845F | `0F 10 00 20` | B031 | $8462 | `0F 19 09 29` |
| B032 | $8465 | `0F 04 0F 14` | B033 | $8468 | `0F 11 01 31` | B034 | $846B | `0F 06 0F 16` | B035 | $846E | `0F 10 00 20` |
| B036 | $8471 | `0F 13 03 23` | B037 | $8474 | `0F 12 11 31` | B038 | $8477 | `0F 15 04 34` | B039 | $847A | `0F 00 00 20` |
| B040 | $847D | `0F 0B 0F 1B` | B041 | $8480 | `0F 1C 0F 2C` | B042 | $8483 | `0F 10 00 20` | B043 | $8486 | `0F 11 01 21` |
| B044 | $8489 | `0F 14 04 24` | B045 | $848C | `0F 1C 0C 2C` | B046 | $848F | `0F 2B 1B 3B` | B047 | $8492 | `0F 27 17 37` |
| B048 | $8495 | `0F 27 16 36` | B049 | $8498 | `0F 15 05 25` | B050 | $849B | `0F 1C 0C 21` | B051 | $849E | `0F 2B 1B 20` |
| B052 | $84A1 | `0F 1C 0C 2C` | B053 | $84A4 | `0F 28 18 20` | B054 | $84A7 | `0F 10 00 20` | B055 | $84AA | `0F 16 06 26` |
| B056 | $84AD | `0F 1B 0B 2B` | B057 | $84B0 | `0F 37 27 20` | B058 | $84B3 | `0F 27 17 30` | B059 | $84B6 | `0F 15 15 15` |
| B060 | $84B9 | `0F 37 37 37` | B061 | $84BC | `0F 0F 18 37` | B062 | $84BF | `0F 0F 25 35` | B063 | $84C2 | `0F 0F 27 38` |
| B064 | $84C8 | `0F 0F 22 31` | B065 | $84C5 | `0F 0F 2B 3B` | B066 | $84CB | `0F 16 05 25` | B067 | $84CE | `0F 11 01 22` |
| B068 | $84D1 | `0F 14 04 34` | B069 | $84D4 | `0F 1A 0A 2A` | B070 | $84D7 | `0F 13 03 23` | B071 | $84DA | `0F 1A 09 3A` |
| B072 | $84DD | `0F 18 08 28` | B073 | $84E0 | `0F 15 05 25` | B074 | $84E3 | `0F 11 01 21` | B075 | $84E6 | `0F 10 00 20` |
| B076 | $84E9 | `0F 1B 0B 2B` | B077 | $84EC | `0F 1C 0C 2C` | B078 | $84EF | `0F 13 03 23` | B079 | $84F2 | `0F 11 01 21` |
| B080 | $84F5 | `0F 1B 0B 2B` | B081 | $84F8 | `0F 28 37 20` | B082 | $84FB | `0F 34 24 16` | B083 | $84FE | `0F 28 37 34` |
| B084 | $8501 | `0F 28 37 12` | B085 | $8504 | `0F 28 37 0F` | B086 | $8507 | `0F 31 0F 0F` | B087 | $850A | `0F 28 37 31` |
| B088 | $850D | `0F 0F 31 0F` | B089 | $8510 | `0F 0F 0F 31` | B090 | $8513 | `0F 37 14 12` | B091 | $8516 | `0F 28 37 14` |
| B092 | $8519 | `0F 1A 2A 20` | B093 | $851C | `0F 1A 2A 15` | B094 | $851F | `0F 1A 2A 3A` | B095 | $8522 | `0F 19 29 12` |
| B096 | $8525 | `0F 0F 37 28` | B097 | $8528 | `0F 31 31 31` | B098 | $852B | `0F 15 25 35` | B099 | $852E | `0F 0F 17 37` |
| B100 | $8531 | `0F 0F 22 31` | B101 | $8534 | `0F 0F 16 36` | B102 | $8537 | `0F 0F 0F 30` | B103 | $853A | `0F 10 00 20` |
| B104 | $853D | `0F 0F 01 22` | B105 | $8540 | `0F 22 23 24` | B106 | $8543 | `0F 10 00 0F` | B107 | $8546 | `0F 01 22 23` |
| B108 | $8549 | `0F 23 24 25` | B109 | $854C | `0F 10 00 01` | B110 | $854F | `0F 25 37 27` | B111 | $8552 | `0F 10 00 23` |
| B112 | $8555 | `0F 0F 00 20` | B113 | $8558 | `0F 0F 16 36` | B114 | $855B | `0F 15 26 37` | B115 | $855E | `0F 0F 14 34` |
| B116 | $8561 | `0F 0F 1A 3A` | B117 | $8564 | `0F 0F 17 37` | B118 | $8567 | `0F 0F 31 33` | B119 | $856A | `0F 0F 17 37` |
| B120 | $856D | `0F 0F 1B 3B` | B121 | $8570 | `0F 0F 04 24` | B122 | $8573 | `0F 0F 15 35` | B123 | $8576 | `0F 0F 19 39` |
| B124 | $8579 | `0F 05 15 25` | B125 | $857F | `0F 07 17 27` | B126 | $857C | `0F 01 1C 2C` | B127 | $8582 | `0F 0A 1A 2A` |
| B128 | $8585 | `0F 33 34 35` | B129 | $8588 | `0F 35 36 37` | B130 | $858B | `0F 10 00 33` | B131 | $858E | `0F 10 00 20` |
| B132 | $8591 | `0F 28 37 30` | B133 | $8594 | `0F 15 12 28` | B134 | $8597 | `0F 0F 17 37` | B135 | $859A | `0F 0F 0F 0F` |

Only `$016E` values `$70`-`$7F` and `$86` are used by areas, and `$3D`-`$41`
by the player suits, but the whole 0-135 range is addressable.

### Player suit palettes (slot 5)

`$D8E4`: sub-palette `$3D + $9A`, where `$9A` is the suit (0-4, derived from
the `$56` bitmask through `$D2B9 = 00 01 02 04 08`).

| suit | sub-palette | slot 5 |
|------|-------------|--------|
| 0 | B061 | `0F 0F 18 37` |
| 1 | B062 | `0F 0F 25 35` |
| 2 | B063 | `0F 0F 27 38` |
| 3 | B064 | `0F 0F 22 31` |
| 4 | B065 | `0F 0F 2B 3B` |

## 3. `$0442` and the `$EF3F` table

`$0442` is the **player's animation frame** (object array base `$0442,X`,
slot 0 = player).  `$EF03` is called once per frame from `$EA19`:

```
EF03  AC 42 04  LDY $0442
EF06  B9 3F EF  LDA $EF3F,Y      ; frame -> 1 KB CHR bank
EF09  C0 1F     CPY #$1F
EF0B  B0 07     BCS +            ; frames >= $1F never get the suit offset
EF0D  A4 9A     LDY $9A
EF0F  F0 03     BEQ +
EF11  69 06     ADC #$06         ; suit != 0 -> +6 banks
EF14  85 44     STA $44          ; MMC3 R2 -> $1000-$13FF
```

The rest of `$EF03` (`$EF16`-`$EF3E`) is unrelated: it patches the two
nametable-select bits of the PPUCTRL shadow `$042C`.

`$EF3F` is **62 bytes**, `$EF3F`-`$EF7C` in bank 15, immediately followed by
code at `$EF7D`.  Index = animation frame 0-61, value = CHR bank for `$1000`:

```
  00: 00 00 00 00 05 01 01 01 01 02 02 02 02 02 03 03
  10: 03 03 03 04 04 04 04 04 05 05 05 05 05 05 05 06
  20: 06 06 06 07 07 0C 0C 0C 0D 0D 0D 0D 0E 0E 0E 0E
  30: 0E 0E 0D 0D 00 0C 0F 0F 0F 0F 0F 01 10 10
```

`$45` (R3, `$1400-$17FF`) is a constant, not a table: `$D290`/`$D294` set it
to `$11` for suit 0 and `$12` for any other suit; `$CE08`, `$D038`, `$D31B`
and `$A693` (bank 0) also force `$11`.

So the whole `$1000-$1FFF` half is:

| range | reg | source |
|-------|-----|--------|
| `$1000-$13FF` | R2 | `$EF3F[player anim frame]`, +6 if suit != 0 and frame < `$1F` |
| `$1400-$17FF` | R3 | `$11` (suit 0) / `$12` (suit 1-4) |
| `$1800-$1BFF` | R4 | area record byte 9 |
| `$1C00-$1FFF` | R5 | area record byte 10 |

## 4. Background CHR: `$0000-$0FFF`

```
$EC5C   R0 = $42 * 2   ->  $0000-$07FF   (2 KB)
        R1 = $43 * 2   ->  $0800-$0FFF   (2 KB)
```

`$42` = area record byte 7 and is static for the whole area.
`$43` starts at area record byte 8 and is then **animated**.

## 5. The background animation on R1 (bank pair 4/5)

Two hooks, both switched in with `LDY #$34` -> bank pair 4/5:

```
$D125  Y=$34, JSR $8018 -> $BEC9      at area start
$D130  Y=$34, JSR $801B -> $BF32      every frame
```

`$BEC9` (load the base):

```
BEC9  A9 06     LDA #$06
BECB  A4 79     LDY $79
BECD  D0 02     BNE +            ; $79 != 0 forces the stage-6 list
BECF  A5 53     LDA $53          ; stage
BED1  0A ASL / A8 TAY
BED3  $00/$01 = word $BEEC,Y     ; 7 words -> per-stage list of base bytes
BEDD  A4 9C     LDY $9C          ; area
BEDF  B1 00     LDA ($00),Y
BEE1  C9 FF     CMP #$FF
BEE3  F0 04     BEQ +            ; $FF = no animation
BEE5  85 5D     STA $5D          ; animation base
BEE7  A9 00     LDA #$00
BEE9  85 5C     STA $5C          ; phase (or $FF, which disables via bit 7)
```

`$BF32` (per frame):

```
BF32  if $53==2 and $9C in {3,4}, or $53==3 and $9C==5:
          storm variant - every 256 frames toggle bit 7 of $5C (on/off),
          and while on, step every 4 frames ($1C & 3) and play sound $15
      else:
          if $5C has bit 7 set -> do nothing
          step every 8 frames ($1C & 7)
BF7C  INC $5C ; if $5C == 3 then $5C = 0        ; 3-phase cycle
BF88  $43 = $5D + $5C
```

So `$0800-$0FFF` walks three consecutive 2 KB banks: `($5D+0)*2`,
`($5D+1)*2`, `($5D+2)*2`.

`$BEEC` table (bank 5), 7 words, then the packed base-byte lists:

| stage | list addr | base bytes (one per area) |
|-------|-----------|---------------------------|
| 0 | $BEFA | 3B 3B 3B 3B 3B 3B 3B |
| 1 | $BEFA | 3B 3B 3B 3B 3B 3B 3B 3B |
| 2 | $BF02 | 33 3B 33 33 33 33 33 |
| 3 | $BF09 | 2D 2D 2D 2D 2D 33 2D |
| 4 | $BF10 | 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D |
| 5 | $BF1A | 3B 20 20 20 20 20 20 20 20 20 20 20 20 20 |
| 6 | $BF28 | 3B 2D 3B 3B 3B 3B 3B 3B 3B 2D A5 |

The lists are packed back to back, `$BEFA`-`$BF31`, and end exactly where the
code at `$BF32` starts.  Stages 0 and 1 share the same list pointer
(`$BEFA`); stage 6 therefore only has **10** bytes for its **11** area-record
slots — area 10 reads `$BF32` (`$A5`), which is opcode, not data.  Stage 6's
area 10 is also a duplicate of area 5's record pointer (`$ADF0`), so it looks
like a padding slot rather than a real area.

## 6. Stage / area table

`R0`, `R4`, `R5` are the raw MMC3 register values; the "background banks"
column lists the four 1 KB CHR banks that make up `$0000-$0FFF` for each of
the three animation phases.  `R2` is shown for animation frame 0 / suit 0.

| stage/area | set A | set B | R0 | base | R2 | R3 | R4 | R5 | $0000-$0FFF, phase 0 / 1 / 2 |
|------------|-------|-------|----|------|----|----|----|----|------------------------------|
| 0/0  | A02 | B112 | 7C | 3B | 00 | 11 | 19 | 13 | `7C 7D 76 77 / 7C 7D 78 79 / 7C 7D 7A 7B` |
| 0/1  | A01 | B112 | 7E | 3B | 00 | 11 | 19 | 13 | `7E 7F 76 77 / 7E 7F 78 79 / 7E 7F 7A 7B` |
| 0/2  | A02 | B112 | 7C | 3B | 00 | 11 | 19 | 13 | `7C 7D 76 77 / 7C 7D 78 79 / 7C 7D 7A 7B` |
| 0/3  | A01 | B112 | 7E | 3B | 00 | 11 | 1A | 13 | `7E 7F 76 77 / 7E 7F 78 79 / 7E 7F 7A 7B` |
| 0/4  | A02 | B112 | 7C | 3B | 00 | 11 | 1B | 13 | `7C 7D 76 77 / 7C 7D 78 79 / 7C 7D 7A 7B` |
| 0/5  | A12 | B112 | 7E | 3B | 00 | 11 | 21 | 13 | `7E 7F 76 77 / 7E 7F 78 79 / 7E 7F 7A 7B` |
| 0/6  | A11 | B115 | 7C | 3B | 00 | 11 | 19 | 16 | `7C 7D 76 77 / 7C 7D 78 79 / 7C 7D 7A 7B` |
| 1/0  | A04 | B112 | 70 | 3B | 00 | 11 | 19 | 13 | `70 71 76 77 / 70 71 78 79 / 70 71 7A 7B` |
| 1/1  | A04 | B115 | 70 | 3B | 00 | 11 | 1A | 16 | `70 71 76 77 / 70 71 78 79 / 70 71 7A 7B` |
| 1/2  | A04 | B118 | 72 | 3B | 00 | 11 | 19 | 23 | `72 73 76 77 / 72 73 78 79 / 72 73 7A 7B` |
| 1/3  | A04 | B118 | 72 | 3B | 00 | 11 | 19 | 23 | `72 73 76 77 / 72 73 78 79 / 72 73 7A 7B` |
| 1/4  | A04 | B118 | 72 | 3B | 00 | 11 | 19 | 23 | `72 73 76 77 / 72 73 78 79 / 72 73 7A 7B` |
| 1/5  | A06 | B112 | 72 | 3B | 00 | 11 | 19 | 13 | `72 73 76 77 / 72 73 78 79 / 72 73 7A 7B` |
| 1/6  | A04 | B115 | 70 | 3B | 00 | 11 | 20 | 16 | `70 71 76 77 / 70 71 78 79 / 70 71 7A 7B` |
| 1/7  | A05 | B112 | 70 | 3B | 00 | 11 | 19 | 13 | `70 71 76 77 / 70 71 78 79 / 70 71 7A 7B` |
| 2/0  | A07 | B115 | 6E | 33 | 00 | 11 | 19 | 16 | `6E 6F 66 67 / 6E 6F 68 69 / 6E 6F 6A 6B` |
| 2/1  | A07 | B112 | 6E | 3B | 00 | 11 | 20 | 13 | `6E 6F 76 77 / 6E 6F 78 79 / 6E 6F 7A 7B` |
| 2/2  | A08 | B116 | 6C | 33 | 00 | 11 | 1A | 17 | `6C 6D 66 67 / 6C 6D 68 69 / 6C 6D 6A 6B` |
| 2/3  | A09 | B112 | 6E | 33 | 00 | 11 | 19 | 13 | `6E 6F 66 67 / 6E 6F 68 69 / 6E 6F 6A 6B` |
| 2/4  | A10 | B112 | 6C | 33 | 00 | 11 | 1B | 13 | `6C 6D 66 67 / 6C 6D 68 69 / 6C 6D 6A 6B` |
| 2/5  | A07 | B117 | 6E | 33 | 00 | 11 | 21 | 18 | `6E 6F 66 67 / 6E 6F 68 69 / 6E 6F 6A 6B` |
| 2/6  | A10 | B117 | 6C | 33 | 00 | 11 | 1B | 18 | `6C 6D 66 67 / 6C 6D 68 69 / 6C 6D 6A 6B` |
| 3/0  | A17 | B117 | 60 | 2D | 00 | 11 | 20 | 18 | `60 61 5A 5B / 60 61 5C 5D / 60 61 5E 5F` |
| 3/1  | A18 | B118 | 62 | 2D | 00 | 11 | 1A | 23 | `62 63 5A 5B / 62 63 5C 5D / 62 63 5E 5F` |
| 3/2  | A19 | B118 | 62 | 2D | 00 | 11 | 19 | 23 | `62 63 5A 5B / 62 63 5C 5D / 62 63 5E 5F` |
| 3/3  | A18 | B112 | 62 | 2D | 00 | 11 | 19 | 13 | `62 63 5A 5B / 62 63 5C 5D / 62 63 5E 5F` |
| 3/4  | A19 | B116 | 62 | 2D | 00 | 11 | 1A | 17 | `62 63 5A 5B / 62 63 5C 5D / 62 63 5E 5F` |
| 3/5  | A17 | B115 | 60 | 33 | 00 | 11 | 1B | 16 | `60 61 66 67 / 60 61 68 69 / 60 61 6A 6B` |
| 3/6  | A20 | B112 | 60 | 2D | 00 | 11 | 19 | 13 | `60 61 5A 5B / 60 61 5C 5D / 60 61 5E 5F` |
| 4/0  | A13 | B117 | 54 | 2D | 00 | 11 | 1B | 18 | `54 55 5A 5B / 54 55 5C 5D / 54 55 5E 5F` |
| 4/1  | A13 | B115 | 54 | 2D | 00 | 11 | 19 | 16 | `54 55 5A 5B / 54 55 5C 5D / 54 55 5E 5F` |
| 4/2  | A13 | B116 | 54 | 2D | 00 | 11 | 21 | 17 | `54 55 5A 5B / 54 55 5C 5D / 54 55 5E 5F` |
| 4/3  | A14 | B134 | 54 | 2D | 00 | 11 | 10 | 14 | `54 55 5A 5B / 54 55 5C 5D / 54 55 5E 5F` |
| 4/4  | A15 | B112 | 56 | 2D | 00 | 11 | 19 | 13 | `56 57 5A 5B / 56 57 5C 5D / 56 57 5E 5F` |
| 4/5  | A16 | B112 | 56 | 2D | 00 | 11 | 19 | 13 | `56 57 5A 5B / 56 57 5C 5D / 56 57 5E 5F` |
| 4/6  | A16 | B118 | 56 | 2D | 00 | 11 | 19 | 23 | `56 57 5A 5B / 56 57 5C 5D / 56 57 5E 5F` |
| 4/7  | A16 | B118 | 56 | 2D | 00 | 11 | 21 | 23 | `56 57 5A 5B / 56 57 5C 5D / 56 57 5E 5F` |
| 4/8  | A16 | B112 | 56 | 2D | 00 | 11 | 19 | 13 | `56 57 5A 5B / 56 57 5C 5D / 56 57 5E 5F` |
| 4/9  | A16 | B115 | 56 | 2D | 00 | 11 | 21 | 16 | `56 57 5A 5B / 56 57 5C 5D / 56 57 5E 5F` |
| 5/0  | A26 | B113 | 58 | 3B | 00 | 11 | 1A | 14 | `58 59 76 77 / 58 59 78 79 / 58 59 7A 7B` |
| 5/1  | A22 | B113 | 50 | 20 | 00 | 11 | 1A | 14 | `50 51 40 41 / 50 51 42 43 / 50 51 44 45` |
| 5/2  | A25 | B113 | 52 | 20 | 00 | 11 | 19 | 14 | `52 53 40 41 / 52 53 42 43 / 52 53 44 45` |
| 5/3  | A22 | B112 | 50 | 20 | 00 | 11 | 19 | 13 | `50 51 40 41 / 50 51 42 43 / 50 51 44 45` |
| 5/4  | A23 | B113 | 52 | 20 | 00 | 11 | 19 | 14 | `52 53 40 41 / 52 53 42 43 / 52 53 44 45` |
| 5/5  | A23 | B113 | 52 | 20 | 00 | 11 | 1A | 14 | `52 53 40 41 / 52 53 42 43 / 52 53 44 45` |
| 5/6  | A23 | B115 | 52 | 20 | 00 | 11 | 1B | 16 | `52 53 40 41 / 52 53 42 43 / 52 53 44 45` |
| 5/7  | A22 | B116 | 50 | 20 | 00 | 11 | 1A | 17 | `50 51 40 41 / 50 51 42 43 / 50 51 44 45` |
| 5/8  | A23 | B114 | 52 | 20 | 00 | 11 | 19 | 15 | `52 53 40 41 / 52 53 42 43 / 52 53 44 45` |
| 5/9  | A22 | B113 | 50 | 20 | 00 | 11 | 20 | 23 | `50 51 40 41 / 50 51 42 43 / 50 51 44 45` |
| 5/10 | A23 | B117 | 52 | 20 | 00 | 11 | 19 | 18 | `52 53 40 41 / 52 53 42 43 / 52 53 44 45` |
| 5/11 | A22 | B114 | 50 | 20 | 00 | 11 | 21 | 15 | `50 51 40 41 / 50 51 42 43 / 50 51 44 45` |
| 5/12 | A25 | B114 | 52 | 20 | 00 | 11 | 19 | 15 | `52 53 40 41 / 52 53 42 43 / 52 53 44 45` |
| 5/13 | A24 | B113 | 50 | 20 | 00 | 11 | 1A | 14 | `50 51 40 41 / 50 51 42 43 / 50 51 44 45` |
| 6/0  | A29 | B120 | 74 | 3B | 00 | 11 | 24 | 25 | `74 75 76 77 / 74 75 78 79 / 74 75 7A 7B` |
| 6/1  | A30 | B118 | 74 | 2D | 00 | 11 | 3A | 3A | `74 75 5A 5B / 74 75 5C 5D / 74 75 5E 5F` |
| 6/2  | A31 | B121 | 74 | 3B | 00 | 11 | 26 | 27 | `74 75 76 77 / 74 75 78 79 / 74 75 7A 7B` |
| 6/3  | A32 | B122 | 74 | 3B | 00 | 11 | 28 | 29 | `74 75 76 77 / 74 75 78 79 / 74 75 7A 7B` |
| 6/4  | A26 | B123 | 58 | 3B | 00 | 11 | 2A | 2B | `58 59 76 77 / 58 59 78 79 / 58 59 7A 7B` |
| 6/5  | A26 | B119 | 58 | 3B | 00 | 11 | 2C | 2D | `58 59 76 77 / 58 59 78 79 / 58 59 7A 7B` |
| 6/6  | A27 | B124 | 74 | 3B | 00 | 11 | 22 | 23 | `74 75 76 77 / 74 75 78 79 / 74 75 7A 7B` |
| 6/7  | A27 | B125 | 74 | 3B | 00 | 11 | 22 | 23 | `74 75 76 77 / 74 75 78 79 / 74 75 7A 7B` |
| 6/8  | A28 | B126 | 74 | 3B | 00 | 11 | 22 | 23 | `74 75 76 77 / 74 75 78 79 / 74 75 7A 7B` |
| 6/9  | A28 | B127 | 74 | 2D | 00 | 11 | 22 | 23 | `74 75 5A 5B / 74 75 5C 5D / 74 75 5E 5F` |
| 6/10 | A26 | B119 | 58 | A5 | 00 | 11 | 2C | 2D | `58 59 4A 4B / 58 59 4C 4D / 58 59 4E 4F` |

### The assembled `$3F00` palette per area (suit 0)

| stage/area | 32 bytes |
|------------|----------|
| 0/0  | `0F 27 16 38 0F 17 06 38 0F 11 01 23 0F 1A 08 39 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 0/1  | `0F 27 16 38 0F 17 06 38 0F 1A 08 39 0F 18 06 36 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 0/2  | `0F 27 16 38 0F 17 06 38 0F 11 01 23 0F 1A 08 39 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 0/3  | `0F 27 16 38 0F 17 06 38 0F 1A 08 39 0F 18 06 36 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 0/4  | `0F 27 16 38 0F 17 06 38 0F 11 01 23 0F 1A 08 39 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 0/5  | `0F 27 16 38 0F 00 00 20 0F 0B 0F 1B 0F 1C 0F 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 0/6  | `0F 27 16 38 0F 17 06 38 0F 12 11 31 0F 15 04 34 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 1/0  | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 1C 0C 3C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 1/1  | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 1C 0C 3C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 1/2  | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 1C 0C 3C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 1/3  | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 1C 0C 3C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 1/4  | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 1C 0C 3C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 1/5  | `0F 27 16 38 0F 10 00 20 0F 15 05 35 0F 1C 0C 3C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 1/6  | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 1C 0C 3C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 1/7  | `0F 27 16 38 0F 10 00 20 0F 12 02 22 0F 18 08 28 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 2/0  | `0F 27 16 38 0F 1C 0C 2C 0F 16 06 36 0F 1A 0A 3A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 2/1  | `0F 27 16 38 0F 1C 0C 2C 0F 16 06 36 0F 1A 0A 3A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 2/2  | `0F 27 16 38 0F 08 0F 18 0F 10 00 20 0F 19 09 29 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 1A 3A` |
| 2/3  | `0F 27 16 38 0F 04 0F 14 0F 11 01 31 0F 06 0F 16 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 2/4  | `0F 27 16 38 0F 08 0F 18 0F 10 00 20 0F 13 03 23 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 2/5  | `0F 27 16 38 0F 1C 0C 2C 0F 16 06 36 0F 1A 0A 3A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |
| 2/6  | `0F 27 16 38 0F 08 0F 18 0F 10 00 20 0F 13 03 23 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |
| 3/0  | `0F 27 16 38 0F 27 16 36 0F 15 05 25 0F 1C 0C 21 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |
| 3/1  | `0F 27 16 38 0F 2B 1B 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 3/2  | `0F 27 16 38 0F 28 18 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 3/3  | `0F 27 16 38 0F 2B 1B 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 3/4  | `0F 27 16 38 0F 28 18 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 1A 3A` |
| 3/5  | `0F 27 16 38 0F 27 16 36 0F 15 05 25 0F 1C 0C 21 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 3/6  | `0F 27 16 38 0F 10 00 20 0F 16 06 26 0F 1B 0B 2B 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 4/0  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 14 04 24 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |
| 4/1  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 14 04 24 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 4/2  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 14 04 24 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 1A 3A` |
| 4/3  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |
| 4/4  | `0F 27 16 38 0F 10 00 20 0F 2B 1B 3B 0F 27 17 37 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 4/5  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 15 05 25 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 4/6  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 15 05 25 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 4/7  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 15 05 25 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 4/8  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 15 05 25 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 4/9  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 15 05 25 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 5/0  | `0F 27 16 38 0F 18 08 28 0F 15 05 25 0F 11 01 21 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 16 36` |
| 5/1  | `0F 27 16 38 0F 16 05 25 0F 11 01 22 0F 14 04 34 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 16 36` |
| 5/2  | `0F 27 16 38 0F 16 05 25 0F 1B 0B 2B 0F 16 06 26 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 16 36` |
| 5/3  | `0F 27 16 38 0F 16 05 25 0F 11 01 22 0F 14 04 34 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20` |
| 5/4  | `0F 27 16 38 0F 16 05 25 0F 1C 0C 2C 0F 1A 0A 2A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 16 36` |
| 5/5  | `0F 27 16 38 0F 16 05 25 0F 1C 0C 2C 0F 1A 0A 2A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 16 36` |
| 5/6  | `0F 27 16 38 0F 16 05 25 0F 1C 0C 2C 0F 1A 0A 2A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 14 34` |
| 5/7  | `0F 27 16 38 0F 16 05 25 0F 11 01 22 0F 14 04 34 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 1A 3A` |
| 5/8  | `0F 27 16 38 0F 16 05 25 0F 1C 0C 2C 0F 1A 0A 2A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 15 26 37` |
| 5/9  | `0F 27 16 38 0F 16 05 25 0F 11 01 22 0F 14 04 34 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 16 36` |
| 5/10 | `0F 27 16 38 0F 16 05 25 0F 1C 0C 2C 0F 1A 0A 2A 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |
| 5/11 | `0F 27 16 38 0F 16 05 25 0F 11 01 22 0F 14 04 34 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 15 26 37` |
| 5/12 | `0F 27 16 38 0F 16 05 25 0F 1B 0B 2B 0F 16 06 26 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 15 26 37` |
| 5/13 | `0F 27 16 38 0F 16 05 25 0F 13 03 23 0F 10 00 20 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 16 36` |
| 6/0  | `0F 27 16 38 0F 10 00 20 0F 11 01 21 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 1B 3B` |
| 6/1  | `0F 27 16 38 0F 10 00 20 0F 15 05 25 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 31 33` |
| 6/2  | `0F 27 16 38 0F 10 00 20 0F 1C 0C 2C 0F 1B 0B 2B 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 04 24` |
| 6/3  | `0F 27 16 38 0F 10 00 20 0F 18 08 28 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 15 35` |
| 6/4  | `0F 27 16 38 0F 18 08 28 0F 15 05 25 0F 11 01 21 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 19 39` |
| 6/5  | `0F 27 16 38 0F 18 08 28 0F 15 05 25 0F 11 01 21 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |
| 6/6  | `0F 27 16 38 0F 10 00 20 0F 1B 0B 2B 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 05 15 25` |
| 6/7  | `0F 27 16 38 0F 10 00 20 0F 1B 0B 2B 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 07 17 27` |
| 6/8  | `0F 27 16 38 0F 10 00 20 0F 13 03 23 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 01 1C 2C` |
| 6/9  | `0F 27 16 38 0F 10 00 20 0F 13 03 23 0F 1C 0C 2C 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0A 1A 2A` |
| 6/10 | `0F 27 16 38 0F 18 08 28 0F 15 05 25 0F 11 01 21 0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 17 37` |

## 7. Adding new palette sets and new background CHR assignments

### 7.1 What limits what

| thing | hard limit | why |
|-------|-----------|-----|
| palette sets (`$016D`) | 128 | `$8046 ASL A` before `LDA $811F,Y`, so index*2 must stay 8-bit |
| sub-palettes (`$016E`) | 256 | `$8084 TAY`, single-byte index into `$82F5`/`$837D` |
| areas per stage | 128 | `$E265 ASL A` on `$9C` |
| `R0`/`R1` values | 0-63 | written `*2` into a 2 KB slot; CHR is 128 KB = 64 x 2 KB |
| `R4`/`R5` values | 0-127 | 1 KB slots, 128 KB CHR |
| animation frames (`$EF3F`) | 62 | table ends at code `$EF7D`; no bound check on `$0442` |

Nothing is length-prefixed or terminated.  Every count in this document is
implied by where the next block starts, which means **you cannot grow any
table in place** — all of them butt straight against the next one.

### 7.2 The exact reads to repoint

Palette set A (bank 0):

| addr | instruction | repoint to |
|------|-------------|------------|
| `$8048` | `LDA $811F,Y` | new pointer table LO |
| `$804D` | `LDA $8120,Y` | new pointer table HI (= LO+1) |

Sub-palettes — four reads, two in each build routine (bank 0):

| addr | instruction | table |
|------|-------------|-------|
| `$805C` | `LDA $82F5,Y` | LO, set-A path |
| `$8061` | `LDA $837D,Y` | HI, set-A path |
| `$8085` | `LDA $82F5,Y` | LO, set-B path |
| `$808A` | `LDA $837D,Y` | HI, set-B path |

Area records (bank 15 / bank pair 6/7):

| addr | instruction | table |
|------|-------------|-------|
| `$E24E`/`$E253` | `LDA $E2BC,Y` / `LDA $E2BD,Y` | 7 words -> one word slot per stage |
| `$E267`/`$E26C` | `LDA ($02),Y` | per-stage record pointer table |

Background animation (bank 5):

| addr | instruction | table |
|------|-------------|-------|
| `$BED3`/`$BED8` | `LDA $BEEC,Y` / `LDA $BEED,Y` | 7 words -> per-stage base list |

Player animation banks (bank 15):

| addr | instruction | table |
|------|-------------|-------|
| `$EF06` | `LDA $EF3F,Y` | 62 bytes |

### 7.3 Free space

There is essentially none in the banks that matter.  Longest run of `$FF`
per PRG bank:

```
bank  0:   2 bytes      bank  8: 150 at $8D6A
bank  1:  75 at $BFB5   bank  9: 103 at $BF99
bank  2:   4            bank 10:   2
bank  3:  38 at $BFDA   bank 11: 203 at $BF35
bank  4:   3            bank 12:   2
bank  5: 112 at $BF90   bank 13:   7
bank  6:   1            bank 14:  24 at $C1E8
bank  7:  53 at $BFCB   bank 15:   2
```

Bank 0 (the whole palette engine) is completely full, so any expansion has to
move data out of it.

### 7.4 Recommended plan for PB3

1. **Lift the 16-bank ceiling first.**  `$ECAB` does `TYA / AND #$0F`, which
   is why the stock cartridge only ever reaches banks 0-15.  Widen that mask
   and the extra PRG banks become usable targets for the new tables.
2. **Move the palette tables wholesale into a new bank**, keeping the exact
   same shapes (pointer table -> 8-byte index lists; split LO/HI pointer
   tables -> 3-byte sub-palettes).  Patch the six reads in 7.2.  The four
   sub-palette reads are the only thing sub-palettes are reached through, so
   moving them is a six-byte patch, not a rewrite.
3. **Store real counts.**  Nothing in the engine needs them, but every tool
   currently has to reconstruct them from "the table ends where its data
   starts".  If new tables are emitted with the data block *after* all
   pointers (as the originals are), existing tooling keeps working.
4. **Palette sets are the cheap axis.**  A new area only needs new *entries*
   in `$811F`/`$817D`, and those entries can reuse existing sub-palettes.  A
   genuinely new colour needs a new 3-byte sub-palette and one new LO/HI pair.
5. **Background CHR needs no new table at all.**  `R0` and `R4`/`R5` are raw
   bytes in the 14-byte area record, so a new area picks any CHR banks by
   writing bytes 7, 9, 10.  The only table involved is the animation base
   list at `$BEEC`; give each new area a base byte there (or `$FF` for a
   static background).  Remember the base must have three usable consecutive
   2 KB banks after it.
6. **`$EF3F` only needs touching if the player gets more animation frames.**
   It is player data, not level data, so Solbrain levels can leave it alone.

## 8. Verification

Method: boot to gameplay with `/tmp/boot.inp`, savestate at frame 1500, then
for each (stage, area) reload the state with `-freeze 53=stage -freeze 9C=area
-poke 1A=0@1505` (state `$1A` = 0 restarts the level-load sequence, which
re-reads the area record) and capture `-vram` at frame 1610.  Compared
`PB2Palettes.area_palette()` against the live 32 bytes of PPU palette memory,
and `area_chr_full()` against the per-scanline MMC3 CHR bank latches.

17 stage/area combinations across all 7 stages, all byte-for-byte:

| stage/area | palette | 8 CHR banks |
|------------|---------|-------------|
| 0/0, 0/5, 0/6 | match | match |
| 1/1, 1/2, 1/6 | match | match |
| 2/0, 2/4 | match | match |
| 3/1, 3/5 | match | match |
| 4/0, 4/3, 4/6 | match | match |
| 5/1, 5/9 | match | match |
| 6/0, 6/2 | match | match |

Sample (stage 0 area 0, frame 1850 of a plain playthrough — no pokes at all):

```
predicted 0F 27 16 38 0F 17 06 38 0F 11 01 23 0F 1A 08 39
          0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20
live      0F 27 16 38 0F 17 06 38 0F 11 01 23 0F 1A 08 39
          0F 0F 11 20 0F 0F 18 37 0F 0F 15 20 0F 0F 00 20
CHR pred  7C 7D 78 79 03 11 19 13
CHR live  7C 7D 78 79 03 11 19 13
```

Suits were checked separately (`-freeze 9A=n -poke 1A=0@1505`): slot 5 matched
`subpalette($3D + $9A)` for all five suits, and `$44` matched
`$EF3F[$0442] + 6` for suits 1-4.

### Not verified

* **`$45` = `$12` for suits 1-4.**  The store at `$D294` only runs inside the
  suit-change routine, which the `-freeze 9A` shortcut bypasses, so `$45`
  stayed `$11` in the capture.  The value is read straight off the
  disassembly.
* **Base byte `$FF` (animation disabled).**  No stage/area in the stock ROM
  uses it; the `CMP #$FF` branch at `$BEE1` is from the disassembly only.
* **Stage 6 area 10.**  Its animation base byte reads past the end of the
  table (`$BF32` = `$A5`).  The area looks like a padding slot and was not
  reached in a real playthrough.
* **`$016D`/`$016E` outside the values the stock areas use.**  The build
  routines have no bounds check, so out-of-range indices are undefined but
  harmless in the sense that they just read neighbouring ROM.
* The second palette engine at bank pair 4/5 `$801B` -> `$BF32` shares the
  `$801B` slot number with bank 0's palette builder; only bank 0's is the
  palette one.  There is no third palette table.
