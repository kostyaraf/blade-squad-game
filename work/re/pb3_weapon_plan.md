# PB3 — the eight Solbrain sub-weapons inside Power Blade 2's engine

Implementation plan. Everything below is either a disassembly excerpt taken from
`Power Blade 2 (USA).nes` / `work/build/PB3.nes`, or a runtime observation from
`work/tools/nesemu`. Claims that are *inferred* rather than observed are tagged
**[inferred]**. Corrections to `work/re/pb2_weapons.md` are tagged **[correction]**.

Goal, restated: eight extra weapons, owned from the first frame, selected with
LEFT/RIGHT in the suit menu, each shot draining the same `$A0` bar / `$9E` spare-tank
pool that the suits drain.

---

## 0. Corrections to `pb2_weapons.md` before anything else

These matter because the plan is built on them.

| # | `pb2_weapons.md` says | Actually |
|---|---|---|
| C1 | `sub_A4FD` computes the charge tier | It is the **muzzle-offset applier**. The charge tier is computed inline at `$A245-$A258` and stored in `$08`. See §1.3. |
| C2 | `$05A2,X` on a suited beam is a "power byte" | It is the **lifetime in frames**. `$A84C DEC $05A2,X / BEQ $A852 / $A852 JMP $C810`. Runtime: a beam spawned with `$05A2 = $09` was freed at `$D6D6` exactly 9 frames later. |
| C3 | `$A905/$A90D/$A915/$A91D` are "the velocity tables" | Those four are the **initial** velocity. `$A925/$A92D/$A935/$A93D` are a **per-frame acceleration** added at `$A7FB` every frame. The suited beam accelerates. |
| C4 | the shot updater covers slots 1-4 | `sub_A563` is `LDX #$01 … INX / CPX #$06 / BNE`, i.e. **slots 1..5**. In PB3 slot 5 is player 2 (`P2_SLOT = 5`), and `RT_FINDSHOT` stops the allocator at 5, so **shots occupy slots 1..4**. |
| C5 | field 11 is `$04F2`… listed as field 21 | Field *n* is `$0400 + 22n`; `$04F2` is **field 11** (X hi). Full list in §1.1. |
| C6 | (not mentioned at all) | **The attacker's hitbox radius is `$B725,type`** — a second 8-entry table overlapping `$B721`. New object types therefore need *two* table patches, not one. See §1.5. This is the single biggest omission in `pb2_weapons.md`. |
| C7 | (not mentioned) | **PB2 player shots already pierce.** `$B673 LDY $26 / JSR $B688` applies damage and nothing in that path frees the attacker slot; the enemy simply gets 8 or 16 i-frames in `$05B8,X`. |
| C8 | (not mentioned) | Held-button state is **`$4A`** (pad 1) / `$4B` (pad 2); `$48`/`$49` are newly-pressed. Proof at `$EBCC` below. |

Proof for C8:

```
EBB0  A2 00     LDX #$00
EBB2  20 E7 EB  JSR $EBE7          ; read pad -> $00,$01
EBB5  A2 02     LDX #$02
EBB7  20 E7 EB  JSR $EBE7          ; read again -> $02,$03 (DPCM re-read guard)
EBBA  A5 00 C5 02 D0 1C            ; mismatch -> $EBDC (zero everything)
...
EBCC  B5 00     LDA $00,X          ; raw
EBCE  A8        TAY
EBCF  55 F7     EOR $F7,X          ; ^ previous raw
EBD1  35 00     AND $00,X          ; & raw    = newly pressed
EBD3  95 48     STA $48,X          ; $48/$49 = NEW
EBD5  95 F5     STA $F5,X
EBD7  94 4A     STY $4A,X          ; $4A/$4B = HELD
EBD9  94 F7     STY $F7,X
EBDB  60        RTS
```

Bit order follows from `ROL $00,X` × 8 with A read first:
`bit7 A, bit6 B, bit5 SELECT, bit4 START, bit3 UP, bit2 DOWN, bit1 LEFT, bit0 RIGHT`.
Consistent with `$A1FA AND #$40` (B), `$D269 AND #$08` (UP), `$D26F AND #$04` (DOWN).

---

## 1. Where the player's fire actually happens

### 1.1 The object array

22 slots × 29 one-byte fields, stride `$16`, field *n* at `$0400 + 22n`:

| field | addr | meaning |
|---|---|---|
| 0 | `$0400` | object type (0 = free slot) |
| 1 | `$0416` | flags; bit7 on slot 0 = player busy |
| 2 | `$042C` | attr: bit7 hide, bit6 H-flip, bits0-1 palette |
| 3 | `$0442` | metasprite id |
| 4 | `$0458` | animation / pose index |
| 5-7 | `$046E`,`$0484`,`$049A` | anim timer, anim seq, HP (`$FF` = invulnerable) |
| 8 | `$04B0` | Y high (must stay 0) |
| 9 | `$04C6` | Y pixel |
| 10 | `$04DC` | Y fraction |
| 11 | `$04F2` | X high (must stay 0) |
| 12 | `$0508` | X pixel |
| 13 | `$051E` | X fraction |
| 14 | `$0534` | Y velocity, integer (signed) |
| 15 | `$054A` | Y velocity, fraction |
| 16 | `$0560` | X velocity, integer (signed) |
| 17 | `$0576` | X velocity, fraction |
| 18 | `$058C` | free per-type byte |
| 19 | `$05A2` | lifetime countdown (shots) |
| 20 | `$05B8` | i-frames |
| 21 | `$05CE` | direction 0..7 (shots) |
| 22-24 | `$05E4`,`$05FA`,`$0610` | free per-type bytes |
| 25-28 | `$0626`,`$063C`,`$0652`,`$0668` | not cleared by `sub_D6D4` |

Directions, read off `$A905/$A90D/$A915/$A91D` (§1.4):
`0 = right, 1 = left, 2 = up, 3 = down, 4 = up-right, 5 = up-left, 6 = down-right, 7 = down-left`.

### 1.2 The two dispatchers — and why the pinned table does not block us

Bank 10 `sub_807A` has an **inline 90-entry word table at `$8080`** consumed by the
`JSR $C84F` → `$CA0B` helper, which PLA/PLAs the return address. That table is
therefore unrelocatable. **But it only drives slots 6..21.**

Player shots are driven by a completely separate loop in bank 9:

```
A563  A2 01     LDX #$01
A565  BD 00 04  LDA $0400,X
A568  F0 03     BEQ $A56D
A56A  20 73 A5  JSR $A573
A56D  E8        INX
A56E  E0 06     CPX #$06
A570  D0 F3     BNE $A565
A572  60        RTS

A573  C9 03     CMP #$03
A575  D0 03     BNE $A57A
A577  4C FB A7  JMP $A7FB          ; suited beam
A57A  ...                          ; unsuited knife
```

**`sub_A573` is a 7-byte patch site and `$8080` is never involved.** Adding new
player-shot types costs one `JMP`.

Caller: `$8E26 20 63 A5 JSR $A563`, once per frame, from bank 8's per-frame chain
(`$8E1D JSR $B316`, `$8E20 JSR $B570`, `$8E23 JSR $A17A`, `$8E26 JSR $A563`, …).

### 1.3 The fire trigger — `$A1F8`

```
A1F8  A5 48     LDA $48            ; newly pressed, pad 1
A1FA  29 40     AND #$40           ; B
A1FC  F0 27     BEQ $A225
A1FE  20 D9 A3  JSR $A3D9          ; allocate a shot slot -> X, C set = failed
A201  B0 22     BCS $A225
A203  86 25     STX $25
A205  20 03 A4  JSR $A403          ; X = direction 0..7, Y = pose (bit7 = refuse)
A208  98        TYA
A209  30 1A     BMI $A225
A20B  8C 58 04  STY $0458
A20E  B9 EE A4  LDA $A4EE,Y
A211  A8        TAY
A212  20 17 B0  JSR $B017          ; put the player into the throw pose
A215  AD 16 04  LDA $0416
A218  09 80     ORA #$80
A21A  8D 16 04  STA $0416          ; player busy
A21D  A9 00     LDA #$00
A21F  8D 00 04  STA $0400          ; (slot-0 scratch)
A222  4C 26 A2  JMP $A226
A225  60        RTS
A226  8A        TXA
A227  A6 25     LDX $25
A229  9D CE 05  STA $05CE,X        ; direction -> the shot
A22C  AD 2C 04  LDA $042C
A22F  29 60     AND #$60
A231  9D 2C 04  STA $042C,X        ; inherit facing + palette bit
A242  20 FD A4  JSR $A4FD          ; *** muzzle offset -- see C1 ***
A245  A0 00     LDY #$00
A247  A5 54     LDA $54            ; charge counter
A249  C5 8D     CMP $8D
A24B  90 0B     BCC ...            ; -> tier 0 / 1 / 2 / 3 against $8D,$8E,$8F
A258  84 08     STY $08            ; charge tier 0..3
A291  A5 9A     LDA $9A            ; suit id
A293  F0 03     BEQ $A298
A295  4C 7F A3  JMP $A37F          ; suited spawn
```

Reached by fallthrough from `$A1C2 LDA $0416 / BPL $A1F8` — **not** by JSR, so the
`RTS` at `$A225` returns from `$A1F8`'s own caller.

Runtime confirmation (`nesemu -trace -watch 400`, PB2, pad B pressed at frame 1600):

```
WATCH 1600,A37F,9,0401,01      ; type 1 written to slot 1
WATCH 1600,A38C,9,0443,45      ; metasprite $45
WATCH 1600,A3A5,9,05A3,09      ; lifetime 9
WATCH 1609,D6D6,14,0401,00     ; freed exactly 9 frames later
```

### 1.4 The allocator and the spawner

```
A3D9  A5 99     LDA $99
A3DB  ...       $10 = 1 + $99                 ; max simultaneous shots
      count non-zero among $0401/$0402/$0403
      CPY $10 / BCS $A402                     ; at the cap -> C set, fail
A3F6  A2 01     LDX #$01                      ; <-- PB3 replaces these 3 bytes
A3F8  BD 00 04  LDA $0400,X                   ;     with JSR RT_FINDSHOT
A3FB  F0 03     BEQ $A400
A3FD  E8        INX
A3FE  D0 F8     BNE $A3F8
A400  18        CLC
A401  60        RTS
A402  38 60     SEC / RTS
```

`RT_FINDSHOT` (already in `work/pb3/build.py`, patched at bank 9 `$A3F6`) stops the
scan at `P2_SLOT = 5`, so **shots live in slots 1..4** in PB3.

`sub_A4FD` — the muzzle offset **[correction C1]**:

```
A4FD  A4 58 04  LDY $0458                     ; pose index 0..14
      LDA $A545,Y   sign-extended, added to $04C6/$04B0 -> $04C6,X / $04B0,X
      LDA $A554,Y   negated when $042C,X bit6 (facing left),
                    added to $0508/$04F2      -> $0508,X / $04F2,X
$A545 = F0 F8 F0 DA 06 E8 F8 F0 00 F0 DA 06 F8 E8 F8     (Y offsets)
$A554 = 08 08 08 00 00 08 08 08 F8 08 00 00 08 08 08     (X offsets)
```

So `$A4FD` also **copies the player's position into the shot slot**. Reuse it verbatim.

Suited spawn `loc_A37F`, runtime-confirmed with `dir = 1` (left):

```
A37F  A9 03     LDA #$03      / 9D 00 04 STA $0400,X       ; type 3
      A9 00     LDA #$00      / 9D E4 05 STA $05E4,X
      BC CE 05  LDY $05CE,X
      B9 E5 A8  LDA $A8E5,Y   / 9D 42 04 STA $0442,X       ; metasprite
      B9 05 A9  LDA $A905,Y   / 9D 76 05 STA $0576,X       ; VX fraction
      B9 0D A9  LDA $A90D,Y   / 9D 60 05 STA $0560,X       ; VX integer
      B9 15 A9  LDA $A915,Y   / 9D 4A 05 STA $054A,X       ; VY fraction
      B9 1D A9  LDA $A91D,Y   / 9D 34 05 STA $0534,X       ; VY integer
      20 58 A3  JSR $A358                                  ; halve when crouching
      ... $05A2,X = (*$A8ED[world])[tier]                  ; LIFETIME  [correction C2]
      A9 22     LDA #$22 / 20 1C C8 JSR $C81C              ; sound
```

Tables (bank 9):

```
$A8E5 = 3E 3E 40 42 3F 3F 41 41          metasprite per direction
$A905 = 40 C0 00 00 2D D3 2D D3          initial VX frac
$A90D = 00 FF 00 00 00 FF 00 FF          initial VX int
$A915 = 00 00 C0 00 D3 D3 2D 2D          initial VY frac
$A91D = 00 00 FF 03 FF FF 00 00          initial VY int
$A925 = C0 40 00 00 87 79 87 79          per-frame VX frac accel   [correction C3]
$A92D = 00 FF 00 00 00 FF 00 FF          per-frame VX int  accel
$A935 = 00 00 00 00 79 79 87 87          per-frame VY frac accel
$A93D = 00 00 FF 01 FF FF 00 00          per-frame VY int  accel
$A8ED = F5 A8 F9 A8 FD A8 01 A9          world -> lifetime table
  $A8F5 = 06 07 08 09   $A8F9 = 09 0A 0B 0C
  $A8FD = 0C 0D 0E 0F   $A901 = 0F 10 11 12    (indexed by charge tier 0..3)
```

### 1.5 Per-frame movement, and the collision tables

```
A7FB (type 3): LDY $05CE,X ; $00..$03 = $A925/$A92D/$A935/$A93D[dir]
               halve when $05FA,X ; $0576/$0560 += $00/$01 ; $054A/$0534 += $02/$03
A849  20 E8 C8 JSR $C8E8      ; generic 24-bit integrator -> $FB7B -> $FA08
A84C  DE A2 05 DEC $05A2,X
A84F  F0 01    BEQ $A852
A851  60       RTS
A852  4C 10 C8 JMP $C810      ; -> sub_D6D4, free the slot

A7B9 (unsuited): integrates and kills when the high byte would go non-zero:
      $04DC,X += $054A,X ; $04C6,X += $0534,X + C ; result hi NOT stored
A7D5  D0 1F    BNE $A7F6
      ... same for X ...
A7F3  D0 01    BNE $A7F6
A7F6  68 68    PLA / PLA
A7F8  4C 10 C8 JMP $C810
```

Note `$A7B9` pops **two** return words. Anything calling it must be exactly two
levels below the `sub_A563` loop. Our handlers are entered by `JMP` (from the
`$CA0B` dispatcher), so a `JSR RT_MOVE` from a handler is exactly two levels — see §3.0.

**Collision** — bank 7, attacker loop over slots 1..5:

```
B5DA  BD 2C 04  LDA $042C,X
B5DD  30 26     BMI $B605              ; defender hidden -> skip
B5DF  A0 01     LDY #$01
B5E1  84 26     STY $26                ; $26 = attacker slot
B5E3  B9 B0 04  LDA $04B0,Y
B5E6  19 F2 04  ORA $04F2,Y
B5E9  D0 13     BNE $B5FE              ; attacker off-world -> skip   <-- keep hi = 0!
B5EB  B9 00 04  LDA $0400,Y
B5EE  F0 0E     BEQ $B5FE
B5F0  B9 00 04  LDA $0400,Y            ; *** PATCH SITE ***
B5F3  A8        TAY
B5F4  B9 25 B7  LDA $B725,Y            ; attacker hitbox radius  [correction C6]
B5F7  85 06     STA $06
B5F9  A4 26     LDY $26
B5FB  20 06 B6  JSR $B606
B5FE  A4 26     LDY $26
B600  C8        INY
B601  C0 06     CPY #$06
B603  D0 DC     BNE $B5E1
```

Overlap test (`$B658`): `|dx| <= $12 + $06` and `|dy| <= $13 + $06`, where `$12`/`$13`
are the defender half-sizes from `JSR $B768` and `$06` is the attacker radius.

Damage:

```
B673  A4 26     LDY $26
B675  20 88 B6  JSR $B688
B678  A9 21     LDA #$21 / 4C 1C C8 JMP $C81C     ; hit sound; attacker NOT freed [C7]

B688  BD 00 04  LDA $0400,X
B68B  C9 0C     CMP #$0C
B68D  F0 62     BEQ $B6F1
B68F  B9 00 04  LDA $0400,Y            ; *** PATCH SITE ***
B692  A8        TAY
B693  B9 21 B7  LDA $B721,Y            ; damage by attacker type
B696  85 17     STA $17
```

The two tables overlap:

```
$B721:  01 01 02 03 05 08 09 10  A0 00 BD 00 04 D9 3C B7 ...
        ^--- damage, index = type
            ^--- $B725 radius, index = type
```

so: **type 1 → dmg 1 / radius 8; type 2 → dmg 2 / radius 9; type 3 → dmg 3 / radius 16.**
`$B725[4]` onwards is already `sub_B729`'s opcodes (`A0 00 BD 00 04 …`). Both tables
are boxed in by code on both sides — hence the slot-gated patch in §4.2, which
relocates nothing.

---

## 2. The selection UI

### 2.1 Why LEFT/RIGHT and not more menu lines

`pb2_weapons.md` §5 lists five fixed-size tables the suit menu is wired to
(`$D2B9 = 00 01 02 04 08`, the portrait pointer list `$D619`, the drain-rate table
`$D326`, …). Adding menu *entries* means growing all five in lockstep, and `$D619`
is consumed through the pinned `$CA0B` inline-table mechanism. So: **do not touch the
suit list at all.** Add an orthogonal axis.

* UP / DOWN — unchanged, cycles the suit (`$9A`).
* LEFT / RIGHT — cycles `RT_WEAPON` 0..8, where 0 = Power Blade 2's own weapon.

Two independent selections, zero table growth.

### 2.2 Patch site

```
CDBE  A5 4D     LDA $4D
CDC0  F0 0C     BEQ $CDCE          ; menu not open
CDC2  A5 27     LDA $27
CDC4  C9 07     CMP #$07
CDC6  D0 03     BNE $CDCB
CDC8  ...
CDCB  4C 59 D2  JMP $D259          ; <-- ORIGINAL: 4C 59 D2
                                   ;     REPLACE : 4C 80 72   (JMP RT_WSEL)
```

`loc_D259` itself (unchanged) guards `$27 == 3`, `($A0 | $9E) != 0`, `$56 != 0`, then:

```
D259  ... guards ...
D269  A5 48     LDA $48
D26B  29 08     AND #$08           ; UP
D26D  D0 07     BNE $D276
D26F  A5 48     LDA $48
D271  29 04     AND #$04           ; DOWN
D273  D0 2B     BNE $D2A0
D275  60        RTS
```

### 2.3 `RT_WSEL`

```asm
; ---- $7280 ----------------------------------------------------------------
; Entered by JMP from $CDCB. Work RAM is always mapped, bank 14 is fixed.
RT_WSEL:
        lda $27
        cmp #$03
        bne to_D259            ; only during normal gameplay
        lda $48
        and #$02               ; LEFT newly pressed
        bne prev
        lda $48
        and #$01               ; RIGHT newly pressed
        bne next
to_D259:
        jmp $D259              ; nothing of ours -> stock UP/DOWN handling

next:   ldx RT_WEAPON
        inx
        cpx #$09
        bcc store
        ldx #$00
        beq store              ; always
prev:   ldx RT_WEAPON
        dex
        bpl store
        ldx #$08
store:  stx RT_WEAPON
        lda #$10
        sta RT_WCD             ; short lockout so the switch cannot double-fire
        jsr $D768              ; free shot slots 1..5  (see below)
        jsr RT_SETCHR          ; point R3 at this weapon's CHR bank
        jsr RT_WHUD            ; repaint the indicator
        lda #$30
        jmp $ECE8              ; the same blip the suit cycle plays; RTS from there
```

`$D768` is the right "clear the shots" call:

```
D768  A2 01     LDX #$01
D76A  20 D4 D6  JSR $D6D4
D76D  E8        INX
D76E  E0 06     CPX #$06
D770  D0 F8     BNE $D76A
D772  60        RTS
```

(`$D773`, the kill-all, starts at `LDX #$06` and would leave the shots alone.)

`sub_D6D4` clears fields 0,1,2,3,4,5,6,7,8,9,10,11,12,13,17,16,15,14,19,20,21,22,23,24
— i.e. everything a shot uses except `$058C` (field 18). **Our handlers must therefore
initialise `$058C,X` explicitly at spawn.** [observed: `$058C` is absent from the
`sub_D6D4` store list]

### 2.4 CHR follow-up

```asm
; ---- $72C0 ----------------------------------------------------------------
RT_SETCHR:                     ; keep MMC3 R3 pointing at the right 1 KB bank
        ldx RT_WEAPON
        beq stock
        lda RT_WCHR-1,x
        sta $45
        rts
stock:  lda $9A
        beq unsuited
        lda #$12
        bne done
unsuited:
        lda #$11
done:   sta $45
        rts
```

`$45` is the shadow of MMC3 R3, written to the hardware by the bank uploader at
`$EC11` (`LDY #$03 / STY $8000 / LDA $45 / STA $8001` in that unrolled block).
The stock game loads it as an immediate at four sites — see §3.2.

Because several of those sites fire on stage entry, respawn and suit change,
`RT_SETCHR` also runs once per frame from a hook on the energy tick:

```
CEFD  20 BE D2  JSR $D2BE      ; ORIGINAL: 20 BE D2
                               ; REPLACE : 20 A0 72   (JSR RT_TICK)
```

```asm
; ---- $72A0 ----------------------------------------------------------------
RT_TICK:
        jsr RT_SETCHR
        jmp $D2BE
```

`$CEFD` runs unconditionally every gameplay frame (verified in the `$CEF0-$CF1F`
listing: it sits between `JSR $CA3A` and `JSR $D23A` in the main loop body).

### 2.5 The status-bar indicator

Free nametable space, **proved by experiment**: the HUD row containing the energy bar
has seven unused tiles at PPU **`$26D7-$26DD`**. Method: the CIRAM of a `-vram` dump
was edited at those offsets and re-rendered with `work/tools/vram.py`; the diff
bounding box against the unedited render was `(184, 192, 240, 193)` — exactly columns
23..29 of that row, nothing else moved.

The attribute byte covering that area is `$00`, so those tiles use BG palette 0
(`0F 27 16 38`) and **no attribute write is needed**.

HUD font mapping (from the existing HUD writers): `A = $01 … Z = $1A`, digit *d* = `$20 + d`.
So `W = $17`.

Indicator = two tiles at `$26D8`,`$26D9`: `"W"` then the weapon digit `0..8`.

```asm
; ---- $7300 ----------------------------------------------------------------
; Push one VRAM command-1 run onto the queue at $0300 (write pointer $1F).
;   $CD18 = push command $01     $CD0B = push one raw byte     $CD09 = push $FF
RT_WHUD:
        jsr $CD18              ; cmd 1 = $FF-terminated horizontal run
        lda #$D8
        jsr $CD0B              ; address low
        lda #$26
        jsr $CD0B              ; address high
        lda #$17               ; 'W'
        jsr $CD0B
        lda RT_WEAPON
        clc
        adc #$20               ; '0'..'8'
        jsr $CD0B
        jmp $CD09              ; $FF terminator; RTS from there
```

The queue is drained by the NMI consumer at `$CC47`.

Repaint after every full HUD rebuild — step 3 of the `$D64F` state machine:

```
D67B  20 8D D5  JSR $D58D
D67E  20 C1 D5  JSR $D5C1      ; ORIGINAL: 20 C1 D5
                               ; REPLACE : 20 30 73   (JSR RT_HUDW)
D681  A9 00     LDA #$00 / 85 1B STA $1B / E6 1A INC $1A / 60 RTS
```

```asm
; ---- $7330 ----------------------------------------------------------------
RT_HUDW:
        jsr $D5C1              ; the stock 3x3 portrait
        jmp RT_WHUD
```

---

## 3. The eight weapons as spawnable behaviours

### 3.0 Common infrastructure

**Object types.** Player shots are dispatched by `sub_A573`, not by the pinned `$8080`
table, so we are free to choose. Use `$10..$1B` — above PB2's shot types 1/2/3 and
above the 0..9 range player 2's whoosh counter writes into slot 5's `$0400`.

| type | weapon | role |
|---|---|---|
| `$10` | 1 | orbit whip |
| `$11` | 2 | grenade bullet |
| `$12` | 2 | grenade blast |
| `$13` | 3 | burst-rifle shot |
| `$14` | 4 | bouncer |
| `$15` | 5 | fan pellet |
| `$16` | 6 | napalm, airborne |
| `$17` | 6 | napalm, crawling |
| `$18` | 7 | flame hitbox |
| `$19` | 8 | boomerang, outbound |
| `$1A` | 8 | boomerang, returning |

Patch at bank 9 `$A573`:

```
ORIGINAL  A573: C9 03 D0 03 4C FB A7     (7 bytes)
REPLACE   A573: 4C 80 74 EA EA EA EA     (JMP RT_SHOT + 4 NOP)
```

`$A573` is only ever reached by `JSR` from `$A56A`; no branch inside the loop targets
`$A574..$A579`, so the four `NOP`s are unreachable padding, and `$A57A` is untouched.

```asm
; ---- $7480 ----------------------------------------------------------------
; A = object type, X = slot. Reached by JSR from $A56A, bank 9 mapped.
RT_SHOT:
        cmp #$10
        bcc stock
        cmp #$1C
        bcs stock
        sec
        sbc #$10
        jsr $C84F              ; inline word table follows; $CA0B pops our return
        .word RT_W1            ; $10  orbit whip
        .word RT_W2A           ; $11  grenade bullet
        .word RT_W2B           ; $12  grenade blast
        .word RT_W3            ; $13  burst shot
        .word RT_W4            ; $14  bouncer
        .word RT_W5            ; $15  fan pellet
        .word RT_W6A           ; $16  napalm airborne
        .word RT_W6B           ; $17  napalm crawling
        .word RT_W7            ; $18  flame hitbox
        .word RT_W8A           ; $19  boomerang out
        .word RT_W8B           ; $1A  boomerang return
        .word RT_KILLNOW       ; $1B  spare
stock:  cmp #$03
        bne unsuited
        jmp $A7FB
unsuited:
        jmp $A57A
```

Stack accounting, which the whole design depends on:

* `$A56A JSR $A573` pushes `$A56C`.
* `$A573` → `JMP RT_SHOT`: no extra push.
* `JSR $C84F` pushes the inline-table address; `$CA0B` pops it and `JMP`s.
* So a handler is entered with **`$A56C` on top of the stack**; its `RTS` returns to
  `$A56D`, exactly like the stock `$A7FB`.
* A handler doing `JSR RT_MOVE` is therefore **two** words deep — the same depth
  `$A7B9`'s `PLA / PLA / JMP $C810` assumes.

Shared helpers:

```asm
; ---- $7E00 ----------------------------------------------------------------
RT_MOVE:                       ; X = slot. Integrate; kill if the object left the world.
        jsr $C8E8              ; -> $FB7B -> $FA08, generic 24-bit integrator
        lda $04B0,x            ; Y high
        ora $04F2,x            ; X high
        beq mv_ok
        pla                    ; drop RT_MOVE's return
        pla                    ; drop $A56C
        jmp $C810              ; -> sub_D6D4; its RTS lands at $A56D
mv_ok:  rts

RT_DIE:                        ; JSR'd from a handler: identical depth to RT_MOVE
        pla
        pla
        jmp $C810
RT_KILLNOW:                    ; JMP'd into from RT_SHOT: one level shallower
        jmp $C810

RT_SOLID:                      ; A = signed dx, Y = signed dy, X = slot
        jmp $C888              ; -> $F342; returns with N set when the cell is solid

RT_TICKLIFE:                   ; X = slot; RTS normally, never returns when expired
        dec $05A2,x
        bne tl_ok
        pla
        pla
        pla                    ; also drop RT_TICKLIFE's own frame
        jmp $C810
tl_ok:  rts
```

(`RT_TICKLIFE` pops three because it is one level below a handler; handlers that
prefer clarity can inline `DEC $05A2,x / BNE :+ / JSR RT_DIE`.)

**Velocity table.** Rather than a runtime multiply, every weapon carries a
pre-computed 8-direction velocity block. Layout, 32 bytes per weapon:

```
RT_VEL + (weapon-1)*32 + dir*4 + 0   VX fraction  -> $0576,X
                              + 1   VX integer   -> $0560,X
                              + 2   VY fraction  -> $054A,X
                              + 3   VY integer   -> $0534,X
```

Unit vectors used to build it (PB2's own direction set, diagonal = 0.707):

```
dir   0 R      1 L      2 U      3 D      4 UR     5 UL     6 DR     7 DL
UX  +1.000  -1.000    0.000    0.000  +0.707  -0.707  +0.707  -0.707
UY   0.000   0.000  -1.000  +1.000  -0.707  -0.707  +0.707  +0.707
```

`build.py` generates the block from a per-weapon speed in px/frame; e.g. weapon 3 at
7.0 px/f gives `dir 0 = 00 07 00 00`, `dir 1 = 00 F9 00 00`, `dir 4 = 7E 04 82 FB`
(4.95 → `$04.7E`, −4.95 → `$FB.82`).

**Common spawner:**

```asm
; ---- $7420 ----------------------------------------------------------------
; X = slot, A = object type, RT_WSPR = direction 0..7.
; $A4FD has already copied the player position + muzzle offset into the slot.
RT_SPAWN:
        sta $0400,x
        lda RT_WEAPON
        sec
        sbc #$01
        asl a
        asl a
        asl a
        asl a
        asl a                  ; * 32     (max 7*32 = 224, fits)
        sta RT_WTMP
        lda RT_WSPR
        asl a
        asl a                  ; * 4
        clc
        adc RT_WTMP
        tay
        lda RT_VEL+0,y : sta $0576,x
        lda RT_VEL+1,y : sta $0560,x
        lda RT_VEL+2,y : sta $054A,x
        lda RT_VEL+3,y : sta $0534,x
        lda #$00
        sta $058C,x            ; sub_D6D4 does NOT clear field 18 -- do it here
        sta $04DC,x
        sta $051E,x
        lda RT_WSPR
        sta $05CE,x
        ldy RT_WEAPON
        lda RT_WLIFE-1,y
        sta $05A2,x
        lda RT_WMSPR-1,y
        sta $0442,x
        rts
```

### 3.1 Sprites — which existing metasprite record carries which weapon

The metasprite pointer tables for slots 0-5 are `$8148` (lo) / `$81B4` (hi) in bank 6,
**exactly 108 entries** (`$8148 + 216 = $81B4 + 108 = $8220`, where the record data
starts). Growing them means relocating both and fixing the composer operands at
`$809F` (`B9 48 81`) and `$80A4` (`B9 B4 81`).

**We do not need to.** The records PB2 already uses for its own shots reference
precisely pattern tiles `$50-$5F`, and that 16-tile window is exactly the region we
control per weapon (§3.2). Decoded records:

```
$3E @$875A n=4  (dy -15, t $51, a $02, dx -8)(dy 0, t $51, a $82, dx -8)
                (dy -15, t $53, a $02, dx  0)(dy 0, t $53, a $82, dx  0)   16x32, V-mirrored
$3F @$876B n=4  t $55 $57 $59 $5B, attr $02                                32x16
$40 @$8779 n=4  t $5D $5F $5F $5D, attr $82/$C2                            32x16, H-mirrored
$41 @$8788 n=4  t $55 $57 $5B $59, attr $82                                32x16
$42 @$8799 n=4  t $5D $5F $5F $5D, attr $02/$42                            32x16, H-mirrored
$43 @$87A8 n=2  t $71 $71, attr $02/$42                                    16x16 (tiles $70-$71)
$44 @$87B1 n=2  t $73 $73, attr $02/$42                                    16x16 (tiles $72-$73)
$45 @$87BA n=2  (dy -8, t $51, a $00, dx -8)(dy -8, t $53, a $00, dx 0)    16x16, plain
$46 @$87C2 n=2  t $59 $5B, attr $00                                        16x16, plain
$47 @$87CA n=2  t $5D $5F, attr $00                                        16x16, plain
$48 @$87D2 n=2  t $5B $59, attr $40                                        16x16, H-flipped
```

In 8×16 sprite mode an odd tile byte `$5n` addresses pattern pair `$5n-1 / $5n` in
pattern table 1. So records `$45`, `$46`, `$47` give three independent plain 16×16
carriers, backed by pattern tiles `$50-$53`, `$58-$5B`, `$5C-$5F`; `$3E` gives a 16×32;
`$3F`/`$41` give a 32×16 over `$54-$5B`; `$40`/`$42` give a mirrored 32×16 over `$5C-$5F`.
Avoid `$43`/`$44` — tiles `$70-$73` sit at bank offset `$300-$33F`, outside the window
that already differs between banks `$11` and `$12`, i.e. they are shared art.

Assignment:

| weapon | on-screen form | record | pattern tiles it needs |
|---|---|---|---|
| 1 orbit whip | 16×16 ball, 2-frame flicker | `$45` / `$46` alternating | `$50-$53`, `$58-$5B` |
| 2 bullet | 16×16 (Solbrain draws 8×16; right half blank) | `$45` | `$50-$53` |
| 2 blast st.1 | 16×32 | `$3E` | `$50-$53` |
| 2 blast st.2/3 | 32×16 (**approximation**, Solbrain is 32×32) | `$40`, then `$42` | `$5C-$5F` |
| 3 shot | 16×16 | `$45` | `$50-$53` |
| 3 muzzle flash | 16×16 | `$46` | `$58-$5B` |
| 4 bouncer | 16×16 | `$45` | `$50-$53` |
| 5 fan pellet | 16×16 | `$45` | `$50-$53` |
| 6 napalm air | 16×16 | `$45` | `$50-$53` |
| 6 napalm crawl | 16×16 | `$46` | `$58-$5B` |
| 7 flame burst | 32×16 | `$41` | `$54-$5B` |
| 7 flame sustain | 16×16 | `$47` | `$5C-$5F` |
| 8 boomerang | 16×16, H-flip on the return leg | `$45` out, `$48` back | `$50-$53`, `$58-$5B` |

Every weapon's art therefore fits inside pattern tiles `$50-$5F` — 16 tiles, 256 bytes,
one contiguous slice of one 1 KB CHR bank. **No metasprite record is added or changed.**

### 3.2 CHR — the MMC3 registers and the constant bank

Question as asked: *which MMC3 registers hold the player's / projectile sprite tiles,
and is there a spare 1 KB bank that is constant across stages?*

MMC3 with CHR A12 inversion off: `$0000-$07FF` = R0 (2 KB), `$0800-$0FFF` = R1 (2 KB),
`$1000-$13FF` = R2, `$1400-$17FF` = R3, `$1800-$1BFF` = R4, `$1C00-$1FFF` = R5.
PB2 runs 8×16 sprites with pattern table 1 for sprites, so **sprites live in R2..R5**.

Sampled per-scanline (`Vram.chr_scan`) across four stages:

| register | window | contents | stage-dependent? |
|---|---|---|---|
| R2 (`$44`) | `$1000-$13FF`, tiles `$00-$3F` | player body, swapped every few frames for animation | no, but constantly re-banked |
| **R3 (`$45`)** | **`$1400-$17FF`, tiles `$40-$7F`** | **player extras + player projectiles** | **no — `$11` unsuited, `$12` suited, in every stage tested** |
| R4 (`$46`) | `$1800-$1BFF` | enemies | yes, per area |
| R5 (`$47`) | `$1C00-$1FFF` | enemies / effects | yes, per area |

**R3 is the answer**: constant across stages, holding exactly the projectile art.
Banks `$11` and `$12` are byte-identical except at bank offset `$100-$1FF`
— that is PPU `$1500-$15FF` = pattern tiles `$50-$5F` — which is precisely the
window §3.1 uses. Nothing outside a shot's own metasprite reads those 16 tiles.

The four immediate loads of `$45` in bank 14 that must become table-driven:

```
CE06  A9 11     LDA #$11 / 85 45 STA $45     ; area / stage entry
D036  A9 11     LDA #$11 / 85 45 STA $45     ; respawn
D290  A9 11     LDA #$11 / ...               ; menu, unsuited
D294  A9 12     LDA #$12 / ...               ; menu, suited
D319  A9 11     LDA #$11 / ...               ; suit falls off (out of energy)
```

Replacing each `A9 nn 85 45` with `20 c0 72 EA` (`JSR RT_SETCHR` + `NOP`) makes all
five obey `RT_WEAPON`. `RT_TICK` (§2.4) is the belt-and-braces per-frame resync.

**Where the eight new banks come from.** `work/build/PB3.nes` has 256 CHR banks — the
MMC3 maximum — and is nominally full, but 18 are duplicates: banks
`131, 134, 135, 138, 139, 143, 146, 147, 151, 154, 155, 158, 159, 163, 226, 227`
are all-zero and byte-identical to PB2's blanking bank `100`, and `156 == 136`.
Reclaim the first eight of the all-zero set and repoint any level reference to bank 100:

```python
RT_WCHR_VALUES = [131, 134, 135, 138, 139, 143, 146, 147]   # weapon 1..8 -> R3
```

Each is built as: `bank 17 ($11)` verbatim, with bytes `$100-$1FF` replaced by that
weapon's 16 projectile tiles, taken from `work/re/sol_weapon_tiles.bin` and repacked
into pattern order `$50..$5F` per the table in §3.1. In `build.py`:

```python
def weapon_chr(chr_rom, sol_tiles, groups):
    """groups = [(bin_offset, n_tiles, dest_pattern_tile)] -> one 1 KB CHR bank."""
    bank = bytearray(chr_rom[17*0x400 : 18*0x400])
    for src, n, dst in groups:
        for i in range(n):
            off = (dst + i - 0x40) * 16            # bank-internal offset
            bank[off:off+16] = sol_tiles[src + i*16 : src + i*16 + 16]
    return bytes(bank)
```

The satellite-robot tiles in `sol_weapon_tiles.bin` are **not** copied — PB3 has no
satellite; the player throws directly. That drops the per-weapon tile count from
up to 20 down to at most 14, which is why 16 tiles suffice.

**Palette caveat.** Solbrain draws these with sprite palettes `0F 21 30` (pal 1) and
`06 27 38` (pal 2). PB2's sprite palettes differ. The art will be recoloured to
whichever palette index the spawner leaves in `$042C,X` bits 0-1. This is cosmetic and
listed as an accepted deviation.

### 3.3 The trigger

Patch at bank 9 `$A1F8`:

```
ORIGINAL  A1F8: A5 48 29 40 F0 27        (6 bytes)
REPLACE   A1F8: 4C 80 73 EA EA EA        (JMP RT_FIRE + 3 NOP)
```

`$A1FE` is preserved and remains a valid re-entry point for the stock path.

```asm
; ---- $7380 ----------------------------------------------------------------
RT_FIRE:
        lda RT_WCD
        beq nocd
        dec RT_WCD
nocd:   lda RT_WEAPON
        bne solbrain
        lda $48                ; --- stock path, byte-for-byte ---
        and #$40
        beq nofire
        jmp $A1FE
nofire: rts

solbrain:
        jsr RT_TRIG            ; C set = this weapon wants to fire now
        bcc nofire
        ldx RT_WEAPON
        jsr RT_PAY             ; C set = the energy pool is empty
        bcs nofire
        jsr $A3D9              ; allocate -> X (PB3: slots 1..4)
        bcs nofire
        stx $25
        jsr $A403              ; X = direction 0..7, Y = pose
        tya
        bmi nofire
        sty $0458
        lda $A4EE,y
        tay
        jsr $B017              ; throw pose
        lda $0416
        ora #$80
        sta $0416
        stx RT_WSPR            ; remember the direction
        ldx $25
        lda $042C
        and #$60
        sta $042C,x            ; inherit facing + palette
        jsr $A4FD              ; muzzle offset AND position copy
        lda RT_WEAPON
        sec
        sbc #$01
        jsr $C84F              ; per-weapon spawner; never returns here
        .word RT_S1
        .word RT_S2
        .word RT_S3
        .word RT_S4
        .word RT_S5
        .word RT_S6
        .word RT_S7
        .word RT_S8

; --- trigger policy -------------------------------------------------------
RT_TRIG:
        ldy RT_WEAPON
        lda RT_WAUTO-1,y
        beq edge
        lda $4A                ; HELD  (see correction C8)
        bne test
edge:   lda $48                ; NEWLY PRESSED
test:   and #$40
        beq trig_no
        lda RT_WCD
        bne trig_no
        ldy RT_WEAPON
        lda RT_WCDT-1,y
        sta RT_WCD
        sec
        rts
trig_no:
        clc
        rts
```

### 3.4 Weapon 1 — orbit whip (type `$10`)

Solbrain: kinematic, 30 px reach, one revolution per 16 frames, 51-frame life,
1 alive, damage 1, ignores terrain. **Fully faithful.**

```asm
RT_S1:  lda #$10
        jsr RT_SPAWN           ; life 51, metasprite $45
        lda #$22
        jmp $C81C              ; throw sound; RTS from there

RT_W1:  ldy $058C,x            ; angle index 0..15
        lda $04C6              ; player Y pixel (slot 0)
        clc
        adc RT_ORBY,y
        sta $04C6,x
        lda $0508              ; player X pixel
        clc
        adc RT_ORBX,y
        sta $0508,x
        lda #$00
        sta $04B0,x            ; keep the high bytes at 0 -- $B5E3 requires it
        sta $04F2,x
        iny
        tya
        and #$0F
        sta $058C,x
        lda $05A2,x
        and #$02               ; 2-frame art flicker, like the original
        beq :+
        lda #$46
        bne :++
:       lda #$45
:       sta $0442,x
        dec $05A2,x
        bne :+
        jsr RT_DIE
:       rts
```

Tables (16 signed bytes each, radius 30):

```
RT_ORBX = 1E 1C 15 0B 00 F5 EB E4 E2 E4 EB F5 00 0B 15 1C
RT_ORBY = 00 0B 15 1C 1E 1C 15 0B 00 F5 EB E4 E2 E4 EB F5
```

### 3.5 Weapon 2 — grenade shot (types `$11` → `$12`)

Solbrain: 4.50 px/f standing / 4.00 crouching, ~20 f, 1 alive, **explodes on walls**,
3-stage blast. **Faithful except the blast's stages 2-3 are 32×16 instead of 32×32.**

```asm
RT_S2:  lda #$11
        jsr RT_SPAWN           ; speed 4.5, life 20, metasprite $45
        lda #$22
        jmp $C81C

RT_W2A:                        ; bullet
        lda #$00
        ldy #$00
        jsr RT_SOLID           ; probe the cell the bullet is standing in
        bmi detonate
        jsr RT_MOVE
        dec $05A2,x
        bne :+
detonate:
        lda #$12
        sta $0400,x
        lda #$00
        sta $0560,x
        sta $0576,x
        sta $0534,x
        sta $054A,x
        sta $058C,x            ; blast stage 0
        lda #$04
        sta $05A2,x
        lda #$3E               ; 16x32
        sta $0442,x
        lda #$1B
        jsr $C81C              ; explosion sound
:       rts

RT_W2B:                        ; blast
        dec $05A2,x
        bne w2b_out
        inc $058C,x
        ldy $058C,x
        cpy #$03
        bcs w2b_die
        lda RT_W2LIFE,y
        sta $05A2,x
        lda RT_W2SPR,y
        sta $0442,x
w2b_out:
        rts
w2b_die:
        jsr RT_DIE
        rts

RT_W2LIFE = 04 04 05
RT_W2SPR  = 3E 40 42
```

### 3.6 Weapon 3 — burst rifle (type `$13`)

Solbrain: 7 px/f, 8 shots at one per 2 frames, 80-frame cycle, pierces `$7F`
(effectively infinite), off-screen death.

**Not faithful — max alive is 4, not 8.** PB3's shot pool is slots 1..4 (`RT_FINDSHOT`
stops at `P2_SLOT = 5`), and PB2's own `$A3D9` cap `$10 = 1 + $99` sits on top of that.
Closest approximation: **a 4-shot burst at one per 2 frames on an 80-frame cycle.**
At 7 px/f a shot clears the screen in about 20 frames, so a 4-deep pool keeps the
stream visually continuous; only the peak density differs.

Pierce comes free — see correction C7.

```asm
RT_S3:  lda #$13
        jsr RT_SPAWN           ; speed 7.0, life 0 (= unlimited, killed off-screen)
        lda RT_WPH
        bne :+
        lda #$50               ; 80-frame cycle starts now
        sta RT_WPH
:       lda #$22
        jmp $C81C

RT_W3:  jsr RT_MOVE            ; RT_MOVE kills it the moment the high byte goes non-zero
        rts
```

Burst pacing lives in the trigger: `RT_WAUTO[3] = 1`, `RT_WCDT[3] = 2`, plus a
per-weapon gate driven by `RT_WPH` (decremented in `RT_TICK`) that blocks firing
outside the first 8 frames of each 80-frame window:

```asm
; inside RT_TICK, before JMP $D2BE
        lda RT_WEAPON
        cmp #$03
        bne :+
        lda RT_WPH
        beq :+
        dec RT_WPH
:       ...
```

and in `RT_TRIG`, for weapon 3 only: `lda RT_WPH / cmp #$48 / bcc trig_no`
(fires while `RT_WPH` is in `$50..$49`, i.e. the first 8 frames).

### 3.7 Weapon 4 — bouncer (type `$14`)

Solbrain: 5.19/3.00 px/f, bounces off terrain, dies after 7 bounces, 2 alive,
edge-triggered on B, no gravity. **Fully faithful.**

```asm
RT_S4:  lda #$14
        jsr RT_SPAWN           ; speed 5.19, metasprite $45
        lda #$07
        sta $05A2,x            ; reuse the lifetime field as the bounce budget
        lda #$22
        jmp $C81C

RT_W4:  lda $0560,x            ; probe one step ahead horizontally
        bpl :+
        lda #$F8
        bne :++
:       lda #$08
:       ldy #$00
        jsr RT_SOLID
        bpl noxhit
        jsr RT_NEGX
        jsr RT_BOUNCE
noxhit: lda #$00
        ldy $0534,x            ; probe one step ahead vertically
        bpl :+
        ldy #$F8
        bne :++
:       ldy #$08
:       jsr RT_SOLID
        bpl noyhit
        jsr RT_NEGY
        jsr RT_BOUNCE
noyhit: jsr RT_MOVE
        rts

RT_BOUNCE:
        dec $05A2,x
        bne :+
        pla                    ; drop RT_BOUNCE's frame ...
        pla
        pla                    ; ... plus the handler's and $A56C
        jmp $C810
:       lda #$1C
        jmp $C81C              ; ricochet sound

RT_NEGX:                       ; two's-complement negate the 16-bit X velocity
        sec
        lda #$00
        sbc $0576,x
        sta $0576,x
        lda #$00
        sbc $0560,x
        sta $0560,x
        rts
RT_NEGY:
        sec
        lda #$00
        sbc $054A,x
        sta $054A,x
        lda #$00
        sbc $0534,x
        sta $0534,x
        rts
```

`RT_SOLID` = `JMP $C888` → `$F342`: A = signed X offset, Y = signed Y offset relative
to the object in slot X; returns with bit 7 of A set when the cell is solid.

### 3.8 Weapon 5 — charge fan (type `$15`)

Solbrain: one pellet every 2 frames while charging, 5-8 px/f pulsing, lifetime equal
to the charge level 1..16, up to 8 alive, sweeping cone.

**Not faithful — max alive is 4, not 8.** Everything else maps cleanly, and PB2 already
has the charge machinery: `$54` is the charge counter and `$8D`/`$8E`/`$8F` the
thresholds (`$A247-$A258`). Approximation: **4-pellet cone.**

```asm
RT_S5:  lda #$15
        jsr RT_SPAWN
        lda $54                ; PB2's own charge counter
        lsr a
        lsr a
        lsr a
        lsr a
        clc
        adc #$01               ; lifetime = 1..16
        sta $05A2,x
        ldy RT_WPH             ; cone sweep index, 0..7
        lda RT_FANDY,y
        clc
        adc $0534,x            ; skew the Y velocity
        sta $0534,x
        inc RT_WPH
        lda RT_WPH
        and #$07
        sta RT_WPH
        lda #$22
        jmp $C81C

RT_W5:  jsr RT_MOVE
        dec $05A2,x
        bne :+
        jsr RT_DIE
:       rts

RT_FANDY = FE FF FF 00 00 01 01 02      ; -2 .. +2 px/f, an eight-step sweep
```

`RT_WAUTO[5] = 1`, `RT_WCDT[5] = 2`.

### 3.9 Weapon 6 — napalm (types `$16` → `$17`)

Solbrain: scatter at 4.0-7.5 px/f for 6-7 frames, then crawl along the floor at
1.0 px/f for up to 134 frames, 4 alive, one per 8 frames while held.
**Fully faithful** — 4 alive fits PB3's pool exactly, and the floor probe is
`$C888` again.

```asm
RT_S6:  lda #$16
        jsr RT_SPAWN           ; speed 5.5 nominal
        lda RT_WPH             ; scatter: perturb the speed per pellet
        and #$03
        tay
        lda RT_NAPX,y
        clc
        adc $0560,x
        sta $0560,x
        inc RT_WPH
        lda #$06
        sta $05A2,x
        lda #$22
        jmp $C81C

RT_W6A:                        ; airborne
        jsr RT_MOVE
        dec $05A2,x
        bne :+
        lda #$17
        sta $0400,x
        lda #$86               ; 134 frames
        sta $05A2,x
        lda #$46
        sta $0442,x
        lda $0560,x            ; keep the horizontal sign, crawl at 1 px/f
        bmi :++
        lda #$01
        bne :+++
:       rts
:       lda #$FF
:       sta $0560,x
        lda #$00
        sta $0576,x
        sta $0534,x
        sta $054A,x
        rts

RT_W6B:                        ; crawling
        lda #$00
        ldy #$0A
        jsr RT_SOLID           ; floor still under us?
        bmi onfloor
        lda #$01               ; no floor: fall one pixel
        clc
        adc $04C6,x
        sta $04C6,x
onfloor:
        lda $0560,x            ; wall ahead?
        bpl :+
        lda #$F8
        bne :++
:       lda #$08
:       ldy #$00
        jsr RT_SOLID
        bpl :+
        jsr RT_NEGX
:       jsr RT_MOVE
        dec $05A2,x
        bne :+
        jsr RT_DIE
:       rts

RT_NAPX = 00 01 FF 02
```

`RT_WAUTO[6] = 1`, `RT_WCDT[6] = 8`.

### 3.10 Weapon 7 — flamethrower / slash (type `$18`)

Solbrain: no projectile at all — a static hitbox for ~9 frames, damage **2**,
at least 30 frames between swings.

**Faithful in every respect except one:** Solbrain widens the *main pool* object's
hitbox for the swing, whereas PB2's attacker radius comes from `$B725,type` (a single
byte, both axes). Approximation: a dedicated object with radius `$14` (20 px) in
`RT_WRAD`, glued to the player every frame.

```asm
RT_S7:  lda #$18
        jsr RT_SPAWN
        lda #$09
        sta $05A2,x
        lda #$41               ; 32x16 flame burst
        sta $0442,x
        lda #$00               ; the hitbox does not move on its own
        sta $0560,x
        sta $0576,x
        sta $0534,x
        sta $054A,x
        lda #$1D
        jmp $C81C

RT_W7:  lda $04C6              ; follow the player
        sta $04C6,x
        lda $0508
        clc
        ldy $042C
        bmi :+                 ; (bit7 never set on the player; bit6 is facing)
:       lda $042C
        and #$40
        beq faceright
        lda $0508
        sec
        sbc #$14
        bcs :+
        lda #$00
:       sta $0508,x
        bne setattr
faceright:
        lda $0508
        clc
        adc #$14
        sta $0508,x
setattr:
        lda #$00
        sta $04B0,x
        sta $04F2,x
        lda $042C
        and #$60
        sta $042C,x
        lda $05A2,x
        cmp #$05
        bcs :+
        lda #$47               ; sustain frames use the smaller record
        sta $0442,x
:       dec $05A2,x
        bne :+
        jsr RT_DIE
:       rts
```

`RT_WCDT[7] = 30`, `RT_WDMG[7] = 2`, `RT_WRAD[7] = $14`.

### 3.11 Weapon 8 — boomerang (types `$19` → `$1A`)

Solbrain: 5,5 px/f out for 13 frames, then homing return at 3-6 px/f, pierces `$10`,
3 alive.

**Faithful with one substitution:** Solbrain's return is a true homing curve computed
from the angle to the player. PB2 has no arctangent. Approximation: **per-axis sign
homing** — each frame the velocity is snapped to ±4 px/f toward the player on whichever
axes are still more than 4 px away. Visually a chase, not a smooth arc.

PB2's own unsuited knife (`$A57A`, `$05CE` bit 7 = returning, caught at `$A764`) is the
nearest existing machinery, but its return is a fixed arc bolted to the knife's charge
tier, so a dedicated type is cleaner.

```asm
RT_S8:  lda #$19
        jsr RT_SPAWN           ; speed 5,5
        lda #$0D
        sta $05A2,x            ; 13 frames outbound
        lda #$22
        jmp $C81C

RT_W8A: jsr RT_MOVE
        dec $05A2,x
        bne :+
        lda #$1A
        sta $0400,x
        lda #$48               ; H-flipped art on the way back
        sta $0442,x
:       rts

RT_W8B: lda $0508              ; horizontal homing
        sec
        sbc $0508,x
        jsr RT_STEP
        sta $0560,x
        lda #$00
        sta $0576,x
        lda $04C6              ; vertical homing
        sec
        sbc $04C6,x
        jsr RT_STEP
        sta $0534,x
        lda #$00
        sta $054A,x
        jsr RT_MOVE
        lda $0508
        sec
        sbc $0508,x
        jsr RT_ABS
        cmp #$08
        bcs :+
        lda $04C6
        sec
        sbc $04C6,x
        jsr RT_ABS
        cmp #$08
        bcs :+
        jsr RT_DIE             ; caught
:       rts

RT_STEP:                       ; A = signed delta -> A = -4, 0 or +4
        cmp #$FC
        bcs zero
        cmp #$05
        bcc zeropos
        bpl pos
        lda #$FC
        rts
pos:    lda #$04
        rts
zeropos:
        cmp #$00
        beq zero
        lda #$04
        rts
zero:   lda #$00
        rts

RT_ABS: cmp #$80
        bcc :+
        eor #$FF
        clc
        adc #$01
:       rts
```

### 3.12 Faithfulness summary

| # | weapon | faithful? | deviation |
|---|---|---|---|
| 1 | orbit whip | **yes** | none |
| 2 | grenade shot | **near** | blast stages 2-3 drawn 32×16 instead of 32×32 (no 32×32 metasprite record exists in the slot-0-5 table) |
| 3 | burst rifle | **no** | 4 simultaneous shots instead of 8 — PB3's shot pool is slots 1..4 |
| 4 | bouncer | **yes** | none |
| 5 | charge fan | **no** | 4 simultaneous pellets instead of 8, same reason |
| 6 | napalm | **yes** | none (4 alive fits exactly) |
| 7 | slash | **near** | fixed 20 px hitbox radius; PB2 has one radius byte per type, not a per-axis box |
| 8 | boomerang | **near** | per-axis ±4 px/f sign homing instead of a true angular homing curve |
| all | — | — | sprite palettes are PB2's, not Solbrain's `0F 21 30` / `06 27 38` |

Damage and radius per weapon:

```
RT_WDMG = 01 01 01 01 01 01 02 01     ; weapon 1..8, matching sol_weapons.md §7
RT_WRAD = 0C 08 06 0A 06 08 14 0C     ; attacker hitbox radius, $B725-style
```

---

## 4. The energy hook

### 4.1 How the suits drain, and what to reuse

```
D2BE  ... gates: $27 != 6, $58 == 0, $9A != 0, ($A0 | $9E) != 0
D2D2  A5 A0     LDA $A0
D2D4  F0 27     BEQ $D2FD
D2D6  A4 9A     LDY $9A
D2D8  88        DEY
D2D9  B9 26 D3  LDA $D326,Y        ; $D326 = 03 04 04 06   drain rate per suit
      16-bit  $85:$86 -= rate
      on borrow: reload $85:$86 with $0600, DEC $A0
D2FD  A5 9E     LDA $9E            ; <<< reusable entry point
D2FF  F0 11     BEQ $D312
D301  C6 9E     DEC $9E            ; burn one spare tank
D303  20 B6 D4  JSR $D4B6          ; repaint the tank counter
      $30 = $10 ; $27 = 6 ; RTS
D30F  4C D9 D4  JMP $D4D9          ; repaint the energy bar
D312  ...       suit falls off: $9A = 0, $45 = $11, JSR $D768, JSR $D5C1, JMP $D8E4
```

`$D2FD` is exactly "burn a spare tank, or drop the suit if there are none", including
the HUD repaint. **Reuse it verbatim.** The unit of account is the 16-bit accumulator
reloaded with `$0600` = 1536 per bar unit; a full bar is `$A0 = $10` = 16 units.

### 4.2 `RT_PAY`

```asm
; ---- $7340 ----------------------------------------------------------------
; X = weapon 1..8.  Returns C set when the shot must be refused.
RT_PAY:
        lda $A0
        ora $9E
        bne have
        sec                    ; pool completely empty -> refuse to fire
        rts
have:   sec
        lda RT_ACCL
        sbc RT_WCOSTL-1,x
        sta RT_ACCL
        lda RT_ACCH
        sbc RT_WCOSTH-1,x
        sta RT_ACCH
        bcs paid               ; no borrow -> still inside the current bar unit
        lda #$00               ; reload with $0600, exactly like $D2EE
        sta RT_ACCL
        lda #$06
        sta RT_ACCH
        lda $A0
        beq tank
        dec $A0
        jsr $D4D9              ; repaint the energy bar
        jmp paid
tank:   jsr $D2FD              ; spare tank, or the suit falls off
        jsr RT_SETCHR          ; $D312 resets $45 to $11 -- put our bank back
paid:   clc
        rts
```

`RT_ACCL`/`RT_ACCH` must be initialised to `$0600` once, in the same place the suits
are granted. Add two stores to `suits_code()` in `build.py`:

```python
0xA9, 0x00, 0x8D, RT_ACCL & 0xFF, RT_ACCL >> 8,
0xA9, 0x06, 0x8D, RT_ACCH & 0xFF, RT_ACCH >> 8,
```

`$D4D9` and `$D2FD` are in bank 14, which is fixed at `$C000`, so `RT_PAY` is callable
from the bank-9 context `RT_FIRE` runs in.

### 4.3 Per-weapon cost table

Units: 1536 = one bar unit; a full bar is 16 units.

| # | weapon | cost/shot | shots per bar unit | shots per full bar | notes |
|---|---|---|---|---|---|
| 1 | orbit whip | 512 (`$0200`) | 3 | 48 | one long-lived orbiter per press |
| 2 | grenade shot | 384 (`$0180`) | 4 | 64 | |
| 3 | burst rifle | 96 (`$0060`) | 16 | 256 | 4 pellets per burst → 64 bursts |
| 4 | bouncer | 256 (`$0100`) | 6 | 96 | |
| 5 | charge fan | 64 (`$0040`) | 24 | 384 | autofire every 2 f → ~12.8 s of held fire |
| 6 | napalm | 128 (`$0080`) | 12 | 192 | autofire every 8 f → ~25.6 s |
| 7 | slash | 384 (`$0180`) | 4 | 64 | 30-frame cadence |
| 8 | boomerang | 256 (`$0100`) | 6 | 96 | |

```
RT_WCOSTL = 00 80 60 00 40 80 80 00
RT_WCOSTH = 02 01 00 01 00 00 01 01
```

### 4.4 Damage and radius patches

Both tables at `$B721`/`$B725` are boxed in by code (`$B717` boss-death data before,
`sub_B729` immediately after), so nothing is relocated. Instead both lookups are
slot-gated: an attacker in slots 1..4 with `RT_WEAPON != 0` is one of ours.

```
Damage — bank 7
ORIGINAL  B68F: B9 00 04 A8 B9 21 B7      (7 bytes)
REPLACE   B68F: 20 00 7E EA EA EA EA      (JSR RT_DMGL + 4 NOP)

Radius — bank 7
ORIGINAL  B5F0: B9 00 04 A8 B9 25 B7      (7 bytes)
REPLACE   B5F0: 20 20 7E EA EA EA EA      (JSR RT_RAD  + 4 NOP)
```

Both patch sites end with the result in A, which the next instruction stores
(`$B696 STA $17` / `$B5F7 STA $06`). Both are entered with **Y = the attacker slot**.

```asm
; ---- $7E00 ----------------------------------------------------------------
; Entered with Y = attacker slot, X = defender slot. X must survive: $B698 and
; $B606 both use it afterwards. Y may be clobbered (both call sites reload it).
RT_DMGL:
        cpy #$01
        bcc @stock             ; slot 0 is the player's own body
        cpy #$05
        bcs @stock             ; slot 5+ is not a player-1 shot
        lda RT_WEAPON
        beq @stock             ; LDA, not LDY -- @stock still needs Y = attacker slot
        tay
        lda RT_WDMG-1,y
        rts
@stock: lda $0400,y
        tay
        lda $B721,y
        rts

; ---- $7E20 ----------------------------------------------------------------
RT_RAD: cpy #$01
        bcc @stock
        cpy #$05
        bcs @stock
        lda RT_WEAPON
        beq @stock             ; LDA, not LDY -- @stock still needs Y = attacker slot
        tay
        lda RT_WRAD-1,y
        rts
@stock: lda $0400,y
        tay
        lda $B725,y
        rts
```

Both routines index the override tables through **Y**, never X, so the defender slot
in X is untouched — the one place in this plan where getting register discipline
wrong would produce a silent, hard-to-find bug.

Note the `cpy #$05` bound: `RT_FINDSHOT` caps the allocator at `P2_SLOT = 5`, so
player-1 shots occupy slots 1..4 and slot 5 is player 2's body, which must keep the
stock lookup.

---

## 5. Integration order

Each step is independently testable and leaves the ROM playable.

| # | change | emulator check that proves it |
|---|---|---|
| 1 | Add `RT_WEAPON`..`RT_WTMP` at `$6078-$607F` and the tables at `$6E00-$6FFF` to `build.py`. No code patches yet. | `nesemu … -ramdump` after boot; bytes `$6078-$607F` are `00`, and `$6E00-$6FFF` matches the generated tables byte-for-byte. |
| 2 | Build the eight CHR banks and write them over 131/134/135/138/139/143/146/147; repoint any level reference to bank 100. | `python3 - <<< "compare CHR bank 131 offset $100-$1FF against the repacked sol tiles"`. Then boot every stage with `-vram` and confirm the render is pixel-identical to the pre-patch build (nothing referenced those banks). |
| 3 | Patch `$CDCB` → `RT_WSEL`; add `RT_WSEL` **without** the CHR/HUD calls (just the counter and `$D768`). | `-trace -watch 6078`; open the menu, press RIGHT eight times and LEFT once: `WATCH f,72xx,16,6078,01 … 08 … 07`. UP/DOWN still cycles suits (`-watch 9A`). |
| 4 | Add `RT_WHUD` and the `$D67E` → `RT_HUDW` patch. | `-vram` dump with `RT_WEAPON = 3`; `work/tools/vram.py` render shows `W3` at columns 24-25 of the HUD row; diff bbox against `RT_WEAPON = 0` is confined to `(192,192,208,200)`. |
| 5 | Add `RT_SETCHR`, `RT_TICK`, the `$CEFD` hook and the five `$45` immediates. | `-vram`; `Vram.chr_scan[110][5]` (the `$1400` slot) reads `131` with weapon 1 selected, `17` with weapon 0. Cycle weapons on one screen and confirm the value tracks. Also confirm it survives a stage transition and a death. |
| 6 | Patch `$A573` → `RT_SHOT` with **only** the `stock` paths wired (types `$10+` fall through to `$A57A`). | Play PB2 normally; `-ramdump` diff of `$0400-$0670` over 600 frames against the pre-patch build must be empty. This proves the dispatcher is transparent. |
| 7 | Patch `$B5F0` → `RT_RAD` and `$B68F` → `RT_DMGL`, still with `RT_WEAPON = 0`. | Same transparency test: shoot an enemy with each of types 1/2/3 and `-watch 17` / `-watch 06`; the values must be `01/02/03` and `08/09/10` exactly as before. |
| 8 | Patch `$A1F8` → `RT_FIRE`, `RT_WEAPON` still 0. | `-trace -watch 0401`; firing must still write type `01` (unsuited) or `03` (suited) at the same frame as the stock build. |
| 9 | Add `RT_PAY` and the `RT_ACC` init, wired only for `RT_WEAPON != 0` (so still inert). | `-ramdump`: `$607B/$607C` = `00 06` after the suits grant. |
| 10 | Weapon 4 (bouncer) first — it exercises spawn, velocity table, terrain probe and lifetime, and has no second stage. | Select weapon 4, fire at a wall. `-watch 0401` shows type `14`; `-watch 0561` shows the X-velocity integer flipping sign on the frame the wall is reached; the slot is freed after the 7th flip. `-png` at the bounce frame shows the Solbrain art. |
| 11 | Weapon 1 (orbit whip). | `-watch 0509` over 16 frames traces the cosine table; slot freed at frame 51. |
| 12 | Weapon 3 (burst rifle), including `RT_WPH` pacing. | `-watch 0401,0402,0403,0404` while holding B: four slots fill on frames 0,2,4,6 of each 80-frame window and nothing fires on frames 8..79. |
| 13 | Weapon 8 (boomerang). | `-watch 0401` shows `19` → `1A` at frame 13; `-watch 0509` shows the X pixel reversing toward the player; the slot frees when it is within 8 px. |
| 14 | Weapon 2 (grenade + blast). | `-watch 0401` shows `11` → `12` on wall contact; `-watch 0443` shows `3E` → `40` → `42`; freed after 13 frames of blast. |
| 15 | Weapon 6 (napalm, two stages + floor crawl). | `-watch 0401` shows `16` → `17` at frame 6; `-watch 04C7` (Y pixel) is constant while crawling on a floor and increments over a gap. |
| 16 | Weapon 5 (charge fan) — needs PB2's `$54` charge counter, so test it last among the projectiles. | Hold B for 60 frames: `-watch 05A3` shows the lifetime rising with `$54`; `-watch 0535` shows the eight-step cone sweep. |
| 17 | Weapon 7 (slash) — the only non-moving type. | `-watch 0509` shows the hitbox pinned 20 px in front of the player and mirroring when the player turns; `-watch 17` during a hit reads `02`, not `01`. |
| 18 | Enable `RT_PAY` for real. | `-watch A0` and `-watch 9E` while firing weapon 5 continuously: `$A0` decrements once every 24 shots, and when it reaches 0 `$9E` decrements and `$A0` refills. With both at 0, `-watch 0401` shows no new spawns. |
| 19 | Full regression. | Play a whole stage on weapon 0 and confirm a byte-identical `-ramdump` trajectory against the pre-patch build for 3000 frames. Then one stage per weapon 1..8 with `-png` proof shots. |

---

## 6. Address budget

### Work RAM

`work/pb3/build.py` copies PRG bank `PAYLOAD_BANK = 16` into `$6000-$7FFF` at boot.
Confirmed free after scanning the current payload:

| range | size | note |
|---|---|---|
| `$6078-$6097` | 32 B | hole between `RT_CUR` (`$6077`) and `RT_WBASE` (`$6098`) |
| `$6E00-$6FFF` | 512 B | above `MW_PALETTE` (`$6B00` + 3 worlds × `$100`) — **only while `PB3_WORLDS <= 3`** |
| `$7280-$7EFF` | 3200 B | above `RT_STN` (`$7270` + 16), below `RT_BOOT` (`$7F00`) |

`$6B00-$6DFF` is **not** free — it is `MW_PALETTE`, three worlds × 256 bytes of
background palette (the scan found 4-byte NES palette rows such as
`0F 0C 17 26 / 0F 0B 1C 10` at `$6C00` and `$6D00`).

Allocation:

```
RT_WEAPON  = $6078   1 B    selected weapon, 0 = Power Blade 2's own
RT_WCD     = $6079   1 B    fire cooldown
RT_WPH     = $607A   1 B    burst / cone phase
RT_ACCL    = $607B   1 B    energy accumulator low
RT_ACCH    = $607C   1 B    energy accumulator high
RT_WSPR    = $607D   1 B    direction captured at spawn
RT_WTMP    = $607E   2 B    scratch

RT_WCHR    = $6E00   8 B    weapon -> R3 CHR bank
RT_WDMG    = $6E08   8 B
RT_WRAD    = $6E10   8 B
RT_WCOSTL  = $6E18   8 B
RT_WCOSTH  = $6E20   8 B
RT_WCDT    = $6E28   8 B    cooldown frames
RT_WAUTO   = $6E30   8 B    0 = edge, 1 = autofire
RT_WLIFE   = $6E38   8 B    default lifetime
RT_WMSPR   = $6E40   8 B    default metasprite
RT_ORBX    = $6E50  16 B
RT_ORBY    = $6E60  16 B
RT_FANDY   = $6E70   8 B
RT_NAPX    = $6E78   4 B
RT_W2LIFE  = $6E7C   3 B
RT_W2SPR   = $6E7F   3 B
RT_VEL     = $6F00 256 B    8 weapons x 8 directions x 4 bytes

RT_WSEL    = $7280
RT_TICK    = $72A0
RT_SETCHR  = $72C0
RT_WHUD    = $7300
RT_HUDW    = $7330
RT_PAY     = $7340
RT_FIRE    = $7380
RT_SPAWN   = $7420
RT_SHOT    = $7480
RT_S1..S8  = $74C0 ...
RT_W1..W8B = $7580 ...
RT_DMGL    = $7E00
RT_RAD     = $7E20
RT_MOVE    = $7E40
RT_DIE     = $7E50
RT_SOLID   = $7E58
RT_NEGX    = $7E60
RT_NEGY    = $7E70
RT_STEP    = $7E80
RT_ABS     = $7E90
RT_BOUNCE  = $7EA0
```

### ROM patch sites

| bank | addr | original bytes | replacement | purpose |
|---|---|---|---|---|
| 9 | `$A1F8` | `A5 48 29 40 F0 27` | `4C 80 73 EA EA EA` | `JMP RT_FIRE` |
| 9 | `$A573` | `C9 03 D0 03 4C FB A7` | `4C 80 74 EA EA EA EA` | `JMP RT_SHOT` |
| 7 | `$B5F0` | `B9 00 04 A8 B9 25 B7` | `20 20 7E EA EA EA EA` | `JSR RT_RAD` |
| 7 | `$B68F` | `B9 00 04 A8 B9 21 B7` | `20 00 7E EA EA EA EA` | `JSR RT_DMGL` |
| 14 | `$CDCB` | `4C 59 D2` | `4C 80 72` | `JMP RT_WSEL` |
| 14 | `$CEFD` | `20 BE D2` | `20 A0 72` | `JSR RT_TICK` |
| 14 | `$D67E` | `20 C1 D5` | `20 30 73` | `JSR RT_HUDW` |
| 14 | `$CE06` | `A9 11 85 45` | `20 C0 72 EA` | `JSR RT_SETCHR` |
| 14 | `$D036` | `A9 11 85 45` | `20 C0 72 EA` | `JSR RT_SETCHR` |
| 14 | `$D290` | `A9 11 …` | `20 C0 72 EA` | `JSR RT_SETCHR` |
| 14 | `$D294` | `A9 12 …` | `20 C0 72 EA` | `JSR RT_SETCHR` |
| 14 | `$D319` | `A9 11 …` | `20 C0 72 EA` | `JSR RT_SETCHR` |

Bank 14's five `$45` sites are listed from the `LDA #$11 / STA $45` pattern; the exact
byte layout at `$D290`/`$D294`/`$D319` should be re-dumped before patching, since those
three sit inside branchy menu code and may not be a clean 4-byte `A9 nn 85 45`.
**[inferred — the `A9 11`/`A9 12` immediates were located, the surrounding 4-byte
alignment was not individually verified at all five sites]**

Free ROM space, if any of the above needs a trampoline: bank 8 `$8D6A-$8DFF`,
bank 9 `$BF99-$BFFF`, bank 11 `$BF35-$BFFF`. Banks 10, 14 and 15 have none.

---

## 7. Open items

1. **`$D290`/`$D294`/`$D319` byte alignment** — see the note above. Re-dump before patching.
2. **Player 2 and `$A4FD`** — the muzzle-offset routine reads slot 0's position
   unconditionally, so a player-2 Solbrain shot would spawn at player 1's muzzle.
   PB3's existing co-op already has this property for the stock weapon; the plan does
   not make it worse, but a second `RT_WEAPON` for player 2 would need a slot-relative
   variant of `$A4FD`.
3. **`$99` and the `$A3D9` cap** — `$10 = 1 + $99` limits simultaneous shots and `$99`
   is set from the suit/upgrade state. Weapons 3, 5 and 6 want 4 alive; confirm `$99`
   is at least 3 in all PB3 configurations, or force `$10 = 4` inside `RT_FIRE`
   before `JSR $A3D9`.
4. **Sound ids** — `$22` (throw) and `$21` (hit) are observed. `$1B`, `$1C`, `$1D`
   used above for explode / ricochet / flame are **[inferred]** placeholders; pick real
   ones from the `$C81C` id space before shipping.
