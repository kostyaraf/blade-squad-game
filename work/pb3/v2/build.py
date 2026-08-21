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
hook:   lda PL_STATE            ; states $12/$13 are the warp-in: a level has
        cmp #$12                ; just started or restarted, so player two is
        bcc h_run               ; built again from player one when he lands
        lda #0
        sta P2_ON
        sta DOWN+0
        sta DOWN+1
h_run:  lda P2_ON
        bne h_two
        jsr PLAYER              ; alone: exactly the original behaviour
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

; --- the sprite tile hooks -------------------------------------------------
; The engine's metasprite writer reads a tile out of a table and stores it.
; Those three stores are redirected here, which is the whole of "player two
; is drawn from different tiles": his sprites come out $40 higher, that is,
; from the 1K bank at $1400 instead of the one at $1000.
tile1:  jsr tshift
        sta OAM_T1,x
        rts
tile2:  jsr tshift
        sta OAM_T2,x
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
; $42.  Player one's is kept, player two's is moved to the neighbouring slot.
chrslot: lda P2_ON
        beq c_none
        lda CUR
        bne c_two
        lda CHR_R2              ; player one just drew: remember his bank
        sta P1BANK
        rts
c_two:  lda CHR_R2              ; player two just drew: the same poses, but
        ldx #NPOSE-1            ; drawn as the other game's hero, go into the
c_map:  cmp poses,x             ; second slot
        beq c_hit
        dex
        bpl c_map
        lda CHR_R2              ; a pose we never saw when the art was built:
        bne c_set               ; he shows Solbrain's man for that one frame
c_hit:  lda novas,x
c_set:  sta CHR_R3
        lda P1BANK              ; and player one gets his own bank back
        sta CHR_R2
c_none: rts
poses:  .byte POSE_TABLE
novas:  .byte NOVA_TABLE

; --- camera: replaces `JSR CAM_XF / JSR CAM_YF` at bank 14 $CD9C -----------
; The engine's camera scrolls when the live player pushes a dead-zone edge, by
; that player's own displacement.  Run it once per player and it follows the
; pair: whoever is pushing outward scrolls the view, and a player standing
; still contributes nothing -- which is what stops one man from pinning the
; other against the screen edge.  Feeding it the midpoint instead does exactly
; that, and was tried first.
camera: lda P2_ON
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

; --- enemies: replaces `JSR ENEMIES` at bank 14 $CDDD ----------------------
; Every enemy interacts with whichever player is nearer, and it does so with
; that player's context live -- so a hit lands on the right man.  Doing that
; per enemy would mean two context swaps per enemy; instead the twelve slots
; are sorted first and the pass is run twice, which costs two swaps a frame.
enemies:
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
    mapping = mapping or {}
    order = sorted(mapping)
    src = src.replace('POSE_TABLE', ','.join(str(b) for b in order) or '0')
    src = src.replace('NOVA_TABLE',
                      ','.join(str(mapping[b]) for b in order) or '0')
    a = Asm(WRAM, dict(SYMS, PL_BLK_LEN=PL_BLK_LEN, MARGIN=MARGIN,
                        RESPAWN=RESPAWN, RESPAWN_DX=RESPAWN_DX,
                        NPOSE=max(1, len(order))))
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
        jmp RESET
"""
    a = Asm(BOOT, dict(SYMS, RTBANK=RTBANK, PAGES=pages))
    return a.assemble(src)


def build():
    img = Image()
    mapping, novabanks, redrawn = novachr.novabanks()
    img.add_chr(novabanks, novachr.NOVA_BASE)
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

    n = img.save()
    print('%s  %d bytes' % (os.path.relpath(OUT, ROOT), n))
    print('runtime %d bytes at $%04X (%d page%s copied), boot %d of 144 bytes'
          % (len(rt), WRAM, pages, '' if pages == 1 else 's', len(boot)))
    for k in ('hook', 'init', 'swap', 'camera', 'clamp', 'enemies', 'mark'):
        print('  %-5s $%04X' % (k, syms[k]))
    return img


if __name__ == '__main__':
    build()
