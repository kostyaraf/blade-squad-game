/* nesemu.c - headless NES emulator for ROM-hacking work
 *
 * build: clang -O2 -Wall -o nesemu nesemu.c -lz
 *
 * Cycle-driven 6502 (all official + common unofficial opcodes), scanline PPU,
 * MMC3 (+ mappers 0/1/2/3), APU frame counter / length counters / $4015,
 * two controllers, PNG screenshots, PRG execution coverage, tracing.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <zlib.h>

/* ------------------------------------------------------------------ */
/* globals                                                             */
/* ------------------------------------------------------------------ */

static uint8_t  ram[0x800];
static uint8_t  prgram[0x2000];
static uint8_t *prg = NULL;   static int prg_size = 0;
static uint8_t *chr = NULL;   static int chr_size = 0;
static int      chr_is_ram = 0;
static int      mapper = 0;
static int      four_screen = 0;

static int prg_map[4];   /* physical byte offset of the 8KB bank at $8000/$A000/$C000/$E000 */
static int chr_map[8];   /* physical byte offset of the 1KB bank at $0000..$1C00           */

/* nametable mirroring */
enum { MIR_HORZ = 0, MIR_VERT, MIR_S0, MIR_S1, MIR_4SCR };
static int mirror_mode = MIR_HORZ;
static uint8_t vram[0x1000];
static uint8_t pal[32];

/* cpu */
static uint8_t  A, X, Y, SP;
static uint8_t  P = 0x24;
static uint16_t PC;
static uint64_t cpu_cycle = 0;
static uint8_t  pending_poll_I = 0x04;
static int      nmi_pending = 0;
static int      nmi_prev = 0;
static uint8_t  bus_last = 0;
static int      cpu_jammed = 0;

#define FC 0x01
#define FZ 0x02
#define FI 0x04
#define FD 0x08
#define FB 0x10
#define FU 0x20
#define FV 0x40
#define FN 0x80

/* ppu */
static uint8_t  ppuctrl, ppumask, ppustatus, oamaddr;
static uint16_t vreg, treg;
static uint8_t  fine_x, wtoggle;
static uint8_t  ppu_buf;
static uint8_t  oam[256];
static int      scanline = 0, dot = 0;
static int      odd_frame = 0;
static int      frame_done = 0;
static uint8_t  fb[256 * 240];

/* apu */
static uint8_t  apu_len[4];
static uint8_t  apu_halt[4];
static uint8_t  apu_enable = 0;
static int      apu_mode = 0;         /* 0 = 4-step, 1 = 5-step */
static int      apu_irq_inhibit = 0;
static int      apu_frame_irq = 0;
static int      apu_dmc_irq = 0;
static uint32_t apu_ctr = 0;
static int      apu_reset_delay = 0;
static uint8_t  apu_regs[0x18];

static const uint8_t length_tbl[32] = {
    10,254, 20,  2, 40,  4, 80,  6,160,  8, 60, 10, 14, 12, 26, 14,
    12, 16, 24, 18, 48, 20, 96, 22,192, 24, 72, 26, 16, 28, 32, 30
};

/* mmc3 */
static uint8_t mmc3_bank_select = 0;
static uint8_t mmc3_regs[8];
static uint8_t mmc3_ram_protect = 0x00;   /* power-on: work RAM off */
static uint8_t mmc3_irq_latch = 0;
static uint8_t mmc3_irq_counter = 0;
static int     mmc3_irq_reload = 0;
static int     mmc3_irq_enable = 0;
static int     mmc3_irq_pending = 0;

/* mmc1 */
static uint8_t mmc1_shift = 0x10, mmc1_count = 0;
static uint8_t mmc1_ctrl = 0x0C, mmc1_chr0 = 0, mmc1_chr1 = 0, mmc1_prg = 0;

/* simple mappers */
static uint8_t m2_bank = 0, m3_bank = 0;

/* ------------------------------------------------------------------ *
 * MULTICART MAPPERS 47 AND 45                                         *
 * ------------------------------------------------------------------ *
 *
 * Sources followed, and why
 * -------------------------
 * Primary: NESdev Wiki INES_Mapper_047 and INES_Mapper_045 (raw wikitext
 * pulled via Special:Export, so the bit-field tables below are the wiki's
 * own, not a paraphrase).
 *
 * Where the wiki is silent (power-on state, exact bank arithmetic) I
 * followed **Mesen2** -- Core/NES/Mappers/Nintendo/MMC3_47.h and
 * Core/NES/Mappers/Mmc3Variants/MMC3_45.h -- in preference to FCEUX.
 * Reason: FCEUX's src/boards/mmc3.cpp M45CW/M45PW never AND the incoming
 * MMC3 bank number at all; they only OR extra bits in, and they apply the
 * AND mask to the *outer* value instead of to the MMC3 value.  That
 * contradicts the wiki ("OR'd with MMC3's CHR A10-A17 *masked according to
 * CHR-AND*").  Mesen2 implements exactly what the wiki describes, so Mesen2
 * wins every disagreement below.  Mapper 47 is identical in both, and both
 * agree with the wiki.
 *
 * ---------------- MAPPER 47 (wiki: "Yet another MMC3 multicart") --------
 *
 *   $6000-$7FFF:  [.... ...B]   Block select
 *   $8000-$FFFF:  Same as MMC3 for the selected block
 *   "Each block has 128k PRG and 128k CHR."  "There is no PRG-RAM.  The
 *   multicart reg lies at $6000-7FFF, but is only writable when MMC3
 *   PRG-RAM is enabled and writable (see $A001)."
 *
 * Bit fields:
 *   B = bit 0 of the value written anywhere in $6000-$7FFF.  Bits 1-7 are
 *       ignored.  B selects one of two 128 KiB PRG / 128 KiB CHR blocks.
 *
 * Bank arithmetic (Mesen2 MMC3_47.h, identical to FCEUX M47PW/M47CW):
 *   prg8  = (mmc3_prg_bank & 0x0F) | (B << 4)      128 KiB = 16 x 8 KiB
 *   chr1  = (mmc3_chr_bank & 0x7F) | (B << 7)      128 KiB = 128 x 1 KiB
 *
 * Block-relative fixed banks: the transform above is applied to EVERY bank
 * the MMC3 selects, including the two hardwired $C000/$E000 "second to last"
 * and "last" banks.  Those are fed in as the 8-bit values -2 = $FE and
 * -1 = $FF, so $FE & $0F = 14 and $FF & $0F = 15, i.e. the last two 8 KiB
 * banks *of the selected block*, not of the whole ROM.  This is the whole
 * point of the mapper and is what makes both games on the cart bootable.
 *
 * Write gating: the wiki and Mesen2 both require MMC3 PRG-RAM to be
 * enabled and not write-protected ($A001 bit 7 set, bit 6 clear) for the
 * $6000-$7FFF write to land.  FCEUX omits this check; I follow the wiki.
 * There is no PRG-RAM on this board, so $6000-$7FFF writes do not store.
 *
 * Power-on / reset: B = 0 (both emulators), MMC3 otherwise at its normal
 * power-on state.
 *
 * ---------------- MAPPER 45 (GA23C ASIC, "Super 1,000,000 in 1") --------
 *
 * Four outer bank registers are written through a single port at $6000
 * (mask $F001, i.e. even addresses in $6000-$7FFF).  The first write goes
 * to register #0, the second to #1, the third to #2, the fourth to #3, and
 * the fifth wraps back to #0.  The registers overlay WRAM and work
 * regardless of the MMC3's $A001 WRAM bits (unlike mapper 47).
 *
 * Register #0 -- CHR-OR LSB ($6000 #0, write, mask $F001)
 *   D~7654 3210
 *     CCCC CCCC
 *     ++++-++++- Select CHR A10-A17, OR'd with MMC3's CHR A10-A17 masked
 *                according to CHR-AND.
 *   => contributes bits 0-7 of the 1 KiB CHR bank number.
 *
 * Register #1 -- PRG-OR LSB ($6000 #1, write, mask $F001)
 *   D~7654 3210
 *     ppPP PPPP
 *     ||++-++++- Select PRG A13-A18, OR'd with MMC3's PRG A13-A18 masked
 *     ||         according to PRG-AND      => 8 KiB bank bits 0-5
 *     ++-------- Select PRG A19-A20        => 8 KiB bank bits 6-7
 *   => the whole byte contributes bits 0-7 of the 8 KiB PRG bank number.
 *
 * Register #2 -- CHR-AND / CHR-OR MSB / PRG-OR MSB ($6000 #2, mask $F001)
 *   D~7654 3210
 *     PPCC cccc
 *     |||| ++++- Select number of CHR bits taken from the MMC3
 *     ||||       ($F: 256 KiB, $E: 128 KiB ... $7-$0: 1 KiB)
 *     ||++------ Select CHR A18-A19        => CHR bank bits 8-9
 *     ++-------- Select CHR A20-A21 and PRG A21-A22
 *                                          => CHR bank bits 10-11
 *                                          => PRG bank bits 8-9
 *   CHR-AND decode: the field counts how many low bank bits survive from
 *   the MMC3.  $F keeps 8 bits (256 KiB / 1 KiB = 256 banks), $E keeps 7,
 *   ... $8 keeps 1, and $7 down to $0 keep none.  Closed form used here and
 *   in Mesen2:   chr_and = 0xFF >> (0x0F - (reg2 & 0x0F))
 *   ($0F-$08 give $FF,$7F,$3F,$1F,$0F,$07,$03,$01; $07-$00 give 0.)
 *   Note both CHR-OR MSB nibbles land at the same place, so the CHR-OR
 *   high bits are simply ((reg2 & 0xF0) << 4).
 *
 * Register #3 -- PRG-AND / register lock ($6000 #3, write, mask $F001)
 *   D~7654 3210
 *     1LPP PPPP
 *      |++-++++- Select PRG-AND mask, INVERTED
 *      |         ($00: 512 KiB, $20: 256 KiB ...)
 *      +-------- 1 = Lock outer bank registers
 *   Bit 7 reads as 1 on hardware and is not used by the mapper logic.
 *   PRG-AND decode:  prg_and = 0x3F ^ (reg3 & 0x3F)
 *   ($00 -> $3F = 64 x 8 KiB = 512 KiB; $20 -> $1F = 256 KiB; etc.)
 *   Lock (bit 6): once set, further writes to $6000 are ignored until a
 *   write to $6001 or a console reset.
 *
 * Reset port ($6001, write, mask $F001)
 *   "Writing any value to $6001 resets the outer bank registers as a soft
 *   reset would, clearing the Lock bit and making the next write to $6000
 *   go to register #0."  So it restores the power-on values below.
 *   (FCEUX only clears the lock bit here; I follow the wiki, which is
 *   explicit that the full register set is reset.)
 *
 * Bank arithmetic (Mesen2 MMC3_45.h, matches the wiki text):
 *   prg8 = (mmc3_prg_bank & prg_and) | prg_or
 *          prg_and = 0x3F ^ (reg3 & 0x3F)
 *          prg_or  = reg1 | ((reg2 & 0xC0) << 2)
 *   chr1 = (mmc3_chr_bank & chr_and) | chr_or        [CHR-ROM boards only]
 *          chr_and = 0xFF >> (0x0F - (reg2 & 0x0F))
 *          chr_or  = reg0 | ((reg2 & 0xF0) << 4)
 *
 *   Divergence note for the diff: Mesen2 writes plain `page |= _reg[1]`
 *   and does NOT fold reg2 bits 6-7 into the PRG bank.  The wiki does
 *   ("Select CHR A20-A21 and PRG A21-22"), so I include ((reg2 & 0xC0) << 2).
 *   The two are identical for every cart of 1 MiB or less, because reg2
 *   bits 6-7 only ever get set on carts with more than 1 MiB of CHR.
 *
 *   As in Mesen2, the CHR transform is skipped entirely on CHR-RAM boards
 *   (the outer CHR bits have nothing to address).
 *
 * Block-relative fixed banks: same mechanism as mapper 47 -- the MMC3's
 * hardwired $C000/$E000 banks arrive as $FE and $FF and are masked by
 * prg_and, so at power-on (prg_and = $3F) they become banks 62 and 63 of
 * the current 512 KiB window rather than of the whole ROM.
 *
 * PRG-RAM: the outer registers overlay WRAM.  Following FCEUX, a write to
 * $6000-$7FFF also stores the byte into PRG-RAM so reads still work; once
 * the lock bit is set the port behaves as plain WRAM (Mesen2 removes the
 * register range at that point, which is the same observable behaviour).
 *
 * Menu Selection #1 ($5000-$5FFF, read): a DIP switch, 8 positions.
 *   A~FEDC BA98 7654 3210   D~7654 3210
 *     0101 AAAA AAAA ....     .... ...D
 *          ++++-++++--------------------+- 1 = if the DIP switch is in the
 *                                           position selected by that A bit
 *   i.e. D0 = (addr >> (4 + dip)) & 1.  Implemented; the DIP defaults to
 *   position 0.  (FCEUX uses a slightly different mask that also matches
 *   lower address bits; I follow the wiki.)
 *
 * Power-on / reset (Mesen2 MMC3_45.h Reset()):
 *   reg[0] = 0, reg[1] = 0, reg[2] = 0x0F, reg[3] = 0, write index = 0.
 *   reg[2] = 0x0F is essential: it makes CHR-AND = $FF so an uninitialised
 *   cart behaves like a plain MMC3 for CHR.  FCEUX leaves reg[2] = 0, which
 *   only works because FCEUX never applies the CHR-AND mask at all.
 *   Mesen2 additionally pre-seeds the MMC3 bank registers to
 *   {0,2,4,5,6,7} because "Famicom Yarou Vol 1" writes CHR-RAM before
 *   initialising them; that is reproduced here.
 */
static uint8_t m45_reg[4] = {0, 0, 0x0F, 0};
static uint8_t m45_index = 0;
static uint8_t m45_dip = 0;
static uint8_t m47_block = 0;

/* controllers */
static uint8_t pad_state[2];      /* live button state for the current frame */
static uint8_t pad_shift[2];
static int     pad_strobe = 0;

/* frame / cli */
static long cur_frame = 1;
static long start_frame = 1;
static long opt_frames = 600;
static const char *opt_png_prefix = NULL;
static long opt_shots[64]; static int opt_nshots = 0;
static const char *opt_cov = NULL;
static const char *opt_trace = NULL;
static const char *opt_ramdump = NULL;
static const char *opt_statedump = NULL;
static long opt_tracefrom = -1, opt_traceto = -1;
static long opt_tracepc_lo = -1, opt_tracepc_hi = -1;
static long opt_watch_lo = -1, opt_watch_hi = -1;
static FILE *trace_fp = NULL;
static uint8_t *cov_bits = NULL;
static const char *opt_prgread = NULL;   /* every PRG byte fetched off the bus */
static uint8_t *rd_bits = NULL;
static long opt_readfrom = -1, opt_readto = -1;
static long opt_verbose_lo = -1, opt_verbose_hi = -1;
static const char *opt_loadstate = NULL;

typedef struct { const char *path; long frame; } SaveReq;
static SaveReq savereqs[64]; static int n_savereqs = 0;
static SaveReq vramreqs[512]; static int n_vramreqs = 0;
/* CHR bank mapping sampled at the start of every visible scanline, so a ripped
 * frame can be rebuilt even though MMC3 swaps banks mid-screen. */
static uint16_t chr_scan[240][8];
static uint16_t v_scan[240];      /* loopy v as the scanline was drawn */
static uint8_t  fx_scan[240];     /* fine X ditto */
static uint8_t  mask_scan[240];   /* PPUMASK ditto */
static uint8_t  ctrl_scan[240];   /* PPUCTRL ditto (pattern table select) */
static uint8_t  pal_scan[240][32];/* palette ditto */
static int chr_scan_arm = 0;

typedef struct { long frame; uint16_t addr; uint8_t val; } PokeEnt;
static PokeEnt pokes[256]; static int n_pokes = 0;

typedef struct { uint16_t addr; uint8_t val; long from; } FreezeEnt;
static FreezeEnt freezes[256]; static int n_freezes = 0;

/* a byte of the cartridge itself, written over before the run begins.  Unlike
   -poke this cannot be undone by the game and costs nothing per frame: it is
   for turning a routine off for a whole run (a study aid, not a fix). */
typedef struct { long off; uint8_t val; } RomPokeEnt;
static RomPokeEnt rompokes[256]; static int n_rompokes = 0;

/* -sample PC=ADDR: what an address held at the moment a piece of code was
 * reached.  A watch says what was written; this says what was read, which is
 * the only way to see what a routine actually decided on. */
/* `spec` is either an address to read or, when `reg` is set, one of the
   processor's own registers: 1 = A, 2 = X, 3 = Y, 4 = P. */
typedef struct { uint16_t pc, addr; int reg; } SampleEnt;
static SampleEnt samples[64]; static int n_samples = 0;

/* input script */
typedef struct { long frame; uint8_t p1, p2; } InputEnt;
static InputEnt *inputs = NULL; static int n_inputs = 0, input_idx = 0;

/* ------------------------------------------------------------------ */
/* forward decls                                                       */
/* ------------------------------------------------------------------ */
static void ppu_tick(void);
static void apu_tick(void);
static uint8_t bus_read(uint16_t a);
static void bus_write(uint16_t a, uint8_t v);
static uint8_t ppu_bus_read(uint16_t a);
static int mapper_prg_wrap(int bank);
static int mapper_chr_wrap(int bank);
static void mmc3_update(void);

static int is_mmc3(void) { return mapper == 4 || mapper == 45 || mapper == 47; }

/* ------------------------------------------------------------------ */
/* mapper                                                              */
/* ------------------------------------------------------------------ */

static int prg_bank_count(void) { return prg_size / 0x2000; }
static int chr_bank_count(void) { return chr_size ? chr_size / 0x400 : 8; }

static void set_prg8(int slot, int bank)
{
    int n = prg_bank_count();
    if (n <= 0) { prg_map[slot] = 0; return; }
    bank = mapper_prg_wrap(bank);
    bank %= n; if (bank < 0) bank += n;
    prg_map[slot] = bank * 0x2000;
}
static void set_chr1(int slot, int bank)
{
    int n = chr_bank_count();
    if (n <= 0) { chr_map[slot] = 0; return; }
    bank = mapper_chr_wrap(bank);
    bank %= n; if (bank < 0) bank += n;
    chr_map[slot] = bank * 0x400;
}

/* Outer-bank transforms; see the big comment block above for the derivation
 * of every mask and shift.  Applied to EVERY MMC3 bank selection, which is
 * what makes the MMC3 fixed $C000/$E000 banks block-relative. */
static int m45_prg_and(void) { return 0x3F ^ (m45_reg[3] & 0x3F); }
static int m45_prg_or(void)  { return m45_reg[1] | ((m45_reg[2] & 0xC0) << 2); }
static int m45_chr_and(void) { return 0xFF >> (0x0F - (m45_reg[2] & 0x0F)); }
static int m45_chr_or(void)  { return m45_reg[0] | ((m45_reg[2] & 0xF0) << 4); }

static int mapper_prg_wrap(int bank)
{
    switch (mapper) {
    case 47: return (bank & 0x0F) | (m47_block << 4);
    case 45: return (bank & m45_prg_and()) | m45_prg_or();
    default: return bank;
    }
}
static int mapper_chr_wrap(int bank)
{
    switch (mapper) {
    case 47: return (bank & 0x7F) | (m47_block << 7);
    case 45:
        if (chr_is_ram) return bank;   /* as Mesen2: CHR-RAM boards untouched */
        return (bank & m45_chr_and()) | m45_chr_or();
    default: return bank;
    }
}

static void mmc3_update(void)
{
    /* The two hardwired banks.  On a plain MMC3 they are simply the last two
     * 8 KiB banks of the ROM.  On the multicart clones they must go through
     * the outer-bank transform, so they are fed in as the 8-bit values
     * -1 = $FF and -2 = $FE and get masked down into the active block. */
    int last, last2;
    if (mapper == 45 || mapper == 47) { last = 0xFF; last2 = 0xFE; }
    else { last = prg_bank_count() - 1; last2 = last - 1; }

    if (mmc3_bank_select & 0x40) {
        set_prg8(0, last2);
        set_prg8(1, mmc3_regs[7]);
        set_prg8(2, mmc3_regs[6]);
        set_prg8(3, last);
    } else {
        set_prg8(0, mmc3_regs[6]);
        set_prg8(1, mmc3_regs[7]);
        set_prg8(2, last2);
        set_prg8(3, last);
    }
    if (mmc3_bank_select & 0x80) {
        set_chr1(0, mmc3_regs[2]);
        set_chr1(1, mmc3_regs[3]);
        set_chr1(2, mmc3_regs[4]);
        set_chr1(3, mmc3_regs[5]);
        set_chr1(4, mmc3_regs[0] & 0xFE);
        set_chr1(5, (mmc3_regs[0] & 0xFE) | 1);
        set_chr1(6, mmc3_regs[1] & 0xFE);
        set_chr1(7, (mmc3_regs[1] & 0xFE) | 1);
    } else {
        set_chr1(0, mmc3_regs[0] & 0xFE);
        set_chr1(1, (mmc3_regs[0] & 0xFE) | 1);
        set_chr1(2, mmc3_regs[1] & 0xFE);
        set_chr1(3, (mmc3_regs[1] & 0xFE) | 1);
        set_chr1(4, mmc3_regs[2]);
        set_chr1(5, mmc3_regs[3]);
        set_chr1(6, mmc3_regs[4]);
        set_chr1(7, mmc3_regs[5]);
    }
}

static void mmc1_update(void)
{
    switch (mmc1_ctrl & 3) {
    case 0: mirror_mode = MIR_S0;   break;
    case 1: mirror_mode = MIR_S1;   break;
    case 2: mirror_mode = MIR_VERT; break;
    case 3: mirror_mode = MIR_HORZ; break;
    }
    int prgmode = (mmc1_ctrl >> 2) & 3;
    int b = mmc1_prg & 0x0F;
    int last16 = prg_bank_count() / 2 - 1;
    if (prgmode == 0 || prgmode == 1) {          /* 32KB */
        set_prg8(0, (b & 0xFE) * 2);
        set_prg8(1, (b & 0xFE) * 2 + 1);
        set_prg8(2, (b & 0xFE) * 2 + 2);
        set_prg8(3, (b & 0xFE) * 2 + 3);
    } else if (prgmode == 2) {                   /* fix first 16KB at $8000 */
        set_prg8(0, 0); set_prg8(1, 1);
        set_prg8(2, b * 2); set_prg8(3, b * 2 + 1);
    } else {                                     /* fix last 16KB at $C000 */
        set_prg8(0, b * 2); set_prg8(1, b * 2 + 1);
        set_prg8(2, last16 * 2); set_prg8(3, last16 * 2 + 1);
    }
    if (mmc1_ctrl & 0x10) {                      /* two 4KB banks */
        for (int i = 0; i < 4; i++) set_chr1(i, mmc1_chr0 * 4 + i);
        for (int i = 0; i < 4; i++) set_chr1(4 + i, mmc1_chr1 * 4 + i);
    } else {
        for (int i = 0; i < 8; i++) set_chr1(i, (mmc1_chr0 & 0x1E) * 4 + i);
    }
}

/* $6000-$7FFF port of mapper 47: one block-select bit, gated on the MMC3
 * PRG-RAM enable/protect bits ($A001 b7 set, b6 clear) per the wiki. */
static void m47_port_write(uint8_t v)
{
    if (!(mmc3_ram_protect & 0x80) || (mmc3_ram_protect & 0x40)) return;
    m47_block = (uint8_t)(v & 1);
    mmc3_update();
}

/* $6000-$7FFF port of mapper 45.  Even address = next outer register in the
 * 4-deep rotation (ignored while locked); odd address = reset the outer
 * registers and release the lock.  The byte is also stored into WRAM
 * because the registers only "overlay" it. */
static void m45_port_write(uint16_t a, uint8_t v)
{
    prgram[a & 0x1FFF] = v;
    if (a & 1) {
        m45_reg[0] = 0; m45_reg[1] = 0; m45_reg[2] = 0x0F; m45_reg[3] = 0;
        m45_index = 0;
    } else {
        if (m45_reg[3] & 0x40) return;          /* lock bit */
        m45_reg[m45_index] = v;
        m45_index = (uint8_t)((m45_index + 1) & 3);
    }
    mmc3_update();
}

static void mapper_reset(void)
{
    int last = prg_bank_count() - 1;
    switch (mapper) {
    case 4:
    case 47:
        memset(mmc3_regs, 0, sizeof mmc3_regs);
        mmc3_regs[6] = 0; mmc3_regs[7] = 1;
        mmc3_bank_select = 0;
        /* a real MMC3 powers up with its work RAM disabled */
        mmc3_ram_protect = (mapper == 4) ? 0x00 : 0x80;
        m47_block = 0;
        mmc3_update();
        break;
    case 45:
        /* wiki $6001 reset state == power-on state; reg2 = $0F is required
         * so CHR-AND starts as $FF (Mesen2 MMC3_45.h Reset()). */
        m45_reg[0] = 0; m45_reg[1] = 0; m45_reg[2] = 0x0F; m45_reg[3] = 0;
        m45_index = 0;
        mmc3_bank_select = 0;
        mmc3_ram_protect = 0x80;
        /* Mesen2 pre-seeds these for Famicom Yarou Vol 1. */
        mmc3_regs[0] = 0; mmc3_regs[1] = 2; mmc3_regs[2] = 4;
        mmc3_regs[3] = 5; mmc3_regs[4] = 6; mmc3_regs[5] = 7;
        mmc3_regs[6] = 0; mmc3_regs[7] = 1;
        mmc3_update();
        break;
    case 1:
        mmc1_ctrl = 0x0C; mmc1_prg = 0; mmc1_chr0 = 0; mmc1_chr1 = 0;
        mmc1_shift = 0x10; mmc1_count = 0;
        mmc1_update();
        break;
    case 2:
        m2_bank = 0;
        set_prg8(0, 0); set_prg8(1, 1);
        set_prg8(2, last - 1); set_prg8(3, last);
        for (int i = 0; i < 8; i++) set_chr1(i, i);
        break;
    case 3:
        m3_bank = 0;
        set_prg8(0, 0); set_prg8(1, 1);
        set_prg8(2, prg_bank_count() > 2 ? 2 : 0);
        set_prg8(3, prg_bank_count() > 2 ? 3 : 1);
        for (int i = 0; i < 8; i++) set_chr1(i, i);
        break;
    default: /* 0 */
        set_prg8(0, 0); set_prg8(1, 1);
        set_prg8(2, prg_bank_count() > 2 ? 2 : 0);
        set_prg8(3, prg_bank_count() > 2 ? 3 : 1);
        for (int i = 0; i < 8; i++) set_chr1(i, i);
        break;
    }
}

static void mapper_write(uint16_t a, uint8_t v)
{
    switch (mapper) {
    case 4: case 45: case 47:
        switch (a & 0xE001) {
        case 0x8000: mmc3_bank_select = v; mmc3_update(); break;
        case 0x8001: mmc3_regs[mmc3_bank_select & 7] = v; mmc3_update(); break;
        case 0xA000:
            if (!four_screen) mirror_mode = (v & 1) ? MIR_HORZ : MIR_VERT;
            break;
        case 0xA001: mmc3_ram_protect = v; break;
        case 0xC000: mmc3_irq_latch = v; break;
        case 0xC001: mmc3_irq_counter = 0; mmc3_irq_reload = 1; break;
        case 0xE000: mmc3_irq_enable = 0; mmc3_irq_pending = 0; break;
        case 0xE001: mmc3_irq_enable = 1; break;
        }
        break;
    case 1:
        if (v & 0x80) {
            mmc1_shift = 0x10; mmc1_count = 0;
            mmc1_ctrl |= 0x0C; mmc1_update();
        } else {
            mmc1_shift = (uint8_t)((mmc1_shift >> 1) | ((v & 1) << 4));
            if (++mmc1_count == 5) {
                uint8_t s = mmc1_shift & 0x1F;
                switch ((a >> 13) & 3) {
                case 0: mmc1_ctrl = s; break;
                case 1: mmc1_chr0 = s; break;
                case 2: mmc1_chr1 = s; break;
                case 3: mmc1_prg  = s; break;
                }
                mmc1_shift = 0x10; mmc1_count = 0;
                mmc1_update();
            }
        }
        break;
    case 2:
        m2_bank = v & 0x0F;
        set_prg8(0, m2_bank * 2); set_prg8(1, m2_bank * 2 + 1);
        break;
    case 3:
        m3_bank = v & 0x03;
        for (int i = 0; i < 8; i++) set_chr1(i, m3_bank * 8 + i);
        break;
    default: break;
    }
}

/* ------------------------------------------------------------------ */
/* ppu memory                                                          */
/* ------------------------------------------------------------------ */

static int nt_offset(uint16_t a)
{
    a &= 0x0FFF;
    int table = a >> 10, idx = a & 0x3FF;
    static const int mh[4] = {0, 0, 1, 1};
    static const int mv[4] = {0, 1, 0, 1};
    switch (mirror_mode) {
    case MIR_HORZ: return mh[table] * 0x400 + idx;
    case MIR_VERT: return mv[table] * 0x400 + idx;
    case MIR_S0:   return idx;
    case MIR_S1:   return 0x400 + idx;
    default:       return table * 0x400 + idx;   /* four screen */
    }
}

static uint8_t pal_read(int i)
{
    i &= 0x1F;
    if ((i & 0x13) == 0x10) i &= 0x0F;
    return pal[i];
}
static void pal_write(int i, uint8_t v)
{
    i &= 0x1F;
    if ((i & 0x13) == 0x10) i &= 0x0F;
    pal[i] = v & 0x3F;
}

static uint8_t ppu_bus_read(uint16_t a)
{
    a &= 0x3FFF;
    if (a < 0x2000) return chr[chr_map[a >> 10] + (a & 0x3FF)];
    if (a < 0x3F00) return vram[nt_offset(a)];
    return pal_read(a);
}

static void ppu_bus_write(uint16_t a, uint8_t v)
{
    a &= 0x3FFF;
    if (a < 0x2000) { if (chr_is_ram) chr[chr_map[a >> 10] + (a & 0x3FF)] = v; return; }
    if (a < 0x3F00) { vram[nt_offset(a)] = v; return; }
    pal_write(a, v);
}

/* ------------------------------------------------------------------ */
/* ppu rendering                                                       */
/* ------------------------------------------------------------------ */

static void ppu_update_nmi(void)
{
    int out = (ppuctrl & 0x80) && (ppustatus & 0x80);
    if (out && !nmi_prev) nmi_pending = 1;
    nmi_prev = out;
}

static void render_scanline(int sl)
{
    uint8_t *line = &fb[sl * 256];
    uint8_t bgpix[256], bgcol[256];
    uint8_t sppix[256], sppri[256], spcol[256];
    uint8_t backdrop = pal_read(0) & 0x3F;
    int show_bg  = (ppumask & 0x08) != 0;
    int show_spr = (ppumask & 0x10) != 0;

    if (!(ppumask & 0x18)) {
        memset(line, backdrop, 256);
        return;
    }

    memset(bgpix, 0, 256);
    memset(bgcol, backdrop, 256);
    memset(sppix, 0, 256);

    if (show_bg) {
        uint16_t vv = vreg;
        int fineY   = (vv >> 12) & 7;
        int coarseY = (vv >> 5) & 0x1F;
        int coarseX0 = vv & 0x1F;
        uint16_t ntsel = vv & 0x0C00;
        int bgbase = (ppuctrl & 0x10) ? 0x1000 : 0x0000;

        for (int t = 0; t < 33; t++) {
            int cxx = coarseX0 + t;
            uint16_t nt = (uint16_t)(0x2000 | (ntsel ^ ((cxx & 0x20) ? 0x0400 : 0)));
            int cx = cxx & 0x1F;
            uint8_t tile = ppu_bus_read((uint16_t)(nt | (coarseY << 5) | cx));
            uint8_t at = ppu_bus_read((uint16_t)(nt | 0x03C0 | ((coarseY >> 2) << 3) | (cx >> 2)));
            int shift = ((coarseY & 2) << 1) | (cx & 2);
            int palsel = (at >> shift) & 3;
            uint16_t pa = (uint16_t)(bgbase + tile * 16 + fineY);
            uint8_t lo = ppu_bus_read(pa), hi = ppu_bus_read((uint16_t)(pa + 8));
            for (int p = 0; p < 8; p++) {
                int sx = t * 8 + p - fine_x;
                if (sx < 0) continue;
                if (sx > 255) break;
                if (sx < 8 && !(ppumask & 0x02)) continue;
                int b = 7 - p;
                int c = ((lo >> b) & 1) | (((hi >> b) & 1) << 1);
                bgpix[sx] = (uint8_t)c;
                bgcol[sx] = c ? (pal_read(palsel * 4 + c) & 0x3F) : backdrop;
            }
        }
    }

    if (show_spr) {
        int sprh = (ppuctrl & 0x20) ? 16 : 8;
        int idx[8], cnt = 0, kept = 0;
        for (int i = 0; i < 64; i++) {
            int y = oam[i * 4];
            int row = sl - y - 1;
            if (row >= 0 && row < sprh) {
                cnt++;
                if (kept < 8) idx[kept++] = i;
                else { ppustatus |= 0x20; break; }
            }
        }
        (void)cnt;
        for (int k = kept - 1; k >= 0; k--) {
            int i = idx[k];
            int y = oam[i * 4];
            uint8_t tn = oam[i * 4 + 1];
            uint8_t at = oam[i * 4 + 2];
            int sx0 = oam[i * 4 + 3];
            int row = sl - y - 1;
            if (at & 0x80) row = sprh - 1 - row;
            uint16_t pa;
            if (sprh == 16) {
                int base = (tn & 1) ? 0x1000 : 0x0000;
                int t = (tn & 0xFE) + (row >= 8 ? 1 : 0);
                pa = (uint16_t)(base + t * 16 + (row & 7));
            } else {
                pa = (uint16_t)(((ppuctrl & 0x08) ? 0x1000 : 0x0000) + tn * 16 + row);
            }
            uint8_t lo = ppu_bus_read(pa), hi = ppu_bus_read((uint16_t)(pa + 8));
            for (int p = 0; p < 8; p++) {
                int x = sx0 + p;
                if (x > 255) break;
                if (x < 8 && !(ppumask & 0x04)) continue;
                int b = (at & 0x40) ? p : 7 - p;
                int c = ((lo >> b) & 1) | (((hi >> b) & 1) << 1);
                if (!c) continue;
                if (i == 0 && show_bg && bgpix[x] && x != 255) ppustatus |= 0x40;
                sppix[x] = (uint8_t)c;
                sppri[x] = (at & 0x20) ? 1 : 0;
                spcol[x] = pal_read(0x10 + (at & 3) * 4 + c) & 0x3F;
            }
        }
    }

    for (int x = 0; x < 256; x++) {
        if (sppix[x] && (!bgpix[x] || !sppri[x])) line[x] = spcol[x];
        else line[x] = bgcol[x];
    }
}

static void ppu_inc_y(void)
{
    if ((vreg & 0x7000) != 0x7000) {
        vreg += 0x1000;
    } else {
        vreg &= ~0x7000;
        int y = (vreg & 0x03E0) >> 5;
        if (y == 29) { y = 0; vreg ^= 0x0800; }
        else if (y == 31) { y = 0; }
        else y++;
        vreg = (uint16_t)((vreg & ~0x03E0) | (y << 5));
    }
}

static void mmc3_clock_irq(void)
{
    if (mmc3_irq_counter == 0 || mmc3_irq_reload) {
        mmc3_irq_counter = mmc3_irq_latch;
        mmc3_irq_reload = 0;
    } else {
        mmc3_irq_counter--;
    }
    if (mmc3_irq_counter == 0 && mmc3_irq_enable) mmc3_irq_pending = 1;
}

static void ppu_tick(void)
{
    int rendering = (ppumask & 0x18) != 0;

    if (scanline < 240) {
        if (dot == 256) {
            if (chr_scan_arm) {
                for (int i = 0; i < 8; i++)
                    chr_scan[scanline][i] = (uint16_t)(chr_map[i] / 0x400);
                v_scan[scanline]    = vreg;
                fx_scan[scanline]   = fine_x;
                mask_scan[scanline] = ppumask;
                ctrl_scan[scanline] = ppuctrl;
                memcpy(pal_scan[scanline], pal, 32);
            }
            render_scanline(scanline);
            if (rendering) ppu_inc_y();
        }
        else if (dot == 257) {
            if (rendering) {
                vreg = (uint16_t)((vreg & ~0x041F) | (treg & 0x041F));
                oamaddr = 0;
            }
        } else if (dot == 260) {
            if (rendering && is_mmc3()) mmc3_clock_irq();
        }
    } else if (scanline == 241) {
        if (dot == 1) {
            ppustatus |= 0x80;
            frame_done = 1;
            ppu_update_nmi();
        }
    } else if (scanline == 261) {
        if (dot == 1) {
            ppustatus &= (uint8_t)~0xE0;
            ppu_update_nmi();
        } else if (dot == 256) {
            if (rendering) ppu_inc_y();
        } else if (dot == 257) {
            if (rendering) {
                vreg = (uint16_t)((vreg & ~0x041F) | (treg & 0x041F));
                oamaddr = 0;
            }
        } else if (dot == 260) {
            if (rendering && is_mmc3()) mmc3_clock_irq();
        } else if (dot >= 280 && dot <= 304) {
            if (rendering) vreg = (uint16_t)((vreg & ~0x7BE0) | (treg & 0x7BE0));
        }
    }

    dot++;
    if (scanline == 261 && dot == 340 && odd_frame && rendering) {
        dot = 341;   /* skipped cycle on odd frames */
    }
    if (dot > 340) {
        dot = 0;
        scanline++;
        if (scanline > 261) { scanline = 0; odd_frame ^= 1; }
    }
}

/* ------------------------------------------------------------------ */
/* ppu registers                                                       */
/* ------------------------------------------------------------------ */

static uint8_t ppu_reg_read(uint16_t a)
{
    uint8_t r = bus_last;
    switch (a & 7) {
    case 2:
        r = (uint8_t)((ppustatus & 0xE0) | (bus_last & 0x1F));
        ppustatus &= (uint8_t)~0x80;
        wtoggle = 0;
        ppu_update_nmi();
        break;
    case 4:
        r = oam[oamaddr];
        break;
    case 7: {
        uint16_t addr = vreg & 0x3FFF;
        if (addr >= 0x3F00) {
            r = pal_read(addr);
            ppu_buf = vram[nt_offset(addr)];
        } else {
            r = ppu_buf;
            ppu_buf = ppu_bus_read(addr);
        }
        vreg = (uint16_t)((vreg + ((ppuctrl & 0x04) ? 32 : 1)) & 0x7FFF);
        break;
    }
    default: break;
    }
    return r;
}

static void ppu_reg_write(uint16_t a, uint8_t v)
{
    switch (a & 7) {
    case 0:
        ppuctrl = v;
        treg = (uint16_t)((treg & 0xF3FF) | ((v & 3) << 10));
        ppu_update_nmi();
        break;
    case 1: ppumask = v; break;
    case 2: break;
    case 3: oamaddr = v; break;
    case 4: oam[oamaddr++] = v; break;
    case 5:
        if (!wtoggle) {
            fine_x = v & 7;
            treg = (uint16_t)((treg & 0xFFE0) | (v >> 3));
            wtoggle = 1;
        } else {
            treg = (uint16_t)((treg & 0x8FFF) | ((v & 7) << 12));
            treg = (uint16_t)((treg & 0xFC1F) | ((v & 0xF8) << 2));
            wtoggle = 0;
        }
        break;
    case 6:
        if (!wtoggle) {
            treg = (uint16_t)((treg & 0x00FF) | ((v & 0x3F) << 8));
            wtoggle = 1;
        } else {
            treg = (uint16_t)((treg & 0xFF00) | v);
            vreg = treg;
            wtoggle = 0;
        }
        break;
    case 7:
        ppu_bus_write(vreg & 0x3FFF, v);
        vreg = (uint16_t)((vreg + ((ppuctrl & 0x04) ? 32 : 1)) & 0x7FFF);
        break;
    }
}

/* ------------------------------------------------------------------ */
/* apu                                                                 */
/* ------------------------------------------------------------------ */

static void apu_half_frame(void)
{
    for (int i = 0; i < 4; i++)
        if (!apu_halt[i] && apu_len[i]) apu_len[i]--;
}
static void apu_quarter_frame(void) { /* envelopes: not needed headless */ }

static void apu_tick(void)
{
    if (apu_reset_delay) {
        if (--apu_reset_delay == 0) {
            apu_ctr = 0;
            if (apu_mode) { apu_quarter_frame(); apu_half_frame(); }
        }
    }
    apu_ctr++;
    if (!apu_mode) {
        switch (apu_ctr) {
        case 7457:  apu_quarter_frame(); break;
        case 14913: apu_quarter_frame(); apu_half_frame(); break;
        case 22371: apu_quarter_frame(); break;
        case 29828: if (!apu_irq_inhibit) apu_frame_irq = 1; break;
        case 29829: apu_quarter_frame(); apu_half_frame();
                    if (!apu_irq_inhibit) apu_frame_irq = 1; break;
        case 29830: if (!apu_irq_inhibit) apu_frame_irq = 1; apu_ctr = 0; break;
        }
    } else {
        switch (apu_ctr) {
        case 7457:  apu_quarter_frame(); break;
        case 14913: apu_quarter_frame(); apu_half_frame(); break;
        case 22371: apu_quarter_frame(); break;
        case 37281: apu_quarter_frame(); apu_half_frame(); break;
        case 37282: apu_ctr = 0; break;
        }
    }
}

static uint8_t apu_read_status(void)
{
    uint8_t r = 0;
    for (int i = 0; i < 4; i++) if (apu_len[i]) r |= (uint8_t)(1 << i);
    if (apu_frame_irq) r |= 0x40;
    if (apu_dmc_irq) r |= 0x80;
    apu_frame_irq = 0;
    return r;
}

static void apu_write(uint16_t a, uint8_t v)
{
    if (a >= 0x4000 && a <= 0x4017) apu_regs[a - 0x4000] = v;
    switch (a) {
    case 0x4000: apu_halt[0] = (v & 0x20) ? 1 : 0; break;
    case 0x4004: apu_halt[1] = (v & 0x20) ? 1 : 0; break;
    case 0x4008: apu_halt[2] = (v & 0x80) ? 1 : 0; break;
    case 0x400C: apu_halt[3] = (v & 0x20) ? 1 : 0; break;
    case 0x4003: if (apu_enable & 0x01) apu_len[0] = length_tbl[v >> 3]; break;
    case 0x4007: if (apu_enable & 0x02) apu_len[1] = length_tbl[v >> 3]; break;
    case 0x400B: if (apu_enable & 0x04) apu_len[2] = length_tbl[v >> 3]; break;
    case 0x400F: if (apu_enable & 0x08) apu_len[3] = length_tbl[v >> 3]; break;
    case 0x4010: if (!(v & 0x80)) apu_dmc_irq = 0; break;
    case 0x4015:
        apu_enable = v & 0x1F;
        for (int i = 0; i < 4; i++) if (!(v & (1 << i))) apu_len[i] = 0;
        if (!(v & 0x10)) apu_dmc_irq = 0;
        break;
    case 0x4017:
        apu_mode = (v & 0x80) ? 1 : 0;
        apu_irq_inhibit = (v & 0x40) ? 1 : 0;
        if (apu_irq_inhibit) apu_frame_irq = 0;
        apu_reset_delay = (cpu_cycle & 1) ? 4 : 3;
        break;
    default: break;
    }
}

/* ------------------------------------------------------------------ */
/* cpu bus                                                             */
/* ------------------------------------------------------------------ */

static void oam_dma(uint8_t page);

static uint8_t bus_read(uint16_t a)
{
    uint8_t r;
    if (a < 0x2000)      r = ram[a & 0x7FF];
    else if (a < 0x4000) r = ppu_reg_read(a);
    else if (a < 0x4020) {
        if (a == 0x4015) r = apu_read_status();
        else if (a == 0x4016 || a == 0x4017) {
            int p = a & 1;
            uint8_t bit;
            if (pad_strobe) bit = pad_state[p] & 1;
            else { bit = pad_shift[p] & 1; pad_shift[p] = (uint8_t)((pad_shift[p] >> 1) | 0x80); }
            r = (uint8_t)(0x40 | bit);
        } else r = bus_last;
    }
    else if (a < 0x6000) {
        /* mapper 45 "Menu Selection #1" DIP read at $5000-$5FFF:
         * D0 = (addr >> (4 + dip)) & 1 */
        if (mapper == 45 && a >= 0x5000)
            r = (uint8_t)((bus_last & 0xFE) | ((a >> (4 + m45_dip)) & 1));
        else r = bus_last;
    }
    else if (a < 0x8000) {
        /* MMC3 leaves the cartridge's work RAM disabled until $A001 bit 7 is
         * set; a disabled read is open bus.  Modelling this is what catches
         * code that forgets to switch the RAM on. */
        r = (mapper == 4 && !(mmc3_ram_protect & 0x80))
            ? bus_last : prgram[a & 0x1FFF];
    }
    else {
        int poff = prg_map[(a >> 13) & 3] + (a & 0x1FFF);
        r = prg[poff];
        if (rd_bits && poff < prg_size &&
            (opt_readfrom < 0 || cur_frame >= opt_readfrom) &&
            (opt_readto   < 0 || cur_frame <= opt_readto))
            rd_bits[poff >> 3] |= (uint8_t)(1 << (poff & 7));
    }
    bus_last = r;
    return r;
}

static void watch_log(uint16_t a, uint8_t v);

static void bus_write(uint16_t a, uint8_t v)
{
    bus_last = v;
    if (opt_watch_lo >= 0 && a >= opt_watch_lo && a <= opt_watch_hi) watch_log(a, v);
    if (a < 0x2000)      { ram[a & 0x7FF] = v; return; }
    if (a < 0x4000)      { ppu_reg_write(a, v); return; }
    if (a < 0x4020) {
        if (a == 0x4014) { oam_dma(v); return; }
        if (a == 0x4016) {
            int ns = v & 1;
            if (pad_strobe && !ns) { pad_shift[0] = pad_state[0]; pad_shift[1] = pad_state[1]; }
            pad_strobe = ns;
            if (pad_strobe) { pad_shift[0] = pad_state[0]; pad_shift[1] = pad_state[1]; }
            return;
        }
        apu_write(a, v);
        return;
    }
    if (a < 0x6000) return;
    if (a < 0x8000) {
        if (mapper == 45) { m45_port_write(a, v); return; }
        if (mapper == 47) { m47_port_write(v); return; }
        /* disabled, or enabled but write-protected -> the write is dropped */
        if (mapper == 4 &&
            (!(mmc3_ram_protect & 0x80) || (mmc3_ram_protect & 0x40))) return;
        prgram[a & 0x1FFF] = v;
        return;
    }
    mapper_write(a, v);
}

/* ------------------------------------------------------------------ */
/* cpu core                                                            */
/* ------------------------------------------------------------------ */

static void cpu_tick(void)
{
    cpu_cycle++;
    ppu_tick(); ppu_tick(); ppu_tick();
    apu_tick();
}

static uint8_t rd(uint16_t a) { cpu_tick(); return bus_read(a); }
static void    wr(uint16_t a, uint8_t v) { cpu_tick(); bus_write(a, v); }

static void oam_dma(uint8_t page)
{
    cpu_tick();                       /* the dummy cycle */
    if (cpu_cycle & 1) cpu_tick();    /* alignment cycle */
    for (int i = 0; i < 256; i++) {
        uint8_t d = rd((uint16_t)((page << 8) | i));
        cpu_tick();
        oam[(uint8_t)(oamaddr + i)] = d;
    }
}

static void push(uint8_t v) { wr((uint16_t)(0x100 | SP), v); SP--; }
static uint8_t pop(void) { SP++; return rd((uint16_t)(0x100 | SP)); }

static void setZN(uint8_t v) { P = (uint8_t)((P & ~(FZ | FN)) | (v ? 0 : FZ) | (v & 0x80)); }

static void do_interrupt(uint16_t vec, int brk)
{
    rd(PC); rd(PC);
    push((uint8_t)(PC >> 8));
    push((uint8_t)(PC & 0xFF));
    push((uint8_t)((P | FU) | (brk ? FB : 0)));
    P |= FI;
    uint8_t lo = rd(vec), hi = rd((uint16_t)(vec + 1));
    PC = (uint16_t)(lo | (hi << 8));
}

static int irq_line(void)
{
    return mmc3_irq_pending || apu_frame_irq || apu_dmc_irq;
}

/* addressing helpers */
static uint16_t am_zp(void)  { return rd(PC++); }
static uint16_t am_zpx(void) { uint8_t b = (uint8_t)rd(PC++); rd(b); return (uint8_t)(b + X); }
static uint16_t am_zpy(void) { uint8_t b = (uint8_t)rd(PC++); rd(b); return (uint8_t)(b + Y); }
static uint16_t am_abs(void) { uint8_t lo = rd(PC++); uint8_t hi = rd(PC++); return (uint16_t)(lo | (hi << 8)); }
static uint16_t am_abi(uint8_t idx, int always)
{
    uint8_t lo = rd(PC++), hi = rd(PC++);
    uint16_t base = (uint16_t)(lo | (hi << 8));
    uint16_t a = (uint16_t)(base + idx);
    if (always || ((base & 0xFF00) != (a & 0xFF00)))
        rd((uint16_t)((base & 0xFF00) | (a & 0x00FF)));
    return a;
}
static uint16_t am_izx(void)
{
    uint8_t t = (uint8_t)rd(PC++);
    rd(t);
    t = (uint8_t)(t + X);
    uint8_t lo = rd(t), hi = rd((uint8_t)(t + 1));
    return (uint16_t)(lo | (hi << 8));
}
static uint16_t am_izy(int always)
{
    uint8_t t = (uint8_t)rd(PC++);
    uint8_t lo = rd(t), hi = rd((uint8_t)(t + 1));
    uint16_t base = (uint16_t)(lo | (hi << 8));
    uint16_t a = (uint16_t)(base + Y);
    if (always || ((base & 0xFF00) != (a & 0xFF00)))
        rd((uint16_t)((base & 0xFF00) | (a & 0x00FF)));
    return a;
}

static void op_adc(uint8_t m)
{
    unsigned s = A + m + (P & FC);
    uint8_t r = (uint8_t)s;
    P = (uint8_t)(P & ~(FC | FV));
    if (s > 0xFF) P |= FC;
    if (~(A ^ m) & (A ^ r) & 0x80) P |= FV;
    A = r; setZN(A);
}
static void op_sbc(uint8_t m) { op_adc((uint8_t)~m); }
static void op_cmp(uint8_t reg, uint8_t m)
{
    unsigned d = reg - m;
    P = (uint8_t)(P & ~FC);
    if (reg >= m) P |= FC;
    setZN((uint8_t)d);
}
static uint8_t op_asl(uint8_t m) { P = (uint8_t)((P & ~FC) | ((m >> 7) & 1)); m = (uint8_t)(m << 1); setZN(m); return m; }
static uint8_t op_lsr(uint8_t m) { P = (uint8_t)((P & ~FC) | (m & 1)); m = (uint8_t)(m >> 1); setZN(m); return m; }
static uint8_t op_rol(uint8_t m) { uint8_t c = P & FC; P = (uint8_t)((P & ~FC) | ((m >> 7) & 1)); m = (uint8_t)((m << 1) | c); setZN(m); return m; }
static uint8_t op_ror(uint8_t m) { uint8_t c = (uint8_t)((P & FC) << 7); P = (uint8_t)((P & ~FC) | (m & 1)); m = (uint8_t)((m >> 1) | c); setZN(m); return m; }

static void branch(int take)
{
    int8_t off = (int8_t)rd(PC++);
    if (take) {
        rd(PC);
        uint16_t np = (uint16_t)(PC + off);
        if ((np & 0xFF00) != (PC & 0xFF00)) rd((uint16_t)((PC & 0xFF00) | (np & 0x00FF)));
        PC = np;
    }
}

/* read-modify-write helper */
#define RMW(addrexpr, body) do { \
    uint16_t _a = (addrexpr); uint8_t m = rd(_a); wr(_a, m); body; wr(_a, m); } while (0)

/* ------------------------------------------------------------------ */
/* disassembly tables                                                  */
/* ------------------------------------------------------------------ */

enum { M_IMP, M_ACC, M_IMM, M_ZP, M_ZPX, M_ZPY, M_IZX, M_IZY,
       M_ABS, M_ABX, M_ABY, M_IND, M_REL };
static const uint8_t mode_len[13] = {1,1,2,2,2,2,2,2,3,3,3,3,2};

typedef struct { const char *m; uint8_t mode; } OpInfo;
static const OpInfo optab[256] = {
/*00*/ {"BRK",M_IMM},{"ORA",M_IZX},{"KIL",M_IMP},{"SLO",M_IZX},{"NOP",M_ZP },{"ORA",M_ZP },{"ASL",M_ZP },{"SLO",M_ZP },
       {"PHP",M_IMP},{"ORA",M_IMM},{"ASL",M_ACC},{"ANC",M_IMM},{"NOP",M_ABS},{"ORA",M_ABS},{"ASL",M_ABS},{"SLO",M_ABS},
/*10*/ {"BPL",M_REL},{"ORA",M_IZY},{"KIL",M_IMP},{"SLO",M_IZY},{"NOP",M_ZPX},{"ORA",M_ZPX},{"ASL",M_ZPX},{"SLO",M_ZPX},
       {"CLC",M_IMP},{"ORA",M_ABY},{"NOP",M_IMP},{"SLO",M_ABY},{"NOP",M_ABX},{"ORA",M_ABX},{"ASL",M_ABX},{"SLO",M_ABX},
/*20*/ {"JSR",M_ABS},{"AND",M_IZX},{"KIL",M_IMP},{"RLA",M_IZX},{"BIT",M_ZP },{"AND",M_ZP },{"ROL",M_ZP },{"RLA",M_ZP },
       {"PLP",M_IMP},{"AND",M_IMM},{"ROL",M_ACC},{"ANC",M_IMM},{"BIT",M_ABS},{"AND",M_ABS},{"ROL",M_ABS},{"RLA",M_ABS},
/*30*/ {"BMI",M_REL},{"AND",M_IZY},{"KIL",M_IMP},{"RLA",M_IZY},{"NOP",M_ZPX},{"AND",M_ZPX},{"ROL",M_ZPX},{"RLA",M_ZPX},
       {"SEC",M_IMP},{"AND",M_ABY},{"NOP",M_IMP},{"RLA",M_ABY},{"NOP",M_ABX},{"AND",M_ABX},{"ROL",M_ABX},{"RLA",M_ABX},
/*40*/ {"RTI",M_IMP},{"EOR",M_IZX},{"KIL",M_IMP},{"SRE",M_IZX},{"NOP",M_ZP },{"EOR",M_ZP },{"LSR",M_ZP },{"SRE",M_ZP },
       {"PHA",M_IMP},{"EOR",M_IMM},{"LSR",M_ACC},{"ALR",M_IMM},{"JMP",M_ABS},{"EOR",M_ABS},{"LSR",M_ABS},{"SRE",M_ABS},
/*50*/ {"BVC",M_REL},{"EOR",M_IZY},{"KIL",M_IMP},{"SRE",M_IZY},{"NOP",M_ZPX},{"EOR",M_ZPX},{"LSR",M_ZPX},{"SRE",M_ZPX},
       {"CLI",M_IMP},{"EOR",M_ABY},{"NOP",M_IMP},{"SRE",M_ABY},{"NOP",M_ABX},{"EOR",M_ABX},{"LSR",M_ABX},{"SRE",M_ABX},
/*60*/ {"RTS",M_IMP},{"ADC",M_IZX},{"KIL",M_IMP},{"RRA",M_IZX},{"NOP",M_ZP },{"ADC",M_ZP },{"ROR",M_ZP },{"RRA",M_ZP },
       {"PLA",M_IMP},{"ADC",M_IMM},{"ROR",M_ACC},{"ARR",M_IMM},{"JMP",M_IND},{"ADC",M_ABS},{"ROR",M_ABS},{"RRA",M_ABS},
/*70*/ {"BVS",M_REL},{"ADC",M_IZY},{"KIL",M_IMP},{"RRA",M_IZY},{"NOP",M_ZPX},{"ADC",M_ZPX},{"ROR",M_ZPX},{"RRA",M_ZPX},
       {"SEI",M_IMP},{"ADC",M_ABY},{"NOP",M_IMP},{"RRA",M_ABY},{"NOP",M_ABX},{"ADC",M_ABX},{"ROR",M_ABX},{"RRA",M_ABX},
/*80*/ {"NOP",M_IMM},{"STA",M_IZX},{"NOP",M_IMM},{"SAX",M_IZX},{"STY",M_ZP },{"STA",M_ZP },{"STX",M_ZP },{"SAX",M_ZP },
       {"DEY",M_IMP},{"NOP",M_IMM},{"TXA",M_IMP},{"XAA",M_IMM},{"STY",M_ABS},{"STA",M_ABS},{"STX",M_ABS},{"SAX",M_ABS},
/*90*/ {"BCC",M_REL},{"STA",M_IZY},{"KIL",M_IMP},{"AHX",M_IZY},{"STY",M_ZPX},{"STA",M_ZPX},{"STX",M_ZPY},{"SAX",M_ZPY},
       {"TYA",M_IMP},{"STA",M_ABY},{"TXS",M_IMP},{"TAS",M_ABY},{"SHY",M_ABX},{"STA",M_ABX},{"SHX",M_ABY},{"AHX",M_ABY},
/*A0*/ {"LDY",M_IMM},{"LDA",M_IZX},{"LDX",M_IMM},{"LAX",M_IZX},{"LDY",M_ZP },{"LDA",M_ZP },{"LDX",M_ZP },{"LAX",M_ZP },
       {"TAY",M_IMP},{"LDA",M_IMM},{"TAX",M_IMP},{"LAX",M_IMM},{"LDY",M_ABS},{"LDA",M_ABS},{"LDX",M_ABS},{"LAX",M_ABS},
/*B0*/ {"BCS",M_REL},{"LDA",M_IZY},{"KIL",M_IMP},{"LAX",M_IZY},{"LDY",M_ZPX},{"LDA",M_ZPX},{"LDX",M_ZPY},{"LAX",M_ZPY},
       {"CLV",M_IMP},{"LDA",M_ABY},{"TSX",M_IMP},{"LAS",M_ABY},{"LDY",M_ABX},{"LDA",M_ABX},{"LDX",M_ABY},{"LAX",M_ABY},
/*C0*/ {"CPY",M_IMM},{"CMP",M_IZX},{"NOP",M_IMM},{"DCP",M_IZX},{"CPY",M_ZP },{"CMP",M_ZP },{"DEC",M_ZP },{"DCP",M_ZP },
       {"INY",M_IMP},{"CMP",M_IMM},{"DEX",M_IMP},{"AXS",M_IMM},{"CPY",M_ABS},{"CMP",M_ABS},{"DEC",M_ABS},{"DCP",M_ABS},
/*D0*/ {"BNE",M_REL},{"CMP",M_IZY},{"KIL",M_IMP},{"DCP",M_IZY},{"NOP",M_ZPX},{"CMP",M_ZPX},{"DEC",M_ZPX},{"DCP",M_ZPX},
       {"CLD",M_IMP},{"CMP",M_ABY},{"NOP",M_IMP},{"DCP",M_ABY},{"NOP",M_ABX},{"CMP",M_ABX},{"DEC",M_ABX},{"DCP",M_ABX},
/*E0*/ {"CPX",M_IMM},{"SBC",M_IZX},{"NOP",M_IMM},{"ISC",M_IZX},{"CPX",M_ZP },{"SBC",M_ZP },{"INC",M_ZP },{"ISC",M_ZP },
       {"INX",M_IMP},{"SBC",M_IMM},{"NOP",M_IMP},{"SBC",M_IMM},{"CPX",M_ABS},{"SBC",M_ABS},{"INC",M_ABS},{"ISC",M_ABS},
/*F0*/ {"BEQ",M_REL},{"SBC",M_IZY},{"KIL",M_IMP},{"ISC",M_IZY},{"NOP",M_ZPX},{"SBC",M_ZPX},{"INC",M_ZPX},{"ISC",M_ZPX},
       {"SED",M_IMP},{"SBC",M_ABY},{"NOP",M_IMP},{"ISC",M_ABY},{"NOP",M_ABX},{"SBC",M_ABX},{"INC",M_ABX},{"ISC",M_ABX},
};

/* side-effect free read for tracing / coverage */
static uint8_t dbg_read(uint16_t a)
{
    if (a < 0x2000) return ram[a & 0x7FF];
    if (a < 0x4020) return 0;
    if (a < 0x6000) return 0;
    if (a < 0x8000) return prgram[a & 0x1FFF];
    return prg[prg_map[(a >> 13) & 3] + (a & 0x1FFF)];
}

static int phys_prg_off(uint16_t a)
{
    if (a < 0x8000) return -1;
    return prg_map[(a >> 13) & 3] + (a & 0x1FFF);
}
static int prg_bank_at(uint16_t a)
{
    if (a < 0x8000) return -1;
    return prg_map[(a >> 13) & 3] / 0x2000;
}

static void cov_mark(uint16_t pc, int len)
{
    if (!cov_bits) return;
    for (int i = 0; i < len; i++) {
        int off = phys_prg_off((uint16_t)(pc + i));
        if (off >= 0 && off < prg_size) cov_bits[off >> 3] |= (uint8_t)(1 << (off & 7));
    }
}

static void watch_log(uint16_t a, uint8_t v)
{
    if (!trace_fp) return;
    fprintf(trace_fp, "WATCH %ld,%04X,%d,%04X,%02X\n", cur_frame, PC, prg_bank_at(PC), a, v);
}

static int trace_active(void)
{
    if (!trace_fp) return 0;
    if (opt_tracefrom >= 0 && cur_frame < opt_tracefrom) return 0;
    if (opt_traceto >= 0 && cur_frame > opt_traceto) return 0;
    if (opt_tracepc_lo >= 0 && (PC < opt_tracepc_lo || PC > opt_tracepc_hi)) return 0;
    return 1;
}

static void emit_trace(void)
{
    uint8_t op = dbg_read(PC);
    const OpInfo *oi = &optab[op];
    int len = mode_len[oi->mode];
    uint8_t b1 = dbg_read((uint16_t)(PC + 1)), b2 = dbg_read((uint16_t)(PC + 2));
    char bytes[16], operand[32];
    if (len == 1) snprintf(bytes, sizeof bytes, "%02X      ", op);
    else if (len == 2) snprintf(bytes, sizeof bytes, "%02X %02X   ", op, b1);
    else snprintf(bytes, sizeof bytes, "%02X %02X %02X", op, b1, b2);

    uint16_t w = (uint16_t)(b1 | (b2 << 8));
    switch (oi->mode) {
    case M_IMP: operand[0] = 0; break;
    case M_ACC: snprintf(operand, sizeof operand, "A"); break;
    case M_IMM: snprintf(operand, sizeof operand, "#$%02X", b1); break;
    case M_ZP:  snprintf(operand, sizeof operand, "$%02X", b1); break;
    case M_ZPX: snprintf(operand, sizeof operand, "$%02X,X", b1); break;
    case M_ZPY: snprintf(operand, sizeof operand, "$%02X,Y", b1); break;
    case M_IZX: snprintf(operand, sizeof operand, "($%02X,X)", b1); break;
    case M_IZY: snprintf(operand, sizeof operand, "($%02X),Y", b1); break;
    case M_ABS: snprintf(operand, sizeof operand, "$%04X", w); break;
    case M_ABX: snprintf(operand, sizeof operand, "$%04X,X", w); break;
    case M_ABY: snprintf(operand, sizeof operand, "$%04X,Y", w); break;
    case M_IND: snprintf(operand, sizeof operand, "($%04X)", w); break;
    case M_REL: snprintf(operand, sizeof operand, "$%04X",
                         (uint16_t)(PC + 2 + (int8_t)b1)); break;
    default: operand[0] = 0; break;
    }
    char text[48];
    if (operand[0]) snprintf(text, sizeof text, "%s %s", oi->m, operand);
    else snprintf(text, sizeof text, "%s", oi->m);

    fprintf(trace_fp, "F%ld %d:%04X %s %-12s  A=%02X X=%02X Y=%02X P=%02X SP=%02X\n",
            cur_frame, prg_bank_at(PC), PC, bytes, text, A, X, Y, P, SP);
}

/* ------------------------------------------------------------------ */
/* instruction execution                                               */
/* ------------------------------------------------------------------ */

static void cpu_step(void)
{
    if (nmi_pending) {
        nmi_pending = 0;
        do_interrupt(0xFFFA, 0);
        pending_poll_I = P & FI;
        return;
    }
    if (irq_line() && !pending_poll_I) {
        do_interrupt(0xFFFE, 0);
        pending_poll_I = P & FI;
        return;
    }
    uint8_t I0 = P & FI;

    if (trace_fp && n_samples) {
        for (int k = 0; k < n_samples; k++) {
            if (samples[k].pc != PC) continue;
            uint8_t v;
            char what[8];
            switch (samples[k].reg) {
            case 1: v = A; strcpy(what, "A"); break;
            case 2: v = X; strcpy(what, "X"); break;
            case 3: v = Y; strcpy(what, "Y"); break;
            case 4: v = P; strcpy(what, "P"); break;
            default:
                v = dbg_read(samples[k].addr);
                sprintf(what, "%04X", samples[k].addr);
            }
            fprintf(trace_fp, "SAMPLE %ld,%04X,%d,%s,%02X\n", cur_frame,
                    PC, prg_bank_at(PC), what, v);
        }
    }
    if (cov_bits || trace_fp) {
        uint8_t op0 = dbg_read(PC);
        cov_mark(PC, mode_len[optab[op0].mode]);
        if (trace_active()) emit_trace();
    }

    uint8_t op = rd(PC++);
    uint16_t a;
    uint8_t m;

    switch (op) {
    /* ---- loads ---- */
    case 0xA9: A = rd(PC++); setZN(A); break;
    case 0xA5: A = rd(am_zp()); setZN(A); break;
    case 0xB5: A = rd(am_zpx()); setZN(A); break;
    case 0xAD: A = rd(am_abs()); setZN(A); break;
    case 0xBD: A = rd(am_abi(X, 0)); setZN(A); break;
    case 0xB9: A = rd(am_abi(Y, 0)); setZN(A); break;
    case 0xA1: A = rd(am_izx()); setZN(A); break;
    case 0xB1: A = rd(am_izy(0)); setZN(A); break;

    case 0xA2: X = rd(PC++); setZN(X); break;
    case 0xA6: X = rd(am_zp()); setZN(X); break;
    case 0xB6: X = rd(am_zpy()); setZN(X); break;
    case 0xAE: X = rd(am_abs()); setZN(X); break;
    case 0xBE: X = rd(am_abi(Y, 0)); setZN(X); break;

    case 0xA0: Y = rd(PC++); setZN(Y); break;
    case 0xA4: Y = rd(am_zp()); setZN(Y); break;
    case 0xB4: Y = rd(am_zpx()); setZN(Y); break;
    case 0xAC: Y = rd(am_abs()); setZN(Y); break;
    case 0xBC: Y = rd(am_abi(X, 0)); setZN(Y); break;

    /* ---- stores ---- */
    case 0x85: wr(am_zp(), A); break;
    case 0x95: wr(am_zpx(), A); break;
    case 0x8D: wr(am_abs(), A); break;
    case 0x9D: wr(am_abi(X, 1), A); break;
    case 0x99: wr(am_abi(Y, 1), A); break;
    case 0x81: wr(am_izx(), A); break;
    case 0x91: wr(am_izy(1), A); break;

    case 0x86: wr(am_zp(), X); break;
    case 0x96: wr(am_zpy(), X); break;
    case 0x8E: wr(am_abs(), X); break;

    case 0x84: wr(am_zp(), Y); break;
    case 0x94: wr(am_zpx(), Y); break;
    case 0x8C: wr(am_abs(), Y); break;

    /* ---- transfers ---- */
    case 0xAA: rd(PC); X = A; setZN(X); break;
    case 0xA8: rd(PC); Y = A; setZN(Y); break;
    case 0xBA: rd(PC); X = SP; setZN(X); break;
    case 0x8A: rd(PC); A = X; setZN(A); break;
    case 0x9A: rd(PC); SP = X; break;
    case 0x98: rd(PC); A = Y; setZN(A); break;

    /* ---- stack ---- */
    case 0x48: rd(PC); push(A); break;
    case 0x08: rd(PC); push((uint8_t)(P | FB | FU)); break;
    case 0x68: rd(PC); rd((uint16_t)(0x100 | SP)); A = pop(); setZN(A); break;
    case 0x28: rd(PC); rd((uint16_t)(0x100 | SP));
               P = (uint8_t)((pop() & ~FB) | FU); break;

    /* ---- logic ---- */
    case 0x29: A &= rd(PC++); setZN(A); break;
    case 0x25: A &= rd(am_zp()); setZN(A); break;
    case 0x35: A &= rd(am_zpx()); setZN(A); break;
    case 0x2D: A &= rd(am_abs()); setZN(A); break;
    case 0x3D: A &= rd(am_abi(X, 0)); setZN(A); break;
    case 0x39: A &= rd(am_abi(Y, 0)); setZN(A); break;
    case 0x21: A &= rd(am_izx()); setZN(A); break;
    case 0x31: A &= rd(am_izy(0)); setZN(A); break;

    case 0x09: A |= rd(PC++); setZN(A); break;
    case 0x05: A |= rd(am_zp()); setZN(A); break;
    case 0x15: A |= rd(am_zpx()); setZN(A); break;
    case 0x0D: A |= rd(am_abs()); setZN(A); break;
    case 0x1D: A |= rd(am_abi(X, 0)); setZN(A); break;
    case 0x19: A |= rd(am_abi(Y, 0)); setZN(A); break;
    case 0x01: A |= rd(am_izx()); setZN(A); break;
    case 0x11: A |= rd(am_izy(0)); setZN(A); break;

    case 0x49: A ^= rd(PC++); setZN(A); break;
    case 0x45: A ^= rd(am_zp()); setZN(A); break;
    case 0x55: A ^= rd(am_zpx()); setZN(A); break;
    case 0x4D: A ^= rd(am_abs()); setZN(A); break;
    case 0x5D: A ^= rd(am_abi(X, 0)); setZN(A); break;
    case 0x59: A ^= rd(am_abi(Y, 0)); setZN(A); break;
    case 0x41: A ^= rd(am_izx()); setZN(A); break;
    case 0x51: A ^= rd(am_izy(0)); setZN(A); break;

    case 0x24: m = rd(am_zp());
               P = (uint8_t)((P & ~(FZ | FV | FN)) | ((A & m) ? 0 : FZ) | (m & 0xC0));
               break;
    case 0x2C: m = rd(am_abs());
               P = (uint8_t)((P & ~(FZ | FV | FN)) | ((A & m) ? 0 : FZ) | (m & 0xC0));
               break;

    /* ---- arithmetic ---- */
    case 0x69: op_adc(rd(PC++)); break;
    case 0x65: op_adc(rd(am_zp())); break;
    case 0x75: op_adc(rd(am_zpx())); break;
    case 0x6D: op_adc(rd(am_abs())); break;
    case 0x7D: op_adc(rd(am_abi(X, 0))); break;
    case 0x79: op_adc(rd(am_abi(Y, 0))); break;
    case 0x61: op_adc(rd(am_izx())); break;
    case 0x71: op_adc(rd(am_izy(0))); break;

    case 0xE9: case 0xEB: op_sbc(rd(PC++)); break;
    case 0xE5: op_sbc(rd(am_zp())); break;
    case 0xF5: op_sbc(rd(am_zpx())); break;
    case 0xED: op_sbc(rd(am_abs())); break;
    case 0xFD: op_sbc(rd(am_abi(X, 0))); break;
    case 0xF9: op_sbc(rd(am_abi(Y, 0))); break;
    case 0xE1: op_sbc(rd(am_izx())); break;
    case 0xF1: op_sbc(rd(am_izy(0))); break;

    case 0xC9: op_cmp(A, rd(PC++)); break;
    case 0xC5: op_cmp(A, rd(am_zp())); break;
    case 0xD5: op_cmp(A, rd(am_zpx())); break;
    case 0xCD: op_cmp(A, rd(am_abs())); break;
    case 0xDD: op_cmp(A, rd(am_abi(X, 0))); break;
    case 0xD9: op_cmp(A, rd(am_abi(Y, 0))); break;
    case 0xC1: op_cmp(A, rd(am_izx())); break;
    case 0xD1: op_cmp(A, rd(am_izy(0))); break;

    case 0xE0: op_cmp(X, rd(PC++)); break;
    case 0xE4: op_cmp(X, rd(am_zp())); break;
    case 0xEC: op_cmp(X, rd(am_abs())); break;

    case 0xC0: op_cmp(Y, rd(PC++)); break;
    case 0xC4: op_cmp(Y, rd(am_zp())); break;
    case 0xCC: op_cmp(Y, rd(am_abs())); break;

    /* ---- inc/dec ---- */
    case 0xE6: RMW(am_zp(),        { m++; setZN(m); }); break;
    case 0xF6: RMW(am_zpx(),       { m++; setZN(m); }); break;
    case 0xEE: RMW(am_abs(),       { m++; setZN(m); }); break;
    case 0xFE: RMW(am_abi(X, 1),   { m++; setZN(m); }); break;
    case 0xC6: RMW(am_zp(),        { m--; setZN(m); }); break;
    case 0xD6: RMW(am_zpx(),       { m--; setZN(m); }); break;
    case 0xCE: RMW(am_abs(),       { m--; setZN(m); }); break;
    case 0xDE: RMW(am_abi(X, 1),   { m--; setZN(m); }); break;
    case 0xE8: rd(PC); X++; setZN(X); break;
    case 0xC8: rd(PC); Y++; setZN(Y); break;
    case 0xCA: rd(PC); X--; setZN(X); break;
    case 0x88: rd(PC); Y--; setZN(Y); break;

    /* ---- shifts ---- */
    case 0x0A: rd(PC); A = op_asl(A); break;
    case 0x06: RMW(am_zp(),      { m = op_asl(m); }); break;
    case 0x16: RMW(am_zpx(),     { m = op_asl(m); }); break;
    case 0x0E: RMW(am_abs(),     { m = op_asl(m); }); break;
    case 0x1E: RMW(am_abi(X, 1), { m = op_asl(m); }); break;
    case 0x4A: rd(PC); A = op_lsr(A); break;
    case 0x46: RMW(am_zp(),      { m = op_lsr(m); }); break;
    case 0x56: RMW(am_zpx(),     { m = op_lsr(m); }); break;
    case 0x4E: RMW(am_abs(),     { m = op_lsr(m); }); break;
    case 0x5E: RMW(am_abi(X, 1), { m = op_lsr(m); }); break;
    case 0x2A: rd(PC); A = op_rol(A); break;
    case 0x26: RMW(am_zp(),      { m = op_rol(m); }); break;
    case 0x36: RMW(am_zpx(),     { m = op_rol(m); }); break;
    case 0x2E: RMW(am_abs(),     { m = op_rol(m); }); break;
    case 0x3E: RMW(am_abi(X, 1), { m = op_rol(m); }); break;
    case 0x6A: rd(PC); A = op_ror(A); break;
    case 0x66: RMW(am_zp(),      { m = op_ror(m); }); break;
    case 0x76: RMW(am_zpx(),     { m = op_ror(m); }); break;
    case 0x6E: RMW(am_abs(),     { m = op_ror(m); }); break;
    case 0x7E: RMW(am_abi(X, 1), { m = op_ror(m); }); break;

    /* ---- flags ---- */
    case 0x18: rd(PC); P &= (uint8_t)~FC; break;
    case 0x38: rd(PC); P |= FC; break;
    case 0x58: rd(PC); P &= (uint8_t)~FI; break;
    case 0x78: rd(PC); P |= FI; break;
    case 0xB8: rd(PC); P &= (uint8_t)~FV; break;
    case 0xD8: rd(PC); P &= (uint8_t)~FD; break;
    case 0xF8: rd(PC); P |= FD; break;

    /* ---- branches ---- */
    case 0x10: branch(!(P & FN)); break;
    case 0x30: branch(  P & FN);  break;
    case 0x50: branch(!(P & FV)); break;
    case 0x70: branch(  P & FV);  break;
    case 0x90: branch(!(P & FC)); break;
    case 0xB0: branch(  P & FC);  break;
    case 0xD0: branch(!(P & FZ)); break;
    case 0xF0: branch(  P & FZ);  break;

    /* ---- jumps ---- */
    case 0x4C: PC = am_abs(); break;
    case 0x6C: {
        uint16_t p = am_abs();
        uint8_t lo = rd(p);
        uint8_t hi = rd((uint16_t)((p & 0xFF00) | ((p + 1) & 0x00FF)));
        PC = (uint16_t)(lo | (hi << 8));
        break;
    }
    case 0x20: {
        uint8_t lo = rd(PC++);
        rd((uint16_t)(0x100 | SP));
        push((uint8_t)(PC >> 8));
        push((uint8_t)(PC & 0xFF));
        uint8_t hi = rd(PC);
        PC = (uint16_t)(lo | (hi << 8));
        break;
    }
    case 0x60: {
        rd(PC); rd((uint16_t)(0x100 | SP));
        uint8_t lo = pop(), hi = pop();
        PC = (uint16_t)(lo | (hi << 8));
        rd(PC); PC++;
        break;
    }
    case 0x40: {
        rd(PC); rd((uint16_t)(0x100 | SP));
        P = (uint8_t)((pop() & ~FB) | FU);
        uint8_t lo = pop(), hi = pop();
        PC = (uint16_t)(lo | (hi << 8));
        break;
    }
    case 0x00: {   /* BRK */
        rd(PC++);
        push((uint8_t)(PC >> 8));
        push((uint8_t)(PC & 0xFF));
        push((uint8_t)(P | FB | FU));
        P |= FI;
        uint8_t lo = rd(0xFFFE), hi = rd(0xFFFF);
        PC = (uint16_t)(lo | (hi << 8));
        break;
    }

    /* ---- NOPs ---- */
    case 0xEA: case 0x1A: case 0x3A: case 0x5A:
    case 0x7A: case 0xDA: case 0xFA:
        rd(PC); break;
    case 0x80: case 0x82: case 0x89: case 0xC2: case 0xE2:
        rd(PC++); break;
    case 0x04: case 0x44: case 0x64:
        rd(am_zp()); break;
    case 0x14: case 0x34: case 0x54: case 0x74: case 0xD4: case 0xF4:
        rd(am_zpx()); break;
    case 0x0C:
        rd(am_abs()); break;
    case 0x1C: case 0x3C: case 0x5C: case 0x7C: case 0xDC: case 0xFC:
        rd(am_abi(X, 0)); break;

    /* ---- unofficial ---- */
    case 0xA7: A = X = rd(am_zp()); setZN(A); break;
    case 0xB7: A = X = rd(am_zpy()); setZN(A); break;
    case 0xAF: A = X = rd(am_abs()); setZN(A); break;
    case 0xBF: A = X = rd(am_abi(Y, 0)); setZN(A); break;
    case 0xA3: A = X = rd(am_izx()); setZN(A); break;
    case 0xB3: A = X = rd(am_izy(0)); setZN(A); break;
    case 0xAB: A = X = rd(PC++); setZN(A); break;

    case 0x87: wr(am_zp(), (uint8_t)(A & X)); break;
    case 0x97: wr(am_zpy(), (uint8_t)(A & X)); break;
    case 0x8F: wr(am_abs(), (uint8_t)(A & X)); break;
    case 0x83: wr(am_izx(), (uint8_t)(A & X)); break;

    case 0xC7: RMW(am_zp(),      { m--; op_cmp(A, m); }); break;
    case 0xD7: RMW(am_zpx(),     { m--; op_cmp(A, m); }); break;
    case 0xCF: RMW(am_abs(),     { m--; op_cmp(A, m); }); break;
    case 0xDF: RMW(am_abi(X, 1), { m--; op_cmp(A, m); }); break;
    case 0xDB: RMW(am_abi(Y, 1), { m--; op_cmp(A, m); }); break;
    case 0xC3: RMW(am_izx(),     { m--; op_cmp(A, m); }); break;
    case 0xD3: RMW(am_izy(1),    { m--; op_cmp(A, m); }); break;

    case 0xE7: RMW(am_zp(),      { m++; op_sbc(m); }); break;
    case 0xF7: RMW(am_zpx(),     { m++; op_sbc(m); }); break;
    case 0xEF: RMW(am_abs(),     { m++; op_sbc(m); }); break;
    case 0xFF: RMW(am_abi(X, 1), { m++; op_sbc(m); }); break;
    case 0xFB: RMW(am_abi(Y, 1), { m++; op_sbc(m); }); break;
    case 0xE3: RMW(am_izx(),     { m++; op_sbc(m); }); break;
    case 0xF3: RMW(am_izy(1),    { m++; op_sbc(m); }); break;

    case 0x07: RMW(am_zp(),      { m = op_asl(m); A |= m; setZN(A); }); break;
    case 0x17: RMW(am_zpx(),     { m = op_asl(m); A |= m; setZN(A); }); break;
    case 0x0F: RMW(am_abs(),     { m = op_asl(m); A |= m; setZN(A); }); break;
    case 0x1F: RMW(am_abi(X, 1), { m = op_asl(m); A |= m; setZN(A); }); break;
    case 0x1B: RMW(am_abi(Y, 1), { m = op_asl(m); A |= m; setZN(A); }); break;
    case 0x03: RMW(am_izx(),     { m = op_asl(m); A |= m; setZN(A); }); break;
    case 0x13: RMW(am_izy(1),    { m = op_asl(m); A |= m; setZN(A); }); break;

    case 0x27: RMW(am_zp(),      { m = op_rol(m); A &= m; setZN(A); }); break;
    case 0x37: RMW(am_zpx(),     { m = op_rol(m); A &= m; setZN(A); }); break;
    case 0x2F: RMW(am_abs(),     { m = op_rol(m); A &= m; setZN(A); }); break;
    case 0x3F: RMW(am_abi(X, 1), { m = op_rol(m); A &= m; setZN(A); }); break;
    case 0x3B: RMW(am_abi(Y, 1), { m = op_rol(m); A &= m; setZN(A); }); break;
    case 0x23: RMW(am_izx(),     { m = op_rol(m); A &= m; setZN(A); }); break;
    case 0x33: RMW(am_izy(1),    { m = op_rol(m); A &= m; setZN(A); }); break;

    case 0x47: RMW(am_zp(),      { m = op_lsr(m); A ^= m; setZN(A); }); break;
    case 0x57: RMW(am_zpx(),     { m = op_lsr(m); A ^= m; setZN(A); }); break;
    case 0x4F: RMW(am_abs(),     { m = op_lsr(m); A ^= m; setZN(A); }); break;
    case 0x5F: RMW(am_abi(X, 1), { m = op_lsr(m); A ^= m; setZN(A); }); break;
    case 0x5B: RMW(am_abi(Y, 1), { m = op_lsr(m); A ^= m; setZN(A); }); break;
    case 0x43: RMW(am_izx(),     { m = op_lsr(m); A ^= m; setZN(A); }); break;
    case 0x53: RMW(am_izy(1),    { m = op_lsr(m); A ^= m; setZN(A); }); break;

    case 0x67: RMW(am_zp(),      { m = op_ror(m); op_adc(m); }); break;
    case 0x77: RMW(am_zpx(),     { m = op_ror(m); op_adc(m); }); break;
    case 0x6F: RMW(am_abs(),     { m = op_ror(m); op_adc(m); }); break;
    case 0x7F: RMW(am_abi(X, 1), { m = op_ror(m); op_adc(m); }); break;
    case 0x7B: RMW(am_abi(Y, 1), { m = op_ror(m); op_adc(m); }); break;
    case 0x63: RMW(am_izx(),     { m = op_ror(m); op_adc(m); }); break;
    case 0x73: RMW(am_izy(1),    { m = op_ror(m); op_adc(m); }); break;

    case 0x0B: case 0x2B:  /* ANC */
        A &= rd(PC++); setZN(A);
        P = (uint8_t)((P & ~FC) | ((A >> 7) & 1));
        break;
    case 0x4B:             /* ALR */
        A &= rd(PC++); A = op_lsr(A);
        break;
    case 0x6B: {           /* ARR */
        A &= rd(PC++);
        uint8_t c = (uint8_t)((P & FC) << 7);
        A = (uint8_t)((A >> 1) | c);
        setZN(A);
        P = (uint8_t)(P & ~(FC | FV));
        if (A & 0x40) P |= FC;
        if (((A >> 6) ^ (A >> 5)) & 1) P |= FV;
        break;
    }
    case 0xCB: {           /* AXS / SBX */
        uint8_t v = rd(PC++);
        unsigned t = (unsigned)(A & X) - v;
        P = (uint8_t)(P & ~FC);
        if ((A & X) >= v) P |= FC;
        X = (uint8_t)t; setZN(X);
        break;
    }
    case 0x8B:             /* XAA (unstable) */
        A = (uint8_t)(X & rd(PC++)); setZN(A);
        break;
    case 0xBB: {           /* LAS (unstable) */
        m = rd(am_abi(Y, 0));
        A = X = SP = (uint8_t)(m & SP); setZN(A);
        break;
    }
    case 0x9B:             /* TAS (unstable) */
        a = am_abi(Y, 1);
        SP = (uint8_t)(A & X);
        wr(a, (uint8_t)(SP & ((a >> 8) + 1)));
        break;
    case 0x9E:             /* SHX (unstable) */
        a = am_abi(Y, 1);
        wr(a, (uint8_t)(X & ((a >> 8) + 1)));
        break;
    case 0x9C:             /* SHY (unstable) */
        a = am_abi(X, 1);
        wr(a, (uint8_t)(Y & ((a >> 8) + 1)));
        break;
    case 0x93:             /* AHX (unstable) */
        a = am_izy(1);
        wr(a, (uint8_t)(A & X & ((a >> 8) + 1)));
        break;
    case 0x9F:
        a = am_abi(Y, 1);
        wr(a, (uint8_t)(A & X & ((a >> 8) + 1)));
        break;

    default:               /* KIL */
        rd(PC);
        cpu_jammed++;
        break;
    }

    pending_poll_I = I0;
}

/* ------------------------------------------------------------------ */
/* png output                                                          */
/* ------------------------------------------------------------------ */

static const uint32_t nes_pal[64] = {
    0x666666,0x002A88,0x1412A7,0x3B00A4,0x5C007E,0x6E0040,0x6C0600,0x561D00,
    0x333500,0x0B4800,0x005200,0x004F08,0x00404D,0x000000,0x000000,0x000000,
    0xADADAD,0x155FD9,0x4240FF,0x7527FE,0xA01ACC,0xB71E7B,0xB53120,0x994E00,
    0x6B6D00,0x388700,0x0C9300,0x008F32,0x007C8D,0x000000,0x000000,0x000000,
    0xFFFEFF,0x64B0FF,0x9290FF,0xC676FF,0xF36AFF,0xFE6ECC,0xFE8170,0xEA9E22,
    0xBCBE00,0x88D800,0x5CE430,0x45E082,0x48CDDE,0x4F4F4F,0x000000,0x000000,
    0xFFFEFF,0xC0DFFF,0xD3D2FF,0xE8C8FF,0xFBC2FF,0xFEC4EA,0xFECCC5,0xF7D8A5,
    0xE4E594,0xCFEF96,0xBDF4AB,0xB3F3CC,0xB5EBF2,0xB8B8B8,0x000000,0x000000
};

static void put_be32(uint8_t *p, uint32_t v)
{
    p[0] = (uint8_t)(v >> 24); p[1] = (uint8_t)(v >> 16);
    p[2] = (uint8_t)(v >> 8);  p[3] = (uint8_t)v;
}

static void png_chunk(FILE *f, const char *type, const uint8_t *data, uint32_t len)
{
    uint8_t hdr[4];
    put_be32(hdr, len);
    fwrite(hdr, 1, 4, f);
    fwrite(type, 1, 4, f);
    if (len) fwrite(data, 1, len, f);
    uLong c = crc32(0L, Z_NULL, 0);
    c = crc32(c, (const Bytef *)type, 4);
    if (len) c = crc32(c, data, len);
    uint8_t cb[4]; put_be32(cb, (uint32_t)c);
    fwrite(cb, 1, 4, f);
}

static int write_png(const char *path)
{
    const int W = 256, H = 240;
    size_t rawlen = (size_t)H * (1 + W * 3);
    uint8_t *raw = malloc(rawlen);
    if (!raw) return -1;
    size_t o = 0;
    for (int y = 0; y < H; y++) {
        raw[o++] = 0;
        for (int x = 0; x < W; x++) {
            uint32_t c = nes_pal[fb[y * W + x] & 0x3F];
            raw[o++] = (uint8_t)(c >> 16);
            raw[o++] = (uint8_t)(c >> 8);
            raw[o++] = (uint8_t)c;
        }
    }
    uLongf clen = compressBound((uLong)rawlen);
    uint8_t *comp = malloc(clen);
    if (!comp) { free(raw); return -1; }
    if (compress2(comp, &clen, raw, (uLong)rawlen, 9) != Z_OK) {
        free(raw); free(comp); return -1;
    }
    FILE *f = fopen(path, "wb");
    if (!f) { free(raw); free(comp); return -1; }
    static const uint8_t sig[8] = {137,'P','N','G','\r','\n',26,'\n'};
    fwrite(sig, 1, 8, f);
    uint8_t ihdr[13];
    put_be32(ihdr, W); put_be32(ihdr + 4, H);
    ihdr[8] = 8; ihdr[9] = 2; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
    png_chunk(f, "IHDR", ihdr, 13);
    png_chunk(f, "IDAT", comp, (uint32_t)clen);
    png_chunk(f, "IEND", NULL, 0);
    fclose(f);
    free(raw); free(comp);
    return 0;
}

/* ------------------------------------------------------------------ */
/* savestates                                                          */
/* ------------------------------------------------------------------ */
/*
 * Format (little-endian host; the file is not portable across endianness):
 *   offset 0   char  magic[8] = "NESEMUST"
 *   offset 8   u32   version   (SS_VERSION)
 *   offset 12  u32   mapper id
 *   offset 16  u32   prg_size
 *   offset 20  u32   chr_size
 *   offset 24  u32   chr_is_ram
 *   offset 28  ...   payload, written by state_io() in a fixed order
 *
 * The payload is emitted and consumed by the same function so save and load
 * can never drift apart.  It carries everything needed to resume
 * bit-identically: CPU regs/PC/cycle counter/interrupt latches, 2 KiB RAM,
 * 8 KiB PRG-RAM, CHR-RAM when present, VRAM, palette, OAM, every PPU
 * register plus v/t/x/w and scanline/dot/odd-frame, the full APU state,
 * controller latches, the live PRG/CHR bank maps, the complete register set
 * of every supported mapper, the frame counter and the framebuffer.
 */
#define SS_MAGIC   "NESEMUST"
#define SS_VERSION 1u

static int ss_err;
static void io_raw(FILE *f, int w, void *p, size_t n)
{
    if (w) { if (fwrite(p, 1, n, f) != n) ss_err = 1; }
    else   { if (fread(p, 1, n, f) != n) ss_err = 1; }
}
#define IO(x)  io_raw(f, w, &(x), sizeof(x))
#define IOA(x) io_raw(f, w,  (x), sizeof(x))

static int state_io(FILE *f, int w)
{
    ss_err = 0;
    /* cpu */
    IO(A); IO(X); IO(Y); IO(SP); IO(P); IO(PC);
    IO(cpu_cycle); IO(pending_poll_I); IO(nmi_pending); IO(nmi_prev);
    IO(bus_last); IO(cpu_jammed);
    /* memories */
    IOA(ram); IOA(prgram); IOA(vram); IOA(pal); IOA(oam);
    if (chr_is_ram) io_raw(f, w, chr, (size_t)chr_size);
    /* ppu */
    IO(ppuctrl); IO(ppumask); IO(ppustatus); IO(oamaddr);
    IO(vreg); IO(treg); IO(fine_x); IO(wtoggle); IO(ppu_buf);
    IO(scanline); IO(dot); IO(odd_frame); IO(frame_done);
    /* apu */
    IOA(apu_len); IOA(apu_halt); IO(apu_enable); IO(apu_mode);
    IO(apu_irq_inhibit); IO(apu_frame_irq); IO(apu_dmc_irq);
    IO(apu_ctr); IO(apu_reset_delay); IOA(apu_regs);
    /* controllers */
    IOA(pad_state); IOA(pad_shift); IO(pad_strobe);
    /* mapper: mirroring + live bank maps + every mapper's registers */
    IO(mirror_mode); IO(four_screen);
    IOA(prg_map); IOA(chr_map);
    IO(mmc3_bank_select); IOA(mmc3_regs); IO(mmc3_ram_protect);
    IO(mmc3_irq_latch); IO(mmc3_irq_counter); IO(mmc3_irq_reload);
    IO(mmc3_irq_enable); IO(mmc3_irq_pending);
    IO(mmc1_shift); IO(mmc1_count); IO(mmc1_ctrl);
    IO(mmc1_chr0); IO(mmc1_chr1); IO(mmc1_prg);
    IO(m2_bank); IO(m3_bank);
    IOA(m45_reg); IO(m45_index); IO(m45_dip); IO(m47_block);
    /* timeline + video */
    IO(cur_frame);
    IOA(fb);
    return ss_err ? -1 : 0;
}
#undef IO
#undef IOA

static int save_state(const char *path)
{
    FILE *f = fopen(path, "wb");
    if (!f) { fprintf(stderr, "savestate: cannot write %s\n", path); return -1; }
    uint32_t hdr[5] = { SS_VERSION, (uint32_t)mapper, (uint32_t)prg_size,
                        (uint32_t)chr_size, (uint32_t)chr_is_ram };
    fwrite(SS_MAGIC, 1, 8, f);
    fwrite(hdr, sizeof(uint32_t), 5, f);
    int r = state_io(f, 1);
    fclose(f);
    if (r) fprintf(stderr, "savestate: write error on %s\n", path);
    return r;
}

static int load_state(const char *path)
{
    FILE *f = fopen(path, "rb");
    if (!f) { fprintf(stderr, "loadstate: cannot open %s\n", path); return -1; }
    char magic[8];
    uint32_t hdr[5];
    if (fread(magic, 1, 8, f) != 8 || memcmp(magic, SS_MAGIC, 8) != 0) {
        fprintf(stderr, "loadstate: %s is not a nesemu savestate\n", path);
        fclose(f); return -1;
    }
    if (fread(hdr, sizeof(uint32_t), 5, f) != 5) {
        fprintf(stderr, "loadstate: %s is truncated\n", path);
        fclose(f); return -1;
    }
    if (hdr[0] != SS_VERSION) {
        fprintf(stderr, "loadstate: version %u, expected %u\n", hdr[0], SS_VERSION);
        fclose(f); return -1;
    }
    if ((int)hdr[1] != mapper || (int)hdr[2] != prg_size ||
        (int)hdr[3] != chr_size || (int)hdr[4] != chr_is_ram) {
        fprintf(stderr, "loadstate: state is for a different cartridge "
                "(mapper %u prg %u chr %u, this ROM is mapper %d prg %d chr %d)\n",
                hdr[1], hdr[2], hdr[3], mapper, prg_size, chr_size);
        fclose(f); return -1;
    }
    int r = state_io(f, 0);
    fclose(f);
    if (r) { fprintf(stderr, "loadstate: truncated payload in %s\n", path); return -1; }
    nmi_prev = (ppuctrl & 0x80) && (ppustatus & 0x80);
    return 0;
}

/* ------------------------------------------------------------------ */
/* poke / freeze                                                       */
/* ------------------------------------------------------------------ */
/* RAM and PRG-RAM are written straight through so no bus side effects or
 * mapper ports are triggered; anything else goes out over the normal CPU
 * bus (so PPU/APU/mapper registers can be poked too) without consuming a
 * cycle and without disturbing the open-bus latch. */
static void poke_write(uint16_t a, uint8_t v)
{
    /* A poke is a write like any other as far as anyone reading the watch log
     * is concerned: leave it out and whoever carries the values forward is
     * left holding what the game last wrote, not what is actually there. */
    if (trace_fp && opt_watch_lo >= 0 && a >= opt_watch_lo && a <= opt_watch_hi)
        fprintf(trace_fp, "WATCH %ld,POKE,-1,%04X,%02X\n", cur_frame, a, v);
    if (a < 0x2000) { ram[a & 0x7FF] = v; return; }
    if (a >= 0x6000 && a < 0x8000) { prgram[a & 0x1FFF] = v; return; }
    uint8_t saved = bus_last;
    bus_write(a, v);
    bus_last = saved;
}

/* ------------------------------------------------------------------ */
/* rom loading                                                         */
/* ------------------------------------------------------------------ */

static int load_rom(const char *path)
{
    FILE *f = fopen(path, "rb");
    if (!f) { fprintf(stderr, "cannot open %s\n", path); return -1; }
    fseek(f, 0, SEEK_END);
    long fsz = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t h[16];
    if (fread(h, 1, 16, f) != 16 || memcmp(h, "NES\x1a", 4) != 0) {
        fprintf(stderr, "not an iNES file\n"); fclose(f); return -1;
    }
    int nes2 = ((h[7] & 0x0C) == 0x08);
    int trainer = (h[6] & 0x04) ? 512 : 0;
    four_screen = (h[6] & 0x08) ? 1 : 0;
    mirror_mode = four_screen ? MIR_4SCR : ((h[6] & 1) ? MIR_VERT : MIR_HORZ);

    if (nes2) {
        mapper = (h[6] >> 4) | (h[7] & 0xF0) | ((h[8] & 0x0F) << 8);
        int pu = h[9] & 0x0F, cu = (h[9] >> 4) & 0x0F;
        if (pu == 0x0F) {
            int mult = (h[4] & 3) * 2 + 1, exp = h[4] >> 2;
            prg_size = mult << exp;
        } else prg_size = ((pu << 8) | h[4]) * 16384;
        if (cu == 0x0F) {
            int mult = (h[5] & 3) * 2 + 1, exp = h[5] >> 2;
            chr_size = mult << exp;
        } else chr_size = ((cu << 8) | h[5]) * 8192;
    } else {
        mapper = (h[6] >> 4) | (h[7] & 0xF0);
        prg_size = h[4] * 16384;
        chr_size = h[5] * 8192;
    }
    if (prg_size <= 0) { fprintf(stderr, "bad PRG size\n"); fclose(f); return -1; }
    if (16 + trainer + prg_size > fsz) {
        fprintf(stderr, "truncated ROM (need %d, have %ld)\n",
                16 + trainer + prg_size, fsz);
        fclose(f); return -1;
    }
    fseek(f, 16 + trainer, SEEK_SET);
    prg = malloc((size_t)prg_size);
    if (fread(prg, 1, (size_t)prg_size, f) != (size_t)prg_size) {
        fprintf(stderr, "short read on PRG\n"); fclose(f); return -1;
    }
    if (chr_size == 0) {
        chr_is_ram = 1; chr_size = 8192;
        chr = calloc(1, (size_t)chr_size);
    } else {
        chr = calloc(1, (size_t)chr_size);
        size_t got = fread(chr, 1, (size_t)chr_size, f);
        if (got != (size_t)chr_size)
            fprintf(stderr, "warning: short CHR read (%zu of %d)\n", got, chr_size);
    }
    fclose(f);
    fprintf(stderr, "ROM: mapper %d, PRG %dKB, CHR %dKB%s, %s%s\n",
            mapper, prg_size / 1024, chr_size / 1024, chr_is_ram ? " (RAM)" : "",
            four_screen ? "4-screen" : (mirror_mode == MIR_VERT ? "vertical" : "horizontal"),
            nes2 ? ", NES 2.0" : "");
    return 0;
}

/* ------------------------------------------------------------------ */
/* input script                                                        */
/* ------------------------------------------------------------------ */

static uint8_t btn_bit(const char *n, int *pad)
{
    *pad = 0;
    if (n[0] == '2' && n[1]) { *pad = 1; n++; }
    if (!strcmp(n, "A"))      return 0x01;
    if (!strcmp(n, "B"))      return 0x02;
    if (!strcmp(n, "SELECT")) return 0x04;
    if (!strcmp(n, "START"))  return 0x08;
    if (!strcmp(n, "UP"))     return 0x10;
    if (!strcmp(n, "DOWN"))   return 0x20;
    if (!strcmp(n, "LEFT"))   return 0x40;
    if (!strcmp(n, "RIGHT"))  return 0x80;
    return 0;
}

static void load_input(const char *path)
{
    FILE *f = fopen(path, "r");
    if (!f) { fprintf(stderr, "cannot open input script %s\n", path); exit(1); }
    char line[512];
    int cap = 64;
    inputs = malloc(sizeof(InputEnt) * cap);
    while (fgets(line, sizeof line, f)) {
        char *h = strchr(line, '#'); if (h) *h = 0;
        char *p = line;
        while (*p == ' ' || *p == '\t') p++;
        if (!*p || *p == '\n' || *p == '\r') continue;
        char *end;
        long fr = strtol(p, &end, 10);
        if (end == p) continue;
        p = end;
        while (*p == ' ' || *p == '\t') p++;
        char *nl = strpbrk(p, "\r\n"); if (nl) *nl = 0;
        uint8_t b1 = 0, b2 = 0;
        if (*p && strcmp(p, "-") != 0) {
            char *tok = strtok(p, ",");
            while (tok) {
                while (*tok == ' ') tok++;
                char *e = tok + strlen(tok);
                while (e > tok && (e[-1] == ' ' || e[-1] == '\t')) *--e = 0;
                int pad; uint8_t bit = btn_bit(tok, &pad);
                if (bit) { if (pad) b2 |= bit; else b1 |= bit; }
                else fprintf(stderr, "warning: unknown button '%s'\n", tok);
                tok = strtok(NULL, ",");
            }
        }
        if (n_inputs == cap) { cap *= 2; inputs = realloc(inputs, sizeof(InputEnt) * cap); }
        inputs[n_inputs].frame = fr;
        inputs[n_inputs].p1 = b1;
        inputs[n_inputs].p2 = b2;
        n_inputs++;
    }
    fclose(f);
}

/* ------------------------------------------------------------------ */
/* dumps                                                               */
/* ------------------------------------------------------------------ */

static void write_coverage(const char *path)
{
    FILE *f = fopen(path, "wb");
    if (!f) { fprintf(stderr, "cannot write %s\n", path); return; }
    fwrite(cov_bits, 1, (size_t)((prg_size + 7) / 8), f);
    fclose(f);

    char tpath[1024];
    snprintf(tpath, sizeof tpath, "%s.txt", path);
    f = fopen(tpath, "w");
    if (!f) return;
    long total = 0;
    fprintf(f, "# PRG execution coverage, physical offsets, PRG size %d bytes\n", prg_size);
    fprintf(f, "# start-end  length  bank(8K):offset\n");
    int i = 0;
    while (i < prg_size) {
        int hit = (cov_bits[i >> 3] >> (i & 7)) & 1;
        if (!hit) { i++; continue; }
        int s = i;
        while (i < prg_size && ((cov_bits[i >> 3] >> (i & 7)) & 1)) i++;
        fprintf(f, "%06X-%06X  %6d  %02X:%04X\n", s, i - 1, i - s,
                s / 0x2000, 0x8000 + (s % 0x2000));
        total += i - s;
    }
    fprintf(f, "# total executed bytes: %ld / %d (%.2f%%)\n",
            total, prg_size, prg_size ? 100.0 * total / prg_size : 0.0);
    fclose(f);
}

static void write_ramdump(const char *path)
{
    FILE *f = fopen(path, "wb");
    if (!f) { fprintf(stderr, "cannot write %s\n", path); return; }
    fwrite(ram, 1, sizeof ram, f);
    fwrite(prgram, 1, sizeof prgram, f);
    fclose(f);
}

/* -vram FILE@FRAME -- everything needed to reconstruct exactly what the PPU
 * would draw this frame, so level graphics can be ripped straight out of a
 * running game instead of reverse engineering the level format.
 *
 * layout, little endian:
 *   0     char[8]   "PB3VRAM1"
 *   8     u32       frame
 *   12    u8[2048]  CIRAM
 *   2060  u8[32]    palette
 *   2092  u8[256]   OAM
 *   2348  u16[8]    CHR 1K bank numbers
 *   2364  u8        mirroring (0 h, 1 v, 2 single0, 3 single1, 4 four)
 *   2365  u8        PPUCTRL
 *   2366  u8        PPUMASK
 *   2367  u16       loopy v
 *   2369  u8        fine x
 *   2370  u8[8]     MMC3 R0-R7
 *   2378  u8[4]     PRG 8K bank numbers
 *   2382            end
 */
static int write_vramdump(const char *path, long frame)
{
    FILE *f = fopen(path, "wb");
    if (!f) { fprintf(stderr, "cannot write %s\n", path); return -1; }
    uint8_t hdr[12] = { 'P','B','3','V','R','A','M','1', 0,0,0,0 };
    hdr[8]  = (uint8_t)(frame & 0xFF);
    hdr[9]  = (uint8_t)((frame >> 8) & 0xFF);
    hdr[10] = (uint8_t)((frame >> 16) & 0xFF);
    hdr[11] = (uint8_t)((frame >> 24) & 0xFF);
    fwrite(hdr, 1, 12, f);
    fwrite(vram, 1, 2048, f);
    fwrite(pal, 1, 32, f);
    fwrite(oam, 1, 256, f);
    for (int i = 0; i < 8; i++) {
        int b = chr_map[i] / 0x400;
        fputc(b & 0xFF, f); fputc((b >> 8) & 0xFF, f);
    }
    fputc(mirror_mode, f);
    fputc(ppuctrl, f);
    fputc(ppumask, f);
    fputc(vreg & 0xFF, f); fputc((vreg >> 8) & 0xFF, f);
    fputc(fine_x, f);
    for (int i = 0; i < 8; i++) fputc(mmc3_regs[i], f);
    for (int i = 0; i < 4; i++) fputc(prg_map[i] / 0x2000, f);
    /* 2382: u16[240][8] per-scanline CHR banks */
    for (int y = 0; y < 240; y++)
        for (int i = 0; i < 8; i++) {
            fputc(chr_scan[y][i] & 0xFF, f);
            fputc((chr_scan[y][i] >> 8) & 0xFF, f);
        }
    fwrite(ram, 1, 2048, f);   /* 6222: CPU RAM, so a ripper can read the game's own camera */
    /* per-scanline scroll / mask / ctrl / palette */
    for (int y = 0; y < 240; y++) {
        fputc(v_scan[y] & 0xFF, f); fputc((v_scan[y] >> 8) & 0xFF, f);
        fputc(fx_scan[y], f);
        fputc(mask_scan[y], f);
        fputc(ctrl_scan[y], f);
        fwrite(pal_scan[y], 1, 32, f);
    }
    fclose(f);
    return 0;
}

static void write_statedump(const char *path)
{
    FILE *f = fopen(path, "w");
    if (!f) { fprintf(stderr, "cannot write %s\n", path); return; }
    fprintf(f, "{\n");
    fprintf(f, "  \"pc\": \"%04X\",\n", PC);
    fprintf(f, "  \"a\": %d, \"x\": %d, \"y\": %d, \"p\": %d, \"sp\": %d,\n", A, X, Y, P, SP);
    fprintf(f, "  \"frames\": %ld,\n", cur_frame - 1);
    fprintf(f, "  \"cpu_cycles\": %llu,\n", (unsigned long long)cpu_cycle);
    fprintf(f, "  \"mapper\": %d,\n", mapper);
    fprintf(f, "  \"prg_size\": %d,\n", prg_size);
    fprintf(f, "  \"chr_size\": %d,\n", chr_size);
    fprintf(f, "  \"mirroring\": \"%s\",\n",
            mirror_mode == MIR_HORZ ? "horizontal" :
            mirror_mode == MIR_VERT ? "vertical" :
            mirror_mode == MIR_S0 ? "single0" :
            mirror_mode == MIR_S1 ? "single1" : "four");
    fprintf(f, "  \"mmc3\": { \"bank_select\": %d, \"regs\": [%d,%d,%d,%d,%d,%d,%d,%d], "
               "\"ram_protect\": %d, \"irq_latch\": %d, \"irq_counter\": %d, "
               "\"irq_enable\": %d, \"irq_pending\": %d },\n",
            mmc3_bank_select, mmc3_regs[0], mmc3_regs[1], mmc3_regs[2], mmc3_regs[3],
            mmc3_regs[4], mmc3_regs[5], mmc3_regs[6], mmc3_regs[7],
            mmc3_ram_protect, mmc3_irq_latch, mmc3_irq_counter,
            mmc3_irq_enable, mmc3_irq_pending);
    fprintf(f, "  \"prg_banks_8k\": [%d,%d,%d,%d],\n",
            prg_map[0] / 0x2000, prg_map[1] / 0x2000, prg_map[2] / 0x2000, prg_map[3] / 0x2000);
    fprintf(f, "  \"chr_banks_1k\": [%d,%d,%d,%d,%d,%d,%d,%d],\n",
            chr_map[0] / 0x400, chr_map[1] / 0x400, chr_map[2] / 0x400, chr_map[3] / 0x400,
            chr_map[4] / 0x400, chr_map[5] / 0x400, chr_map[6] / 0x400, chr_map[7] / 0x400);
    if (mapper == 47) {
        fprintf(f, "  \"mapper_outer\": { \"type\": 47, \"block\": %d, "
                   "\"prg_and\": 15, \"prg_or\": %d, "
                   "\"chr_and\": 127, \"chr_or\": %d },\n",
                m47_block, m47_block << 4, m47_block << 7);
    } else if (mapper == 45) {
        fprintf(f, "  \"mapper_outer\": { \"type\": 45, "
                   "\"regs\": [%d,%d,%d,%d], \"write_index\": %d, "
                   "\"locked\": %d, \"dip\": %d, "
                   "\"prg_and\": %d, \"prg_or\": %d, "
                   "\"chr_and\": %d, \"chr_or\": %d },\n",
                m45_reg[0], m45_reg[1], m45_reg[2], m45_reg[3], m45_index,
                (m45_reg[3] & 0x40) ? 1 : 0, m45_dip,
                m45_prg_and(), m45_prg_or(), m45_chr_and(), m45_chr_or());
    } else {
        fprintf(f, "  \"mapper_outer\": null,\n");
    }
    fprintf(f, "  \"ppu\": { \"ctrl\": %d, \"mask\": %d, \"status\": %d, "
               "\"v\": %d, \"t\": %d, \"x\": %d },\n",
            ppuctrl, ppumask, ppustatus, vreg, treg, fine_x);
    fprintf(f, "  \"jam_count\": %d\n", cpu_jammed);
    fprintf(f, "}\n");
    fclose(f);
}

/* ------------------------------------------------------------------ */
/* main                                                                */
/* ------------------------------------------------------------------ */

static void reset_machine(void)
{
    memset(ram, 0, sizeof ram);
    memset(prgram, 0, sizeof prgram);
    memset(vram, 0, sizeof vram);
    memset(oam, 0, sizeof oam);
    memset(pal, 0x0F, sizeof pal);
    mapper_reset();
    A = X = Y = 0; SP = 0xFD; P = 0x24;
    uint8_t lo = bus_read(0xFFFC), hi = bus_read(0xFFFD);
    PC = (uint16_t)(lo | (hi << 8));
    ppuctrl = ppumask = ppustatus = oamaddr = 0;
    vreg = treg = 0; fine_x = wtoggle = 0; ppu_buf = 0;
    scanline = 0; dot = 0; odd_frame = 0;
    nmi_pending = 0; nmi_prev = 0;
    pending_poll_I = FI;
    apu_ctr = 0; apu_mode = 0; apu_irq_inhibit = 0; apu_frame_irq = 0;
    memset(apu_len, 0, sizeof apu_len);
    memset(apu_halt, 0, sizeof apu_halt);
}

static void usage(void)
{
    fprintf(stderr,
        "usage: nesemu <rom.nes> [options]\n"
        "  -frames N         run N frames (default 600)\n"
        "  -input FILE       input script\n"
        "  -png PREFIX       write PREFIX_<frame>.png\n"
        "  -shot N[,N...]    frames to screenshot\n"
        "  -cov FILE         PRG coverage bitmap (+ FILE.txt summary)\n"
        "  -trace FILE       instruction trace\n"
        "  -tracefrom N -traceto M\n"
        "  -tracepc LO-HI    hex PC range\n"
        "  -watch ADDR[-ADDR]\n"
        "  -prgread FILE [-readfrom N] [-readto M]   bitmap of PRG bytes read\n"
        "  -ramdump FILE     $0000-$07FF then $6000-$7FFF\n"
        "  -statedump FILE   final state JSON\n"
        "  -vram FILE@N      dump CIRAM+palette+OAM+bank state at frame N (repeatable)\n"
        "  -savestate F@N    save a savestate at the start of frame N (repeatable)\n"
        "  -loadstate FILE   resume from a savestate; -frames is still the\n"
        "                    ABSOLUTE last frame number to run\n"
        "  -poke A=V@N       write byte V to CPU address A once at frame N (hex A/V)\n"
        "  -freeze A=V[@N]   rewrite byte V to CPU address A every frame from N on\n"
        "  -rompoke O=V      write byte V at PRG file offset O before the run (hex O/V)\n"
        "  -sample P=A       log what address A held whenever PC reached P (hex);\n"
        "                    A may instead be a register: A, X, Y or P\n"
        "  -verbose LO-HI    one line per frame in that range: frame, PC, PRG banks\n");
}

int main(int argc, char **argv)
{
    if (argc < 2) { usage(); return 1; }
    const char *rompath = argv[1];

    for (int i = 2; i < argc; i++) {
        const char *o = argv[i];
        #define NEED(x) if (i + 1 >= argc) { fprintf(stderr, "%s needs an argument\n", x); return 1; }
        if (!strcmp(o, "-frames"))      { NEED(o); opt_frames = strtol(argv[++i], NULL, 0); }
        else if (!strcmp(o, "-input"))  { NEED(o); load_input(argv[++i]); }
        else if (!strcmp(o, "-png"))    { NEED(o); opt_png_prefix = argv[++i]; }
        else if (!strcmp(o, "-shot"))   {
            NEED(o);
            char *s = argv[++i];
            char *tok = strtok(s, ",");
            while (tok && opt_nshots < 64) { opt_shots[opt_nshots++] = strtol(tok, NULL, 0); tok = strtok(NULL, ","); }
        }
        else if (!strcmp(o, "-cov"))       { NEED(o); opt_cov = argv[++i]; }
        else if (!strcmp(o, "-prgread"))   { NEED(o); opt_prgread = argv[++i]; }
        else if (!strcmp(o, "-readfrom"))  { NEED(o); opt_readfrom = atol(argv[++i]); }
        else if (!strcmp(o, "-readto"))    { NEED(o); opt_readto = atol(argv[++i]); }
        else if (!strcmp(o, "-trace"))     { NEED(o); opt_trace = argv[++i]; }
        else if (!strcmp(o, "-tracefrom")) { NEED(o); opt_tracefrom = strtol(argv[++i], NULL, 0); }
        else if (!strcmp(o, "-traceto"))   { NEED(o); opt_traceto = strtol(argv[++i], NULL, 0); }
        else if (!strcmp(o, "-tracepc"))   {
            NEED(o);
            char *s = argv[++i]; char *d = strchr(s, '-');
            opt_tracepc_lo = strtol(s, NULL, 16);
            opt_tracepc_hi = d ? strtol(d + 1, NULL, 16) : opt_tracepc_lo;
        }
        else if (!strcmp(o, "-watch"))     {
            NEED(o);
            char *s = argv[++i]; char *d = strchr(s, '-');
            opt_watch_lo = strtol(s, NULL, 16);
            opt_watch_hi = d ? strtol(d + 1, NULL, 16) : opt_watch_lo;
        }
        else if (!strcmp(o, "-ramdump"))   { NEED(o); opt_ramdump = argv[++i]; }
        else if (!strcmp(o, "-statedump")) { NEED(o); opt_statedump = argv[++i]; }
        else if (!strcmp(o, "-loadstate")) { NEED(o); opt_loadstate = argv[++i]; }
        else if (!strcmp(o, "-savestate")) {
            NEED(o);
            char *s = argv[++i];
            char *at = strrchr(s, '@');
            if (!at) { fprintf(stderr, "-savestate needs FILE@FRAME\n"); return 1; }
            if (n_savereqs >= 64) { fprintf(stderr, "too many -savestate\n"); return 1; }
            *at = 0;
            savereqs[n_savereqs].path = s;
            savereqs[n_savereqs].frame = strtol(at + 1, NULL, 10);
            n_savereqs++;
        }
        else if (!strcmp(o, "-vram")) {
            NEED(o);
            char *s = argv[++i];
            char *at = strrchr(s, '@');
            if (!at) { fprintf(stderr, "-vram needs FILE@FRAME\n"); return 1; }
            if (n_vramreqs >= 512) { fprintf(stderr, "too many -vram\n"); return 1; }
            *at = 0;
            vramreqs[n_vramreqs].path = s;
            vramreqs[n_vramreqs].frame = strtol(at + 1, NULL, 10);
            n_vramreqs++;
        }
        else if (!strcmp(o, "-poke")) {
            NEED(o);
            char *s = argv[++i];
            char *eq = strchr(s, '='), *at = strrchr(s, '@');
            if (!eq || !at || at < eq) { fprintf(stderr, "-poke needs ADDR=VAL@FRAME\n"); return 1; }
            if (n_pokes >= 256) { fprintf(stderr, "too many -poke\n"); return 1; }
            pokes[n_pokes].addr  = (uint16_t)strtol(s, NULL, 16);
            pokes[n_pokes].val   = (uint8_t)strtol(eq + 1, NULL, 16);
            pokes[n_pokes].frame = strtol(at + 1, NULL, 10);
            n_pokes++;
        }
        else if (!strcmp(o, "-freeze")) {
            NEED(o);
            char *s = argv[++i];
            char *eq = strchr(s, '=');
            if (!eq) { fprintf(stderr, "-freeze needs ADDR=VAL\n"); return 1; }
            if (n_freezes >= 256) { fprintf(stderr, "too many -freeze\n"); return 1; }
            char *at = strrchr(s, '@');
            freezes[n_freezes].addr = (uint16_t)strtol(s, NULL, 16);
            freezes[n_freezes].val  = (uint8_t)strtol(eq + 1, NULL, 16);
            freezes[n_freezes].from = at ? strtol(at + 1, NULL, 10) : 0;
            n_freezes++;
        }
        else if (!strcmp(o, "-sample")) {
            NEED(o);
            char *s = argv[++i];
            char *eq = strchr(s, '=');
            if (!eq) { fprintf(stderr, "-sample needs PC=ADDR\n"); return 1; }
            if (n_samples >= 64) { fprintf(stderr, "too many -sample\n"); return 1; }
            samples[n_samples].pc   = (uint16_t)strtol(s, NULL, 16);
            samples[n_samples].reg  = 0;
            samples[n_samples].addr = 0;
            {
                const char *w = eq + 1;
                if (w[0] && !w[1]) {
                    switch (w[0]) {
                    case 'A': case 'a': samples[n_samples].reg = 1; break;
                    case 'X': case 'x': samples[n_samples].reg = 2; break;
                    case 'Y': case 'y': samples[n_samples].reg = 3; break;
                    case 'P': case 'p': samples[n_samples].reg = 4; break;
                    }
                }
                if (!samples[n_samples].reg)
                    samples[n_samples].addr = (uint16_t)strtol(w, NULL, 16);
            }
            n_samples++;
        }
        else if (!strcmp(o, "-rompoke")) {
            NEED(o);
            char *s = argv[++i];
            char *eq = strchr(s, '=');
            if (!eq) { fprintf(stderr, "-rompoke needs OFFSET=VAL\n"); return 1; }
            if (n_rompokes >= 256) { fprintf(stderr, "too many -rompoke\n"); return 1; }
            rompokes[n_rompokes].off = strtol(s, NULL, 16);
            rompokes[n_rompokes].val = (uint8_t)strtol(eq + 1, NULL, 16);
            n_rompokes++;
        }
        else if (!strcmp(o, "-verbose")) {
            NEED(o);
            char *s = argv[++i]; char *d = strchr(s, '-');
            opt_verbose_lo = strtol(s, NULL, 10);
            opt_verbose_hi = d ? strtol(d + 1, NULL, 10) : opt_verbose_lo;
        }
        else { fprintf(stderr, "unknown option %s\n", o); usage(); return 1; }
        #undef NEED
    }

    if (load_rom(rompath) != 0) return 1;
    for (int k = 0; k < n_rompokes; k++) {
        if (rompokes[k].off < 0 || rompokes[k].off >= prg_size) {
            fprintf(stderr, "-rompoke offset %lX outside PRG (%d bytes)\n",
                    rompokes[k].off, prg_size);
            return 1;
        }
        prg[rompokes[k].off] = rompokes[k].val;
    }
    if (opt_cov) cov_bits = calloc(1, (size_t)((prg_size + 7) / 8));
    if (opt_prgread) rd_bits = calloc(1, (size_t)((prg_size + 7) / 8));
    if (n_vramreqs) chr_scan_arm = 1;
    if (opt_trace) {
        trace_fp = fopen(opt_trace, "w");
        if (!trace_fp) { fprintf(stderr, "cannot write %s\n", opt_trace); return 1; }
    }

    reset_machine();

    if (opt_loadstate) {
        if (load_state(opt_loadstate) != 0) return 1;
        fprintf(stderr, "loaded %s: resuming at frame %ld (PC=%04X)\n",
                opt_loadstate, cur_frame, PC);
        if (cur_frame > opt_frames)
            fprintf(stderr, "warning: -frames %ld is at or before the loaded "
                    "frame %ld, so no frames will run (-frames is absolute)\n",
                    opt_frames, cur_frame);
    }
    start_frame = cur_frame;

    for (cur_frame = start_frame; cur_frame <= opt_frames; cur_frame++) {
        /* apply input for this frame */
        while (input_idx < n_inputs && inputs[input_idx].frame <= cur_frame) {
            pad_state[0] = inputs[input_idx].p1;
            pad_state[1] = inputs[input_idx].p2;
            input_idx++;
        }
        if (pad_strobe) { pad_shift[0] = pad_state[0]; pad_shift[1] = pad_state[1]; }

        /* one-shot pokes, then the freeze list, then any savestate request:
         * the state therefore captures the frame exactly as it will run */
        for (int k = 0; k < n_pokes; k++)
            if (pokes[k].frame == cur_frame) poke_write(pokes[k].addr, pokes[k].val);
        for (int k = 0; k < n_freezes; k++)
            if (cur_frame >= freezes[k].from)
                poke_write(freezes[k].addr, freezes[k].val);
        for (int k = 0; k < n_vramreqs; k++)
            if (vramreqs[k].frame == cur_frame) write_vramdump(vramreqs[k].path, cur_frame);
        for (int k = 0; k < n_savereqs; k++)
            if (savereqs[k].frame == cur_frame && save_state(savereqs[k].path) == 0)
                fprintf(stderr, "wrote savestate %s at frame %ld\n",
                        savereqs[k].path, cur_frame);

        frame_done = 0;
        uint64_t guard = cpu_cycle + 4000000;
        while (!frame_done) {
            cpu_step();
            if (cpu_cycle > guard) {
                fprintf(stderr, "frame %ld: watchdog trip (no vblank)\n", cur_frame);
                break;
            }
        }

        if (opt_verbose_lo >= 0 && cur_frame >= opt_verbose_lo &&
            cur_frame <= opt_verbose_hi) {
            printf("V %ld PC=%04X PRG=%d,%d,%d,%d",
                   cur_frame, PC, prg_map[0] / 0x2000, prg_map[1] / 0x2000,
                   prg_map[2] / 0x2000, prg_map[3] / 0x2000);
            if (mapper == 47) printf(" BLOCK=%d", m47_block);
            else if (mapper == 45)
                printf(" OUTER=%02X,%02X,%02X,%02X", m45_reg[0], m45_reg[1],
                       m45_reg[2], m45_reg[3]);
            printf("\n");
        }

        if (opt_png_prefix) {
            for (int s = 0; s < opt_nshots; s++) {
                if (opt_shots[s] == cur_frame) {
                    char path[1024];
                    snprintf(path, sizeof path, "%s_%ld.png", opt_png_prefix, cur_frame);
                    if (write_png(path) == 0) fprintf(stderr, "wrote %s\n", path);
                    else fprintf(stderr, "failed writing %s\n", path);
                }
            }
        }
    }

    if (opt_cov) write_coverage(opt_cov);
    if (opt_prgread) {
        FILE *f = fopen(opt_prgread, "wb");
        if (f) { fwrite(rd_bits, 1, (size_t)((prg_size + 7) / 8), f); fclose(f);
                 fprintf(stderr, "wrote %s\n", opt_prgread); }
    }
    if (opt_ramdump) write_ramdump(opt_ramdump);
    if (opt_statedump) write_statedump(opt_statedump);
    if (trace_fp) fclose(trace_fp);
    if (cpu_jammed) fprintf(stderr, "note: %d JAM opcode(s) executed\n", cpu_jammed);
    fprintf(stderr, "done: %ld frames, %llu cpu cycles\n",
            opt_frames, (unsigned long long)cpu_cycle);
    return 0;
}
