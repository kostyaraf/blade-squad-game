"""Compose the PB3 mapper-45 multicart image.

PRG 1 MB = four 256K blocks of 32 x 8K banks:
   block A (banks   0- 31) Power Blade 2
   block B (banks  32- 63) PB3 shell  <- bank 63 is the power-on $E000, so boot lands here
   block C (banks  64- 95) Solbrain
   block D (banks  96-127) spare / shared new content

Inside a game block:
   position  0..13 -> original bank 0..13   (bank numbers unchanged for the host engine)
   position 14..29 -> new PB3 code
   position 30     -> original bank 14  (block second-to-last -> $C000)
   position 31     -> original bank 15  (block last           -> $E000)

CHR 512K = four 128K blocks.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rombuild import load, make_header, write_nes, PB2, SOL, BANK

BLOCK_BANKS = 32
BLOCK_BYTES = BLOCK_BANKS * BANK          # 256K
CHR_BLOCK   = 128 * 1024
FREE_LO, FREE_HI = 14, 29

BLOCK_A, BLOCK_B, BLOCK_C, BLOCK_D = 0, 1, 2, 3

# Each block sees a 256K CHR window: the host game's original 128K at bank $00-$7F
# and 128K of brand new tiles at $80-$FF, reachable without touching the outer regs.
CHR_WINDOW_BASE = {0: 0, 1: 0, 2: 256, 3: 256}   # in 1K banks, per PRG block

def outer_regs(block):
    """(reg0 chr-or, reg1 prg-or, reg2 chr-and + chr high, reg3 prg-and) for one block.

    reg3 is $20 and not $A0: the wiki shows bit 7 as always set, but Nestopia XORs the
    whole byte without masking, so a set bit 7 corrupts the PRG-AND mask there.
    The lock bit (bit 6) must stay clear - Mesen unmaps $6000-$7FFF once locked and
    never implements the $6001 unlock, which would strand us inside one block.
    """
    chr_base = CHR_WINDOW_BASE[block]      # in 1K banks
    reg0 = chr_base & 0xFF
    reg2 = 0x0F | (((chr_base >> 8) & 0x0F) << 4)   # CHR-AND = 256K window
    reg1 = block * BLOCK_BANKS             # in 8K banks
    reg3 = 0x20                            # PRG-AND = 256K, unlocked
    return reg0, reg1, reg2, reg3

def game_block(prg, new_banks=None, fill=0xFF):
    assert len(prg) == 16 * BANK
    out = bytearray(bytes([fill]) * BLOCK_BYTES)
    out[0:14*BANK]        = prg[0:14*BANK]
    out[30*BANK:31*BANK]  = prg[14*BANK:15*BANK]
    out[31*BANK:32*BANK]  = prg[15*BANK:16*BANK]
    for pos, data in (new_banks or {}).items():
        assert FREE_LO <= pos <= FREE_HI, f"bank position {pos} is not free"
        assert len(data) <= BANK
        out[pos*BANK:pos*BANK+len(data)] = data
    return out

def blank_block(banks=None, fill=0xFF):
    out = bytearray(bytes([fill]) * BLOCK_BYTES)
    for pos, data in (banks or {}).items():
        assert 0 <= pos < BLOCK_BANKS and len(data) <= BANK
        out[pos*BANK:pos*BANK+len(data)] = data
    return out

def chr_block(data=b'', fill=0x00):
    out = bytearray(bytes([fill]) * CHR_BLOCK)
    out[0:len(data)] = data
    return out

def compose(out="work/build/PB3.nes", pb2_new=None, sol_new=None,
            shell_banks=None, spare_banks=None,
            pb2_patch=None, sol_patch=None,
            shell_chr=b'', spare_chr=b''):
    pb2_prg, pb2_chr = load(PB2)
    sol_prg, sol_chr = load(SOL)
    if pb2_patch: pb2_patch(pb2_prg, pb2_chr)
    if sol_patch: sol_patch(sol_prg, sol_chr)
    prg = (game_block(pb2_prg, pb2_new) +
           blank_block(shell_banks) +
           game_block(sol_prg, sol_new) +
           blank_block(spare_banks))
    # CHR: [0-127] PB2 original | [128-255] new tiles for the PB2/shell window
    #      [256-383] Solbrain original | [384-511] new tiles for the Solbrain window
    chrom = (chr_block(pb2_chr) + chr_block(shell_chr) +
             chr_block(sol_chr) + chr_block(spare_chr))
    assert len(prg) == 1024*1024 and len(chrom) == 512*1024
    write_nes(out, make_header(len(prg), len(chrom), 45), prg, chrom)
    return out

if __name__ == '__main__':
    for b,n in [(0,'A PowerBlade2'),(1,'B shell'),(2,'C Solbrain'),(3,'D spare')]:
        r=outer_regs(b)
        print(f"block {n:14} reg0=${r[0]:02X} reg1=${r[1]:02X} reg2=${r[2]:02X} reg3=${r[3]:02X}")
    compose(sys.argv[1] if len(sys.argv)>1 else "work/build/PB3_layout_test.nes")
