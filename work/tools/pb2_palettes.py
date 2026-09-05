"""Power Blade 2 (USA) — palettes and CHR bank assignment, decoded from ROM.

Everything here is proven against the running game (see `work/re/pb2_palettes.md`).

PALETTES
--------
The area record (5th per-stage table, `$E2BC`) ends with two selector bytes:

    byte 12 -> $016D   "palette set A"   full 32-byte palette
    byte 13 -> $016E   "palette set B"   one sub-palette, forced into slot 7

`$CEC0` (bank 14) runs them::

    LDA $016D / JSR $ED1C -> bank 0 $801B -> $8044   full set
    LDA $016E / LDX #$07
              / JSR $ED30 -> bank 0 $801E -> $8080   one slot
    JMP $D8E4: LDA $9A / ADC #$3D / LDX #$05 / JSR $ED30   player-suit slot
               JMP $ED48 -> bank 0 $8021 -> $80AB          upload

Tables, all in PRG bank 0 (mapped at $8000 by `$ECA7` with Y=$30):

    $811F  palette-set-A pointer table, 47 words -> an 8-byte list of
           sub-palette indices, one per $3F00 slot.  Data $817D..$82F4.
    $82F5  sub-palette pointer LO, 136 bytes
    $837D  sub-palette pointer HI, 136 bytes
    $8405  136 sub-palettes, 3 bytes each (colours 1,2,3).  Colour 0 of every
           slot is hard-coded $0F by `$8066`/`$8096`.

The assembled 32 bytes live in RAM at $03E0..$03FF and `$80AB` queues them to
$3F00 through the VBlank write queue at $0300.

CHR
---
PPUCTRL is $A9 during play: bit4 = 0, so the BACKGROUND pattern table is
$0000-$0FFF, driven by MMC3 R0/R1 = area record bytes 7/8 (written *2).
Sprites are 8x16 (bit5 = 1), so a sprite tile picks its half by tile bit 0.

    $0000-$07FF  R0 = rec[7]*2      background, per area
    $0800-$0FFF  R1 = rec[8]*2      background, per area
    $1000-$13FF  R2 = $EF3F[$0442] (+6 if suit != 0 and frame < $1F)  player
    $1400-$17FF  R3 = $11 (suit 0) / $12 (suit != 0)                  player
    $1800-$1BFF  R4 = rec[9]        objects, per area
    $1C00-$1FFF  R5 = rec[10]       objects, per area

R1 is then ANIMATED: `$D125` (bank pair 4) -> `$8018` -> `$BEC9` reads a
per-stage/per-area base byte out of `$BEEC` into `$5D` and clears `$5C`;
`$D130` -> `$801B` -> `$BF32` runs every frame and does `$43 = $5D + $5C`
with `$5C` cycling 0,1,2 every 8 frames.  So the second half of the
background pattern table steps through three consecutive 2 KB banks.
A base byte of $FF disables the animation and leaves R1 at rec[8].
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom

# --- bank 0 (palette engine) --------------------------------------------------
SETA_PTR      = 0x811F          # 47 words
SUBPAL_LO     = 0x82F5          # 136 bytes
SUBPAL_HI     = 0x837D          # 136 bytes
SUBPAL_DATA   = 0x8405          # 136 * 3
PAL_BUF       = 0x03E0          # RAM, 32 bytes, uploaded to $3F00
BG_COLOR      = 0x0F            # hard-coded colour 0 of every slot

# --- bank 15 ------------------------------------------------------------------
AREA_REC_TBL  = 0xE2BC          # 7 words -> a word slot in bank pair 6/7
# $F04C: where the walk-on stands the hero when an area is opened.  Seven
# tables of one byte an area -- the high nibble is the row, the low nibble the
# column, and the eighth table is not a stage but the boss rooms ($79).
AREA_START_TBL = 0xF0A4
# $8551 (bank 10): six tables of two bytes an area -- where on the screen the
# door at the end of that area is drawn open.  The seventh stage has none: it
# is the boss rooms, and they have no doors.
DOOR_VRAM_TBL = 0x8587
BOSS_VRAM_TBL = 0x843D
DOOR_PAIR     = 10
EF3F          = 0xEF3F          # 62 bytes: player anim frame -> CHR R2
EF3F_LEN      = 62
AREA_PAIR     = 6               # $ECA7 is called with Y=$36 -> pair 6/7

# --- bank pair 4/5 (background animation) ------------------------------------
ANIM_PAIR     = 4               # $D125/$D130 call $ECA7 with Y=$34
ANIM_PTR      = 0xBEEC          # 7 words -> one base byte per area
ANIM_CYCLE    = 3               # $BF80 CMP #$03

NSTAGES       = 7
SUIT_SLOT     = 5               # $D8E9 LDX #$05
SUIT_SUBPAL0  = 0x3D            # $D8E7 ADC #$3D
SETB_SLOT     = 7               # $CECA LDX #$07
NSUITS        = 5               # $9A = 0..4


class PB2Palettes:
    def __init__(self, rom_path="Power Blade 2 (USA).nes"):
        self.rom  = Rom(rom_path)
        self.b0   = self.rom.bank(0)
        self.b15  = self.rom.bank(15)
        self.pair = self.rom.bank(AREA_PAIR) + self.rom.bank(AREA_PAIR + 1)
        self.apair = self.rom.bank(ANIM_PAIR) + self.rom.bank(ANIM_PAIR + 1)
        self.door = self.rom.bank(DOOR_PAIR) + self.rom.bank(DOOR_PAIR + 1)

        self._seta = self._ptr_table(SETA_PTR)              # 47 addresses
        n = SUBPAL_HI - SUBPAL_LO                           # 136
        self._subpal = [self._b0(SUBPAL_LO + i) | (self._b0(SUBPAL_HI + i) << 8)
                        for i in range(n)]
        self.ef3f = [self._b15(EF3F + i) for i in range(EF3F_LEN)]

    # -- raw reads ------------------------------------------------------------
    def _b0(self, a):   return self.b0[a - 0x8000]
    def _b15(self, a):  return self.b15[a - 0xE000]
    def _w0(self, a):   return self._b0(a) | (self._b0(a + 1) << 8)
    def _w15(self, a):  return self._b15(a) | (self._b15(a + 1) << 8)
    def _p(self, a):    return self.pair[a - 0x8000]
    def _wp(self, a):   return self._p(a) | (self._p(a + 1) << 8)
    def _a(self, a):    return self.apair[a - 0x8000]
    def _d(self, a):    return self.door[a - 0x8000]
    def _wd(self, a):   return self._d(a) | (self._d(a + 1) << 8)
    def _wa(self, a):   return self._a(a) | (self._a(a + 1) << 8)

    @staticmethod
    def _grow(word, base, lo=0x8000, hi=0xC000):
        """A pointer table runs until the lowest address it points at."""
        out, limit, a = [], 0xFFFF, base
        while a < limit:
            v = word(a)
            if not lo <= v < hi:
                break
            limit = min(limit, v)
            out.append(v)
            a += 2
        return out

    def _ptr_table(self, base):
        return self._grow(self._w0, base)

    # -- palettes -------------------------------------------------------------
    def count_a(self):  return len(self._seta)      # 47
    def count_b(self):  return len(self._subpal)    # 136

    def set_a_indices(self, i):
        """The 8 sub-palette indices palette set `i` is made of."""
        a = self._seta[i]
        return [self._b0(a + k) for k in range(8)]

    def subpalette(self, i):
        """One 4-byte $3F00 slot: hard $0F plus the three ROM colours."""
        a = self._subpal[i]
        return [BG_COLOR] + [self._b0(a + k) for k in range(3)]

    def palette_set_a(self, i):
        """32 NES colour indices, exactly what `$8044` builds in $03E0."""
        out = []
        for s in self.set_a_indices(i):
            out += self.subpalette(s)
        return out

    def palette_set_b(self, i):
        """The 4 bytes `$8080` writes; `$CECC` puts them in slot 7."""
        return self.subpalette(i)

    def suit_palette(self, suit=0):
        """Slot 5, written by `$D8E4` from $9A."""
        return self.subpalette(SUIT_SUBPAL0 + suit)

    # -- area records ---------------------------------------------------------
    def area_table(self, stage):
        slot = self._w15(AREA_REC_TBL + stage * 2)
        return self._wp(slot)

    def area_pointers(self, stage):
        return self._grow(self._wp, self.area_table(stage))

    def n_areas(self, stage):
        return len(self.area_pointers(stage))

    def area_record(self, stage, area):
        a = self.area_pointers(stage)[area]
        return [self._p(a + k) for k in range(14)]

    def area_starts(self, stage):
        """One byte an area: where the walk-on stands the hero."""
        a = self._w15(AREA_START_TBL + stage * 2)
        return [self._b15(a + k) for k in range(self.n_areas(stage))]

    def area_start(self, stage, area):
        """Where the hero stands when this area is opened -- $F04C.

        `$04C6` (down) is the byte's high nibble with fifteen underneath it;
        `$0508` (along) is the low nibble shifted up into a whole cell.  Which
        way he faces is bit six of `$042C`, set when he is past the middle of
        the screen and cleared when he is on it or before it.
        """
        b = self.area_starts(stage)[area]
        x = (b << 4) & 0xF0
        return dict(x=x, y=(b & 0xF0) | 0x0F, face=1 if x > 0x80 else 0)

    def area_door(self, stage, area):
        """Where the door of this area is drawn open -- two bytes, high first.

        The cartridge keeps them in the thing's own fields ($05FA and $0610)
        and walks them backwards a row at a time as the door opens.
        """
        if stage * 2 >= 12:
            return [0, 0]
        a = self._wd(DOOR_VRAM_TBL + stage * 2)
        return [self._d(a + area * 2), self._d(a + area * 2 + 1)]

    def boss_door(self, stage):
        """Where the way to the boss is drawn -- two bytes, high first.

        $843D in bank 10, one pair per stage, read by the thing of type $03
        that stands at the end of a stage and opens the boss's room.
        """
        if stage * 2 >= 12:
            return [0, 0]
        return [self._d(BOSS_VRAM_TBL + stage * 2),
                self._d(BOSS_VRAM_TBL + stage * 2 + 1)]

    def area_palette_ids(self, stage, area):
        r = self.area_record(stage, area)
        return r[12], r[13]

    def area_palette(self, stage, area, suit=0):
        """The 32 bytes that end up at $3F00 for this area, in load order."""
        ia, ib = self.area_palette_ids(stage, area)
        pal = self.palette_set_a(ia)
        pal[SETB_SLOT * 4:SETB_SLOT * 4 + 4] = self.palette_set_b(ib)
        pal[SUIT_SLOT * 4:SUIT_SLOT * 4 + 4] = self.suit_palette(suit)
        return pal

    # -- CHR ------------------------------------------------------------------
    def r2_for_frame(self, frame, suit=0):
        """$EF03: player animation frame -> the 1 KB bank at $1000."""
        v = self.ef3f[frame] if frame < EF3F_LEN else None
        if v is None:
            return None
        if frame < 0x1F and suit:
            v = (v + 6) & 0xFF
        return v

    def r3_for_suit(self, suit=0):
        return 0x12 if suit else 0x11        # $D290 / $D294

    def area_chr(self, stage, area, frame=0, suit=0):
        """MMC3 R2..R5 = the four 1 KB banks at $1000-$1FFF (SPRITES)."""
        r = self.area_record(stage, area)
        return (self.r2_for_frame(frame, suit), self.r3_for_suit(suit),
                r[9], r[10])

    def bg_anim_base(self, stage, area):
        """`$BEC9`: the $5D base for the animated half of the background."""
        lst = self._wa(ANIM_PTR + stage * 2)
        return self._a(lst + area)

    def area_bg_chr(self, stage, area, phase=0):
        """The four 1 KB banks at $0000-$0FFF, i.e. the BACKGROUND tiles.

        Returns (r0, r1, banks).  `phase` is $5C (0..2); R1 walks
        base+0, base+1, base+2 unless the base byte is $FF."""
        r = self.area_record(stage, area)
        base = self.bg_anim_base(stage, area)
        v1 = r[8] if base == 0xFF else (base + phase % ANIM_CYCLE)
        r0, r1 = (r[7] * 2) & 0xFE, (v1 * 2) & 0xFE
        return r0, r1, [r0, r0 + 1, r1, r1 + 1]

    def area_bg_chr_phases(self, stage, area):
        """All the $0000-$0FFF bank sets this area cycles through."""
        base = self.bg_anim_base(stage, area)
        n = 1 if base == 0xFF else ANIM_CYCLE
        return [self.area_bg_chr(stage, area, p)[2] for p in range(n)]

    def area_chr_full(self, stage, area, frame=0, suit=0, phase=0):
        """All eight 1 KB CHR banks, $0000-$1FFF, in address order."""
        _, _, bg = self.area_bg_chr(stage, area, phase)
        return bg + list(self.area_chr(stage, area, frame, suit))


def _hex(xs):
    return ' '.join('%02X' % x for x in xs)


if __name__ == '__main__':
    p = PB2Palettes(sys.argv[1] if len(sys.argv) > 1
                    else "Power Blade 2 (USA).nes")

    print("== palette set A: %d sets, table $%04X, data $%04X..$%04X =="
          % (p.count_a(), SETA_PTR, p._seta[0], p._seta[-1] + 7))
    for i in range(p.count_a()):
        idx = p.set_a_indices(i)
        pal = p.palette_set_a(i)
        print("  A%02d ($%04X) sub=[%s]" % (i, p._seta[i], _hex(idx)))
        print("        bg  %s | %s | %s | %s"
              % tuple(_hex(pal[k*4:k*4+4]) for k in range(4)))
        print("        spr %s | %s | %s | %s"
              % tuple(_hex(pal[16+k*4:20+k*4]) for k in range(4)))

    print("\n== palette set B / sub-palettes: %d, ptr $%04X/$%04X, data $%04X =="
          % (p.count_b(), SUBPAL_LO, SUBPAL_HI, SUBPAL_DATA))
    for i in range(p.count_b()):
        print("  B%03d ($%04X) %s" % (i, p._subpal[i], _hex(p.palette_set_b(i))),
              end='\n' if i % 4 == 3 else '   ')
    print()

    print("\n== player suit palettes (slot %d, sub-palette $%02X+$9A) =="
          % (SUIT_SLOT, SUIT_SUBPAL0))
    for s in range(NSUITS):
        print("  suit %d -> B%03d %s" % (s, SUIT_SUBPAL0 + s,
                                         _hex(p.suit_palette(s))))

    print("\n== $EF3F: player anim frame -> CHR R2 (%d entries) ==" % EF3F_LEN)
    for i in range(0, EF3F_LEN, 16):
        print("  %02X: %s" % (i, _hex(p.ef3f[i:i+16])))

    print("\n== per-stage/area CHR + palette selectors ==")
    print("  st/ar  setA setB | R0 R1(base) R2 R3 R4 R5 | "
          "$0000-$0FFF background banks (phase 0/1/2)")
    for s in range(NSTAGES):
        for a in range(p.n_areas(s)):
            r  = p.area_record(s, a)
            r0, r1, _ = p.area_bg_chr(s, a)
            ia, ib = p.area_palette_ids(s, a)
            ph = ' / '.join(_hex(b) for b in p.area_bg_chr_phases(s, a))
            print("  %d/%-2d   A%02d  B%03d | %02X %02X(%02X)  %02X %02X %02X %02X"
                  " | %s"
                  % (s, a, ia, ib, r0, r1, p.bg_anim_base(s, a),
                     p.ef3f[0], p.r3_for_suit(0), r[9], r[10], ph))

    print("\n== assembled $3F00 palette per area (suit 0) ==")
    for s in range(NSTAGES):
        for a in range(p.n_areas(s)):
            print("  %d/%-2d %s" % (s, a, _hex(p.area_palette(s, a))))
