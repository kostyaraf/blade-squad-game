#!/usr/bin/env python3
"""Compare the collision the cartridge is using with the one we exported.

The console keeps what the physics reads in a small cache at $0680: sixteen
rows of sixteen cells, two bits each.  If the engine's map is right, the cache
and the map say the same thing about every cell on the screen.
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pb2_probe as P                                          # noqa: E402
from pb2_map import Area                                       # noqa: E402

CLASS = [0x00, 0x01, 0x80, 0x02]
SIGN = {0x00: '.', 0x01: '=', 0x80: '#', 0x02: '!'}


def cache(stage, area, spot=None, script=(), frames=2):
    """The cache, and the camera, as the game has them after `frames`."""
    state = os.path.join(tempfile.gettempdir(),
                         'cache_%d_%d_%s.st' % (stage, area, spot))
    P.make_state(state, stage=stage, area=area, spot=spot)
    d = tempfile.mkdtemp(prefix='pb2cache')
    ram = os.path.join(d, 'r.ram')
    cmd = [P.EMU, P.ROM, '-loadstate', state,
           '-frames', str(P.IN_LEVEL + frames), '-ramdump', ram]
    if script:
        inp = os.path.join(d, 'i.inp')
        with open(inp, 'w') as f:
            for fr, keys in sorted(script):
                f.write('%d %s\n' % (P.IN_LEVEL + fr, keys or '-'))
        cmd += ['-input', inp]
    subprocess.run(cmd, check=True, capture_output=True)
    m = open(ram, 'rb').read()
    grid = {}
    for page in (0, 1):
        for row in range(16):
            for col in range(16):
                b = m[0x0680 + page * 0x40 + row * 4 + (col >> 2)]
                grid[(page, row, col)] = CLASS[(b >> ((col & 3) * 2)) & 3]
    cam = (m[0x66] << 8) | m[0x67]
    return grid, cam, m


def main():
    stage, area = (int(x) for x in sys.argv[1].split(':'))
    frames = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    keys = sys.argv[3] if len(sys.argv) > 3 else None
    a = Area(stage, area)
    spot = None
    grid, cam, m = cache(stage, area, spot,
                         [(2, keys)] if keys else (), frames)
    page = m[0xFF] & 1
    print('cam=%d page=%d $FD=%02X $FC=%02X' % (cam, page, m[0xFD], m[0xFC]))
    print('   cartridge         map')
    for row in range(16):
        left = ''.join(SIGN[grid[(page, row, c)]] for c in range(16))
        # the cache's columns are the map's, taken modulo a screen
        right = ''
        for c in range(16):
            px = (cam & ~0xFF) + c * 16 + (0 if a.vertical else 0)
            py = row * 16 if not a.vertical else row * 16
            right += SIGN[a.klass(px if not a.vertical else c * 16,
                                  py if not a.vertical else py)]
        print('%2d %s  %s' % (row, left, right))


if __name__ == '__main__':
    main()
