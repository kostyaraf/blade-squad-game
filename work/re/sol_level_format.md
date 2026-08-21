# Tokkyuu Shirei Solbrain (Japan) — level data format

Reverse-engineered from `Tokkyuu Shirei Solbrain (Japan).nes`
(iNES mapper 4 / MMC3, 128 K PRG = 16 × 8 K banks, 128 K CHR, vertical mirroring).

Every claim below cites the ROM address of the code that proves it.  Addresses
are **CPU** addresses.  PRG mode 0 is used, so:

| CPU window | contents |
|---|---|
| `$8000-$9FFF` | switchable 8 K bank (MMC3 R6) |
| `$A000-$BFFF` | switchable 8 K bank (MMC3 R7) |
| `$C000-$DFFF` | fixed bank 14 |
| `$E000-$FFFF` | fixed bank 15 |

The level code always maps an **even/odd pair** into `$8000-$BFFF` at once
(`$C92C` is the "load bank pair" helper called from `$E6CD`), so throughout
this document "PRG pair *n*" means banks *n* and *n*+1 mapped at `$8000`.

Decoder: [`work/tools/sol_levels.py`](../tools/sol_levels.py).
Proof: [§9](#9-proof).

---

## 1. Coordinate system

All world positions are **fixed point with 16 sub-units per pixel**, stored
little-endian in 16-bit zero-page pairs.  The high byte therefore counts 16-pixel
units, which is why the engine can index metatiles straight out of it.

| quantity | zero page | proof |
|---|---|---|
| camera X | `$30/$31` | `$EC44` reads `$31` to detect an 8-px move |
| camera Y | `$32/$33` | `$EC2B`, `$EC06` |
| collision probe X | `$90/$91` | `$D0C4 LDA $91` |
| collision probe Y | `$92/$93` | `$D0CB LDA $93` |

Hierarchy (each level of it is proved by the index arithmetic quoted in §4):

```
room      256 x 256 px   =  8 x 8  blocks
block      32 x  32 px   =  2 x 2  metatiles
metatile   16 x  16 px   =  2 x 2  tiles      <-- unit of palette + collision
tile        8 x   8 px                        <-- unit of CHR pattern
```

The room grid is **16 rooms wide**; a room id is `roomY*16 + roomX`
(`$EFA0`: `LDA $91 / LSR x4 / STA $9F / LDA $93 / AND #$F0 / ADC $9F / TAY`).
The same formula builds the room id cached in `$05EB` at `$93B5`.

---

## 2. Stage selection

`$55` holds the stage/area index, `0..19`.  `$E6C7` onward:

```
E6C7  LDX $55
E6C9  LDA $C965,X          ; even PRG bank of the pair holding this stage
E6CC  ...
E6CD  JSR $C92C            ; map that pair at $8000-$BFFF
E6CF  LDA $55
E6D1  ASL A
E6D2  TAY
E6D3  LDA $E6E0,Y  -> $90  ; pointer to the 20-byte area header
E6D8  LDA $E6E1,Y  -> $91
E6DD  JMP $E708
```

* `$C965` (bank 14) — 20 bytes, the even bank number:
  `04 06 06 06 06 06 06 06 04 06 04 04 06 06 04 04 04 06 06 04`
* `$E6E0` (bank 15) — 20 little-endian pointers into bank 15:
  `E7D9 E851 E865 E8DD E829 E83D E88D E8A1 E8C9 E8F1 E919 E92D E8B5 E879 E941 E955 E969 E991 E905 E97D`

The pointer table is followed by an array of 20-byte records starting at
`$E7D9`.  Records at `$E7ED`, `$E801` and `$E815` sit inside that array but are
referenced by no pointer and by no code (verified by searching all 16 banks for
their byte encodings) — **leftover / unused data**.

---

## 3. Area header (20 bytes)

Parsed linearly by `$E708`-`$E77C`:

| off | destination | meaning | proof |
|---|---|---|---|
| 0 | X | byte offset into the tileset table | `$E644 TAX`, used by `$E642` |
| 1,2 | `$80/$81` | player start X (16 u/px); `$31 = b2 & $F0` | `$E70C` |
| 3,4 | `$82/$83` | player start Y; `$33 = b4 & $F0` | `$E71D` |
| 5 | `$39` (`$38=0`) | camera X minimum, high byte | `$E730` |
| 6 | `$3B` (`$3A=0`) | world right edge, high byte | `$E735` |
| 7 | `$3D` (`$3C=0`) | camera Y minimum, high byte | `$E73A` |
| 8 | `$3F` (`$3E=0`) | world bottom edge, high byte | `$E73F` |
| 9,10 | `$20/$21` | pointer to the 32-byte palette | `$E744` |
| 11..16 | `$40..$45` | MMC3 CHR registers R0..R5 | `$E74E`-`$E767` |
| 17,18 | `$92/$93` | always `D2 E9` — **purpose unverified** | `$E76C` |
| 19 | compared with `$2E` | music track | `$E776` |

Camera clamping (`$F1F0`-`$F248` for X, `$F27E`-`$F2C7` for Y) keeps

```
camera X in [ ($38,$39) , ($3A,$3B) - $1000 ]      ; $1000 units = 256 px
camera Y in [ ($3C,$3D) , ($3E,$3F) - $1000 ]
```

**Important caveat:** these bounds are only the *initial* ones.  The per-stage
scroll scripts in PRG pair 8/9 (dispatch table `$93E8 + stage*2`; stage 0 →
`$9410` → per-room routine table `$9422` indexed via `$957E,Y` with Y = room id)
rewrite `$38`-`$3F` as the player advances — there are hundreds of
`STA $39/$3B/$3D/$3F` sites in banks 8 and 9.  The true playable extent must
therefore be taken from the room map plus the object room table (§7), not from
the header.  The contents of those per-room scripts are **not enumerated here**.

Immediately after parsing, `$E77E` clears the level to its start state:

```
E77E  LDA #$FF / LDX #$1F / STA $0540,X ...   ; 32-byte metatile alt-state bitmap
E788  LDX #$3F / LDA #$01 / STA $0560,X ...   ; 64 object "alive" flags
```

---

## 4. Tileset record and the tile tables

`$E642` loads six pointers from a 12-byte record at `$800D + b0`, inside the
stage's own PRG pair:

```
E642  LDY #$00
E644  LDX <b0>
E647  LDA $800D,X -> $10   ; +0  quad table   (metatile -> 4 tile numbers)
      LDA $800E,X -> $11
      LDA $800F,X -> $12   ; +2  block table  (block -> 4 metatile ids)
      LDA $8010,X -> $13
      LDA $8011,X -> $14   ; +4  screen table (64 bytes per screen)
      LDA $8012,X -> $15
      LDA $8013,X -> $1E   ; +6  room map     (16 wide)
      LDA $8014,X -> $1F
      LDA $8015,X -> $16   ; +8  property table (1 byte per metatile)
      LDA $8016,X -> $17
      LDA $8017,X -> $18   ; +10 alternate table (1 byte per metatile)
      LDA $8018,X -> $19
```

(Record `$24` in PRG pair 4/5 is a `JMP` table, not a tileset — pair 4/5 has
records at `$00,$0C,$18,$30,$3C` only.)

### 4.1 Room map → screen

`roommap[roomY*16 + roomX]` = screen id.  Proof `$EFB0 LDA ($1E),Y` with Y built
as in §1.  Screen id 0 is the blank filler used to pad the unused parts of the
16-wide grid.

### 4.2 Screen → block (64 bytes, **row major**, 8 × 8)

```
EFB4  LDA #$00 / LSR $95 / ROR A / LSR $95 / ROR A   ; screen * 64
EFBC  ADC $14 -> $94 ; ... $95                        ; + screen table base
```
and the index within the screen (from the collision copy, `$D0C4`):
```
D0C4  LDA $91 / ROR A / AND #$07 -> $9E     ; block column = (Xpx/32) & 7
D0CB  LDA $93 / AND #$0E / ASL / ASL        ; block row * 8
D0D1  ADC $9E / TAY / LDA ($94),Y           ; = screens[row*8 + col]
```

### 4.3 Block → metatile (4 bytes, **column major**)

```
D0D6  LDY $13 / ASL A / BCC + / INY INY     ; block * 4 (16-bit)
D0DD  ASL A / BCC + / INY
D0E2  ADC $12 -> $97 ; STY $98
D0EB  LDY #$00
D0ED  LDA $93 / ROR A / BCC + / INY         ; +1 for the lower half
D0F3  LDA $91 / ROR A / BCC + / INY INY     ; +2 for the right half
D0FA  LDA ($97),Y                           ; = blocks[b*4 + xhalf*2 + yhalf]
```
so the four bytes are `[left-top, left-bottom, right-top, right-bottom]`.
The renderer does the same thing at `$F031`.

### 4.4 Metatile → 4 tiles (4 bytes, **column major**)

`quads[m*4 + tileX*2 + tileY]` = `[TL, BL, TR, BR]` (`$F031` expands one block
into four tile numbers at `$0300,X` plus two property bytes at `$0390,X`).

### 4.5 Property byte

`props[m]`, one byte per metatile (`$D0FF LDA ($16),Y`):

```
bit 7,6  background palette (0..3) for this 16x16 metatile
bit 5    "has an alternate state" — see §4.6
bits 4..0  collision class
```

Collision consumers see the byte **shifted left three times**
(`$D101 ASL A / ASL A / ASL A`), so bit 4 becomes the sign bit.  One classifier,
`$8DC5` in PRG pair 2/3, reads:

```
8DC5  BMI $8DD6        ; props bit4 set -> return as-is  == SOLID
8DC7  AND #$E0
8DC9  CMP #$60 / BEQ $8DD4
8DCD  AND #$20 / BEQ $8DD4   ; props bit2 -> $FF
8DD1  LDA #$00 / RTS
8DD4  LDA #$FF / RTS
```

**Verified:** bit 4 = solid.  The precise meaning of bits 3..0 beyond "bit 2 is
a second class that `$8DC5` reports as `$FF`" is **unverified**; the decoder
emits the raw 5-bit class so nothing is lost.  Values that actually occur across
all 20 stages: `00 01 02 03 04 06 07 08 0C 0D 0E 0F 10 11 13 14 15 16 17 18 19
1A 1B`.

### 4.6 Alternate metatiles (destructible / switchable scenery)

If `props[m] & $20`, the metatile has a second form in `alt[m]`, selected by a
32-byte RAM bitmap at `$0540`-`$055F` (`$0540[m>>3]` tested with
`$D136[m&7]`, MSB first; `$D136` = `80 40 20 10 08 04 02 01`):

```
D101  ASL A / ASL A / ASL A / STA $29
D106  BCC $D119                 ; carry = props bit5
D108  TYA / JSR $D124           ; test the $0540 bitmap for metatile Y
D10C  BEQ $D11F                 ; flag clear -> keep the original
D10E  LDY $2A / LDA ($18),Y     ; m = alt[m]
D112  TAY / LDA ($16),Y         ; props of the substitute
D115  ASL A / ASL A / ASL A / RTS

D124  PHA / LSR A / LSR A / LSR A / TAX
D129  LDA $0540,X / TAX / PLA / AND #$07 / TAY / TXA / AND $D136,Y
```

The renderer does the identical test at `$F0D8`.  `$E77E` fills the bitmap with
`$FF`, so **on entering a stage every bit-5 metatile shows its `alt` form**.
That is the state the decoder reproduces by default; `Stage.resolve(m, flags)`
accepts a live bitmap if you have one.

### 4.7 The complete decode

```python
def tile(C, R):                       # C,R = world tile column/row (8 px units)
    s = roommap[(R // 32) * 16 + (C // 32)]
    B = screens[s * 64 + ((R % 32) // 4) * 8 + ((C % 32) // 4)]
    m = blocks[B * 4 + ((C % 4) // 2) * 2 + ((R % 4) // 2)]
    if (props[m] & 0x20) and (flags[m >> 3] & (0x80 >> (m & 7))):
        m = alt[m]
    return quads[m * 4 + (C % 2) * 2 + (R % 2)]

palette   = props[m] >> 6      # per 16x16 metatile
collision = props[m] & 0x1F    # per 16x16 metatile
```

### 4.8 Table lengths

The six tables are packed contiguously, so the distance from a pointer to the
next-highest pointer of the same record gives the exact length.  This is
self-consistent: for stage 0, `props` (`$88FF`) → `alt` (`$899B`) = 156 bytes,
`alt` → `blocks` (`$8A37`) = 156 bytes, and `quads` (`$868F`) → `props` = 624 =
4 × 156.  The decoder uses this and falls back on the largest referenced index.

---

## 5. Nametable mapping and the column builder

The screen is written as `CIRAM[page][row][col]` with

```
col  = C & 31
row  = R mod 30                      ; $EC06 / $EBFC compute camera Y mod 240
page = nt_page((C >> 5) & 1)         ; vertical mirroring
```

Relevant code, all in bank 15:

| address | role |
|---|---|
| `$EC44` / `$EC2B` | detect an 8-px camera move, set the pending-column/row flags `$37`/`$36` |
| `$ED9A` / `$EDC5` | build one nametable **column** |
| `$EDF1` / `$EE00` / `$F0F1` | build one nametable **row** |
| `$EFA0` | room-map lookup (§4.1) |
| `$EFC7` | walk 8 blocks down a column |
| `$F031` | block → 4 tile numbers into `$0300,X` + 2 property bytes into `$0390,X` |
| `$F0D8` | alternate-state test |
| `$EE4F` / `$EEDE` / `$EF0D` / `$EF54` | pack 16×16 palettes into attribute bytes |
| `$EB47` / `$EB96` | PPU address computation |
| `$EBFC` / `$EC06` | camera Y → mod-240 (stage 0 takes the `$EBFC` special case) |
| `$FB00`-`$FBB0` | NMI flush driver |
| `$FD12` → `$FD70`-`$FE43` | unrolled VRAM copier |
| `$FE97` / `$FE44` | attribute upload |
| `$FF07` | extra upload queue |

The level owns the top **224 scanlines**; the bottom 16 are the status bar,
drawn with its own mid-frame scroll write into the two nametable rows the
30-row window has wrapped past.

---

## 6. CHR banks and palette

### CHR

Header bytes 11..16 are copied to `$40`-`$45`, which are the shadow copies of
MMC3 registers R0..R5, pushed to the mapper at `$FBA1`.  The background pattern
table is `$0000-$0FFF` (PPUCTRL bit 4 is clear during play), i.e.

* R0 (`$40`) = 2 K at `$0000-$07FF` → 1 K CHR banks `R0 & $FE` and `+1`
* R1 (`$41`) = 2 K at `$0800-$0FFF` → 1 K CHR banks `R1 & $FE` and `+1`

R2 (`$42`) and R5 (`$45`) are rewritten per sprite by `$F48C`, so their header
values only matter for the first frame.

**R1 is animated.**  A four-phase cycle driven by the global frame counter
`$0C`; the driver in PRG pair 8/9 is

```
AAAE  LDA $0C / LSR A / LSR A / AND #$03 / TAX
AAB5  LDA $AABB,X / STA $41
AABB  22 26 2A 2E                    ; this stage's four background banks
```

Different stages use their own copy of this table.  Measured across 60 captured
frames covering all 20 stages, the observed value at `$0800` is always
`header_R1 + {0, 4, 8, 12}` — i.e. four consecutive 2 K background banks
starting at the header value, cycling every 4 frames.

### Palette

Header bytes 9/10 point at 32 bytes **inside PRG pair 10/11** (measured: bank 10
offset `$8040` is byte-identical to the live PPU palette on stage 0).  Copied to
`$0390` at `$F81E` and to `$0790` at `$CC50`; uploaded at `$C69B`/`$C6A1`.
Verified equal to the live background palette in 58 of 60 captures; the two
exceptions are stage 12, where a script animates sub-palette 2 entries 1 and 2
away from their ROM values.

---

## 7. Object (enemy / item) placement

PRG pair 8/9, entry `$AE7C`:

```
AE81  LDA $55 / ASL A / ASL A / TAY
AE86  LDA $AFAD,Y -> $9A    ; ptrA: room id -> group id  ($FF = nothing here)
AE8B  LDA $AFAE,Y -> $9B
AE90  LDA $AFAF,Y -> $9C    ; ptrB: group table, 4 bytes per group
AE95  LDA $AFB0,Y -> $9D
AE9A  LDY $05EB             ; current room id (built at $93B5)
AE9D  LDA ($9A),Y / CMP #$FF / BEQ done
AEA3  ASL A / ASL A / TAY
AEA6  LDA ($9C),Y -> count       ; +0 = number of objects
AEAC  INY INY / LDA ($9C),Y -> list lo   ; +2,+3 = pointer to the record list
AEB7  LDY #$00                           ; 6-byte records follow
AEB9  LDA ($9A),Y -> $9C     ; +0  type | direction gate in bits 7,6
      LDA ($9A),Y -> $9D     ; +1  parameter
      LDA ($9A),Y -> $90     ; +2  X lo
      LDA ($9A),Y -> $91     ; +3  X hi
      LDA ($9A),Y -> $92     ; +4  Y lo
      LDA ($9A),Y -> $93     ; +5  Y hi
AED7  JSR $8059              ; proximity / quadrant test against the camera
AEDF  AND #$C0               ; direction gate
AEF7 / AF20  spawn: $0600,X = type, $A0/$B0/$C0/$D0,X = position
```

Positions are in the same 16-units-per-pixel world coordinates.

The 20 `$AFAD` entries (PRG pair 8/9):

| stage | room table | group table | stage | room table | group table |
|---|---|---|---|---|---|
| 0 | `$B1A8` | `$AFFD` | 10 | `$B3D8` | `$B5FC` |
| 1 | `$B451` | `$BD92` | 11 | `$B3D8` | `$B670` |
| 2 | `$B451` | `$BAFC` | 12 | `$B225` | `$AFFD` |
| 3 | `$B2E5` | `$BA36` | 13 | `$B225` | `$AFFD` |
| 4 | `$B12F` | `$B746` | 14 | `$B225` | `$AFFD` |
| 5 | `$B12F` | `$B10F` | 15 | `$B32F` | `$B94E` |
| 6 | `$B546` | `$BBDA` | 16 | `$B32F` | `$B94E` |
| 7 | `$B546` | `$BCC4` | 17 | `$B225` | `$AFFD` |
| 8 | `$B225` | `$AFFD` | 18 | `$B225` | `$AFFD` |
| 9 | `$B2E5` | `$BA94` | 19 | `$B225` | `$AFFD` |

Notes proved by inspection of the region:

* Sibling stages share a **room table** but have their own **group table** of a
  different length (3/9, 4/5, 6/7, 10/11, 1/2, 15/16).  A room whose group id
  exceeds this stage's group table therefore belongs to the sibling; the decoder
  marks such groups `out_of_range` instead of decoding neighbouring bytes.
* `$B225` is 192 bytes of `$FF` — stages 8, 12, 13, 14, 17, 18 and 19 have **no
  scripted spawns at all**; their bosses are created by the scroll script.
* A room table is bounded by the next pointer above it *and* by the room map's
  own length; without the second bound stage 6/7's table runs into the
  neighbouring stage's record lists.

The room table doubles as an excellent cross-check on the room map: for stage 0
the rooms it names (`$11`-`$15`, `$25`-`$28`, `$38`, `$47`-`$4C`, `$5B`, `$5C`,
`$6C`, `$7C`) are exactly the non-zero cells of the room map, reached in order.

---

## 8. Per-stage data

Room bounding box is the flood fill of the room map from the player start and
the object rooms (see `Stage.used_rooms`).

| st | header | PRG pair | tileset | quads | blocks | screens | roommap | props | alt | screens# | metatiles# | palette | CHR R0..R5 | music | rooms | room bbox | objects |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | `$E7D9` | 4/5 | `$00` | `$868F` | `$8A37` | `$81CF` | `$8152` | `$88FF` | `$899B` | 19 | 156 | `$8040` | 20 22 40 56 70 00 | 1 | 21 | 0,1..12,7 | 105 |
| 1 | `$E851` | 6/7 | `$18` | `$9D55` | `$A1BB` | `$9755` | `$961E` | `$A045` | `$A101` | 24 | 188 | `$8100` | 28 22 40 56 77 7B | 5 | 71 | 1,0..14,15 | 67 |
| 2 | `$E865` | 6/7 | `$24` | `$9EFD` | `$A3AF` | `$9755` | `$961E` | `$A0AF` | `$A169` | 30 | 108 | `$8100` | 28 22 40 56 70 7E | 5 | 72 | 1,0..14,15 | 32 |
| 3 | `$E8DD` | 6/7 | `$48` | `$B768` | `$B920` | `$B428` | `$B3DE` | `$BB18` | `$BB86` | 13 | 110 | `$81E0` | 30 32 40 56 77 71 | 5 | 21 | 0,0..9,4 | 46 |
| 4 | `$E829` | 6/7 | `$00` | `$8EFB` | `$930D` | `$87FB` | `$8782` | `$91B3` | `$9261` | 28 | 174 | `$80C0` | 2C 22 40 56 77 72 | 2 | 34 | 1,1..11,7 | 84 |
| 5 | `$E83D` | 6/7 | `$0C` | `$904B` | `$94D9` | `$87FB` | `$8782` | `$9207` | `$92B5` | 33 | 120 | `$80E0` | 2C 22 40 56 74 00 | 2 | 49 | 1,0..15,7 | 43 |
| 6 | `$E88D` | 6/7 | `$30` | `$ACBB` | `$AF8B` | `$A5BB` | `$A54F` | `$B287` | `$B33B` | 28 | 180 | `$8140` | 34 22 40 56 74 7F | 6 | 30 | 1,0..12,6 | 77 |
| 7 | `$E8A1` | 6/7 | `$3C` | `$ADDB` | `$B0C7` | `$A5BB` | `$A54F` | `$B2CF` | `$B383` | 32 | 242 | `$8160` | 34 22 40 56 77 7A | 6 | 30 | 1,0..12,6 | 87 |
| 8 | `$E8C9` | 4/5 | `$00` | `$868F` | `$8A37` | `$81CF` | `$8152` | `$88FF` | `$899B` | 19 | 156 | `$8060` | 20 22 40 56 75 60 | 7 | 3 | 12,1..14,1 | 0 |
| 9 | `$E8F1` | 6/7 | `$54` | `$B768` | `$B920` | `$B428` | `$B3DE` | `$BB18` | `$BB86` | 13 | 110 | `$8200` | 30 32 40 56 70 7C | 5 | 21 | 0,0..9,4 | 31 |
| 10 | `$E919` | 4/5 | `$0C` | `$905F` | `$92DF` | `$8D1F` | `$8CB7` | `$925F` | `$9577` | 13 | 128 | `$8220` | 24 32 40 56 77 73 | 3 | 30 | 0,0..11,6 | 28 |
| 11 | `$E92D` | 4/5 | `$18` | `$905F` | `$93D3` | `$8D1F` | `$8CB7` | `$925F` | `$9577` | 13 | 128 | `$8240` | 24 32 40 56 70 72 | 3 | 30 | 0,0..11,6 | 40 |
| 12 | `$E8B5` | 6/7 | `$3C` | `$ADDB` | `$B0C7` | `$A5BB` | `$A54F` | `$B2CF` | `$B383` | 32 | 242 | `$81C0` | 34 22 40 56 6B 60 | 7 | 2 | 10,6..11,6 | 0 |
| 13 | `$E879` | 6/7 | `$60` | `$9EFD` | `$A3AF` | `$9755` | `$966E` | `$A0AF` | `$A169` | 30 | 108 | `$8120` | 28 22 40 56 70 00 | 7 | 65 | 1,0..6,14 | 0 |
| 14 | `$E941` | 4/5 | `$18` | `$905F` | `$93D3` | `$8D1F` | `$8CB7` | `$925F` | `$9577` | 13 | 128 | `$8260` | 24 32 40 56 75 63 | 7 | 1 | 4,3..4,3 | 0 |
| 15 | `$E955` | 4/5 | `$30` | `$AF59` | `$B6C1` | `$A899` | `$A800` | `$B449` | `$B585` | 27 | 316 | `$83E0` | 38 32 40 56 77 73 | 4 | 34 | 1,1..12,9 | 188 |
| 16 | `$E969` | 4/5 | `$3C` | `$B271` | `$B9AD` | `$A899` | `$A800` | `$B50F` | `$B64B` | 39 | 241 | `$8420` | 3C 32 40 56 70 7A | 4 | 34 | 1,1..12,9 | 188 |
| 17 | `$E991` | 6/7 | `$0C` | `$904B` | `$94D9` | `$87FB` | `$8782` | `$9207` | `$92B5` | 33 | 120 | `$8460` | 2C 22 40 56 74 00 | 7 | 1 | 12,6..12,6 | 0 |
| 18 | `$E905` | 6/7 | `$54` | `$B768` | `$B920` | `$B428` | `$B3DE` | `$BB18` | `$BB86` | 13 | 110 | `$8440` | 30 32 40 56 70 00 | 7 | 9 | 1,4..9,4 | 0 |
| 19 | `$E97D` | 4/5 | `$30` | `$AF59` | `$B6C1` | `$A899` | `$A800` | `$B449` | `$B585` | 27 | 316 | `$84E0` | 38 32 40 56 70 60 | 7 | 1 | 2,2..2,2 | 0 |

Sharing between stages, read straight off the table:

* **Identical tileset record** (same six pointers, different palette / CHR /
  music / start position): 0 and 8; 3, 9 and 18; 7 and 12; 11 and 14; 5 and 17;
  15 and 19.  These are second visits to the same map.
* **Same `screens` + `roommap`, different `quads`/`props`/`alt`** — the same
  geometry redressed with a new tile set: 1 and 2; 4 and 5; 6 and 7; 15 and 16.
* **Same `screens`/`roommap`/`props`, different `blocks`**: 10 and 11.
* Stage 13 reuses stage 2's tile tables with its own room map (`$966E`).

There is exactly **one area per stage index**; the game has 20 of them and they
do not chain through any in-data "next area" field.  Progression between them is
driven by the stage index `$55` itself.

---

## 9. Proof

`work/tools/sol_levels.py --verify DUMP` compares the decoder against a
`nesemu -vram` dump: every visible 8×8 tile number against CIRAM, every visible
16×16 palette against the packed attribute bytes, the background palette, and
the CHR bank at `$0000`.

`work/tools/sol_levels.py --render DUMP PREFIX` goes further: it rebuilds the
visible part of CIRAM **purely from ROM level data**, hands both the real and
the rebuilt CIRAM to `work/tools/vram.py`'s scanline-accurate PPU renderer, and
counts differing sub-pixels over the 224 scanlines the level owns.

Captures (input script `/tmp/sol/long.inp`, one run per stage; `-poke` forces
the stage index just before `$E6C7` reads it):

```
nesemu "Tokkyuu Shirei Solbrain (Japan).nes" -input long.inp -frames 2700 \
    -poke 0055=<SS>@1703 \
    -vram <SS>_2050.bin@2050 -vram <SS>_2300.bin@2300 -vram <SS>_2600.bin@2600
```

Result over **all 20 stages × 3 frames = 60 captures, 39 distinct
(stage, camera) views**:

```
tiles compared      54612
tile mismatches         0
attribute mismatches    0
playfield sub-pixel differences (224 scanlines x 256 px x RGB)   0
```

Frame 1750 captures were also taken but are excluded: the poke lands at frame
1703 and at 1750 the engine has not yet pushed every column into VRAM, so CIRAM
still holds the previous screen in places.  From 2050 on it is fully settled.

Two comparison subtleties, both forced by how the PPU works rather than by the
format:

* a 33rd tile column exists only when the camera sits mid-tile; off-screen the
  engine leaves it stale, so it is excluded when `camera_x % 8 == 0`;
* only 224 of the 240 scanlines belong to the level (§5).

---

## 10. Decoder output

`work/tools/sol_levels.py ROM --outdir DIR` writes `stage_NN.json` for all 20
stages (6.4 MB total).  Each file contains:

* `area_header` — raw bytes and every decoded field
* `chr` — MMC3 R0/R1, the four 1 K background banks, and the animation note
* `palette` — the 32 ROM palette bytes
* `tileset` — the six table addresses and their derived lengths
* `room_grid` — the full 16×16 room map, the bounding box, the used rooms
* `screens`, `blocks`, `metatiles` — the raw tables, with each metatile's four
  tile numbers, palette index, collision class, alt id and decoded class names
* `objects` — room→group map and every group's 6-byte records in world and
  pixel coordinates
* `grids` — the assembled level over the room bounding box:
  * `tiles` — one hex byte per 8×8 tile
  * `metatiles` — one hex byte per 16×16 metatile
  * `palettes` — one hex nibble (0-3) per 16×16 metatile
  * `collision` — one hex byte (`props & $1F`) per 16×16 metatile

---

## 11. Explicitly unverified

* Area header bytes 17/18 (`$92/$93` = `$E9D2`).  Constant across all 20
  records; the value is overwritten before use by the collision code, so it may
  be dead.
* The meaning of collision-class bits 3..0 (bit 4 = solid and bit 2 = a second
  class are proved; the rest is not).
* The contents of the per-room scroll scripts that rewrite the camera bounds
  `$38`-`$3F`.  The mechanism is located (`$93E8 + stage*2` → `$9410` → `$9422`
  via `$957E,Y`) but not enumerated, so the header bounds in §8 describe only
  the initial scroll region.
* Object record byte +1 (`param`) and the meaning of the type byte's low 6 bits.
* The unused area records at `$E7ED`, `$E801`, `$E815` — proved unreferenced,
  but their intended stage is unknown.
