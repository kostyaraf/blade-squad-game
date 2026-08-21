# Power Blade 2 — adding a genuine simultaneous second player

Everything below is derived from `Power Blade 2 (USA).nes` (mapper 4/MMC3, 128K PRG,
128K CHR, PRG mode 0: bank 14 fixed at `$C000`, bank 15 fixed at `$E000`), using the
disassembly in `work/re/pair*.asm` / `b14.asm` / `b15.asm` plus live traces from
`work/tools/nesemu`. Every claim cites a bank:address and, where it matters, a trace
line. Bank numbers are physical 8K PRG banks (`pairN.asm` = bank N mapped at `$8000`,
bank N+1 mapped at `$A000`, selected together — see §1).

Traces used, reproducible with:

```
work/tools/nesemu "Power Blade 2 (USA).nes" -frames 705 -input /tmp/boot.inp \
    -trace /tmp/tr705.txt -tracefrom 700 -traceto 703 -tracepc 0000-FFFF
work/tools/nesemu "Power Blade 2 (USA).nes" -frames 703 -input /tmp/boot.inp \
    -trace /tmp/oam.txt -tracefrom 701 -traceto 702 -watch 0200-02FF
work/tools/nesemu "Power Blade 2 (USA).nes" -frames 800 -input work/re/pb2play.inp \
    -ramdump /tmp/ram800.bin
```
(`/tmp/boot.inp`: `python3 -c "print('\n'.join(f'{f} START\n{f+6} -' for f in range(60,1200,40)))" > /tmp/boot.inp`)

---

## 1. Per-frame call chain down to the player update

Confirmed live in `/tmp/tr705.txt` — the exact sequence below repeats once per frame
(lines 1–1629 for frame `$700`, then identically at `$701`, `$702`, `$703`):

```
$E9C7  NMI handler (bank 15, fixed $E000)              PPU housekeeping, OAM DMA
  -> JSR $CC41                (bank 15 -> bank 14, fixed $C000)
$CC41  bank 14                -> JSR $CD0B -> ... (level/object housekeeping)
       ... eventually the $1A state-machine (jump table at $CDD3, bank 14, 13
           entries) reaches its steady gameplay state, $1A == 5 -> loc_CED2.
$CED2  bank 14: JSR sub_D2BE; JSR sub_D23A; selects pair 6, JSR $802F; restores;
       selects pair 10, JSR $8000 (bank10's per-slot "any active object?" scan,
       X = 0..21 over $0400,X); restores; falls into:
$CF22  LDA $79 ; BNE $CF36                              (trace: A=$07, branch taken)
$CF36  JSR $EF00                              (bank 14 -> bank 15, fixed $E000)
$EF00  JMP $EF7D
$EF7D  LDA $27                                (inner per-frame sub-phase, trace: 3)
       JSR $CA0B          (bank 15 -> bank 14 $CA0B: pops the return address, reads
                            an inline 8-entry jump table that follows the JSR at
                            $EF7F, JMPs indirect — NO return to $EF7D)
$EF82  jump table (8 entries); index 3 -> $EFD7
$EFD7  bank 15: LDY #$38 ; JSR sub_ECA7           (masks Y &0x0F = 8, sets MMC3
                                                    R6=8, R7=9: PRG bank 8 at
                                                    CPU $8000, bank 9 at $A000)
       JMP $8000                                  (tail-jump, bank 8, physical)
$8000  bank 8 (pair8.asm, byte 0): JMP $8E15
$8E15  ***THE PLAYER UPDATE*** (bank 8/9 = pair8.asm)
       ... JSR sub_B316 / sub_B570 / sub_A17A / sub_A563 / sub_8E56 (state
       dispatch) / sub_A945 / sub_B69E ...
$8E55  RTS
```
Trace proof (`/tmp/tr705.txt` line 1596-1629, identical at `F701`/`F702`/`F703`):
```
F700 14:CF36 20 00 EF JSR $EF00
F700 15:EF00 4C 7D EF JMP $EF7D
F700 15:EF7D A5 27    LDA $27        A=00 ...
F700 15:EF7F 20 0B CA JSR $CA0B      A=03 ...
F700 14:CA0B 0A       ASL A  ...  (pop ret addr, read table, JMP indirect)
F700 14:CA21 6C 02 00 JMP ($0002)
F700 15:EFD7 A0 38    LDY #$38
F700 15:EFD9 20 A7 EC JSR $ECA7
F700 15:EFDC 4C 00 80 JMP $8000
F700 8:8000  4C 15 8E JMP $8E15
F700 8:8E15  A9 05    LDA #$05       <- player update starts
```
This is exactly one invocation per frame (`grep -c "8:8E15 A9 05"` in a longer trace
== frame count). `player_footprint.txt`'s "422 invocations across 11 trace windows"
is consistent.

**Recommended single wrap point:** the 3 bytes at bank 8 physical offset `$0000`
(CPU `$8000`): `4C 15 8E` (`JMP $8E15`). It is reached **only** through the chain
above (verified: the only other `JSR/JMP $8000` sites in the fixed banks — `b14.asm`
`$CF1C`, `b15.asm` `$EA3A`/`$ECF3`/`$ED0B` — all execute while a *different* PRG pair
(10, 6, 6, 0 respectively) is selected into the `$8000` window, so they target
different code, not `$8E15`). Replacing it with `JSR $8E15 / <context swap> / JSR
$8E15 / <context restore> / RTS` preserves the caller's stack exactly (original was
a tail `JMP`, so the final `RTS` still returns to whoever called `$EF00` — bank 14
`$CF36` — one level up, as before). This needs a few dozen bytes of new code, which
must live in newly-added banks (this ROM has no PRG headroom — see
`ARCHITECTURE.md`).

An equally valid alternative wrap point, if it's preferable to keep the patch out of
bank 8 entirely: `b15.asm $EFD7-$EFDC` (`LDY #$38 / JSR $ECA7 / JMP $8000`, 8 bytes),
in the always-fixed bank 15.

---

## 2. Sprite (OAM) output

**Not built by the player routine.** It is a separate, later, per-frame pass over
the whole 22-slot object array, in a different PRG pair.

Proven with `-watch 0200-02FF` (`/tmp/oam.txt`): every OAM byte written in frame 701
comes from bank **6**, PCs `$80C5`/`$80D1`/`$80F4`/`$811A` (Y, tile, attr, X of one
OAM entry), e.g.:
```
WATCH 701,80C8,6,0204,6E    (Y byte, addr $0204)
WATCH 701,80D4,6,0205,27    (tile)
WATCH 701,80F7,6,0206,41    (attr)
WATCH 701,811D,6,0207,E5    (X byte)
WATCH 701,80C8,6,02C8,6E    (next entry, addr jumped by +0xC4)
```
Entry point: bank 6/7 (`pair6.asm`) `$8038` (called from `b15.asm $EA35` region,
`LDY #$36` → pair 6, `JSR $8000` → `JMP $8038`, once per frame, **before** the
player-state dispatch of §1 runs — i.e. it renders last frame's object state while
this frame's player/enemy logic hasn't run yet, standard for this kind of engine).

Mechanics (`pair6.asm $8038`-`$8135`):
* `$0D` counts *object slots processed* (`CPX #$16`⇒22, the same 22 slots as
  everywhere else).
* `X` is a **rotating OAM/field cursor**, not slot-linear: it starts at `$0B`=`$28`
  (a value that itself advances by `+$44` every frame — deliberate round-robin so
  that when there are more sprites than OAM room, which objects get dropped
  rotates instead of always being the same ones) and advances by `+$C4` (≡ −60,
  mod 256) per rendered object, further advancing inside the object by the same
  `+$C4` per extra metasprite part (loop `loc_80B2`).
* For each slot it checks `$0442,X` (object *type*, `BEQ`⇒skip) and `$042C,X` bit 7
  (`BMI`⇒skip = inactive), then reads position from `$04C6,X`/`$04B0,X` (Y) and
  `$0508,X`/`$04F2,X` (X), and looks up a metasprite-definition pointer by object
  type — **from one of two tables depending on slot number**: `$8148`/`$81B4` for
  `X<6`, `$8C88`/`$8D83` for `X>=6` (`$808F: CPX #$06 ; BCC $809F`). Anything not
  rendered this pass is later hidden (`loc_804B`: writes `$F4` = off-screen Y to
  the remaining unused OAM bytes).

**Consequence for two players:** the composer already iterates the whole object
array unconditionally, keyed off the array's own `active`/`type` bits, **not** off
how many times the player-logic routine ran. So it does **not** need to be touched
at all — running player logic a second time does not by itself duplicate sprites,
and conversely, simply making a second slot "active" with the right type/position
is enough for this existing pass to draw it. The `X<6` vs `X>=6` split (see §4b/§6)
is the one thing that has to be checked against whichever slot P2's avatar lands in.

---

## 3. Input

Read once per frame, bank 15 fixed, `sub_EBB0` at `$EBB0` (called from `$EA1F`,
which the trace shows running **before** the player-state dispatch, at line 167 of
`/tmp/tr705.txt`, well before line 1629's `$8E15`, i.e. in the same frame but a
different, non-nested, call — matches `ARCHITECTURE.md`'s existing note verbatim):

```
$EBB0  X=0; JSR $EBE7          -> reads controller-1 port ($4016) into $00,
                                   controller-2 port ($4017) into $01
       X=2; JSR $EBE7 (again)  -> re-reads into $02/$03 (glitch-detection re-read)
       CMP $00,$02 / CMP $01,$03 -> if either differs, bail to $EBDC (clear both
                                     pads for this frame; a corrupted read is
                                     treated as "nothing pressed")
       X=0; JSR $EBCC ; INX ; <falls through into sub_EBCC body again for X=1>
$EBCC  A = raw,X ; Y = A
       A = (raw,X EOR prev,X) AND raw,X     -> "just pressed" edge bits
       STA $48,X   (X=0) / STA $49,X (X=1)  -> $48 = pad1 just-pressed,
                                                $49 = pad2 just-pressed
       STA $F5,X                            -> duplicate copy ($F5/$F6, used
                                                by non-gameplay menu code, e.g.
                                                pair2.asm $8032 `EOR $F5,X`)
       STY $4A,X / STY $F7,X                -> $4A = pad1 held (raw bits),
                                                $4B = pad2 held; $F7/$F8 = this
                                                frame's raw bits, kept for next
                                                frame's edge calc
```
`sub_EBE7` itself (`$EBE7`) reads the actual hardware port ($4016 for X=0's call,
$4017 for X=2's call) 8 times each with the standard `LSR/ORA/LSR/ROL` bit-merge
idiom (robustness against D0/D1 wiring, not a 2-controller merge).

**So: `$48`/`$4A` = pad 1 (pressed/held), `$49`/`$4B` = pad 2 (pressed/held). The
game genuinely strobes and reads controller port 2 every single frame.** But the
player-update code (`pair8.asm`, all of banks 8/9) **never references `$49` or
`$4B`** — confirmed by exhaustive grep across `pair0/2/4/6/8/10/12.asm`, `b14.asm`,
`b15.asm`: `$4B` is read in exactly one place, `b15.asm $EDE9/$EDEF/$EDF5`, gating a
hidden developer/debug feature (pad-1 START held + a specific pad-2 button combo
→ `INC $19`, a debug counter, plus a sound-test trigger at `$EE04`). `$49` is never
read anywhere in gameplay code. Pad 2 is read into RAM and then thrown away.

**Implication:** to give the second player's pass of the player-update routine its
own input, the simplest and least invasive method is: immediately before the
*second* call to `$8E15`, copy `$49`→`$48` and `$4B`→`$4A` (both already computed
every frame by `$EBB0`, no new controller-read code needed); restore `$48`/`$4A`'s
original (pad 1) values before returning to the normal frame. No other zero page
input variable needs touching.

---

## 4. Complete player context (verified with tracemem)

Method: `work/tools/tracemem.py` walks a trace, tracks the CPU stack pointer from
the moment `8:$8E15` is entered until the matching `RTS`/`RTI` pops back above that
depth, and buckets every RAM access `<$0800` into "written" vs "read-but-never-
written-in-this-call" (i.e. state the routine depends on from a previous frame).
`work/re/player_footprint.txt` is an existing 11-window aggregate; I re-derived and
corrected it against fresh single-session traces and the disassembly (two entries in
the old footprint turned out to be tracing artifacts — see the correction note at
the end of §4a).

### 4a. Zero page

**Genuinely player-private, must be swapped (saved/restored around the 2nd call):**
none of the zero-page bytes the routine merely *reads* turn out to be player-
identity data — see the correction below. The only zero-page bytes that must differ
between the two calls are the **input mirrors**:

| addr | role | handling for P2's pass |
|---|---|---|
| `$48` | pad1 just-pressed (recomputed every frame by `$EBB0`) | before 2nd call: `$48 = $49` (pad2's just-pressed); after: restore |
| `$4A` | pad1 held | before 2nd call: `$4A = $4B`; after: restore |

**Correction to the naive "read-before-write" list** (`player_footprint.txt`
originally listed `$2E,$39,$3A,$48,$4A,$53,$55,$66,$67,$79,$87,$8D,$8E,$8F,$95,$96,
$97,$99,$9A,$A2,$FD,$FF` as read-without-write): cross-checked each against who else
writes it —
* `$53` (stage number), `$79` (boss/no-scroll flag), `$27`/`$1A` (state machine) are
  **global level/engine state**, correctly read as-is by both players' passes; must
  **not** be swapped.
* `$95`/`$96` are written every frame in bank 14's fixed camera code (`$CA6A`,
  `$CA84`, `$CAB3`, ... — camera/scroll X, not player-owned); `$97` is written at
  `b15.asm $E274`; `$FF`/`$87`/`$FD` are written from **many** unrelated pairs
  (`pair0.asm`, `pair10.asm`, `b14.asm` — dozens of sites) — these are shared
  engine scratch (temp registers / camera), not player identity. Both player passes
  correctly want to see the **same** value (same camera, same frame), so leaving
  them alone is correct, not an oversight.
* `$9A` = **current suit index (0-4)**, fully documented in `pb2_suits.md` §2 as a
  save-file-wide progression variable (also gates `$0416` bit checks, drains `$A0`,
  etc). It is read by the player routine (`b8:9363` etc.) but owned by
  pickup/menu code elsewhere. **Left as one global value** unless a design decision
  is made to give P2 an independent suit (see Risks, §7).
* `$39`/`$3A`, `$66`/`$67`, `$8D`-`$8F`, `$A2`, `$2E` are single-read-site values
  (collision-probe pointer bytes, `pb2_collision.md`-style scratch) set earlier in
  the *same* frame by non-player engine code; they behave like `$95`/`$96` above.

**Zero page the player routine writes (true scratch, safe by construction — fully
overwritten before use every single call, confirmed by tracemem: none of these
addresses also appear in the read-before-write list):** `$00-$0D` (pointers/loop
counters, incl. the 8-byte probe-result array `$00-$07` from `pb2_collision.md`
§"Probe geometry"), `$10-$17` (current AABB corners, shared scratch also written by
the generic collision helper `b15.asm sub_$F342`), `$1D`, `$25` (saved slot index
while spawning a shot — see §4b), `$54`. These do **not** need saving/restoring;
running `$8E15` twice back-to-back just recomputes them twice, correctly, as long as
**nothing else runs between the two calls** (true for the recommended wrap point in
§1 — it's a tail call with no intervening code).

**Zero-page bytes that must never be touched by the swap** (mapper/CHR shadows,
confirmed never written from bank 8/9 in the footprint): `$3F`/`$40`/`$41` (current/
saved PRG bank pair), `$42`-`$47` (CHR bank numbers), `$A1`/`$A4` (bank-select
shadow) — all documented in `ARCHITECTURE.md` and touched only from bank 12/15
mapper-switch code.

### 4b. `$0100`-`$07FF`

**The 22-slot object array is 29 parallel one-byte-per-slot field tables**, base
addresses 22 (`$16`) apart, confirmed by the generic "zero one slot" helper
`sub_D6D4` at `b14.asm $D6D4` (writes `#$00` to all 29 addresses `,X` in one pass,
called in a `X=0..21` loop by `sub_D746`/`$D746`, itself the "reset all slots"
routine invoked from the level-setup states, and empirically from inside the
player's own death/respawn handling too — see the risk note in §7):

```
$0400 $0416 $042C $0442 $0458 $046E $0484 $049A $04B0 $04C6 $04DC $04F2 $0508
$051E $0534 $054A $0560 $0576 $058C $05A2 $05B8 $05CE $05E4 $05FA $0610 $0626
$063C $0652 $0668
```
(29 tables × 22 bytes = 638 bytes, `$0400`-`$067D`.) Slot *N*'s byte for field
*F* is at `F+N`. Field semantics established from `pb2_collision.md`/`pb2_suits.md`
plus the disassembly above: `$04C6`/`$04B0`/`$04DC` = Y position
(accumulator/integer/fraction), `$04F2`/`$0508`/`$051E` = X position, `$0534`/
`$054A` = Y velocity/accel, `$0560`/`$0576` = X velocity/accel, `$042C` =
attribute/active bits (bit7 = inactive), `$0442` = object type (indexes the
sprite-metadata tables of §2 and the terrain-probe table of `pb2_collision.md`),
`$058C` = player animation/logic sub-state, `$049A` = HP (0-`$10`, per
`pb2_suits.md`), `$0416` = a bitfield the player and several enemies test directly
(ladder/facing/interaction flags).

**Confirmed: slot 0 = player.** Overwhelming evidence: every write to these 29
tables from bank 8/9 (the player routine itself) uses the **bare, absolute address**
(e.g. `pair8.asm $A21F: 8D 00 04  STA $0400`, `$A1EC: STA $0416`, `$9E30: STA $042C`)
— never `,X` — i.e. the opcode itself is hard-wired to offset 0. `sub_A563`
(`pair8.asm $A563`, called directly from `$8E15` at `$8E26`) is the one place player
code scans *other* slots: `LDX #$01 … CPX #$06`, i.e. **slots 1-5**, checking
`$0400,X` for a "special object" trigger and, on a match, incrementing the player's
own `$0400` (`sub_A573`, `$A57A: JSR $C837 ; INC $0400`). Combined with §2's
`X<6`/`X>=6` sprite-table split and `pb2_suits.md`'s `$0446` = "suit-4 orbiter
object slot flag" (slot 4 of the type-adjacent table), **slots 0-5 are a reserved
"special object" pool** (player + a handful of fixed per-level/per-suit entities),
and **slots 6-21 are the generic dynamic enemy/item/shot pool**.

**Slot 1 is not free.** Live ramdump at frame 800 of `work/re/pb2play.inp`
(`/tmp/ram800.bin`) during ordinary single-player stage-1 play:
```
$0442 slot0=0x52 slot1=0x50      (both ACTIVE object types)
$04C6 slot0=0xC8 slot1=0x18      (distinct Y positions)
$0508 slot0=0x80 slot1=0xD0      (distinct X positions)
```
Slot 1 already holds a live, naturally-spawned object in normal play — it is part
of the generic pool the level/spawner code hands out, not reserved or usually
empty. **A second player cannot simply be hardcoded into "the next slot"; a slot
must be permanently reserved and withheld from the enemy/shot spawner's free-slot
search** (see Risks, §7 — the exact free-slot-search routine was not fully traced).

**Non-array scalars owned by the player, absolute-addressed, must be
saved/restored around the 2nd call:** `$0110` (`INC`ed unconditionally every call,
`$8E1A` — a per-frame counter/timer), `$0111`-`$0113` (a 24-bit accumulator, heavy
`ADC`/`INC`/`DEC` traffic throughout `pair8.asm`, e.g. `$924B-$9263`; distance or
sub-position state for a specific move), `$0116` (set to `#$05` unconditionally at
entry, `$8E17`; **also read back by bank 14's camera-follow code right after the
player update returns** — `b14.asm $D3BE`/`$D3DD`/`$D3E4`, in `loc_D3B8`, reached
from `$CF36`'s continuation `JMP loc_D3B8` — see §6), `$0117`/`$0118`/`$011F`
(cleared unconditionally at both entry and near-exit, `$8E4C`/`$8E4F`/`$8E52`;
`$011F` is also the base of a short `,Y`-indexed sub-table, `pair8.asm $9F65`/
`$ACA1`, extent not fully verified — treat conservatively as `$0110-$013F`, flagged
as an open item in §7).

**Correction — not player state:** `player_footprint.txt` listed `$01EF`/`$01F0` as
written by `b9:$B125`/`$B12C`. Disassembly shows the actual instructions are
`STA $0103,X` / `STA $0104,X` inside `sub_B116` (`pair8.asm $B116`), which begins
with `TSX` — **X is the CPU stack pointer**, and this is the documented
(`pb2_collision.md` §"inline-argument convention") trick of reading bytes that
follow a `JSR` on the stack to fetch inline call arguments. `$01EF`/`$01F0` were
simply whatever the live SP happened to be at trace time; this is **stack
machinery, not player RAM**, and must be excluded from any swap set.

### 4c. Must NOT be swapped (global)

`$27`,`$1A` (frame/level state machines), `$53` (stage), `$79` (boss/no-scroll),
`$9A`/`$56`/`$A0`/`$9E`/`$9D`/`$9F`/`$AF`/`$4D` (suit/progression/lives, all
documented in `pb2_suits.md` §2), `$45` (PPU CHR bank register — shared hardware,
can't be split per player), `$95`/`$96`/`$97` (camera/scroll), `$0119` (global
per-frame parity toggle used by several systems, e.g. `pair10.asm $8017 INC $0119`
then `EOR $0119` at `pair10.asm $9456`/`b15.asm $FB82` etc., for round-robin
AI/collision staggering — confirmed shared across pairs, not player-specific),
`$3F`/`$40`/`$41`/`$42`-`$47`/`$A1`/`$A4` (mapper/CHR shadows), `$0680`-`$06FF`
(terrain class cache, `pb2_collision.md` §3, camera-relative not player-relative).

---

## 5. Fixed vs. indexed addressing (where P1/P2 would collide)

* **All of the player's own object-array field writes are fixed/absolute**
  (`STA $0400`, `STA $0416`, `STA $042C`, ... — no `,X`). This is *the* structural
  obstacle: simply calling `$8E15` twice does not make the second call operate on a
  different slot — it would clobber slot 0 twice. This is why §7's swap approach
  (temporarily exchange slot 0 and slot N's 29 bytes around the second call) is
  required, rather than e.g. passing a slot number in X.
* **Writes to objects the player *spawns*** (its shots) already use `,X`, with X
  loaded from a found/free slot index held in `$25` — e.g. `pair8.asm $A226: TXA ;
  LDX $25 ; STA $05CE,X`, `$A22F: STA $042C,X`. This part of the code is already
  slot-agnostic and needs no change.
* **The zero-page scratch** (`$00-$17`, `$1D`, `$25`, `$54`) is absolute too, but
  because it's fully recomputed every call (§4a) that's harmless as long as the two
  calls are back-to-back.
* **The generic engine helpers are already indexed** and slot-agnostic:
  `sub_D6D4`/`sub_D746` (clear-slot), the pair-10 object scan (`$0400,X` loop,
  `pair10.asm` entry `$8000`/`$803E`), the sprite composer of §2 (`$0442,X` etc.),
  the generic AABB helper `sub_F342` (`b15.asm`, takes X as a parameter). These
  would work unmodified against a second player slot.
* **Enemy-vs-player checks hardcode slot 0** on the "player side" of the
  comparison while indexing the enemy side by X — see §6.

---

## 6. Enemy/level collision against the player

**Reads the object array at slot 0 via absolute addressing — not a zero-page
mirror.** Zero page `$10-$17` is a transient AABB workspace recomputed for
whichever pair of objects is currently being tested (§4a); it is not "the player's
hitbox" persistently. Direct evidence, all *outside* the player's own pair
(bank 8/9), i.e. genuinely on the enemy/engine side:

* `pair10.asm sub_$8D92` (`$8D99`): `LDA $0508,X ; SEC ; SBC $0508` — enemy's own X
  position minus the bare `$0508` (player's X, slot 0) — proximity/targeting check.
* `pair10.asm sub_$AB02` (`$AB06`): `LDA $0416` (player's bare bitfield) combined
  with `$042C,X EOR $042C` (enemy vs. player facing) — a grab/interaction check
  gated by `$9A` (suit).
* `b15.asm loc_$FB4B` (`$FB50`): `LDA $04C6,X ; SEC ; SBC $04C6` — enemy Y vs.
  player's bare `$04C6` — feeds into `sub_$F342`'s generic AABB overlap test used by
  the shot/enemy/player damage-collision callers (`$FB9E`, `$FBBE`, `$FBCC`, `$FC02`,
  `$FC0B`).
* Similar bare references exist in `pair0.asm`, `pair6.asm`, `b14.asm`, `b15.asm`
  (22, 22, 15, 29 raw hits respectively for the field bases listed in §4b) — a full
  enumeration of every site was not completed (see §7); the ones above are
  representative, confirmed examples, not the complete list.
* **The camera also hardcodes slot 0**: `b14.asm loc_$D3B8` (reached immediately
  after the player-update call returns, from `$CF36`'s `JMP loc_D3B8`) computes the
  scroll target from the bare `$0508`/`$04C6` (player position) and `$0116` (a
  value the player routine sets during its own update, §4b).

**What would have to change for enemies (and the camera) to also react to a second
player:** every one of these hardcoded "vs. slot 0" comparisons would need to either
(a) be patched to also test the second player's slot, which means finding and
editing on the order of dozens of scattered call sites across most PRG pairs, or
(b) be exercised twice via the same slot-swap trick as §1/§7, but this only works
for a *self-contained, once-per-object* routine — it does **not** work for the
enemy AI/movement update as a whole, because that update is one pass over all 22
slots per frame; re-running the whole pass with slots swapped would move every
enemy twice as fast. A pragmatic middle ground (see §7) is to alternate, frame by
frame, which player occupies slot 0 for the purposes of enemy AI/collision and the
camera, so both players are eventually targetable/followed, at half temporal
resolution each.

---

## 7. Recommended implementation sketch

1. **Reserve slot 21** (last object slot) exclusively for player 2. Patch the
   enemy/shot free-slot allocator (not yet located exactly — see Unknowns) to treat
   slot 21 as permanently taken, e.g. by capping its search range to `X < 21`.
2. **Per frame, at the wrap point identified in §1** (bank 8 physical `$0000`,
   currently `JMP $8E15`), replace with:
   ```
   JSR $8E15                     ; run player 1 (slot 0, pad 1) exactly as today
   JSR NEW_SWAP_TO_P2             ; swap slot0<->slot21 (29 bytes) + $0110-$013F
                                   ; P1<->P2 shadow, redirect $48/$4A <- $49/$4B
   JSR $8E15                     ; run "slot 0" again -- now actually P2's data
   JSR NEW_SWAP_BACK_TO_P1         ; swap back, restore $48/$4A
   RTS
   ```
   `NEW_SWAP_*` reuses the exact 29-address table already embedded in
   `sub_D6D4`/`b14.asm $D6D4` (repurposed: instead of storing `#$00` to each
   `addr,X`, `LDA addr+0 / TAY / LDA addr+21 / STA addr+0 / STY addr+21` for each of
   the 29 bases, i.e. exchange slot 0 and slot 21), plus explicit swaps of
   `$0110-$013F` and the `$48/$4A <-> $49/$4B` redirect from §3. This code is new
   and must live in one of the new banks the wider PB3 project already plans to add
   (`ARCHITECTURE.md`); there is no free space in the original image.
3. **Do not touch** the OAM composer (§2) — it already renders whatever is active
   in slot 21 automatically once step 2 makes it valid.
4. **Enemy/camera awareness of P2** (§6) is the expensive part and is *not* required
   for a first playable milestone (P2 can move, shoot, collect, and be drawn, but
   won't be hit by enemies and won't move the camera) — see Risks below for how to
   phase it in.
5. Order within the frame matters: the double-call must happen exactly where the
   original single call happened (between the per-frame object-active scan and the
   camera-follow code), and the two `$8E15` invocations must be strictly
   back-to-back with no other code between them, because §4a's zero-page scratch is
   only safe under that assumption.

---

## Risks and unknowns

* **Free-slot allocator not located.** `pair8.asm sub_$A403` (called from the shot-
  spawn path at `$A205`) turned out on inspection to be a weapon/direction dispatch,
  not the free-slot search. The routine that actually picks a free slot for a new
  shot/enemy (and that must be told to skip the reserved P2 slot) needs a fresh trace
  (watch writes to `$042C,X` with the "activate" bit set, from a fresh/previously-
  inactive slot, across many spawn events).
* **`$0110-$013F` upper bound is not fully verified.** `$011F` is used both as a
  scalar and as the base of a `,Y`-indexed table (`pair8.asm $9F65`, `$ACA1`); the
  Y range was not established. The swap set below conservatively covers through
  `$013F`; if the real table is longer this would need widening.
* **Suit/progression (`$9A`, `$56`, `$A0`, `$9E`, `$9D`, `$9F`) is currently
  designed as global, one-per-savefile.** Whether P2 shares P1's suit/lives/energy
  or gets independent copies is a game-design decision this document does not make;
  either choice is mechanically possible (shared = no change; independent = extend
  the swap set to include these, and duplicate the pickup-grant logic in
  `pb2_suits.md` §3, which currently writes them unconditionally as globals).
* **Enemy-vs-player and camera-vs-player hardcoding (§6) is pervasive, not a single
  choke point.** A full inventory of every bare reference to the 29 field-table
  bases outside pair 8/9 was not completed (counts only: 22 in `pair0.asm`, 22 in
  `pair6.asm`, 6 in `pair10.asm`, 15 in `b14.asm`, 29 in `b15.asm` — some of these
  are almost certainly unrelated to player-vs-enemy specifically, e.g. terrain
  lookups). Treat "enemies can hit/be hit by P2" and "camera follows P2" as a
  separate, larger follow-up task; the pragmatic first step is alternating which
  player occupies slot 0 for AI/camera purposes on alternating frames (cheap: swap
  slot 0 and 21 *once* per frame instead of twice, right before the object-active
  scan at `$CED2`, rather than around `$8E15`).
* **Slot 0's death/respawn logic appears able to invoke the generic "clear all 22
  slots" helper (`sub_D746`) from inside `$8E15`'s own call tree** (this is how
  `b14:$D6D6`-family addresses ended up in the original `player_footprint.txt`
  despite `sub_D746`'s only static callers being outside the player routine). If
  true, **player 1 dying could wipe player 2's object-array state along with every
  enemy's**, mid-frame, before P2's pass even runs. This needs to be re-confirmed
  with a trace that captures an actual death, and patched (e.g. skip slot 21 in the
  reset loop) before shipping co-op.
* **Two-controller detection**: nothing in the ROM currently gates gameplay on
  whether a second controller is physically present; `$49`/`$4B` will simply read
  all-zero with no pad 2 plugged in (§3), so P2 would sit idle rather than the game
  refusing to start. Whether that's the desired behavior, or an explicit "players:
  1/2" menu should be added, is a design decision.

---

## Byte-range dict for a build script

Zero-page and low-RAM ranges to save/redirect around the second `$8E15` call
(inclusive `(lo, hi)` byte ranges unless noted). `object_fields` gives the 29
field-table base addresses (one byte per slot; slot N is `base+N`) rather than a
range, since they are not contiguous.

```python
TWO_PLAYER_CONTEXT = {
    # input redirect (P2's pass reads pad-2 data through P1's variables)
    "input_redirect": {
        "pad_pressed": (0x0048, 0x0048),   # $48 <- $49 before call, restore after
        "pad_held":    (0x004A, 0x004A),   # $4A <- $4B before call, restore after
    },

    # object array: one byte per slot at base+slot; swap slot0 <-> P2_SLOT here
    "object_fields": [
        0x0400, 0x0416, 0x042C, 0x0442, 0x0458, 0x046E, 0x0484, 0x049A,
        0x04B0, 0x04C6, 0x04DC, 0x04F2, 0x0508, 0x051E, 0x0534, 0x054A,
        0x0560, 0x0576, 0x058C, 0x05A2, 0x05B8, 0x05CE, 0x05E4, 0x05FA,
        0x0610, 0x0626, 0x063C, 0x0652, 0x0668,
    ],
    "object_field_stride": 0x16,   # 22 slots, 0..21
    "object_field_slot_count": 22,
    "recommended_p2_slot": 21,     # must also be excluded from the free-slot
                                    # allocator (unlocated, see Risks)

    # non-indexed player scalars outside the object array; swap whole range
    "player_scalars": [
        (0x0110, 0x013F),  # counter/accumulator/weapon-slot block; upper bound
                             # ($0120-$013F) is a conservative guess, unverified
    ],

    # explicitly excluded even though tracemem's raw "reads without writes"
    # list included them -- shared engine/camera scratch, must NOT be swapped
    "global_do_not_swap": [
        0x0027, 0x001A,             # frame / level state machines
        0x0053, 0x0079,             # stage number, boss/no-scroll flag
        0x009A, 0x0056, 0x00A0, 0x009E, 0x009D, 0x009F, 0x00AF, 0x004D,
                                     # suit / progression / lives (pb2_suits.md)
        0x0045,                     # PPU CHR bank register (shared hardware)
        0x0095, 0x0096, 0x0097,     # camera/scroll
        0x0119,                     # global per-frame parity toggle
        0x003F, 0x0040, 0x0041,     # PRG bank-pair current/saved
        0x0042, 0x0043, 0x0044, 0x0046, 0x0047,  # CHR bank numbers
        0x00A1, 0x00A4,             # bank-select shadow
        (0x0680, 0x06FF),           # terrain class cache (camera-relative)
    ],

    # confirmed NOT player state despite appearing in the raw trace footprint
    # (stack-relative addressing artifacts inside sub_B116's inline-arg trick)
    "trace_false_positives": [0x01EF, 0x01F0],
}
```
