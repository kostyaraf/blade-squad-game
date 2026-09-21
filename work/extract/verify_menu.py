#!/usr/bin/env python3
"""Э7.2 acceptance: the screen the build opens on does what it promises.

This one stand in the whole project compares nothing against a cartridge,
and it says so out loud.  The screen that asks which game is wanted is the
port's own: each cartridge was its console's whole world and never had to
ask.  There is no recording to hold this against, so what is written down
here is the promise the screen makes, and the stand keeps it honest.

The promise:

* the caret walks one row a press, down and up, and holds at both ends;
* only the edge of a press counts, the way both games count the pad -- a
  button held down does not walk the caret on;
* START takes the row the caret stands on, and A does the same;
* once a row is taken the screen is finished with: nothing moves after, and
  nothing is taken a second time.

And the one thing that matters to every other stand: a run that was asked for
anything at all on the command line never sees this screen
(`OS.get_cmdline_user_args().is_empty()` is the whole of the condition).  That
is not checked here but by the other sixty-three stands, every one of which
drives `main.gd` by its arguments and would answer nothing if the screen came
up in front of them.
"""
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'work', 'tools'))
sys.path.insert(0, HERE)
import pb2_trace                                             # noqa: E402
import verify_player as V                                    # noqa: E402

# The pad as both cartridges order it, which is what `Pad` holds.
A = 0x80
START = 0x10
UP = 0x08
DOWN = 0x04

# Which game each row is, top down.  Two, and not three: the PB3 mode has
# never been drawn, so the screen does not offer it -- see work/re/release.md.
ROWS = ['pb2', 'sol']

# (name, the buttons picture by picture, what the caret should read after each
#  of them, and what should have been taken by then)
WALKS = [
    ('stands still', [0, 0, 0], [0, 0, 0], [None, None, None]),
    ('down one', [DOWN, 0], [1, 1], [None, None]),
    # A button held is not a button pressed: the caret walks once and waits.
    ('down held', [DOWN, DOWN, DOWN], [1, 1, 1], [None, None, None]),
    ('down twice', [DOWN, 0, DOWN, 0], [1, 1, 1, 1], [None] * 4),
    ('up at the top', [UP, 0, UP], [0, 0, 0], [None, None, None]),
    ('down then up', [DOWN, 0, UP, 0], [1, 1, 0, 0], [None] * 4),
    ('start takes the top', [START, 0], [0, 0], ['pb2', 'pb2']),
    ('a takes it too', [A, 0], [0, 0], ['pb2', 'pb2']),
    ('start takes the second', [DOWN, 0, START, 0],
     [1, 1, 1, 1], [None, None, 'sol', 'sol']),
    # Once taken, the screen is done: neither the caret nor the answer moves.
    ('taken is taken', [START, 0, DOWN, 0, START],
     [0, 0, 0, 0, 0], ['pb2'] * 5),
]


def engine(buttons, path):
    """The screen walked by that script, one line to a picture."""
    open(path, 'w').write(json.dumps({'frames': buttons}))
    try:
        r = subprocess.run([V.GODOT, '--path', V.GAME, '--headless', '--',
                            '--menu=' + path], capture_output=True,
                           text=True, timeout=V.ENGINE_WAIT)
    except subprocess.TimeoutExpired:
        sys.stderr.write('the engine never stopped\n')
        return []
    out = []
    for line in r.stdout.split('\n'):
        parts = line.strip().split('|')
        if len(parts) != 2 or not parts[0].strip().isdigit():
            continue
        took = parts[1].strip()
        out.append((int(parts[0]), None if took == '-' else took))
    if not out:
        sys.stderr.write(r.stdout[-3000:] + r.stderr[-3000:])
    return out


def check(name, buttons, carets, takens, tmp):
    got = engine(buttons, os.path.join(tmp, 'm.json'))
    # Line nought is the screen as it stands before anything is pressed, and
    # it is not one of the pictures the walk asks about.
    if len(got) != len(buttons) + 1:
        return None, ('the engine put out %d lines, not %d'
                      % (len(got), len(buttons) + 1))
    if got[0] != (0, None):
        return None, 'the screen came up on %r' % (got[0],)
    for i in range(len(buttons)):
        want = (carets[i], takens[i])
        if got[i + 1] != want:
            return None, ('picture %d: the screen says %r, the promise is %r'
                          % (i, got[i + 1], want))
    return len(buttons), None


def main():
    tmp = pb2_trace.P.scratch('menuverify')
    bad = pictures = 0
    try:
        for name, buttons, carets, takens in WALKS:
            n, why = check(name, buttons, carets, takens, tmp)
            if why is None:
                pictures += n
                print('%-24s ok   %d pictures' % (name, n))
            else:
                bad += 1
                print('%-24s BROKEN  %s' % (name, why))
            sys.stdout.flush()
    finally:
        pb2_trace.P.sweep(tmp)
    print('%d pictures of the screen, %d rows offered (%s)'
          % (pictures, len(ROWS), ', '.join(ROWS)))
    print('%d of %d walks break the promise' % (bad, len(WALKS)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
