# Power Blade 2 — the weapon system (fully decoded, for adding 8 new weapons)

> **Corrections, Э3.3 (the port and its acceptance run).**  Everything below
> was written before the weapon code was ported and driven against the
> cartridge frame by frame.  Three things in it are wrong or incomplete:
>
> 1. **`$55` is not the world, the stage or the level.**  It is how far the
>    blade has been raised, 0..3 — a pickup.  It is zeroed at `$D06C` beside
>    `$A2`, `$99`, `$54` and `$9A`, and put up by one (ceiling 3) by the thing
>    at `$B572` in bank 7.  Read every "world"/"stage" below as "the blade's
>    power".
> 2. **`$8C` is read**, by `$D243`: it is the ceiling the hold counter `$54`
>    stops at.  `$D255,Y` holds the same four numbers, and `$D243` reads that
>    one; `$8C` is the copy `$D8F1` leaves behind.  Raising `$55` behind the
>    game's back without also copying `$8C..$8F` gives a hero whose ceiling is
>    the new power's and whose three marks are the old one's.
> 3. **The sub-tables at `$A885..$A89D` do not collide with the arc tables.**
>    The four accel bases (`$A8BD`, `$A8CD`, `$A89D`, `$A8AD`) are biased, and
>    only rows 8..23 are ever indexed, so the two readings never overlap.
>
> The numbers themselves are no longer read by hand out of this document: they
> are pulled straight from the ROM by `work/extract/pb2_weapons.py` into
> `game/data/pb2/weapons.json`.  The order the weapon code runs in, which
> nothing below states, is `$8E15`: `$8E23` death, **`$8E26` what is already
> in the air moves**, `$8E29` the state machine and `$A1C2` inside it — so a
> blade let go this step does not move on the step it was let go.  He himself
> is not moved until `$8E2C` (`$A945`), which is why a throw comes out of the
> place the table still shows him standing in.  `$D23A`, which counts the
> button, runs at `$CF00` — before the table is written down at `$CF14` and
> before the step.

Scope: everything needed to bolt eight new player weapons onto the existing
engine — the shared object table, the fire/spawn code (both weapon paths),
the generic sprite/animation pipeline, the damage model, the pause-menu
weapon/suit selector, the energy pool, and where there is free PRG space to
put new code/data. All facts below are pinned to a CPU address and either a
disassembly excerpt (from `work/re/pair6.asm`, `pair8.asm`, `b14.asm`,
`b15.asm`) or a direct ROM byte dump (Python read of
`Power Blade 2 (USA).nes`, offset = `16 + bank*8192 + (addr - window_base)`).
Bank numbering and PRG windows: banks 14/15 fixed at `$C000`/`$E000`; bank
pairs (8,9), (10,11), (6,7) etc. map to `$8000`/`$A000` when MMC3 R6/R7 select
them (`$ECA7`/`$ECAB` helper, see `ARCHITECTURE.md`).

---

## 1. Shot objects — the shared 22-slot object table

There is **no separate projectile pool**. Player, player's shot(s), and every
enemy/boss/pickup share one array: 22 columns (`X = 0..21`) of a "field
table" where field *n* occupies `$0400 + 22*n` and each column is one byte
of that field, i.e. **object *n*'s byte of field *f* is at `$0400 + 22*f + n`**
(stride 22 = `$16`).

**Proof of 22 slots**: the generic per-frame sprite-draw entry point,
`pair6.asm` `loc_8038` (reached via `$8000 → JMP loc_8038`, i.e. run once per
frame while bank pair 6/7 is paged in):
```
8035  4C 37 BC JMP loc_BC37      ; (unrelated code just before)
loc_8038: A5 28 LDA $28 / ... / A2 00 LDX #$00 / STX $0D
loc_805D: E6 0D INC $0D / A6 0D LDX $0D / E0 16 CPX #$16 / B0 E6 BCS loc_804B
```
`CPX #$16` = 22 — the loop that walks every object column stops at 22.

**Player = slot 0, shots start at slot 1**: allocator `sub_A3D9`
(`pair8.asm`):
```
A3D9  A4 99 LDY $99 / C8 INY / 84 10 STY $10      ; $10 = allowed count (1..3), from $99 (0-2 extra simultaneous shots, pb2_suits.md subtype 7)
A3DE..A3F2                                          ; Y = how many of slots 1,2,3 ($0401,$0402,$0403) are already non-zero
A3F2  C4 10 CMP $10 / B0 0C BCS loc_A402            ; already at cap -> fail (carry set, caller aborts)
A3F6  A2 01 LDX #$01
loc_A3F8: BD 00 04 LDA $0400,X / F0 03 BEQ loc_A400 / E8 INX / D0 F8 BNE loc_A3F8
loc_A400: 18 CLC / 60 RTS                           ; X = first free slot >= 1, returned in X, carry clear = success
```
So the free-slot scan starts at `X=1` and only ever checks/allocates among
slots **1, 2, 3** — the engine hard-caps simultaneous player shots at 3, and
the live cap is `1 + $99` (0-2), matching `pb2_suits.md`'s already-proven
"$99 = extra simultaneous shots, cap 2" pickup subtype 7.

**Per-slot byte meaning** (fields confirmed against `pb2_collision.md` and
fresh reads above; `X` = the shot's own slot 1-3):

| field addr (`base,X`) | meaning | evidence |
|---|---|---|
| `$0400,X` | **type/active tag** (0 = free; 1/2 = unsuited knife variants; 3 = suited beam) | written at `loc_A2A6` (type 1/2) and `loc_A37F`/`$A381` (type 3); read back as the enemy-vs-shot dispatch tag everywhere (e.g. damage lookup, §4) |
| `$04B0,X` / `$04C6,X` / `$04DC,X` | Y position: hi / pixel / fraction | `pb2_collision.md`, confirmed field(8)/(9)/(10) = `0x400+22*8=0x4B0`, `+22*9=0x4C6`, `+22*10=0x4DC` |
| `$04F2,X` / `$0508,X` / `$051E,X` | X position: hi / pixel / fraction | field(21)/(22)/(23) by the same arithmetic, symmetric with Y |
| `$0534,X` / `$054A,X` | Y accel (two-byte) | set at `loc_A37F` (`$A8ED`-derived per-suit table, see §2) and `loc_A327` (unsuited path) |
| `$0560,X` / `$0576,X` | X accel (two-byte) | same two call sites |
| `$05CE,X` | **direction/variant code, 0-7** — indexes the per-direction sprite/velocity tables (§2) | `sub_A403`'s `X` return value, stored via `loc_A226: TXA / LDX $25 / STA $05CE,X` |
| `$05E4,X` | X speed accumulator (fed by `$0560/$0576` via `$B20B`, per `pb2_collision.md`) | zeroed at `loc_A37F`: `A9 00 / STA $05E4,X` |
| `$0442,X` | **current tile id / metasprite id actually drawn** (see §3) | `loc_A37F` writes it directly from `$A8E5,Y`; unsuited path writes it via the bank-15 animation stepper |
| `$0458,X` | animation **sequence id** for the generic tile stepper (§3) | `loc_E2D5` (`STA $0458,X`), set for unsuited shots via `$C83A → loc_E2D5` at `loc_A2AB` |
| `$046E,X` | animation **frame index** | `loc_E301`/`loc_E303`/`loc_E346`/`loc_E34E` etc. |
| `$05A2,X` | for a *shot*, this doubles as the **frame-hold countdown** *and* — for the suited weapon only — the byte pulled from the per-stage/per-charge power table (`loc_A3BD: STA $05A2,X`, see §2) | see §2 and §3 |
| `$042C,X` bit7 | "frozen/hidden" flag (checked by the draw loop, `loc_8065: BMI loc_805D`) | |
| `$0416,X` | misc state byte (bit7 used as "just spawned"/"active" by the bank-15 stepper) | |

No slot exists for "who fired it" or "damage value" as a stored per-shot
byte — damage is *derived* at hit-test time from field `$0400,X` (§4), not
stored on the shot. **A new weapon that wants its own fixed damage must
either reuse one of the existing type values 1-7 whose damage table entry
matches, or extend the 8-entry damage table (§4) and use a new type value
that still fits in the same table.**

---

## 2. Spawning

**Call chain** (per-frame, while bank pair 8/9 is paged in for the player
update):
```
$8000  JMP loc_8E15                 ; player-update entry, called once/frame
$8E23  JSR sub_A17A
  ...
$A1C5  BPL loc_A1F8                 ; -> B-button-newly-pressed dispatch
loc_A1F8:
  A5 48 LDA $48 / 29 40 AND #$40 / F0 27 BEQ loc_A225   ; $48 bit6 = B newly pressed (pad1 newly-pressed reg, ARCHITECTURE.md)
  20 D9 A3 JSR sub_A3D9                                  ; allocate a free shot slot (§1); abort if none
  86 25 STX $25                                          ; save shot slot
  20 03 A4 JSR sub_A403                                  ; direction/variant resolver, see below
  ...
  4C 26 A2 JMP loc_A226
loc_A226:
  8A TXA / A6 25 LDX $25 / 9D CE 05 STA $05CE,X           ; $05CE,shot = sub_A403's X output (0-7)
  ...
  20 FD A4 JSR sub_A4FD                                   ; compute charge tier -> $08 (see below)
  A5 54 CMP $8D / $8E / $8F ...  STY $08                  ; tier = 0..3
  A9 00 STA $54                                           ; reset hold-frame counter
  ...
loc_A291: A5 9A LDA $9A / F0 03 BEQ loc_A298 / 4C 7F A3 JMP loc_A37F
```
`$9A` = current suit (0 = none, 1-4 = suits, `pb2_suits.md`): `$9A==0` takes
the **unsuited** path (`loc_A298`), any suit takes the **suited** path
(`loc_A37F`).

### Direction resolver `sub_A403`

Reads the held-direction bits `$0416` (recent-facing) and `$4A` (pad1 held),
and the crouch bit `$042C` bit6, and returns **two independent values**:
* `X` = 0-7, the shot's own direction/variant code — stored into `$05CE,X`
  and used to index the per-direction shot tables below.
* `Y` = 0-14 (or `$FF` = "no valid direction, abort") — remapped through
  `LDA $A4EE,Y` (table `$A4EE = 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 12 14 14`,
  15 bytes) into a **player pose id** fed to `sub_B017` (the player's own
  throw-animation stepper, tables `$B072`/`$B08A`, cosmetic only — it
  animates the player's arm, not the shot).

  (`loc_A226`'s `TXA`/`LDX $25` sequence is *not* a bug: `sub_A403` returns
  the shot-direction in `X` and the pose-remap input in `Y`; `X` survives
  the `sub_B017` call untouched and is what gets copied into `$05CE,X` —
  this resolves what looked like an X/Y inconsistency during RE.)

### Unsuited path (`loc_A298`, type 1/2)

```
A298  A4 A2 LDY $A2 / F0 08 BEQ loc_A2A4                 ; $A2 != 0 -> OR $042C,X |= $02 (extra flag)
loc_A2A4: C8 INY / 98 TYA / 9D 00 04 STA $0400,X         ; type = $A2($A2==0 -> 1, else -> 2)
A2A9  A9 08 LDA #$08 / 20 3A C8 JSR $C83A                ; $C83A = JMP loc_E2D5 (bank15): starts anim sequence 8
```
Then a **per-(type, world) X-accel arc table**, keyed by the current stage
number `$55` (0-3):
```
A2AE  LDA $0400,X (type) ASL,ASL,ASL -> $00              ; type*8
A2B6  LDA $55 ASL -> ADC $00 -> Y                          ; + world*2
A2BD  LDA $A84D,Y / LDA $A84E,Y -> $00/$01                 ; 16-bit pointer (per type,world)
A2C7  LDA $08 ASL -> Y ; LDA ($00),Y -> $11 ; INY ; LDA ($00),Y -> $10
A2D6  negate $11:$10 -> $13:$12                             ; magnitude flipped to a signed accel
```
verified table dump (`pair8.asm` bank 8 file offset): pointer sub-tables at
`$A865/$A86D/$A875/$A87D` (type 1, worlds 0-3) and `$A885/$A88D/$A895/$A89D`
(type 2, worlds 0-3), each **4 entries × 2 bytes = one per charge tier
0-3**, e.g. `$A865 = 00 03 80 03 00 04 80 04` (tier0=`$0300`, tier1=`$0380`,
tier2=`$0400`, tier3=`$0480`). **This is the mechanism that scales the
unsuited knife's throw arc by held-B "charge tier" and by world.**

### Charge tier (`$08`, 0-3) — this is the `$D8F1` "weapon power table"

`$54` is a **frames-B-has-been-held counter**, incremented once per frame
elsewhere (`b14.asm` `sub_D23A`, called from the main dispatch at `$CF00`):
```
D23A  LDA $1C AND #$03 CMP #$03 BNE(rts)
D243  LDY $55 / LDA $D255,Y -> $10        ; per-stage cap, $D255 = 04 08 0C 10
D24A  LDA $54 CMP $10 BEQ(skip) / INC $54  ; increment while below the per-stage cap
```
At fire time, `sub_A4FD`+`loc_A247` compares `$54` against **three ascending
thresholds `$8D`,`$8E`,`$8F`** to produce `$08 = 0,1,2,3`:
```
A247 LDA $54 / CMP $8D BCC->0 / INY,CMP $8E BCC->1 / INY,CMP $8F BCC->2 / INY ->3
```
`$8D..$8F` (plus a leading unused `$8C`) are loaded once per game-state
transition by **`sub_D8F1`** (`b14.asm`, called from `$D04C`, which itself
runs right after the per-life `$55`/`$99`/`$A2` housekeeping — i.e. at
stage/life entry):
```
D8F1  LDA $55 ASL A TAY                    ; $55 = current world/stage, 0-3
      LDA $D90C,Y -> $00 ; LDA $D90D,Y -> $01   ; $D90C = 8-byte pointer table (4 stages)
      LDY #$00
loc_D901: LDA ($00),Y / STA $008C,Y / INY / CPY #$04 / BNE loc_D901
```
`$D90C..$D923` (24 bytes) = pointer table `14 D9 18 D9 1C D9 20 D9` + the 4
data rows themselves right after it:
```
$D914: 04 01 02 03      ; stage 0 -> $8C,$8D,$8E,$8F
$D918: 08 02 04 07       ; stage 1
$D91C: 0C 04 08 0B       ; stage 2
$D920: 10 06 0C 0F       ; stage 3
```
So **the "weapon power table" is per-stage**: `$8D/$8E/$8F` are the
frame-hold thresholds that convert charge into tier 0-3 (used by *both*
weapon paths — unsuited arc table above, suited power table below); `$8C`
is loaded but no read of it was found in `pair8.asm`/`pair6.asm` (see
"could not determine").

### Suited path (`loc_A37F`, type 3)

```
A37F  A9 03 STA $0400,X                       ; type = 3
A384  A9 00 STA $05E4,X                        ; reset X speed accumulator
A389  LDY $05CE,X                              ; direction code 0-7
A38C  LDA $A8E5,Y STA $0442,X                  ; sprite/tile id  (8-byte table)
A392  LDA $A905,Y STA $0576,X                  ; X accel byte A  (8-byte table)
A398  LDA $A90D,Y STA $0560,X                  ; X accel byte B  (8-byte table)
A39E  LDA $A915,Y STA $054A,X                  ; Y accel byte A  (8-byte table)
A3A4  LDA $A91D,Y STA $0534,X                  ; Y accel byte B  (8-byte table)
A3AA  JSR sub_A358                             ; halve accel if suit 1 crouch-throw
A3AD  LDA $55 ASL A TAY                        ; world*2
A3B1  LDA $A8ED,Y / LDA $A8EE,Y -> $00/$01      ; per-world pointer (4 entries, right after the sprite table)
A3BB  LDY $08                                  ; charge tier 0-3
A3BD  LDA ($00),Y -> $05A2,X                    ; per-stage, per-charge power byte written onto the shot
```
Verified byte dumps (bank 9 file offset): `$A8E5` (8 bytes, one per
direction) = `3E 3E 40 42 3F 3F 41 41`; immediately followed (no gap) by
`$A8ED` (8 bytes = 4 pointers, one per world) = `F5 A8 F9 A8 FD A8 01 A9`
→ `$A8F5/$A8F9/$A8FD/$A901`; those in turn hold 4 bytes each (one per
charge tier): world0 `06 07 08 09`, world1 `09 0A 0B 0C`, world2
`0C 0D 0E 0F`, world3 `0F 10 11 12`. **This is the direct "does `$9A` /
weapon level change the shot" mechanism for the suited weapon: world and
charge tier select a power byte that lands in the shot's `$05A2` field**
(reused there as a power/flag byte instead of its usual "animation frame
hold" role — the same overloading pattern documented for `$0400`).

`$A905/$A90D/$A915/$A91D` are each exactly 8 bytes and pack back-to-back
with zero gap (`$A905+8 == $A90D`, etc. — confirmed by direct ROM read),
so **8 entries per table is the true, fully-used length**, matching
`sub_A403`'s `X` range 0-7:

| dir | sprite `$A8E5` | Xa `$A905/$A90D` | Ya `$A915/$A91D` |
|---|---|---|---|
| 0 | `$3E` | `40/00` | `00/00` |
| 1 | `$3E` | `C0/FF` | `00/00` |
| 2 | `$40` | `00/00` | `C0/FF` |
| 3 | `$42` | `00/00` | `00/03` |
| 4 | `$3F` | `2D/FF` | `D3/FF` |
| 5 | `$3F` | `D3/00` | `2D/FF` |
| 6 | `$41` | `2D/FF` | `D3/00` |
| 7 | `$41` | `D3/00` | `2D/00` |

Signs (byte pairs read as little-endian, second byte = high) show
dir0=+X,0 · dir1=−X,0 · dir2=0,−Y(up) · dir3=0,+Y(down, large) ·
dir4=−X,−Y · dir5=+X,−Y · dir6=−X,+Y · dir7=+X,+Y(small) — an 8-way
compass, consistent with up/down/left/right + 4 diagonals.

**To add a new weapon that behaves like the suited beam**: append new
direction-code(s), extend these five 8-entry tables (they are packed
tight against each other and against the `$A8ED` power-table, so this
requires relocating them to free space, see §7, and repointing the five
`LDA $A8E5,Y` / `$A905,Y` / `$A90D,Y` / `$A915,Y` / `$A91D,Y` operands at
`$A38C/$A392/$A398/$A39E/$A3A4`), or add a new `type` value and give it its
own small block modeled on `loc_A37F`.

---

## 3. Update + draw

**Per-frame tile-id stepper** (drives `$0442,X`, the field the draw loop
actually reads) — generic for every object 0-21, lives in bank 15, entered
via a fixed trampoline `$C83A = JMP loc_E2D5` (bank 14, confirmed
disassembly byte pattern `4C D5 E2` at `$C83A`) for *starting* a sequence,
and via `sub_E30F`/`loc_E309` (called once per object per frame from the
generic object-update pass, xref `$FA05`) for *stepping* an already-running
one:

* `$0458,X` = **sequence id** (argument to `loc_E2D5`, e.g. `#$08` for the
  unsuited knife spawn at `$A2A9`).
* Sequence lookup: `LDY #$36 / JSR sub_ECA7` pages in **bank pair 6/7**
  (`$36 & $0F = $06`), then reads a **fixed two-byte cell `$802D/$802E`**
  (present at the same fixed low offset in whichever bank is now at
  `$8000`) which holds a pointer to the **per-sequence-id pointer table**;
  `seq_id*2` indexes it to get a pointer to the **4-byte sequence record**:
  * byte 0: bit7 = clamp/hold-last-frame vs. loop; low 7 bits = last valid
    frame index.
  * byte 1: frames to hold each animation step (reloaded into `$05A2,X`
    every time the countdown in `$05A2,X` hits 0).
  * byte 2 (loop mode): base tile id — final tile = `byte2 + $046E,X`
    (frame index), written to `$0442,X`.
  * byte 3 (clamp mode): index (×2) into a **local** pointer table
    `$E39C` (bank 15) → an explicit per-frame tile-id list, looked up by
    `$046E,X`.
* `$046E,X` = current frame index within the sequence, advanced/reset by
  the stepper each time the hold countdown expires.

The **suited weapon bypasses this stepper entirely** — `loc_A37F` writes
`$0442,X` directly from the 8-entry `$A8E5` table every time it fires, so
suited shots do not animate frame-to-frame (single static tile per
direction). A new weapon can use either mechanism: direct single-tile
write (simple, no animation) or a sequence id + 4-byte record (animated).

**Draw / OAM composition** — bank pair 6/7, entered once per frame at
`$8000 → JMP loc_8038` (same code that proves the 22-slot bound in §1):
```
loc_8065: LDY $0442,X / BEQ loc_805D          ; tile id 0 = invisible, skip
          LDA $042C,X / BMI loc_805D          ; frozen/hidden flag
          ... load position -> $10/$11/$12/$13
          CPX #$06 / BCC loc_809F              ; X<6 (player + its own shots) vs X>=6 (enemies)
loc_809F: LDA $8148,Y / STA $08 ; LDA $81B4,Y / STA $09   ; player-range pointer table (Y = the tile id!)
   (X>=6) LDA $8C88,Y / STA $08 ; LDA $8D83,Y / STA $09   ; enemy-range pointer table
loc_80A9: LDY #0 / LDA ($08),Y -> $0A          ; byte0 of the metasprite record = OAM-entry COUNT
loc_80B2..8145: per entry, 4 bytes: dy (signed), tile, attr, dx (signed)
          -> $0200,X / $0201,X / $0202,X / $0203,X ; buffered OAM (later flushed to real OAM elsewhere), X += $C4 per object
```
**Metasprite id = the object's own `$0442,X` byte**, looked up in one of
two pointer tables selected by the object's *slot number* (not weapon
type): slots 0-5 (player + all its shots, since shots live in slots 1-3)
use `$8148`(lo)/`$81B4`(hi); slots 6-21 (enemies) use `$8C88`(lo)/`$8D83`(hi).
**Metasprite record format** = `[count] + count × (dy:i8, tile:u8, attr:u8, dx:i8)`,
with horizontal mirroring applied uniformly (facing bit in `$042C,X` bit6
flips both the `attr` bit6 and negates `dx`).

`$8148/$81B4` is **exactly 108 entries (`$6C`), fully packed** — verified by
dereferencing all 108 pointers: they increase monotonically and the last
one (`$87BA`) sits right where the table itself ends (`$8148 + 108*2 =
$8220`, `$81B4 + 108 = $8220` too, and metasprite data for id 0 starts
there). **There is zero slack in this table: adding new player/shot
sprites needs either unused metasprite-id slack (there is none — ids 0-107
are all in use and the code does `LDA $8148,Y` with no bounds check, so
id ≥108 reads garbage) or relocating/extending the table** into free space
(§7) and patching the two hard-coded operands at `$809F`/`$80A4`.

---

## 4. Damage

Hit test / HP-decrement is `sub_B688`/`sub_B698` (`pair6.asm`, called from
`$B675`, itself part of the generic collision handler that also plays the
hit sound `$21`):
```
sub_B688:
  B688 LDA $0400,X CMP #$0C BEQ loc_B6F1        ; defender type $0C = special (no damage, different reaction)
  B68F LDA $0400,Y TAY                          ; Y = attacker's OWN slot -> read attacker's type byte
  B693 LDA $B721,Y STA $17                      ; damage = damage_table[attacker type]
sub_B698:
  B698 LDA $049A,X CMP #$FF BEQ(rts)            ; $049A,X = defender HP; $FF = invincible, skip
  B69F SEC / SBC $17 / STA $049A,X              ; HP -= damage
  ...death/knockback branches on the result and on defender type vs #$50 (boss threshold)
```
**Damage table**: `$B721..$B728` = `01 01 02 03 05 08 09 10` (8 bytes,
verified byte-for-byte, sitting inside a labeled 18-byte data block
`$B717..$B728` that also holds the boss-death-animation table
`$B717..$B720 = 03 03 03 03 03 03 06 06 06 06` immediately before it — the
two tables are packed with **zero slack**, and `sub_B729`'s live code
starts immediately after `$B728`).

Damage is **indexed by the attacker's own `$0400` type byte**, so:
`type 1` (unsuited knife) and `type 2` (unsuited, `$A2`-flag variant) both
→ `$01` damage; `type 3` (suited beam) → `$02` damage; types 4-7 (enemy
melee types reusing the same byte range) → `03/05/08/09`. **To give a new
projectile a chosen damage value**: pick (or add) a `type` value 0-7 whose
`$B721` entry already equals the desired damage, or extend the table —
since it's packed tight both before (death-anim table) and after (live
code `sub_B729`), extending in place is not possible; the table must be
relocated to free space (§7) and the single `LDA $B721,Y` operand at
`$B693` repointed. Because the index is the attacker's *own* type byte
(0-255 range but only 0-7 ever read safely — any type ≥8 used as an
attacker reads into the death-animation table or beyond, which is
presumably why every player-shot type stays ≤7), **new weapon types
should also stay ≤7 unless the table is relocated and given real bounds.**

---

## 5. The in-game menu at `$D259` (bank 14)

All of the following is independently re-verified against the pre-existing
`pb2_suits.md` (which reverse-engineered the suit/weapon-select UI in
detail); addresses re-checked directly in `b14.asm` during this pass.

**Open** — `$D0A6`, called every frame from `$CDBB`. Requires
`$27==3` (not mid-transform), not stage-5 intro, no cutscene/halt flags.
START newly pressed (`$48 & $10`) sets `$4D=1` (menu open), remembers
`$AF=$9A`, plays sound `$17`, and freezes all objects (`JMP $D69C`).

**Cursor movement** — `loc_D259` (called every frame from `$CDCB`, i.e.
the *cycle* step of the same menu). Guarded by `$27==3`, `($A0|$9E)!=0`
(has energy or a spare tank), `$56!=0` (owns ≥1 suit):
```
D269  LDA $48 AND #$08 BNE loc_D276     ; UP  -> next owned entry
D26F  LDA $48 AND #$04 BNE loc_D2A0     ; DOWN -> previous owned entry
loc_D276/loc_D27E: walk Y = $9A+1 .. up to 5, or Y = $9A-1 .. down to 0,
  landing only where  $56 AND $D2B9[Y] != 0
$D2B9 = 00 01 02 04 08                  ; 5-byte ownership mask, index 0 ("unsuited") always matches via fallthrough
```
Landing: `STY $9A`; `$45` (MMC3 R3 shadow / CHR bank) = `$11` if unsuited
else `$12`; blip sound via `$ECE8`; redraw the HUD portrait (`JMP $D5C1`).

**Drawing entries** — the "entries" are not a text list, they are a 3×3
tile portrait (`$D5C1`, data `$D613..$D64F`): `$D619` holds 5 pointers
(indexed `$9A*2`) into 5 nine-tile blocks (`$D623/$D62C/$D635/$D63E/$D647`),
each blitted as three 3-tile VRAM-queue rows at fixed PPU addresses
`$26F1/$2711/$2731`. Called from `$D030` (respawn), `$D29D` (cycle),
`$D320` (energy ran out), `$D67E` (HUD rebuild).

**Applying selection / closing** — back in `$D0A6`: pressing START again
while `$4D!=0`. If `$9A==$AF` (nothing changed) just close (`$4D=0`,
unfreeze). Otherwise `$D0FE`: reset shot slots 1-5 (`$D768`), sound `$1F`,
set `$27=7` ("transforming"), kick off the transform sprite fields
(`$0443=$58`, `$0509=$80`, `$04C7=$78`). State 7 is drained at bank 15
`$F02B`: waits for a timer, restores fields, `$4D=0`, `$27=3`, unfreeze.

### Exactly what has to change to add 8 new weapon entries

The menu's "5 entries" limit is baked into **five different fixed-size
tables/constants**, all of which must grow together:
1. `$D2B9` ownership mask — 5 bytes; the cycling code's wrap bound
   `CPY #$05` (`$D27A`) and `LDY #$04` (`$D2AA`) are literal immediates.
2. `$D619` HUD-icon pointer table — 5 entries × 2 bytes, plus the 5
   nine-tile data blocks they point to.
3. `$D326` energy-drain-rate table — only 4 entries (suits 1-4, §6); a new
   weapon that drains energy needs a slot here too.
4. `$56`, the ownership bitmask, is **one byte, only 4 bits used** (bits
   0-3 = suits 1-4, bits 4-7 unused/never set by any pickup) — this gives
   room for **at most 4 more** owned items before a second byte is needed;
   for 8 new weapons a new RAM byte (and a parallel extension of the
   password-packing code `$9A3F`/`$9D38`/`$9D5F`, which currently packs
   exactly 4 bits) is required.
5. `$D8E4`'s palette-group computation (`LDA $9A / ADC #$3D`) and the CHR
   bank swap (`$45 = $11`/`$12`) assume a small, contiguous `$9A` range and
   only two CHR sets (unsuited/suited) — new weapons that need distinct
   sprites will need either new CHR banks or to share the existing suited
   set, and a wider palette-group table than the current 5 entries
   (`$84BC/$84BF/$84C2/$84C8/$84C5`).

None of these tables have spare bytes in place (all confirmed tightly
packed against neighboring code/data); every extension implies relocating
the table to free space (§7) and patching the small number of hard-coded
operands/immediates listed above.

---

## 6. Energy drain

Re-verified against `pb2_suits.md`, directly in `b14.asm`:

`sub_D2BE` (called every frame from `$CEFD`):
```
D2BE  LDA $27 CMP #$06 BEQ(rts)          ; not while refilling
D2C4  LDA $58 BNE(rts)                    ; not while halted
D2C8  LDA $9A BEQ(rts)                    ; no suit worn -> no drain
D2CC  LDA $A0 ORA $9E BEQ(rts)            ; nothing left to drain
D2D2  LDA $A0 BEQ loc_D2FD                ; bar already empty -> go straight to spare-tank logic
D2D6  LDY $9A DEY / LDA $D326,Y -> $17    ; $D326 = 03 04 04 06, per-suit-1..4 drain rate
D2DE  $85:$86 -= $17    (16-bit, $85 = high byte)
       on borrow: $85:$86 = $0600 (1536), and A0 -= 1
D2FD  if $A0==0: if $9E!=0 { $9E-=1, redraw($D4B6), $30=$10, $27=6 }  ; burn a spare tank
                 else       { $9A=0, redraw($D4D9), $45=$11, $D768, $D5C1, JMP $D8E4 }  ; suit falls off
```
`$85:$86` is a 16-bit accumulator reloaded to `$0600` (1536) each time it
borrows, so a suit with drain-rate *r* loses one energy-bar unit every
`1536/r` frames (suit 1: 512 frames ≈ 8.5s per unit, full 16-unit bar ≈
136s; suit 4 drains twice as fast). HUD repaint: `$D4B6` redraws the spare
tank counter, `$D4D9` redraws the energy bar itself (`$2708`).

**Where to hook 8 new weapons into the same energy pool**: the cheapest,
least invasive hook is **inside `sub_A1F8`'s fire-check, right after
`sub_A3D9` succeeds and before spawning** — insert a check/decrement of
`$A0`/`$9E` there (mirroring the `($A0|$9E)!=0` gate already used by the
menu at `$D25F`/`$D2CC`), so a shot simply refuses to spawn (like the menu
refuses to open) when the pool is empty, and drains `$A0` by a
per-weapon amount using the *same* `$85:$86`/`$D326`-style accumulator
mechanism (or, simpler for a per-shot cost model instead of continuous
drain, just `DEC $A0` directly with the existing spare-tank fallback logic
at `$D2FD` re-used as a subroutine). This reuses the exact same variables
(`$A0` bar, `$9E` spare tanks, `$D4B6`/`$D4D9` redraw) the existing suits
already share, so no new RAM is needed for the energy pool itself — only
for a per-weapon drain-rate/cost table analogous to `$D326`.

---

## 7. Free space

Independently scanned twice (static byte-run scan over the ROM file, cross-
checked against the disassembly's own "==== data ====" labels to confirm
no code references land inside the range) for runs of `$00` or `$FF` ≥32
bytes, per required PRG window:

| bank | CPU range | size | value | notes |
|---|---|---|---|---|
| 8 | `$8D6A-$8DFF` | 150 B | `$FF` | tail of a larger (369 B) unreferenced data block `$8C8F-$8DFF`; only this trailing part is pure `$FF` |
| 9 | `$BF99-$BFFF` | 103 B | `$FF` | immediately after a live 8-byte branch-opcode lookup table `$BF91-$BF98` used by code at `$BF85`; confirmed unreferenced past `$BF98` |
| 11 | `$BF35-$BFFF` | 203 B | `$FF` | clean tail padding right after `JMP $C8CD` (end of bank's live code) |
| 10 | — | — | — | no run ≥32 B found |
| 14 | — | — | — | no run ≥32 B found (fixed bank, already very tight — matches `ARCHITECTURE.md`'s "24 bytes of slack" note) |
| 15 | — | — | — | no run ≥32 B found |

Total confirmed reclaimable space in the required banks: **456 bytes**
(150+103+203), all in banks 8/9/11 — exactly the banks that hold the
per-direction/per-world/per-charge weapon tables (§2) and the metasprite
pointer table (§3), which is convenient since those are also the tables
that need extending. Banks 10, 14 and 15 have no usable free space at all
under this deliverable's ≥32-byte bar — any new code/data destined for
those banks must go into genuinely new PRG banks (as `ARCHITECTURE.md`
already plans for the whole PB3 multicart).

---

## Could not determine

* **`$8C`** (the first of the four bytes `sub_D8F1` loads per stage) is
  never read by any code found in `pair6.asm`/`pair8.asm`. Its purpose is
  unknown — possibly dead, possibly consumed by a bank not yet searched.
* **The exact real-world meaning of `$A2`** (the flag that selects
  unsuited shot type 1 vs type 2 at `loc_A298`). Structurally it behaves
  like a boolean modifier (crouch? recent-hit? a pickup-consumed charge —
  `pb2_suits.md` separately documents `$A2` as a pickup-subtype-5 counter
  capped at 1, which is consistent with a single-use flag, but the two
  uses were not cross-verified against each other with a live emulator
  test).
* **Live-emulator confirmation of all 8 suited-weapon directions.** The
  velocity-sign table in §2 was derived from static ROM bytes and is
  internally consistent (matches an 8-way compass), but only 2-3 of the 8
  codes were confirmed against actual on-screen firing during this session
  (earlier suit 2/3/4 tests only exercised the default/no-direction-held
  case, type=3, not all 8 `$05CE` values).
* **The `$A4EE`-remapped player pose ids (`$0B-$16`) and their visual
  effect** — traced the mechanism (feeds `sub_B017`'s pose-animation
  tables `$B072`/`$B08A`) but did not decode what each of the 11 distinct
  values (`$0B..$16`) looks like on screen; purely cosmetic to the player
  sprite, does not affect the shot itself, so treated as out of scope for
  bolting on new weapons.
* **The clamp-mode tile-list table `$E39C`** (bank 15) used by the generic
  animation stepper's "hold last frame" path — structurally identified
  (pointer table, indexed by the sequence record's byte 3, dereferenced by
  frame index) but its actual contents were not dumped; not needed by
  either existing player weapon (both use the simple loop-mode "base +
  frame index" path), so likely only relevant to enemy/boss animations.
* **Whether any other bank (0-5, 12-13) also contains free space or
  additional weapon-adjacent tables** — this deliverable only scanned
  banks 8, 9, 10, 11, 14, 15 as required; banks 0-5 and 12-13 (sound driver,
  per earlier investigation) were not scanned for free space.
* **Precise units of the accel/power-table values** (§2's `$A865`-style
  tables and the `$A8ED` power-byte) were not empirically calibrated
  against measured pixels/frame in the live emulator — only their storage
  location and selection logic (by tier/world/direction) are proven.
