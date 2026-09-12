#!/usr/bin/env python3
"""Э4.6: the words the tale types out.

Mode $5D does not draw its words with the rest of the screen.  $803A in bank
four points $5C:$5D at $80F9 and $8037 types one of them into the queue at
$0300 every eighth picture -- every picture while a button is held -- and when
the stream runs out it sets $57, which is what ends the mode.

The stream is read a record at a time.  A byte that is not nought is a tile,
written where $5F:$5E points, and the place then walks on by one.  A nought
opens a record: the byte after it is nought again at the end of the whole
stream, two for a tune ($F8), and one to say where to write from now on --
the two bytes after that are the place and the one after those is the first
tile of the line.

`game/data/sol/tale.json` is the stream as it stands in the cartridge; the
engine walks it in `SolTale`.
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
ROM = os.path.join(ROOT, 'Tokkyuu Shirei Solbrain (Japan).nes')
OUT = os.path.join(ROOT, 'game', 'data', 'sol', 'tale.json')

BANK = 4
AT = 0x80F9
## $8068 -- one letter every eighth picture, and one every picture while a
## button is held.
EVERY = 8


def stream():
    rom = open(ROM, 'rb').read()[16:]
    bank = rom[BANK * 0x2000:(BANK + 1) * 0x2000]
    i = AT - 0x8000
    n = i
    while not (bank[n] == 0 and bank[n + 1] == 0):
        n += 1
    return list(bank[i:n + 2])


def main():
    out = {'at': AT, 'every': EVERY, 'bytes': stream()}
    open(OUT, 'w').write(json.dumps(out) + '\n')
    print('%s: %d bytes from $%04X of bank %d'
          % (os.path.relpath(OUT, ROOT), len(out['bytes']), AT, BANK))


if __name__ == '__main__':
    main()
