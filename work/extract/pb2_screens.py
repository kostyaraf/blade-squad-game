#!/usr/bin/env python3
"""Export the screens the cartridge draws outside a level -- the picture, not
the level.

The map, the stage-select strip, the titles and the rest of the game's flat
screens are all put on the console the same way: a number goes into X, $C84C
($CB41) looks up a stream in the table at $CBCC and plays it into $2006/$2007.
The stream is the whole of the picture -- the tiles and the colours that go
with them -- so reading the stream out of the ROM is reading the screen.

`work/re/pb2_map.md` says where each number comes from and what the palette
loader ($8044) does; nothing is typed by hand here.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'tools'))
from common import ROM_PB2, outdir, write_json                   # noqa: E402
from m6502 import Rom                                            # noqa: E402

# $CBCC -- fifteen screens, and the number the code hands over is already
# doubled: $CB4C reads the low byte at $CBCC,X and the high at $CBCD,X.
TABLE = 0xCBCC
COUNT = 15
# $CB43 -- a screen numbered under two is played out of the fixed bank, and
# every other one out of the pair $ECAB takes from $38, which is banks 8 and 9.
FIXED = 2
PAIR = 8
# $8044 -- the palette: eight records of four bytes, $0F and three colours.
PAL_TBL = 0x811F
PAL_LO = 0x82F5
PAL_HI = 0x837D
PAL_N = 16


def stream(img14, img89, at):
    """Play one stream and return the writes it makes, in the order it makes
    them: [{'addr': int, 'tiles': [...]}, ...].

    $CB59 reads two bytes for the address ($2006 takes the high byte first,
    so the record keeps the low byte first) and then walks the stream until
    $FF: a byte with bit seven set is that many tiles as they lie, a byte
    without it is the next byte over again that many times, and $7F starts
    the whole thing again at a new address.
    """
    img = img14 if at >= 0xC000 else img89
    base = 0xC000 if at >= 0xC000 else 0x8000
    o = at - base
    out = []
    while True:
        addr = img[o] | (img[o + 1] << 8)
        o += 2
        tiles = []
        while True:
            c = img[o]
            if c in (0xFF, 0x7F):
                o += 1
                break
            if c & 0x80:
                n = c & 0x7F
                tiles += list(img[o + 1:o + 1 + n])
                o += 1 + n
            else:
                tiles += [img[o + 1]] * c
                o += 2
        out.append(dict(addr=addr, tiles=tiles))
        if c == 0xFF:
            return out


def palettes(img0):
    """$8044's records: sixteen screens of thirty-two bytes."""
    out = []
    for n in range(PAL_N):
        rec = img0[PAL_TBL - 0x8000 + n * 2]
        rec |= img0[PAL_TBL - 0x8000 + n * 2 + 1] << 8
        bytes_ = []
        for i in range(8):
            k = img0[rec - 0x8000 + i]
            p = img0[PAL_LO - 0x8000 + k] | (img0[PAL_HI - 0x8000 + k] << 8)
            bytes_ += [0x0F] + list(img0[p - 0x8000:p - 0x8000 + 3])
        out.append(bytes_)
    return out


def export():
    rom = Rom(ROM_PB2)
    b14 = rom.bank(14) + rom.bank(15)
    img89 = rom.bank(PAIR) + rom.bank(PAIR + 1)
    img0 = rom.bank(0) + rom.bank(1)
    screens = []
    for i in range(COUNT):
        x = i * 2
        at = b14[TABLE - 0xC000 + x] | (b14[TABLE - 0xC000 + x + 1] << 8)
        screens.append(dict(x=x, at=at, fixed=x < FIXED,
                            blocks=stream(b14, img89, at)))
    d = outdir('pb2')
    size = write_json(os.path.join(d, 'screens.json'),
                      dict(screens=screens, palettes=palettes(img0)))
    for s in screens:
        wrote = sum(len(b['tiles']) for b in s['blocks'])
        print('screen $%02X  $%04X  %d blocks  %4d tiles  %s'
              % (s['x'], s['at'], len(s['blocks']), wrote,
                 ' '.join('$%04X' % b['addr'] for b in s['blocks'])))
    print('%d bytes' % size)


if __name__ == '__main__':
    export()
