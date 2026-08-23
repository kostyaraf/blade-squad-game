# PB3 multicart mapper — research, decision, and implementation spec

**Verdict up front: your plan is correct, and the mapper that implements it exactly is
iNES Mapper 045.** With PRG-AND set to "256 KiB" the MMC3's fixed `$C000`/`$E000`
windows land on block positions 30 and 31 — precisely the layout you sketched.
Two 256 KiB blocks = 512 KiB PRG. Mapper 52 also implements the same idea and is
simpler, but **Nestopia's mapper 52 lets the outer register be written only once per
power-on**, which kills runtime block switching, and its CHR bit assignment disagrees
with FCEUX/Mesen. So: **mapper 45**.

Three things about mapper 45 that you must design around and that the wiki does not
tell you (all verified in emulator source, cited below):

1. **The wiki's `$6001` "reset outer registers + unlock" is implemented by nobody.**
   Mesen2, Nestopia, puNES and libretro-fceumm do not decode A0 at all; FCEUX master
   decodes it but only clears the lock bit. ⇒ **Never set the lock bit.**
2. **The write index is only reset at power-on/reset.** ⇒ **Always write exactly four
   bytes to `$6000` per configuration**, so the index returns to 0.
3. **Current FCEUX master (since commit `764e1ebd76`, 2023-10-26) has a mapper-45
   regression** that removes the AND-masking of the MMC3 bank. Under that build your
   cart's block 1 collapses onto block 0. FCEUX **2.6.6 and earlier are correct**;
   libretro's fceumm fork is correct; see §5.

---

## 1. Candidate mappers — transcribed register behaviour

Every register description below is transcribed from the NESdev wiki page named in
the heading. Where the wiki is Disch's old notes rather than a hardware description
I say so.

### 1.1 MMC3 (mapper 4) — the baseline

Source: <https://www.nesdev.org/wiki/MMC3>

```
Bank select   ($8000-$9FFE, even)   CPMx xRRR
                                    |||   +++- R0..R7 select
                                    ||+------- (MMC6 only)
                                    |+-------- P: PRG mode
                                    +--------- C: CHR A12 inversion
Bank data     ($8001-$9FFF, odd)
Mirroring     ($A000-$BFFE, even)   ....... M   0=vertical, 1=horizontal
PRG RAM prot. ($A001-$BFFF, odd)    RW.. ....   R=enable, W=write-protect
IRQ latch     ($C000-$DFFE, even)
IRQ reload    ($C001-$DFFF, odd)
IRQ disable   ($E000-$FFFE, even)
IRQ enable    ($E001-$FFFF, odd)
```

PRG map:

| CPU window | `$8000.6 = 0` (PRG mode 0) | `$8000.6 = 1` |
|---|---|---|
| `$8000-$9FFF` | R6 | **(-2)** |
| `$A000-$BFFF` | R7 | R7 |
| `$C000-$DFFF` | **(-2)** | R6 |
| `$E000-$FFFF` | **(-1)** | **(-1)** |

> "(-1) : the last bank / (-2) : the second last bank"
> "R6 and R7 will ignore the top two bits, as the MMC3 has only 6 PRG ROM address lines."
> "Because the values in R6, R7, and $8000 are unspecified at power on, the reset
> vector must point into $E000-$FFFF, and code must initialize these before jumping
> out of $E000-$FFFF."
> — <https://www.nesdev.org/wiki/MMC3>

**This is the key fact for the whole design:** the MMC3 does not "know" the ROM size.
It puts a hard-wired all-ones pattern on PRG A13..A18 for `$E000` (`$3F`) and
all-ones-minus-one for `$C000` (`$3E`). Any multicart mapper that ANDs the MMC3's
PRG A13..A18 output with a block mask therefore gets **block-relative fixed banks for
free**. That is exactly what mappers 44, 45, 47, 49, 52, 205 do.

Both your games are PRG mode 0 (`$8000.6 = 0`), so `$C000` = (-2) and `$E000` = (-1).

**Mapper 4 submappers** (<https://www.nesdev.org/wiki/NES_2.0_submappers>):
0 = MMC3C/normal sharp IRQ, 1 = MMC6, 2 = deprecated (was "MMC3 with no WRAM"),
3 = MMC3A / "NEC" alternate IRQ, 4 = MMC3A revA IRQ, 5 = T9552 scrambling.
None of them add banking capacity — there is no "mapper 4 with an outer bank".
Oversized mapper 4 (8-bit R6/R7, up to 2 MiB) exists as a romhack convention but the
wiki explicitly warns it is "deliberately not supported by many emulators", and it
still gives you a single global last bank. Not usable here.

---

### 1.2 iNES Mapper 045 — GA23C  ← **CHOSEN**

Source: <https://www.nesdev.org/wiki/INES_Mapper_045> (a real hardware description,
not Disch notes).

> "iNES Mapper 045 denotes multicart PCBs using the GA23C ASIC in its standard
> configuration. It is an MMC3 clone with four outer bank registers."
> "The four outer bank registers are accessed at address $6000. The first write goes
> to the first register, the second write to the second, and so on; the fifth write
> goes to the first register again. **The outer bank registers overlay WRAM and
> function regardless of the MMC3's WRAM bits' setting.**"

MMC3-compatible registers `$8000-$FFFF` behave identically to MMC3, "with the PRG/CHR
bank registers subject to masking by the outer bank registers."

```
CHR-OR LSB                      ($6000 #0, write)   Mask: $F001
  D~7654 3210
    CCCC CCCC
    ++++-++++- CHR A10-A17, OR'd with MMC3's CHR A10-A17 masked according to CHR-AND

PRG-OR LSB                      ($6000 #1, write)   Mask: $F001
  D~7654 3210
    ppPP PPPP
    ||++-++++- PRG A13-A18, OR'd with MMC3's PRG A13-A18 masked according to PRG-AND
    ++-------- PRG A19-A20

CHR-AND, CHR-OR/PRG-OR MSB      ($6000 #2, write)   Mask: $F001
  D~7654 3210
    PPCC cccc
    |||| ++++- number of CHR bits taken from the MMC3
    ||||       ($F: 256 KiB, $E: 128 KiB ... $7-$0: 1 KiB)
    ||++------ CHR A18-A19
    ++-------- CHR A20-A21 and PRG A21-A22

PRG-AND, register lock          ($6000 #3, write)   Mask: $F001
  D~7654 3210
    1LPP PPPP
     |++ ++++- PRG-AND mask (INVERTED) ($00: 512 KiB, $20: 256 KiB ...)
     +-------- 1 = Lock outer bank registers

Reset outer bank registers      ($6001, write)      Mask: $F001
  "Writing any value to $6001 resets the outer bank registers as a soft reset would,
   clearing the 'Lock' bit and making the next write to $6000 go to register #0."
```

Also on the page: a DIP-switch read port at `$5000-$5FFF` (returns D0 = 1 when the
address bit matching the DIP position is set) and a "menu selection #2" scheme where a
high address line is wired to PRG /CE. **Neither matters for PB3** — but note that
libretro-fceumm and puNES implement the `$5000-$5FFF` read port, so `$5000-$5FFF`
reads are *not* open bus on those cores. Do not use `$5000-$5FFF` for anything.

**Derived arithmetic** (this is the formulation used by puNES and libretro-fceumm and
is the one to implement):

```
prg_and = (~reg3) & 0x3F                    # $20 -> 0x1F -> 256 KiB block
prg_or  = reg1 | ((reg2 & 0xC0) << 2)       # 10 bits => PRG A13..A22, max 8 MiB
phys_8k = (mmc3_prg_bank & prg_and) | (prg_or & ~prg_and)

chr_and = 0xFF >> ((~reg2) & 0x0F)          # $F -> 0xFF -> 256 KiB block
chr_or  = reg0 | ((reg2 & 0xF0) << 4)       # 12 bits => CHR A10..A21, max 4 MiB
phys_1k = (mmc3_chr_bank & chr_and) | (chr_or & ~chr_and)
```

Check the CHR-AND encoding against the wiki table: `$F` → `0xFF >> 0` = `$FF` = 256
pages = 256 KiB ✔; `$E` → `0xFF >> 1` = `$7F` = 128 KiB ✔; `$8` → `0xFF >> 7` = `$01`
= 2 KiB ✔; `$7`…`$0` → shift ≥ 8 → `0` = 1 KiB ✔.

**Answers to your §2 questions for mapper 45:**

| Question | Answer |
|---|---|
| Max PRG | 8 MiB (PRG A13-A22: `reg1` 8 bits + `reg2` bits 6-7) |
| Max CHR | 4 MiB (CHR A10-A21: `reg0` 8 bits + `reg2` bits 4-7) |
| Block size configurable? | **Yes**, PRG in powers of two from 8 KiB to 512 KiB via PRG-AND; CHR from 1 KiB to 256 KiB via CHR-AND. PRG and CHR block sizes are independent. |
| Fixed banks block-relative? | **Yes** — the AND mask is applied to the MMC3's `$3E`/`$3F` fixed-bank output |
| Block selection | 4 sequential byte writes to `$6000`; works regardless of the MMC3 WRAM enable bits |
| Survives stray `$6000-$7FFF` writes? | **No** unless you set the lock bit — and the lock is effectively one-way (see §5). Mitigation in §7.3. |
| Power-on / reset state | `reg0 = reg1 = reg3 = 0`, index = 0 in every implementation. `reg2` is `$00` in Nestopia/FCEUX and `$0F` in Mesen2/fceumm/puNES — **wiki does not specify**. With `reg3 = 0` the PRG mask is `$3F`, so **`$E000` at power-on is physical 8 KiB bank 63** regardless of ROM size. |

---

### 1.3 iNES Mapper 044 — BMC SUPERBIG 7-IN-1

Source: <https://www.nesdev.org/wiki/INES_Mapper_044> (Disch notes).

```
Range,Mask: $8000-FFFF, $E001
$A001: [EW.. .BBB]   E,W = normal MMC3 PRG-RAM protect bits; B = Block select
Selecting block 7 is the same as selecting block 6.

Block   PRG-AND  PRG-OR   CHR-AND  CHR-OR
  0       $0F     $00       $7F     $000
  1       $0F     $10       $7F     $080
  ...
 6,7      $1F     $60       $FF     $300
"All MMC3 selected pages are chosen from the given block (including fixed pages)."
Powerup: "Block 0 must be selected at powerup"
```

Max PRG/CHR 1 MiB. Fixed banks **are** block-relative. **Disqualified because the
block register lives inside MMC3 `$A001`** — the games' own PRG-RAM-protect writes
would silently change the block (e.g. `LDA #$80 / STA $A001` selects block 0), and
only block 6 is 256 KiB.

---

### 1.4 iNES Mapper 047 — Super Spike V'Ball + Nintendo World Cup

Source: <https://www.nesdev.org/wiki/INES_Mapper_047> (Disch notes).

```
$6000-7FFF: [.... ...B]  Block select    ("only writable when MMC3 PRG-RAM is
$8000-FFFF: Same as MMC3 for selected block   enabled and writable, see $A001")
Each block has 128k PRG and 128k CHR.
```

Fixed banks block-relative (Mesen2 `MMC3_47.h`: `page &= 0x0F; if(block==1) page |= 0x10;`).
**Disqualified: 128 KiB blocks, 256 KiB PRG total.** No room for new banks at all.

---

### 1.5 iNES Mapper 049 — Super HIK 4-in-1

Source: <https://www.nesdev.org/wiki/INES_Mapper_049> (Disch notes).

```
$6000-7FFF: [BBPP ...O]   B=Block, P=32k PRG reg, O=PRG mode (0=32k mode)
            (writable only when MMC3 PRG-RAM is enabled+writable)
Each block is 128k PRG and 128k CHR.   $6000 set to 0 on powerup.
```

Max 512 KiB PRG / 512 KiB CHR, 4 blocks. Fixed banks block-relative when `O=1`.
**Disqualified: 128 KiB blocks.**

---

### 1.6 iNES Mapper 052 — Realtec 8213 (runner-up, rejected)

Source: <https://www.nesdev.org/wiki/INES_Mapper_052> (hardware description).

```
Outer Bank Register ($6000-$7FFF, write)
 D~[LTCc SBPp]
    |||| ||++-- PRG A18..A17
    |||| |+---- PRG/CHR A19
    |||| +----- PRG A17 mode: 0=from MMC3, 1=from p
    ||++------- CHR A18..A17
    |+--------- CHR A17 mode: 0=from MMC3, 1=from c
    +---------- 1=Lock Outer Bank register until next reset
 Value on reset: $00
"The MMC3's WRAM interface must be enabled and writeable in MMC3 register $A001.
 The Outer Bank Register overlaps any actual PRG RAM that may be present."
```

With `T = 0` the MMC3 supplies PRG A13..A17 → **256 KiB block**, exactly what we need;
outer bit 1 = PRG A18 = block select; outer bit 5 = CHR A18 = CHR block select. One
single byte write (`$00` for block 0, `$22` for block 1), explicit `$00` reset value,
max 1 MiB PRG / 1 MiB CHR. Genuinely attractive — **and rejected for two reasons**:

* **Nestopia allows the register to be written exactly once per power-on.**
  `source/core/board/NstBoardBmcMarioParty7in1.cpp`, `NES_POKE_AD(MarioParty7in1,6000)`:
  ```cpp
  if (exRegs[1]) { /* treat as WRAM */ }
  else { exRegs[1] = 1; exRegs[0] = data; Mmc3::UpdatePrg(); Mmc3::UpdateChr(); }
  ```
  <https://github.com/0ldsk00l/nestopia/blob/master/source/core/board/NstBoardBmcMarioParty7in1.cpp>
  Runtime block switching is impossible there.
* **The CHR bit assignment is disputed.** FCEUX/Mesen2 put CHR A18 on outer bit 5;
  Nestopia puts it on bit 2 and CHR A19 on bit 5. Compare
  `M52CW` in <https://github.com/TASEmulators/fceux/blob/master/src/boards/mmc3.cpp>
  (which even carries the comment *"actually 256K CHR banks index bits is inverted!"*)
  against `MarioParty7in1::UpdateChr` in Nestopia. A cart that works in one will show
  wrong tiles in the other.

---

### 1.7 iNES Mapper 205 — BMC-JC-016-2

Source: <https://www.nesdev.org/wiki/INES_Mapper_205>.

Disch's table claims four 128/256 KiB blocks, but the wiki's own hardware note
overrides it: *"Q1 directly connects to PRG A18 and CHR A18, and both ROMs' A17 pins
are `Q0 + A17·/Q1`"*. Working that out gives **one** 256 KiB block (mode 0) and three
128 KiB blocks (modes 1-3), 512 KiB max. **Disqualified: only one 256 KiB block.**

---

### 1.8 Mappers 114 / 115 / 245 — not multicart mappers

* **115** (<https://www.nesdev.org/wiki/INES_Mapper_115>) — Kǎshèng SFC-02B/-03/-004.
  `$6000` = NROM-override/mode + PRG A18, `$6001` = CHR A18, power-on `$00`.
  Registers work regardless of WRAM enable. But there is **no AND mask**: the MMC3's
  PRG A17..A14 either come from the MMC3 or are replaced wholesale by the register.
  The MMC3 fixed `$E000` bank is not confined to a block. 512 KiB PRG / 512 KiB CHR.
  **Disqualified — no block-relative fixed bank.**
* **114** — same `$6000`/`$6001` registers as 115 plus MMC3 register/index scrambling
  and NEC IRQ behaviour. Same disqualification, plus scrambling.
* **245** (<https://www.nesdev.org/wiki/INES_Mapper_245>) — Waixing F003. Repurposes
  the MMC3 CHR A11 output as PRG A19 to reach 1 MiB with CHR-RAM only. There is no
  outer AND mask and no CHR-ROM. **Disqualified.**
* **215** (<https://www.nesdev.org/wiki/INES_Mapper_215>, UNL-8237) — actually *does*
  give block-relative 256 KiB blocks (`$5000` bit 6 = 0 ⇒ PRG/CHR A17 from MMC3,
  `$5001` supplies A18/A19). But it adds selectable MMC3 address/data scrambling, has
  a `$xF` power-up value for `$5001`, resets its outer register on M2 interruption,
  and has far thinner emulator coverage than 45. Viable fallback, not the pick.
* **268** (COOLBOY/MINDKIDS, <https://www.nesdev.org/wiki/NES_2.0_Mapper_268>) — up to
  32 MiB PRG and block-relative masking (`$xxx0` bit 6 = "PRG mask: PRG A17 from
  0: MMC3; 1: offset"), but almost every variant is **CHR-RAM only** (only the
  JTH-813 submapper has CHR-ROM), and the submapper zoo is a compatibility minefield.
  Consider only if you later need >1 MiB PRG and switch to CHR-RAM.
* **37 / 44 / 47 / 49 / 205** are the "Nintendo-style" small multicarts, all covered above.

---

## 2. Decision

**Use iNES Mapper 045, submapper 0, with a 256 KiB PRG block and a 256 KiB CHR block.**

Why it wins:

* It is the only widely-implemented mapper with a **programmable** block size *and*
  block-relative fixed banks *and* enough address space, and its outer registers are
  independent of the MMC3 WRAM enable bits (so no `$A001` dance is required).
* Its AND/OR structure is exactly your plan: with PRG-AND = `$20` (256 KiB), the
  MMC3's `$3E`/`$3F` fixed outputs become block positions 30 and 31.
* It has by far the largest install base of any MMC3 multicart mapper (hundreds of
  Chinese N-in-1 carts), so it is implemented in every serious emulator.
* It leaves headroom: if 128 KiB of new code per game turns out not to be enough, you
  change one byte (PRG-AND `$20` → `$00`) and go to 512 KiB blocks / 1 MiB ROM
  without touching anything else.

Your proposed layout is **correct as written**, with one correction: which block boots.

---

## 3. Cartridge layout

### 3.1 PRG — 512 KiB, 64 × 8 KiB banks

```
phys bank   file offset      block   block pos   content
---------   --------------   -----   ---------   -----------------------------------
 0 .. 13    $00000-$1BFFF      0       0..13     Power Blade 2 banks 0..13 (verbatim)
14 .. 29    $1C000-$3BFFF      0      14..29     PB3 new code, copy A (128 KiB)
   30       $3C000-$3DFFF      0        30       Power Blade 2 bank 14  -> $C000
   31       $3E000-$3FFFF      0        31       Power Blade 2 bank 15  -> $E000
32 .. 45    $40000-$5BFFF      1       0..13     Solbrain banks 0..13 (verbatim)
46 .. 61    $5C000-$7BFFF      1      14..29     PB3 new code, copy B (128 KiB, identical to copy A)
   62       $7C000-$7DFFF      1        30       Solbrain bank 14       -> $C000
   63       $7E000-$7FFFF      1        31       Solbrain bank 15 + PB3 BOOT STUB -> $E000
```

(Add `$10` to every file offset for the 16-byte header.)

The 128 KiB of new code is stored **twice**, once per block. That is the price of the
scheme and it is unavoidable: an 8 KiB window at `$8000` can only reach banks inside
the current block. Build both copies from the same source; they must be
byte-identical except for anything that legitimately differs per game.

### 3.2 Which block boots — the one correction to your plan

At power-on every implementation has `reg1 = reg3 = 0`, i.e. **PRG-AND = "512 KiB"
(mask `$3F`) and PRG-OR = 0**. The MMC3 puts `$3F` on its fixed-`$E000` output, so
`$E000` maps to **physical 8 KiB bank 63** — the *last* bank of the *first 512 KiB* of
the ROM, independent of how big the ROM actually is. The 6502 fetches its reset vector
from `$FFFC`, which is inside that bank.

**⇒ Physical bank 63 (`$7E000`-`$7FFFF`) must contain the PB3 boot stub and the reset
vector.** In the layout above that bank is block 1 position 31 = Solbrain's bank 15.
So: put **Solbrain in block 1** and patch its bank 15 to carry the boot stub, or swap
the games. Either way, the second block's `$E000` bank is the boot bank.

This has a very pleasant consequence: **configuring block 1 from the power-on state
does not move `$E000`.**

```
power-on:            $E000 = (0x3F & 0x3F) | 0x00 = 0x3F  -> bank 63
after write #1 ($20): $E000 = (0x3F & 0x3F) | 0x20 = 0x3F  -> bank 63   (mask still $3F)
after write #3 ($20): $E000 = (0x3F & 0x1F) | 0x20 = 0x3F  -> bank 63   (mask now $1F)
```

so the boot stub can do the whole four-byte configuration in place, from ROM, with no
trampoline. `$C000` likewise stays at bank 62 throughout. Only a *later* switch to
block 0 needs the trampoline of §7.

### 3.3 CHR — 512 KiB, 512 × 1 KiB pages

Set CHR-AND = `$F`, i.e. the MMC3 supplies a full 8-bit (256 KiB) CHR page number, and
put the CHR block base on a 256 KiB boundary:

```
1K page      file offset      block   content
---------    --------------   -----   ---------------------------------------------
$000-$07F    $00000-$1FFFF      0     Power Blade 2 CHR, verbatim (128 KiB)
$080-$0FF    $20000-$3FFFF      0     new CHR for PB3-in-PB2 (128 KiB)
$100-$17F    $40000-$5FFFF      1     Solbrain CHR, verbatim (128 KiB)
$180-$1FF    $60000-$7FFFF      1     new CHR for PB3-in-Solbrain (128 KiB)
```

Because each original game has only 128 KiB of CHR, it only ever writes MMC3 CHR bank
values `$00`-`$7F`; those pass through the `$FF` mask unchanged and land in the lower
half of the block. **PB3 code writes `$80`-`$FF` to reach the new tiles**, in the same
block, without touching the outer registers. This is much nicer than swapping CHR
blocks wholesale.

*Trade-off:* with mask `$FF` a buggy/garbage high bit in a game's CHR write would now
reach new tiles instead of being folded back. If you want bit-exact original CHR
behaviour instead, use CHR-AND = `$E` (mask `$7F`, 128 KiB CHR block) and select
between four 128 KiB CHR blocks with `reg0` bit 7 and `reg2` bit 4 — at the cost of
having to switch the whole CHR block to draw new tiles.

*Cheaper variant:* if you drop new CHR entirely, use 256 KiB CHR total
(CHR-AND `$E`, `reg0`/`reg2` selecting the 128 KiB half) and set header byte 5 to
`$20`. Everything else is unchanged.

---

## 4. Exact register programming

### 4.1 The four bytes

Compute them as:

```
reg0 = CHR block base page & $FF                     (CHR A10..A17)
reg1 = PRG block base 8K-bank & $FF                  (PRG A13..A20)
reg2 = chr_size_code | ((chr_base_page >> 4) & $F0) | ((prg_base_bank >> 2) & $C0)
reg3 = ((~prg_block_mask) & $3F) | (lock ? $40 : 0)
```

For the PB3 layout:

| | `reg0` (CHR-OR) | `reg1` (PRG-OR) | `reg2` (CHR-AND + MSBs) | `reg3` (PRG-AND + lock) |
|---|---|---|---|---|
| **Block 0 — Power Blade 2** | `$00` | `$00` | `$0F` | `$20` |
| **Block 1 — Solbrain** | `$00` | `$20` | `$1F` | `$20` |

* `reg1 = $20` = physical 8 KiB bank 32 = 256 KiB offset ✔
* `reg2` low nibble `$F` = "256 KiB of CHR from the MMC3" ⇒ CHR mask `$FF`
* `reg2` bit 4 = CHR A18 ⇒ CHR page base `$100` for block 1 ✔
* `reg3 = $20` ⇒ PRG mask `(~$20) & $3F = $1F` ⇒ 256 KiB block ✔ and **lock clear**

**On `reg3` bit 7:** the wiki draws it as a literal `1` (`1LPP PPPP`). No emulator
reads it (Mesen2 and FCEUX mask `reg3` to `$3F` first; puNES and fceumm compute
`~reg3 & 0x3F`; Nestopia computes `reg3 ^ 0x3F` unmasked, where a set bit 7 leaks into
the mask as bit 7 only and is harmless because MMC3 bank values are ≤ `$3F`). **Write
`$20`, not `$A0`** — `$20` behaves identically everywhere including Nestopia's
unmasked path. If you ever build real GA23C hardware, re-test with `$A0`; this is the
one genuinely ambiguous bit on the page.

### 4.2 The exact write sequence

```asm
; ---- select a mapper-45 block -------------------------------------------
; Preconditions:
;   * the outer write index must be 0 (true at power-on/reset, and true after
;     every previous configuration because we always write exactly 4 bytes)
;   * the lock bit (reg3 bit 6) must be clear -- we never set it
;   * interrupts disabled if this switch moves $E000 (see §7)
;
SelectBlock:            ; X = 0 for block 0, 4 for block 1
        lda BlockCfg+0,x
        sta $6000       ; -> outer register #0  (CHR-OR LSB)
        lda BlockCfg+1,x
        sta $6000       ; -> outer register #1  (PRG-OR LSB)
        lda BlockCfg+2,x
        sta $6000       ; -> outer register #2  (CHR-AND + CHR/PRG-OR MSB)
        lda BlockCfg+3,x
        sta $6000       ; -> outer register #3  (PRG-AND, lock left clear)
        rts             ; index has wrapped 0->1->2->3->0, back in sync

BlockCfg:
        .byte $00,$00,$0F,$20   ; block 0 : Power Blade 2
        .byte $00,$20,$1F,$20   ; block 1 : Solbrain
```

Rules, all of which follow from §5:

* **Always write to `$6000` itself.** Never to an odd address in `$6000-$7FFF`
  (FCEUX master would treat that as an unlock instead of a register write, desyncing
  the index against every other emulator).
* **Always write exactly four bytes.** Never one, never two.
* **Never set `reg3` bit 6 (lock).** It cannot be reliably cleared again.
* **Always write all four**, even if only `reg1` is changing — the index makes partial
  updates position-dependent, and `reg2`'s power-on value is not portable.
* After the four writes, **re-program the MMC3 bank registers** (`$8000`/`$8001` for
  R0-R7) — the outer registers only change the masking, they do not touch R0-R7, and
  R0-R7 still hold the *previous* block's values.

### 4.3 Recovering if the index is ever unknown

If some code path writes an unknown number of bytes to `$6000-$7FFF`, the index is
unknown mod 4 and there is no portable way to reset it (`$6001` is not implemented).
The only recovery is a console reset. **Therefore: `$6000` must be written from
exactly one routine in the whole ROM, and that routine always writes four bytes.**

---

## 5. Emulator behaviour — what the implementations actually do

I read the source of every implementation below. Deviations from the wiki are the
important part.

| | AND-mask applied to MMC3 bank (⇒ block-relative fixed banks) | PRG-OR width | CHR-OR width | `reg2` power-on | decodes A0 | `$6001` reset/unlock | lock honoured |
|---|---|---|---|---|---|---|---|
| **Wiki spec** | yes | 10 bits (8 MiB) | 12 bits (4 MiB) | unspecified | yes (`$F001`) | yes | yes |
| **Mesen / Mesen2** | **yes** | 8 bits (2 MiB) | 12 bits | `$0F` | no | **no** | yes, *permanently* |
| **Nestopia UE** | **yes** | 8 bits | 12 bits | `$00` | no | **no** | yes |
| **puNES** | **yes** | 10 bits | 12 bits | `$0F` | no | **no** | yes |
| **libretro-fceumm** | **yes** | 10 bits | 12 bits | `$0F` | no | **no** | yes |
| **FCEUX ≤ 2.6.6** | **yes** | 8 bits | 12 bits | `$00` | no | **no** | yes |
| **FCEUX master (≥ 2023-10-26)** | **NO — broken** | broken | ok in practice | `$00` | yes | partial (clears lock only) | yes |

Sources:

* **Mesen2** — `Core/NES/Mappers/Mmc3Variants/MMC3_45.h`:
  ```cpp
  void SelectPrgPage(uint16_t slot, uint16_t page, ...) override {
      page &= 0x3F ^ (_reg[3] & 0x3F);
      page |= _reg[1];
      MMC3::SelectPrgPage(slot, page, memoryType);
  }
  void SelectChrPage(uint16_t slot, uint16_t page, ...) override {
      if(!HasChrRam()) {
          page &= 0xFF >> (0x0F - (_reg[2] & 0x0F));
          page |= _reg[0] | ((_reg[2] & 0xF0) << 4);
      } ...
  }
  void Reset(bool softReset) override { ... memset(_reg,0,...); _reg[2] = 0x0F; ... }
  void WriteRegister(uint16_t addr, uint8_t value) override {
      if(addr < 0x8000) {
          if(!(_reg[3] & 0x40)) { _reg[_regIndex] = value; _regIndex = (_regIndex+1) & 0x03; }
          if(_reg[3] & 0x40) { RemoveRegisterRange(0x6000, 0x7FFF); }
          UpdateState();
      } else { MMC3::WriteRegister(addr, value); }
  }
  ```
  <https://github.com/SourMesen/Mesen2/blob/master/Core/NES/Mappers/Mmc3Variants/MMC3_45.h>
  The fixed banks arrive as `SelectPrgPage(2, -2)` / `SelectPrgPage(3, -1)` in
  `Core/NES/Mappers/Nintendo/MMC3.h::UpdatePrgMapping()` — as `uint16_t` those are
  `$FFFE`/`$FFFF`, so `& $1F` gives `$1E`/`$1F`. Block-relative ✔.
  Note `RemoveRegisterRange` on lock: **once locked, Mesen2 stops intercepting
  `$6000-$7FFF` entirely, so `$6001` cannot unlock.**
  <https://github.com/SourMesen/Mesen2/blob/master/Core/NES/Mappers/Nintendo/MMC3.h>
* **Nestopia UE** — `source/core/board/NstBoardBmcHero.cpp`
  (mapper 45 is board `BMC_HERO`, see `NstBoard.cpp` `case 45:`):
  ```cpp
  void NST_FASTCALL Hero::UpdatePrg(uint address,uint bank) {
      prg.SwapBank<SIZE_8K>( address, exRegs[1] | (bank & (exRegs[3] ^ 0x3F)) );
  }
  void NST_FASTCALL Hero::UpdateChr(uint address,uint bank) const {
      chr.SwapBank<SIZE_1K>( address,
          (exRegs[0] | (exRegs[2] << 4 & 0xF00)) |
          ((exRegs[2] & 0x8) ? bank & ((1U << ((exRegs[2] & 0x7) + 1)) - 1)
                             : exRegs[2] ? 0 : bank) );
  }
  ```
  <https://github.com/0ldsk00l/nestopia/blob/master/source/core/board/NstBoardBmcHero.cpp>
  Fixed-bank values come from `NstBoardMmc3.cpp`, which hard-codes
  `banks.prg[2] = 0x3E; banks.prg[3] = 0x3F;` — so `& $1F` → `$1E`/`$1F` ✔.
  <https://github.com/0ldsk00l/nestopia/blob/master/source/core/board/NstBoardMmc3.cpp>
  Watch the CHR expression: if `reg2`'s low nibble is ≤ 7 *and* `reg2` is non-zero,
  CHR is forced to page 0. Our `reg2 = $0F/$1F` has bit 3 set, so we take the correct
  branch.
* **puNES** — `src/core/mappers/mapper_045.c`:
  ```c
  void prg_swap_mmc3_045(WORD address, WORD value) {
      WORD base = m045.reg[1] | ((m045.reg[2] & 0xC0) << 2);
      WORD mask = ~m045.reg[3] & 0x3F;
      ...  memmap_auto_wp_8k(0, MMCPU(address), (base | (value & mask)), enabled, FALSE);
  }
  void chr_swap_mmc3_045(WORD address, WORD value) { ...
      WORD base = m045.reg[0] | ((m045.reg[2] & 0xF0) << 4);
      WORD mask = 0xFF >> (~m045.reg[2] & 0x0F);
      chr_swap_MMC3_base(address, (base | (value & mask)));
  }
  ```
  with `memset(&m045,0,...); m045.reg[2] = 0x0F;` at init and
  `info.mapper.extend_wr = TRUE` (so `$6000-$7FFF` writes reach the mapper regardless
  of WRAM state, matching the wiki).
  <https://github.com/punesemu/puNES/blob/master/src/core/mappers/mapper_045.c>
  Fixed banks come from `prg_fix_MMC3_base()` in `src/core/mappers/MMC3.c` as
  `MMC3_prg_swap(0xC000, ~1); MMC3_prg_swap(0xE000, ~0);` — `$FFFF & $1F = $1F` ✔.
  <https://github.com/punesemu/puNES/blob/master/src/core/mappers/MMC3.c>
* **libretro-fceumm** — `src/boards/mmc3.c`, `M45PW`/`M45CW`:
  ```c
  static void M45PW(uint32_t A, uint8_t V) {
      int prgAND = ~EXPREGS[3] & 0x3F;
      int prgOR  = EXPREGS[1] | EXPREGS[2] << 2 & 0x300;
      setprg8(A, V & prgAND | prgOR & ~prgAND);
      ...
  }
  static void M45CW(uint32_t A, uint8_t V) { ...
      int chrAND = 0xFF >> (~EXPREGS[2] & 0xF);
      int chrOR  = EXPREGS[0] | EXPREGS[2] << 4 & 0xF00;
      setchr1(A, V & chrAND | chrOR & ~chrAND);
  }
  static void M45Power(void) { ... EXPREGS[2] = 0x0F; ... }
  ```
  <https://github.com/libretro/libretro-fceumm/blob/master/src/boards/mmc3.c>
  This is the most wiki-faithful implementation of the set. Note `prgOR & ~prgAND`:
  the OR value's bits *inside* the block mask are discarded, which is what real
  address-line ORing does. Our `reg1 = $20` has no bits under mask `$1F`, so it is
  unaffected — but do not rely on low bits of the OR value.
* **FCEUX ≤ 2.6.6** — `src/boards/mmc3.cpp`:
  ```c
  static void M45PW(uint32 A, uint8 V) {
      uint32 MV = V & ((EXPREGS[3] & 0x3F) ^ 0x3F);
      MV |= EXPREGS[1];
      if (UNIFchrrama) MV |= ((EXPREGS[2] & 0x40) << 2);
      setprg8(A, MV);
  }
  ```
  <https://github.com/TASEmulators/fceux/blob/v2.6.6/src/boards/mmc3.cpp> — correct.
* **FCEUX master — REGRESSION.** Commit `764e1ebd76fc3297f9e11e8e7e2f59854731ecee`
  ("Mapper 45 fixes", Alexey 'Cluster' Avdyukhin, 2023-10-26) changed it to
  ```c
  static void M45PW(uint32 A, uint8 V) {
      uint32 MV = V;                                    /* <-- AND mask dropped */
      const int mask = (EXPREGS[3] & 0x3F) ^ 0x3F;
      MV |= (EXPREGS[1] & 0x3F & mask) | (EXPREGS[1] & 0xC0);
      setprg8(A, MV);
  }
  ```
  <https://github.com/TASEmulators/fceux/commit/764e1ebd76fc3297f9e11e8e7e2f59854731ecee>
  The MMC3 bank is no longer confined to the block, **and** the OR value is ANDed with
  the block mask, which for our `reg1 = $20` / mask `$1F` produces `$00` — block 1
  collapses onto block 0 and both games' `$E000` points at physical bank 63.
  A follow-up commit `5a5faa7372` added A0 decoding (`$6000` even = register write,
  `$6001` odd = clear lock bit, index *not* reset) and moved the write handler from
  `$5000-$7FFF` to `$6000-$7FFF`.
  <https://github.com/TASEmulators/fceux/commit/5a5faa737225bcd2d26d8a96f59ea5ce066f829e>
  The latest tagged FCEUX release is **v2.6.6**, which predates this, so *release*
  FCEUX is fine; FCEUX "interim"/master builds are not.
  <https://github.com/TASEmulators/fceux/tags>

  **Action items:** test against FCEUX 2.6.6, and file the regression upstream. The
  one-line fix is `uint32 MV = V & ((EXPREGS[3] & 0x3F) ^ 0x3F);` plus
  `MV |= EXPREGS[1] | ((EXPREGS[2] & 0xC0) << 2);`.

**Size caps:** none of these cap mapper 45. FCEUX's `GenMMC3_Init(info, 512, 256, ...)`
*looks* like a 512 KiB PRG / 256 KiB CHR cap, but the code is
`PRGmask8[0] &= (prg >> 13) - 1;` with `prg` in KiB, so `512 >> 13 == 0` and the mask
becomes `0xFFFFFFFF` — the cap is dead code and 512 KiB CHR works.
<https://github.com/TASEmulators/fceux/blob/master/src/boards/mmc3.cpp>

**Emulator/hardware coverage** — see §8.

---

## 6. NES 2.0 header — all sixteen bytes

For **512 KiB PRG + 512 KiB CHR, mapper 45, submapper 0, no battery,
mapper-controlled mirroring, NTSC**:

```
4E 45 53 1A 20 40 D0 28 00 00 00 00 00 00 00 01
```

| Off | Value | Meaning |
|---|---|---|
| 0-3 | `4E 45 53 1A` | `"NES"` + `$1A`. Required identification string. |
| 4 | `$20` | PRG-ROM size LSB, in 16 KiB units. 512 KiB / 16 KiB = 32 = `$20`. |
| 5 | `$40` | CHR-ROM size LSB, in 8 KiB units. 512 KiB / 8 KiB = 64 = `$40`. |
| 6 | `$D0` | `NNNN FTBM`. `N = $D` = mapper D3..D0 (45 = `$2D`, low nibble `$D`). `F` (alternative nametables / four-screen) = 0. `T` (trainer) = 0. `B` (battery) = 0. `M` (hard-wired nametable layout) = 0 — MMC3 controls mirroring through `$A000`, and the wiki's rule is that mapper-controlled mirroring is encoded as 0 here. |
| 7 | `$28` | `NNNN 10TT`. `N = $2` = mapper D7..D4. Bits 3-2 = `%10` = the NES 2.0 identifier (`(header[7] & 0x0C) == 0x08`). `TT = 0` = plain NES/Famicom console. |
| 8 | `$00` | `SSSS NNNN`. Submapper = 0 (mapper 45 has no submappers). Mapper D11..D8 = 0. Combined mapper number = `$0` `$2` `$D` = 45. |
| 9 | `$00` | `CCCC PPPP`. CHR-ROM size MSB = 0, PRG-ROM size MSB = 0 (both sizes fit in the LSB byte). |
| 10 | `$00` | PRG-RAM / PRG-NVRAM shift counts. Both 0 ⇒ **no PRG-RAM at all**, which is what we want — `$6000-$7FFF` is the mapper register window. |
| 11 | `$00` | CHR-RAM / CHR-NVRAM shift counts. Both 0 ⇒ no CHR-RAM; the cart is pure CHR-ROM. |
| 12 | `$00` | CPU/PPU timing: 0 = RP2C02, NTSC. (Both source games are NTSC-region MMC3 titles; use `$00`.) |
| 13 | `$00` | Only meaningful when byte 7 `AND 3` is 1 or 3 (Vs. System / extended console). Ours is 0, so this byte is unused — write 0. |
| 14 | `$00` | Number of miscellaneous ROMs present = 0. |
| 15 | `$01` | Default expansion device = 1 = standard NES controller. |

Reference: <https://www.nesdev.org/wiki/NES_2.0>

Variants:

* **256 KiB CHR** (no new CHR): byte 5 = `$20`.
* **1 MiB PRG** (512 KiB blocks, PRG-AND = `$00`): byte 4 = `$40`.
* Total file size must be `16 + PRG + CHR` = `16 + 524288 + 524288` = **1 048 592
  bytes** for the 512/512 build.

Backwards compatibility: an iNES-only loader reads bytes 4/5/6/7 and gets
32 × 16 KiB PRG, 64 × 8 KiB CHR, mapper 45 — the same thing. No NES-2.0-exclusive
feature is required, so the header is safe everywhere.

---

## 7. Runtime block switching

### 7.1 What moves

A change of `reg1` (PRG-OR) re-points **all four** CPU PRG windows at once:

```
$8000 : (R6   & $1F) | OR
$A000 : (R7   & $1F) | OR
$C000 : ($3E  & $1F) | OR   = $1E | OR      <- moves
$E000 : ($3F  & $1F) | OR   = $1F | OR      <- moves, and this is where IRQ/NMI/RESET
                                               vectors are fetched from
```

so the instruction after `STA $6000` (the write that changes `reg1`) may well be in a
different bank. You need a trampoline that is at the same *physical* bytes before and
after the switch. Two ways to get that:

* **RAM trampoline (recommended).** Copy ~40 bytes into CPU RAM and `JMP` there.
  Bulletproof, no constraint on the ROM layout.
* **Mirrored ROM stub.** Place a byte-identical stub at the same address (e.g.
  `$FF00`) in *all four* fixed banks — physical 30, 31, 62 and 63 — so that whichever
  bank is at `$C000`/`$E000` the CPU keeps executing the same code. This is what real
  multicart menus do, but it costs you identical free space at a fixed address inside
  both games' banks 14 and 15. Use only if you cannot spare the RAM.

**Special case, no trampoline needed:** going from the power-on state to **block 1**
does not move `$E000` (§3.2), so the boot stub can configure block 1 in place.

### 7.2 The safe sequence

```asm
; ---------------------------------------------------------------------------
;  SwitchBlock  --  change mapper-45 block and restart the target game
;  Call with A = 0 for block 0, A = 4 for block 1.
;  Clobbers everything. Never returns.
;  Must be called with the CPU executing from ROM; it relocates itself to RAM.
; ---------------------------------------------------------------------------
TRAMP   = $0500                 ; any RAM we are free to destroy
CFG     = $04F0                 ; 4 staged config bytes, also in RAM

SwitchBlock:
        sei                     ; 1. no interrupts from here on
        tax                     ; X = config table offset

        ldy #$03                ; 2. STAGE THE CONFIG BYTES IN RAM.
:       lda BlockCfg,x          ;    Critical: after the first $6000 write the PRG
        sta CFG,y               ;    map starts moving, so the trampoline must not
        inx                     ;    read anything out of ROM.
        dey
        bpl :-

        lda #$00
        sta $2000               ; 3. NMI off
        sta $2001               ; rendering off  (do this in vblank to avoid a
                                ;                 visible glitch; harmless otherwise)
        bit $2002               ; clear the vblank latch
        sta $4015               ; APU channels off
        lda #$40
        sta $4017               ; APU frame IRQ off
        lda #$00
        sta $E000               ; 4. MMC3 IRQ disable + acknowledge
                                ;    (MMC3 $E000 even = "IRQ disable")

        ldy #TrampEnd-TrampSrc  ; 5. copy the trampoline into RAM
:       dey
        lda TrampSrc,y
        sta TRAMP,y
        tya
        bne :-

        jmp TRAMP               ; 6. leave ROM

; --- this block is executed from RAM, and reads only RAM and immediates -----
;     (note CFG was filled back-to-front above, so CFG+3 is reg#0 ... CFG+0 is reg#3)
TrampSrc:
        lda CFG+3
        sta $6000               ; outer reg #0  (CHR-OR LSB)
        lda CFG+2
        sta $6000               ; outer reg #1  (PRG-OR LSB) <-- $C000/$E000 move
        lda CFG+1
        sta $6000               ; outer reg #2  (CHR-AND + MSBs)
        lda CFG+0
        sta $6000               ; outer reg #3  (PRG-AND)    <-- $C000/$E000 move
                                ;               index is back to 0

        ldx #$FF                ; 6. clean 6502 state, as after a real reset
        txs
        cld

        lda #$00                ; 7. re-programme the MMC3 for the target game
        sta $8000               ; (R0..R7 still hold the previous block's values;
        sta $8001               ;  the outer registers do not touch them)
        lda #$01
        sta $8000
        lda #$02
        sta $8001
        ; ... R2..R5 as required ...
        lda #$06
        sta $8000
        lda #$00
        sta $8001               ; R6 = target game's bank 0 at $8000
        lda #$07
        sta $8000
        lda #$01
        sta $8001               ; R7 = target game's bank 1 at $A000
        lda #$00
        sta $A000               ; mirroring
        sta $A001               ; PRG-RAM protect (irrelevant, no WRAM)

        jmp ($FFFC)             ; 8. enter the target block through its reset vector
TrampEnd:
```

Notes on the sequence:

* **`SEI` before anything.** After the switch the NMI/IRQ vectors at `$FFFA`/`$FFFE`
  belong to the *other* game. An NMI taken mid-switch jumps into whatever the new bank
  happens to hold.
* **MMC3 IRQ off via `$E000`.** A pending scanline IRQ is just as dangerous as an NMI.
  Doing `STA $E000` also re-uses the MMC3 register file, which is fine.
* **Rendering off before the switch** because the CHR mapping changes at the same
  moment (`reg0`/`reg2`). If you can afford to, do the whole switch in vblank.
* **The four `STA $6000` writes must be adjacent and in RAM.** Between write #1 and
  write #3 the PRG map is in an intermediate state (new OR, old AND); that state maps
  `$8000-$FFFF` somewhere well-defined but not necessarily useful, which is exactly
  why we are in RAM.
* **`JMP ($FFFC)`** reads the target block's own reset vector — the original game's
  reset handler, or the PB3 stub you patched into it. This keeps the trampoline
  independent of where each game's entry point actually is. It does *not* reset the
  PPU/APU, so steps 2/6 above stand in for the hardware reset; add a two-vblank wait
  in the target game's entry stub if it expects a cold PPU.
* If you also need the *CHR* mapping re-programmed for the target game, do it after
  step 7 by writing R0-R5, before re-enabling rendering.

### 7.3 Protecting the block selection from the games

Mapper 45 offers exactly one protection: `reg3` bit 6, the lock. **Do not use it** —
the wiki's `$6001` unlock is implemented by no emulator (Mesen2 goes as far as
*removing* the `$6000-$7FFF` handler entirely on lock), so locking makes the block
selection permanent until a console reset.

The practical protection is verification:

* I grepped the fixed bank 15 disassemblies you already have
  (`work/re/pb2_b15.asm`, `work/re/sol_fixed_raw.asm`, `work/re/b15_rd.asm`) for any
  `STA/STX/STY $6xxx/$7xxx` — **zero hits in all three files**. Bank 15 is where MMC3
  init code lives, so that is the most likely place and it is clean.
* A naive linear opcode scan over the full 128 KiB of each PRG finds "hits", but they
  are overwhelmingly data misinterpreted as code, so that scan proves nothing.
* **Do this before you commit:** run each original ROM under your emulator
  (`work/tools/nesemu.c`) with a write-watch on `$6000-$7FFF` for a full playthrough
  of the attract mode, a level, the pause menu, and a game over. Any hit at all means
  you must patch that instruction out. Since both headers declare **0** bytes of
  PRG-RAM (byte 10 = `$00` in both files, verified), any such write would already be a
  no-op bug in the original and is safe to NOP out.

---

## 8. Emulator and hardware support

### 8.1 Emulators

| Emulator | Mapper 45 | Correct for a 2-block cart? | Evidence |
|---|---|---|---|
| **Mesen2** | yes (`MMC3_45`) | **yes** | `Core/NES/MapperFactory.cpp` case 45; `Core/NES/Mappers/Mmc3Variants/MMC3_45.h` |
| **Mesen 0.9.9** | yes | **yes** (identical code) | `Core/MMC3_45.h` |
| **Nestopia UE** | yes, board `BMC SUPER/HERO X-IN-1` | **yes** | `source/core/board/NstBoard.cpp` case 45 → `NstBoardBmcHero.cpp` |
| **puNES** | yes | **yes** — closest to the wiki | `src/core/mappers/mapper_045.c` |
| **libretro-fceumm** | yes (`Mapper45_Init`, "MMC3 BMC PIRATE B") | **yes** — closest to the wiki | `src/ines.c` line 535; `src/boards/mmc3.c` |
| **FCEUX ≤ 2.6.6** (latest tagged release) | yes | **yes** | `src/boards/mmc3.cpp` @ v2.6.6 |
| **FCEUX master / interim builds** | yes | **NO — block confinement broken** | commit `764e1ebd76`, see §5 |
| **Nintendulator** | yes, rated "Full" | presumed yes (not source-verified) | <https://www.qmtpro.com/~nes/nintendulator/> ; <https://github.com/quietust/nintendulator-mappers> |
| **MiSTer NES core** | yes, "Supported + Save state" | presumed yes | `rtl/mappers/MMC3.sv` — has `m45_reg[3:0]`, `m45_index`, `m45_locked = m45_reg[3][6] // per Nintendulator` |
| **QuickNES** (RetroArch) | **no** | — | `nes_emu/Nes_Mapper.cpp` mapper list has no 45 |
| **jsnes** | **no** | — | `src/mappers/` only has 0,1,2,3,4,5,7,9,11,34,38,66,71,79,94,118,119,140,180,240,241 |
| **ares / higan Famicom** | **no** | — | `mia/medium/famicom.cpp` has no `case 45`; tracking issue <https://github.com/ares-emulator/ares/issues/72> |

There is no published Mesen mapper-compatibility page (`mesen.ca/docs/compatibility.html`
is a 404); the source file above is the authoritative list. libretro's docs likewise
do not publish per-mapper tables.

For reference, mappers 47 and 52 in the same emulators: **47** is the most portable of
the three (it is the only one `ares` implements); **52** tracks 45 almost exactly
(present in Mesen2, Nestopia, fceumm, Nintendulator, EverDrive) — but see §1.6 for why
52 is still the wrong choice.

### 8.2 Flash carts and real hardware

* **EverDrive N8 and EverDrive N8 Pro — mapper 45 IS supported.** Mapper 4, 45, 47 and
  52 all appear in krikzz's official supported-mapper chart
  <https://krikzz.com/pub/support/everdrive-n8/pro-series/mappers.png>, and the N8 Pro
  firmware changelog explicitly lists "Fixes for mappers: 45, 150, 176, 243"
  <https://krikzz.com/pub/support/everdrive-n8/pro-series/firmware/changelog.txt>.
  For the original N8, OS v1.20 added mappers "37, **45**, 49, 51, **52**, …"
  <https://krikzz.com/pub/support/everdrive-n8/original-series/OS/changelist.txt>;
  see also <https://www.nesdev.org/wiki/Everdrive_N8>.
  Note: <https://github.com/krikzz/EDN8-PRO> does **not** contain a mapper list or
  mapper 45 source — only example FPGA packs (000, 001, 004, 005, 021, 255); shipped
  mappers are compiled `.rbf` bitstreams.
  **Caveat to test on hardware:** the N8's mapper 45 core is a reimplementation, and I
  have not been able to verify its power-on `reg2` value or whether it decodes A0.
  Follow the §4.2 rules (always four writes to `$6000` exactly, never lock) and it
  should be safe, but **the EverDrive is the one platform you must physically test.**
* **PowerPak — mapper 45 is NOT supported** (and neither is 52). The official V1.35b
  mapper table lists 004 = yes, 047 = yes, **045 = no, 052 = no**
  <https://www.nesdev.org/wiki/PowerPak>. None of the community mapper sets (Loopy's,
  TheFox's PowerMappers, Myask's) add it. If PowerPak support matters to you, mapper 45
  is a dead end and you would have to fall back to mapper 47 — which cannot hold this
  project.
* **MiSTer — supported**, and its Verilog is the only public open-source *hardware*
  implementation of mapper 45:
  <https://github.com/MiSTer-devel/NES_MiSTer/blob/master/rtl/mappers/MMC3.sv>
  (README marks 45 and 52 "Supported + Save state").
* **New-production PCB — none found.** There is no off-the-shelf mapper-45 board:
  Infinite NES Lives' published boards are discrete/UNROM-512 (mapper 30), MMC1 and
  MMC3 (their site could not be fetched, so treat as unverified rather than proven
  absent); a NESdev forum search for "GA23C" returns zero hits; no CPLD implementation
  is published. Real-hardware options are (a) EverDrive N8/N8 Pro, (b) MiSTer, or
  (c) reusing an original GA23C pirate multicart PCB as a donor — those exist in
  quantity. FlameCyclone published full 6502 source for a 14-game mapper-45 multicart
  menu, which is a useful cross-check on register usage:
  <https://forums.nesdev.org/viewtopic.php?t=19908>.

---

## 9. Implementation checklist

1. Build the 512 KiB PRG image per §3.1 — **Solbrain in block 1** so that its bank 15
   (physical bank 63) carries the boot stub and the reset vector.
2. Build the 512 KiB CHR image per §3.3.
3. Prepend the header from §6.
4. Patch physical bank 63's reset vector (`$FFFC`) to the PB3 boot stub. The stub does
   the four `$6000` writes for **block 1** in place — no trampoline needed — then sets
   up the MMC3 and jumps into the shell.
5. Put the new PB3 code in block positions 14-29 of both blocks, byte-identical.
6. Route every `$6000` write through the single four-byte `SelectBlock` routine (§4.2).
7. Use the §7.2 RAM trampoline for every game-to-game transition.
8. Port `work/tools/mapper_ref.py` into `work/tools/nesemu.c`.
9. Test on: Mesen2, Nestopia UE, puNES, FCEUX **2.6.6** (not master), RetroArch/fceumm,
   and — the one that really matters — a real **EverDrive N8 Pro**.
10. Run the `$6000-$7FFF` write-watch verification of §7.3 on both original ROMs.
11. Accept that jsnes, QuickNES and ares will not run the cart at all, and PowerPak
    cannot either. If browser playability is a hard requirement, ship a separate
    single-game mapper-4 build for the web.

---

## 10. Files produced

* `work/re/mapper_choice.md` — this document.
* `work/tools/mapper_ref.py` — executable reference implementation of the mapper-45
  banking logic (MMC3 core + outer registers → physical PRG/CHR offsets), the
  configuration-byte generator, the PB3 layout constants, the NES 2.0 header builder,
  and a self-test that asserts every claim in §3 and §4.
  Run it as `python3 /Users/hropl/pr/mypr/PB3/work/tools/mapper_ref.py`.
  (It used to have to be run from elsewhere: `work/tools/dis.py` shadowed the
  standard-library `dis` module.  That file is now `disasm.py`.)
