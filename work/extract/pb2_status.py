#!/usr/bin/env python3
"""Export the hero's own counters: the suits, his energy and his spare tanks.

None of this lives in the level or in the table of things.  It is the handful
of bytes the whole game keeps about the man himself -- which suit he wears,
which ones he has found, how much is left in it -- and the four little
routines that move them: the pause menu that changes a suit, the drain that
wears one out, the pickups that fill them, and the two refills that follow a
pickup.  `work/re/pb2_suits.md` says where each address came from.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROM_PB2, outdir, write_json                   # noqa: E402

BANK = 0x2000


def export():
    rom = open(ROM_PB2, 'rb').read()

    def bank(n):
        return rom[16 + n * BANK: 16 + (n + 1) * BANK]

    b0, b7, b14, b15 = bank(0), bank(7), bank(14), bank(15)

    def a0(addr, n=1):
        return b0[addr - 0x8000: addr - 0x8000 + n]

    def a7(addr, n=1):
        return b7[addr - 0xA000: addr - 0xA000 + n]

    def a14(addr, n=1):
        return b14[addr - 0xC000: addr - 0xC000 + n]

    def word14(addr):
        return a14(addr)[0] | (a14(addr + 1)[0] << 8)

    # $D8E4 asks for palette group $3D + $9A, and $8080 turns a group into
    # three colours through a pair of half-pointers.  Those three colours are
    # the whole of what one suit looks like: they go to sprite palette one.
    pal = []
    for suit in range(5):
        g = 0x3D + suit
        p = a0(0x837D + g)[0] * 256 + a0(0x82F5 + g)[0]
        pal.append(list(a0(p, 3)))

    # $D619: five pointers into the block after it, one three-by-three
    # portrait each, and $D613: the three places on the screen they go.
    icon = []
    for suit in range(5):
        p = a14(0xD61A + suit * 2)[0] * 256 + a14(0xD619 + suit * 2)[0]
        icon.append(list(a14(p, 9)))

    out = dict(
        # $D2B9: which bit of $56 each suit answers to.  Index nought is nought
        # -- no suit is always owned, which is how the ring always has a way
        # back to plain Nova.
        own_mask=list(a14(0xD2B9, 5)),
        # $D326: how much a frame each suit takes out of $85:$86
        drain=list(a14(0xD326, 4)),
        # $D2ED: and what that pair is set back to each time it runs out
        drain_reload=a14(0xD2EE)[0] * 256 + a14(0xD2F2)[0],
        # $D290/$D294: the thousand bytes of tiles the man himself is drawn
        # from.  Every suit shares one; only the colours tell them apart.
        chr_plain=a14(0xD291)[0],
        chr_suit=a14(0xD295)[0],
        suit_palette=pal,
        icon_at=[a14(0xD613 + i * 2)[0] * 256 + a14(0xD614 + i * 2)[0]
                 for i in range(3)],
        icon=icon,
        # $B5CD: stage N holds suit N+1, and the pickup turns that bit over.
        stage_bit=list(a7(0xB5CD, 8)),
        # The caps the eight pickup routines keep ($B503 onwards), in the
        # order $B4CD dispatches them: health, energy, health tanks, energy
        # tanks, a suit, the second blade, the blade's power, the extra throw.
        cap_life=a7(0xB507)[0],
        cap_energy=a7(0xB51E)[0],
        cap_life_tank=a7(0xB535)[0],
        cap_energy_tank=a7(0xB54A)[0],
        cap_second=a7(0xB55F)[0],
        cap_power=a7(0xB56C)[0],
        cap_extra=a7(0xB57F)[0],
        # $B512 and $B52B: how many cells a pickup is worth, and $D306: how
        # many a spare tank is worth when the suit drinks one.
        refill_life=a7(0xB513)[0],
        refill_energy=a7(0xB52A)[0],
        refill_tank=a14(0xD307)[0],
        # $EFE3 and $F009: a cell every fourth frame while it fills
        refill_every=b15[0xEFE4 - 0xE000] + 1,
        # $CE45: how long the man is given.  Three tables at $CE67, one for
        # each half of the stage ($AD), six stages apiece, and each entry four
        # binary-coded digits -- $96 the lower two, $95 the upper.
        time=[[a14(word14(0xCE67 + h * 2) + n * 2)[0]
               | (a14(word14(0xCE67 + h * 2) + n * 2 + 1)[0] << 8)
               for n in range(6)] for h in range(3)],
        # $CA44: it goes down by one every sixty-four frames...
        time_every=a14(0xCA47)[0] + 1,
        # ...and at $0030 ($CA75) $57 goes up, and the tick starts calling
        # for the sound $34 ($CA4E).
        time_warn=a14(0xCA76)[0],
        time_warn_sound=a14(0xCA4F)[0],
    )
    d = outdir('pb2')
    size = write_json(os.path.join(d, 'status.json'), out)
    print('status.json  %d bytes' % size)
    for k in ('own_mask', 'drain', 'drain_reload', 'chr_plain', 'chr_suit',
              'suit_palette', 'stage_bit', 'time', 'time_every',
              'time_warn'):
        print('  %-16s %s' % (k, out[k]))


if __name__ == '__main__':
    export()
