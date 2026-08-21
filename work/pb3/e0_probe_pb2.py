#!/usr/bin/env python3
"""E0 probe: does a second player fit inside Power Blade 2's engine?

`work/re/pb2_two_players.md` argues that the player's own update routine can be
run twice per frame if slot 0 and a reserved slot exchange their 29 object
fields around the second call, because everything the routine writes is
absolute.  This builds the smallest thing that tests that claim: a stock ROM
with the swap in place, a reserved slot 21, and pad 2 feeding the second pass.

It deliberately stops there.  Enemies and the camera still only know about slot
0, and the $0110-$013F player scalars are not swapped -- the question this probe
answers is only "does a second character appear and move", which is measurement
3 of docs/ver2_spec.md 2.3 for the Power Blade 2 side.

The two free regions used are genuine filler: bank 8 $8D6A-$8DFF and bank 9
$BF99-$BFFF are 150 and 103 bytes of $FF, and banks 8/9 are the pair that holds
the player, so no banking is needed.
"""
import os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, 'Power Blade 2 (USA).nes')
OUT = os.path.join(ROOT, 'work/build/probe_pb2.nes')

# The sprite composer reads a metasprite pointer from one of two tables
# depending on the slot number -- $8148/$81B4 for slots below 6, $8C88/$8D83 for
# the rest (bank 6 $808F).  A second player therefore has to live below slot 6
# or he is drawn out of the enemy table.  Slot 5 is the last of the five
# player-shot slots, so P1 loses one concurrent shot; that is the cheapest
# correct-looking place for a probe.
P2 = 0x05
CODE = 0x8D6A                   # bank 8, 150 bytes of filler
PLAYER = 0x8E15                 # the player update, bank 8


def swap():
    """Exchange slot 0 and slot 21 across all 29 object fields, then exchange
    the two pads.  The field bases are $0400 + n*$16, so the walk is arithmetic
    and needs no table."""
    b = bytearray()
    b += bytes((0xA9, 0x00, 0x85, 0x02, 0xA9, 0x04, 0x85, 0x03))   # ptr = $0400
    b += bytes((0xA2, 0x1D))                                       # ldx #29
    top = len(b)
    b += bytes((0xA0, 0x00, 0xB1, 0x02, 0x48))                     # a = slot0
    b += bytes((0xA0, P2, 0xB1, 0x02))                             # a = slot21
    b += bytes((0xA0, 0x00, 0x91, 0x02))                           # -> slot0
    b += bytes((0x68, 0xA0, P2, 0x91, 0x02))                       # old -> slot21
    b += bytes((0xA5, 0x02, 0x18, 0x69, 0x16, 0x85, 0x02))         # ptr += $16
    b += bytes((0x90, 0x02, 0xE6, 0x03))
    b += bytes((0xCA, 0xD0, (top - (len(b) + 3)) & 0xFF))          # dex / bne
    for a, c in ((0x48, 0x49), (0x4A, 0x4B)):                      # pad 1 <-> 2
        b += bytes((0xA5, a, 0xA4, c, 0x85, c, 0x84, a))
    b += bytes((0x60,))
    return bytes(b)


def init(done_is_rts=True):
    """First frame in an area, slot 21 is empty: give player 2 a copy of player
    1's whole state, moved 24 pixels to the left so the two are visibly
    separate -- to the right they land on the screen edge, which the terrain
    query reports as solid."""
    b = bytearray()
    # slot 0's *type* is 0 -- the player is not an AI object -- so aliveness is
    # read off $0442, the metasprite id, which is what the sprite composer uses
    b += bytes((0xAD, 0x42 + P2, 0x04))                            # lda $0457
    j1 = len(b); b += bytes((0xD0, 0x00))                          # bne done
    b += bytes((0xAD, 0x42, 0x04))                                 # lda $0442
    j2 = len(b); b += bytes((0xF0, 0x00))                          # beq done
    b += bytes((0xA9, 0x00, 0x85, 0x02, 0xA9, 0x04, 0x85, 0x03))
    b += bytes((0xA2, 0x1D))
    top = len(b)
    b += bytes((0xA0, 0x00, 0xB1, 0x02, 0xA0, P2, 0x91, 0x02))     # slot0 -> 21
    b += bytes((0xA5, 0x02, 0x18, 0x69, 0x16, 0x85, 0x02))
    b += bytes((0x90, 0x02, 0xE6, 0x03))
    b += bytes((0xCA, 0xD0, (top - (len(b) + 3)) & 0xFF))
    b += bytes((0xAD, 0x08, 0x05, 0x38, 0xE9, 0x18, 0x8D, 0x08 + P2, 0x05))
    done = len(b)
    b += bytes((0x60,))
    b[j1 + 1] = done - (j1 + 2)
    b[j2 + 1] = done - (j2 + 2)
    return bytes(b)


def build():
    rom = bytearray(open(SRC, 'rb').read())
    hdr = 16
    def bank(n):
        return hdr + n * 0x2000

    i, s = init(), swap()
    entry_len = 16
    a_init = CODE + entry_len
    a_swap = a_init + len(i)
    entry = bytes((
        0x20, PLAYER & 0xFF, PLAYER >> 8,       # jsr player      -- player 1
        0x20, a_init & 0xFF, a_init >> 8,       # jsr init
        0x20, a_swap & 0xFF, a_swap >> 8,       # jsr swap
        0x20, PLAYER & 0xFF, PLAYER >> 8,       # jsr player      -- player 2
        0x20, a_swap & 0xFF, a_swap >> 8,       # jsr swap        -- and back
        0x60,
    ))
    assert len(entry) == entry_len, len(entry)
    blob = entry + i + s
    off = bank(8) + (CODE - 0x8000)
    assert set(rom[off:off + 0x8E00 - CODE]) == {0xFF}, 'bank 8 filler is not free'
    assert len(blob) <= 0x8E00 - CODE, f'{len(blob)} bytes will not fit'
    rom[off:off + len(blob)] = blob

    # the wrap point: bank 8's first instruction is JMP $8E15, the single call
    # to the player.  Point it at the doubled version instead.
    assert bytes(rom[bank(8):bank(8) + 3]) == b'\x4C\x15\x8E'
    rom[bank(8):bank(8) + 3] = bytes((0x4C, CODE & 0xFF, CODE >> 8))

    # NOT reserved: the routine that hands out shot slots 1..5 was not located
    # (work/re/pb2_two_players.md lists it as an unknown), so a burst of shots
    # can still overwrite player 2.  Acceptable for a probe, not for a build.

    open(OUT, 'wb').write(rom)
    print(f"{OUT}  {len(rom)} bytes")
    print(f"  entry ${CODE:04X}  init ${a_init:04X}  swap ${a_swap:04X}  "
          f"{len(blob)} of {0x8E00 - CODE} filler bytes used")
    return OUT


if __name__ == '__main__':
    build()
