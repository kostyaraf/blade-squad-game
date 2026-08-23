#!/usr/bin/env python3
"""What sort of place each area is, and where its line runs.

Two numbers decide whether a spot in an area is water, or a drop into
something that kills: $87 says what sort of area this is and $29 says at which
line of the screen the thing starts.  They are set by sixty-odd little
routines, one per area, so instead of reading all of them the game is asked:
each area is opened and the two bytes are read back out of its memory.
"""
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
import pb2_probe as P                                            # noqa: E402

DATA = os.path.join(ROOT, 'game', 'data', 'pb2', 'levels')


def read(stage, area):
    os.makedirs(P.SCRATCH, exist_ok=True)
    state = os.path.join(P.SCRATCH, 'kind_%d_%d.st' % (stage, area))
    P.make_state(state, stage=stage, area=area)
    d = P.scratch('kind')
    try:
        ram = os.path.join(d, 'r.ram')
        subprocess.run([P.EMU, P.ROM, '-loadstate', state,
                        '-frames', str(P.IN_LEVEL + 2), '-ramdump', ram],
                       check=True, capture_output=True)
        m = open(ram, 'rb').read()
        return m[0x87], m[0x29]
    finally:
        P.sweep(d)


def main():
    index = json.load(open(os.path.join(DATA, 'index.json')))
    for st in index['stages']:
        stage = st['stage']
        path = os.path.join(DATA, 'stage%d.json' % stage)
        doc = json.load(open(path))
        for area in range(st['areas']):
            kind, line = read(stage, area)
            doc['areas'][area]['kind'] = kind
            doc['areas'][area]['line'] = line
            print('%d:%-2d kind=%02X line=%02X' % (stage, area, kind, line))
            sys.stdout.flush()
        json.dump(doc, open(path, 'w'), separators=(',', ':'))


if __name__ == '__main__':
    main()
