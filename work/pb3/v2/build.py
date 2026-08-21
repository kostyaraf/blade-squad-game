#!/usr/bin/env python3
"""PB3 ver2 -- the cartridge, built on Tokkyuu Shirei Solbrain's engine.

Why this engine: `docs/engine_choice.md`.  Short version -- Solbrain's level
format holds every Power Blade 2 level without loss, the reverse holds 19 %,
and Solbrain's player is a private 50-byte block outside the object pool, which
is what makes a second player affordable.

Layout.  The image grows to 256 KB of PRG so there is room for new code and,
later, for both games' levels.  MMC3 fixes the last two banks, so Solbrain's
banks 14 and 15 move to physical 30 and 31 and everything else stays where it
was; banks 16..29 are new.  Bank 16 holds the co-op runtime, which the boot
code copies into the cartridge's work RAM at $6000 -- work RAM the original
game never touches (measured: zero accesses in 6000 frames), and which is
mapped no matter which PRG bank is live, so a hook in it can be called from
anywhere.
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
sys.path.insert(0, HERE)
from asm import Asm
import novachr

SRC = os.path.join(ROOT, 'Tokkyuu Shirei Solbrain (Japan).nes')
OUT = os.path.join(ROOT, 'work/build/PB3.nes')

HDR   = 16
BANK  = 0x2000
NBANK = 32                      # 256 KB of PRG
RTBANK = 16                     # the co-op runtime's home bank

# --- work RAM map -----------------------------------------------------------
WRAM   = 0x6000
P2_BLK = 0x7F00                 # shadow of the player block $05A2-$05CE
P2_POS = 0x7F30                 # shadow of the world position $80-$83
P2_SPD = 0x7F34                 # shadow of the horizontal speed $35
P2_ON  = 0x7F35                 # second player present and initialised
SV_POS = 0x7F36                 # scratch: player one's position, while the
SV_DSP = 0x7F3A                 # camera is temporarily fed the pair's midpoint
TMP    = 0x7F3E                 # scratch: a 16-bit bound, for the screen clamp
TMP2   = 0x7F40                 # scratch: a second 16-bit distance
TMP3   = 0x7F4E                 # scratch: the better distance so far
NEARF  = 0x7F42                 # one byte per enemy slot: is player two nearer?
DOWN   = 0x7F50                 # per player: out of health and waiting
TMR    = 0x7F52                 # per player: frames until he is put back
CUR    = 0x7F54                 # which of the two `onep` is running for
P2JOIN = 0x7F55                 # pad two has pressed start at least once
SPAWN  = 0x7F60                 # a pristine copy of a standing player, 45 bytes
TILEADD= 0x7F56                 # added to every sprite tile the engine emits
P1BANK = 0x7F57                 # player one's sprite CHR bank, kept over the
                                # frame while player two overwrites the shadow
HERO1  = 0x7F58                 # 0 = this game's hero, 1 = the other game's
HERO2  = 0x7F59
LABDY  = 0x7F5A                 # scratch: which row a select-screen label is on
# SPAWN is 45 bytes, so everything below it starts past $7F8C.
SUIT   = 0x7F90                 # Power Blade suit, 0-4, one byte per player
ENE    = 0x7F92                 # the energy bar, 0-16, one byte per player
EACC   = 0x7F94                 # 16-bit drain accumulator, two per player
GUN    = 0x7F98                 # the Solbrain sub-weapon: 0 = none, 1-8 (shared)
MOPEN  = 0x7F99                 # the in-game menu is up
MROW   = 0x7F9A                 # which line it is on, one per pad
OAMP   = 0x7F9B                 # where our own sprites go in the OAM buffer
MDROP  = 0x7F9C                 # per player: the suit just ran out of energy
TX     = 0x7F9E                 # the text writer's cursor and its arguments
TY     = 0x7F9F
TN     = 0x7FA0
TATTR  = 0x7FA1
PADT   = 0x7FA2
PFLAG  = 0x7FA3                 # the sprite just written is player two's own
MCLR   = 0x7FA4                 # wipe the menu's sprites on the frame it closes

# --- the engine, as far as the runtime needs to know it ---------------------
SYMS = {
    'PLAYER':   0x9159,         # bank 12: one player update
    'PL_STATE': 0x05A2,         # state index into the dispatch table at $96C0
    'PL_BLK':   0x05A2,         # the player's whole object, 45 bytes
    'PL_POS':   0x0080,         # world position, 12.4 fixed point, 4 bytes
    'PL_SPD':   0x0035,         # horizontal speed -- the one byte outside PL_BLK
    'PAD1_P':   0x0004,         # pad 1, newly pressed
    'PAD2_P':   0x0005,
    'PAD1_H':   0x0006,         # pad 1, held
    'PAD2_H':   0x0007,
    'PL_DSP':   0x05B6,         # this frame's displacement, X then Y, 16-bit
    'CAM_X':    0x0030,         # camera, same 12.4 units as the world position
    'CAM_Y':    0x0032,
    'CAM_XF':   0xF1EA,         # engine: move the camera after the player, X
    'CAM_YF':   0xF24B,         # ... and Y
    'RESET':    0xF8F8,
    'P2_BLK':   P2_BLK, 'P2_POS': P2_POS, 'P2_SPD': P2_SPD, 'P2_ON': P2_ON,
    'SV_POS':   SV_POS, 'SV_DSP': SV_DSP, 'TMP': TMP, 'TMP2': TMP2,
    'NEARF':    NEARF, 'TMP3': TMP3, 'P2JOIN': P2JOIN, 'SPAWN': SPAWN,
    'TILEADD':  TILEADD, 'P1BANK': P1BANK,
    'CHR_R2':   0x0042,         # shadow of the MMC3 1K bank at $1000 -- the
                                # player's own sprite art, swapped per pose
    'CHR_R3':   0x0043,         # shadow of the bank at $1400: tiles $40-$7F
    'CHR_R4':   0x0044,         # shadow of the bank at $1800: tiles $80-$BF
    'MODE':     0x0002,         # which screen the game is on; $05 = the title
    'OAM':      0x0200,         # the buffer that is sent to the PPU each frame
    'PALBUF':   0x0110,
    'HERO1':    HERO1, 'HERO2': HERO2, 'LABDY': LABDY,
    'SUIT':     SUIT, 'ENE': ENE, 'EACC': EACC, 'GUN': GUN,
    'MOPEN':    MOPEN, 'MROW': MROW, 'OAMP': OAMP, 'MDROP': MDROP,
    'TX':       TX, 'TY': TY, 'TN': TN, 'TATTR': TATTR, 'PADT': PADT,
    'PFLAG':    PFLAG, 'MCLR': MCLR,
    'OAM_A1':   0x0202,         # the attribute byte that goes with each tile
    'OAM_A2':   0x01FF,
    'CHR_R5':   0x0045,         # shadow of the bank at $1C00: tiles $C0-$FF,
                                # which the game never uses in a level
    'SAT_TYPE': 0x060C,         # the satellite's object type = the weapon ID
    'SAT_MAKE': 0x9310,         # bank 12: build the satellite, X = weapon index
    'SAT_IDX':  0x065C,
    'PL_PWR':   0x05C8,         # the engine's own double-damage flag
    'OAM_T1':   0x0201,         # the three places the engine stores a tile
    'OAM_T2':   0x01FE,
    'OBJ_YL':   0x00C0, 'OBJ_YH': 0x00D0, 'DOWN': DOWN, 'TMR': TMR, 'CUR': CUR,
    'PL_HP':    0x05C5,         # the health bar, eight units
    'PL_INV':   0x05A3,         # invulnerability countdown; >= $70 = untouchable
    'OBJ_XL':   0x00A0,         # object X, low byte then high, 12 slots + 4
    'OBJ_XH':   0x00B0,
    'OBJ_TYPE': 0x0600,
    'ENEMIES':  0xCE1D,         # engine: update all twelve enemy slots
    'ENEMY1':   0xCE26,         # engine: update one, X = slot
    'P2_DSP':   P2_BLK + 0x05B6 - 0x05A2,
}
PL_BLK_LEN = 45
RESPAWN_DX = 0x0200             # 32 px, so a respawn is not on top of him
RESPAWN = 120                   # frames a downed player sits out
MARGIN = 0x100                  # 16 px of screen edge the players cannot cross


def load():
    rom = bytearray(open(SRC, 'rb').read())
    assert rom[:4] == b'NES\x1a' and rom[4] == 8 and rom[5] == 16, rom[:8].hex()
    prg = rom[HDR:HDR + 8 * 0x4000]
    chr_ = rom[HDR + 8 * 0x4000:]
    return rom[:HDR], prg, chr_


class Image:
    """The PB3 cartridge under construction: 32 PRG banks addressed by their
    new physical numbers, with `where()` translating an original Solbrain bank
    into its new home."""

    MOVED = {14: 30, 15: 31}

    def __init__(self):
        hdr, prg, chr_ = load()
        self.chr = bytearray(chr_)
        self.prg = bytearray(b'\xFF' * (NBANK * BANK))
        for b in range(16):
            self.prg[self.where(b) * BANK:(self.where(b) + 1) * BANK] = \
                prg[b * BANK:(b + 1) * BANK]
        self.hdr = bytearray(hdr)
        self.hdr[4] = NBANK // 2            # 16 units of 16 KB
        self.hdr[10] = 7                    # 64 << 7 = 8 KB of work RAM
        self.used = {}                      # bank -> [(start, end, name)]

    @classmethod
    def where(cls, bank):
        return cls.MOVED.get(bank, bank)

    def off(self, bank, cpu):
        """File offset of a CPU address inside an *original* Solbrain bank."""
        base = {14: 0xC000, 15: 0xE000}.get(bank,
                0x8000 if bank % 2 == 0 else 0xA000)
        assert base <= cpu < base + BANK, hex(cpu)
        return self.where(bank) * BANK + (cpu - base)

    def poke(self, bank, cpu, data, name='patch'):
        o = self.off(bank, cpu)
        self.prg[o:o + len(data)] = data
        self.used.setdefault(bank, []).append((cpu, cpu + len(data), name))

    def free(self, bank, cpu, data, name):
        """Write into padding, refusing if it is not padding after all."""
        o = self.off(bank, cpu)
        assert set(self.prg[o:o + len(data)]) <= {0xFF}, \
            'not free: bank %d $%04X' % (bank, cpu)
        self.poke(bank, cpu, data, name)

    def add_chr(self, banks, first):
        """Drop new 1K CHR banks in, padding the ROM out to a power of two so
        no emulator has to guess how to mask a bank number."""
        need = (first + len(banks)) * 1024
        size = 0x2000
        while size < need:
            size *= 2
        self.chr += bytearray(size - len(self.chr))
        for i, b in enumerate(banks):
            o = (first + i) * 1024
            self.chr[o:o + 1024] = b
        self.hdr[5] = len(self.chr) // 0x2000

    def save(self, path=OUT):
        open(path, 'wb').write(bytes(self.hdr) + bytes(self.prg) + bytes(self.chr))
        return len(self.hdr) + len(self.prg) + len(self.chr)


# ===========================================================================
# The co-op runtime.  Lives at $6000 in work RAM.
# ===========================================================================

def runtime(mapping=None):
    """Two players sharing one player update.

    The engine calls the player exactly once a frame, from `12:$9150`.  That
    call is redirected here, and here it happens twice: once on the live
    context and once with the second player's context swapped in.  The whole
    of a Solbrain player is 45 contiguous bytes plus a 4-byte world position
    plus one speed byte, and nothing else in the engine writes them, so an
    exchange is all it takes -- see work/re/sol_two_players.md.
    """
    src = """
; --- entry: replaces `JSR PLAYER` at bank 12 $9150 -------------------------
hook:   lda MOPEN               ; the menu is up: nothing in the level moves
        beq h_live
        rts
h_live: lda PL_STATE            ; states $12/$13 are the warp-in: a level has
        cmp #$12                ; just started or restarted, so player two is
        bcc h_run               ; built again from player one when he lands
        lda #0
        sta P2_ON
        sta DOWN+0
        sta DOWN+1
        lda #$10                ; a level always starts on a full bar
        sta ENE+0
        sta ENE+1
h_run:  jsr gunkeep
        lda P2_ON
        bne h_two
        lda #0                  ; alone: the original behaviour, except that
        sta TILEADD             ; a lone player may still be the other hero
        sta CUR
        jsr PLAYER
        jsr chrslot
        ldx #0
        jsr drain
        ldx #0
        jsr suitfx
        ldx #0
        jsr gunfee
        jmp init
h_two:  lda DOWN+0              ; both out of health?  Then stop hiding it and
        and DOWN+1              ; let the engine run its own death sequence on
        beq h_go                ; the live player.
        lda #0
        sta DOWN+0
        sta DOWN+1
        sta PL_HP
        jmp PLAYER
h_go:   ldx #0
        jsr onep
        jsr swap
        ldx #1
        jsr onep
        jsr swap
        lda #0                  ; everything drawn after the pair -- enemies,
        sta TILEADD             ; shots, the HUD -- keeps its own tiles
        rts

; --- gunkeep: the chosen sub-weapon is simply always the one you carry -----
; Solbrain hands out its eight weapons by making you collect three Greek
; letters; here the menu picks one and this puts it back every frame, using
; the engine's own creation routine, so the satellite is built exactly the way
; the original builds it.
gunkeep: lda P2_ON              ; no energy left in the party, no weapon unit
        beq gk_one
        lda ENE+0
        ora ENE+1
        jmp gk_e
gk_one: lda ENE+0
gk_e:   bne gk_have
        lda #$00
        sta SAT_TYPE
        rts
gk_have: lda PL_STATE            ; not while dying or warping in
        cmp #$10
        bcs gk_ret
        lda SAT_TYPE
        cmp #$FF                ; the satellite is in its death animation
        beq gk_ret
        cmp GUN                 ; the type is the weapon's own ID, 1-8
        beq gk_ret
        ldx GUN
        beq gk_none
        dex
        jmp SAT_MAKE
gk_none: sta SAT_TYPE           ; nothing chosen: bare hands, and A is 0 here
gk_ret: rts

; --- one player's frame.  X selects his down flag and respawn timer. --------
; This always runs with that player's context live, so his partner is always
; the shadow -- which is what makes the respawn a straight copy.
onep:   stx CUR
        lda DOWN,x
        bne o_down
        lda #0                  ; player two's sprites are drawn out of the
        cpx #0                  ; next 1K of the sprite pattern table, so his
        beq o_t0                ; art can differ from player one's
        lda #$40
o_t0:   sta TILEADD
        jsr PLAYER
        jsr chrslot
        ldx CUR
        jsr drain
        ldx CUR
        jsr suitfx
        ldx CUR
        jsr gunfee
        jsr clamp
        lda PL_HP
        bne o_ret
        ldx CUR                 ; the engine's player update does not keep X
        lda #1                  ; out of health: park him, and put the bar back
        sta DOWN,x              ; to one so the engine, which reads the live
        sta PL_HP               ; player's health every frame, sees nothing
        lda #RESPAWN
        sta TMR,x
o_ret:  rts
o_down: dec TMR,x
        bne o_ret
        ldx #PL_BLK_LEN-1       ; a man who has just died carries a whole block
o_rb:   lda SPAWN,x             ; of dying state -- animation, the flag at $05AF
        sta PL_BLK,x            ; that holds him in place -- so put back the
        dex                     ; clean standing block instead of poking fields
        bpl o_rb
        lda #0
        sta PL_SPD
        ldx #3                  ; back on his feet, next to his partner
o_rs:   lda P2_POS,x
        sta PL_POS,x
        dex
        bpl o_rs
        ; and exactly on his partner's feet, not a step to the side: the
        ; partner is standing somewhere the level allows a man to stand, a
        ; step to the side may be inside a wall, and a man respawned inside a
        ; wall keeps his speed but never moves.  They separate on the first
        ; step anyway.
        lda #8
        sta PL_HP
        lda #$78                ; a moment of invulnerability
        sta PL_INV
        lda #0
        sta PL_STATE
        ldx CUR                 ; X was consumed by the copy
        sta DOWN,x
        rts

; --- the energy bar --------------------------------------------------------
; Power Blade 2 runs its suits off a bar that empties by itself, at a rate the
; suit sets, and drops the suit when it hits nothing.  Those are its own
; numbers: 1536 accumulator ticks to a bar unit, 3/4/4/6 ticks a frame.  The
; sub-weapons are charged against the same bar, per shot.
drain:  lda SUIT,x
        beq dr_ret
        tay
        lda drate-1,y
        sta TN
        lda ENE,x
        beq dr_off
        txa
        asl a
        tay
        sec
        lda EACC,y
        sbc TN
        sta EACC,y
        iny
        lda EACC,y
        sbc #$00
        sta EACC,y
        bcs dr_ret
        jsr reload
        dec ENE,x
dr_ret: rts
dr_off: lda #$00                ; empty: the suit comes off, as it does there
        sta SUIT,x
        rts
drate:  .byte 3,4,4,6

; Y already points at this player's accumulator.
reload: lda #$00
        dey
        sta EACC,y
        iny
        lda #$06
        sta EACC,y
        rts

; one shot costs its weapon's price out of the same accumulator.  $04 is
; whichever pad is live, because the swap puts it there.
gunfee: lda PAD1_P
        and #$40
        beq gf_ret
        lda SAT_TYPE
        beq gf_ret
        txa
        asl a
        tay
        ldx GUN
        beq gf_ret
        dex
        sec
        lda EACC,y
        sbc gclo,x
        sta EACC,y
        iny
        lda EACC,y
        sbc gchi,x
        sta EACC,y
        bcs gf_ret
        jsr reload
        ldx CUR
        lda ENE,x
        beq gf_ret
        dec ENE,x
gf_ret: rts
gclo:   .byte 0,0,0,$80,0,0,$80,$80
gchi:   .byte 1,2,1,1,1,2,1,1

; --- the two letter pickups now fill the bar --------------------------------
; The alpha and beta capsules used to spell out which sub-weapon you were
; allowed to carry.  Every weapon is carried from the start now, so the
; capsules pay for the bar instead -- four units each, to whoever is playing.
pick1:  sta $90                 ; the two bytes the alpha handler stands in for
        jsr addene
        ldy #$01
        rts
pick2:  sta $90
        jsr addene
        ldy #$02
        rts
addene: ldx #$00
        jsr addone
        ldx #$01
addone: lda ENE,x
        clc
        adc #$04
        cmp #$11
        bcc ae_s
        lda #$10
ae_s:   sta ENE,x
        rts

; --- what each Power Blade suit does ---------------------------------------
; Power Blade 2 spreads its four suits over a dozen sites inside its own
; player update.  None of that code fits this engine, so each suit is redone
; here as the nearest thing this engine can do, using its own variables.
suitfx: lda SUIT,x
        beq sf_ret
        cmp #$01
        beq sf_flo
        cmp #$02
        beq sf_spd
        cmp #$03
        beq sf_pow
        lda PL_INV              ; 4, armour: the engine's own untouchable timer
        cmp #$70
        bcs sf_ret
        lda #$70
        sta PL_INV
sf_ret: rts
sf_pow: lda #$20                ; 3, power: the engine's own double-damage flag
        sta PL_PWR
        rts
sf_flo: lda PAD1_H              ; 1, float: hold A and half the fall is undone
        and #$80
        beq sf_ret
        lda PL_DSP+3
        bmi sf_ret              ; already going up
        lsr a
        sta TMP+1
        lda PL_DSP+2
        ror a
        sta TMP
        sec
        lda PL_POS+2
        sbc TMP
        sta PL_POS+2
        lda PL_POS+3
        sbc TMP+1
        sta PL_POS+3
        rts
sf_spd: lda PL_DSP+1            ; 2, speed: a quarter more ground per frame
        cmp #$80
        ror a
        sta TMP+1
        lda PL_DSP+0
        ror a
        sta TMP
        lda TMP+1
        cmp #$80
        ror a
        sta TMP+1
        lda TMP
        ror a
        sta TMP
        clc
        lda PL_POS+0
        adc TMP
        sta PL_POS+0
        lda PL_POS+1
        adc TMP+1
        sta PL_POS+1
        rts

; --- the sprite tile hooks -------------------------------------------------
; The engine's metasprite writer reads a tile out of a table and stores it.
; Those three stores are redirected here, which is the whole of "player two
; is drawn from different tiles": his sprites come out $40 higher, that is,
; from the 1K bank at $1400 instead of the one at $1000.
tile1:  jsr tshift
        sta OAM_T1,x
        jmp pmark               ; this writer stores the attribute next
tile2:  jsr tshift
        sta OAM_T2,x
        jsr pmark               ; and this one stored it a moment ago
        pha
        lda PFLAG
        beq t2_ret
        lda OAM_A2,x
        and #$FC
        ora #$03
        sta OAM_A2,x
t2_ret: pla
        rts

; --- the sprite attribute ---------------------------------------------------
; Both men are drawn by the same engine code, so they would share sprite
; palette 0 and could not wear different suits.  Player two is moved to sprite
; palette 3, which a level never uses, and only for his own tiles -- the HUD
; is drawn inside the player update too and has to keep its colours.
; Y is the engine's own pointer into the metasprite table and X is the OAM
; slot, so neither may be touched here.
pmark:  pha
        lda TILEADD
        beq pm_no
        pla
        pha
        cmp #$40
        bcc pm_no
        cmp #$60
        bcs pm_no
        lda #$01
        sta PFLAG
        pla
        rts
pm_no:  lda #$00
        sta PFLAG
        pla
        rts

attr1:  pha
        lda PFLAG
        beq a1_st
        pla
        and #$FC
        ora #$03
        sta OAM_A1,x
        rts
a1_st:  pla
        sta OAM_A1,x
        rts

; The man himself is exactly the first 32 tiles of the bank ($00-$1F,
; measured over a run).  Everything above that -- the health bar, the letters,
; the boxes, the satellite -- is drawn inside the player update as well and
; must stay where it is.
tshift: cmp #$20
        bcs t_keep
        clc
        adc TILEADD
t_keep: rts

; --- chrslot: give each player his own 1K of the sprite pattern table ------
; The engine picks the player's art bank per pose and leaves it in the shadow
; $42.  That pose then has to be fetched as whichever hero the man chose, out
; of a bank built for the slot he is drawn in -- see work/pb3/v2/novachr.py.
chrslot: lda P2_ON
        bne c_pair
        lda HERO1               ; alone, and playing as the other hero
        beq c_ret
        lda CHR_R2
        jsr map_n2
        sta CHR_R2
c_ret:  rts
c_pair: lda CUR
        bne c_two
        lda CHR_R2              ; player one just drew: remember his pose
        sta P1BANK
        rts
c_two:  lda HERO2               ; player two just drew: his pose goes into the
        beq c_2s                ; second slot, as the hero he chose
        lda CHR_R2
        jsr map_n3
        jmp c_set
c_2s:   lda CHR_R2
        jsr map_s3
c_set:  sta CHR_R3
        lda HERO1               ; and player one gets the first slot back
        beq c_1s
        lda P1BANK
        jsr map_n2
        jmp c_1e
c_1s:   lda P1BANK
c_1e:   sta CHR_R2
        rts

; A pose bank we never saw when the art was built comes back unchanged, so the
; man shows this game's hero for that one frame rather than rubble.
map_n2: ldx #NPOSE-1
m2a:    cmp poses,x
        beq m2h
        dex
        bpl m2a
        rts
m2h:    lda nova2,x
        rts
map_n3: ldx #NPOSE-1
m3a:    cmp poses,x
        beq m3h
        dex
        bpl m3a
        rts
m3h:    lda nova3,x
        rts
map_s3: ldx #NPOSE-1
msa:    cmp poses,x
        beq msh
        dex
        bpl msa
        rts
msh:    lda sol3,x
        rts
poses:  .byte POSE_TABLE
nova2:  .byte NOVA2_TABLE
nova3:  .byte NOVA3_TABLE
sol3:   .byte SOL3_TABLE

; --- the select screen -----------------------------------------------------
; Hooked in just before the sprites are handed to the PPU, so it can put its
; own men on top of the title screen without fighting anybody for the buffer:
; the title draws no sprites at all.  Left picks this game's hero, right picks
; the other one; each pad picks for its own player.
menu:   lda MODE
        cmp #$05
        beq q_on
        cmp #$00                ; $00 is a level in play
        beq q_game
        jmp q_end
q_game: lda #GLYPHS             ; the font goes in the one sprite bank the
        sta CHR_R5              ; game never uses inside a level
        lda PAD1_H              ; SELECT opens and closes the menu.  The edge
        ora PAD2_H              ; is found here rather than trusting the
        and #$20                ; engine's own newly-pressed byte, which this
        cmp MROW                ; hook can see twice.
        sta MROW
        beq q_g2
        lda MROW
        beq q_g2
        lda MOPEN
        eor #$01
        sta MOPEN
        bne q_g2
        sta MCLR                ; closing: the menu's sprites have to go
        inc MCLR
q_g2:   jsr suitpal
        lda MOPEN
        beq q_g3
        jsr mnav
        jsr mdraw
        jmp q_end
q_g3:   jsr bars
        jmp q_end
q_on:
        lda #MENU_POSE          ; both men have to be mapped in at once, so
        sta CHR_R2              ; the two slots hold the two heroes' art
        lda #MENU_NOVA
        sta CHR_R3
        lda #GLYPHS
        sta CHR_R4
        jsr q_pal
        jsr q_pads
        jsr q_draw
q_end:  lda #$00                ; the two bytes the hook stands in for
        ldx #$02
        rts

; The title screen has no sprites, so it has no sprite colours either.  Three
; entries of sprite palette 0 are set here, inside vblank, right before the
; sprites are sent; the game reloads its own scroll after this hook returns.
q_pal:  lda #$30                ; the title's own sprite colours are three
        sta PALBUF+1            ; near-black purples; the two men need to be
        lda #$16                ; readable, so recolour sprite palette 0 in
        sta PALBUF+2            ; the game's own buffer -- it uploads it for us
        lda #$11
        sta PALBUF+3
        rts

q_pads: lda PAD1_P
        and #$03
        beq q_p2
        lsr a                   ; right in the carry, left in what is left
        lda #$00
        adc #$00
        sta HERO1
q_p2:   lda PAD2_P
        and #$03
        beq q_pe
        lsr a
        lda #$00
        adc #$00
        sta HERO2
q_pe:   rts

q_draw: lda #$00
        sta LABDY
        ldx #$00                ; the title screen draws nothing of its own,
        lda #$F0                ; so park every sprite off the bottom first
q_clr:  sta OAM+0,x
        inx
        inx
        inx
        inx
        bne q_clr
        ldy #$00
q_lp:   lda #MENU_Y              ; this game's hero on the left
        clc
        adc msy,y
        sta OAM+0,x
        lda mst,y
        sta OAM+1,x
        lda #$00
        sta OAM+2,x
        lda msx,y
        clc
        adc #MENU_X1
        sta OAM+3,x
        lda #MENU_Y              ; the other game's hero on the right
        clc
        adc msy,y
        sta OAM+4,x
        lda mst,y
        clc
        adc #$40
        sta OAM+5,x
        lda #$00
        sta OAM+6,x
        lda msx,y
        clc
        adc #MENU_X2
        sta OAM+7,x
        txa
        clc
        adc #$08
        tax
        iny
        cpy #NMENU
        bne q_lp
        lda HERO1               ; a label under each man's choice
        ldy #G_1
        jsr q_lab
        lda #$10                ; the second label sits a row lower, so the
        sta LABDY               ; two of them read even on the same man
        lda HERO2
        ldy #G_2
q_lab:  pha
        lda #MENU_LY
        clc
        adc LABDY
        sta OAM+0,x
        sta OAM+4,x
        tya
        sta OAM+1,x
        lda #G_P
        sta OAM+5,x
        lda #$00
        sta OAM+2,x
        sta OAM+6,x
        pla
        beq q_l1
        lda #MENU_X2+4
        bne q_l2
q_l1:   lda #MENU_X1+4
q_l2:   sta OAM+3,x
        clc
        adc #$08
        sta OAM+7,x
        txa
        clc
        adc #$08
        tax
        rts
; --- puts: TN characters from strs+X at (TX,TY), advancing TX ------------
puts:   ldy OAMP
p_lp:   lda TY
        sta OAM+0,y
        lda strs,x
        asl a                   ; two 8x8 tiles per character, and the odd bit
        clc                     ; picks the second pattern table
        adc #$C1
        sta OAM+1,y
        lda TATTR
        sta OAM+2,y
        lda TX
        sta OAM+3,y
        clc
        adc #$08
        sta TX
        iny
        iny
        iny
        iny
        inx
        dec TN
        bne p_lp
        sty OAMP
        rts

; --- suitpal: a Power Blade suit shows as its own colours -------------------
; The four suits differ in Power Blade 2 by exactly one thing on screen: three
; entries of a sprite palette.  Those are its own numbers, copied here.
suitpal: ldx #$00
        jsr onepal
        lda P2_ON
        beq sp_ret
        ldx #$01
onepal: lda SUIT,x
        beq sp_ret              ; no suit: the engine's own colours stand
        stx PADT
        asl a
        clc
        adc SUIT,x              ; three colours per suit
        sec
        sbc #$03
        tay
        lda PADT
        beq op_p0
        lda #$0D                ; player two paints sprite palette 3
        bne op_go
op_p0:  lda #$01                ; player one paints sprite palette 0
op_go:  tax
        lda palsuit,y
        sta PALBUF,x
        iny
        inx
        lda palsuit,y
        sta PALBUF,x
        iny
        inx
        lda palsuit,y
        sta PALBUF,x
        ldx PADT
sp_ret: rts
palsuit: .byte PALSUIT

gap:    lda TX                  ; a blank column costs no sprite
        clc
        adc #$08
        sta TX
        rts

; --- bars: the energy bar, one row per player, drawn every frame ----------
bars:   lda MCLR                ; the frame after the menu closes, park every
        beq b_go                ; sprite it drew; the engine redraws its own
        lda #$00                ; on the next frame
        sta MCLR
        ldx #$04
        lda #$F0
b_cl:   sta OAM,x
        inx
        inx
        inx
        inx
        cpx #$A8
        bne b_cl
b_go:   lda #$68                ; sixteen sprite slots the level leaves free
        sta OAMP
        lda #$01
        sta TATTR
        ldx #$00
        jsr onebar
        lda P2_ON
        beq b_ret
        ldx #$01
onebar: txa
        asl a
        asl a
        asl a
        asl a
        clc
        adc #BAR_Y
        sta TY
        lda #BAR_X
        sta TX
        lda ENE,x
        lsr a                   ; one block to every two units of energy
        sta TN
        beq b_ret
        ldx #STR_BAR
        jsr puts
b_ret:  rts

; --- mnav: LEFT/RIGHT picks your suit, UP/DOWN picks the sub-weapon -------
mnav:   ldx #$00
        lda PAD1_P
        sta PADT
        jsr mone
        ldx #$01
        lda PAD2_P
        sta PADT
mone:   lda PADT
        and #$02
        beq n_1
        dec SUIT,x
        bpl n_1
        lda #NSUIT-1
        sta SUIT,x
n_1:    lda PADT
        and #$01
        beq n_2
        inc SUIT,x
        lda SUIT,x
        cmp #NSUIT
        bcc n_2
        lda #$00
        sta SUIT,x
n_2:    lda PADT
        and #$08
        beq n_3
        inc GUN
        lda GUN
        cmp #NGUN
        bcc n_3
        lda #$00
        sta GUN
n_3:    lda PADT
        and #$04
        beq n_4
        dec GUN
        bpl n_4
        lda #NGUN-1
        sta GUN
n_4:    rts

; --- mdraw: the menu itself.  Every row is eight sprites or fewer, which is
; --- what one scanline can show. ------------------------------------------
mdraw:  lda #$04
        sta OAMP
        lda #$01
        sta TATTR
        lda #M_X+8
        sta TX
        lda #M_Y
        sta TY
        ldx #STR_SUIT
        lda #4
        sta TN
        jsr puts
        ldx #$00
        jsr mrow
        ldx #$01
        jsr mrow
        lda #M_X+8              ; and the sub-weapon, shared by the pair
        sta TX
        lda #M_Y+56
        sta TY
        ldx #STR_GUN
        lda #3
        sta TN
        jsr puts
        lda #M_X+8
        sta TX
        lda #M_Y+72
        sta TY
        lda GUN
        clc
        adc #STR_DIG
        tax
        lda #1
        sta TN
        jsr puts
        jsr gap
        lda GUN                 ; seven characters of name per weapon
        asl a
        asl a
        asl a
        sec
        sbc GUN
        clc
        adc #STR_GN
        tax
        lda #GNLEN
        sta TN
        jmp puts

; one player's line: "1P", the suit number, and what that suit does
mrow:   txa
        pha
        asl a
        asl a
        asl a
        asl a
        clc
        adc #M_Y+16
        sta TY
        lda #M_X-16
        sta TX
        pla
        pha
        asl a
        clc
        adc #STR_1P
        tax
        lda #2
        sta TN
        jsr puts
        jsr gap
        pla
        pha
        tax
        lda SUIT,x
        clc
        adc #STR_DIG
        tax
        lda #1
        sta TN
        jsr puts
        jsr gap
        pla
        tax
        lda SUIT,x
        asl a
        asl a
        clc
        adc SUIT,x
        clc
        adc #STR_SN
        tax
        lda #SNLEN
        sta TN
        jmp puts

strs:   .byte STRS

msx:    .byte MS_X
msy:    .byte MS_Y
mst:    .byte MS_T

; --- camera: replaces `JSR CAM_XF / JSR CAM_YF` at bank 14 $CD9C -----------
; The engine's camera scrolls when the live player pushes a dead-zone edge, by
; that player's own displacement.  Run it once per player and it follows the
; pair: whoever is pushing outward scrolls the view, and a player standing
; still contributes nothing -- which is what stops one man from pinning the
; other against the screen edge.  Feeding it the midpoint instead does exactly
; that, and was tried first.
camera: lda MOPEN
        bne c_frz
        lda P2_ON
        beq c_one
        ldx #3                  ; keep player one's real position aside
c_sv:   lda PL_POS,x
        sta SV_POS,x
        lda PL_DSP,x
        sta SV_DSP,x
        dex
        bpl c_sv
        jsr CAM_XF              ; ... his own pass
        jsr CAM_YF
        ldx #3                  ; then player two's
c_p2:   lda P2_POS,x
        sta PL_POS,x
        lda P2_DSP,x
        sta PL_DSP,x
        dex
        bpl c_p2
        jsr CAM_XF
        jsr CAM_YF
        ldx #3
c_rs:   lda SV_POS,x
        sta PL_POS,x
        lda SV_DSP,x
        sta PL_DSP,x
        dex
        bpl c_rs
        rts
c_one:  jsr CAM_XF
        jmp CAM_YF
c_frz:  rts

; --- enemies: replaces `JSR ENEMIES` at bank 14 $CDDD ----------------------
; Every enemy interacts with whichever player is nearer, and it does so with
; that player's context live -- so a hit lands on the right man.  Doing that
; per enemy would mean two context swaps per enemy; instead the twelve slots
; are sorted first and the pass is run twice, which costs two swaps a frame.
enemies:
        lda MOPEN
        bne e_frz
        lda P2_ON
        beq e_solo
        jsr mark
        ldx #$0B
e_a:    lda NEARF,x
        bne e_a2
        jsr ENEMY1
e_a2:   dex
        bpl e_a
        jsr swap
        ldx #$0B
e_b:    lda NEARF,x
        beq e_b2
        jsr ENEMY1
e_b2:   dex
        bpl e_b
        jmp swap
e_solo: jmp ENEMIES
e_frz:  rts

; NEARF[x] := 1 if enemy x is closer to player two.  Runs before any swap, so
; player one is live and player two's position is in P2_POS.  Distance is
; |dx| + |dy|, which is close enough and costs no multiply.
mark:   ldx #$0B
m_lp:   lda #0
        sta NEARF,x
        lda OBJ_TYPE,x
        beq m_next
        sec                     ; TMP = |enemy - player one|, X then Y
        lda OBJ_XL,x
        sbc PL_POS+0
        sta TMP
        lda OBJ_XH,x
        sbc PL_POS+1
        sta TMP+1
        bpl m_1y
        jsr negtmp
m_1y:   sec
        lda OBJ_YL,x
        sbc PL_POS+2
        sta TMP2
        lda OBJ_YH,x
        sbc PL_POS+3
        sta TMP2+1
        bpl m_1a
        jsr negtmp2
m_1a:   jsr addtmp              ; TMP := TMP + TMP2
        lda TMP
        sta TMP3
        lda TMP+1
        sta TMP3+1
        sec                     ; TMP = |enemy - player two|, X then Y
        lda OBJ_XL,x
        sbc P2_POS+0
        sta TMP
        lda OBJ_XH,x
        sbc P2_POS+1
        sta TMP+1
        bpl m_2y
        jsr negtmp
m_2y:   sec
        lda OBJ_YL,x
        sbc P2_POS+2
        sta TMP2
        lda OBJ_YH,x
        sbc P2_POS+3
        sta TMP2+1
        bpl m_2a
        jsr negtmp2
m_2a:   jsr addtmp
        lda TMP                 ; player two nearer?
        cmp TMP3
        lda TMP+1
        sbc TMP3+1
        bcs m_next
        lda #1
        sta NEARF,x
m_next: dex
        bmi m_end
        jmp m_lp
m_end:  rts

negtmp: sec
        lda #0
        sbc TMP
        sta TMP
        lda #0
        sbc TMP+1
        sta TMP+1
        rts
negtmp2:sec
        lda #0
        sbc TMP2
        sta TMP2
        lda #0
        sbc TMP2+1
        sta TMP2+1
        rts
addtmp: clc
        lda TMP
        adc TMP2
        sta TMP
        lda TMP+1
        adc TMP2+1
        sta TMP+1
        rts

; --- clamp: the live player stays inside the visible screen ----------------
; 256 px is $1000 in world units; MARGIN keeps him off the very edge.
clamp:  clc                     ; low bound = camera + MARGIN
        lda CAM_X
        adc #<MARGIN
        sta TMP
        lda CAM_X+1
        adc #>MARGIN
        sta TMP+1
        lda PL_POS+0            ; player < low bound?
        cmp TMP
        lda PL_POS+1
        sbc TMP+1
        bcs cl_hi
        lda TMP
        sta PL_POS+0
        lda TMP+1
        sta PL_POS+1
        rts
cl_hi:  clc                     ; high bound = camera + $1000 - MARGIN
        lda CAM_X
        adc #<($1000-MARGIN)
        sta TMP
        lda CAM_X+1
        adc #>($1000-MARGIN)
        sta TMP+1
        lda TMP                 ; player > high bound?
        cmp PL_POS+0
        lda TMP+1
        sbc PL_POS+1
        bcs cl_ret
        lda TMP
        sta PL_POS+0
        lda TMP+1
        sta PL_POS+1
cl_ret: rts

; --- init: take the second player's context from the first -----------------
; Only once player one is in the ground state, or player two inherits the
; warp-in state and can never leave it ($05AF stays non-zero).
init:   lda PL_STATE
        bne iret
        lda P2JOIN              ; pad two joins by pressing start, and having
        bne i_go                ; joined once he is put back in automatically
        lda PAD2_P              ; after every level restart
        and #$10
        beq iret
        sta P2JOIN
i_go:
        ldx #PL_BLK_LEN-1
i1:     lda PL_BLK,x
        sta P2_BLK,x
        sta SPAWN,x             ; and keep one clean copy of a standing player,
        dex                     ; which is what a respawn is restored from
        bpl i1
        ldx #3
i2:     lda PL_POS,x
        sta P2_POS,x
        dex
        bpl i2
        clc                     ; and stand him 64 px to the right
        lda P2_POS+1
        adc #4
        sta P2_POS+1
        bcc i3
        inc P2_POS+2
i3:     lda PL_SPD
        sta P2_SPD
        lda #1
        sta P2_ON
iret:   rts

; --- swap: exchange the live context with the second player's --------------
swap:   ldx #PL_BLK_LEN-1
s1:     lda PL_BLK,x
        pha
        lda P2_BLK,x
        sta PL_BLK,x
        pla
        sta P2_BLK,x
        dex
        bpl s1
        ldx #3
s2:     lda PL_POS,x
        pha
        lda P2_POS,x
        sta PL_POS,x
        pla
        sta P2_POS,x
        dex
        bpl s2
        lda PL_SPD
        ldy P2_SPD
        sta P2_SPD
        sty PL_SPD
        lda PAD1_P
        ldy PAD2_P
        sta PAD2_P
        sty PAD1_P
        lda PAD1_H
        ldy PAD2_H
        sta PAD2_H
        sty PAD1_H
        ; --- and the punch hitbox ------------------------------------------
        ; The melee punch is object slot $0F, and one slot cannot hold two
        ; punches.  Slot $0D is a second player-weapon hitbox the original game
        ; never fills, and the enemy-vs-weapon test at 8:$8424 already checks
        ; it.  Exchanging the two slots along with the player context therefore
        ; gives each player his own punch at no cost in collision code.
        ldy #$F0                ; the 16 object arrays, $0600 + k*$10
p1:     lda $060F,y
        pha
        lda $060D,y
        sta $060F,y
        pla
        sta $060D,y
        tya
        sec
        sbc #$10
        tay
        bcs p1
        ldy #$30                ; and the 4 position arrays, $00A0 + k*$10
p2:     lda $00AF,y
        pha
        lda $00AD,y
        sta $00AF,y
        pla
        sta $00AD,y
        tya
        sec
        sbc #$10
        tay
        bcs p2
        rts
"""
    order = novachr.SOL_ORDER
    tbl = lambda base: ','.join(str(base + i) for i in range(len(order)))
    src = src.replace('POSE_TABLE', ','.join(str(b) for b in order))
    src = src.replace('NOVA2_TABLE', tbl(novachr.NOVA2_BASE))
    src = src.replace('NOVA3_TABLE', tbl(novachr.NOVA3_BASE))
    src = src.replace('SOL3_TABLE', tbl(novachr.SOL3_BASE))
    strs, off = [], {}

    def put(key, text):
        off[key] = len(strs)
        strs.extend(novachr.FONT.index(c) for c in text)

    put('STR_SUIT', 'SUIT')
    put('STR_GUN', 'GUN')
    put('STR_1P', '1P2P')
    put('STR_DIG', '0123456789')
    put('STR_BAR', '\x1e' * 8)
    put('STR_SN', 'NONE FLOATSPEEDPOWERORBIT')
    put('STR_GN', 'NONE   WHIP   GRENADERIFLE  BOUNCE FAN    NAPALM SLASH  '
                  'BOOMER ')

    ink, mbank, msprs = mapping
    src = src.replace('PALSUIT', ','.join(
        str(v) for v in (0x0F, 0x25, 0x35, 0x0F, 0x27, 0x38,
                         0x0F, 0x22, 0x31, 0x0F, 0x2B, 0x3B)))
    src = src.replace('STRS', ','.join(str(v) for v in strs))
    src = src.replace('MS_X', ','.join(str(s[0]) for s in msprs))
    src = src.replace('MS_Y', ','.join(str(s[1] & 0xFF) for s in msprs))
    src = src.replace('MS_T', ','.join(str(s[4] | 1) for s in msprs))
    a = Asm(WRAM, dict(SYMS, PL_BLK_LEN=PL_BLK_LEN, MARGIN=MARGIN,
                        RESPAWN=RESPAWN, RESPAWN_DX=RESPAWN_DX,
                        NPOSE=len(order), NMENU=len(msprs),
                        MENU_POSE=mbank,
                        MENU_NOVA=novachr.NOVA3_BASE + order.index(mbank),
                        GLYPHS=novachr.GLYPH_BANK,
                        G_1=0x81 + 2 * novachr.FONT.index('1'),
                        G_2=0x81 + 2 * novachr.FONT.index('2'),
                        G_P=0x81 + 2 * novachr.FONT.index('P'),
                        MENU_X1=40, MENU_X2=200, MENU_Y=128, MENU_LY=134,
                        NSUIT=5, NGUN=9, SNLEN=5, GNLEN=7,
                        M_X=72, M_Y=40, BAR_X=16, BAR_Y=40, **off))
    return a.assemble(src), a.syms


# ===========================================================================
# Boot: turn the work RAM on, fill it, then let Solbrain's own reset run.
# ===========================================================================

BOOT = 0xFF50                   # 144 bytes of padding in the fixed bank


def boot_code(pages):
    src = """
        sei
        cld
        ldx #$FF
        txs
        lda #$80                ; MMC3: work RAM enabled, writes allowed
        sta $A001
        lda #$00                ; PRG mode 0, so $8000 is R6
        sta $8000
        lda #$06
        sta $8000
        lda #RTBANK
        sta $8001
        lda #$00                ; copy bank RTBANK -> $6000
        sta $00
        sta $02
        lda #$80
        sta $01
        lda #$60
        sta $03
        ldx #PAGES
        ldy #$00
c1:     lda ($00),y
        sta ($02),y
        iny
        bne c1
        inc $01
        inc $03
        dex
        bne c1
        lda #$00                ; who each pad starts out playing as
        sta HERO1
        sta GUN
        sta MOPEN
        sta SUIT+0
        sta SUIT+1
        sta EACC+0              ; the drain accumulators start empty
        sta EACC+2
        lda #$06
        sta EACC+1
        sta EACC+3
        lda #$10                ; both energy bars full
        sta ENE+0
        sta ENE+1
        lda #$01
        sta HERO2
        jmp RESET
"""
    a = Asm(BOOT, dict(SYMS, RTBANK=RTBANK, PAGES=pages))
    return a.assemble(src)


def build():
    img = Image()
    mapping, first, novabanks, redrawn = novachr.novabanks()
    img.add_chr(novabanks, first)
    rt, syms = runtime(mapping)
    pages = (len(rt) + 0xFF) // 0x100
    img.prg[RTBANK * BANK:RTBANK * BANK + len(rt)] = rt

    boot = boot_code(pages)
    img.free(15, BOOT, boot, 'boot')
    img.poke(15, 0xFFFC, bytes((BOOT & 0xFF, BOOT >> 8)), 'reset vector')

    # the one call site of the player update, redirected into the runtime
    old = img.prg[img.off(12, 0x9150):img.off(12, 0x9150) + 3]
    assert bytes(old) == bytes((0x20, 0x59, 0x91)), old.hex()
    img.poke(12, 0x9150, bytes((0x20, syms['hook'] & 0xFF, syms['hook'] >> 8)),
             '2p hook')

    # the two camera calls, replaced by one that feeds them the pair's midpoint
    old = img.prg[img.off(14, 0xCD9C):img.off(14, 0xCD9C) + 6]
    assert bytes(old) == bytes((0x20, 0xEA, 0xF1, 0x20, 0x4B, 0xF2)), old.hex()
    img.poke(14, 0xCD9C,
             bytes((0x20, syms['camera'] & 0xFF, syms['camera'] >> 8,
                    0xEA, 0xEA, 0xEA)), 'camera hook')

    # the enemy pass, split so each enemy meets the player he is nearer to
    old = img.prg[img.off(14, 0xCDDD):img.off(14, 0xCDDD) + 3]
    assert bytes(old) == bytes((0x20, 0x1D, 0xCE)), old.hex()
    img.poke(14, 0xCDDD,
             bytes((0x20, syms['enemies'] & 0xFF, syms['enemies'] >> 8)),
             'enemy hook')

    # the three places the sprite writer stores a tile byte, so player two's
    # sprites can come from a different 1K of the pattern table
    for cpu, orig, sym in ((0xF5C3, (0x9D, 0x01, 0x02), 'tile1'),
                           (0xF775, (0x9D, 0x01, 0x02), 'tile1'),
                           (0xF6CA, (0x9D, 0xFE, 0x01), 'tile2')):
        old = img.prg[img.off(15, cpu):img.off(15, cpu) + 3]
        assert bytes(old) == bytes(orig), '%04X %s' % (cpu, old.hex())
        img.poke(15, cpu,
                 bytes((0x20, syms[sym] & 0xFF, syms[sym] >> 8)), 'tile hook')

    # and the attribute byte that goes with the first writer's tile, so the
    # second man can wear a different suit colour from the first
    for cpu in (0xF5CB, 0xF77D):
        old = img.prg[img.off(15, cpu):img.off(15, cpu) + 3]
        assert bytes(old) == bytes((0x9D, 0x02, 0x02)), '%04X %s' % (cpu, old.hex())
        img.poke(15, cpu,
                 bytes((0x20, syms['attr1'] & 0xFF, syms['attr1'] >> 8)),
                 'attribute hook')

    # the two letter capsules, which now refill the energy bar
    for cpu, sym in ((0x82B5, 'pick1'), (0x82F3, 'pick2')):
        old = img.prg[img.off(8, cpu):img.off(8, cpu) + 4]
        assert bytes(old[2:]) == bytes((0x85, 0x90)), '%04X %s' % (cpu, old.hex())
        img.poke(8, cpu,
                 bytes((0x20, syms[sym] & 0xFF, syms[sym] >> 8, 0xEA)),
                 'capsule hook')

    # the select screen, hooked in right before the sprites go to the PPU
    old = img.prg[img.off(15, 0xFAE7):img.off(15, 0xFAE7) + 4]
    assert bytes(old) == bytes((0xA9, 0x00, 0xA2, 0x02)), old.hex()
    img.poke(15, 0xFAE7,
             bytes((0x20, syms['menu'] & 0xFF, syms['menu'] >> 8, 0xEA)),
             'select screen')

    n = img.save()
    print('%s  %d bytes' % (os.path.relpath(OUT, ROOT), n))
    print('runtime %d bytes at $%04X (%d page%s copied), boot %d of 144 bytes'
          % (len(rt), WRAM, pages, '' if pages == 1 else 's', len(boot)))
    for k in ('hook', 'init', 'swap', 'camera', 'clamp', 'enemies', 'mark'):
        print('  %-5s $%04X' % (k, syms[k]))
    return img


if __name__ == '__main__':
    build()
