#!/usr/bin/env python3
"""Export the tables the per-stage scroll script is steered by.

Every picture the game is playing, $CDB3 calls bank eight's $93B5.  That works
out which room of the stage the view stands in -- the high byte of the view
across, rounded, plus the high byte down, rounded, as a column and a row -- and
if the room has changed it puts the step counter $7F back to nought.  Then the
stage's own dispatcher is picked out of $93E8 by $55, the room is looked up in
that dispatcher's room table, and the routine that comes out is jumped to.

So three layers of table, and all three are here:

  * `stages`   -- which of the eight dispatchers each of the twenty stages uses
                  (they are shared: 0 and 8 keep the same one, and so on);
  * `dispatch` -- for each dispatcher, the room table (one index per room id)
                  and the addresses of the routines it indexes;
  * `tables`   -- the second level: a routine that is a script of several steps
                  reads $7F (or $58) and jumps again through a table of its own.

The routines themselves are code, not data, and are ported by hand in
`game/src/sol_script.gd`; what is exported here is only what they are reached
through, plus the handful of small byte tables they read.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

# $93E8 -- twenty words, the dispatcher of each stage.
STAGES_AT = 0x93E8
STAGES = 20

# The small byte tables the routines read.  Name, address, how many.
ROWS = [
    # $AABB and $AE65 -- the four tile books the two plain routines walk $41
    # through, one every four pictures.
    ('chr_a', 0xAABB, 4),
    ('chr_b', 0xAE65, 4),
    # $AC71 -- five pairs: how far along and how far down each of the five
    # things $ABE2 lets out stands from the hero.
    ('spawn_at', 0xAC71, 10),
    # $AC7B -- the order they are let out in, ending with $FF.
    ('spawn_order', 0xAC7B, 17),
    # $AC8C and $AC91 -- the speed and the behaviour of each of the five.
    ('spawn_speed', 0xAC8C, 5),
    ('spawn_mind', 0xAC91, 5),
    # $AD6C -- four pictures of the number the last stage shows while it waits.
    ('wait_pic', 0xAD6C, 4),
]


# $E9B6..$E9CE and $C045..$C04B -- every place the script can point $20:$21
# at.  What stands there is thirty two bytes of colour, and $F81E copies them
# into the shadow at $0390.  They live in bank ten.
PAL_BANK = 10
PAL_AT = (0x8160, 0x8180, 0x81A0, 0x83E0, 0x8400, 0x8420, 0x8480, 0x84A0,
          0x84C0)

# $E626 -- the map record of a stage: $C965 says which bank, $E6E0 holds a
# pointer per stage, the byte it points at is an offset, and twelve bytes from
# $800D plus that offset are read into $10..$15, $1E, $1F and $16..$19.
AREA_BANKS = 0xC965
AREA_PTRS = 0xE6E0
AREA_REC = 0x800D
AREA_LEN = 12


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]

    def bank(n):
        return prg[n * 0x2000: (n + 1) * 0x2000]

    b8 = prg[8 * 0x2000: 9 * 0x2000]
    b9 = prg[9 * 0x2000: 10 * 0x2000]
    b14 = bank(14)
    b15 = bank(15)

    def rd(a):
        return b8[a - 0x8000] if a < 0xA000 else b9[a - 0xA000]

    def word(a):
        return rd(a) | rd(a + 1) << 8

    stages = [word(STAGES_AT + 2 * i) for i in range(STAGES)]
    order = sorted(set(stages))
    # A dispatcher's pointer table runs up to the next dispatcher; the last of
    # them is bounded by $9534, where the room tables begin.
    stop = {d: (order[i + 1] if i + 1 < len(order) else 0x9534)
            for i, d in enumerate(order)}
    # $9410 and its like are all the same eighteen bytes: LDA rooms,Y / ASL /
    # TAX / LDA ptrs,X / STA $90 / LDA ptrs+1,X / STA $91 / JMP ($0090).
    dispatch = []
    rooms_at = sorted(set(word(d + 1) for d in order)) + [0x98FF + 1]
    for d in order:
        at = word(d + 1)
        ptrs = word(d + 6)
        n = (stop[d] - ptrs) // 2
        end = rooms_at[rooms_at.index(at) + 1]
        dispatch.append({
            'at': d,
            'rooms': [rd(a) for a in range(at, end)],
            'routines': [word(ptrs + 2 * k) for k in range(n)],
        })

    # The second level.  Each of these is walked by a routine that reads $7F
    # (or, for the last stage, $58) and jumps through it; how long each is was
    # found by walking the code and stopping where the table runs into it.
    second = {
        0x99D2: 9, 0x9AB1: 8, 0x9BF9: 8, 0x9DAB: 4, 0x9E0A: 21,
        0xA150: 7, 0xA280: 4, 0xA2DF: 4, 0xA440: 6, 0xA5BE: 6,
        0xA60A: 6, 0xA630: 6, 0xA656: 6, 0xA68D: 4, 0xA760: 4,
        0xA8AB: 2, 0xA978: 4, 0xAA7F: 2, 0xAB39: 4, 0xACFD: 2,
        0xADA5: 2, 0xADE0: 4, 0xAE49: 2,
    }
    tables = {'%04X' % a: [word(a + 2 * k) for k in range(n)]
              for a, n in sorted(second.items())}

    # $F81E's palettes, and $E626's map records.
    pal = bank(PAL_BANK)
    palettes = {'%04X' % a: list(pal[a - 0x8000: a - 0x8000 + 32])
                for a in PAL_AT}
    areas = []
    for st in range(STAGES):
        bk = b14[AREA_BANKS - 0xC000 + st]
        ptr = (b15[AREA_PTRS - 0xE000 + 2 * st]
               | b15[AREA_PTRS - 0xE000 + 2 * st + 1] << 8)
        lo, hi = bank(bk), bank(bk + 1)
        off = b15[ptr - 0xE000]

        def rd8(a, lo=lo, hi=hi):
            return lo[a - 0x8000] if a < 0xA000 else hi[a - 0xA000]

        areas.append({
            'ptr': ptr,
            'rec': [rd8(AREA_REC + off + i) for i in range(AREA_LEN)],
        })

    out = {
        'stages': [order.index(s) for s in stages],
        'dispatch': dispatch,
        'tables': tables,
        'palettes': palettes,
        'areas': areas,
        # $C992 reads $8000, which is the top byte of whatever bank stands
        # there; inside the script that is bank eight, so this is what $46
        # becomes every time the script maps a bank of its own.
        'bank_top': prg[8 * 0x2000],
    }
    for name, at, n in ROWS:
        out[name] = [rd(at + i) for i in range(n)]
    size = write_json(os.path.join(outdir('sol'), 'script.json'), out)
    print('%d dispatchers, %d second tables, %d bytes'
          % (len(dispatch), len(tables), size))


if __name__ == '__main__':
    main()
