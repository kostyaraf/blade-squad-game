#!/usr/bin/env python3
"""Export the end of the game: the bonus screen, the sunrise, and the names.

The game is over when the last stage is cleared, and $9FF8 in bank eight puts
$4C on $02.  What follows is eleven modes in a row and nothing else can reach
them, so they are one piece:

* `$4C` ($E33A) lays screen $39 -- what the whole game paid -- and works out
  the bonus ($E39D): a thousand for every try left, a thousand for the
  satellite, ten thousand for finishing at all and a hundred thousand for
  finishing without ever having seen GAME OVER or TEST MODE.
* `$4D` ($E421, and the twenty one steps of $89A4 in bank twelve) holds that
  screen while the sun comes up behind it: eight colour rows out of $8AA4 and
  $8ABF, and the view walked from $48 to $9E a point every other picture.
* `$4E` ($E3E7) lays screen $3A, which is the ground the names stand on, and
  `$4F`..`$54` walk the man across it and then take the colours down.
* `$22` ($E4E9) wipes both boards, and `$23` ($E515, and the twenty one steps
  of $8836 in bank twelve) types the names out over the black.  When the last
  of them has been shown it puts $55 on $02, which is where a high score is
  typed in.

The names are a stream in bank six at $820E that two readers share, and which
of them reads next is what makes it a stream: $8180 takes five bytes of it --
the picture the man wears, how long the beat lasts, the colours it is in, and
how many lines it shows -- and $8269 then takes that many single bytes, each
of them a line out of the twenty six $829F points at.  A line is a record in
$E28C's own shape: a tag, an address and the tiles.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

FIXED = 14                # the pair that stands at $C000
BANK_STEP = 12            # the steps of both machines, at $8000
BANK_TEXT = 6             # the stream of names, at $8000

## $E35F and $E3F3 -- the two screens, and $E356 -- the four kilobytes both are
## drawn out of.  $E343 fills both boards with $0F before screen $39 goes on,
## which is what leaves the sky standing where the screen writes nothing.
BONUS_SCREEN = 0x39
STAFF_SCREEN = 0x3A
CHR = (0x18, 0x1A)
FILL = 0x0F

## $E36E, $E40C and $E4F4 -- the colours each of the three takes.  The first is
## the whole thirty two out of bank ten; the last is twenty of a table in the
## fixed bank, so the other twelve are left as the screen before wrote them.
BONUS_TABLE = 0x8010
STAFF_TABLE = 0x8020
CREDIT_TABLE = 0xD481
CREDIT_N = 0x14

## $E39D -- what the game pays for being finished.  $E3CF is a thousand, and
## the satellite pays for as many thousands as $060C stands six past a
## multiple of eight; $E3BB is ten thousand for finishing, and $E3C6 a hundred
## thousand more for never having lost.
PAY_LIFE = 1000
PAY_SAT = 1000
SAT_SLOT = 0x0C
SAT_TURN = 6
PAY_CLEAR = 10000
PAY_CLEAN = 100000

## $8AA4 and $8ABF in bank twelve -- the sun coming up, three colours a row
## into $0101..$0103 and three more into $0105..$0107.  Eight rows of each,
## three apart.
SUN_A = 0x8AA4
SUN_B = 0x8ABF
SUN_N = 8

## $E387 and $8ADA -- the view starts at $48 and walks a point every other
## picture; $9F is where it stops and $9E is as far as it goes.  $8AE9 -- the
## line the beam is cut at is eight less the low three of it, past $98.
SUN_FROM = 0x48
SUN_STOP = 0x9F
SUN_TOP = 0x9E
SUN_LINE = 0x98
## $E381 and $89D3 -- the two tricks the beam is asked for over the ending.
SUN_TRICK = 0x75
STAFF_TRICK = 0x84

## $E42F..$E494 -- the man walked across the names.  He starts at nought, is
## drawn every picture at $4C by $80 whole pixels, moves a point every other
## picture, and the colours start down when he reaches $40 and the walk is
## over at $B8.  $4F is the picture he wears.
WALK_Y = 0x80
WALK_ASK = 0x40
WALK_END = 0xB8
WALK_PIC = (0x30, 0x2E, 0x2C)

## $8138 in bank six, mode $53 -- eight rows of three, nine apart, which is
## what takes the names down into the dark.
RAMP = 0x8138
RAMP_N = 3                # how many rows of the ramp there are ($4D = 0, 3, 6)
RAMP_STEP = 9
RAMP_TIMES = 8            # and how many threes are written out of each

## $820E in bank six -- the stream, and $829F -- the twenty six lines.
STREAM = 0x820E
LINES = 0x829F
LINES_N = 26

## $81E4 in bank six -- the colours a beat is in: three for the pair the beat
## names and three apiece for the three that are always the same.
BEAT_PAL = 0x81E4
BEAT_FIXED = (0x1E, 0x21, 0x24)

## $8963 and $8975 in bank twelve -- six rows of twenty blanks, which is what
## wipes the names off between beats.  $2588 is the first and each is $60 on.
ERASE_AT = 0x2588
ERASE_STEP = 0x60
ERASE_ROWS = 3            # in two passes of three
ERASE_N = 0x14
ERASE_TAG = 0x94

## $8180 -- where the man stands when a beat opens, in sixteenths of a pixel,
## and $88AD -- how much of it he loses a picture, down to where $81 is under
## three.
MAN_X = 0x1400
MAN_Y = 0x0800
MAN_STEP = 0x0080
MAN_HOME = 3


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    fixed = prg[FIXED * 0x2000:(FIXED + 2) * 0x2000]
    step = prg[BANK_STEP * 0x2000:(BANK_STEP + 1) * 0x2000]
    text = prg[BANK_TEXT * 0x2000:(BANK_TEXT + 1) * 0x2000]

    def at(b, a, n):
        return list(b[a - 0x8000:a - 0x8000 + n])

    def word(b, a):
        return b[a - 0x8000] | (b[a - 0x8000 + 1] << 8)

    sun_a = [at(step, SUN_A + 3 * i, 3) for i in range(SUN_N)]
    sun_b = [at(step, SUN_B + 3 * i, 3) for i in range(SUN_N)]

    # The lines the stream names, each of them a record $E28C understands.
    lines = []
    for i in range(LINES_N):
        p = word(text, LINES + 2 * i)
        tag = text[p - 0x8000]
        n = tag & 0x3F
        assert tag & 0x80, 'line %d at $%04X carries no address' % (i, p)
        hi, lo = text[p - 0x8000 + 1], text[p - 0x8000 + 2]
        lines.append({'at': (hi << 8) | lo, 'tiles': at(text, p + 3, n)})

    # And the stream itself, read the way the two readers take turns at it.
    beats, y = [], 0
    while True:
        rec = at(text, STREAM + y, 5)
        y += 5
        said = at(text, STREAM + y, rec[4])
        y += rec[4]
        beats.append({
            'pic': rec[0] | ((rec[1] & 0x1F) << 8),
            'flip': rec[1] >> 7,
            'pace': rec[2],
            'pal': rec[3],
            'lines': said,
        })
        if rec[0] == 0 and (rec[1] & 0x1F) == 0:
            break

    data = {
        'bonus_screen': BONUS_SCREEN,
        'staff_screen': STAFF_SCREEN,
        'chr': list(CHR),
        'fill': FILL,
        'bonus_table': BONUS_TABLE,
        'staff_table': STAFF_TABLE,
        'credit_table': CREDIT_TABLE,
        'credit_n': CREDIT_N,
        'pay_life': PAY_LIFE,
        'pay_sat': PAY_SAT,
        'sat_slot': SAT_SLOT,
        'sat_turn': SAT_TURN,
        'pay_clear': PAY_CLEAR,
        'pay_clean': PAY_CLEAN,
        'sun_a': sun_a,
        'sun_b': sun_b,
        'sun_from': SUN_FROM,
        'sun_stop': SUN_STOP,
        'sun_top': SUN_TOP,
        'sun_line': SUN_LINE,
        'sun_trick': SUN_TRICK,
        'staff_trick': STAFF_TRICK,
        'walk_y': WALK_Y,
        'walk_ask': WALK_ASK,
        'walk_end': WALK_END,
        'walk_pic': list(WALK_PIC),
        'ramp': [[at(text, RAMP + 3 * i + RAMP_STEP * k, 3)
                  for k in range(RAMP_TIMES)] for i in range(RAMP_N)],
        'ramp_rows': RAMP_N,
        'ramp_times': RAMP_TIMES,
        'beats': beats,
        'lines': lines,
        'beat_pal': [at(text, BEAT_PAL + i, 3) for i in range(0x28)],
        'beat_fixed': list(BEAT_FIXED),
        'erase_at': [ERASE_AT + ERASE_STEP * i
                     for i in range(2 * ERASE_ROWS)],
        'erase_n': ERASE_N,
        'erase_tag': ERASE_TAG,
        'man_x': MAN_X,
        'man_y': MAN_Y,
        'man_step': MAN_STEP,
        'man_home': MAN_HOME,
    }
    size = write_json(os.path.join(outdir('sol'), 'end.json'), data)
    print('%d beats, %d lines, %d bytes' % (len(beats), len(lines), size))


if __name__ == '__main__':
    main()
