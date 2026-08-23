# Power Blade 2 — enemy / object placement and spawning

Everything below is decoded from `Power Blade 2 (USA).nes` (MMC3, 16 x 8 KB PRG
banks; 14/15 fixed at `$C000`/`$E000`).  Every claim is backed either by a
disassembly snippet reproduced here or by a trace taken with
`work/tools/nesemu`; anything that is a guess is labelled **(guess)**.

Companion documents: `pb2_level_format.md` (geometry), `pb2_area_records.md`
(per-area camera/CHR/palette record), `pb2_collision.md`, `pb2_weapons.md`.

---

## 0. One-paragraph summary

Enemies are **not** spawned by timers and **not** by a per-screen list.  Every
*area* owns one flat, position-sorted list of **4-byte records** stored in bank
pair 6/7.  A scan routine (`$E3F3`, bank 15) runs once per frame while the
camera is moving; it walks that list from the beginning, skips everything the
camera has already passed, and creates an object the moment a record's position
lands on the edge of the screen that the camera is currently uncovering.  The
record supplies the object **type**, its position **along** the scroll axis (in
16-pixel units) and **across** it (in pixels), plus a flags byte.  The type byte
is an index into a 90-entry jump table at `$8080` in bank 10.

---

## 1. Where the data is

### 1.1 Lookup chain

```
$E3B5 (bank 15)  — called once per area, from $CEB1 (bank 14, game state 4)

  LDY #$36 / JSR $ECA7          ; map bank pair 6/7 at $8000-$BFFF
  A = 6 if $79 != 0 else $53    ; $53 = stage 0..6, $79 != 0 = "boss stage" mode
  Y = A*2
  $0A/$0B = $E515,Y             ; 7 words in bank 15  -> a word in bank pair 6/7
  $08/$09 = ($0A)               ; the per-stage table of area lists
  Y = $9C*2                     ; $9C = area index
  $68/$69 = ($08),Y             ; ***the placement list for this area***
  $3B = 0 ; $0171 = 0           ; reset the per-area "already used" list
  JMP $DFB4                     ; recompute $A3 (camera column)
```

Disassembly (from `work/re/b15.asm`):

```
E3B5  A0 36    LDY #$36
E3B7  20 A7 EC JSR sub_ECA7            ; banks 6/7 -> $8000/$A000
E3BA  A9 06    LDA #$06
E3BC  A4 79    LDY $79
E3BE  D0 02    BNE loc_E3C2
E3C0  A5 53    LDA $53
E3C2  0A       ASL A
E3C3  A8       TAY
E3C4  B9 15 E5 LDA $E515,Y             ; per-stage pointer table, bank 15
E3C7  85 0A    STA $0A
E3C9  B9 16 E5 LDA $E516,Y
E3CC  85 0B    STA $0B
E3CE  A0 00    LDY #$00
E3D0  B1 0A    LDA ($0A),Y
E3D2  85 08    STA $08
E3D4  C8       INY
E3D5  B1 0A    LDA ($0A),Y
E3D7  85 09    STA $09
E3D9  A5 9C    LDA $9C                 ; area index
E3DB  0A       ASL A
E3DC  A8       TAY
E3DD  B1 08    LDA ($08),Y
E3DF  85 68    STA $68                 ; <- placement list pointer
E3E1  C8       INY
E3E2  B1 08    LDA ($08),Y
E3E4  85 69    STA $69
E3E6  A9 00    LDA #$00
E3E8  85 3B    STA $3B
E3EA  8D 71 01 STA $0171
E3ED  20 B4 DF JSR $DFB4
E3F0  4C C7 EC JMP sub_ECC7
```

### 1.2 The two levels of table

`$E515` (bank 15, 7 words):

```
E515:  03 80  05 80  07 80  09 80  0B 80  0D 80  0F 80
       ^st0   ^st1   ^st2   ^st3   ^st4   ^st5   ^st6
```

i.e. the seven per-stage tables are pointed at by `$8003`, `$8005` ... `$800F`
**in bank pair 6/7** — the slot immediately before the area-record pointers at
`$8011..$801D` (see `pb2_area_records.md`) and the collision pointers at
`$801F..$802B` (see `pb2_collision.md`).  Raw bytes, bank 6:

```
$8000: 4C 38 80 | 4C A1 | 95 A2 | E5 A3 | 56 A5 | F3 A6 | 71 A8 | F7 A9 |
                 \____________ $8003 .. $8010: enemy tables __________/
$8010: A9 44 AA B4 AA 34 AB A4 AB 14 AC B4 AC 94 AD 36      <- $8011: area records
```

(The `4C A1` at `$8003` is data, not a `JMP`; the byte-oriented listing in
`work/re/pair6.asm` mis-renders it as code.)

**Per-stage table of area lists** (bank pair 6/7):

| stage | table | areas | first list |
|-------|-------|-------|------------|
| 0 | `$A14C` | 7 | `$A15A` |
| 1 | `$A295` | 8 | `$A2A5` |
| 2 | `$A3E5` | 7 | `$A3F3` |
| 3 | `$A556` | 7 | `$A564` |
| 4 | `$A6F3` | 10 | `$A707` |
| 5 | `$A871` | 14 | `$A88D` |
| 6 | `$A9F7` | 11 | `$AA0D` |

The area counts are confirmed independently by `$D6CD` in bank 14, the table the
area-exit object compares `$9C` against:

```
sub_D6BC (bank 14, reached through the jump island $C894):
D6BC  A5 9C     LDA $9C
D6BE  85 17     STA $17
D6C0  A4 53     LDY $53
D6C2  B9 CD D6  LDA $D6CD,Y
D6C5  C5 17     CMP $17
D6C7  F0 02     BEQ $D6CB
D6C9  18        CLC           ; more areas left
D6CA  60        RTS
D6CB  38        SEC           ; that was the last area of the stage
D6CC  60        RTS
D6CD: 07 08 07 07 0A 0E 0C     ; areas per stage 0..6
```

Stages 0-5 agree exactly (7, 8, 7, 7, 10, 14).  Stage 6's byte says 12 while the
pointer table only holds 11 entries — stage 6 is the boss stage, which is
entered with `$79 = 1` and an explicitly assigned `$9C`, and never uses
`$D6BC`, so the 12 is dead.

The whole block is contiguous and self-terminating: `$A14C` (stage 0 pointer
table) through `$AA43` (last stage-6 record) is followed immediately by `$AA44`,
the stage-0 area-record table documented in `pb2_area_records.md`.  Each pointer
table's length is `(first list address - table address) / 2`, and each record
list ends at the first record whose byte 0 is `$FF`.

### 1.3 Record layout — 4 bytes

| off | meaning | destination |
|-----|---------|-------------|
| 0 | position **along the scroll axis**, in units of 16 px. `$FF` terminates the list. Records must be sorted ascending. | used only as the trigger key |
| 1 | **object type**, `$00..$59` | `$0400,X` |
| 2 | position **across the scroll axis**, in pixels (0-255) | `$0508,X` (X) if the area is vertical, `$04C6,X` (Y) if horizontal — see the swap at `$E4DB` |
| 3 | **flags / per-type parameter** | `$049A,X` |

For a **horizontally** scrolling area (`$97 = 0`) byte 0 is the X column and
byte 2 is the Y pixel; for a **vertically** scrolling area (`$97 = 1`) byte 0 is
the Y row and byte 2 is the X pixel.  `$97` comes from the area record
(`pb2_area_records.md`, offset 0).

Byte 3 is type-specific.  Two uses are proven:

* For **type `$02`** (the 16 permanent power-up capsules) the high nibble is a
  bit index 0-7 and bit 0 selects `$2B` (0) or `$2C` (1); that bit is the
  "already collected" flag.  See §4.
* Bit 7 is set on many walkers/flyers and is very likely the initial facing
  **(guess)** — not proven here.

---

## 2. What triggers a spawn

`$E3F3` (bank 15) is called once per frame from `$CF0E`, inside the main
gameplay state (`$1A = 5`, `loc_CED2` in bank 14):

```
CEFD  20 BE D2 JSR sub_D2BE
CF00  20 3A D2 JSR sub_D23A
CF03  A0 36    LDY #$36
CF05  20 A7 EC JSR $ECA7
CF08  20 2F 80 JSR $802F        ; bank pair 6/7 collision/interaction
CF0B  20 C7 EC JSR $ECC7
CF0E  20 F3 E3 JSR $E3F3        ; <<< the spawn scan
CF11  20 24 D9 JSR sub_D924     ; camera scroll ($94 recomputed here)
CF14  20 4D D3 JSR sub_D34D     ; shift every object by $94
CF17  A0 3A    LDY #$3A
CF19  20 A7 EC JSR $ECA7        ; banks 10/11
CF1C  20 00 80 JSR $8000        ; <<< object AI (see 5)
```

### 2.1 The two camera variables the scan uses

```
loc_DFB4 (bank 14) — run after every scroll step
DFB4  A5 67    LDA $67
DFB6  29 F0    AND #$F0
DFB8  20 06 CB JSR sub_CB06     ; >>4
DFBB  85 10    STA $10
DFBD  A5 66    LDA $66
DFBF  29 0F    AND #$0F
DFC1  20 01 CB JSR sub_CB01     ; <<4
DFC4  05 10    ORA $10
DFC6  85 A3    STA $A3          ; $A3 = ($66&15)*16 + $67/16
DFC8  60       RTS
```

`$A3` is the camera's leading 16-pixel column (or row), wrapping every 16
screens.  `$94` is the **signed pixel scroll of this frame**: `sub_D924`
zeroes it, then `sub_D99E` / `sub_D9F1` (horizontal) and `sub_DA52` /
`sub_DAAB` (vertical) `INC $94` / `DEC $94` once per scrolled pixel
(`$D9D8`, `$DA39`, `$DAEB`, `$DA95`).

### 2.2 The scan

```
loc_E3F3
E3F3  A5 97    LDA $97
E3F5  F0 2B    BEQ loc_E422           ; horizontal
      ; --- vertical: screens are 240 px tall, so convert
E3F7  A5 A3    LDA $A3 / AND #$F0 / (BEQ loc_E422) / LSR x4  -> $00   ; = $66
E403  A5 A3    LDA $A3 / SEC / SBC $00 -> $08                        ; = $66*15 + $67/16
E40A  A5 66    LDA $66 / ASL x4 -> $00
E412  A5 67    LDA $67 / SEC / SBC $00 -> $09                        ; 16-bit:
E419  A5 66    LDA $66 / SBC #$00     -> $0A                         ; $66*240 + $67
E41F  4C 2E E4 JMP loc_E42E
loc_E422 ; --- horizontal
E422  A5 66    LDA $66 / STA $0A      ; $0A:$09 = camera world position
E426  A5 67    LDA $67 / STA $09
E42A  A5 A3    LDA $A3 / STA $08      ; $08   = camera position / 16
loc_E42E
E42E  A0 36    LDY #$36
E430  20 A7 EC JSR sub_ECA7           ; banks 6/7 (that is where $68/$69 points)
E433  A5 94    LDA $94
E435  D0 07    BNE loc_E43E           ; camera moved this frame -> scan
E437  A5 8A    LDA $8A
E439  D0 03    BNE loc_E43E           ; or "area just loaded" -> scan
E43B  4C C7 EC JMP sub_ECC7           ; otherwise do nothing at all
loc_E43E
E43E  A2 00    LDX #$00
E440  A0 FC    LDY #$FC               ; Y = -4, X = 0
loc_E442
E442  C8 C8 C8 C8  INY x4             ; Y += 4  (record stride)
E446  E8       INX                    ; X = record index + 1
loc_E447
E447  B1 68    LDA ($68),Y            ; record byte 0
E449  C9 FF    CMP #$FF
E44B  F0 2A    BEQ loc_E477           ; end of list
E44D  C5 08    CMP $08
E44F  90 F1    BCC loc_E442           ; behind the camera edge -> next record
E451  A9 00    LDA #$00 / STA $00
E455  B1 68    LDA ($68),Y            ; byte 0 again
E457  C9 FF    CMP #$FF / BEQ loc_E477
E45B  0A 26 00 (ASL A / ROL $00) x4   ; $00:A = byte0 * 16
E467  38 E5 09 SEC / SBC $09 -> $01   ; $01  = low  (byte0*16 - camera)
E46C  A5 00    LDA $00 / SBC $0A      ;        high
E470  F0 0C    BEQ loc_E47E           ; high == 0 -> within 0..255 of the camera
E472  10 03    BPL loc_E477           ; high  > 0 -> past the screen, stop scanning
E474  4C 05 E5 JMP loc_E505           ; high  < 0 -> behind, skip this record
loc_E477
E477  A9 00    LDA #$00
E479  85 8A    STA $8A                ; clear the "populate everything" flag
E47B  4C C7 EC JMP sub_ECC7
loc_E47E
E47E  A5 94    LDA $94
E480  30 08    BMI loc_E48A
E482  A5 01    LDA $01 / CMP #$F8
E486  B0 0F    BCS loc_E497           ; scrolling forward: spawn at screen X/Y >= $F8
E488  90 06    BCC loc_E490
loc_E48A
E48A  A5 01    LDA $01 / CMP #$08
E48E  90 07    BCC loc_E497           ; scrolling backward: spawn at screen X/Y < $08
loc_E490
E490  A5 8A    LDA $8A
E492  D0 03    BNE loc_E497           ; area just loaded -> spawn anywhere on screen
E494  4C 05 E5 JMP loc_E505           ; else not yet
```

So the trigger is a **camera-edge crossing**, evaluated every frame in which the
camera moved (`$94 != 0`), plus one "fill the visible screen" pass at area load
time (`$8A`, set to 1 at `$CEAF` just before `$E3B5` and cleared by the first
scan that reaches the end of the list or a record past the screen).

`$01` — the record's position minus the camera position — becomes the new
object's screen-relative coordinate; objects are stored in screen coordinates
and re-based every frame by `sub_D34D` (`$04C6,X -= $94`, `$0508,X -= $94`).

### 2.3 Duplicate suppression

```
loc_E497
E497  86 02    STX $02                ; $02 = record index + 1  (1-based, never 0)
E499  A2 0E    LDX #$0E
E49B  A9 80    LDA #$80 / STA $00     ; $00 = $80 = "no free slot found yet"
loc_E49F
E49F  BD 00 04 LDA $0400,X
E4A2  D0 03    BNE loc_E4A7
E4A4  4C 0D E5 JMP loc_E50D           ; free slot -> remember it in $00 (see below)
loc_E4A7
E4A7  BD 84 04 LDA $0484,X
E4AA  C5 02    CMP $02
E4AC  D0 03    BNE loc_E4B1
E4AE  4C 03 E5 JMP loc_E503           ; this record is already live -> skip
loc_E4B1
E4B1  E8       INX / CPX #$16 / BNE loc_E49F
E4B6  A6 00    LDX $00
E4B8  10 03    BPL loc_E4BD           ; found a free slot
E4BA  4C 03 E5 JMP loc_E503           ; all of $0E..$15 busy -> silently drop
loc_E50D
E50D  86 00    STX $00
E50F  4C B1 E4 JMP loc_E4B1
```

`loc_E50D` stores `X` into `$00` **unconditionally** and then carries on with
the loop, so `$00` ends up holding the **last** free slot, not the first.  Seen
on the cartridge: in area 0:2 the only record on screen at load time
(`along = 6`, type `$29`) is put into slot `$15`, the highest of the eight, and
not into `$0E`.

Placed objects therefore live **only in slots `$0E`..`$15`** (8 slots), and
they fill from the top down.  Slot 0
is the player, `$06..$0D` is the pool `$CB1B` hands out to shots and to
dynamically spawned children, and `$CB0B` hands out `$0E..$15` to whatever else
needs it.  `$0484,X` holds the 1-based record index and is what stops a record
from spawning twice while its object is alive.  It is cleared by `sub_D6D4`, so
an object that is killed or culled **will** respawn if the camera uncovers its
column again.

---

## 3. The record -> object translation

```
loc_E4BD
E4BD  20 23 E5 JSR sub_E523          ; persistent-item gate  (type $02 only)
E4C0  B0 41    BCS loc_E503
E4C2  20 59 E5 JSR sub_E559          ; once-per-area gate    (types $24/$3A/$3E/$40)
E4C5  B0 3C    BCS loc_E503
E4C7  20 D4 D6 JSR $D6D4             ; zero all 29 fields of slot X
E4CA  C8       INY
E4CB  B1 68    LDA ($68),Y
E4CD  9D 00 04 STA $0400,X           ; byte 1 -> type
E4D0  C8       INY
E4D1  B1 68    LDA ($68),Y
E4D3  85 03    STA $03               ; byte 2
E4D5  C8       INY
E4D6  B1 68    LDA ($68),Y
E4D8  9D 9A 04 STA $049A,X           ; byte 3 -> flags
E4DB  A5 97    LDA $97
E4DD  D0 0C    BNE loc_E4EB          ; vertical area: no swap
E4DF  A5 03    LDA $03 / STA $04     ; horizontal area: exchange $01 and $03
E4E3  A5 01    LDA $01 / STA $03
E4E7  A5 04    LDA $04 / STA $01
loc_E4EB
E4EB  A5 03    LDA $03
E4ED  9D 08 05 STA $0508,X           ; X position, low byte
E4F0  A5 01    LDA $01
E4F2  9D C6 04 STA $04C6,X           ; Y position, low byte
E4F5  A9 08    LDA #$08
E4F7  9D 16 04 STA $0416,X           ; object flag byte, always $08 here
E4FA  A5 02    LDA $02
E4FC  9D 84 04 STA $0484,X           ; record index + 1
E4FF  AA       TAX                   ; restore X = record index + 1
E500  4C 08 E5 JMP loc_E508          ; continue the scan
```

### 3.1 The minimal field set (answer to question 4)

`sub_D6D4` (bank 14) writes `#$00` to all 29 per-slot fields
(`$0400,X`, `$0416,X`, `$042C,X`, `$0442,X`, `$0458,X`, `$046E,X`, `$0484,X`,
`$049A,X`, `$04B0,X`, `$04C6,X`, `$04DC,X`, `$04F2,X`, `$0508,X`, `$051E,X`,
`$0534,X`, `$054A,X`, `$0560,X`, `$0576,X`, `$058C,X`, `$05A2,X`, `$05B8,X`,
`$05CE,X`, `$05E4,X`, `$05FA,X`, `$0610,X`, `$0626,X`, `$063C,X`, `$0652,X`,
`$0668,X`), and for `X >= 6` also calls `$FEE0`.  After that the spawner sets
exactly **six** bytes:

| field | value | why |
|-------|-------|-----|
| `$0400,X` | record byte 1 | object type; non-zero = slot alive, and the AI dispatch index |
| `$0508,X` | screen X (low) | `$04F2,X` (high) stays 0 from the clear |
| `$04C6,X` | screen Y (low) | `$04B0,X` (high) stays 0 |
| `$0416,X` | `$08` | object flag byte read by the bank-7 interaction code (`$B296`, `$B2A6`, `$B325`, `$B330`, `$B33D`, `$B349`, `$B374`, `$B391`, `$B3A9`, `$B617`, `$B66C`) and by `$D781`; individual bit meanings **not decoded** |
| `$049A,X` | record byte 3 | flags / per-type parameter |
| `$0484,X` | record index + 1 | anti-duplicate key |

Notably `$0442,X` (the sprite/metasprite id, i.e. "slot is drawn") and
`$058C,X` (the per-object state-machine index) are left at 0.  The object is
invisible until its own handler runs and calls the animation setter
`$E2D5` (jump island `$C83A`), which fills `$0458,X`, `$05A2,X` and `$0442,X`
from the animation table at `($802D)` in bank pair 6/7 — see `pb2_weapons.md` §
"Per-frame tile-id stepper".

---

## 4. The two spawn gates

### 4.1 `sub_E523` — the 16 permanent collectables (`type $02`)

```
E523  84 26    STY $26
E525  C8       INY
E526  B1 68    LDA ($68),Y            ; record byte 1 = type
E528  C9 02    CMP #$02
E52A  D0 29    BNE loc_E555           ; not type $02 -> CLC, allow
E52C  C8 C8    INY / INY              ; Y -> byte 3
E52E  B1 68    LDA ($68),Y
E530  4A 4A 4A 4A / 29 0F  -> $24     ; $24 = high nibble = bit index
E538  B1 68    LDA ($68),Y
E53A  4A       LSR A
E53B  B0 0B    BCS loc_E548           ; bit 0 of the flags picks the byte
E53D  A4 24    LDY $24 / LDA $E5B1,Y / AND $2B / BEQ allow / BNE deny
E548  A4 24    LDY $24 / LDA $E5B1,Y / AND $2C / BEQ allow / (deny)
E5B1: 01 02 04 08 10 20 40 80
```

`$2B`/`$2C` are 16 persistent "already collected" bits.  They are copied to and
from `$06A1`/`$06A3` by the continue/save code in bank 0 (`$9D21`, `$9D26`,
`$9D48`, `$9D4D`), so they survive a death.  `sub_E580` (bank 15, reached
through the jump island `$C8A3`) is the setter: it EORs the same bit using
`$049A,X`.

There are exactly **16** type-`$02` records in the whole ROM, and they use each
of the 16 bits exactly once:

| stage | area | record | bit | byte |
|---|---|---|---|---|
| 0 | 2 | `29 02 40 03` | 0 | `$2C` |
| 0 | 3 | `1A 02 50 02` | 0 | `$2B` |
| 0 | 4 | `4D 02 50 12` | 1 | `$2B` |
| 1 | 1 | `06 02 D0 13` | 1 | `$2C` |
| 1 | 2 | `12 02 50 23` | 2 | `$2C` |
| 1 | 4 | `1C 02 70 22` | 2 | `$2B` |
| 2 | 0 | `0E 02 30 33` | 3 | `$2C` |
| 2 | 3 | `09 02 E0 43` | 4 | `$2C` |
| 2 | 3 | `2C 02 20 32` | 3 | `$2B` |
| 3 | 3 | `26 02 30 42` | 4 | `$2B` |
| 3 | 3 | `32 02 D0 53` | 5 | `$2C` |
| 3 | 5 | `0E 02 30 52` | 5 | `$2B` |
| 4 | 5 | `1C 02 30 63` | 6 | `$2C` |
| 4 | 6 | `26 02 30 62` | 6 | `$2B` |
| 5 | 8 | `02 02 30 73` | 7 | `$2C` |
| 5 | 9 | `0E 02 30 72` | 7 | `$2B` |

**Engine limit worth knowing:** `$E5B1` is only 8 bytes long, so a flags high
nibble of 8-15 on a type-`$02` record would read past it into the code at
`$E5B9`.  No shipped record does this.

### 4.2 `sub_E559` — "only once per area" objects

```
E559  84 26    STY $26
E55B  C8       INY
E55C  B1 68    LDA ($68),Y            ; type
E55E  C9 24    CMP #$24 / BEQ loc_E56E
E562  C9 3E    CMP #$3E / BEQ loc_E56E
E566  C9 40    CMP #$40 / BEQ loc_E56E
E56A  C9 3A    CMP #$3A / BNE loc_E555   ; any other type -> allow
loc_E56E
E56E  AC 71 01 LDY $0171              ; number of entries in the list
E571  F0 E2    BEQ loc_E555           ; empty -> allow
E573  88       DEY
E574  B9 72 01 LDA $0172,Y
E577  C5 02    CMP $02                ; this record's index?
E579  F0 D6    BEQ loc_E551           ; yes -> deny
E57B  88       DEY / BPL loc_E574
E57E  30 D5    BMI loc_E555
```

The list is filled by the mirror-image routine in bank 7:

```
B746  A0 00    LDY #$00
B748  BD 00 04 LDA $0400,X
B74C  D9 64 B7 CMP $B764,Y
B74F  F0 06    BEQ $B757
B751  C8       INY / CPY #$04 / BNE $B749
B756  60       RTS
B757  AC 71 01 LDY $0171
B75A  BD 84 04 LDA $0484,X            ; the record index
B75D  99 72 01 STA $0172,Y
B760  EE 71 01 INC $0171
B763  60       RTS
B764: 24 3E 40 3A
```

`$0171`/`$0172..` are reset by `$E3B5` on every area load, so these four types
("collect me once per visit" — energy/ammo pickups **(guess)**) do not come back
until the area is re-entered.

---

## 5. Turning the type byte into behaviour

`$CF1C` maps bank pair 10/11 and calls `$8000`:

```
bank 10
8000  4C 03 80 JMP $8003
8003  A5 27    LDA $27 / CMP #$05 / BCS $8042 (RTS)
8009  20 18 BF JSR $BF18
800C  ...      $011F = 0, $0166 = 0, $0167 = 0, INC $0119
801A  A2 06    LDX #$06                 ; slots 6..$15
801C  BD 00 04 LDA $0400,X
801F  F0 1C    BEQ $803D                ; empty slot
8021  20 34 81 JSR $8134                ; per-type off-screen / cull check
8024  B0 4F    BCS $8075                ; carry -> JSR $C810 ( = $D6D4, free slot )
8026  BD B8 05 LDA $05B8,X              ; freeze/stun timer
8029  D0 18    BNE $8043
802B  A5 2A    LDA $2A / BEQ $803A      ; $2A != 0 = global "only types 3/4 run"
802F  BD 00 04 LDA $0400,X / CMP #$03 / BEQ $803A / CMP #$04 / BNE $803D
803A  20 7A 80 JSR $807A
803D  E8       INX / CPX #$16 / BNE $801C
8042  60       RTS

sub_807A  ; <<< THE TYPE DISPATCH
807A  BD 00 04 LDA $0400,X
807D  20 4F C8 JSR $C84F               ; = JMP sub_CA0B, "jump table follows the JSR"
8080  .... 180 bytes = 90 words ....
```

`$C84F` is the fixed-bank island `JMP sub_CA0B`; `sub_CA0B` (bank 14) is the
standard "word table inlined after the `JSR`" dispatcher:

```
CA0B  0A       ASL A
CA0C  84 03    STY $03
CA0E  A8       TAY / INY
CA10  68       PLA / STA $00           ; return address = table base - 1
CA13  68       PLA / STA $01
CA16  B1 00    LDA ($00),Y / STA $02
CA1A  C8       INY
CA1B  B1 00    LDA ($00),Y
CA1D  A4 03    LDY $03 / STA $03
CA21  6C 02 00 JMP ($0002)
```

**Table address: `$8080` in bank 10.  Size: 180 bytes = 90 entries.  Valid type
values: `$00`..`$59`.**  The size is confirmed by the parallel per-type class
table at `$8212`, which is exactly 90 bytes long and butts up against type
`$01`'s handler at `$826C`:

```
$8212 (90 bytes, one class 0..7 per type; index into the 8 handlers
       $815A $8162 $816A $8148 $8172 $817E $8186 $818E via $814A/$8152)
$00: 00 03 00 00 00 00 00 02 01 00 03 00 00 00 00 03
$10: 02 00 00 00 04 00 04 01 04 07 00 00 04 00 00 06
$20: 00 04 00 05 00 00 00 05 05 07 04 03 00 00 00 00
$30: 06 06 06 06 03 03 03 02 00 00 00 06 00 00 00 04
$40: 00 03 03 03 00 03 03 03 04 03 03 04 04 03 00 03
$50: 03 03 03 03 03 03 03 03 03 03
```

### 5.1 The dispatch table

| type | handler | bank | culling class | placed in stages | role |
|---|---|---|---|---|---|
| `$00` | `$8042` | 10 | 0 | - (0) | RTS stub (unused) |
| `$01` | `$826C` | 10 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$02` | `$83EA` | 10 | 0 | 0,1,2,3,4,5 (16) | persistent power-up capsule (the 16 collectables; gated by $2B/$2C) |
| `$03` | `$840A` | 10 | 0 | 0,1,2,3 (4) | stage-end / boss door  ($79=1, $9C=$53+6) |
| `$04` | `$8542` | 10 | 0 | 0,1,2,3,4,5 (52) | area exit  (INC $9C, game state 6) |
| `$05` | `$8728` | 10 | 0 | 6 (6) | stage-6 area object, first six areas (INC $9C chain, boss/lift) |
| `$06` | `$87B2` | 10 | 0 | 6 (5) | stage-6 area object, last five areas (INC $9C chain, boss/lift) |
| `$07` | `$9FDE` | 10 | 2 | 0,1,2,3,5 (8) | enemy / hazard — behaviour not individually identified |
| `$08` | `$9FB8` | 10 | 1 | 3,4,5 (6) | enemy / hazard — behaviour not individually identified |
| `$09` | `$A061` | 11 | 0 | 1,5 (3) | enemy / hazard — behaviour not individually identified |
| `$0A` | `$A09D` | 11 | 3 | 0,1,2,4 (4) | enemy / hazard — behaviour not individually identified |
| `$0B` | `$A50B` | 11 | 0 | 2,3 (23) | enemy / hazard — behaviour not individually identified |
| `$0C` | `$8A5D` | 10 | 0 | 0,1,3,4,5 (23) | enemy / hazard — behaviour not individually identified |
| `$0D` | `$8B4F` | 10 | 0 | 5 (1) | enemy / hazard — behaviour not individually identified |
| `$0E` | `$8B86` | 10 | 0 | 4 (1) | enemy / hazard — behaviour not individually identified |
| `$0F` | `$A309` | 11 | 3 | 4,5 (19) | enemy / hazard — behaviour not individually identified |
| `$10` | `$9E2F` | 10 | 2 | 0,1,2,3 (12) | enemy / hazard — behaviour not individually identified |
| `$11` | `$8BED` | 10 | 0 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$12` | `$8BED` | 10 | 0 | 0,5 (12) | enemy / hazard — behaviour not individually identified |
| `$13` | `$96AA` | 10 | 0 | 0,1,2,3,4 (31) | enemy / hazard — behaviour not individually identified |
| `$14` | `$8BD8` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$15` | `$9EF1` | 10 | 0 | 1,3 (5) | enemy / hazard — behaviour not individually identified |
| `$16` | `$9C68` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$17` | `$9DA5` | 10 | 1 | 0,1,2,3,4,5 (37) | enemy / hazard — behaviour not individually identified |
| `$18` | `$9D79` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$19` | `$9D1F` | 10 | 7 | 1,4 (8) | enemy / hazard — behaviour not individually identified |
| `$1A` | `$9C7D` | 10 | 0 | 0,1,4 (11) | enemy / hazard — behaviour not individually identified |
| `$1B` | `$8DE4` | 10 | 0 | 1,2 (5) | enemy / hazard — behaviour not individually identified |
| `$1C` | `$8E29` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$1D` | `$8E9D` | 10 | 0 | 0,1,3,4,5 (16) | enemy / hazard — behaviour not individually identified |
| `$1E` | `$A650` | 11 | 0 | 0,1,4 (8) | enemy / hazard — behaviour not individually identified |
| `$1F` | `$A71F` | 11 | 6 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$20` | `$8F96` | 10 | 0 | 5 (4) | enemy / hazard — behaviour not individually identified |
| `$21` | `$908E` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$22` | `$910D` | 10 | 0 | 0,1,2 (13) | enemy / hazard — behaviour not individually identified |
| `$23` | `$91A2` | 10 | 5 | 0,2,3,4 (22) | enemy / hazard — behaviour not individually identified |
| `$24` | `$92E7` | 10 | 0 | 2,3,5 (8) | "once per area" object (registered in $0172 when destroyed) |
| `$25` | `$932E` | 10 | 0 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$26` | `$9383` | 10 | 0 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$27` | `$9780` | 10 | 5 | 2,3,5 (8) | enemy / hazard — behaviour not individually identified |
| `$28` | `$977D` | 10 | 5 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$29` | `$A7AD` | 11 | 7 | 0,1,3,4,5 (12) | enemy / hazard — behaviour not individually identified |
| `$2A` | `$A893` | 11 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$2B` | `$A8B4` | 11 | 3 | 5 (3) | enemy / hazard — behaviour not individually identified |
| `$2C` | `$A95C` | 11 | 0 | 0,1,2,3,4 (43) | enemy / hazard — behaviour not individually identified |
| `$2D` | `$A95C` | 11 | 0 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$2E` | `$A95C` | 11 | 0 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$2F` | `$93A8` | 10 | 0 | 0,2,3,5 (9) | enemy / hazard — behaviour not individually identified |
| `$30` | `$940D` | 10 | 6 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$31` | `$9473` | 10 | 6 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$32` | `$9524` | 10 | 6 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$33` | `$95FB` | 10 | 6 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$34` | `$AD7A` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$35` | `$AD64` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$36` | `$AE8D` | 11 | 3 | 5 (8) | enemy / hazard — behaviour not individually identified |
| `$37` | `$B00E` | 11 | 2 | 5 (12) | enemy / hazard — behaviour not individually identified |
| `$38` | `$B0C0` | 11 | 0 | 0,2,4,5 (12) | enemy / hazard — behaviour not individually identified |
| `$39` | `$B697` | 11 | 0 | 1,2,3,5 (7) | enemy / hazard — behaviour not individually identified |
| `$3A` | `$B1EC` | 11 | 0 | 2,3,4,5 (7) | "once per area" object (registered in $0172 when destroyed) |
| `$3B` | `$B40D` | 11 | 6 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$3C` | `$B500` | 11 | 0 | 0,1,2,3,4,5 (10) | enemy / hazard — behaviour not individually identified |
| `$3D` | `$B652` | 11 | 0 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$3E` | `$BACB` | 11 | 0 | 2,3,4,5 (7) | "once per area" object (registered in $0172 when destroyed) |
| `$3F` | `$B49F` | 11 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$40` | `$B7AD` | 11 | 0 | 2,3,4,5 (6) | "once per area" object (registered in $0172 when destroyed) |
| `$41` | `$B9A4` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$42` | `$8C3A` | 10 | 3 | 1,3,4,5 (19) | enemy / hazard — behaviour not individually identified |
| `$43` | `$B989` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$44` | `$BC89` | 11 | 0 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$45` | `$8C3A` | 10 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$46` | `$AC0D` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$47` | `$A312` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$48` | `$9A6F` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$49` | `$AB45` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$4A` | `$AB45` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$4B` | `$9B6A` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$4C` | `$9B8D` | 10 | 4 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$4D` | `$AC2D` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$4E` | `$8042` | 10 | 0 | - (0) | RTS stub (unused) |
| `$4F` | `$9AB2` | 10 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$50` | `$BDE9` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$51` | `$BDE9` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$52` | `$BDE9` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$53` | `$BDE9` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$54` | `$BDE9` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$55` | `$BDE9` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$56` | `$BDBD` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$57` | `$BDBD` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$58` | `$BDBD` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |
| `$59` | `$BDBD` | 11 | 3 | - (0) | never placed by the level data; spawned dynamically or unused |

Notes on the tail of the table: types `$50`..`$55` all point at `$BDE9` and
`$56`..`$59` at `$BDBD`, which is the filler byte `BD` repeated — those four
entries look like padding.  None of `$4E`..`$59` is ever placed by level data.

### 5.2 The area-transition objects (answer to question 3, last part)

**`type $04` = "go to the next area".**  It is the object that ends an area.
Its handler is a small state machine (`JSR $C97E` -> `$FD10` -> `LDA $058C,X /
JMP $CA0B`, i.e. dispatch on the per-object state `$058C,X`, with the state
table inlined at `$8545`: `$8551 $8449 $85FD $864A $86D2 $86E7`).  The last
state is the transition itself:

```
bank 10
86E7  DE 26 06 DEC $0626,X          ; short delay
86EA  D0 21    BNE $870D
86EC  A9 06    LDA #$06
86EE  85 1A    STA $1A              ; game state 6 = "load the next area"
86F0  E6 9C    INC $9C              ; <<< next area index
86F2  20 94 C8 JSR $C894            ; = JMP sub_D6BC: was that the last area?
86F5  90 13    BCC $870A
86F7  A9 01    LDA #$01 / STA $79   ; yes -> switch to the boss stage
86FB  A9 02    LDA #$02 / STA $AD
86FF  A0 00    LDY #$00
8701  A5 53    LDA $53 / CMP #$05 / BEQ $8708
8707  A8       TAY
8708  84 9C    STY $9C              ; boss-stage area = $53 (0 when $53 = 5)
870A  4C 10 C8 JMP $C810            ; = JMP sub_D6D4, free this slot
870D  60       RTS
```

There are **52** type-`$04` records across stages 0-5, which between them have
53 areas — essentially one exit per area.

**`type $03` = "go to the boss / end of stage"** (4 records, stages 0-3):

```
84F1  A5 CC    LDA $CC / BEQ $84F6 / RTS
84F6  A9 06    LDA #$06 / STA $1A
84FC  A9 01    LDA #$01 / STA $79    ; boss-stage mode
8500  A5 53    LDA $53 / CLC / ADC #$06
8505  85 9C    STA $9C               ; boss-stage area = stage + 6
8507  4C 10 C8 JMP $C810
```

With `$79 != 0` every per-stage lookup (`$E3B5`, `$E23F`, `$DDE1`, `$E11C`)
substitutes stage index 6, so the "boss stage" is stage 6.  Its placement lists
are trivially one record each:

```
$AA0D areas 0-5:  08 05 80 01 FF     ; type $05 at 8*16 = 128, across = $80
$AA2B areas 6-10: 08 06 80 01 FF     ; type $06
```

`type $05` and `type $06` are the two stage-6 objects and both also drive `$9C`
(`$8708 STY $9C`, `$891D INC $9C`, `$8505 STA $9C`) — they are the boss-room /
lift sequencing objects **(guess: `$06` = boss capsule sequence, `$05` = the
mid-stage lift)**.

---

## 6. Worked example: stage 0

Raw dump, decoded with the rules above.  `pb2_area_records.md` gives the axis
per area (offset 0 of the area record at `$AA52`, `$AA60`, ...): areas 0, 2, 4, 6
are horizontal, areas 1, 3, 5 are vertical.

```
$A14C: 5A A1 83 A1 9C A1 C9 A1 F6 A1 27 A2 58 A2   -> $A15A, $A183, $A19C, $A1C9, $A1F6, $A227, $A258

area 0  list $A15A  10 records  horizontal (byte0=X/16, byte2=Y)
  raw: 01 04 80 00 04 17 90 80 09 2C 50 00 0C 22 A0 40 10 22 A0 40 12 12 30 00 15 12 30 00 1B 12 30 00 1C 17 90 00 1E 12 30 00 FF
   #  bytes        along-axis px   type   across px   flags
   0  01 04 80 00      16          $04      128       $00
   1  04 17 90 80      64          $17      144       $80
   2  09 2C 50 00     144          $2C       80       $00
   3  0C 22 A0 40     192          $22      160       $40
   4  10 22 A0 40     256          $22      160       $40
   5  12 12 30 00     288          $12       48       $00
   6  15 12 30 00     336          $12       48       $00
   7  1B 12 30 00     432          $12       48       $00
   8  1C 17 90 00     448          $17      144       $00
   9  1E 12 30 00     480          $12       48       $00

area 1  list $A183  6 records  vertical (byte0=Y/16, byte2=X)
  raw: 04 13 70 00 07 04 F0 00 08 2C E0 00 0C 2C 40 00 0E 13 90 80 10 13 70 00 FF
   #  bytes        along-axis px   type   across px   flags
   0  04 13 70 00      64          $13      112       $00
   1  07 04 F0 00     112          $04      240       $00
   2  08 2C E0 00     128          $2C      224       $00
   3  0C 2C 40 00     192          $2C       64       $00
   4  0E 13 90 80     224          $13      144       $80
   5  10 13 70 00     256          $13      112       $00

area 2  list $A19C  11 records  horizontal (byte0=X/16, byte2=Y)
  raw: 06 29 20 00 13 29 20 00 19 1E 40 80 20 29 20 00 29 02 40 03 2B 07 B0 01 34 23 90 00 38 23 90 01 3F 1D 70 00 4A 13 40 01 4F 04 80 00 FF
   #  bytes        along-axis px   type   across px   flags
   0  06 29 20 00      96          $29       32       $00
   1  13 29 20 00     304          $29       32       $00
   2  19 1E 40 80     400          $1E       64       $80
   3  20 29 20 00     512          $29       32       $00
   4  29 02 40 03     656          $02       64       $03
   5  2B 07 B0 01     688          $07      176       $01
   6  34 23 90 00     832          $23      144       $00
   7  38 23 90 01     896          $23      144       $01
   8  3F 1D 70 00    1008          $1D      112       $00
   9  4A 13 40 01    1184          $13       64       $01
  10  4F 04 80 00    1264          $04      128       $00

area 3  list $A1C9  11 records  vertical (byte0=Y/16, byte2=X)
  raw: 02 2F 90 00 06 2C 50 00 07 04 10 00 0A 0C 80 00 0B 2C 30 00 13 0C 70 01 1A 02 50 02 1A 2C 90 00 1D 2C 70 00 1E 2F 30 01 20 2C 90 00 FF
   #  bytes        along-axis px   type   across px   flags
   0  02 2F 90 00      32          $2F      144       $00
   1  06 2C 50 00      96          $2C       80       $00
   2  07 04 10 00     112          $04       16       $00
   3  0A 0C 80 00     160          $0C      128       $00
   4  0B 2C 30 00     176          $2C       48       $00
   5  13 0C 70 01     304          $0C      112       $01
   6  1A 02 50 02     416          $02       80       $02
   7  1A 2C 90 00     416          $2C      144       $00
   8  1D 2C 70 00     464          $2C      112       $00
   9  1E 2F 30 01     480          $2F       48       $01
  10  20 2C 90 00     512          $2C      144       $00

area 4  list $A1F6  12 records  horizontal (byte0=X/16, byte2=Y)
  raw: 01 04 80 01 03 2C 90 00 07 2C 70 00 0B 2C 50 00 11 22 A0 40 13 22 A0 40 18 03 80 00 1D 22 A0 40 29 13 90 01 36 13 60 00 49 0A 94 00 4D 02 50 12 FF
   #  bytes        along-axis px   type   across px   flags
   0  01 04 80 01      16          $04      128       $01
   1  03 2C 90 00      48          $2C      144       $00
   2  07 2C 70 00     112          $2C      112       $00
   3  0B 2C 50 00     176          $2C       80       $00
   4  11 22 A0 40     272          $22      160       $40
   5  13 22 A0 40     304          $22      160       $40
   6  18 03 80 00     384          $03      128       $00
   7  1D 22 A0 40     464          $22      160       $40
   8  29 13 90 01     656          $13      144       $01
   9  36 13 60 00     864          $13       96       $00
  10  49 0A 94 00    1168          $0A      148       $00
  11  4D 02 50 12    1232          $02       80       $12

area 5  list $A227  12 records  vertical (byte0=Y/16, byte2=X)
  raw: 07 04 F0 00 0A 0C 30 00 10 38 80 00 10 0C D0 01 18 1E 18 81 1E 38 B0 00 24 38 80 00 2C 1E E8 81 30 1E E8 80 32 1A E0 82 34 1A 20 00 36 1A E0 82 FF
   #  bytes        along-axis px   type   across px   flags
   0  07 04 F0 00     112          $04      240       $00
   1  0A 0C 30 00     160          $0C       48       $00
   2  10 38 80 00     256          $38      128       $00
   3  10 0C D0 01     256          $0C      208       $01
   4  18 1E 18 81     384          $1E       24       $81
   5  1E 38 B0 00     480          $38      176       $00
   6  24 38 80 00     576          $38      128       $00
   7  2C 1E E8 81     704          $1E      232       $81
   8  30 1E E8 80     768          $1E      232       $80
   9  32 1A E0 82     800          $1A      224       $82
  10  34 1A 20 00     832          $1A       32       $00
  11  36 1A E0 82     864          $1A      224       $82

area 6  list $A258  15 records  horizontal (byte0=X/16, byte2=Y)
  raw: 13 12 60 00 17 12 60 00 1B 12 60 00 1F 12 60 00 21 10 6D 07 23 12 60 00 28 3C A0 00 2F 10 6D 03 38 23 30 80 3C 23 30 80 40 23 30 81 41 13 90 81 44 23 30 81 48 23 30 80 4F 04 80 00 FF
   #  bytes        along-axis px   type   across px   flags
   0  13 12 60 00     304          $12       96       $00
   1  17 12 60 00     368          $12       96       $00
   2  1B 12 60 00     432          $12       96       $00
   3  1F 12 60 00     496          $12       96       $00
   4  21 10 6D 07     528          $10      109       $07
   5  23 12 60 00     560          $12       96       $00
   6  28 3C A0 00     640          $3C      160       $00
   7  2F 10 6D 03     752          $10      109       $03
   8  38 23 30 80     896          $23       48       $80
   9  3C 23 30 80     960          $23       48       $80
  10  40 23 30 81    1024          $23       48       $81
  11  41 13 90 81    1040          $13      144       $81
  12  44 23 30 81    1088          $23       48       $81
  13  48 23 30 80    1152          $23       48       $80
  14  4F 04 80 00    1264          $04      128       $00
```

### 6.1 Runtime cross-check

Reproduce with:

```
printf '1 -\n300 START\n308 -\n700 START\n708 -\n1000 START\n1008 -\n1150 LEFT\n' > L.inp
# plus a LEFT,A pulse every 45 frames from 1300 on, to clear the first ledge:
work/tools/nesemu "Power Blade 2 (USA).nes" -input LJ.inp -frames 4000 \
     -trace t.txt -tracefrom 3999 -traceto 4000 -tracepc FFFE-FFFF -watch 0400-0415
```

Stage 0 area 0 is horizontal and starts with the camera at `$66:$67 = 2:$00`
(world X 512) with limit `$59 = 2`, i.e. the camera can only move **left**, down
to 0.  So the list is consumed back-to-front.  `-watch 0400-0415` gives every
write to the object-type table; the writes from `$E4D0` (`STA $0400,X` at
`$E4CD`) are the spawns:

```
WATCH 1295,E4D0,15,0415,12       slot $15  type $12   record 9  (pos $1E)
WATCH 1332,E4D0,15,0414,17       slot $14  type $17   record 8  (pos $1C)
WATCH 1348,E4D0,15,0413,12       slot $13  type $12   record 7  (pos $1B)
WATCH 1446,E4D0,15,0415,12       slot $15  type $12   record 6  (pos $15)
WATCH 1512,E4D0,15,0413,12       slot $13  type $12   record 5  (pos $12)
WATCH 1544,E4D0,15,0412,22       slot $12  type $22   record 4  (pos $10)
WATCH 1609,E4D0,15,0415,22       slot $15  type $22   record 3  (pos $0C)
WATCH 1717,E4D0,15,0413,2C       slot $13  type $2C   record 2  (pos $09)
```

The order and the types are exactly the stage-0 area-0 list read backwards.
(`$F8B0`/`$F8F3` writes to `$0406..$0409` in the same log are the player's
shots, which come from `$CB1B`, not from this table.)

Four of them traced instruction-by-instruction
(`-tracepc E422-E502`, one frame each) — the `A=` column is the value the
*previous* instruction produced:

**Frame 1332 — record 8 `1C 17 90 00`**

```
F1332 15:E424 85 0A  STA $0A     A=01      ; camera high = $01
F1332 15:E428 85 09  STA $09     A=C0      ; camera low  = $C0  -> world 448
F1332 15:E42C 85 08  STA $08     A=1C      ; camera column = $1C
F1332 15:E4CB B1 68  LDA ($68),Y  Y=21     ; -> byte 1
F1332 15:E4CD 9D 00 04 STA $0400,X A=17 X=14 ; type  $17   == record byte 1
F1332 15:E4D1 B1 68  LDA ($68),Y  A=17 Y=22 ; -> byte 2
F1332 15:E4D6 B1 68  LDA ($68),Y  A=90 Y=23 ; byte 2 = $90
F1332 15:E4D8 9D 9A 04 STA $049A,X A=00     ; flags $00   == record byte 3
F1332 15:E4ED 9D 08 05 STA $0508,X A=00     ; X = 28*16 - 448 = 0
F1332 15:E4F2 9D C6 04 STA $04C6,X A=90     ; Y = $90     == record byte 2
F1332 15:E4FC 9D 84 04 STA $0484,X A=09     ; record index + 1 = 9
```

**Frame 1544 — record 4 `10 22 A0 40`**

```
F1544 15:E424 85 0A  STA $0A     A=01
F1544 15:E428 85 09  STA $09     A=00      ; camera = $0100 = 256
F1544 15:E42C 85 08  STA $08     A=10      ; column $10
F1544 15:E4CD 9D 00 04 STA $0400,X A=22 X=12 ; type $22
F1544 15:E4D6 B1 68  LDA ($68),Y  A=A0     ; byte 2 = $A0
F1544 15:E4D8 9D 9A 04 STA $049A,X A=40     ; flags $40
F1544 15:E4ED 9D 08 05 STA $0508,X A=00     ; X = 16*16 - 256 = 0
F1544 15:E4F2 9D C6 04 STA $04C6,X A=A0     ; Y = $A0
F1544 15:E4FC 9D 84 04 STA $0484,X A=05     ; record index + 1 = 5
```

**Frame 1609 — record 3 `0C 22 A0 40`**

```
F1609 15:E428 85 09  STA $09     A=C0      ; camera = $00C0 = 192
F1609 15:E42C 85 08  STA $08     A=0C
F1609 15:E4CD 9D 00 04 STA $0400,X A=22 X=15 ; type $22
F1609 15:E4D8 9D 9A 04 STA $049A,X A=40     ; flags $40
F1609 15:E4ED 9D 08 05 STA $0508,X A=00     ; X = 12*16 - 192 = 0
F1609 15:E4F2 9D C6 04 STA $04C6,X A=A0     ; Y = $A0
F1609 15:E4FC 9D 84 04 STA $0484,X A=04
```

**Frame 1717 — record 2 `09 2C 50 00`**

```
F1717 15:E428 85 09  STA $09     A=90      ; camera = $0090 = 144
F1717 15:E42C 85 08  STA $08     A=09
F1717 15:E4CD 9D 00 04 STA $0400,X A=2C X=13 ; type $2C
F1717 15:E4D8 9D 9A 04 STA $049A,X A=00     ; flags $00
F1717 15:E4ED 9D 08 05 STA $0508,X A=00     ; X = 9*16 - 144 = 0
F1717 15:E4F2 9D C6 04 STA $04C6,X A=50     ; Y = $50
F1717 15:E4FC 9D 84 04 STA $0484,X A=03
```

All four match the decoded bytes exactly (type, Y, flags, and screen X = the
record column minus the camera).

### 6.2 The "not yet / behind" branches, also observed

At frame 1290 the camera was at world 485 (`$0A:$09 = $01:$E5`, `$08 = $1E`) and
the same record 9 was rejected because it lies *behind* the camera edge:

```
F1290 15:E447 B1 68    LDA ($68),Y   -> 01     ; record 0, skipped ( < $08 )
      ...                             04 09 0C 10 12 15 1B 1C
F1290 15:E44F 90 F1    BCC $E442     A=1E      ; record 9: $1E >= $08, evaluate
F1290 15:E465 26 00    ROL $00       A=E0      ; byte0*16 = $01E0 = 480
F1290 15:E468 E5 09    SBC $09       -> $01 = $FB
F1290 15:E46E E5 0A    SBC $0A       A=FF      ; high byte negative
F1290 15:E474 4C 05 E5 JMP $E505               ; -> skip, next record
F1290 15:E447 B1 68    LDA ($68),Y   A=FF      ; terminator
F1290 15:E479 85 8A    STA $8A       A=00      ; end of scan
```

Five frames later, with the camera at 480, the same record produced the spawn
logged above at frame 1295 (`$01 = 0`, `$94 = $FF` so the `< $08` branch at
`$E48A` was taken).

Also confirms the list contents read through `($68),Y` at runtime: `01 04 09 0C
10 12 15 1B 1C 1E FF` — byte-for-byte the stage-0 area-0 record byte 0s decoded
from ROM at `$A15A`.

---

## 7. Global type census

Types actually used by the placement data (42 of the 90):

| type | records | stages |
|---|---|---|
| `$02` | 16 | 0,1,2,3,4,5 |
| `$03` | 4 | 0,1,2,3 |
| `$04` | 52 | 0,1,2,3,4,5 |
| `$05` | 6 | 6 |
| `$06` | 5 | 6 |
| `$07` | 8 | 0,1,2,3,5 |
| `$08` | 6 | 3,4,5 |
| `$09` | 3 | 1,5 |
| `$0A` | 4 | 0,1,2,4 |
| `$0B` | 23 | 2,3 |
| `$0C` | 23 | 0,1,3,4,5 |
| `$0D` | 1 | 5 |
| `$0E` | 1 | 4 |
| `$0F` | 19 | 4,5 |
| `$10` | 12 | 0,1,2,3 |
| `$12` | 12 | 0,5 |
| `$13` | 31 | 0,1,2,3,4 |
| `$15` | 5 | 1,3 |
| `$17` | 37 | 0,1,2,3,4,5 |
| `$19` | 8 | 1,4 |
| `$1A` | 11 | 0,1,4 |
| `$1B` | 5 | 1,2 |
| `$1D` | 16 | 0,1,3,4,5 |
| `$1E` | 8 | 0,1,4 |
| `$20` | 4 | 5 |
| `$22` | 13 | 0,1,2 |
| `$23` | 22 | 0,2,3,4 |
| `$24` | 8 | 2,3,5 |
| `$27` | 8 | 2,3,5 |
| `$29` | 12 | 0,1,3,4,5 |
| `$2B` | 3 | 5 |
| `$2C` | 43 | 0,1,2,3,4 |
| `$2F` | 9 | 0,2,3,5 |
| `$36` | 8 | 5 |
| `$37` | 12 | 5 |
| `$38` | 12 | 0,2,4,5 |
| `$39` | 7 | 1,2,3,5 |
| `$3A` | 7 | 2,3,4,5 |
| `$3C` | 10 | 0,1,2,3,4,5 |
| `$3E` | 7 | 2,3,4,5 |
| `$40` | 6 | 2,3,4,5 |
| `$42` | 19 | 1,3,4,5 |

---

## 8. What I could NOT determine

* **What most of the 90 object types actually are.**  I proved the roles of
  `$02` (permanent collectable), `$03` (stage-end/boss door), `$04` (area exit),
  `$05`/`$06` (the stage-6 sequencing objects) and the "once per area" set
  `$24 / $3A / $3E / $40`.  The other 33 placed types are enemies/hazards whose
  individual behaviour I did not reverse — I only have their handler address,
  their culling class and where they occur.  I deliberately did not guess names
  such as "walker" or "flyer": nothing in this investigation supports such
  labels.
* **The bit meanings of `$0416,X`** (initialised to `$08` by the spawner).  It is
  clearly a flags byte — bank 7 masks it with `#$50`, `#$88`, `#$40`, `#$10`,
  `#$02`, `#$20`, `#$DA` and compares it to `#$80` and `#$02` — but I did not
  decode which bit is which.
* **The meaning of record byte 3 for types other than `$02`.**  `$80` is the most
  common non-zero value and my guess is "start facing left", but that is a guess:
  `$049A,X` is also read by the generic freeze check at `$806B` (`CMP #$20`) and
  is overwritten by some handlers at runtime (in my stage-0 run a type-`$22`
  object spawned with `$049A = $40` and held `$01` a few hundred frames later).
* **The exact `$058C,X` state machines** of the transition objects: I traced the
  final state of the type-`$04` machine (`$86E7`) but not the earlier ones
  (`$8551`, `$8449`, `$85FD`, `$864A`, `$86D2`), so I cannot say what makes the
  exit "arm" (a touch? a switch? `$0626,X` is a countdown, `$05E4,X` is compared
  against `#$08` at `$86D5`).
* **The area-count discrepancy with `pb2_level_format.md`.**  That document lists
  14 areas for stage 2 and 30 for stage 5; the enemy tables, the area-record
  tables and `$D6CD` all agree on 7 and 14.  I did not chase down which of the
  two is measuring what — most likely the geometry doc's self-terminating
  heuristic overshoots for those two stages.
* **`$3B`**, zeroed next to `$0171` by `$E3B5`.  It is written elsewhere only by
  `$8AA0`/`$8B81` in bank 10 (`EOR $3B / STA $3B` against a table at `$BE36`) and
  by `$DFE4`; I did not work out what it tracks.
* **Two-player behaviour.**  Everything above was traced with one player; I did
  not check whether the second player's camera affects the scan.
* **Whether `$94` can exceed one 16-pixel column in a frame.**  It is a per-pixel
  counter, so at high scroll speeds a record could in principle be stepped over
  without ever landing in the `< $08` / `>= $F8` window.  I did not construct a
  case that demonstrates or rules this out.

---

## 9. Как это проверено (Э3.2a)

`work/extract/verify_spawns.py` гоняет картридж и движок по одному сценарию и
сверяет две вещи на каждом шаге игры: где стоит вид (`$66:$67`) и что за этот
шаг родилось — номер места в таблице, тип, номер записи и координаты на экране.

Сверять спавн короткими прогонами бесполезно: список уровня разворачивается
только по мере того, как вид едет вперёд, а герой в случайном сценарии гибнет
или упирается в стену через десяток шагов.  Поэтому к случайным сценариям
добавлен один длинный «протяг» на участок: герой перестаёт ходить, его просто
прикалывают к дальнему краю экрана (`-freeze`), вид гонится за ним и проезжает
участок целиком, а на середине прогона колышек переносят к ближнему краю — и
вид едет обратно.  Смерть на это время выключается правкой самого картриджа
(`-rompoke`, см. `IMMORTAL` в `work/tools/pb2_probe.py`).

Три вещи, которые всплыли по дороге и стоят того, чтобы их знать:

* **Вниз по уровню героя нельзя прикалывать к самому низу.**  На `$04C6 = $E0`
  игра решает, что он ушёл с картинки: `$D0BB` видит `$4E` и выходит, не доехав
  до вида вообще.  `$C0` — предел, при котором участок ещё живёт.
* **По кадрам нельзя угадать, что видел `$D3B8`.**  Шаг игры может занять два
  кадра, и работа шага приходится то на первый из них, то на второй — как ляжет
  граница кадра.  Поэтому положение героя, по которому решается судьба вида,
  снимается прямо с чтения: `nesemu -sample D3CA=0508` и `-sample D3D2=04C6`
  пишут, что лежало по адресу в тот миг, когда до него дошло исполнение
  (`see_x`/`see_y` в `work/tools/pb2_trace.py`).
* **Список уровня — не единственный, кто занимает места в таблице.**  Обработчик
  может выставить свой снаряд или кусок себя, и тогда скану места не хватает
  (`$E4B6`: `$00` остался `$80` — свободного нет, запись молча пропадает).  У
  движка обработчиков пока нет, поэтому ему такие места просто называют — так
  же, как называют смерти.  Это долг Э3.2, а не свойство скана.

Результат прогона записан в `docs/status_ver3.md`.

---

## 10. Как объект пропадает сам: сдвиг и отсев ($D34D, $8134)

Появление — половина дела: пока вид едет, список кладёт вещи на край экрана
без конца, а мест всего восемь.  Освобождает их отсев (терм. «culling») —
проверка «не ушло ли это слишком далеко за край», которую игра делает **каждый
шаг для каждого занятого места, до того как вещь получит ход**.

### 10.1 Место вещи на экране и его сдвиг

Место хранится двумя байтами на ось: старший — на сколько экранов вещь ушла в
сторону (`$04F2,X` вдоль, `$04B0,X` поперёк), младший — где она внутри экрана
(`$0508,X` и `$04C6,X`).  При рождении `$D6D4` обнуляет всю запись, поэтому
старший байт новорождённой вещи — ноль.

`$D34D` (bank 14, вызывается из `$CF14`, то есть **после** того как вид поехал)
отнимает у всех — у героя, место 0, и у мест 6..$15 — сдвиг вида `$94` по той
оси, по которой уровень едет.  Знак разносится по старшему байту через `$00`:

```
D34D  LDY #$00 / LDA $94 / BPL $D354 / DEY      ; $00 = $FF если $94 < 0
D354  STY $00
D356  LDA $97 / BEQ $D389                       ; $97 != 0 -- уровень вниз
D35A  ; вертикально: $04C6 -= $94, $04B0 -= $00 (с заёмом), затем то же
D36B  ; для X = 6..$15, но только там, где $0400,X != 0
D389  ; горизонтально: то же самое с $0508 / $04F2
```

Поперёк экрана вещь не двигают вовсе — уровень едет только по одной оси.

### 10.2 Отсев: `$8134`

```
8134  LDY $0400,X          ; тип
8137  LDA $8212,Y          ; класс отсева, 0..7
813A  TAY
813B  LDA $814A,Y / STA $00
8140  LDA $8152,Y / STA $01
8145  JMP ($0000)
```

`$814A` = `5A 62 6A 48 72 7E 86 8E`, `$8152` = восемь раз `81`, то есть восемь
обработчиков класса:

Проверок две, и это **не** «вдоль уровня» и «поперёк»: как бы уровень ни
шёл, одна читает пару байт места вбок по экрану (`$04F2`/`$0508`), другая —
пару байт места вниз по экрану (`$04B0`/`$04C6`).

| класс | обработчик | вбок | вниз |
|---|---|---|---|
| 0 | `$815A` | `$81A2` запас 64 | `$81BD` низ сразу, верх 32 |
| 1 | `$8162` | `$819E` запас 128 | `$81BD` |
| 2 | `$816A` | `$81A2` запас 64 | `$81D4` запас 64 |
| 3 | `$8148` | `CLC / RTS` — не отсеивается никогда | — |
| 4 | `$8172` | отсев, если старший байт **любой** пары не ноль | |
| 5 | `$817E` | `$81A2` запас 64 | `$81D0` запас 128 |
| 6 | `$8186` | `$819A` запас 32 | `$81EF` низ по $D0, верх 32 |
| 7 | `$818E` | `$8196` запас 16 | `$81CC` запас 16 |

Ответ передаётся флагом переноса: перенос стоит — место освобождают
(`$8024 BCS $8075` → `JSR $C810` = `$D6D4`).  Общий выход `$8206` — это
`SEC / PLA / PLA / RTS`: он снимает адрес возврата вложенной проверки и
возвращается сразу наружу, минуя вторую половину обработчика класса.

Проверка вбок (`$81A4`, входы `$81A2`/`$819E`/`$819A`/`$8196` задают Y =
0/2/4/6):

```
A = $04F2,X
если A == 0            -> на экране, оставить
если A отрицателен     -> слева: отсев, если $0508,X <  $820A+Y
иначе                  -> справа: отсев, если $0508,X >= $820B+Y
```

`$820A` = `C0 40 | 80 80 | E0 20 | F0 10` — пары «сколько ещё терпеть слева» и
«справа»: 64, 128, 32 и 16 точек соответственно.

Проверка вниз того же вида (`$81D6`, входы `$81D4`/`$81D0`/`$81CC`) читает
`$04B0,X` и `$04C6,X` и берёт из той же таблицы Y = 0/2/6.

Два особых случая:

```
81BD  A = $04B0,X
      == 0            -> оставить
      > 0             -> отсев сразу (ушло вниз)
      < 0             -> отсев, если $04C6,X < $E0 (вверх терпят 32 точки)

81EF  A = $04B0,X
      == 0            -> отсев, если $04C6,X >= $D0
      > 0             -> отсев
      < 0             -> отсев, если $04C6,X < $E0
```

### 10.3 Таблица классов `$8212` (90 байт, тип -> класс)

```
$00: 00 03 00 00 00 00 00 02 01 00 03 00 00 00 00 03
$10: 02 00 00 00 04 00 04 01 04 07 00 00 04 00 00 06
$20: 00 04 00 05 00 00 00 05 05 07 04 03 00 00 00 00
$30: 06 06 06 06 03 03 03 02 00 00 00 06 00 00 00 04
$40: 00 03 03 03 00 03 03 03 04 03 03 04 04 03 00 03
$50: 03 03 03 03 03 03 03 03 03 03
```

### 10.4 Что ещё стоит между отсевом и ходом

```
801C  LDA $0400,X / BEQ next          ; пусто
8021  JSR $8134 / BCS $8075           ; отсев -> $D6D4
8026  LDA $05B8,X / BNE $8043         ; оглушено -- ход пропускают
802B  LDA $2A / BEQ ход               ; $2A != 0 -- ходят только типы 3 и 4
803A  JSR $807A                       ; ход по таблице $8080
```

### 10.5 Три мелочи, найденные при переносе

**`-frames N` у `work/tools/nesemu` доводит счёт до кадра N включительно.**
Снимок памяти, взятый с `-frames N+1`, — это состояние на кадр позже, чем
нужно. Из-за этого таблица вещей, которую приёмка отдавала движку как
начальную, была на один шаг вперёд, и отсев срабатывал на шаг раньше
картриджа. Видно это стало только тогда, когда начали сверять отсев: рождения
одинаково сдвигались у обоих и потому сходились.

**Вещи двигают себя сами.** Место `$0508,X` меняет не только `$D34D`: у
объекта типа `$1E`, например, есть свой код в bank 15 (`$FA8B`), который
переписывает это место. Пока у движка нет умов для вещей, он не может знать,
где они стоят, — поэтому приёмка Э3.2b **сообщает** ему таблицу мест такой,
какой её видел `$8134`, и сверяет только ответ отсева. Заодно считается, у
скольких вещей движок и сам угадал место: это те, что стоят на месте и
двигаются только вместе с видом, то есть проверка `$D34D`.

**`$D34D` переключает банк на середине.** Сдвиг идёт сверху вниз по местам, и
где-то посреди списка `$D370` вызывает переключатель банков — а вызов кладёт
адрес возврата на стек. Приёмка снимала таблицу с первой же записи, которая
пришла не из восьми известных `STA` сдвига, и потому останавливалась на этом
вызове: половина мест попадала в снимок ещё не сдвинутой, на кадр назад.
Разошлось это в единственном месте на все 125 прогонов — область 1:6, шаг
1470, место `$14`: `$04C6` было `$E0` в снимке и `$DF` на деле, а `$81BD`
режет ровно по `$E0`. Снимок теперь берут после **последней** записи сдвига в
кадре, а не после первой чужой.

## 11. Два запрета: что не появляется дважды

Между «место нашлось» (`$E4B6`) и `$D6D4`, который его чистит, стоят два
вопроса. Оба отвечают переносом: взведён — запись пропускают, место остаётся
свободным, обход идёт дальше (`$E4C0`/`$E4C5` -> `$E503`).

### 11.1 Собранное навсегда — `$E523`

Только тип `$02`.

```
$24 := (третий байт записи >> 4) AND $0F
если (третий байт AND 1) = 0:  слово := $2B
иначе:                          слово := $2C
если слово AND $E5B1[$24] -> запрет
```

`$E5B1` = `01 02 04 08 10 20 40 80`. Шестнадцать бит на две ячейки — ровно
шестнадцать вещей, которые в игре берут один раз за всю игру.

Ставит бит `$E580` (переходник `$C8A3`): он читает `$049A,X` уже
родившейся вещи, разбирает тот же нибл и **переключает** (EOR) бит.

### 11.2 Один раз за посещение — `$E559`

Типы `$24`, `$3E`, `$40`, `$3A`.

```
для Y = $0171-1 вниз до 0:
    если $0172,Y = номер записи -> запрет
```

`$0171` — сколько записей в списке, `$0172` — сам список. Список обнуляют
при открытии области (`$E3EA STA $0171`).

Дописывает в него банк 7, `$B747`:

```
$B747: Y := 0
$B749: если $0400,X = $B764[Y] -> $B757
       Y := Y + 1; пока Y < 4 -> $B749
       выйти
$B757: $0172[$0171] := $0484,X;  $0171 := $0171 + 1
```

`$B764` = `24 3E 40 3A` — те же четыре типа. Зовут это из `$B6E3`, то есть
**в тот миг, когда вещь убили**: убитая дверь, лифт или рычаг больше не
появляется, пока герой не выйдет из области.

### 11.3 Что это в движке

Два поля у таблицы вещей: `got` (шестнадцать бит) и `done` (список номеров
записей). Спрашивают их в `_place`, сразу после того, как место нашлось.
Пока у движка нет умов, оба ему **называют** по шагам: он ничего не
подбирает и никого не убивает, так что сам изменить их не может.
