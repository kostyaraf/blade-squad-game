#!/usr/bin/env python3
"""Export the four panels of every stage -- what ducking on one buys.

Solbrain has no shops and no pick-ups for the three things that matter; it has
panels set into the walls, and the hero buys from one by ducking on it.  The
whole of it is $9CA0, the tail of the ducking state in bank twelve:

* $9D6E holds four tile numbers a stage, and the tile his feet are standing
  on ($2A, with the low bit dropped) is compared against each of the four in
  turn.  A stage that has no panel of a kind writes nought there, and nought
  is never a tile.
* The first buys a shield ($9DBE): $05C8 is put to three for ten.
* The second fills the suit ($9CC3 and $9E00): while $05C5 is under eight a
  step goes on every odd picture, and the thirty it costs is only taken when
  the eighth step lands.  Under it the count of his own arrival is held at
  $20 ($8825), so he does not die while he stands there.
* The third buys a try ($9E30): $071C goes up by one for two hundred.
* The fourth ($9DDF) is whichever of those three the table at $9DEC names for
  the stage.

What it is paid with is the bonus he has not been paid yet ($05C6:$05C7), and
the paying is spread out: $9E4F puts the price on $56, and $CDE3 takes one off
both $56 and the bonus every picture until $56 is nought.

A panel used up is broken open ($9E6D): the two places under his feet are put
through $BA15 -- the panels' own "may this give way", which is not the punch's
$B9CD -- and object $2D is hatched between them.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import ROM_SOL, outdir, write_json                  # noqa: E402

# Banks twelve and thirteen stand together, so one window reads both.
BANK, BASE = 12, 0x8000

## $9D6E -- four tiles a stage: shield, suit, try, and the one the table below
## names.
TILES, STAGES = 0x9D6E, 20
## $9DEC -- what the fourth panel of each stage gives: nought a shield, one a
## step of suit, anything else a try.
GIFT = 0x9DEC

## $9DC5, $9E07 and $9E30 -- what each of the three costs.
COST_SHIELD, COST_SUIT, COST_TRY = 0x0A, 0x1E, 0xC8
## $9DCF -- what a bought shield is worth, and $9E05 -- the whole suit.
SHIELD_FULL, SUIT_FULL = 0x03, 0x08
## $9DD7, $9E23 and $9E40 -- the noises.
NOISE_DONE, NOISE_TRY = 0x1F, 0x11
## $8825 -- the count his own arrival is held at while he stands on a panel.
HOLD_TIMER = 0x20
## $9E48 -- the button the panel holds down for him, so that he keeps ducking.
HOLD_PAD = 0x04
## $9E8D -- what is hatched where a panel was used up.
SPAWN = 0x2D


def main():
    with open(ROM_SOL, 'rb') as f:
        prg = f.read()[16:]
    win = prg[BANK * 0x2000:BANK * 0x2000 + 0x4000]

    def at(a, n):
        return list(win[a - BASE:a - BASE + n])

    rows = at(TILES, STAGES * 4)
    data = {
        'tiles': [rows[i * 4:i * 4 + 4] for i in range(STAGES)],
        'gift': at(GIFT, STAGES),
        'cost': [COST_SHIELD, COST_SUIT, COST_TRY],
        'shield_full': SHIELD_FULL,
        'suit_full': SUIT_FULL,
        'noise_done': NOISE_DONE,
        'noise_try': NOISE_TRY,
        'hold_timer': HOLD_TIMER,
        'hold_pad': HOLD_PAD,
        'spawn': SPAWN,
    }
    d = outdir('sol')
    size = write_json(os.path.join(d, 'panels.json'), data)
    have = sum(1 for r in data['tiles'] for t in r if t)
    print('%d stages, %d panels, %d bytes' % (STAGES, have, size))


if __name__ == '__main__':
    main()
