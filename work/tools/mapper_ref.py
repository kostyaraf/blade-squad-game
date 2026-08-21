#!/usr/bin/env python3
"""
mapper_ref.py -- reference banking logic for iNES Mapper 045 (GA23C), the mapper
chosen for the PB3 two-game multicart.

This file is DOCUMENTATION + EXECUTABLE REFERENCE ONLY.  It is deliberately kept
separate from work/tools/nesemu.c; port the arithmetic in Mmc3Mapper45.prg_offsets()
and .chr_offsets() into nesemu.c by hand.

Spec sources (see work/re/mapper_choice.md for the full citation list):
  https://www.nesdev.org/wiki/INES_Mapper_045
  https://www.nesdev.org/wiki/MMC3

Formulation (identical to puNES src/core/mappers/mapper_045.c and
libretro-fceumm src/boards/mmc3.c M45PW/M45CW):

    prg_and = (~reg3) & 0x3F                       # 6-bit AND mask, reg3 is inverted
    prg_or  = reg1 | ((reg2 & 0xC0) << 2)          # 10 bits -> PRG A13..A22 (8 MiB)
    phys8k  = (mmc3_bank & prg_and) | (prg_or & ~prg_and)

    chr_and = 0xFF >> ((~reg2) & 0x0F)             # 8-bit AND mask
    chr_or  = reg0 | ((reg2 & 0xF0) << 4)          # 12 bits -> CHR A10..A21 (4 MiB)
    phys1k  = (mmc3_chr & chr_and) | (chr_or & ~chr_and)

`mmc3_bank` for the two MMC3 fixed windows is the all-ones value the MMC3 puts on
its PRG A13..A18 pins: -2 and -1, i.e. 0x3E and 0x3F in 6-bit terms.  Because the
AND mask is applied to that value too, the fixed windows land at
(block_size_in_banks - 2) and (block_size_in_banks - 1) *inside the selected
block*.  That is the whole reason mapper 45 can host two independent MMC3 games.
"""

# --------------------------------------------------------------------------
# MMC3 core (mapper 4) -- exactly the Nintendo part, no multicart logic
# --------------------------------------------------------------------------

class Mmc3Core:
    """Plain MMC3.  Produces *logical* bank numbers, before any outer masking."""

    def __init__(self):
        # $8000 bank-select latch
        self.bank_select = 0x00      # bit7 = CHR A12 inversion, bit6 = PRG mode
        self.R = [0, 2, 4, 5, 6, 7, 0, 1]   # R0..R7; power-on values unspecified
        self.mirroring = 0           # $A000 bit0: 0 = vertical, 1 = horizontal
        self.ram_protect = 0         # $A001
        self.irq_latch = 0
        self.irq_counter = 0
        self.irq_reload = False
        self.irq_enable = False

    # -- register file --------------------------------------------------
    def write(self, addr, value):
        reg = addr & 0xE001
        if reg == 0x8000:
            self.bank_select = value
        elif reg == 0x8001:
            idx = self.bank_select & 0x07
            if idx == 6 or idx == 7:
                # "R6 and R7 will ignore the top two bits, as the MMC3 has only
                #  6 PRG ROM address lines."  -- nesdev MMC3 page
                value &= 0x3F
            self.R[idx] = value
        elif reg == 0xA000:
            self.mirroring = value & 1
        elif reg == 0xA001:
            self.ram_protect = value
        elif reg == 0xC000:
            self.irq_latch = value
        elif reg == 0xC001:
            self.irq_counter = 0
            self.irq_reload = True
        elif reg == 0xE000:
            self.irq_enable = False
        elif reg == 0xE001:
            self.irq_enable = True

    # -- logical bank numbers -------------------------------------------
    def prg_banks(self):
        """Logical 8 KiB bank numbers for $8000/$A000/$C000/$E000.

        The two fixed windows are the MMC3's -2 / -1 outputs.  On the real chip
        only PRG A13..A18 exist, so they are 0x3E and 0x3F.  Emulators pass
        0xFE/0xFF (FCEUX, Nestopia uses a literal 0x3E/0x3F) or 0xFFFF (Mesen2,
        puNES); every one of those values has all six low bits set, which is the
        only thing the mapper-45 AND mask cares about.  We use 0xFF/0xFE so the
        value is representable in one byte, like FCEUX.
        """
        last, second_last = 0xFF, 0xFE
        if self.bank_select & 0x40:          # PRG mode 1
            return [second_last, self.R[7], self.R[6], last]
        else:                                # PRG mode 0 (both our games)
            return [self.R[6], self.R[7], second_last, last]

    def chr_banks(self):
        """Logical 1 KiB bank numbers for the eight PPU $0000..$1C00 windows."""
        r = self.R
        two_k = [r[0] & 0xFE, r[0] | 0x01, r[1] & 0xFE, r[1] | 0x01]
        one_k = [r[2], r[3], r[4], r[5]]
        if self.bank_select & 0x80:           # CHR A12 inversion
            return one_k + two_k
        return two_k + one_k


# --------------------------------------------------------------------------
# Mapper 45 outer bank registers
# --------------------------------------------------------------------------

class Mapper45:
    """iNES mapper 45 = MMC3 clone + four outer bank registers at $6000.

    prg_size / chr_size are in bytes and are used only for the final wrap.
    """

    def __init__(self, prg_size=512 * 1024, chr_size=512 * 1024):
        self.prg_size = prg_size
        self.chr_size = chr_size
        self.mmc3 = Mmc3Core()
        self.reg = [0x00, 0x00, 0x0F, 0x00]   # outer register file
        self.index = 0

    # ------------------------------------------------------------------
    # power-on / reset
    # ------------------------------------------------------------------
    def power_on(self):
        """Power-on state.

        NOTE: the wiki does not state the outer registers' power-on values.
        Implementations disagree on reg2 only:
            reg2 = 0x00 : Nestopia (NstBoardBmcHero.cpp), FCEUX (mmc3.cpp M45Power)
            reg2 = 0x0F : Mesen/Mesen2 (MMC3_45.h Reset), libretro-fceumm,
                          puNES (mapper_045.c map_init_045)
        reg0/reg1/reg3 and the write index are 0 in ALL of them.  PB3 therefore
        must never depend on reg2's reset value: always write all four registers
        before touching CHR.

        With reg1 = reg3 = 0 the PRG mask is 0x3F and the PRG OR is 0, so at
        power-on $E000 is *physical 8 KiB bank 63* (file offset $7E000 + 16).
        That is where the reset vector is fetched from, and therefore where the
        PB3 boot stub must live.
        """
        self.reg = [0x00, 0x00, 0x0F, 0x00]
        self.index = 0
        self.mmc3 = Mmc3Core()

    # ------------------------------------------------------------------
    # CPU writes
    # ------------------------------------------------------------------
    def cpu_write(self, addr, value):
        if 0x6000 <= addr <= 0x7FFF:
            # Wiki: mask $F001, even address = outer register, odd = reset+unlock.
            # Reality: Mesen2, Nestopia, puNES and libretro-fceumm ignore A0 and
            # treat EVERY write in $6000-$7FFF as an outer-register write; only
            # FCEUX master decodes A0.  PB3 therefore only ever writes $6000.
            if self.reg[3] & 0x40:           # lock bit -> writes go to WRAM
                return
            self.reg[self.index] = value
            self.index = (self.index + 1) & 3
        elif addr >= 0x8000:
            self.mmc3.write(addr, value)

    # ------------------------------------------------------------------
    # derived masks
    # ------------------------------------------------------------------
    @property
    def prg_and(self):
        return (~self.reg[3]) & 0x3F

    @property
    def prg_or(self):
        return self.reg[1] | ((self.reg[2] & 0xC0) << 2)

    @property
    def chr_and(self):
        return 0xFF >> ((~self.reg[2]) & 0x0F)

    @property
    def chr_or(self):
        return self.reg[0] | ((self.reg[2] & 0xF0) << 4)

    # ------------------------------------------------------------------
    # physical mapping
    # ------------------------------------------------------------------
    def prg_bank_numbers(self):
        a, o = self.prg_and, self.prg_or
        n = self.prg_size // 8192
        return [(((b & a) | (o & ~a)) & 0xFFFFFFFF) % n
                for b in self.mmc3.prg_banks()]

    def prg_offsets(self):
        """Byte offsets into the PRG-ROM image for $8000/$A000/$C000/$E000."""
        return [b * 8192 for b in self.prg_bank_numbers()]

    def chr_bank_numbers(self):
        a, o = self.chr_and, self.chr_or
        n = self.chr_size // 1024
        return [(((b & a) | (o & ~a)) & 0xFFFFFFFF) % n
                for b in self.mmc3.chr_banks()]

    def chr_offsets(self):
        """Byte offsets into the CHR-ROM image for PPU $0000,$0400,...,$1C00."""
        return [b * 1024 for b in self.chr_bank_numbers()]

    # ------------------------------------------------------------------
    # convenience: emit the 4-byte configuration sequence
    # ------------------------------------------------------------------
    @staticmethod
    def config_bytes(prg_or, prg_block_kib, chr_or_page, chr_block_kib,
                     lock=False):
        """Return the four bytes to write, in order, to $6000.

        prg_or        : physical 8 KiB bank number of the block base (0, 32, ...)
        prg_block_kib : block size in KiB (512, 256, 128, ... 8)
        chr_or_page   : physical 1 KiB page number of the CHR block base
        chr_block_kib : CHR block size in KiB (256, 128, ... 1)
        """
        # PRG-AND field is the INVERTED 6-bit mask: $00 = 512 KiB, $20 = 256 KiB...
        prg_banks = prg_block_kib // 8
        assert prg_banks and (prg_banks & (prg_banks - 1)) == 0, "power of two"
        prg_mask = prg_banks - 1                      # e.g. 256 KiB -> 0x1F
        reg3_prg = (~prg_mask) & 0x3F                 # e.g. 0x20
        assert prg_or & prg_mask == 0, "PRG-OR overlaps the AND mask"

        # CHR-AND field is a size code: $F = 256 KiB ... $8 = 2 KiB, $7-$0 = 1 KiB
        chr_pages = chr_block_kib                     # 1 KiB pages
        assert chr_pages and (chr_pages & (chr_pages - 1)) == 0, "power of two"
        chr_mask = chr_pages - 1                      # e.g. 256 KiB -> 0xFF
        # chr_mask == 0xFF >> (0x0F - c)  ->  c = 0x0F - (number of dropped bits)
        dropped = 0
        m = chr_mask
        while m != 0xFF:
            m = (m << 1 | 1) & 0xFF
            dropped += 1
        chr_code = (0x0F - dropped) & 0x0F
        assert chr_or_page & chr_mask == 0, "CHR-OR overlaps the AND mask"

        reg0 = chr_or_page & 0xFF                     # CHR A10..A17
        reg1 = prg_or & 0xFF                          # PRG A13..A20
        reg2 = chr_code | ((chr_or_page >> 4) & 0xF0) | ((prg_or >> 2) & 0xC0)
        reg3 = reg3_prg | (0x40 if lock else 0x00)
        return [reg0 & 0xFF, reg1 & 0xFF, reg2 & 0xFF, reg3 & 0xFF]


# --------------------------------------------------------------------------
# PB3 cartridge layout constants
# --------------------------------------------------------------------------

# PRG: 512 KiB = 64 x 8 KiB banks, two 256 KiB blocks
PB3_PRG_BLOCK_KIB = 256
PB3_BLOCK0_BASE_BANK = 0x00          # Power Blade 2   -> physical banks 0..31
PB3_BLOCK1_BASE_BANK = 0x20          # Solbrain        -> physical banks 32..63

# CHR: 512 KiB = 512 x 1 KiB pages, two 256 KiB blocks
PB3_CHR_BLOCK_KIB = 256
PB3_CHR0_BASE_PAGE = 0x000           # PB2  CHR $000-$07F, new CHR $080-$0FF
PB3_CHR1_BASE_PAGE = 0x100           # SOL  CHR $100-$17F, new CHR $180-$1FF

BLOCK0_CONFIG = Mapper45.config_bytes(PB3_BLOCK0_BASE_BANK, PB3_PRG_BLOCK_KIB,
                                      PB3_CHR0_BASE_PAGE, PB3_CHR_BLOCK_KIB)
BLOCK1_CONFIG = Mapper45.config_bytes(PB3_BLOCK1_BASE_BANK, PB3_PRG_BLOCK_KIB,
                                      PB3_CHR1_BASE_PAGE, PB3_CHR_BLOCK_KIB)


# --------------------------------------------------------------------------
# self test
# --------------------------------------------------------------------------

def _hexlist(xs, w=2):
    return "[" + " ".join(f"${x:0{w}X}" for x in xs) + "]"


def _selftest():
    ok = True

    def check(label, got, want):
        nonlocal ok
        good = got == want
        ok = ok and good
        print(f"  {'PASS' if good else 'FAIL'}  {label}: {got!r}"
              + ("" if good else f"  (want {want!r})"))

    print("config byte sequences (write in this order to $6000):")
    print("  block 0 (Power Blade 2):", _hexlist(BLOCK0_CONFIG))
    print("  block 1 (Solbrain)     :", _hexlist(BLOCK1_CONFIG))
    check("block0 config", BLOCK0_CONFIG, [0x00, 0x00, 0x0F, 0x20])
    check("block1 config", BLOCK1_CONFIG, [0x00, 0x20, 0x1F, 0x20])

    print("\npower-on state (all outer regs default):")
    m = Mapper45(); m.power_on()
    banks = m.prg_bank_numbers()
    print("   $8000/$A000/$C000/$E000 ->", _hexlist(banks))
    check("power-on $E000 is physical bank 63", banks[3], 63)
    check("power-on $C000 is physical bank 62", banks[2], 62)

    print("\nafter selecting block 1 (Solbrain) from power-on:")
    for b in BLOCK1_CONFIG:
        m.cpu_write(0x6000, b)
    check("write index back to 0", m.index, 0)
    banks = m.prg_bank_numbers()
    print("   $8000/$A000/$C000/$E000 ->", _hexlist(banks))
    check("$E000 unchanged (still bank 63)", banks[3], 63)
    check("$C000 is bank 62 = block1 pos 30", banks[2], 62)

    # Solbrain asks for its own banks 0 and 1 at $8000/$A000
    m.cpu_write(0x8000, 0x06); m.cpu_write(0x8001, 0x00)
    m.cpu_write(0x8000, 0x07); m.cpu_write(0x8001, 0x01)
    banks = m.prg_bank_numbers()
    check("SOL bank0 -> physical 32", banks[0], 32)
    check("SOL bank1 -> physical 33", banks[1], 33)
    # a new PB3 bank: block position 14
    m.cpu_write(0x8000, 0x06); m.cpu_write(0x8001, 14)
    check("new bank 14 -> physical 46", m.prg_bank_numbers()[0], 46)
    # the game must not be able to escape its block
    m.cpu_write(0x8000, 0x06); m.cpu_write(0x8001, 0x3F)
    check("runaway bank $3F clamps into block1", m.prg_bank_numbers()[0], 63)

    print("\nafter switching to block 0 (Power Blade 2):")
    for b in BLOCK0_CONFIG:
        m.cpu_write(0x6000, b)
    m.cpu_write(0x8000, 0x06); m.cpu_write(0x8001, 0x00)
    m.cpu_write(0x8000, 0x07); m.cpu_write(0x8001, 0x01)
    banks = m.prg_bank_numbers()
    print("   $8000/$A000/$C000/$E000 ->", _hexlist(banks))
    check("PB2 bank0 -> physical 0", banks[0], 0)
    check("PB2 bank1 -> physical 1", banks[1], 1)
    check("$C000 -> physical 30 (PB2 bank 14)", banks[2], 30)
    check("$E000 -> physical 31 (PB2 bank 15)", banks[3], 31)

    print("\nCHR, block 0, MMC3 CHR mode 0, R0..R5 = 0,2,4,5,6,7:")
    pages = m.chr_bank_numbers()
    print("   ", _hexlist(pages, 3))
    check("CHR pages stay in $000-$0FF", all(p < 0x100 for p in pages), True)
    m.cpu_write(0x8000, 0x02); m.cpu_write(0x8001, 0x80)   # R2 = $80 -> new CHR
    check("R2=$80 reaches new CHR page $080", m.chr_bank_numbers()[4], 0x080)

    print("\nCHR, block 1:")
    for b in BLOCK1_CONFIG:
        m.cpu_write(0x6000, b)
    pages = m.chr_bank_numbers()
    print("   ", _hexlist(pages, 3))
    check("CHR pages now in $100-$1FF",
          all(0x100 <= p < 0x200 for p in pages), True)
    check("R2=$80 reaches new CHR page $180", pages[4], 0x180)

    print("\nfile offsets, block 1 selected, SOL banks 0/1 at $8000/$A000:")
    m.cpu_write(0x8000, 0x06); m.cpu_write(0x8001, 0x00)
    m.cpu_write(0x8000, 0x07); m.cpu_write(0x8001, 0x01)
    print("   PRG offsets:", _hexlist(m.prg_offsets(), 5))
    print("   CHR offsets:", _hexlist(m.chr_offsets(), 5))

    print("\nNES 2.0 header:", _hexlist(pb3_header()))
    check("header bytes", pb3_header(),
          [0x4E, 0x45, 0x53, 0x1A, 0x20, 0x40, 0xD0, 0x28,
           0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])

    print("\n" + ("ALL CHECKS PASSED" if ok else "*** FAILURES ***"))
    return 0 if ok else 1


def pb3_header(prg_kib=512, chr_kib=512, mapper=45, submapper=0,
               battery=False, four_screen=False, hardwired_horizontal=False):
    """Build the 16-byte NES 2.0 header for the PB3 cartridge."""
    prg16k = prg_kib // 16
    chr8k = chr_kib // 8
    assert prg16k < 0xF00 and chr8k < 0xF00
    b6 = ((mapper & 0x0F) << 4)
    b6 |= 0x01 if hardwired_horizontal else 0x00
    b6 |= 0x02 if battery else 0x00
    b6 |= 0x08 if four_screen else 0x00
    b7 = (((mapper >> 4) & 0x0F) << 4) | 0x08      # 0x08 = NES 2.0 identifier
    b8 = ((submapper & 0x0F) << 4) | ((mapper >> 8) & 0x0F)
    b9 = (((chr8k >> 8) & 0x0F) << 4) | ((prg16k >> 8) & 0x0F)
    return [0x4E, 0x45, 0x53, 0x1A,
            prg16k & 0xFF, chr8k & 0xFF, b6, b7, b8, b9,
            0x00,   # byte 10: no PRG-RAM, no PRG-NVRAM
            0x00,   # byte 11: no CHR-RAM, no CHR-NVRAM
            0x00,   # byte 12: NTSC (RP2C02)
            0x00,   # byte 13: unused (console type 0)
            0x00,   # byte 14: no miscellaneous ROMs
            0x01]   # byte 15: default expansion device = standard controller


if __name__ == "__main__":
    import sys
    sys.exit(_selftest())
