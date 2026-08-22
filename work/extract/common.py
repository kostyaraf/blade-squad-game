"""Shared pieces of the ROM -> data export.

The exported data is meant to be read by the engine as-is, so it keeps the
shape the ROM gave it: a tile is four bits deep and its colour is decided at
draw time by a palette, exactly as the console does it.  Baking colour into
the pictures here would throw away the palette swaps the games rely on --
the flashing of a hurt enemy, the colour of the suit the player wears.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
TOOLS = os.path.join(ROOT, 'work', 'tools')
OUT = os.path.join(ROOT, 'game', 'data')
sys.path.insert(0, TOOLS)

ROM_PB2 = os.path.join(ROOT, 'Power Blade 2 (USA).nes')
ROM_SOL = os.path.join(ROOT, 'Tokkyuu Shirei Solbrain (Japan).nes')

# The console's 64 colours, taken from work/tools/nesemu.c so that a picture
# built from this data and a screenshot of the real game are comparable byte
# for byte.
NES_RGB = [
    0x666666, 0x002A88, 0x1412A7, 0x3B00A4, 0x5C007E, 0x6E0040, 0x6C0600, 0x561D00,
    0x333500, 0x0B4800, 0x005200, 0x004F08, 0x00404D, 0x000000, 0x000000, 0x000000,
    0xADADAD, 0x155FD9, 0x4240FF, 0x7527FE, 0xA01ACC, 0xB71E7B, 0xB53120, 0x994E00,
    0x6B6D00, 0x388700, 0x0C9300, 0x008F32, 0x007C8D, 0x000000, 0x000000, 0x000000,
    0xFFFEFF, 0x64B0FF, 0x9290FF, 0xC676FF, 0xF36AFF, 0xFE6ECC, 0xFE8170, 0xEA9E22,
    0xBCBE00, 0x88D800, 0x5CE430, 0x45E082, 0x48CDDE, 0x4F4F4F, 0x000000, 0x000000,
    0xFFFEFF, 0xC0DFFF, 0xD3D2FF, 0xE8C8FF, 0xFBC2FF, 0xFEC4EA, 0xFECCC5, 0xF7D8A5,
    0xE4E594, 0xCFEF96, 0xBDF4AB, 0xB3F3CC, 0xB5EBF2, 0xB8B8B8, 0x000000, 0x000000,
]

# One tile sheet is this many tiles across.  1024 px wide, and a tile's number
# is its position in the sheet, so the engine finds a tile by arithmetic alone.
SHEET_W = 128


def outdir(*parts):
    d = os.path.join(OUT, *parts)
    os.makedirs(d, exist_ok=True)
    return d


def write_json(path, obj):
    with open(path, 'w') as f:
        json.dump(obj, f, separators=(',', ':'), sort_keys=False)
    return os.path.getsize(path)


def tile_pixels(chr_bytes, index):
    """The 8x8 colour indices of one tile, row major, values 0..3."""
    b = chr_bytes[index * 16: index * 16 + 16]
    out = []
    for y in range(8):
        lo, hi = b[y], b[y + 8]
        for x in range(8):
            s = 7 - x
            out.append(((lo >> s) & 1) | (((hi >> s) & 1) << 1))
    return out
