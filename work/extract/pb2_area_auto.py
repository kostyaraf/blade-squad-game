#!/usr/bin/env python3
"""Which areas carry the view along by themselves.

$D924 asks $2E first.  Zero means the view follows the hero, as everywhere
else.  Anything else means the area moves it on its own: $2E picks how often
($D941 -- three, four and five every fourth picture, seven and two every
eighth, the rest every sixteenth) and which way (odd goes back, even goes on),
and $5E holds it still for that many pictures first.

Nobody writes these down in the level data in one place, so the game is asked:
each area is opened, played for a moment, and the two bytes read back out.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
import pb2_probe as P                                            # noqa: E402

DATA = os.path.join(ROOT, 'game', 'data', 'pb2', 'levels')
# Far enough in that the area's own opening has finished setting them.
AFTER = 60


def read(stage, area):
    os.makedirs(P.SCRATCH, exist_ok=True)
    state = os.path.join(P.SCRATCH, 'auto_%d_%d.st' % (stage, area))
    P.make_state(state, stage=stage, area=area)
    d = P.scratch('auto')
    try:
        ram = os.path.join(d, 'r.ram')
        subprocess.run([P.EMU, P.ROM, '-loadstate', state,
                        '-frames', str(P.IN_LEVEL + AFTER), '-ramdump', ram],
                       check=True, capture_output=True)
        m = open(ram, 'rb').read()
        return m[0x2E], m[0x5E]
    finally:
        P.sweep(d)


def main():
    index = json.load(open(os.path.join(DATA, 'index.json')))
    for st in index['stages']:
        stage = st['stage']
        path = os.path.join(DATA, 'stage%d.json' % stage)
        doc = json.load(open(path))
        for area in range(st['areas']):
            auto, wait = read(stage, area)
            doc['areas'][area]['auto'] = auto
            doc['areas'][area]['auto_wait'] = wait
            if auto or wait:
                print('%d:%-2d $2E=%02X $5E=%02X' % (stage, area, auto, wait))
                sys.stdout.flush()
        json.dump(doc, open(path, 'w'), separators=(',', ':'))


if __name__ == '__main__':
    main()
