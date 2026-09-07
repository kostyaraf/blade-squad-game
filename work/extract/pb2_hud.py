#!/usr/bin/env python3
"""Export the status bar of Power Blade 2, straight out of the cartridge.

Everything the game puts in the bottom four rows of the screen goes through
one queue at $0300, and every number, tile and address that fills it is read
here from the address the code reads it from.  `work/re/pb2_hud.md` says where
each one came from.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, outdir, write_json                   # noqa: E402

BANK = 0x2000


def read_split(img):
    """The interrupt's own routine that hands the screen to the bar.

    It is not looked up by hand: the routines are read as they run -- a very
    small machine that knows how to load a register and how to store it -- and
    the one that writes an address into $2006 twice is the bar's.  What comes
    out of it is that address, the byte it puts in $2000, and the six numbers
    it hands the cartridge's tile switch ($8000/$8001).
    """
    for i in range(len(img) - 10):
        if img[i:i + 2] != bytes((0xA9, 0x26)):
            continue
        a = x = y = 0
        addr = []
        ctrl = None
        regs = {}
        sel = 0
        j, ok = i, True
        while j < len(img) and ok:
            op = img[j]
            if op == 0xA9:                     # LDA #imm
                a, j = img[j + 1], j + 2
            elif op == 0xA2:                   # LDX #imm
                x, j = img[j + 1], j + 2
            elif op == 0xA0:                   # LDY #imm
                y, j = img[j + 1], j + 2
            elif op == 0xC8:                   # INY
                y, j = (y + 1) & 0xFF, j + 1
            elif op in (0x8D, 0x8E, 0x8C):     # STA/STX/STY abs
                v = {0x8D: a, 0x8E: x, 0x8C: y}[op]
                t = img[j + 1] | (img[j + 2] << 8)
                if t == 0x2006:
                    addr.append(v)
                elif t == 0x2000:
                    ctrl = v
                elif t == 0x8000:
                    sel = v
                elif t == 0x8001:
                    regs[sel & 7] = v
                j += 3
            elif op == 0x4C:                   # JMP -- the routine is over
                break
            else:
                ok = False
        if not ok or ctrl is None or len(addr) != 2:
            continue
        return dict(addr=(addr[0] << 8) | addr[1], ctrl=ctrl,
                    banks=[regs[k] for k in sorted(regs)])
    raise SystemExit('no split routine found')


def export():
    rom = open(ROM_PB2, 'rb').read()
    # $C000..$DFFF is bank fourteen, and it never moves.
    b = rom[16 + 14 * BANK: 16 + 15 * BANK]

    def at(addr, n=1):
        return list(b[addr - 0xC000: addr - 0xC000 + n])

    def word(addr):
        return b[addr - 0xC000] | (b[addr - 0xC000 + 1] << 8)

    # --- the queue itself ------------------------------------------------
    # $CC5A -- what the mode adds to $2000, which is the step between two
    # writes: mode two steps a row down instead of a column along.
    fill_bits = at(0xCC3C, 5)

    # --- the ready-made strips ($CD28) -----------------------------------
    # Ten of them.  A strip is an address, low byte first, and then letters
    # until $FE; $FD inside one means another address follows.
    strip_ptr = [word(0xCD28 + i * 2) for i in range(10)]
    strips = {}
    for p in sorted(set(strip_ptr)):
        out = []
        o = p
        while True:
            out.append(b[o - 0xC000])
            o += 1
            if out[-1] == 0xFE:
                break
        # An address at the head and after every $FD is two bytes and no
        # letters, so the end is only ever met where the reading stops.
        strips['%04X' % p] = out

    # --- the three digits of a number ($D40A) ----------------------------
    digit_base = at(0xD420)[0]                         # $D41F ADC #$20

    # --- the seven pieces ------------------------------------------------
    # Each number is an address written low byte first into $10:$11 and a byte
    # of the game's own memory into $12.
    def number(lo_at, hi_at, source):
        return dict(addr=(at(hi_at)[0] << 8) | at(lo_at)[0], source=source)

    numbers = dict(
        # $D431 -- the stage and the area, and only while $79 is nought.
        stage=number(0xD43B, 0xD43F, 0x53),
        area=number(0xD44D, 0xD451, 0x9C),
        # $D471 -- and the tile that stands for the stage.
        stage_tile=number(0xD46A, 0xD46E, None),
        # $D489 -- the score, two bytes of it.
        score_hi=number(0xD48A, 0xD48E, 0x95),
        score_lo=number(0xD499, 0xD49D, 0x96),
        # $D4A7, $D4B6, $D4C5 -- the three down the right hand side.
        right_1=number(0xD4A8, 0xD4AC, 0x9D),
        right_2=number(0xD4B7, 0xD4BB, 0x9E),
        right_3=number(0xD4CC, 0xD4D0, 0x9F),
    )
    # $D483 -- one tile a stage, put where the stage's number is not.  There
    # are six bytes there and seven stages: on the last one $D471 reads a byte
    # past the table, into the first byte of $D489, and draws it as a pair of
    # figures.  The seventh entry is taken the same way, so the bar shows what
    # the cartridge shows.
    stage_tile = at(0xD483, 7)
    # $D45D -- the area's number is kept as a plain count and shown as two
    # figures, so a low half that has run past nine is carried by hand.
    area_carry = [at(0xD45E)[0], at(0xD463)[0]]

    # --- the four bars ---------------------------------------------------
    # All of one shape: eight tiles, top to bottom, the weight of one tile
    # taken off the count each time, and what is left over choosing a half
    # tile out of a little table.
    def bar(source, lo_at, hi_at, weight_at, full_at, rest_at, rest_n):
        return dict(source=source,
                    addr=(at(hi_at)[0] << 8) | at(lo_at)[0],
                    weight=at(weight_at)[0],
                    full=at(full_at)[0],
                    rest=at(rest_at, rest_n))

    bars = dict(
        # $D4ED -- his health, out of the fifteenth field of his own place.
        health=bar(0x049A, 0xD4F6, 0xD4FB, 0xD505, 0xD516, 0xD520, 2),
        # $D4D9 -- what is left of the suit.
        suit=bar(0xA0, 0xD4E1, 0xD4E6, 0xD505, 0xD516, 0xD520, 2),
        # $D58D -- how far the blade has been raised.
        charge=bar(0x54, 0xD595, 0xD59A, 0xD5A4, 0xD5B5, 0xD5BF, 2),
    )
    # $D522 -- the boss's health is two bars in one: below $20 it is drawn
    # with the first set, and from $20 up the count has $20 taken off it and
    # the second set is used.  Eight tiles then show sixty four in two
    # colours.
    bars['boss'] = dict(
        source=0x04A9,
        addr=(at(0xD52D)[0] << 8) | at(0xD528)[0],
        weight=at(0xD542)[0],
        split=at(0xD537)[0],
        full=[at(0xD553)[0], at(0xD57C)[0]],
        rest=[at(0xD585, 4), at(0xD589, 4)],
    )

    # --- the suit's portrait ($D5C1) -------------------------------------
    # Three rows of three tiles.  The rows go to three addresses of their own,
    # kept high byte first; the tiles come from one of five lists, and the
    # third and fourth of them are the other way round from the tiles.
    rows = [(at(0xD613 + i * 2)[0] << 8) | at(0xD614 + i * 2)[0]
            for i in range(3)]
    face_ptr = [word(0xD619 + i * 2) for i in range(5)]
    faces = {'%04X' % p: at(p, 9) for p in sorted(set(face_ptr))}

    # --- where the picture unit is told to show it -----------------------
    # The level owns the top of the screen and the bar the bottom, and the
    # cartridge changes from one to the other in the middle of the picture,
    # on the counter the cartridge keeps ($E640, the interrupt).  Whichever of
    # its little routines writes an address into $2006 is the one that begins
    # the bar; it also says which thousand bytes of tiles the bar is drawn
    # from, and which way round the name tables are.
    split = read_split(rom[16 + 15 * BANK: 16 + 16 * BANK])

    # --- the schedule ($D650) --------------------------------------------
    # Four turns, one a frame, counted by $1B; the last of them puts $1B back
    # to nought and lets the level's own count ($1A) move on.
    schedule = [word(0xD655 + i * 2) for i in range(4)]

    out = dict(
        fill_bits=fill_bits,
        strip_index=['%04X' % p for p in strip_ptr],
        strips=strips,
        digit_base=digit_base,
        numbers=numbers,
        stage_tile=stage_tile,
        area_carry=area_carry,
        bars=bars,
        face_rows=rows,
        face_index=['%04X' % p for p in face_ptr],
        faces=faces,
        schedule=['%04X' % p for p in schedule],
        split=split,
    )
    d = outdir('pb2')
    size = write_json(os.path.join(d, 'hud.json'), out)
    print('hud.json  %d strips, %d faces, %d bytes'
          % (len(strips), len(faces), size))
    for k in ('fill_bits', 'digit_base', 'stage_tile', 'area_carry',
              'face_rows'):
        print('  %-12s %s' % (k, out[k]))
    for k, v in bars.items():
        print('  bar %-7s %s' % (k, v))


if __name__ == '__main__':
    export()
