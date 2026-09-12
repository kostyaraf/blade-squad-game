#!/usr/bin/env python3
"""Export what GAME OVER and BEST 5 write over their screens.

Both modes draw a screen and then write numbers into it, and the numbers are
not tiles the screen holds: the cartridge turns a count into six digits and
hands them to $EF84, the writer bank four keeps at $9607, as a little script
-- a tag, an address, and the bytes.

* $EC7C turns the three bytes at $90..$92 into six digits at $93..$98 by
  taking a hundred thousand away, then ten thousand, and so on; anything over
  nine hundred and ninety nine thousand nine hundred and ninety nine comes out
  as six nines.  $ECF5 then adds $30 to each, which is where the digits stand
  in the tiles.
* $D9F1 lays the script out at $0095: `$46` (an address follows, six bytes),
  the address, the six digits, and a nought to end it.

GAME OVER ($D974) writes the count at $2173 and the best at $21B3, and then
$E237 draws screen $20 and one of thirteen name plates -- which one is
$E223,$55, the stage the game was left in, through $E248.

BEST 5 ($D6CA) writes five counts and five names of three letters, the top of
the board first.  Where each line goes is $D774 (low) and $D779 (high); the
name is nine tiles further along.  The counts and the letters both start from
tables the reset copies into memory at $F954: $E545 and $E54A are the counts,
$E536, $E53B and $E540 the letters.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

FIXED = 14

## $E223 -- which of the thirteen plates a stage is shown by, and $E248 -- the
## screens themselves.
PLATE_OF = 0xE223
PLATE_N = 20
PLATE = 0xE248
PLATE_N2 = 13

## $E237 -- the plate always goes over this screen first.
GROUND = 0x20

## $D99F and $D9AD -- where GAME OVER writes the two counts.
OVER_SCORE = 0x2173
OVER_BEST = 0x21B3

## $ECF5 -- where the digits stand in the tiles.
DIGIT = 0x30

## $D774 low and $D779 high -- where each of the five lines of BEST 5 goes,
## and how much further along its name stands.
BEST_LO = 0xD774
BEST_HI = 0xD779
BEST_N = 5
NAME_AWAY = 9

## $F954 -- what the reset puts in the five lines: three letters apiece out of
## $E536, $E53B and $E540, and a count out of $E545 low and $E54A high.
LETTERS = (0xE536, 0xE53B, 0xE540)
SCORE_LO = 0xE545
SCORE_MID = 0xE54A


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    fixed = prg[FIXED * 0x2000:(FIXED + 2) * 0x2000]

    def at(a, n):
        return list(fixed[a - 0xC000:a - 0xC000 + n])

    lo, hi = at(BEST_LO, BEST_N), at(BEST_HI, BEST_N)
    where = [(hi[i] << 8) | lo[i] for i in range(BEST_N)]
    rows = at(LETTERS[0], BEST_N), at(LETTERS[1], BEST_N), at(LETTERS[2], BEST_N)
    slo, smid = at(SCORE_LO, BEST_N), at(SCORE_MID, BEST_N)
    data = {
        'plate_of': at(PLATE_OF, PLATE_N),
        'plate': at(PLATE, PLATE_N2),
        'ground': GROUND,
        'over_score': OVER_SCORE,
        'over_best': OVER_BEST,
        'digit': DIGIT,
        'best_at': where,
        'name_at': [w + NAME_AWAY for w in where],
        'names': [[rows[0][i], rows[1][i], rows[2][i]] for i in range(BEST_N)],
        'scores': [slo[i] | (smid[i] << 8) for i in range(BEST_N)],
    }
    size = write_json(os.path.join(outdir('sol'), 'over.json'), data)
    print('%d plates, %d lines, %d bytes'
          % (len(data['plate']), BEST_N, size))


if __name__ == '__main__':
    main()
