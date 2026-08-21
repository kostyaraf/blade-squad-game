#!/usr/bin/env python3
"""Build the PB3 cartridge.

PB3 is Power Blade 2's engine living in a much bigger cartridge so that the
converted Solbrain levels, the extra CHR and the new PB3 code all fit.

    mapper 4 (MMC3), 512 KB PRG (64 banks), 256 KB CHR, 8 KB work RAM

    PRG bank  0..13   Power Blade 2 banks 0..13   (the level pairs the engine's
                      own $0F-masked bank helper can still reach)
    PRG bank 16..61   PB3 payload: converted Solbrain levels and new code
    PRG bank 62,63    Power Blade 2 banks 14,15 -- MMC3 hard-wires the last two
                      banks to $C000 and $E000, which is exactly where this
                      engine expects its fixed code
    CHR   0..127 (1K) Power Blade 2's CHR
    CHR 128..255 (1K) Solbrain's CHR, so its levels keep their own artwork

Work RAM $6000-$7FFF is untouched by Power Blade 2 (verified over 2400 frames),
so PB3's runtime code and its extended stage tables are copied there at boot.
"""
import os, sys, hashlib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PB2  = os.path.join(ROOT, "Power Blade 2 (USA).nes")
SOL  = os.path.join(ROOT, "Tokkyuu Shirei Solbrain (Japan).nes")
OUT  = os.path.join(ROOT, "work/build/PB3.nes")

PRG_BANKS = 64          # 8 KB each  -> 512 KB
CHR_BANKS = 256         # 1 KB each  -> 256 KB


def load(path):
    d = open(path, 'rb').read()
    hdr, d = d[:16], d[16:]
    nprg = hdr[4] * 16384
    prg, chr_ = d[:nprg], d[nprg:]
    return hdr, prg, chr_


class Image:
    def __init__(self):
        self.prg = bytearray(b'\xFF' * (PRG_BANKS * 0x2000))
        self.chr = bytearray(CHR_BANKS * 0x400)
        self.free_prg = []          # banks handed out by alloc()

    def put_prg(self, bank, data):
        assert len(data) == 0x2000, len(data)
        self.prg[bank * 0x2000: (bank + 1) * 0x2000] = data

    def get_prg(self, bank):
        return self.prg[bank * 0x2000: (bank + 1) * 0x2000]

    def put_chr(self, bank, data):
        n = len(data) // 0x400
        self.chr[bank * 0x400: (bank + n) * 0x400] = data

    def patch(self, bank, cpu_addr, base, data):
        """Write `data` at CPU address `cpu_addr`, where `base` is the CPU
        address bank `bank` is mapped at."""
        off = bank * 0x2000 + (cpu_addr - base)
        self.prg[off:off + len(data)] = data

    def read(self, bank, cpu_addr, base, n):
        off = bank * 0x2000 + (cpu_addr - base)
        return bytes(self.prg[off:off + n])


def header():
    h = bytearray(16)
    h[0:4] = b'NES\x1a'
    h[4] = (PRG_BANKS * 0x2000) // 16384        # 32 x 16 KB
    h[5] = (CHR_BANKS * 0x400) // 8192          # 32 x  8 KB
    h[6] = 0x40                                 # mapper lo = 4, horizontal
    h[7] = 0x08                                 # NES 2.0
    h[10] = 0x07                                # 8 KB of work RAM (64 << 7)
    return bytes(h)


def build():
    _, pb2_prg, pb2_chr = load(PB2)
    _, sol_prg, sol_chr = load(SOL)
    img = Image()

    for b in range(14):
        img.put_prg(b, pb2_prg[b * 0x2000:(b + 1) * 0x2000])
    img.put_prg(62, pb2_prg[14 * 0x2000:15 * 0x2000])
    img.put_prg(63, pb2_prg[15 * 0x2000:16 * 0x2000])

    img.put_chr(0,   pb2_chr)          # 128 KB -> CHR banks 0..127
    img.put_chr(128, sol_chr)          # 128 KB -> CHR banks 128..255

    img.sol_prg = sol_prg
    return img


def write(img, path=OUT):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(header())
        f.write(img.prg)
        f.write(img.chr)
    print(f"{path}: {os.path.getsize(path)} bytes "
          f"({PRG_BANKS * 8} KB PRG, {CHR_BANKS} KB CHR)")


if __name__ == '__main__':
    write(build())


# ===========================================================================
# PB3 runtime
#
# Power Blade 2 looks its level data up through five tables that live in its
# fixed bank and have exactly seven entries, one per stage.  PB3 needs more
# stages than that and there is no free room next to the originals, so the
# tables are copied into work RAM -- which the game never touches -- and every
# instruction that read them is repointed.  While the tables are in RAM they
# can also be rebuilt at run time, which is what a stage-select menu needs.
# ===========================================================================

PAYLOAD_BANK = 16

WRAM        = 0x6000
RT_SETBANK  = 0x6000        # bank helper without the engine's $0F mask
RT_SETBANK_NS = 0x6006      # ... the same, entered without saving the old bank
RT_T1       = 0x6100        # was $DE31   attribute-pointer table
RT_T2       = 0x6120        # was $DE3F   block-pointer table
RT_T3       = 0x6140        # was $DE4D   area-pointer table
RT_T4       = 0x6160        # was $DE5B   screen-pointer table
RT_T5       = 0x6180        # was $E2BC   area-record table
RT_T6       = 0x61E0        # was $DE23   collision table
RT_T8       = 0x61F0        # was $F0A4   per-area player entry list
RT_T7       = 0x6110        # was $E515   object-placement table
RT_NAREA    = 0x6130        # was $D6CD   areas per stage
RT_PAIR     = 0x61A0        # was $DFD8   stage -> level PRG bank pair
RT_ABANK    = 0x61C0        # new        stage -> area-record PRG bank pair
RT_PAL      = 0x6200        # new        palette hook for converted stages
RT_PALDATA  = 0x6400        # new       16 x 16 bytes of background palette
RT_SUITS    = 0x6300        # new        the all-suits grant
RT_ANIM     = 0x6320        # new        background-animation gate
RT_CONV     = 0x61B0        # new        stage -> 1 if the level is converted
RT_WORLD    = 0x6071        # new        map screen: which block of stages
RT_WBASE    = 0x6098        # new        world -> first stage on the map
RT_LOADW    = 0x6340        # new        swap the live stage tables for a world
RT_MAPIN    = 0x6380        # new        map screen input hook
RT_MAPLIM   = 0x63C0        # new        map cursor upper bound
RT_SETCLR   = 0x63E0        # new        stage-cleared mask, clamped
RT_SETSUIT  = 0x63F0        # new        suit-pickup mask, clamped
RT_NEWGAME  = 0x6338        # new        new-game init tail
MW_TABLES   = 0x6800        # new        three worlds x one page of stage tables
MW_PALETTE  = 0x6B00        # new        three worlds x one page of palettes
RT_AREABANK = 0x6040        # new        maps the area-record bank
RT_ENTRY    = 0x6050        # new        read the per-area player entry byte
RT_EDGE     = 0x6700        # new        the collision probe's bounds check
RT_WANT2P   = 0x6073        # new        1 = co-op selected on the menu
RT_HERO     = 0x6074        # new        0 = Power Blade, 1 = Solbrain
RT_P2CD     = 0x6076        # new        frames until player 2 (re)joins
RT_PLAYERS  = 0x6500        # new        run player 1, then player 2
RT_SWAP     = 0x6540        # new        exchange the two players' state
RT_JOIN     = 0x65C0        # new        put player 2 into the level
RT_P2SCAL   = 0x6620        # new        player 2's copy of $0110-$013F
RT_FINDSHOT = 0x6660        # new        bounded free-slot search for shots
RT_CUR      = 0x6077        # new        which line the menu cursor is on
RT_MENU     = 0x7000        # new        the PB3 front-end
RT_CURHI    = 0x7200        # new        cursor line -> nametable address
RT_CURLO    = 0x7220
RT_MRKHI    = 0x7240        # new        option marker -> nametable address
RT_MRKLO    = 0x7248
RT_STW      = 0x7260        # new        menu line -> world
RT_STN      = 0x7270        # new        menu line -> stage inside that world
RT_CRATE    = 0x6E00        # new        the $BA42 breakable-block redraw hook
RT_CRTAB    = 0x7300        # new        (world, stage) -> that stage's areas
RT_CRPOOL   = 0x7330        # new        ... and the records they point at
RT_CREND    = 0x7F00        # new        where the pool has to stop
MENU_BANK   = 60            # new        the menu's nametable and palette

MENU_ROWS   = 18            # two option lines and sixteen stages
MENU_CUR    = 0x1C          # the font's arrow glyph
FONT_BANK   = 28            # the 2 KB CHR bank the status bar's font lives in
RT_BOOT     = 0x7F00        # the copy loop, reached at $9F00 before the copy

PB3_STAGES  = 7             # the engine indexes everything by a 0..6 stage
PB3_WORLDS  = 3             # ... so extra levels arrive as extra worlds

PB2_RESET   = 0xE5B9
BOOT_STUB   = 0xFFDC        # 24 unused bytes ahead of the vectors
WRAM_ON     = 0xFFEE        # ... the last six of them


def asm(*parts):
    out = bytearray()
    for p in parts:
        out += bytes(p) if isinstance(p, (list, tuple, bytes, bytearray)) else bytes([p])
    return bytes(out)


def rel(src_next, dst):
    d = dst - src_next
    assert -128 <= d <= 127, d
    return d & 0xFF


def setbank_code():
    """A = physical 8 K bank; maps A and A+1 at $8000/$A000.  Mirrors what
    $ECA7 does, including saving the previous bank in $40, but without the
    #$0F mask that limits the original to the first sixteen banks."""
    return asm(
        0x48,                       # pha
        0xA5, 0x3F,                 # lda $3F
        0x85, 0x40,                 # sta $40
        0x68,                       # pla
        0xA8,                       # tay
        0x84, 0x3F,                 # sty $3F
        0xA9, 0x06,                 # lda #$06
        0x85, 0xA4,                 # sta $A4
        0x8D, 0x00, 0x80,           # sta $8000
        0x8C, 0x01, 0x80,           # sty $8001
        0xA9, 0x07,                 # lda #$07
        0x85, 0xA4,                 # sta $A4
        0x8D, 0x00, 0x80,           # sta $8000
        0xC8,                       # iny
        0x8C, 0x01, 0x80,           # sty $8001
        0x60,                       # rts
    )


def areabank_code():
    """Stock code hard-wires bank pair 6/7 for the area records ($E23F,
    LDY #$36).  PB3 gives every stage its own entry so a converted level can
    carry its records in its own bank."""
    return asm(
        0xA0, 0x06,                 # ldy #6
        0xA5, 0x79,                 # lda $79
        0xD0, 0x02,                 # bne +
        0xA4, 0x53,                 # ldy $53
        0xB9, RT_ABANK & 0xFF, RT_ABANK >> 8,   # + lda RT_ABANK,y
        0x4C, RT_SETBANK & 0xFF, RT_SETBANK >> 8,
    )


def entry_code():
    """$F04C reads the per-area entry byte through a pointer.  In Power Blade 2
    that pointer aimed at the fixed bank, so no banking was needed; a converted
    stage carries its list in its own level bank, and $F04C is reached with
    whatever bank the caller left mapped -- the object AI's, usually.  Map the
    level, read the byte, put the caller's bank back."""
    return asm(
        0xA5, 0x3F,                 # lda $3F        the caller's bank
        0x48,                       # pha
        0x20, RT_AREABANK & 0xFF, RT_AREABANK >> 8,
        0xA4, 0x9C,                 # ldy $9C
        0xB1, 0x00,                 # lda ($00),y
        0xAA,                       # tax
        0x68,                       # pla
        0x20, RT_SETBANK & 0xFF, RT_SETBANK >> 8,
        0x8A,                       # txa
        0x60,                       # rts
    )


def edge_code():
    """Replaces `LDA ($35),Y / ASL A / TAY` at $F497, the point where the
    routine that says what is at a world position turns a screen number into a
    screen.

    Nothing checks that number.  Power Blade 2's own levels are walled in, so
    the question never comes up; a converted Solbrain area very often has open
    space at its edge, and one probe past it arrives here with Y = $FF.  The
    routine then reads a screen pointer, a block id and a tile out of whatever
    follows the level in the bank, and the tile it finds is $FF -- which no
    threshold in the table is above, so the classifier's search loop never
    terminates and the game hangs with the music still playing.

    Anything outside the area now reads as solid, which is also what it should
    have been: the edge of the level is a wall.  Three separate paths reach
    $F497 and all of them come in with the classifier's own return address on
    top of the stack, so bailing out is two pulls and the exit $F502 uses."""
    b = bytearray()
    b += asm(0xC4, 0x59)                    # cpy $59      the last screen
    beq = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq ok
    bcs = len(b) + 1
    b += asm(0xB0, 0x00)                    # bcs out      past it, or below 0
    ok = len(b)
    b += asm(0xB1, 0x35, 0x0A, 0xA8, 0x60)  # lda ($35),y / asl a / tay / rts
    out = len(b)
    b += asm(0x68, 0x68)                    # pla / pla    leave the classifier
    b += asm(0xA6, 0x25)                    # ldx $25      ... the way it does
    b += asm(0x20, 0xC7, 0xEC)              # jsr $ECC7
    b += asm(0xA9, 0x80, 0x85, 0x17)        # lda #$80 / sta $17   solid
    b += asm(0x60)
    b[beq] = rel(beq + 1, ok)
    b[bcs] = rel(bcs + 1, out)
    return bytes(b)


def pal_code():
    """Replaces the JMP at bank-pair-0 $801B.

    Power Blade 2 builds its 32 palette bytes at $03E0 from a set index in
    $016D: 47 sets, so anything with bit 7 set is free.  PB3 uses that bit to
    mean "run set 0 as usual, then paint the four background palettes over it
    from RAM", which is how a converted Solbrain stage keeps its own colours
    while the sprites keep Power Blade 2's."""
    body = bytearray()
    body += asm(0x48)                       # pha
    body += asm(0xAA)                       # tax
    body += asm(0x29, 0x80)                 # and #$80
    beq = len(body) + 1
    body += asm(0xF0, 0x00)                 # beq stock
    body += asm(0xA2, 0x00)                 # ldx #0   converted -> neutral set
    stock = len(body)
    body += asm(0x8A)                       # txa
    body += asm(0x20, 0x44, 0x80)           # jsr $8044   the stock builder
    body += asm(0x68)                       # pla
    bpl = len(body) + 1
    body += asm(0x10, 0x00)                 # bpl done    (patched once done is known)
    body += asm(0x29, 0x0F)                 # and #$0F
    body += asm(0x0A, 0x0A, 0x0A, 0x0A)     # asl x4  -> slot * 16
    body += asm(0xA8)                       # tay
    body += asm(0xA2, 0x00)                 # ldx #0
    loop = len(body)
    body += asm(0xB9, RT_PALDATA & 0xFF, RT_PALDATA >> 8)   # lda RT_PALDATA,y
    body += asm(0x9D, 0xE0, 0x03)           # sta $03E0,x
    body += asm(0xC8, 0xE8)                 # iny / inx
    body += asm(0xE0, 0x10)                 # cpx #$10
    body += asm(0xD0, rel(len(body) + 2, loop))
    body += asm(0x60)                       # rts
    done = len(body) - 1                    # the rts doubles as the exit
    body[bpl] = rel(bpl + 1, done)
    body[beq] = rel(beq + 1, stock)
    return bytes(body)


def suits_code():
    """work/pb3/patches/pb2_all_suits.py, moved into work RAM so it does not
    fight the boot stub for the tail of bank 15."""
    return asm(
        0xA9, 0x10, 0x85, 0xA0,     # lda #$10 / sta $A0   full suit energy
        0x4A, 0x85, 0x9E,           # lsr a    / sta $9E   full spare tanks
        0xA9, 0x0F, 0x85, 0x56,     # lda #$0F / sta $56   every suit owned
        0xA9, 0x3C,                 # lda #60   player 2 walks in after a
        0x8D, RT_P2CD & 0xFF, RT_P2CD >> 8,   # ... second of the new stage
        0x20, 0xF1, 0xD8,           # jsr $D8F1  the tail this hook replaced
        0x20, 0xB6, 0xD4,           # jsr $D4B6  repaint the tank counter
        0x4C, 0xD9, 0xD4,           # jmp $D4D9  repaint the energy bar
    )


def anim_code():
    """Replaces bank pair 4's $8018 island entry.

    $BEC9 picks the animated background CHR bank out of a seven-entry table --
    one entry per original stage -- so a converted stage would read past its
    end.  Converted stages have no animated background, and $5C = $FF is
    exactly how the stock table says "this area does not animate", so the
    record's own CHR bank is left alone."""
    return asm(
        0xA5, 0x79,                 # lda $79     boss/intro areas stay stock
        0xD0, 0x0B,                 # bne orig
        0xA6, 0x53,                 # ldx $53
        0xBD, RT_CONV & 0xFF, RT_CONV >> 8,   # lda RT_CONV,x
        0xF0, 0x05,                 # beq orig
        0xA9, 0xFF,                 # lda #$FF
        0x85, 0x5C,                 # sta $5C
        0x60,                       # rts
        0x4C, 0xC9, 0xBE,           # orig: jmp $BEC9
    )


def mapin_code():
    """Replaces the map screen's `JSR $C837` at $871E.

    Power Blade 2's map holds five nodes and its own five stages.  PB3 has
    sixteen, so the map gains a second axis: UP and DOWN move between worlds
    (0 = Power Blade 2, 1 and 2 = the converted Solbrain stages) and the five
    nodes then address that world's block of stages."""
    b = bytearray()
    b += asm(0x20, 0x37, 0xC8)              # jsr $C837   the call this replaced
    b += asm(0xAE, RT_WORLD & 0xFF, RT_WORLD >> 8)   # ldx RT_WORLD
    # tint the rider on the map so the current world is visible at a glance
    b += asm(0xAD, 0x2C, 0x04)              # lda $042C   cursor sprite attribute
    b += asm(0x29, 0xFC)                    # and #$FC
    b += asm(0x0D, RT_WORLD & 0xFF, RT_WORLD >> 8)   # ora RT_WORLD
    b += asm(0x8D, 0x2C, 0x04)              # sta $042C
    b += asm(0xAE, RT_WORLD & 0xFF, RT_WORLD >> 8)   # ldx RT_WORLD
    b += asm(0xA5, 0x48)                    # lda $48     newly pressed
    b += asm(0x29, 0x08)                    # and #$08    UP
    beq_down = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq chk_down
    b += asm(0xE8)                          # inx
    b += asm(0xE0, 0x03)                    # cpx #3
    bne_store = len(b) + 1
    b += asm(0xD0, 0x00)                    # bne store
    b += asm(0xA2, 0x00)                    # ldx #0
    beq_store2 = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq store   (always)
    chk_down = len(b)
    b += asm(0xA5, 0x48)                    # lda $48
    b += asm(0x29, 0x04)                    # and #$04    DOWN
    beq_ret = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq ret
    b += asm(0xCA)                          # dex
    bpl_store = len(b) + 1
    b += asm(0x10, 0x00)                    # bpl store
    b += asm(0xA2, 0x02)                    # ldx #2
    store = len(b)
    b += asm(0x8E, RT_WORLD & 0xFF, RT_WORLD >> 8)   # stx RT_WORLD
    b += asm(0x20, RT_LOADW & 0xFF, RT_LOADW >> 8)   # jsr RT_LOADW
    b += asm(0xA9, 0x29)                    # lda #$29    the map's own blip
    b += asm(0x4C, 0x1C, 0xC8)              # jmp $C81C
    ret = len(b)
    b += asm(0x60)                          # rts
    b[beq_down]   = rel(beq_down + 1, chk_down)
    b[bne_store]  = rel(bne_store + 1, store)
    b[beq_store2] = rel(beq_store2 + 1, store)
    b[beq_ret]    = rel(beq_ret + 1, ret)
    b[bpl_store]  = rel(bpl_store + 1, store)
    return bytes(b)


def loadw_code():
    """Copy one world's stage tables into the live ones.

    Power Blade 2 indexes fifteen different seven-entry tables with the stage
    number, so the stage number has to stay in 0..6.  PB3 therefore does not
    widen it: it keeps three parallel *worlds* of seven stages and swaps the
    tables the engine reads -- which are in work RAM anyway -- whenever the
    player changes world on the map."""
    b = bytearray()
    b += asm(0xA9, 0x00, 0x85, 0x00, 0x85, 0x02)     # lda #0 / sta $00 / sta $02
    b += asm(0xAD, RT_WORLD & 0xFF, RT_WORLD >> 8)   # lda RT_WORLD
    b += asm(0x18, 0x69, MW_TABLES >> 8, 0x85, 0x01) # clc / adc #>MW / sta $01
    b += asm(0xA9, RT_T1 >> 8, 0x85, 0x03)           # lda #>$6100 / sta $03
    b += asm(0xA0, 0x00)                             # ldy #0
    l1 = len(b)
    b += asm(0xB1, 0x00, 0x91, 0x02, 0xC8)           # lda ($00),y / sta ($02),y / iny
    b += asm(0xD0, rel(len(b) + 2, l1))              # bne l1
    b += asm(0xAD, RT_WORLD & 0xFF, RT_WORLD >> 8)   # lda RT_WORLD
    b += asm(0x18, 0x69, MW_PALETTE >> 8, 0x85, 0x01)
    b += asm(0xA9, RT_PALDATA >> 8, 0x85, 0x03)
    l2 = len(b)
    b += asm(0xB1, 0x00, 0x91, 0x02, 0xC8)
    b += asm(0xC0, 0x80)                             # cpy #$80
    b += asm(0xD0, rel(len(b) + 2, l2))
    b += asm(0x60)
    return bytes(b)


def maplim_code():
    """Replaces the node upper bound at $874D.  Returns carry clear while the
    cursor may still move right.  Power Blade 2's own world keeps its rule --
    node 4 only opens once the first four stages are cleared -- and the two
    converted worlds are open from the start."""
    b = bytearray()
    b += asm(0xAD, RT_WORLD & 0xFF, RT_WORLD >> 8)   # lda RT_WORLD
    bne = len(b) + 1
    b += asm(0xD0, 0x00)                    # bne lim4
    b += asm(0xA5, 0x5B)                    # lda $5B
    b += asm(0xC9, 0x0F)                    # cmp #$0F
    beq = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq lim4
    b += asm(0xA5, 0x22)                    # lda $22
    b += asm(0xC9, 0x03)                    # cmp #3
    b += asm(0x60)                          # rts
    lim4 = len(b)
    b += asm(0xA5, 0x22)                    # lda $22
    b += asm(0xC9, 0x04)                    # cmp #4
    b += asm(0x60)                          # rts
    b[bne] = rel(bne + 1, lim4)
    b[beq] = rel(beq + 1, lim4)
    return bytes(b)


def mask_code(zp):
    """$BE22 and $BE2C mark a stage cleared / a suit collected.  Only Power
    Blade 2's own world owns that progress -- clearing a converted stage must
    not tick off the Power Blade 2 stage that shares its node."""
    b = bytearray()
    b += asm(0xAD, RT_WORLD & 0xFF, RT_WORLD >> 8)   # lda RT_WORLD
    bne = len(b) + 1
    b += asm(0xD0, 0x00)                    # bne skip
    b += asm(0xA4, 0x53)                    # ldy $53
    b += asm(0xB9, 0x36, 0xBE)              # lda $BE36,y
    b += asm(0x05, zp)                      # ora zp
    b += asm(0x85, zp)                      # sta zp
    skip = len(b)
    b += asm(0x60)                          # rts
    b[bne] = rel(bne + 1, skip)
    return bytes(b)


def newgame_code():
    """Tail of the new-game wipe at $9832; A is still zero there."""
    return asm(0x8D, RT_WORLD & 0xFF, RT_WORLD >> 8,   # sta RT_WORLD
               0x4C, 0x13, 0xC8)                       # jmp $C813


P2_SLOT   = 5               # the object slot player 2 lives in
OBJ_BASE  = 0x0400          # field 0 of slot 0; fields are $16 apart
OBJ_N     = 29              # ... and there are 29 of them
SCAL_LO   = 0x0110          # the player scalars that are not in the array
SCAL_N    = 0x30
OBJ_LIVE  = 0x0442          # field 3: non-zero means the slot holds an object


def players_code():
    """Replaces the `JMP $8E15` at bank 8 $8000, which is the one place the
    engine says "now update the player".

    Player 2 is object slot 5.  It has to be one of slots 0-5: the metasprite
    composer keeps two separate pointer tables, $8148/$81B4 for slots 0-5 and
    $8C88/$8D83 for slots 6-21, and only the first one knows the player's
    poses.  Slots 1-3 are the player's shots and slot 4 is left to them, so 5
    is the one that is free.  The engine addresses
    the player through hardcoded absolute addresses into slot 0, so player 2
    is run by swapping it into slot 0, calling the same code, and swapping
    back; the two updates happen back to back inside one frame, which is what
    makes this simultaneous rather than alternating."""
    b = bytearray()
    b += asm(0x20, 0x15, 0x8E)              # jsr $8E15    player 1
    b += asm(0xAD, RT_WANT2P & 0xFF, RT_WANT2P >> 8)
    beq_done = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq done     one-player game
    b += asm(0xAD, (OBJ_LIVE + P2_SLOT) & 0xFF, OBJ_LIVE >> 8)   # lda $0457
    bne_run = len(b) + 1
    b += asm(0xD0, 0x00)                    # bne run2     already in the level
    b += asm(0xAD, OBJ_LIVE & 0xFF, OBJ_LIVE >> 8)         # lda $0442
    beq_done2 = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq done     nobody to spawn onto
    b += asm(0xAD, RT_P2CD & 0xFF, RT_P2CD >> 8)
    beq_join = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq join
    b += asm(0xCE, RT_P2CD & 0xFF, RT_P2CD >> 8)           # dec RT_P2CD
    bne_done = len(b) + 1
    b += asm(0xD0, 0x00)                    # bne done
    join = len(b)
    b += asm(0x20, RT_JOIN & 0xFF, RT_JOIN >> 8)
    run2 = len(b)
    b += asm(0x20, RT_SWAP & 0xFF, RT_SWAP >> 8)
    b += asm(0x20, 0x15, 0x8E)              # jsr $8E15    player 2
    b += asm(0x20, RT_SWAP & 0xFF, RT_SWAP >> 8)
    # $B258 makes the player visible again every frame, but only ever for
    # slot 0; player 2 has to have its own "drawn this frame" bit cleared
    attr2 = 0x042C + P2_SLOT
    b += asm(0xAD, attr2 & 0xFF, attr2 >> 8, 0x29, 0x7F,
             0x8D, attr2 & 0xFF, attr2 >> 8)
    done = len(b)
    b += asm(0x60)                          # rts
    b[beq_done]  = rel(beq_done + 1, done)
    b[beq_done2] = rel(beq_done2 + 1, done)
    b[bne_done]  = rel(bne_done + 1, done)
    b[bne_run]   = rel(bne_run + 1, run2)
    b[beq_join]  = rel(beq_join + 1, join)
    return bytes(b)


def swap_code():
    """Exchange everything that says which player is which: the 29 object
    fields, the scalars at $0110-$013F, and the two controllers."""
    b = bytearray()
    b += asm(0xA9, OBJ_BASE & 0xFF, 0x85, 0x00)
    b += asm(0xA9, OBJ_BASE >> 8, 0x85, 0x01)
    b += asm(0xA2, OBJ_N)                   # ldx #29
    lp = len(b)
    b += asm(0xA0, 0x00, 0xB1, 0x00)        # ldy #0   / lda ($00),y
    b += asm(0x48)                          # pha
    b += asm(0xA0, P2_SLOT, 0xB1, 0x00)     # ldy #21  / lda ($00),y
    b += asm(0xA0, 0x00, 0x91, 0x00)        # ldy #0   / sta ($00),y
    b += asm(0x68)                          # pla
    b += asm(0xA0, P2_SLOT, 0x91, 0x00)     # ldy #21  / sta ($00),y
    b += asm(0xA5, 0x00, 0x18, 0x69, 0x16, 0x85, 0x00)
    b += asm(0xA5, 0x01, 0x69, 0x00, 0x85, 0x01)
    b += asm(0xCA)                          # dex
    b += asm(0xD0, rel(len(b) + 2, lp))
    b += asm(0xA2, 0x00)                    # ldx #0
    sc = len(b)
    b += asm(0xBD, SCAL_LO & 0xFF, SCAL_LO >> 8)           # lda $0110,x
    b += asm(0xBC, RT_P2SCAL & 0xFF, RT_P2SCAL >> 8)       # ldy RT_P2SCAL,x
    b += asm(0x9D, RT_P2SCAL & 0xFF, RT_P2SCAL >> 8)       # sta RT_P2SCAL,x
    b += asm(0x98)                                         # tya
    b += asm(0x9D, SCAL_LO & 0xFF, SCAL_LO >> 8)           # sta $0110,x
    b += asm(0xE8, 0xE0, SCAL_N)
    b += asm(0xD0, rel(len(b) + 2, sc))
    b += asm(0xA5, 0x48, 0xA4, 0x49, 0x84, 0x48, 0x85, 0x49)
    b += asm(0xA5, 0x4A, 0xA4, 0x4B, 0x84, 0x4A, 0x85, 0x4B)
    b += asm(0x60)
    return bytes(b)


def join_code():
    """Player 2 enters the level as a copy of player 1 -- same position, same
    suit -- and the same routine puts it back after a death or a stage change."""
    b = bytearray()
    b += asm(0xA9, OBJ_BASE & 0xFF, 0x85, 0x00)
    b += asm(0xA9, OBJ_BASE >> 8, 0x85, 0x01)
    b += asm(0xA2, OBJ_N)
    lp = len(b)
    b += asm(0xA0, 0x00, 0xB1, 0x00)
    b += asm(0xA0, P2_SLOT, 0x91, 0x00)
    b += asm(0xA5, 0x00, 0x18, 0x69, 0x16, 0x85, 0x00)
    b += asm(0xA5, 0x01, 0x69, 0x00, 0x85, 0x01)
    b += asm(0xCA)
    b += asm(0xD0, rel(len(b) + 2, lp))
    b += asm(0xA2, 0x00)
    sc = len(b)
    b += asm(0xBD, SCAL_LO & 0xFF, SCAL_LO >> 8)
    b += asm(0x9D, RT_P2SCAL & 0xFF, RT_P2SCAL >> 8)
    b += asm(0xE8, 0xE0, SCAL_N)
    b += asm(0xD0, rel(len(b) + 2, sc))
    b += asm(0xA9, 120, 0x8D, RT_P2CD & 0xFF, RT_P2CD >> 8)
    b += asm(0x60)
    return bytes(b)


def findshot_code():
    """Replaces the player-shot allocator's own scan at $A3F8, which walks X
    upwards with no bound at all and would march straight through player 2's
    slot into the next field table.  Returns X = the free slot, Z set."""
    b = bytearray()
    b += asm(0xA2, 0x01)                    # ldx #1
    lp = len(b)
    b += asm(0xBD, OBJ_BASE & 0xFF, OBJ_BASE >> 8)
    beq = len(b) + 1
    b += asm(0xF0, 0x00)                    # beq found
    b += asm(0xE8, 0xE0, P2_SLOT)           # inx / cpx #21
    b += asm(0xD0, rel(len(b) + 2, lp))
    b += asm(0xA9, 0x01)                    # lda #1   -> Z clear, no slot
    found = len(b)
    b += asm(0x60)
    b[beq] = rel(beq + 1, found)
    return bytes(b)


def boot_code():
    """Runs from $9F00 with the payload bank mapped at $8000.  Copies the
    whole bank down into work RAM and then enters Power Blade 2's reset."""
    body = bytearray()
    body += asm(0xA0, 0x00)             # ldy #0
    body += asm(0x84, 0x00)             # sty $00
    body += asm(0x84, 0x02)             # sty $02
    body += asm(0xA9, 0x80, 0x85, 0x01) # lda #$80 / sta $01
    body += asm(0xA9, 0x60, 0x85, 0x03) # lda #$60 / sta $03
    loop = len(body)
    body += asm(0xB1, 0x00)             # lda ($00),y
    body += asm(0x91, 0x02)             # sta ($02),y
    body += asm(0xC8)                   # iny
    body += asm(0xD0, rel(len(body) + 2, loop))
    body += asm(0xE6, 0x01)             # inc $01
    body += asm(0xE6, 0x03)             # inc $03
    body += asm(0xA5, 0x03, 0xC9, 0x80) # lda $03 / cmp #$80
    body += asm(0xD0, rel(len(body) + 2, loop))
    body += asm(0x4C, PB2_RESET & 0xFF, PB2_RESET >> 8)
    return bytes(body)


def boot_stub():
    """Sits in the fixed bank, reached through the reset vector.

    The write to $A001 comes first and is not optional: on MMC3 the cartridge's
    work RAM is disabled until bit 7 of that register is set, and everything
    PB3 adds lives in that RAM.  Power Blade 2 never needed it, so its reset
    code writes $00 there -- see wram_on_code()."""
    return asm(
        0xA9, 0x80, 0x8D, 0x01, 0xA0,               # lda #$80 / sta $A001
        0xA9, 0x06, 0x8D, 0x00, 0x80,               # lda #$06 / sta $8000
        0xA9, PAYLOAD_BANK, 0x8D, 0x01, 0x80,       # lda #bank / sta $8001
        0x4C, RT_BOOT & 0xFF, (RT_BOOT + 0x2000) >> 8,   # jmp $9F00
    )


def wram_on_code():
    """Replaces `STA $A001` at $E60E, which would switch the work RAM back off
    a few instructions into Power Blade 2's reset.  X is used rather than A
    because the caller goes straight on to wipe RAM with the A it still holds,
    and reloads X itself on the very next instruction."""
    return asm(0xA2, 0x80,              # ldx #$80
               0x8E, 0x01, 0xA0,        # stx $A001
               0x60)                    # rts


# ===========================================================================
# Breakable blocks in converted stages
#
# Power Blade 2's destructible background blocks (object type $0C) need two
# things: the object, which the placement records carry, and the redraw hook
# at $BA42 in bank 13, which substitutes tile $00 for the block's own tile
# while its $3B bit is set -- without it the block grows straight back as soon
# as the camera refills its column.  See work/re/pb2_breakables.md.
#
# $BA42's tables are indexed by $53, the 0..6 stage number, and PB3 puts more
# than seven stages behind that number by adding worlds.  So the hook moves to
# work RAM, where it can pick its table from (world, stage) -- and where the
# tables themselves live, since the hook runs with bank pair 12/13 mapped and
# the level's own bank swapped out.  World 0 is handed straight back to the
# original code, so stock Power Blade 2 behaves exactly as it always did.
# ===========================================================================

def crates_code():
    """Replaces `$BA42`'s head.  Falls through into the original at `$BA51`
    (stage -> `$BAA8`) for world 0 and at `$BA5D` (area -> record list, then
    the record scan) for a converted one."""
    a = Asm(RT_CRATE)
    a.emit(0xA9, 0x00, 0x8D, 0x7A, 0x01)        # lda #$00 / sta $017A
    a.emit(0xA5, 0x79).br(0xD0, 'ret')          # boss stages have no blocks
    a.emit(0xAD, RT_WORLD & 0xFF, RT_WORLD >> 8).br(0xD0, 'conv')
    a.emit(0xA5, 0x53, 0xC9, 0x02).br(0xF0, 'ret')   # stock: not on stage 2
    a.emit(0x4C, 0x51, 0xBA)
    a.label('conv')
    a.emit(0x0A, 0x0A, 0x0A)                    # world * 8 ...
    a.emit(0x38, 0xED, RT_WORLD & 0xFF, RT_WORLD >> 8)   # ... - world = * 7
    a.emit(0x18, 0x65, 0x53)                    # + the stage inside the world
    a.emit(0x0A, 0xA8)
    a.emit(0xB9, RT_CRTAB & 0xFF, RT_CRTAB >> 8, 0x85, 0x10)
    a.emit(0xB9, (RT_CRTAB + 1) & 0xFF, (RT_CRTAB + 1) >> 8, 0x85, 0x11)
    a.emit(0x05, 0x10).br(0xF0, 'ret')          # a stage with no blocks at all
    a.emit(0x4C, 0x5D, 0xBA)
    a.label('ret').emit(0x60)
    return a.done()


def add_crates(img):
    """Point the redraw hook at PB3's own tables.  `set_crates` fills them."""
    code = crates_code()
    pay = bytearray(img.get_prg(PAYLOAD_BANK))
    a = RT_CRATE - WRAM
    assert pay[a:a + len(code)] == bytes(len(code)), "RT_CRATE is not free"
    assert pay[RT_CRTAB - WRAM: RT_CREND - WRAM] == bytes(RT_CREND - RT_CRTAB)
    pay[a:a + len(code)] = code
    img.put_prg(PAYLOAD_BANK, bytes(pay))

    assert img.read(13, 0xBA42, 0xA000, 5) == b'\xA9\x00\x8D\x7A\x01'
    img.patch(13, 0xBA42, 0xA000,
              asm(0x4C, RT_CRATE & 0xFF, RT_CRATE >> 8, 0xEA, 0xEA))
    # the two places the hook jumps back into
    assert img.read(13, 0xBA51, 0xA000, 5) == b'\x0A\xA8\xB9\xA8\xBA'
    assert img.read(13, 0xBA5D, 0xA000, 3) == b'\xA5\x9C\x0A'
    img.crate_pool = RT_CRPOOL
    return img


def set_crates(img, world, node, per_area):
    """Store one converted stage's `$BA42` records, one list per area.

    Each record is the 4 bytes `$BA76` scans: screen index, `$73 & $1E` band,
    tile number, `$3B` mask.  A list is terminated with `$FF`, and areas
    without any block share one terminator."""
    assert 0 <= node < PB3_STAGES and 0 <= world < PB3_WORLDS
    pay = bytearray(img.get_prg(PAYLOAD_BANK))
    pool = img.crate_pool
    def put(addr, data):
        pay[addr - WRAM: addr - WRAM + len(data)] = data

    # $9C can be read one past the stage's last area while an exit is handing
    # over, so the table carries two spare entries
    n = len(per_area) + 2
    tbl, pool = pool, pool + n * 2
    empty = pool
    put(pool, b'\xFF')
    pool += 1
    for i in range(n):
        recs = per_area[i] if i < len(per_area) else ()
        if not recs:
            put(tbl + i * 2, bytes((empty & 0xFF, empty >> 8)))
            continue
        blob = b''.join(bytes(r) for r in recs) + b'\xFF'
        put(pool, blob)
        put(tbl + i * 2, bytes((pool & 0xFF, pool >> 8)))
        pool += len(blob)
    assert pool <= RT_CREND, f"crate records overflow work RAM: ${pool:04X}"
    put(RT_CRTAB + (world * PB3_STAGES + node) * 2, bytes((tbl & 0xFF, tbl >> 8)))
    img.crate_pool = pool
    img.put_prg(PAYLOAD_BANK, bytes(pay))


def add_runtime(img):
    _, pb2_prg, _ = load(PB2)
    b14 = pb2_prg[14 * 0x2000:15 * 0x2000]      # original fixed bank at $C000

    # --- the payload bank, addressed as $6000 once it has been copied -------
    pay = bytearray(b'\x00' * 0x2000)
    def put(addr, data):
        a = addr - WRAM
        assert pay[a:a + len(data)] == bytes(len(data)), \
            f"work-RAM block at ${addr:04X} runs into the next one"
        pay[a:a + len(data)] = data

    put(RT_SETBANK, setbank_code())
    put(RT_AREABANK, areabank_code())
    put(RT_ENTRY, entry_code())
    put(RT_EDGE, edge_code())
    put(RT_PAL, pal_code())
    put(RT_SUITS, suits_code())
    put(RT_ANIM, anim_code())
    put(RT_LOADW, loadw_code())
    put(RT_MAPIN, mapin_code())
    put(RT_MAPLIM, maplim_code())
    put(RT_SETCLR, mask_code(0x5B))
    put(RT_SETSUIT, mask_code(0x56))
    put(RT_NEWGAME, newgame_code())
    put(RT_PLAYERS, players_code())
    put(RT_SWAP, swap_code())
    put(RT_JOIN, join_code())
    put(RT_FINDSHOT, findshot_code())
    put(RT_MENU, menu_code())
    chi, clo, mhi, mlo, stw, stn = menu_tables()
    put(RT_CURHI, chi); put(RT_CURLO, clo)
    put(RT_MRKHI, mhi); put(RT_MRKLO, mlo)
    put(RT_STW, stw);   put(RT_STN, stn)
    put(RT_BOOT, boot_code())

    # the five original tables, widened to PB3_STAGES entries
    for dst, src in ((RT_T1, 0xDE31), (RT_T2, 0xDE3F), (RT_T3, 0xDE4D), (RT_T4, 0xDE5B)):
        put(dst, b14[src - 0xC000: src - 0xC000 + 14])          # 7 words
    # the original values carry a high nibble the engine's #$0F mask threw
    # away; PB3's helper has no mask, so store the banks already masked
    put(RT_PAIR, bytes(b & 0x0F for b in b14[0xDFD8 - 0xC000: 0xDFD8 - 0xC000 + 7]))
    b15 = pb2_prg[15 * 0x2000:16 * 0x2000]
    put(RT_T5, b15[0xE2BC - 0xE000: 0xE2BC - 0xE000 + 14])
    put(RT_T6, b14[0xDE23 - 0xC000: 0xDE23 - 0xC000 + 14])
    put(RT_T7, b15[0xE515 - 0xE000: 0xE515 - 0xE000 + 14])
    # $F0A4 points straight at a byte list rather than at a word, so world 0's
    # entries keep pointing into bank 15, which is still there as bank 63
    put(RT_T8, b15[0xF0A4 - 0xE000: 0xF0A4 - 0xE000 + 14])
    put(RT_NAREA, b14[0xD6CD - 0xC000: 0xD6CD - 0xC000 + 7])
    put(RT_ABANK, bytes([6] * PB3_STAGES))      # stock records all live in 6/7

    for w in range(PB3_WORLDS):
        pay[MW_TABLES - WRAM + w * 0x100: MW_TABLES - WRAM + (w + 1) * 0x100] = \
            pay[RT_T1 - WRAM: RT_T1 - WRAM + 0x100]
        pay[MW_PALETTE - WRAM + w * 0x100: MW_PALETTE - WRAM + w * 0x100 + 0x80] = \
            pay[RT_PALDATA - WRAM: RT_PALDATA - WRAM + 0x80]

    img.put_prg(PAYLOAD_BANK, bytes(pay))

    # --- repoint every instruction that read the originals ------------------
    B15, B14 = 63, 62
    for cpu, new in ((0xE016, RT_T2), (0xE01B, RT_T2 + 1),
                     (0xE02D, RT_T1), (0xE032, RT_T1 + 1),
                     (0xE064, RT_T2), (0xE069, RT_T2 + 1),
                     (0xE07B, RT_T1), (0xE080, RT_T1 + 1),
                     (0xE12B, RT_T3), (0xE130, RT_T3 + 1),
                     (0xE142, RT_T4), (0xE147, RT_T4 + 1),
                     (0xEFBD, RT_T2), (0xEFC2, RT_T2 + 1),
                     (0xE24E, RT_T5), (0xE253, RT_T5 + 1),
                     (0xE3C4, RT_T7), (0xE3C9, RT_T7 + 1),
                     (0xF056, RT_T8), (0xF05B, RT_T8 + 1)):
        assert img.read(B15, cpu, 0xE000, 1) == b'\xB9', hex(cpu)
        img.patch(B15, cpu + 1, 0xE000, bytes((new & 0xFF, new >> 8)))
    for cpu, new in ((0xDDF0, RT_T6), (0xDDF5, RT_T6 + 1),
                     (0xD6C2, RT_NAREA)):
        assert img.read(B14, cpu, 0xC000, 1) == b'\xB9', hex(cpu)
        img.patch(B14, cpu + 1, 0xC000, bytes((new & 0xFF, new >> 8)))

    # The level's own tables travel with it, so map its bank and not the stock
    # pair 6/7: at $DDE1 where the three collision pointers are fetched, at
    # $DCC3/$F4EA where they are dereferenced, at $E3B5 where the stage is
    # opened, and at $E42E, which is the map that precedes the object-placement
    # scan at $E442 -- leave that one alone and the scan reads spawn records out
    # of Power Blade 2's bank 6 and hands the spawner a garbage type byte.
    # The remaining `LDY #$36` sites really do want pair 6/7 and stay as they are.
    for bank, cpu, base in ((B14, 0xDDE1, 0xC000), (B14, 0xDCC3, 0xC000),
                            (B15, 0xF4EA, 0xE000), (B15, 0xE3B5, 0xE000),
                            (B15, 0xE42E, 0xE000)):
        assert img.read(bank, cpu, base, 5) == b'\xA0\x36\x20\xA7\xEC', hex(cpu)
        img.patch(bank, cpu, base,
                  asm(0x20, RT_AREABANK & 0xFF, RT_AREABANK >> 8, 0xEA, 0xEA))

    # $ECC7/$ECDF put the saved bank back through the #$0F mask, which turns
    # a level living in bank 18 into bank 2 the moment anything -- the
    # collision classifier at $DCBF, say -- borrows the mapper mid-fill.
    assert img.read(B15, 0xECC7, 0xE000, 5) == b'\xA4\x40\x4C\xAB\xEC'
    img.patch(B15, 0xECC7, 0xE000,
              asm(0xA5, 0x40, 0x4C, RT_SETBANK_NS & 0xFF, RT_SETBANK_NS >> 8))
    assert img.read(B15, 0xECDF, 0xE000, 5) == b'\xA4\x41\x20\xAB\xEC'
    img.patch(B15, 0xECDF, 0xE000,
              asm(0xA5, 0x41, 0x20, RT_SETBANK_NS & 0xFF, RT_SETBANK_NS >> 8))

    # $F060: the entry byte lives in the level bank, so map it around the read
    assert img.read(B15, 0xF060, 0xE000, 4) == b'\xA4\x9C\xB1\x00'
    img.patch(B15, 0xF060, 0xE000,
              asm(0x20, RT_ENTRY & 0xFF, RT_ENTRY >> 8, 0xEA))

    # $F497: a probe outside the area used to walk off the end of the level
    assert img.read(B15, 0xF497, 0xE000, 4) == b'\xB1\x35\x0A\xA8'
    img.patch(B15, 0xF497, 0xE000,
              asm(0x20, RT_EDGE & 0xFF, RT_EDGE >> 8, 0xEA))

    # $E23F: pick the area-record bank per stage instead of always 6/7
    assert img.read(B15, 0xE23F, 0xE000, 5) == b'\xA0\x36\x20\xA7\xEC'
    img.patch(B15, 0xE23F, 0xE000,
              asm(0x20, RT_AREABANK & 0xFF, RT_AREABANK >> 8, 0xEA, 0xEA))

    # $DFC9's tail: read the pair table from RAM and use the unmasked helper
    assert img.read(B14, 0xDFD1, 0xC000, 7) == b'\xB9\xD8\xDF\xA8\x4C\xA7\xEC'
    img.patch(B14, 0xDFD1, 0xC000,
              asm(0xB9, RT_PAIR & 0xFF, RT_PAIR >> 8,          # lda $6180,y
                  0x4C, RT_SETBANK & 0xFF, RT_SETBANK >> 8,    # jmp $6000
                  0xEA))                                       # nop

    # every Power Suit, from the first frame of every stage
    assert img.read(B15, 0xEFD4, 0xE000, 3) == b'\x4C\xF1\xD8'
    img.patch(B15, 0xEFD4, 0xE000,
              asm(0x4C, RT_SUITS & 0xFF, RT_SUITS >> 8))

    # the animated-background picker, through bank pair 4's jump island
    assert img.read(4, 0x8018, 0x8000, 3) == b'\x4C\xC9\xBE'
    img.patch(4, 0x8018, 0x8000, asm(0x4C, RT_ANIM & 0xFF, RT_ANIM >> 8))

    # the palette builder is reached through bank pair 0's jump island
    assert img.read(0, 0x801B, 0x8000, 3) == b'\x4C\x44\x80'
    img.patch(0, 0x801B, 0x8000, asm(0x4C, RT_PAL & 0xFF, RT_PAL >> 8))

    # --- the map screen, now sixteen stages deep ---------------------------
    assert img.read(0, 0x871E, 0x8000, 3) == b'\x20\x37\xC8'
    img.patch(0, 0x871E, 0x8000, asm(0x20, RT_MENU & 0xFF, RT_MENU >> 8))
    scr = menu_screen()
    img.put_prg(MENU_BANK, scr + b'\x00' * (0x2000 - len(scr)))
    assert img.read(0, 0x874D, 0x8000, 6) == b'\xA5\x5B\xC9\x0F\xD0\x07'
    img.patch(0, 0x874D, 0x8000,
              asm(0x20, RT_MAPLIM & 0xFF, RT_MAPLIM >> 8,
                  0x90, 0x0F,             # bcc $8761   (inc $22)
                  0x60))
    assert img.read(0, 0x9832, 0x8000, 3) == b'\x4C\x13\xC8'
    img.patch(0, 0x9832, 0x8000, asm(0x4C, RT_NEWGAME & 0xFF, RT_NEWGAME >> 8))
    assert img.read(11, 0xBE22, 0xA000, 2) == b'\xA4\x53'
    img.patch(11, 0xBE22, 0xA000, asm(0x4C, RT_SETCLR & 0xFF, RT_SETCLR >> 8))
    assert img.read(11, 0xBE2C, 0xA000, 2) == b'\xA4\x53'
    img.patch(11, 0xBE2C, 0xA000, asm(0x4C, RT_SETSUIT & 0xFF, RT_SETSUIT >> 8))

    # --- two players at once -----------------------------------------------
    # the one place the engine updates the player
    assert img.read(8, 0x8000, 0x8000, 3) == b'\x4C\x15\x8E'
    img.patch(8, 0x8000, 0x8000, asm(0x4C, RT_PLAYERS & 0xFF, RT_PLAYERS >> 8))
    # the player's shots take the first free slot from 1 upwards, with no
    # upper bound at all -- they must now stop below player 2's
    assert img.read(9, 0xA3F6, 0xA000, 12) == \
        b'\xA2\x01\xBD\x00\x04\xF0\x03\xE8\xD0\xF8\x18\x60'
    img.patch(9, 0xA3F6, 0xA000,
              asm(0x20, RT_FINDSHOT & 0xFF, RT_FINDSHOT >> 8,
                  0xF0, 0x05,               # beq $A400   (carry clear, found)
                  0x38, 0x60,               # sec / rts   (none free)
                  0xEA, 0xEA, 0xEA))

    # --- boot: the reset vector now runs the stub, which loads work RAM -----
    stub, on = boot_stub(), wram_on_code()
    assert BOOT_STUB + len(stub) <= WRAM_ON and WRAM_ON + len(on) <= 0xFFF4
    assert img.read(B15, BOOT_STUB, 0xE000, 24) == b'\x00' * 24
    img.patch(B15, BOOT_STUB, 0xE000, stub)
    img.patch(B15, WRAM_ON, 0xE000, on)
    assert img.read(B15, 0xE60E, 0xE000, 3) == b'\x8D\x01\xA0'
    img.patch(B15, 0xE60E, 0xE000, asm(0x20, WRAM_ON & 0xFF, WRAM_ON >> 8))
    img.patch(B15, 0xFFFC, 0xE000, bytes((BOOT_STUB & 0xFF, BOOT_STUB >> 8)))

    # --- breakable background blocks in converted stages -------------------
    add_crates(img)
    return img


# ===========================================================================
# Solbrain levels, converted into Power Blade 2's format and dropped into
# their own bank pair.
# ===========================================================================

def add_level(img, blob, bank):
    """Place a packed level ($8000-based) into `bank`/`bank+1`."""
    data = bytes(blob) + b'\xFF' * (0x4000 - len(blob))
    assert len(blob) <= 0x4000, len(blob)
    img.put_prg(bank, data[:0x2000])
    img.put_prg(bank + 1, data[0x2000:0x4000])


def set_area_count(img, world, node, n):
    """$D6BC asks whether the area just left was the stage's last; the answer
    used to come from a seven-byte table in the fixed bank.  A converted stage
    has its own count, and it is deliberately one more than the highest area an
    exit can reach, so the last area simply has no exit rather than falling
    into Power Blade 2's boss stage."""
    pay = bytearray(img.get_prg(PAYLOAD_BANK))
    a = RT_NAREA + world * 0x100 - RT_T1 + MW_TABLES - WRAM + node
    pay[a] = n
    img.put_prg(PAYLOAD_BANK, bytes(pay))


def set_stage(img, world, node, bank, base=0x8000):
    """Point world `world`'s stage `node` at the level living in `bank`/`bank+1`."""
    assert 0 <= node < PB3_STAGES and 0 <= world < PB3_WORLDS
    pay = bytearray(img.get_prg(PAYLOAD_BANK))
    page = MW_TABLES + world * 0x100 - RT_T1        # master pages mirror $6100
    def put(addr, data):
        a = addr + page - WRAM
        pay[a: a + len(data)] = data
    for i, t in enumerate((RT_T1, RT_T2, RT_T3, RT_T4)):
        a = base + i * 2                      # the header word in the level bank
        put(t + node * 2, bytes((a & 0xFF, a >> 8)))
    put(RT_T5 + node * 2, bytes(((base + 8) & 0xFF, (base + 8) >> 8)))
    put(RT_T6 + node * 2, bytes(((base + 10) & 0xFF, (base + 10) >> 8)))
    put(RT_T7 + node * 2, bytes(((base + 12) & 0xFF, (base + 12) >> 8)))
    # $F04C reads this one with a single indirection, so it is the address of
    # the entry list itself -- pb2_pack puts that right behind the header
    put(RT_T8 + node * 2, bytes(((base + 16) & 0xFF, (base + 16) >> 8)))
    put(RT_PAIR + node, bytes((bank,)))
    put(RT_ABANK + node, bytes((bank,)))
    put(RT_CONV + node, b'\x01')
    img.put_prg(PAYLOAD_BANK, bytes(pay))


def set_palette(img, world, node, bg16):
    """Store one converted stage's four background palettes; the area record
    then asks for it with $016D = $80 | node."""
    assert len(bg16) == 16, len(bg16)
    pay = bytearray(img.get_prg(PAYLOAD_BANK))
    a = MW_PALETTE + world * 0x100 - WRAM + node * 16
    pay[a:a + 16] = bytes(bg16)
    img.put_prg(PAYLOAD_BANK, bytes(pay))


# ===========================================================================
# The PB3 front-end
#
# Power Blade 2's map screen is a five-node ride with its own rules about
# which node is open; it cannot show sixteen stages and it has nowhere to ask
# how many players there are.  So the map state's idle handler is replaced by
# a screen of PB3's own: a plain list, drawn with the status bar's font, that
# also carries the player-count and hero choices.  Nothing in the map code is
# removed -- only the one JSR that used to poll it.
# ===========================================================================

MENU_LIST = [("POWER BLADE  %d" % (i + 1), 0, i) for i in range(7)] + \
            [("SOLBRAIN     %d" % (i + 1), 1, i) for i in range(5)] + \
            [("SOLBRAIN     %d" % (i + 6), 2, i) for i in range(4)]

MENU_TOP    = 11            # first stage line
MENU_CURCOL = 5
MENU_TXTCOL = 7
MENU_OPTROW = (5, 7)        # players, hero
MENU_MARK   = ((5, 16), (5, 22), (7, 14), (7, 21))
MENU_PAL    = bytes((0x0F, 0x16, 0x21, 0x30)) * 8


def font_byte(c):
    if c == ' ':  return 0x00
    if c == '.':  return 0x2A
    if c == '/':  return 0x2E
    if 'A' <= c <= 'Z': return ord(c) - 64
    if '0' <= c <= '9': return 0x20 + ord(c) - 48
    raise ValueError(c)


def menu_screen():
    """1024 bytes of nametable + attributes, then 32 bytes of palette."""
    nt = bytearray(0x400)
    def text(row, col, msg):
        for i, c in enumerate(msg):
            nt[row * 32 + col + i] = font_byte(c)
    text(3, 13, 'P B 3')
    text(5, 7, 'PLAYERS')
    text(5, 17, '1P')
    text(5, 23, '2P')
    text(7, 7, 'HERO')
    text(7, 15, 'BLADE')
    text(7, 22, 'SOLBRAIN')
    text(9, 9, 'SELECT STAGE')
    for i, (label, _, _) in enumerate(MENU_LIST):
        text(MENU_TOP + i, MENU_TXTCOL, label)
    return bytes(nt) + MENU_PAL


def menu_tables():
    """The four little lookup tables the menu code indexes."""
    rows = list(MENU_OPTROW) + [MENU_TOP + i for i in range(len(MENU_LIST))]
    assert len(rows) == MENU_ROWS
    addr = [0x2000 + r * 32 + MENU_CURCOL for r in rows]
    mark = [0x2000 + r * 32 + c for r, c in MENU_MARK]
    return (bytes(a >> 8 for a in addr), bytes(a & 0xFF for a in addr),
            bytes(a >> 8 for a in mark), bytes(a & 0xFF for a in mark),
            bytes(w for _, w, _ in MENU_LIST), bytes(n for _, _, n in MENU_LIST))


class Asm:
    """A one-screen assembler with labels, so the menu can be written as code
    instead of as hand-counted branch offsets."""

    def __init__(self, org):
        self.org = org
        self.b = bytearray()
        self.lab = {}
        self.fix = []          # (offset, label, kind)

    def emit(self, *v):
        self.b += asm(*v); return self

    def label(self, n):
        self.lab[n] = self.org + len(self.b); return self

    def br(self, op, n):
        self.b += asm(op, 0x00)
        self.fix.append((len(self.b) - 1, n, 'rel')); return self

    def jump(self, op, n):
        self.b += asm(op, 0x00, 0x00)
        self.fix.append((len(self.b) - 2, n, 'abs')); return self

    def done(self):
        for off, n, kind in self.fix:
            t = self.lab[n]
            if kind == 'rel':
                self.b[off] = rel(self.org + off + 1, t)
            else:
                self.b[off] = t & 0xFF; self.b[off + 1] = t >> 8
        return bytes(self.b)


def menu_code():
    a = Asm(RT_MENU)
    PPUCTRL, PPUMASK, PPUADDR, PPUDATA, PPUSCROLL = 0x2000, 0x2001, 0x2006, 0x2007, 0x2005
    PPUSTATUS = 0x2002

    # --- take the screen over ------------------------------------------
    a.emit(0x78)                                    # sei
    a.emit(0xA9, 0x00, 0x8D, 0x00, 0xE0)            # MMC3 IRQ off -- its
    a.emit(0xA9, 0x00, 0x8D, 0x00, 0x20)            # ... handler owns the CHR
                                                    # banks and would take the
                                                    # font back mid-frame
    a.emit(0x2C, 0x02, 0x20).label('vb')
    a.emit(0x2C, 0x02, 0x20).br(0x10, 'vb')
    a.emit(0xA9, 0x00, 0x8D, 0x01, 0x20)            # rendering off
    # the status bar's font, as two 2 KB CHR banks at $0000
    a.emit(0xA9, 0x00, 0x8D, 0x00, 0x80, 0xA9, FONT_BANK, 0x8D, 0x01, 0x80)
    a.emit(0xA9, 0x01, 0x8D, 0x00, 0x80, 0xA9, FONT_BANK + 2, 0x8D, 0x01, 0x80)
    # nametable + attributes, straight out of the menu's own bank
    a.emit(0xA9, MENU_BANK, 0x20, RT_SETBANK & 0xFF, RT_SETBANK >> 8)
    a.emit(0xA9, 0x20, 0x8D, 0x06, 0x20, 0xA9, 0x00, 0x8D, 0x06, 0x20)
    a.emit(0xA9, 0x00, 0x85, 0x00, 0xA9, 0x80, 0x85, 0x01)
    a.emit(0xA2, 0x04, 0xA0, 0x00)
    a.label('cp').emit(0xB1, 0x00, 0x8D, 0x07, 0x20, 0xC8).br(0xD0, 'cp')
    a.emit(0xE6, 0x01, 0xCA).br(0xD0, 'cp')
    a.emit(0xA9, 0x3F, 0x8D, 0x06, 0x20, 0xA9, 0x00, 0x8D, 0x06, 0x20)
    a.emit(0xA0, 0x00)
    a.label('pl').emit(0xB9, 0x00, 0x84, 0x8D, 0x07, 0x20, 0xC8, 0xC0, 0x20)
    a.br(0xD0, 'pl')
    a.emit(0xA9, 0x00, 0x20, RT_SETBANK_NS & 0xFF, RT_SETBANK_NS >> 8)
    a.emit(0xA9, 0x02, 0x8D, RT_CUR & 0xFF, RT_CUR >> 8)
    a.emit(0xA9, 0x0A, 0x8D, 0x01, 0x20)            # show the background
    a.emit(0xA9, MENU_CUR).jump(0x20, 'cursor')
    a.jump(0x20, 'markdraw')

    # --- one pass per frame --------------------------------------------
    a.label('main')
    a.emit(0x2C, 0x02, 0x20)
    a.label('w2').emit(0x2C, 0x02, 0x20).br(0x10, 'w2')
    a.emit(0x20, 0xB0, 0xEB)                        # read both pads
    a.emit(0xA5, 0x48, 0x05, 0x49, 0x85, 0x02)      # either one drives the menu

    a.emit(0xA5, 0x02, 0x29, 0x08).br(0xF0, 'noup')     # UP
    a.emit(0xA9, 0x00).jump(0x20, 'cursor')
    a.emit(0xCE, RT_CUR & 0xFF, RT_CUR >> 8).br(0x10, 'upok')
    a.emit(0xA9, MENU_ROWS - 1, 0x8D, RT_CUR & 0xFF, RT_CUR >> 8)
    a.label('upok').emit(0xA9, MENU_CUR).jump(0x20, 'cursor')
    a.label('noup')

    a.emit(0xA5, 0x02, 0x29, 0x04).br(0xF0, 'nodn')     # DOWN
    a.emit(0xA9, 0x00).jump(0x20, 'cursor')
    a.emit(0xEE, RT_CUR & 0xFF, RT_CUR >> 8)
    a.emit(0xAD, RT_CUR & 0xFF, RT_CUR >> 8, 0xC9, MENU_ROWS).br(0xD0, 'dnok')
    a.emit(0xA9, 0x00, 0x8D, RT_CUR & 0xFF, RT_CUR >> 8)
    a.label('dnok').emit(0xA9, MENU_CUR).jump(0x20, 'cursor')
    a.label('nodn')

    a.emit(0xA5, 0x02, 0x29, 0x03).br(0xF0, 'nolr')     # LEFT or RIGHT
    a.emit(0xAD, RT_CUR & 0xFF, RT_CUR >> 8).br(0xD0, 'chk1')
    a.emit(0xAD, RT_WANT2P & 0xFF, RT_WANT2P >> 8, 0x49, 0x01,
           0x8D, RT_WANT2P & 0xFF, RT_WANT2P >> 8).jump(0x4C, 'marks')
    a.label('chk1').emit(0xC9, 0x01).br(0xD0, 'nolr')
    a.emit(0xAD, RT_HERO & 0xFF, RT_HERO >> 8, 0x49, 0x01,
           0x8D, RT_HERO & 0xFF, RT_HERO >> 8)
    a.label('marks').jump(0x20, 'markdraw')
    a.label('nolr')

    a.emit(0xA5, 0x02, 0x29, 0x10).br(0xF0, 'nost')     # START
    a.emit(0xAD, RT_CUR & 0xFF, RT_CUR >> 8, 0xC9, 0x02).br(0x90, 'nost')
    a.emit(0x38, 0xE9, 0x02, 0xAA)
    a.emit(0xBD, RT_STW & 0xFF, RT_STW >> 8,
           0x8D, RT_WORLD & 0xFF, RT_WORLD >> 8)
    a.emit(0xBD, RT_STN & 0xFF, RT_STN >> 8, 0x85, 0x22)
    a.emit(0x20, RT_LOADW & 0xFF, RT_LOADW >> 8)
    # wipe the menu out of the nametable before handing back.  The map screen's
    # tail animates over whatever is already there, and what is already there is
    # the stage list -- so without this the player watches half a map screen
    # scribble itself over the menu for a second and a half.
    a.emit(0xA9, 0x00, 0x8D, 0x01, 0x20)            # rendering off
    a.emit(0xA9, 0x20, 0x8D, 0x06, 0x20, 0xA9, 0x00, 0x8D, 0x06, 0x20)
    a.emit(0xA2, 0x04, 0xA0, 0x00, 0xA9, 0x00)
    a.label('wipe').emit(0x8D, 0x07, 0x20, 0xC8).br(0xD0, 'wipe')
    a.emit(0xCA).br(0xD0, 'wipe')
    a.emit(0xA9, 0xA8, 0x8D, 0x00, 0x20)            # hand the NMI back
    a.emit(0xA9, 0x1C, 0x8D, 0x01, 0x20)
    a.emit(0x58)                                    # cli
    a.emit(0x68, 0x68)                              # drop the return to $8721
    # $8735 is the map's own "this node was chosen" tail, entered past the
    # check that decides whether the node is open yet
    a.emit(0x4C, 0x35, 0x87)
    a.label('nost')

    a.emit(0xA9, 0x00, 0x8D, 0x05, 0x20, 0x8D, 0x05, 0x20)
    a.jump(0x4C, 'main')

    # --- drawing -------------------------------------------------------
    a.label('cursor')
    a.emit(0xAE, RT_CUR & 0xFF, RT_CUR >> 8)
    a.emit(0xBC, RT_CURHI & 0xFF, RT_CURHI >> 8, 0x8C, 0x06, 0x20)
    a.emit(0xBC, RT_CURLO & 0xFF, RT_CURLO >> 8, 0x8C, 0x06, 0x20)
    a.emit(0x8D, 0x07, 0x20, 0x60)

    a.label('markdraw')
    a.emit(0xAD, RT_WANT2P & 0xFF, RT_WANT2P >> 8).br(0xD0, 'two')
    a.emit(0xA2, 0x00).jump(0x20, 'show')
    a.emit(0xA2, 0x01).jump(0x20, 'blank').jump(0x4C, 'hero')
    a.label('two')
    a.emit(0xA2, 0x00).jump(0x20, 'blank')
    a.emit(0xA2, 0x01).jump(0x20, 'show')
    a.label('hero')
    a.emit(0xAD, RT_HERO & 0xFF, RT_HERO >> 8).br(0xD0, 'sol')
    a.emit(0xA2, 0x02).jump(0x20, 'show')
    a.emit(0xA2, 0x03).jump(0x4C, 'blank')
    a.label('sol')
    a.emit(0xA2, 0x02).jump(0x20, 'blank')
    a.emit(0xA2, 0x03).jump(0x4C, 'show')

    a.label('blank').emit(0xA9, 0x00).br(0xF0, 'mput')
    a.label('show').emit(0xA9, MENU_CUR)
    a.label('mput')
    a.emit(0xBC, RT_MRKHI & 0xFF, RT_MRKHI >> 8, 0x8C, 0x06, 0x20)
    a.emit(0xBC, RT_MRKLO & 0xFF, RT_MRKLO >> 8, 0x8C, 0x06, 0x20)
    a.emit(0x8D, 0x07, 0x20, 0x60)
    return a.done()
