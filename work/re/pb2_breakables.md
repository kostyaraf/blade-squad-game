# Power Blade 2 — destructible background blocks

Everything below is decoded from `Power Blade 2 (USA).nes` (MMC3, 16 x 8 KB PRG
banks; 14/15 fixed at `$C000`/`$E000`) and proved at runtime with
`work/tools/nesemu`. Companion documents: `pb2_level_format.md`,
`pb2_collision.md`, `pb2_spawns.md`, `pb2_area_records.md`, `pb2_weapons.md`.

Anything I could not determine is labelled **UNRESOLVED**.

---

## 0. The answer

**Yes.** Power Blade 2 has a complete, shipped destructible-background-block
mechanism, and it is exactly the architecture the question calls "option (b)":
the block is ordinary **background** in the level's block/screen data, and when
it is destroyed a small piece of code patches **both** the collision class cache
and the nametable, while a per-area RAM bitmask plus a per-level tile-remap
table make the change survive scrolling.

The five moving parts:

| part | where | role |
|---|---|---|
| **object type `$0C`** | dispatch word at `$8098` -> `$8A5D`, bank 10 | invisible one-hit hitbox sitting on the block |
| **`$B688` / `$B6F1`** | bank 7 | any weapon hit on a type-`$0C` defender -> state 2, no HP |
| **`$8AF0`** | bank 10 | the destruction: open the collision cell + blank 4 tiles |
| **`$3B`** | zero page, 8 bits, per area | "this block is already broken" |
| **`$BA42`** | bank 13, reached through `$DF85` | redraw hook: while the bit is set, the scroll refill substitutes tile `$00` for the block's tile **before** both the PPU write and the collision classification |

There is **no** RAM overlay consulted by `sub_DCBF` itself. `$DCBF` still only
sees a tile number. The overlay lives one level up, in `$BA42`, which rewrites
the tile number that `$DCBF` is then handed.

**Nametable upload queue: `$0300`, write index `$1F`, flushed in NMI by
`$CC41` (called from `$E9F9`, NMI vector `$E9C7`).**
**Attribute shadow RAM: there is none.** Attribute bytes are streamed straight
from ROM into the same `$0300` queue by `$DC73`/`$DCA5`; nothing keeps a RAM
copy, and the destruction code never touches attributes (proved by CIRAM diff in
§5 — only tile bytes changed).

---

## 1. The PPU upload queue (`$0300` / `$1F`)

### Writers

```
$CD0B  A6 1F     LDX $1F          ; the only push primitive
$CD0D  9D 00 03  STA $0300,X
$CD10  E8        INX
$CD11  86 1F     STX $1F
$CD13  60        RTS
$CD09  A9 FF     LDA #$FF / BNE $CD0B     ; push $FF
$CD14  A9 00     LDA #$00 / BEQ $CD0B     ; push $00
$CD18  A9 01     LDA #$01 / BNE $CD0B     ; push $01
$CD1C  A9 02     LDA #$02 / BNE $CD0B     ; push $02
$CD20  A9 03 ... $CD24  A9 04 ...
```

Reached from switchable banks through the fixed island:

| trampoline | target | meaning |
|---|---|---|
| `$C840` | `$CD18` | push command byte `$01` |
| `$C843` | `$CD1C` | push command byte `$02` |
| `$C846` | `$CD09` | push `$FF` (stream terminator) |
| `$C849` | `$CD0B` | push A |

There is **no bound check** on `$1F`. The buffer is `$0300..$03FF` (the object
array starts at `$0400`), so 256 bytes per frame is the hard ceiling.

### Reader — `$CC41`, called from the NMI at `$E9F9`

```
CC41  A9 00     LDA #$00
CC43  20 0B CD  JSR $CD0B        ; append a 0 terminator
CC46  A8        TAY              ; Y = 0
CC47  BE 00 03  LDX $0300,Y      ; X = command byte
CC4A  F0 24     BEQ $CC70        ; 0 = end of queue
CC4C  A5 FF     LDA $FF / AND #$18 / ORA $CC3C,X / STA $2000
CC56  C8        INY
CC57  AD 02 20  LDA $2002
CC5A  B9 01 03  LDA $0301,Y      ; PPU addr HIGH  (stream byte 2)
CC5D  8D 06 20  STA $2006
CC60  B9 00 03  LDA $0300,Y      ; PPU addr LOW   (stream byte 1)
CC63  8D 06 20  STA $2006
CC66  C8 C8     INY / INY
CC68  E0 03     CPX #$03 / BEQ $CC93 / BCC $CC82 / BCS $CCA3
```

**Record format:** `[cmd] [addr lo] [addr hi] [payload...]`, records back to back,
a `$00` command byte ends the queue.

| cmd | `$CC3C,X` -> `$2000` bits | payload |
|---|---|---|
| `$01` | `$00` (+1 increment) | bytes until `$FF`; an `$FF` followed by a byte >= 5 means "write a literal `$FF` and keep going" (`$CC8A`) |
| `$02` | `$04` (+32 increment) | same, column-wise |
| `$03` | `$00` | `[count][byte]` — RLE fill (`$CC93`) |
| `$04` | `$00` | `[count][b0..b{n-1}]` — counted literal block (`$CCA3`) |

`$CC70` resets `$0300 = 0` and `$1F = 0` and restores `$2000` from the shadow
`$FF`.

### Attributes

`$DC73` is the attribute row fill and it uses command `$04`:

```
DC73  A9 04     LDA #$04 / JSR $CD0B         ; cmd 4
DC78  A5 73     LDA $73 / ASL A / AND #$38   -> $08
DC7F  29 BF     AND #$BF / CLC / ADC #$C0 / JSR $CD0B   ; addr lo
DC87  A9 23     LDA #$23 / JSR $CD0B                    ; addr hi ($23C0)
DC8C  A9 08     LDA #$08 / JSR $CD0B                    ; count 8
DC91  A5 08     LDA $08 / TAY / LDA ($70),Y   ; screen -> block index
DC97  A8        TAY / LDA ($75),Y             ; block -> attribute byte
DC99  20 0B CD  JSR $CD0B
```

`($75)` is the per-block attribute table straight out of ROM. **No RAM copy of
the attribute tables exists anywhere in the engine** — I looked for one both by
following `$DC73`/`$DCA5` and by a ROM-wide scan for a second producer of `$23C0`
addresses, and there is none.

---

## 2. Type `$0C` — the breakable block object

### 2.1 It is placed like any other object

4-byte placement record (`pb2_spawns.md` §1.3), object type `$0C`:

| off | meaning for a `$0C` |
|---|---|
| 0 | position along the scroll axis, 16-px units |
| 1 | `$0C` |
| 2 | position across the scroll axis, pixels |
| 3 | **`$3B` bit index, 0-7** (see §2.4) |

All shipped `$0C` records (decoded with `work/tools/pb2_spawns.py`):

```
stage 0 area  3: 0A 0C 80 00   13 0C 70 01          (vertical area)
stage 0 area  5: 0A 0C 30 00   10 0C D0 01          (vertical area)
stage 1 area  4: 03 0C 50 00                        (vertical)
stage 1 area  5: 27 0C 50 00   28 0C 50 01          (horizontal)
stage 1 area  6: 0E 0C D0 00   14 0C 20 01          (vertical)
stage 3 area  0: 0E 0C 80 00   0F 0C 80 01
                 1E 0C 80 02   1F 0C 80 03          (horizontal)
stage 3 area  6: 26 0C 40 00   27 0C 40 01
                 28 0C 40 02   29 0C 40 03          (horizontal)
stage 4 area  7: 04 0C 30 00                        (vertical)
stage 5: two more groups (see §6, table decode overflowed pb2_spawns.py)
```

Runs of consecutive positions (`$0E,$0F,$1E,$1F` / `$26..$29`) are how the game
builds a wall wider than 16 px: **one record = one 16x16 px cell.**

### 2.2 The object is invisible and not solid *as an object*

The spawner (`$E4BD`) leaves `$0442,X` (metasprite id) at 0, and nothing in the
`$0C` handler ever sets it except the smash puff. The block the player sees and
stands on is **background**, drawn from the level's block data; its solidity
comes from the tile number through the normal `$DCBF` -> `$0680` path.

The player-vs-object interaction pass explicitly refuses to look at type `$0C`:

```
bank 7, sub_B285 (called from the object loop at $B278)
B285  BD 00 04  LDA $0400,X
B288  C9 0C     CMP #$0C
B28A  F0 11     BEQ $B29D        ; <<< type $0C -> RTS, no touch damage, no push
B28C  AD 9A 04  LDA $049A ...
```

So the crate is never solid, never harmful, never collectable as an object. It
is a pure hitbox.

### 2.3 Getting hit — one hit, no HP

Shot-vs-object test, bank 7 `$B606` (called per player-shot slot 1-5 from the
loop at `$B5D5`, which is called from `$B27B`):

```
B606  LDA $0400,X   BEQ rts             ; empty slot
B60B  LDA $049A,X   CMP #$FF BEQ rts    ; $FF = invincible
B612  LDA $05B8,X   BNE rts             ; stunned
B617  LDA $0416,X   AND #$DA  BNE rts   ; <<< flag gate
B61E  LDA $042C,X   BMI rts             ; hidden
B623  JSR $B768                         ; $12/$13 = defender half-extents
B626  LDY $0400,X / LDA $B44F,Y -> $07  ; per-type hitbox Y offset
B62F  $07 = $04C6,X - $B44F[type]       ; hitbox centre Y
B637  $0A = |shot.$0508 - obj.$0508|
B649  $0B = |shot.$04C6 - $07|
B658  if $12 + $06 <  $0A  -> miss      ; $06 = $B725[shot type] = shot radius
B662  if $13 + $06 <  $0B  -> miss
B66C  LDA $0416,X AND #$20 -> deflect    (sound $26, stun)
B673  LDY $26 / JSR $B688 / LDA #$21 / JMP $C81C   ; hit + hit sound
```

and the damage routine special-cases `$0C`:

```
B688  BD 00 04  LDA $0400,X
B68B  C9 0C     CMP #$0C
B68D  F0 62     BEQ $B6F1        ; <<< type $0C: no HP arithmetic at all
...
B6F1  A9 02     LDA #$02
B6F3  9D 8C 05  STA $058C,X      ; state 2 = "destroy now"
B6F6  A9 80     LDA #$80
B6F8  9D 16 04  STA $0416,X      ; $80 & $DA != 0 -> no longer hittable
B6FB  60        RTS
```

Hitbox data for type `$0C`:

* `$B44F + $0C = $B45B` = `$F8` -> hitbox centre Y = `$04C6,X + 8`
* `$B7DC + $0C*2 = $B7F4` = `80 B8` -> record `$B880` = `07 07`
  -> a 15x15 px box, i.e. exactly one 16x16 cell.

The flag gate at `$B617` is why the object is hittable at all: the spawner writes
`$0416,X = $08` (`$E4F5`) and state 0 writes `$01` (`$C99F` = `$FD76`); both pass
`AND #$DA`. After the hit `$0416,X = $80` fails it, so a crate cannot be hit
twice.

### 2.4 The state machine (`$8A5D`, bank 10)

```
8A5D  20 7E C9  JSR $C97E        ; = $FD10: LDA $058C,X / JMP $CA0B, table inline
8A60  6C 8A     .word $8A6C      ; state 0  arm
8A62  96 8A     .word $8A96      ; state 1  idle (RTS) -- resting state
8A64  97 8A     .word $8A97      ; state 2  destroy
8A66  B7 8A     .word $8AB7      ; state 3  smash puff timer
8A68  CA 8A     .word $8ACA      ; state 4  re-destroy after respawn
8A6A  E2 8A     .word $8AE2      ; state 5  park
```

**state 0** — `$8A6C`

```
8A6C  20 9F C9  JSR $C99F              ; = $FD76: $0416,X = $01 (hittable)
8A6F  BD 08 05  LDA $0508,X / CLC / ADC #$08 / STA $0508,X    ; X -> cell centre
8A78  BD F2 04  LDA $04F2,X / ADC #$00 / STA $04F2,X          ; carry into X hi
8A80  BD 9A 04  LDA $049A,X / TAY
8A84  B9 36 BE  LDA $BE36,Y            ; $BE36 = 01 02 04 08 10 20 40 80
8A87  25 3B     AND $3B                ; already broken?
8A89  D0 03     BNE $8A8E
8A8B  4C 66 C9  JMP $C966              ; = INC $058C,X -> state 1, wait to be hit
8A8E  A9 04     LDA #$04 / STA $058C,X ; already broken -> state 4
8A93  4C AB C9  JMP $C9AB              ; = $FD86: $0416,X = $80 (not hittable)
```

**state 2** — `$8A97`, the destruction

```
8A97  BD 9A 04  LDA $049A,X / TAY
8A9B  B9 36 BE  LDA $BE36,Y / EOR $3B / STA $3B    ; remember "broken"
8AA2  A9 01     LDA #$01 / JSR $C83A               ; = $E2D5, smash animation 1
8AA7  20 F0 8A  JSR $8AF0                          ; <<< THE DESTRUCTION
8AAA  A9 10     LDA #$10 / STA $05CE,X             ; puff timer
8AAF  A9 24     LDA #$24 / JSR $C81C               ; sound $24
8AB4  4C 66 C9  JMP $C966                          ; -> state 3
```

**state 3** — `$8AB7`: `JSR $C837` (animation step), `DEC $05CE,X`; at 0 set
state 5 and `$0442,X = 0` (puff disappears).

**state 4** — `$8ACA`, replayed when the camera brings the object back:

```
8ACA  A5 97     LDA $97 / BEQ $8ADC       ; horizontal?
8ACE  BD C6 04  LDA $04C6,X / CMP #$B8 / BCC $8AD6 / RTS
8AD6  20 F0 8A  JSR $8AF0 / JMP $C966
8ADC  20 F0 8A  JSR $8AF0 / JMP $C810     ; horizontal: re-destroy, free the slot
```

**state 5** — `$8AE2`: if `$04C6,X >= $B8` go to state 4, else RTS.

`$3B` is zeroed on every area load (`$E3E8`, bank 15) and on every screen setup
(`$DFE4`, bank 14), so the memory is **per area, 8 blocks maximum**. Bank 10
`$8B78` (inside type `$0D`) EORs the same bits, so `$0D` shares the byte — budget
for that if a stage uses both.

### 2.5 `$8AF0` — the destruction primitive

```
8AF0  BC C6 04  LDY $04C6,X            ; Y = object Y = TOP of the cell
8AF3  BD 08 05  LDA $0508,X / SEC / SBC #$08     ; A = LEFT of the cell
8AF9  20 A9 C8  JSR $C8A9              ; = $DF21   collision class of the cell := 0
8AFC  BD C6 04  LDA $04C6,X / CLC / ADC #$08 / TAY   ; bottom tile row
8B03  BD 08 05  LDA $0508,X / SEC / SBC #$08
8B09  20 A6 C8  JSR $C8A6              ; = $DEFA   $08/$09 := PPU address
8B0C  20 1E 8B  JSR $8B1E              ; queue 2 tiles of $00
8B0F  BC C6 04  LDY $04C6,X            ; top tile row
8B12  BD 08 05  LDA $0508,X / SEC / SBC #$08
8B18  20 A6 C8  JSR $C8A6
8B1B  4C 1E 8B  JMP $8B1E              ; queue 2 more tiles of $00

8B1E  86 25     STX $25
8B20  20 40 C8  JSR $C840     ; queue command $01 (horizontal, +1)
8B23  A5 08     LDA $08 / JSR $C849      ; addr lo
8B28  A5 09     LDA $09 / JSR $C849      ; addr hi
8B2D  A9 00     LDA #$00 / JSR $C849     ; tile $00      <<< hard-coded
8B32  A9 00     LDA #$00 / JSR $C849     ; tile $00      <<< hard-coded
8B37  20 46 C8  JSR $C846     ; $FF terminator
8B3A  A6 25     LDX $25 / RTS
```

So one call = **one 16x16 px cell**: four tiles set to `$00`, one collision
quadrant opened. Cost per call: 1 cache write + 2 queue records = 12 bytes of
`$0300`.

### 2.6 The two cell primitives in bank 14

```
DF21  20 8B DD  JSR $DD8B              ; A = x, Y = y -> $0A = quadrant, $0B = index
DF24  A4 0B     LDY $0B
DF26  B9 80 06  LDA $0680,Y
DF29  A4 0A     LDY $0A
DF2B  39 34 DF  AND $DF34,Y            ; $DF34 = 3F CF F3 FC
DF2E  A4 0B     LDY $0B
DF30  99 80 06  STA $0680,Y            ; class := 0 (air)
DF33  60        RTS

DF38  20 8B DD  JSR $DD8B              ; the mirror image
DF3B  ...       AND $DF34,Y / ORA $DF4E,Y   ; $DF4E = 80 20 08 02 -> class 2 (solid)
DF4D  60        RTS

DEFA  20 52 DF  JSR $DF52              ; A = x, Y = y
DEFD  ...       $08/$09 := PPU nametable address of the tile containing (x,y)
                $08 = ((nt_y & $3F) << 2) | (x' >> 3)
                $09 = $20 + (nt_y >> 6) + $DF1F[page]     ; $DF1F = 00 04
DF1E  60        RTS

DF52  ; the shared cell locator
      $0B = x ; $0D = y
      $09 = ($97 ? $FC : $E0) + y        ; nt row; the CMP #$F0 / ADC #$0F path
                                         ; makes it exactly world_y - $10 for
                                         ; horizontal areas (16-px HUD band)
      $0A = x + $FD                      ; + camera fine scroll
      Y   = page = ($FF ^ $08) & 1, flipped on carry
```

**These are the only three callers of the cell primitives in the whole ROM**
(ROM-wide byte scan for `20 A9 C8`, `20 AC C8`, `20 A6 C8`, `20 21 DF`,
`20 38 DF`, `20 FA DE`):

| site | bank | what |
|---|---|---|
| `$8AF9` (`$C8A9`) | 10 | type `$0C` breakable — clear class |
| `$A3EB` (`$C8A9`) | 11 | type `$47` moving BG block — clear class behind it |
| `$A3F4` (`$C8AC`) | 11 | type `$0F` moving BG block — set class 2 in front of it |
| `$8B09`, `$8B18` (`$C8A6`) | 10 | type `$0C` — PPU address |
| `$A478`, `$A48B` (`$C8A6`) | 11 | type `$0F`/`$47` — PPU address |

Type `$0F`/`$47` (`$A309`/`$A312`) is the *other* runtime-background object: a
16x16 block that walks around, drawing itself into the nametable with tiles
`$5E $5F / $60 $61` (or `$65 $66 / $67 $68` on stage 4) from `$A4B5`/`$A4BB` and
erasing with `$00`, and keeping `$0680` in step. It is a moving platform/crusher,
not a breakable, but it is a second working proof that the "background object"
technique is engine-supported.

---

## 3. The redraw hook — the closest thing to a RAM overlay

`$DF85` (bank 14) is called by the column fill (`$DB62`, `$DB7D`) and the row
fill (`$DC40`, `$DC55`) **on the even (top/left) tile of every 16-px pair**:

```
DB5E  A4 02     LDY $02
DB60  B1 00     LDA ($00),Y     ; raw tile from the block definition
DB62  20 85 DF  JSR $DF85       ; <<< the hook, may rewrite the tile
DB65  20 0B CD  JSR $CD0B       ; push the (possibly rewritten) tile to the PPU
DB68  20 BF DC  JSR $DCBF       ; <<< classify the (possibly rewritten) tile
DB6B  C8 C8 C8 C8  INY x4
DB6F  B1 00     LDA ($00),Y     ; the odd tile of the pair
DB71  20 9D DF  JSR $DF9D       ; blanks it if $017A != 0
DB74  20 0B CD  JSR $CD0B
```

so **one hook feeds both the renderer and the collision classifier.** (This also
settles the open question in `pb2_collision.md` §3: `$DCBF` is only ever called
on the even tile of each pair, which is the top-left tile of the 16x16 cell —
the "top-left tile decides the class" rule is now proved writer-side.)

```
DF85  8D 77 01  STA $0177        ; $0177 = the tile number, in and out
DF88  8C 78 01  STY $0178
DF8B  A0 3C     LDY #$3C / JSR $ECA7      ; bank pair 12/13
DF90  20 06 80  JSR $8006                 ; -> $BA42 in bank 13
DF93  20 C7 EC  JSR $ECC7
DF96  AD 77 01  LDA $0177 / LDY $0178 / RTS

DF9D  8D 77 01  STA $0177 / STY $0178
DFA3  AD 7A 01  LDA $017A / BEQ $DFAD
DFA8  A9 00     LDA #$00 / STA $0177      ; blank the odd tile too
DFAD  AD 77 01  LDA $0177 / LDY $0178 / RTS
```

### `$BA42`, bank 13 — the "already broken" tile substitution

```
BA42  A9 00     LDA #$00 / STA $017A       ; clear the "pair was remapped" flag
BA47  A5 79     LDA $79 / BNE rts          ; not on boss stages
BA4B  A5 53     LDA $53 / CMP #$02 / BEQ rts   ; not on stage 2
BA51  0A        ASL A / TAY
BA53  B9 A8 BA  LDA $BAA8,Y -> $10 ; $BAA9,Y -> $11    ; per-stage area table
BA5D  A5 9C     LDA $9C / ASL A / TAY
BA61  B1 10     LDA ($10),Y -> $12 ; -> $13            ; this area's record list
BA6A  A5 73     LDA $73 / AND #$1E / STA $17
BA74  A0 00     LDY #$00
BA76  B1 12     LDA ($12),Y / CMP #$FF / BEQ rts       ; end of list
BA7C  CD 79 01  CMP $0179      / BNE next              ; byte 0 == screen index
BA81  C8 / B1 12  LDA ($12),Y / CMP $17 / BNE next     ; byte 1 == $73 & $1E
BA88  C8 / B1 12  LDA ($12),Y / CMP $0177 / BNE next   ; byte 2 == the tile number
BA90  C8 / B1 12  LDA ($12),Y / AND $3B / BEQ next     ; byte 3 == the $3B bit
BA9F  A9 00     LDA #$00 / STA $0177        ; -> tile $00 for renderer AND collision
BAA4  EE 7A 01  INC $017A                   ; the odd tile of the pair too
BAA7  60        RTS
```

`$0179` is written only at `$E0BB` (bank 15), inside the screen-pick routine
`$E0B9`, from the camera screen counter `$66`. `$73` is the fill index along the
scroll axis, 0-31, wrapping at `$20` (`$D9C7`/`$D9CB` incrementing,
`$DA28`/`$DA2C` decrementing, both calling `$DE69` on wrap).

**Record: 4 bytes, list terminated by `$FF`.**

| off | meaning |
|---|---|
| 0 | `$0179` — index of the screen inside the area's screen list |
| 1 | `$73 & $1E` — the 16-px band along the scroll axis, in tiles (always even) |
| 2 | the tile number to substitute (matched against the *even* tile of the pair) |
| 3 | the `$3B` bitmask (`01/02/04/08/...`) |

Note what the record does **not** contain: a position across the scroll axis.
The substitution therefore applies to **every 16-px pair in that band of that
screen whose leading tile equals byte 2**. That is why each stage uses a
dedicated tile number for its breakables (`$D5` stage 0, `$D3` stage 1, `$F7`
stage 3, `$F6` stage 4, `$F4` stage 5).

### The shipped table (`$BAA8`, bank pair 12/13)

```
$BAA8:  B4 BA  D4 BA  B4 BA  FB BA  2B BB  44 BB  CA BA
        st0    st1    st2    st3    st4    st5    st6
```

| stage | area | records (`screen, band, tile, bit`) |
|---|---|---|
| 0 | 3 | `00 14 D5 01`  `01 08 D5 02` |
| 0 | 5 | `00 14 D5 01`  `01 02 D5 02` |
| 1 | 4 | `00 06 D3 01` |
| 1 | 5 | `02 0E D3 01`  `00 10 D3 02` |
| 1 | 6 | `00 1C D3 00`  `01 0A D3 02` |
| 3 | 0 | `00 1C F7 01`  `00 1E F7 02`  `01 1C F7 04`  `01 1E F7 08` |
| 3 | 6 | `02 0C F7 01`  `02 0E F7 02`  `02 10 F7 04`  `02 12 F7 08` |
| 4 | 7 | `00 08 F6 01` |
| 5 | 5 | `00 18 F4 01`  `00 1A F4 02`  `00 1C F4 04`  `00 1E F4 08` |
| 5 | 12 | `01 00 F4 01` |

Every other area points at an `$FF` (`$BACA`, `$BAB4`+... are shared empty
lists). The bit column matches the `$0C` placement records' flags byte
one-for-one.

**Cross-check against the placements, horizontal areas — exact, 8/8:**
stage 3 area 0, `$0C` at columns `$0E $0F $1E $1F` = world x 224/240/480/496
-> screens 0/0/1/1, within-screen tile columns 28/30/28/30 = `$1C $1E $1C $1E`.
Stage 3 area 6, columns `$26..$29` = x 608..656 -> screen 2, tile columns
12/14/16/18 = `$0C $0E $10 $12`. Both match byte for byte.

**UNRESOLVED:** in **vertical** areas the records whose byte 0 is 0 match the
same way (stage 1 area 4 `00 06` for row `$03`; stage 4 area 7 `00 08` for row
`$04`), but every record with byte 0 >= 1 comes out **2 tiles higher than the
naive prediction** (stage 0 area 3 `01 08` where row `$13` predicts `06`;
stage 0 area 5 `01 02` where row `$10` predicts `00`; stage 1 area 6 `01 0A`
where row `$14` predicts `08`). This is consistent with the 240-vs-256 nametable
wrap that `$DF52` handles explicitly (`CMP #$F0 / ADC #$0F`), but I did not
prove it. **For converted levels, derive byte 0/byte 1 for vertical areas by
measurement** (`-watch 0179` plus `-tracepc BA74-BAA7`), or keep crates in
horizontal areas where the rule is verified.
Also note `stage 1 area 6`'s first record has bit mask **`$00`**, which
`AND $3B` can never match — a dead record in the cartridge.

---

## 4. What does *not* exist

Stated plainly, since the brief asked:

* **No pushable/movable scenery block.** Type `$0F`/`$47` moves and paints
  itself into the background, but it is engine-driven, not player-pushed.
* **No RAM bitmap consulted by `sub_DCBF`.** `$DCBF` is a pure function of the
  tile number in `$10`. The state lives one level up, in `$BA42`.
* **No list of "cleared cells".** The state is the 8-bit `$3B` plus the
  `$0680` cache, both volatile and both rebuilt from the same 8 bits.
* **No attribute shadow RAM**, and the destruction never rewrites an attribute
  byte. Proved: see the CIRAM diff in §5 — 8 tile bytes changed, 0 attribute
  bytes.
* **No "stand on an object" support in the player physics.** The player's
  terrain probes (`$B316` in bank 9, probe lists `$B520`-`$B560`) read only the
  `$0680` class cache. Nothing anywhere makes an object slot solid to the
  player. This is decisive for the design choice in §7.

---

## 5. Runtime proof

All commands from the repo root; scratch in `$S`.

```sh
printf '1 -\n300 START\n308 -\n700 START\n708 -\n1000 START\n1008 -\n' > $S/boot.inp
./work/tools/nesemu "Power Blade 2 (USA).nes" -input $S/boot.inp -frames 620 \
    -savestate $S/pre.st@605
```

### 5.1 The objects exist and are placed where the ROM says

```sh
./work/tools/nesemu "Power Blade 2 (USA).nes" -loadstate $S/pre.st -input $S/boot.inp \
    -freeze 53=03 -frames 1700 -trace $S/t.txt -tracefrom 1699 -traceto 1700 \
    -tracepc FFFE-FFFF -watch 0400-0415
```

```
WATCH 1095,E4D0,15,0415,17
WATCH 1095,E4D0,15,0414,39
WATCH 1095,E4D0,15,0413,0C      <<< slot $13 = type $0C
WATCH 1095,E4D0,15,0412,0C      <<< slot $12 = type $0C
```

RAM at frame 1299 (stage 3, `$53=03`, `$9C=00`, `$97=00` horizontal,
camera `$66=$67=00`):

```
slot $12: type $0C  Xlo=$F8 (248)  Ylo=$80  state=1
slot $13: type $0C  Xlo=$E8 (232)  Ylo=$80  state=1
$3B = 00
$0680 page1 row 7 = 80 A0 00 0A      ; byte 3 = $0A -> quadrants 2 and 3 = class 2
```

248 = 240 + 8 and 232 = 224 + 8: the placement columns `$0F`/`$0E` (world x 240
and 224) plus state 0's `+8`. Both cells classify as **class 2, solid**, from the
level tile alone.

### 5.2 Forcing state 2 destroys them

```sh
./work/tools/nesemu "Power Blade 2 (USA).nes" -loadstate $S/pre.st -input $S/boot.inp \
    -freeze 53=03 -frames 1300 -poke 59E=02@1250 -poke 59F=02@1252 \
    -vram $S/B.vram@1299 -trace $S/tb.txt -tracefrom 1299 -traceto 1300 \
    -tracepc FFFE-FFFF -watch 0680-06FF
```

(`$058C + $12 = $059E`, `$058C + $13 = $059F`.)

```
WATCH 1250,DF33,14,06DF,08      ; $0A & $FC = $08   (quadrant 3 cleared)
WATCH 1252,DF33,14,06DF,00      ; $08 & $F3 = $00   (quadrant 2 cleared)
```

`$06DF` = `$0680 + $40 + 7*4 + 3` = page 1, row 7 (nt y 112-127), x 192-255.
`x=248-8=240 -> (240>>4)&3 = 3` and `x=232-8=224 -> 2` — the two quadrants the
masks `$FC` and `$F3` clear. Both cells go from class 2 to class 0.

CIRAM diff, control vs poked, same frame:

```
ciram[05DC] page1 TILE col28 row14  F7 -> 00
ciram[05DD] page1 TILE col29 row14  F7 -> 00
ciram[05DE] page1 TILE col30 row14  F7 -> 00
ciram[05DF] page1 TILE col31 row14  F7 -> 00
ciram[05FC] page1 TILE col28 row15  F7 -> 00
ciram[05FD] page1 TILE col29 row15  F7 -> 00
ciram[05FE] page1 TILE col30 row15  F7 -> 00
ciram[05FF] page1 TILE col31 row15  F7 -> 00
```

Eight tiles, columns 28-31 (x 224-255), rows 14-15 (y 112-127) — exactly the two
16x16 cells. **No attribute byte changed.** Screenshots
`A_1299.png` / `B_1299.png`: a 32x16 orange brick panel disappears.

### 5.3 A real weapon hit does the same

```sh
# RIGHT + alternating A / B from frame 1100
./work/tools/nesemu "Power Blade 2 (USA).nes" -loadstate $S/pre.st -input $S/f.inp \
    -freeze 53=03 -frames 1750 -trace $S/tf.txt -tracefrom 1050 -traceto 1750 \
    -tracepc B688-B68E -watch 0680-06FF
```

```
F1321 7:B688 BD 00 04 LDA $0400,X   A=00 X=13 Y=01 P=21   ; defender slot $13, attacker slot 1
F1321 7:B68B C9 0C    CMP #$0C      A=0C X=13 Y=01 P=21
F1321 7:B68D F0 62    BEQ $B6F1     A=0C X=13 Y=01 P=23   ; Z set -> taken
WATCH 1321,DF33,14,06DF,02                                ; $0A & $F3 = $02
```

CIRAM before (frame 1310) vs after (frame 1345):

```
ciram[05DC] page1 TILE col28 row14  F7 -> 00
ciram[05DD] page1 TILE col29 row14  F7 -> 00
ciram[05FC] page1 TILE col28 row15  F7 -> 00
ciram[05FD] page1 TILE col29 row15  F7 -> 00
```

Four tiles, one cell, no attribute change. The whole chain — player's boomerang
in slot 1, `$B606` box test, `$B688`/`$B6F1`, state 2, `$8A97`, `$8AF0`,
`$DF21` + `$0300` queue — runs live.

### 5.4 Also verified

`grep "WATCH.*,06DF," $S/tf.txt` over the whole 1750-frame run shows the only
writes to that cache byte are the level fill at frames 1082-1085 (`$DD33`) and
the destruction at 1321 (`$DF33`). Nothing else touches it.

---

## 6. What all this means for the converter

Facts a level converter has to respect:

1. **Granularity is 16x16 px**, one placement record per cell. A 32x32 Solbrain
   crate is four records out of the box.
2. **`$3B` is 8 bits per area.** Eight breakable *records* per area, shared with
   type `$0D`. Four-record crates therefore cap at **two crates per area**
   unmodified.
3. **The `$0680` cache holds the pre-break class**, which must come from the
   crate's own tile number through the stage's `$DCBF` tables — i.e. the crate
   tile must classify as `$80` (solid). You control tile numbering, so make the
   crate tile land in the solid band.
4. **The replacement tile is hard-coded `$00`** at `$8B2D` and `$8B32`
   (bank 10, file offsets `$14B3D`, `$14B42`). CHR tile `$00` is *not* blank in
   most of PB2's 128 1-KB CHR banks — it happens to be blank in the banks stage 3
   uses. Reserve a blank tile in the converted CHR, or change those two
   immediates.
5. **Attributes are never rewritten.** With a blank replacement tile that is
   correct (colour 0 is shared by all four background palettes). With a
   non-blank replacement you must push an attribute record yourself:
   `[4][lo][hi][1][attr]` with address `$23C0`/`$27C0 + (y>>5)*8 + (x>>5)`.
   A 32x32 crate is exactly one PB2 block, hence exactly one attribute byte.
6. **You must also emit the `$BA42` remap records**, otherwise the block reappears
   as soon as the camera refills that column (the object's state-4 path repairs
   it, but only once per respawn and with a visible one-frame flash).
7. **Reserving a contiguous tile range does help — for the `$BA42` records.**
   Byte 2 of a remap record is a tile number, and the record has no across-axis
   coordinate, so the substitution hits every matching pair in that band of that
   screen. Give breakables their own tile numbers and never reuse them for
   non-breakable scenery, and the records become trivially correct. (It does not
   help the collision classifier: `$0C` is keyed on the object type, not on the
   tile.)

---

## 7. Design — how to reproduce Solbrain's 32x32 crates

### 7.1 Why (a) "as objects" is the wrong answer

* The player-object pass **skips type `$0C` by name** (`$B285`), and there is no
  generic "solid object" concept anywhere. To let the player stand on a sprite
  crate you would have to inject an object scan into the player's terrain probe
  results in bank 9 around `$B316`-`$B3D8`, per probe, per frame. Bank 9 has 103
  free bytes (`$BF99-$BFFF`) and bank 8 has 150 (`$8D6A-$8DFF`); the probe code
  itself is packed, so every hook is a JSR-out-and-back with saved state.
* A new dispatch entry is cheap by itself (2 bytes at `$8080+type*2`, plus one
  byte in the culling-class table `$8212`, plus one byte in `$B44F` and one word
  in `$B7DC`), but `$B7DC` is **fully packed**: the pointer table `$B7DC..$B87B`
  (80 words for types `$00`-`$4F`) is immediately followed by the hitbox records
  at `$B87C`, and the words for types `$50`-`$59` already read into the record
  data. So a new type must reuse an existing record.
* You would still have to draw the crate. As a sprite it costs 4 hardware
  sprites minimum (32x32) out of a budget already spent on the player and
  enemies, and it would flicker.

**Do not do (a).**

### 7.2 Recommendation: (b), by reusing type `$0C`

The engine already *is* (b). The only thing missing is that a `$0C` covers one
16x16 cell instead of a 32x32 crate. Fixing that is 5 patched bytes and 151 new
bytes, all inside banks that are already mapped when the code runs.

#### Tier A — zero code

Emit four `$0C` placement records and four `$BA42` remap records per crate.
Works today, with the 2-crates-per-area cap.

#### Tier B — one crate = one record

**Anchor convention after the patch:** state 0 moves `$0508,X` to the crate's
**centre X** (`left + 16`); `$04C6,X` stays the crate's **top Y**. The four
cleared cells are at `($0508,X - $10 + {0,16}, $04C6,X + {0,16})`.

**Patch sites** (file offsets are into `Power Blade 2 (USA).nes`, 16-byte header
included; in the PB3 multicart image add the block's base offset):

| # | bank | CPU | file | from | to | why |
|---|---|---|---|---|---|---|
| 1 | 10 | `$8A74` | `$14A84` | `08` | `10` | operand of `ADC #$08` at `$8A73`: anchor X at the crate centre (+16) instead of the cell centre (+8) |
| 2 | 10 | `$8A64` | `$14A74` | `97 8A` | `94 BF` | state-2 word -> `cr_s2` |
| 3 | 10 | `$8A68` | `$14A78` | `CA 8A` | `B4 BF` | state-4 word -> `cr_s4` |
| 4 | 7 | `$B45B` | `$0F46B` | `F8` | `F0` | `$B44F[$0C]`: hitbox centre Y = `$04C6,X + 16` |
| 5 | 7 | `$B7F4` | `$0F804` | `80 B8` | `84 B8` | `$B7DC[$0C]`: hitbox record `$B880` (07,07) -> `$B884` (0F,0F) = 31x31 px. `$B884` already exists (used by type `$37`), so no new data |
| 6 | 11 | `$BF35..$BFCB` | `$17F45` | `FF` x151 | the blob below | the new code |

Optional, only if a converted **stage 2** needs crates:

| 7 | 13 | `$BA4F` | `$1BA5F` | `F0 22` | `EA EA` | remove `CMP #$02 / BEQ rts`, the hard-coded "stage 2 has no breakables" guard |

Bank 11 `$BF35-$BFFF` is 203 bytes of `$FF` after `JMP $C8CD` ends the bank's
live code (verified: every byte is `$FF`). Bank 10 has **no** free run >= 24
bytes, which is why the new code goes in bank 11 — and that is free, because
banks 10 and 11 are mapped together as a pair (`$8000-$9FFF` and `$A000-$BFFF`),
so `cr_one` can `JSR $8B1E` into bank 10 directly.

#### The new routine

```
; ===== PB3: type $0C becomes a 32x32 destructible crate ==============
; bank 11, org $BF35.   X = object slot throughout.
;   $0508,X = crate centre X   (state 0 put it there: left + 16)
;   $04C6,X = crate top    Y
; The four 16x16 cells are ($0508,X - $10 + dx, $04C6,X + dy),
; dx,dy in {0,16}.

BF35  BC C6 04    cr_one:  LDY $04C6,X       ; Y = top of this cell
BF38  BD 08 05             LDA $0508,X
BF3B  38                   SEC
BF3C  E9 10                SBC #$10          ; A = left of this cell
BF3E  20 A9 C8             JSR $C8A9         ; ->$DF21  $0680 cell class := 0
BF41  BD C6 04             LDA $04C6,X
BF44  18                   CLC
BF45  69 08                ADC #$08          ; bottom tile row of the cell
BF47  A8                   TAY
BF48  BD 08 05             LDA $0508,X
BF4B  38                   SEC
BF4C  E9 10                SBC #$10
BF4E  20 A6 C8             JSR $C8A6         ; ->$DEFA  $08/$09 := PPU address
BF51  20 1E 8B             JSR $8B1E         ; queue "2 tiles = $00"  (bank 10)
BF54  BC C6 04             LDY $04C6,X       ; top tile row
BF57  BD 08 05             LDA $0508,X
BF5A  38                   SEC
BF5B  E9 10                SBC #$10
BF5D  20 A6 C8             JSR $C8A6
BF60  4C 1E 8B             JMP $8B1E         ; queue "2 tiles = $00", RTS

; --- clear all four cells; leaves the anchor exactly as it found it ---
BF63  20 35 BF    cr_clear: JSR cr_one                       ; cell (0,0)
BF66  BD 08 05 18 69 10 9D 08 05    LDA $0508,X/CLC/ADC #$10/STA $0508,X
BF6F  20 35 BF              JSR cr_one                       ; cell (1,0)
BF72  BD C6 04 18 69 10 9D C6 04    LDA $04C6,X/CLC/ADC #$10/STA $04C6,X
BF7B  20 35 BF              JSR cr_one                       ; cell (1,1)
BF7E  BD 08 05 38 E9 10 9D 08 05    LDA $0508,X/SEC/SBC #$10/STA $0508,X
BF87  20 35 BF              JSR cr_one                       ; cell (0,1)
BF8A  BD C6 04 38 E9 10 9D C6 04    LDA $04C6,X/SEC/SBC #$10/STA $04C6,X
BF93  60                    RTS

; --- state 2: hit -> destroy.  Clone of $8A97 with cr_clear. ---------
BF94  BD 9A 04    cr_s2:   LDA $049A,X       ; record flags = $3B bit index 0-7
BF97  A8                   TAY
BF98  B9 36 BE             LDA $BE36,Y       ; $BE36 = 01 02 04 08 10 20 40 80
BF9B  45 3B                EOR $3B
BF9D  85 3B                STA $3B           ; mark broken for this area
BF9F  A9 01                LDA #$01
BFA1  20 3A C8             JSR $C83A         ; ->$E2D5 start smash animation 1
BFA4  20 63 BF             JSR cr_clear      ; <<< 4 cells instead of 1
BFA7  A9 10                LDA #$10
BFA9  9D CE 05             STA $05CE,X       ; puff timer
BFAC  A9 24                LDA #$24
BFAE  20 1C C8             JSR $C81C         ; ->$ECE8 sound $24
BFB1  4C 66 C9             JMP $C966         ; ->INC $058C,X = state 3

; --- state 4: re-apply after a respawn.  Clone of $8ACA. -------------
BFB4  A5 97       cr_s4:   LDA $97
BFB6  F0 0E                BEQ $BFC6         ; horizontal area
BFB8  BD C6 04             LDA $04C6,X
BFBB  C9 B8                CMP #$B8
BFBD  90 01                BCC $BFC0
BFBF  60                   RTS
BFC0  20 63 BF             JSR cr_clear
BFC3  4C 66 C9             JMP $C966
BFC6  20 63 BF             JSR cr_clear
BFC9  4C 10 C8             JMP $C810         ; ->$D6D4 free the slot
```

Raw bytes for file offset `$17F45` (151 bytes):

```
BF35: BC C6 04 BD 08 05 38 E9 10 20 A9 C8 BD C6 04 18
BF45: 69 08 A8 BD 08 05 38 E9 10 20 A6 C8 20 1E 8B BC
BF55: C6 04 BD 08 05 38 E9 10 20 A6 C8 4C 1E 8B 20 35
BF65: BF BD 08 05 18 69 10 9D 08 05 20 35 BF BD C6 04
BF75: 18 69 10 9D C6 04 20 35 BF BD 08 05 38 E9 10 9D
BF85: 08 05 20 35 BF BD C6 04 38 E9 10 9D C6 04 60 BD
BF95: 9A 04 A8 B9 36 BE 45 3B 85 3B A9 01 20 3A C8 20
BFA5: 63 BF A9 10 9D CE 05 A9 24 20 1C C8 4C 66 C9 A5
BFB5: 97 F0 0E BD C6 04 C9 B8 90 01 60 20 63 BF 4C 66
BFC5: C9 20 63 BF 4C 10 C8
```

52 bytes of bank-11 slack remain.

#### Runtime state it needs

**None that does not already exist.** No new work RAM at all:

* `$3B` bit — already there, from the record's flags byte.
* `$058C,X` state, `$05CE,X` timer, `$0416,X` hittable flag, `$0442,X` puff —
  already there.
* `$0680` cache and the `$0300` queue — already there.

Cost per destruction: 4 cache writes and 8 queue records = **48 bytes of the 256
byte `$0300` buffer in one frame**, 8 PPU address set-ups and 16 `$2007` writes.
That is roughly half of a scroll column fill (32 tiles), and the queue is flushed
in the same NMI. If you ever need it leaner, replace `$8B1E` with a bank-11
routine that emits one command per 4-tile row (4 records, 16 writes) instead of
two per cell.

#### Data the converter emits per crate

1. **Level data** — the crate drawn normally in the 32x32 block, using tiles
   whose `$DCBF` band gives type `$80` (class 2). One PB2 block = one attribute
   byte, so a crate aligned to the block grid is exactly one attribute cell.
2. **Placement record** (bank pair 6/7, this area's list, position-sorted):
   `[pos] $0C [across] [bit]` where `pos` is the crate's **left** column in
   16-px units along the scroll axis, `across` is the **top** pixel across it,
   and `bit` is 0-7, unique per area.
3. **Four `$BA42` remap records** (bank pair 12/13, this area's list): the crate
   spans two 16-px bands and two 16-px cells across, and the remap key is
   `(screen, band, tile)`; with the crate's own reserved tile numbers you need
   one record per (band, tile) pair actually used — in the common case where all
   four cells use two distinct tile numbers (top pair, bottom pair):

   ```
   [screen] [band  ] [tile_top   ] [bit]
   [screen] [band+2] [tile_bottom] [bit]
   ```

   If all four cells share one tile number, two records still suffice (one per
   band). If the crate straddles a screen boundary you need the records for both
   screen indices. For **horizontal** areas: `screen = left_x >> 8`,
   `band = ((left_x >> 3) & $1E)`. For **vertical** areas measure it (see the
   UNRESOLVED note in §3).

#### Caveats to design around

* **8 crates per area** (`$3B`). If you need more, the next cheapest extension is
  to widen the "broken" set: `$3B` is a plain zero-page byte read at `$8A87`,
  `$8A9E`, `$8B7F` and `$BA93`. Moving it to a 16-byte bitmap indexed by
  `$049A,X >> 3` costs one extra `LDA/AND/TAX` at each of those four sites and
  16 bytes of RAM — but `$BA93` is inside the bank-13 hook where you have room,
  and the three bank-10 sites do not. Budget a rewrite of `$8A5D`'s whole
  handler into bank 11 if you go there.
* **`$0416,X` bit meanings are not fully decoded.** The values the crate path
  uses (`$08` from the spawner, `$01` from `$C99F`, `$80` from `$C9AB`/`$B6F1`)
  are proven to work; do not invent new values.
* **`$B725,Y`** (shot radius) and **`$B721,Y`** (damage) overlap by 4 bytes and
  are indexed by the *attacker's* type. A crate is destroyed by any hit
  regardless of damage, so neither matters here — but the crate's hit box grows
  by the shot radius, `$06`, which is `$08` for the unsuited knife (type 1) and
  `$10` for the suited beam (type 3). With `(0F,0F)` the effective reach is
  ±23 to ±31 px around the crate centre. If that feels too generous, use
  `$B882` = `(0C,0C)` instead of `$B884`.
* **The `$0300` queue has no overflow check.** If a frame ever destroys two
  crates *and* does a column fill *and* an attribute fill, you are at roughly
  48 + 41 + 13 = 102 bytes — still fine, but the ceiling is 256 bytes and about
  one VBlank's worth of `$2007` writes. Do not let more than ~2 crates break in
  the same frame.
* **`$6600-$67FF` may not be usable.** `ARCHITECTURE.md` puts the mapper-45
  outer registers over `$6000-$7FFF` with the lock bit left at 0, which means
  writes there hit the mapper, not RAM. The design above needs **no** work RAM,
  which sidesteps the problem entirely. If a future extension does need RAM,
  note that a static scan found no unreferenced zero-page byte and `$0700-$07FF`
  is densely used.

---

## 8. Address index

| address | bank | what |
|---|---|---|
| `$0300` / `$1F` | RAM | PPU upload queue and its write index |
| `$0680-$06FF` | RAM | 2-bit-per-16x16-cell collision class cache |
| `$3B` | RAM | per-area "block already broken" bitmask, 8 bits |
| `$0177`/`$0178`/`$017A` | RAM | tile / Y save and "pair remapped" flag for `$DF85`/`$DF9D` |
| `$0179` | RAM | screen index inside the area (`$66`), written at `$E0BB` |
| `$8098` | 10 | dispatch word for type `$0C` -> `$8A5D` |
| `$8A5D` | 10 | type `$0C` state machine |
| `$8A6C` `$8A96` `$8A97` `$8AB7` `$8ACA` `$8AE2` | 10 | states 0-5 |
| `$8AF0` | 10 | destroy one 16x16 cell |
| `$8B1E` | 10 | push "2 tiles of `$00`" into the queue |
| `$BE36` | 11 | `01 02 04 08 10 20 40 80` |
| `$A309`/`$A312` | 11 | types `$0F`/`$47`, the moving background block |
| `$A3EB`/`$A3F4` | 11 | its clear / set of the collision cell |
| `$A4B5`/`$A4BB` | 11 | its tile pairs |
| `$B285` | 7 | player-touch pass; skips type `$0C` |
| `$B606` | 7 | shot-vs-object box test |
| `$B688`/`$B6F1` | 7 | damage; `$0C` -> state 2 |
| `$B44F` | 7 | per-type hitbox Y offset, 90 bytes |
| `$B7DC` | 7 | per-type hitbox pointer table (80 usable words) |
| `$B87C..$B8A3` | 7 | the hitbox (halfW, halfH) records |
| `$BA42` | 13 | the "already broken" tile substitution hook |
| `$BAA8` | 13 | its per-stage area-table pointers |
| `$CC41` | 14 | NMI queue flush |
| `$CD0B` `$CD09` `$CD14` `$CD18` `$CD1C` `$CD20` `$CD24` | 14 | queue push primitives |
| `$C840` `$C843` `$C846` `$C849` | 14 | their trampolines |
| `$C8A6` `$C8A9` `$C8AC` | 14 | trampolines to `$DEFA` / `$DF21` / `$DF38` |
| `$DB42` / `$DBDE` | 14 | column / row fill |
| `$DC73` / `$DCA5` | 14 | attribute fill (queue command `$04`) |
| `$DCBF` | 14 | tile -> collision class |
| `$DD8B` | 14 | (x,y) -> `$0680` index + quadrant |
| `$DEFA` / `$DF52` | 14 | (x,y) -> PPU address / cell locator |
| `$DF21` / `$DF38` | 14 | clear cell to class 0 / set cell to class 2 |
| `$DF85` / `$DF9D` | 14 | per-level tile remap hook and its odd-tile sibling |
| `$E0B9` | 15 | screen pick; writes `$0179` |
| `$E3F3` / `$E4BD` | 15 | placement scan and record -> object translation |
| `$E9C7` / `$E9F9` | 15 | NMI / the queue flush call |
