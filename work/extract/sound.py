#!/usr/bin/env python3
"""Export the two banks each sound driver lives in.

Neither driver is a routine that plays a tune; each is a small interpreter --
about two kilobytes of code walking six kilobytes of tables in its own bank.
The tables are the tunes.  So what is exported is not a list of notes but the
window the driver reads, $8000..$BFFF, with the two banks the game's wrapper
always maps there:

    Power Blade 2   banks 12 and 13  ($ECAF sets R6 to Y and R7 to Y+1)
    Solbrain        banks 0 and 1    (bank fourteen's boot sets R6 to 0, R7 to 1)

The port reads this window at the cartridge's own addresses -- `$8AE9,Y` in
the port is `$8AE9,Y` in the cartridge -- so no table is ever copied out by
hand and no constant is written down twice.  Whatever the driver reads, it
reads here.

Samples are not in this file.  A DMC sample lives in the fixed banks and is
named by $4012 and $4013, which the tape carries as plain writes; nothing
plays it until there is something to play it with (Э6.3).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import common as C                                               # noqa: E402
sys.path.insert(0, C.TOOLS)
import rombuild                                                  # noqa: E402

# The bank the driver's code is in; the bank after it holds the music data.
# The same two numbers work/tools/sndprobe.py boots the cartridge with.
DRIVER = {'pb2': 12, 'sol': 0}
ROM = {'pb2': C.ROM_PB2, 'sol': C.ROM_SOL}
BANK = 0x2000


def main():
    for game in ('pb2', 'sol'):
        prg, _ = rombuild.load(ROM[game])
        lo = DRIVER[game] * BANK
        window = prg[lo:lo + 2 * BANK]
        path = os.path.join(C.outdir(game), 'sound.json')
        n = C.write_json(path, {
            'base': 0x8000,
            'banks': [DRIVER[game], DRIVER[game] + 1],
            'rom': list(window),
        })
        print('%s: banks %d and %d, %d bytes at $%04X -> %s (%d bytes)'
              % (game, DRIVER[game], DRIVER[game] + 1, len(window), 0x8000,
                 os.path.relpath(path, C.ROOT), n))
    return 0


if __name__ == '__main__':
    sys.exit(main())
