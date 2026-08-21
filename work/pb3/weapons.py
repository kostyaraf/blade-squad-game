#!/usr/bin/env python3
"""PB3 -- Solbrain's eight sub-weapons inside Power Blade 2's engine.

Everything here is additive: `install(img)` appends a weapon runtime to the
payload bank (which `build.py` copies to $6000-$7FFF at boot), rewrites eight
CHR banks, and patches a dozen call sites in Power Blade 2's own code.  It
touches nothing `build.py` writes.

    * LEFT / RIGHT in the START menu cycle RT_WEAPON 0..8.  0 is Power
      Blade 2's own weapon and every patched path is byte-transparent then.
    * Weapons 1..8 are Solbrain's, spawned into object slots 1..4 with new
      object types $10..$1B, driven by a dispatcher hung off `sub_A573`.
    * Every shot pays from the same $A0 bar / $9E spare-tank pool the Power
      Suits drain, through the stock `$D2FD` tail.

Layout notes and the reverse engineering behind each patch are in
`work/re/pb3_weapon_plan.md`; the deviations from it that the ROM forced are
listed in `NOTES` at the bottom of this file.
"""
import build
from build import asm, rel, Asm, PAYLOAD_BANK, WRAM

# ---------------------------------------------------------------------------
# work RAM
# ---------------------------------------------------------------------------
# scalars live in the 32-byte hole between RT_CUR ($6077) and RT_WBASE ($6098)
RT_WEAPON = 0x6078          # 0 = Power Blade 2's own weapon, 1..8 = Solbrain's
RT_WCD    = 0x6079          # frames until the next shot is allowed
RT_WPH    = 0x607A          # weapon 3's 80-frame burst window
RT_ACCL   = 0x607B          # energy accumulator, low   (1536 = one bar unit)
RT_ACCH   = 0x607C          # ... high
RT_WSPR   = 0x607D          # direction 0..7 captured at spawn
RT_WSEQ   = 0x607E          # scatter / cone sweep index
RT_WTMP   = 0x607F          # scratch

# tables: the gap above the crate hook's code ($6E00-$6E34) and below RT_MENU
RT_WCHR   = 0x6E40          # weapon -> the 1 KB CHR bank R3 points at
RT_WCOSTL = 0x6E48          # energy per shot, low
RT_WCOSTH = 0x6E50          # ... high
RT_WCDT   = 0x6E58          # cooldown frames
RT_WAUTO  = 0x6E60          # 0 = fire on the press, 1 = fire while held
RT_WLIFE  = 0x6E68          # default $05A2
RT_WMSPR  = 0x6E70          # default $0442
RT_TDMG   = 0x6E78          # object type $10..$1B -> damage      (12)
RT_TRAD   = 0x6E88          # object type $10..$1B -> hitbox radius (12)
RT_ORBX   = 0x6E98          # weapon 1's orbit, 16 steps
RT_ORBY   = 0x6EA8
RT_FANDY  = 0x6EB8          # weapon 5's cone sweep
RT_NAPX   = 0x6EC0          # weapon 6's scatter
RT_W2LIFE = 0x6EC4          # weapon 2's blast stages
RT_W2SPR  = 0x6EC8
RT_SHTAB  = 0x6ECC          # object type $10..$1B -> handler (12 words)
RT_SPTAB  = 0x6EE4          # weapon 1..8 -> spawner (8 words)
RT_VEL    = 0x6F00          # 8 weapons x 8 directions x 4 bytes

# Candidate homes for the code.  build.py owns this bank and keeps growing new
# routines into it, so these are only *candidates*: install() intersects each
# with the zero runs actually left in the payload it is handed, and fails only
# if the total no longer covers the runtime.  Nothing here is a region the
# engine writes at run time.
CODE_REGIONS = [
    (0x7C00, 0x7F00),       # crate-record pool headroom -- guarded, see install()
    (0x6670, 0x6800),       # above RT_FINDSHOT, below MW_TABLES
    (0x7F22, 0x8000),       # above RT_BOOT's copy loop
    (0x6225, 0x6300),       # above RT_PAL, below RT_SUITS
    (0x7280, 0x7300),       # above RT_STN, below RT_CRTAB
    (0x71A7, 0x7200),       # above RT_MENU, below RT_CURHI
    (0x6591, 0x65C0),       # above RT_PLAYERS, below RT_JOIN
    (0x65F5, 0x6620),       # above RT_JOIN, below RT_P2SCAL
    (0x601F, 0x6040),       # above RT_SETBANK, below RT_AREABANK
    (0x6080, 0x6098),       # rest of the hole this file's scalars sit in
]

# ---------------------------------------------------------------------------
# Power Blade 2 entry points this runtime borrows
# ---------------------------------------------------------------------------
PB2_FREE     = 0xC810       # -> sub_D6D4, wipe object slot X
PB2_SOUND    = 0xC81C       # -> $ECE8, play sound id A
PB2_SOLID    = 0xC888       # -> $F342, A/Y = signed dx/dy; N set = solid cell
PB2_MOVEKILL = 0xA7B9       # integrate slot X; PLA/PLA + free when it leaves screen
PB2_BEAM     = 0xA7FB       # the suited beam's per-frame handler
PB2_KNIFE    = 0xA57A       # the unsuited knife's
PB2_DIR      = 0xA403       # X = direction 0..7, Y = throw pose (bit7 = refuse)
PB2_POSEMS   = 0xA4EE       # pose -> animation id
PB2_SETANIM  = 0xB017       # start the throw animation (Y = animation id)
PB2_MUZZLE   = 0xA4FD       # copy slot 0's position + the pose's muzzle offset
PB2_SUITMENU = 0xD259       # the stock UP/DOWN suit cycle
PB2_ENERGY   = 0xD2BE       # the per-frame suit drain
PB2_TANK     = 0xD2FD       # burn one spare tank, or drop the suit
PB2_KILLSHOTS= 0xD768       # wipe object slots 1..5
PB2_BARHUD   = 0xD4D9       # repaint the energy bar
PB2_PORTRAIT = 0xD5C1       # repaint the suit portrait
PB2_QCMD     = 0xCD18       # push VRAM command 1 (a $FF-terminated run)
PB2_QBYTE    = 0xCD0B       # push one raw byte
PB2_QEND     = 0xCD09       # push the $FF terminator
PB2_DMGTAB   = 0xB721       # damage by attacker object type
PB2_RADTAB   = 0xB725       # ... and the hitbox radius, four bytes along
SHOT_SLOTS   = 4            # object slots 1..3 hold shots; see r_alloc()

OBJ_TYPE, OBJ_FLAGS, OBJ_ATTR, OBJ_MSPR, OBJ_POSE = 0x0400, 0x0416, 0x042C, 0x0442, 0x0458
OBJ_YHI, OBJ_Y, OBJ_YF = 0x04B0, 0x04C6, 0x04DC
OBJ_XHI, OBJ_X, OBJ_XF = 0x04F2, 0x0508, 0x051E
OBJ_VYI, OBJ_VYF, OBJ_VXI, OBJ_VXF = 0x0534, 0x054A, 0x0560, 0x0576
OBJ_F18, OBJ_LIFE, OBJ_DIR, OBJ_CROUCH = 0x058C, 0x05A2, 0x05CE, 0x05FA

# object types
T_ORBIT, T_BULLET, T_BLAST, T_RIFLE, T_BOUNCE = 0x10, 0x11, 0x12, 0x13, 0x14
T_FAN, T_NAPALM, T_CRAWL, T_FLAME, T_BOOM, T_BOOMR = 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A

SND_THROW, SND_BOOM, SND_RICOCHET, SND_FLAME = 0x22, 0x24, 0x1C, 0x1D

# ---------------------------------------------------------------------------
# per-weapon data
# ---------------------------------------------------------------------------
#           1     2     3     4     5     6     7     8
SPEED   = (0.0,  4.50, 7.00, 5.19, 6.50, 5.50, 0.00, 5.50)
LIFE    = (0x33, 0x14, 0x00, 0x07, 0x10, 0x06, 0x09, 0x0D)
MSPR    = (0x45, 0x46, 0x45, 0x45, 0x45, 0x45, 0x41, 0x45)
CDT     = (0x08, 0x0C, 0x02, 0x0A, 0x02, 0x08, 0x1E, 0x10)
AUTO    = (0,    0,    1,    0,    1,    1,    0,    0)
COST    = (512,  384,  96,   256,  64,   128,  384,  256)
CHRBANK = (248, 249, 250, 251, 252, 253, 254, 255)

# damage / hitbox radius, indexed by object type - $10
TDMG = (1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 1)
TRAD = (0x0C, 0x08, 0x14, 0x06, 0x0A, 0x06, 0x08, 0x08, 0x14, 0x0C, 0x0C, 0x08)


def _vel_block(speed):
    """8 directions x (VX frac, VX int, VY frac, VY int), 8.8 signed."""
    d = 0.70710678
    units = ((1, 0), (-1, 0), (0, -1), (0, 1),
             (d, -d), (-d, -d), (d, d), (-d, d))
    out = bytearray()
    for ux, uy in units:
        for u in (ux, uy):
            n = int(round(u * speed * 256)) & 0xFFFF
            out += bytes((n & 0xFF, n >> 8))
    return bytes(out)


def _orbit(radius=30):
    import math
    x = bytearray()
    y = bytearray()
    for i in range(16):
        a = i * math.pi / 8
        x.append(int(round(math.cos(a) * radius)) & 0xFF)
        y.append(int(round(math.sin(a) * radius)) & 0xFF)
    return bytes(x), bytes(y)


# ---------------------------------------------------------------------------
# a tiny assembler layer on top of build.Asm
# ---------------------------------------------------------------------------
def _lo(a): return a & 0xFF
def _hi(a): return (a >> 8) & 0xFF


class A(Asm):
    """build.Asm plus the addressing modes this file keeps repeating."""
    def op(self, code, addr):       # absolute
        return self.emit(code, _lo(addr), _hi(addr))

    def lda(self, a):  return self.op(0xAD, a)
    def sta(self, a):  return self.op(0x8D, a)
    def ldax(self, a): return self.op(0xBD, a)
    def stax(self, a): return self.op(0x9D, a)
    def lday(self, a): return self.op(0xB9, a)
    def incx(self, a): return self.op(0xFE, a)
    def decx(self, a): return self.op(0xDE, a)
    def ldai(self, v): return self.emit(0xA9, v)
    def ldxi(self, v): return self.emit(0xA2, v)
    def ldyi(self, v): return self.emit(0xA0, v)
    def jsr(self, a):  return self.op(0x20, a)
    def jmp(self, a):  return self.op(0x4C, a)
    def rts(self):     return self.emit(0x60)

    def clear(self, *addrs):
        """A must already be zero."""
        for a in addrs:
            self.stax(a)
        return self


def _dispatch(a, table):
    """A = a zero-based index; jump through a word table in work RAM.  X is
    preserved, which is what matters: it is the object slot.  $02/$03 are the
    same two scratch bytes Power Blade 2's own $CA0B dispatcher uses, and this
    adds no stack depth, so a handler's RTS still lands at $A56D."""
    a.emit(0x0A, 0xA8)                       # asl a / tay
    a.lday(table).emit(0x85, 0x02)
    a.lday(table + 1).emit(0x85, 0x03)
    a.emit(0x6C, 0x02, 0x00)                 # jmp ($0002)
    return a


# ===========================================================================
# the routines.  Each takes its own origin and the symbol table, and returns
# bytes; link() calls every one twice, once to measure and once for real.
# ===========================================================================

def r_wsel(org, S):
    """Entered by JMP from $CDCB, which only runs while the START menu is
    open.  LEFT/RIGHT are ours, everything else is the stock suit cycle."""
    a = A(org)
    a.emit(0xA5, 0x27, 0xC9, 0x03).br(0xD0, 'stock')     # gameplay only
    a.emit(0xA5, 0x48, 0x29, 0x02).br(0xD0, 'prev')      # LEFT
    a.emit(0xA5, 0x48, 0x29, 0x01).br(0xD0, 'next')      # RIGHT
    a.label('stock').jmp(PB2_SUITMENU)
    a.label('next')
    a.op(0xAE, RT_WEAPON).emit(0xE8, 0xE0, 0x09).br(0x90, 'store')
    a.ldxi(0x00).br(0xF0, 'store')
    a.label('prev')
    a.op(0xAE, RT_WEAPON).emit(0xCA).br(0x10, 'store')
    a.ldxi(0x08)
    a.label('store')
    a.op(0x8E, RT_WEAPON)
    a.ldai(0x10).sta(RT_WCD)
    a.ldai(0x00).sta(RT_WPH).sta(RT_WSEQ)
    a.jsr(PB2_KILLSHOTS)                                 # drop shots in flight
    a.jsr(S['RT_SETCHR']).jsr(S['RT_WHUD'])
    a.ldai(0x30).jmp(PB2_SOUND)                          # tail call; it RTSes
    return a.done()


def r_setchr(org, S):
    """MMC3 R3 ($1400-$17FF, sprite tiles $40-$7F) holds the player's
    projectile art and is the one sprite register that does not change with
    the stage.  $45 is its shadow.  X survives because two of the five sites
    this replaces are in the middle of code that still wants it."""
    a = A(org)
    a.emit(0x8A, 0x48)                                   # txa / pha
    a.op(0xAE, RT_WEAPON).br(0xF0, 'stock')
    a.op(0xBD, RT_WCHR - 1).br(0xD0, 'done')             # banks are never 0
    a.label('stock')
    a.emit(0xA5, 0x9A).br(0xF0, 'bare')
    a.ldai(0x12).br(0xD0, 'done')
    a.label('bare').ldai(0x11)
    a.label('done')
    a.emit(0x85, 0x45)
    a.emit(0x68, 0xAA)                                   # pla / tax
    a.rts()
    return a.done()


def r_tick(org, S):
    """Replaces `JSR $D2BE` at $CEFD, which runs once per gameplay frame."""
    a = A(org)
    a.jsr(S['RT_SETCHR'])
    a.lda(RT_WCD).br(0xF0, 'nocd')
    a.op(0xCE, RT_WCD)
    a.label('nocd')
    a.lda(RT_WPH).br(0xF0, 'noph')
    a.op(0xCE, RT_WPH)
    a.label('noph')
    a.jmp(PB2_ENERGY)
    return a.done()


def r_whud(org, S):
    """Two tiles at PPU $26D8: 'W' and the weapon digit.  Queue entries are
    [cmd, addr lo, addr hi, bytes..., $FF] -- see $D4D9/$CC47."""
    a = A(org)
    a.jsr(PB2_QCMD)
    a.ldai(0xD8).jsr(PB2_QBYTE)
    a.ldai(0x26).jsr(PB2_QBYTE)
    a.ldai(0x17).jsr(PB2_QBYTE)                          # 'W'  (A=$01 .. Z=$1A)
    a.lda(RT_WEAPON).emit(0x18, 0x69, 0x20).jsr(PB2_QBYTE)
    a.jmp(PB2_QEND)
    return a.done()


def r_hudw(org, S):
    """Replaces `JSR $D5C1` in the HUD rebuild at $D67E."""
    a = A(org)
    a.jsr(PB2_PORTRAIT).jmp(S['RT_WHUD'])
    return a.done()


def r_pay(org, S):
    """X = weapon 1..8.  C set on return means the shot is refused.
    1536 units = one $A0 bar unit, the same accumulator step $D2EE reloads."""
    a = A(org)
    a.emit(0xA5, 0xA0, 0x05, 0x9E).br(0xD0, 'have')
    a.emit(0x38).rts()                                   # pool empty
    a.label('have')
    a.emit(0x38)                                         # sec
    a.lda(RT_ACCL).op(0xFD, RT_WCOSTL - 1).sta(RT_ACCL)
    a.lda(RT_ACCH).op(0xFD, RT_WCOSTH - 1).sta(RT_ACCH)
    a.br(0xB0, 'paid')
    a.ldai(0x00).sta(RT_ACCL)
    a.ldai(0x06).sta(RT_ACCH)
    a.emit(0xA5, 0xA0).br(0xF0, 'tank')
    a.emit(0xC6, 0xA0)
    a.jsr(PB2_BARHUD).jump(0x4C, 'paid')
    a.label('tank')
    a.jsr(PB2_TANK)                                      # spare tank, or the
    a.jsr(S['RT_SETCHR'])                                # suit falls off and
    a.label('paid')                                      # resets $45
    a.emit(0x18).rts()
    return a.done()


def r_trig(org, S):
    """C set when this weapon wants to fire this frame."""
    a = A(org)
    a.op(0xAC, RT_WEAPON)
    a.lday(RT_WAUTO - 1).br(0xF0, 'edge')
    a.emit(0xA5, 0x4A).br(0xD0, 'test')                  # HELD
    a.label('edge').emit(0xA5, 0x48)                     # NEWLY PRESSED
    a.label('test').emit(0x29, 0x40).br(0xF0, 'no')      # B
    a.op(0xAC, RT_WEAPON).emit(0xC0, 0x03).br(0xD0, 'ready')
    # weapon 3 fires only in the first 8 frames of an 80-frame window
    a.lda(RT_WPH).br(0xD0, 'window')
    a.ldai(0x50).sta(RT_WPH).br(0xD0, 'ready')
    a.label('window').emit(0xC9, 0x49).br(0x90, 'no')
    a.label('ready')
    a.lda(RT_WCD).br(0xD0, 'no')
    a.op(0xAC, RT_WEAPON)
    a.lday(RT_WCDT - 1).sta(RT_WCD)
    a.emit(0x38).rts()
    a.label('no').emit(0x18).rts()
    return a.done()


def r_fire(org, S):
    """Replaces the head of $A1F8, which the player update falls through to
    when the player is not already busy in a throw animation."""
    a = A(org)
    a.lda(RT_WEAPON).br(0xD0, 'solbrain')
    a.emit(0xA5, 0x48, 0x29, 0x40).br(0xF0, 'no')
    a.jmp(0xA1FE)                                        # the stock allocator
    a.label('no').rts()

    a.label('solbrain')
    a.jsr(S['RT_TRIG']).br(0x90, 'no')
    a.op(0xAE, RT_WEAPON)
    a.jsr(S['RT_PAY']).br(0xB0, 'no')
    a.jsr(S['RT_ALLOC']).br(0xD0, 'no')                  # X = slot, Z = found
    a.emit(0x86, 0x25)                                   # stx $25
    a.jsr(PB2_DIR)                                       # X = dir, Y = pose
    a.emit(0x98).br(0x30, 'no')                          # tya / refused
    a.op(0x8E, RT_WSPR)                                  # direction
    a.emit(0x8C, _lo(RT_WTMP), _hi(RT_WTMP))             # sty RT_WTMP  (pose)
    a.emit(0xA6, 0x25)                                   # ldx $25
    a.lda(OBJ_ATTR).emit(0x29, 0x60).stax(OBJ_ATTR)      # inherit facing+palette
    a.lda(OBJ_POSE).emit(0x48)                           # save the real pose
    a.lda(RT_WTMP).sta(OBJ_POSE)
    a.jsr(PB2_MUZZLE)                                    # position + muzzle offset
    a.emit(0x68).sta(OBJ_POSE)                           # and put it back
    a.op(0xAC, RT_WEAPON)
    a.lday(RT_WAUTO - 1).br(0xD0, 'nopose')
    # edge-triggered weapons get the stock throw animation and busy flag
    a.op(0xAC, RT_WTMP).emit(0x8C, _lo(OBJ_POSE), _hi(OBJ_POSE))
    a.lday(PB2_POSEMS).emit(0xA8)
    a.jsr(PB2_SETANIM)                                   # preserves X
    a.lda(OBJ_FLAGS).emit(0x09, 0x80).sta(OBJ_FLAGS)
    a.label('nopose')
    a.emit(0xA6, 0x25)                                   # ldx $25
    a.lda(RT_WEAPON).emit(0x38, 0xE9, 0x01)              # weapon - 1
    _dispatch(a, RT_SPTAB)
    return a.done()


def r_alloc(org, S):
    """The free-slot search Solbrain weapons use.  It cannot be build.py's
    RT_FINDSHOT: that one stops at P2_SLOT, and slot 4 is not free.  $A945
    runs every frame and, unless the player is wearing suit 4, wipes slots 4
    *and 5* the moment slot 4's metasprite field is non-zero -- which would
    delete player 2 as a side effect of firing.  So shots live in slots 1..3.

        A945  LDA $9A / CMP #$04 / BEQ $A95A
        A94B  LDA $0446 / BNE $A951 / RTS
        A951  LDX #$04 / JSR $C810 / INX / JMP $C810

    Returns X = the slot and Z set, or Z clear when the pool is full."""
    a = A(org)
    a.ldxi(0x01)
    a.label('lp').ldax(OBJ_TYPE).br(0xF0, 'found')
    a.emit(0xE8, 0xE0, SHOT_SLOTS).br(0xD0, 'lp')
    a.ldai(0x01)                                         # Z clear: none free
    a.label('found').rts()
    return a.done()


def r_spawn(org, S):
    """X = slot, A = object type, RT_WSPR = direction.  $A4FD has already put
    the muzzle position in the slot."""
    a = A(org)
    a.stax(OBJ_TYPE)
    a.lda(RT_WEAPON).emit(0x38, 0xE9, 0x01)
    a.emit(0x0A, 0x0A, 0x0A, 0x0A, 0x0A)                 # * 32
    a.sta(RT_WTMP)
    a.lda(RT_WSPR).emit(0x0A, 0x0A, 0x18)                # * 4
    a.op(0x6D, RT_WTMP).emit(0xA8)
    a.lday(RT_VEL + 0).stax(OBJ_VXF)
    a.lday(RT_VEL + 1).stax(OBJ_VXI)
    a.lday(RT_VEL + 2).stax(OBJ_VYF)
    a.lday(RT_VEL + 3).stax(OBJ_VYI)
    a.ldai(0x00).clear(OBJ_F18, OBJ_YF, OBJ_XF, OBJ_CROUCH)
    a.lda(RT_WSPR).stax(OBJ_DIR)
    a.op(0xAC, RT_WEAPON)
    a.lday(RT_WLIFE - 1).stax(OBJ_LIFE)
    a.lday(RT_WMSPR - 1).stax(OBJ_MSPR)
    a.rts()
    return a.done()


def r_shot(org, S):
    """Replaces $A573, the player-shot type switch.  Types below $10 take the
    exact path they always did."""
    a = A(org)
    a.emit(0xC9, 0x10).br(0x90, 'stock')
    a.emit(0xC9, 0x1C).br(0xB0, 'stock')
    a.emit(0x38, 0xE9, 0x10)
    _dispatch(a, RT_SHTAB)
    a.label('stock')
    a.emit(0xC9, 0x03).br(0xD0, 'knife')
    a.jmp(PB2_BEAM)
    a.label('knife').jmp(PB2_KNIFE)
    return a.done()


# --- shared helpers, all called with JSR from a handler --------------------

def r_negx(org, S):
    a = A(org)
    a.emit(0x38)
    a.ldai(0x00).op(0xFD, OBJ_VXF).stax(OBJ_VXF)
    a.ldai(0x00).op(0xFD, OBJ_VXI).stax(OBJ_VXI)
    a.rts()
    return a.done()


def r_negy(org, S):
    a = A(org)
    a.emit(0x38)
    a.ldai(0x00).op(0xFD, OBJ_VYF).stax(OBJ_VYF)
    a.ldai(0x00).op(0xFD, OBJ_VYI).stax(OBJ_VYI)
    a.rts()
    return a.done()


def r_step(org, S):
    """A = a signed delta -> -4, 0 or +4."""
    a = A(org)
    a.emit(0xC9, 0x80).br(0xB0, 'neg')
    a.emit(0xC9, 0x05).br(0x90, 'zero')
    a.ldai(0x04).rts()
    a.label('neg').emit(0xC9, 0xFC).br(0xB0, 'zero')
    a.ldai(0xFC).rts()
    a.label('zero').ldai(0x00).rts()
    return a.done()


def r_abs(org, S):
    a = A(org)
    a.emit(0xC9, 0x80).br(0x90, 'out')
    a.emit(0x49, 0xFF, 0x18, 0x69, 0x01)
    a.label('out').rts()
    return a.done()


def r_bounce(org, S):
    """Spend one of weapon 4's seven bounces.  Called with JSR from a handler,
    so the stack is [our return, $A56C] and the death path drops both."""
    a = A(org)
    a.decx(OBJ_LIFE).br(0xD0, 'alive')
    a.emit(0x68, 0x68).jmp(PB2_FREE)
    a.label('alive').ldai(SND_RICOCHET).jmp(PB2_SOUND)
    return a.done()


# --- the eight spawners ----------------------------------------------------

def _s_simple(kind, sound=SND_THROW):
    def f(org, S):
        a = A(org)
        a.ldai(kind).jsr(S['RT_SPAWN'])
        a.ldai(sound).jmp(PB2_SOUND)
        return a.done()
    return f


r_s1 = _s_simple(T_ORBIT)
r_s2 = _s_simple(T_BULLET)
r_s3 = _s_simple(T_RIFLE)
r_s4 = _s_simple(T_BOUNCE)
r_s7 = _s_simple(T_FLAME, SND_FLAME)
r_s8 = _s_simple(T_BOOM)


def r_s5(org, S):
    """Weapon 5: the pellet's life follows Power Blade 2's own charge counter
    ($54, thresholds $8D/$8E/$8F) and each pellet is skewed one step further
    along an eight-step cone."""
    a = A(org)
    a.ldai(T_FAN).jsr(S['RT_SPAWN'])
    a.emit(0xA5, 0x54, 0x4A, 0x4A, 0x4A, 0x4A, 0x18, 0x69, 0x0C)
    a.stax(OBJ_LIFE)
    a.op(0xAC, RT_WSEQ)
    a.lday(RT_FANDY).emit(0x18).op(0x7D, OBJ_VYI).stax(OBJ_VYI)
    a.op(0xEE, RT_WSEQ)
    a.lda(RT_WSEQ).emit(0x29, 0x07).sta(RT_WSEQ)
    a.ldai(SND_THROW).jmp(PB2_SOUND)
    return a.done()


def r_s6(org, S):
    """Weapon 6 scatters: every pellet leaves at a slightly different speed."""
    a = A(org)
    a.ldai(T_NAPALM).jsr(S['RT_SPAWN'])
    a.lda(RT_WSEQ).emit(0x29, 0x03, 0xA8)
    a.lday(RT_NAPX).emit(0x18).op(0x7D, OBJ_VXI).stax(OBJ_VXI)
    a.op(0xEE, RT_WSEQ)
    a.ldai(SND_THROW).jmp(PB2_SOUND)
    return a.done()


# --- the per-frame handlers, X = slot, entered with $A56C on the stack -----

def r_w1(org, S):
    """Weapon 1: a whip that orbits the player, ignoring terrain."""
    a = A(org)
    a.ldax(OBJ_F18).emit(0xA8)
    a.lda(OBJ_Y).emit(0x18).op(0x79, RT_ORBY).stax(OBJ_Y)
    a.lda(OBJ_X).emit(0x18).op(0x79, RT_ORBX).stax(OBJ_X)
    a.ldai(0x00).clear(OBJ_YHI, OBJ_XHI)
    a.emit(0xC8, 0x98, 0x29, 0x0F).stax(OBJ_F18)
    a.ldax(OBJ_LIFE).emit(0x29, 0x02).br(0xF0, 'even')
    a.ldai(0x46).br(0xD0, 'put')
    a.label('even').ldai(0x45)
    a.label('put').stax(OBJ_MSPR)
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.jmp(PB2_FREE)
    a.label('out').rts()
    return a.done()


def r_w2a(org, S):
    """Weapon 2's bullet: explodes on the first solid cell it enters."""
    a = A(org)
    a.ldai(0x00).emit(0xA8).jsr(PB2_SOLID).br(0x30, 'boom')
    a.jsr(PB2_MOVEKILL)
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.label('boom')
    a.ldai(T_BLAST).stax(OBJ_TYPE)
    a.ldai(0x00).clear(OBJ_VXI, OBJ_VXF, OBJ_VYI, OBJ_VYF, OBJ_F18)
    a.ldai(0x04).stax(OBJ_LIFE)
    a.ldai(0x3E).stax(OBJ_MSPR)
    a.ldai(SND_BOOM).jmp(PB2_SOUND)
    a.label('out').rts()
    return a.done()


def r_w2b(org, S):
    """... and its three-stage blast."""
    a = A(org)
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.incx(OBJ_F18)
    a.ldax(OBJ_F18).emit(0xA8, 0xC0, 0x03).br(0xB0, 'die')
    a.lday(RT_W2LIFE).stax(OBJ_LIFE)
    a.lday(RT_W2SPR).stax(OBJ_MSPR)
    a.label('out').rts()
    a.label('die').jmp(PB2_FREE)
    return a.done()


def r_w3(org, S):
    """Weapon 3: a straight, piercing bullet that dies off-screen."""
    a = A(org)
    a.jsr(PB2_MOVEKILL).rts()
    return a.done()


def r_w4(org, S):
    """Weapon 4: bounces off terrain on both axes, seven bounces then gone.
    An axis it is not moving along is not probed -- otherwise a horizontal
    shot spends a bounce on the floor the player is standing on."""
    a = A(org)
    a.ldax(OBJ_VXI).br(0x30, 'xneg').br(0xD0, 'xpos')
    a.ldax(OBJ_VXF).br(0xF0, 'noxhit')
    a.label('xpos').ldai(0x08).br(0xD0, 'xdo')
    a.label('xneg').ldai(0xF8)
    a.label('xdo').ldyi(0x00).jsr(PB2_SOLID).br(0x10, 'noxhit')
    a.jsr(S['RT_NEGX']).jsr(S['RT_BOUNCE'])
    a.label('noxhit')
    a.ldax(OBJ_VYI).br(0x30, 'yneg').br(0xD0, 'ypos')
    a.ldax(OBJ_VYF).br(0xF0, 'noyhit')
    a.label('ypos').ldyi(0x08).br(0xD0, 'ydo')
    a.label('yneg').ldyi(0xF8)
    a.label('ydo').ldai(0x00).jsr(PB2_SOLID).br(0x10, 'noyhit')
    a.jsr(S['RT_NEGY']).jsr(S['RT_BOUNCE'])
    a.label('noyhit')
    a.jsr(PB2_MOVEKILL).rts()
    return a.done()


def r_w5(org, S):
    a = A(org)
    a.jsr(PB2_MOVEKILL)
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.jmp(PB2_FREE)
    a.label('out').rts()
    return a.done()


def r_w6a(org, S):
    """Weapon 6 in the air; after six frames it lands and starts crawling."""
    a = A(org)
    a.jsr(PB2_MOVEKILL)
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.ldai(T_CRAWL).stax(OBJ_TYPE)
    a.ldai(0x86).stax(OBJ_LIFE)
    a.ldai(0x46).stax(OBJ_MSPR)
    a.ldax(OBJ_VXI).br(0x30, 'left')
    a.ldai(0x01).br(0xD0, 'set')
    a.label('left').ldai(0xFF)
    a.label('set').stax(OBJ_VXI)
    a.ldai(0x00).clear(OBJ_VXF, OBJ_VYI, OBJ_VYF)
    a.label('out').rts()
    return a.done()


def r_w6b(org, S):
    """... and along the floor, turning at walls and falling down holes."""
    a = A(org)
    a.ldai(0x00).ldyi(0x0A).jsr(PB2_SOLID).br(0x30, 'floor')
    a.incx(OBJ_Y)
    a.label('floor')
    a.ldax(OBJ_VXI).br(0x10, 'xpos')
    a.ldai(0xF8).br(0xD0, 'xdo')
    a.label('xpos').ldai(0x08)
    a.label('xdo').ldyi(0x00).jsr(PB2_SOLID).br(0x10, 'nowall')
    a.jsr(S['RT_NEGX'])
    a.label('nowall')
    a.jsr(PB2_MOVEKILL)
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.jmp(PB2_FREE)
    a.label('out').rts()
    return a.done()


def r_w7(org, S):
    """Weapon 7 is a hitbox, not a projectile: it is glued 20 px in front of
    the player for nine frames."""
    a = A(org)
    a.lda(OBJ_Y).stax(OBJ_Y)
    a.lda(OBJ_ATTR).emit(0x29, 0x40).br(0xF0, 'right')
    a.lda(OBJ_X).emit(0x38, 0xE9, 0x14).br(0xB0, 'putx')
    a.ldai(0x00).br(0xF0, 'putx')
    a.label('right')
    a.lda(OBJ_X).emit(0x18, 0x69, 0x14).br(0x90, 'putx')
    a.ldai(0xFF)
    a.label('putx').stax(OBJ_X)
    a.ldai(0x00).clear(OBJ_YHI, OBJ_XHI)
    a.lda(OBJ_ATTR).emit(0x29, 0x60).stax(OBJ_ATTR)
    a.ldax(OBJ_LIFE).emit(0xC9, 0x05).br(0xB0, 'keep')
    a.ldai(0x47).stax(OBJ_MSPR)
    a.label('keep')
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.jmp(PB2_FREE)
    a.label('out').rts()
    return a.done()


def r_w8a(org, S):
    """Weapon 8 outbound: thirteen frames, then it turns around."""
    a = A(org)
    a.jsr(PB2_MOVEKILL)
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.ldai(T_BOOMR).stax(OBJ_TYPE)
    a.ldai(0x48).stax(OBJ_MSPR)
    a.ldai(0x78).stax(OBJ_LIFE)
    a.label('out').rts()
    return a.done()


def r_w8b(org, S):
    """... and homing back, per axis, until it is within 8 px of the player."""
    a = A(org)
    a.lda(OBJ_X).emit(0x38).op(0xFD, OBJ_X)
    a.jsr(S['RT_STEP']).stax(OBJ_VXI)
    a.ldai(0x00).stax(OBJ_VXF)
    a.lda(OBJ_Y).emit(0x38).op(0xFD, OBJ_Y)
    a.jsr(S['RT_STEP']).stax(OBJ_VYI)
    a.ldai(0x00).stax(OBJ_VYF)
    a.jsr(PB2_MOVEKILL)
    a.lda(OBJ_X).emit(0x38).op(0xFD, OBJ_X)
    a.jsr(S['RT_ABS']).emit(0xC9, 0x08).br(0xB0, 'alive')
    a.lda(OBJ_Y).emit(0x38).op(0xFD, OBJ_Y)
    a.jsr(S['RT_ABS']).emit(0xC9, 0x08).br(0x90, 'die')
    a.label('alive')
    a.decx(OBJ_LIFE).br(0xD0, 'out')
    a.label('die').jmp(PB2_FREE)
    a.label('out').rts()
    return a.done()


def r_kill(org, S):
    """The spare type $1B: free the slot at once."""
    a = A(org)
    a.jmp(PB2_FREE)
    return a.done()


# --- the two collision-table overrides, called from bank 7 ----------------

def _table_override(tbl, stock):
    """Y = attacker slot, X = defender slot -- X must survive, $B698 and $B606
    both use it afterwards.  Gating on the object type rather than on
    RT_WEAPON means a shot still in flight when the weapon changes keeps its
    own numbers."""
    def f(org, S):
        a = A(org)
        a.lday(OBJ_TYPE)
        a.emit(0x38, 0xE9, 0x10, 0xC9, 0x0C).br(0xB0, 'stock')
        a.emit(0xA8)
        a.lday(tbl).rts()
        a.label('stock')
        a.lday(OBJ_TYPE).emit(0xA8)
        a.lday(stock).rts()
        return a.done()
    return f


r_dmgl = _table_override(RT_TDMG, PB2_DMGTAB)
r_rad = _table_override(RT_TRAD, PB2_RADTAB)


# ===========================================================================
# linking
# ===========================================================================
ROUTINES = [
    ('RT_WSEL', r_wsel), ('RT_SETCHR', r_setchr), ('RT_TICK', r_tick),
    ('RT_WHUD', r_whud), ('RT_HUDW', r_hudw), ('RT_PAY', r_pay),
    ('RT_TRIG', r_trig), ('RT_FIRE', r_fire), ('RT_SPAWN', r_spawn),
    ('RT_SHOT', r_shot), ('RT_ALLOC', r_alloc),
    ('RT_NEGX', r_negx), ('RT_NEGY', r_negy), ('RT_STEP', r_step),
    ('RT_ABS', r_abs), ('RT_BOUNCE', r_bounce),
    ('RT_S1', r_s1), ('RT_S2', r_s2), ('RT_S3', r_s3), ('RT_S4', r_s4),
    ('RT_S5', r_s5), ('RT_S6', r_s6), ('RT_S7', r_s7), ('RT_S8', r_s8),
    ('RT_W1', r_w1), ('RT_W2A', r_w2a), ('RT_W2B', r_w2b), ('RT_W3', r_w3),
    ('RT_W4', r_w4), ('RT_W5', r_w5), ('RT_W6A', r_w6a), ('RT_W6B', r_w6b),
    ('RT_W7', r_w7), ('RT_W8A', r_w8a), ('RT_W8B', r_w8b),
    ('RT_KILL', r_kill), ('RT_DMGL', r_dmgl), ('RT_RAD', r_rad),
]


class _Sym(dict):
    """Unknown symbols answer with a placeholder during the sizing pass; every
    reference is a 3-byte absolute one, so sizes do not depend on the answer."""
    def __missing__(self, k):
        return 0x7FFF


def free_blocks(pay):
    """The zero runs CODE_REGIONS still has in this payload, largest first."""
    out = []
    for lo, hi in CODE_REGIONS:
        run = None
        for a in range(lo, hi + 1):
            free = a < hi and pay[a - WRAM] == 0
            if free and run is None:
                run = a
            elif not free and run is not None:
                if a - run >= 3:
                    out.append([run, a])
                run = None
    out.sort(key=lambda r: r[0] - r[1])
    return out


def link(free):
    """Place every routine in the free work-RAM fragments and resolve the
    cross-references.  Returns {name: address} and {name: bytes}."""
    sizes = {n: len(f(0x7000, _Sym())) for n, f in ROUTINES}
    free = [list(r) for r in free]
    addr = {}
    for n in sorted(sizes, key=lambda n: -sizes[n]):
        for r in free:
            if r[1] - r[0] >= sizes[n]:
                addr[n] = r[0]
                r[0] += sizes[n]
                break
        else:
            raise AssertionError(f"no room left for {n} ({sizes[n]} bytes)")
    syms = _Sym(addr)
    code = {}
    for n, f in ROUTINES:
        code[n] = f(addr[n], syms)
        assert len(code[n]) == sizes[n], n
    return addr, code


def tables(sym):
    """Every table this runtime reads, as {address: bytes}."""
    orbx, orby = _orbit()
    t = {
        RT_WCHR:   bytes(CHRBANK),
        RT_WCOSTL: bytes(c & 0xFF for c in COST),
        RT_WCOSTH: bytes(c >> 8 for c in COST),
        RT_WCDT:   bytes(CDT),
        RT_WAUTO:  bytes(AUTO),
        RT_WLIFE:  bytes(LIFE),
        RT_WMSPR:  bytes(MSPR),
        RT_TDMG:   bytes(TDMG),
        RT_TRAD:   bytes(TRAD),
        RT_ORBX:   orbx,
        RT_ORBY:   orby,
        RT_FANDY:  bytes((0xFE, 0xFF, 0xFF, 0x00, 0x00, 0x01, 0x01, 0x02)),
        RT_NAPX:   bytes((0x00, 0x01, 0xFF, 0x02)),
        RT_W2LIFE: bytes((0x04, 0x04, 0x05)),
        RT_W2SPR:  bytes((0x3E, 0x40, 0x42)),
        RT_VEL:    b''.join(_vel_block(s) for s in SPEED),
        RT_ACCL:   bytes((0x00, 0x06)),          # one whole bar unit in hand
    }
    handlers = ('RT_W1', 'RT_W2A', 'RT_W2B', 'RT_W3', 'RT_W4', 'RT_W5',
                'RT_W6A', 'RT_W6B', 'RT_W7', 'RT_W8A', 'RT_W8B', 'RT_KILL')
    t[RT_SHTAB] = b''.join(bytes((_lo(sym[h]), _hi(sym[h]))) for h in handlers)
    spawners = tuple('RT_S%d' % i for i in range(1, 9))
    t[RT_SPTAB] = b''.join(bytes((_lo(sym[s]), _hi(sym[s]))) for s in spawners)
    return t


# ===========================================================================
# CHR
# ===========================================================================
def _mirror(tile):
    """Horizontally flip one 2bpp tile."""
    rev = lambda b: int('{:08b}'.format(b)[::-1], 2)
    return bytes(rev(b) for b in tile)


# (source offset in sol_weapon_tiles.bin, destination pattern tile, mirrored?)
# Every weapon's art has to land inside tiles $50-$5F, which is exactly the
# 256-byte window in which CHR banks $11 and $12 already differ, and exactly
# the window the metasprite records Power Blade 2 uses for its own shots read.
TILE_MAP = [
    # 1 orbit whip: two animation frames, each an 8x16 sprite plus its mirror
    [(0x0080, 0x50), (0x0090, 0x51), (0x0080, 0x52, 1), (0x0090, 0x53, 1),
     (0x00A0, 0x58), (0x00B0, 0x59), (0x00A0, 0x5A, 1), (0x00B0, 0x5B, 1)],
    # 2 grenade: bullet on record $46, blast stage 1 on $3E, 2-3 on $40/$42
    [(0x0100, 0x58), (0x0110, 0x59),
     (0x0120, 0x50), (0x0130, 0x51), (0x0120, 0x52, 1), (0x0130, 0x53, 1),
     (0x0140, 0x5C), (0x0150, 0x5D), (0x0160, 0x5E), (0x0170, 0x5F)],
    # 3 burst rifle: the shot, plus the muzzle flash on the spare record
    [(0x0220, 0x50), (0x0230, 0x51), (0x0240, 0x52), (0x0250, 0x53),
     (0x0200, 0x58), (0x0210, 0x59), (0x0200, 0x5A, 1), (0x0210, 0x5B, 1)],
    # 4 bouncer
    [(0x02A0, 0x50), (0x02B0, 0x51), (0x02C0, 0x52), (0x02D0, 0x53)],
    # 5 fan pellet
    [(0x0320, 0x50), (0x0330, 0x51), (0x0320, 0x52, 1), (0x0330, 0x53, 1)],
    # 6 napalm: airborne, then the crawling frame
    [(0x0380, 0x50), (0x0390, 0x51), (0x0380, 0x52, 1), (0x0390, 0x53, 1),
     (0x03A0, 0x58), (0x03B0, 0x59), (0x03A0, 0x5A, 1), (0x03B0, 0x5B, 1)],
    # 7 flame: the 32x16 burst on record $41, the 16x16 sustain on $47
    [(0x04C0 + 16 * i, 0x54 + i) for i in range(8)] +
    [(0x0560 + 16 * i, 0x5C + i) for i in range(4)],
    # 8 boomerang: the same art on records $45 (out) and $48 (H-flipped, back)
    [(0x05E0, 0x50), (0x05F0, 0x51), (0x0600, 0x52), (0x0610, 0x53),
     (0x05E0, 0x58), (0x05F0, 0x59), (0x0600, 0x5A), (0x0610, 0x5B)],
]


def weapon_chr(img, sol_tiles):
    """Eight copies of CHR bank $11 with pattern tiles $50-$5F replaced."""
    base = bytes(img.chr[0x11 * 0x400: 0x12 * 0x400])
    out = []
    for groups in TILE_MAP:
        bank = bytearray(base)
        # blank the window first: a weapon that uses fewer than sixteen tiles
        # must not show the stock beam's art in the leftovers
        bank[0x100:0x200] = bytes(0x100)
        for g in groups:
            src, dst = g[0], g[1]
            tile = sol_tiles[src:src + 16]
            if len(g) > 2 and g[2]:
                tile = _mirror(tile)
            off = (dst - 0x40) * 16
            bank[off:off + 16] = tile
        out.append(bytes(bank))
    return out


# ===========================================================================
# installation
# ===========================================================================
PATCHES_9 = (
    # (cpu, original, replacement builder)
    (0xA1F8, b'\xA5\x48\x29\x40\xF0\x27', 'RT_FIRE', 0x4C, 3),
    (0xA573, b'\xC9\x03\xD0\x03\x4C\xFB\xA7', 'RT_SHOT', 0x4C, 4),
)
PATCHES_7 = (
    (0xB5F0, b'\xB9\x00\x04\xA8\xB9\x25\xB7', 'RT_RAD', 0x20, 4),
    (0xB68F, b'\xB9\x00\x04\xA8\xB9\x21\xB7', 'RT_DMGL', 0x20, 4),
)
# the five sites that load MMC3 R3's shadow with a constant
PATCHES_CHR = (0xCE06, 0xD036, 0xD319)


def install(img):
    """Add the weapon runtime to the payload bank and patch the ROM."""
    # --- the payload bank --------------------------------------------------
    pay = bytearray(img.get_prg(PAYLOAD_BANK))

    def put(addr, data, what):
        a = addr - WRAM
        assert pay[a:a + len(data)] == bytes(len(data)), \
            f"{what} at ${addr:04X} is not free in the payload bank"
        pay[a:a + len(data)] = data

    # build.py grows its breakable-block record pool upwards from RT_CRPOOL
    # towards RT_CREND; the first code region starts inside that headroom, so
    # fail loudly here rather than let the pool silently overwrite the code.
    assert getattr(img, 'crate_pool', 0) <= CODE_REGIONS[0][0], \
        "the crate pool has grown into the weapon runtime -- move CODE_REGIONS[0]"

    sym, code = link(free_blocks(pay))
    for addr, data in sorted(tables(sym).items()):
        put(addr, data, 'table')
    for name, blob in sorted(code.items(), key=lambda kv: sym[kv[0]]):
        put(sym[name], blob, name)
    img.put_prg(PAYLOAD_BANK, bytes(pay))

    # --- CHR: eight banks for MMC3 R3 --------------------------------------
    import os
    tiles = open(os.path.join(build.ROOT, 'work/re/sol_weapon_tiles.bin'), 'rb').read()
    for bank, data in zip(CHRBANK, weapon_chr(img, tiles)):
        img.put_chr(bank, data)

    # --- Power Blade 2's own code ------------------------------------------
    def patch(bank, cpu, base, old, new):
        assert img.read(bank, cpu, base, len(old)) == old, \
            f"bank {bank} ${cpu:04X}: {img.read(bank, cpu, base, len(old)).hex()}"
        assert len(new) == len(old)
        img.patch(bank, cpu, base, new)

    for cpu, old, name, op, pad in PATCHES_9:
        patch(9, cpu, 0xA000, old,
              asm(op, _lo(sym[name]), _hi(sym[name])) + b'\xEA' * pad)
    for cpu, old, name, op, pad in PATCHES_7:
        patch(7, cpu, 0xA000, old,
              asm(op, _lo(sym[name]), _hi(sym[name])) + b'\xEA' * pad)

    jsr_setchr = asm(0x20, _lo(sym['RT_SETCHR']), _hi(sym['RT_SETCHR']), 0xEA)
    for cpu in PATCHES_CHR:
        patch(62, cpu, 0xC000, b'\xA9\x11\x85\x45', jsr_setchr)
    # $D290/$D294 are not a clean four bytes: $D28E branches over the first
    # LDA to the second.  Both arms have to reach RT_SETCHR, which reads $9A
    # itself, so the first arm becomes padding and the call goes at $D294.
    patch(62, 0xD290, 0xC000, b'\xA9\x11\xD0\x02\xA9\x12\x85\x45',
          b'\xEA\xEA\xEA\xEA' + jsr_setchr)

    patch(62, 0xCDCB, 0xC000, b'\x4C\x59\xD2',
          asm(0x4C, _lo(sym['RT_WSEL']), _hi(sym['RT_WSEL'])))
    patch(62, 0xCEFD, 0xC000, b'\x20\xBE\xD2',
          asm(0x20, _lo(sym['RT_TICK']), _hi(sym['RT_TICK'])))
    patch(62, 0xD67E, 0xC000, b'\x20\xC1\xD5',
          asm(0x20, _lo(sym['RT_HUDW']), _hi(sym['RT_HUDW'])))

    img.weapon_sym = sym
    return img


# ---------------------------------------------------------------------------
# NOTES -- where the ROM disagreed with work/re/pb3_weapon_plan.md
#
# * The plan's work-RAM map is stale: $6E00 is now build.py's crate hook,
#   $7000-$72FF is the menu and its tables, and $7330-$7F00 is the crate pool.
#   The runtime is scattered over the eight fragments in CODE_REGIONS instead,
#   and install() asserts each is still free.
# * $D290 is NOT `A9 11 85 45`.  It is `A9 11 / D0 02 / A9 12 / 85 45` with
#   $D28E branching to $D294, so the plan's four-byte replacement would have
#   destroyed a branch target.  Patched as an eight-byte block instead.
# * $D6D4 *does* clear field 18 ($058C) -- the plan says it does not.
# * $A3D9's cap counts only slots 1..3 and depends on $99 (which is 0 in PB3),
#   so Solbrain weapons use RT_ALLOC instead.  And the pool is slots 1..3, not
#   1..4: $A945 wipes slots 4 and 5 every frame unless the suit is number 4.
#   Weapons 3, 5 and 6 are therefore three shots deep, not four.
# * $A7B9 is exactly "integrate, and free the slot the moment it leaves the
#   screen", with the PLA/PLA a handler-level JSR needs.  It replaces the
#   plan's hand-written RT_MOVE.
# * Damage and radius are keyed off the object type, not RT_WEAPON, so the
#   plan's `cpy #$05` slot gate is unnecessary and a shot still in flight when
#   the weapon changes keeps its own numbers.
# * $1B is not a sound id Power Blade 2 ever plays; the explosion uses $24.
# * The CHR banks are 248-255 (the tail of Solbrain's own CHR, which PB3 never
#   reads at run time), not the all-zero duplicates the plan named -- mkpb3.py
#   now writes converted-stage patterns over those.
# ---------------------------------------------------------------------------
