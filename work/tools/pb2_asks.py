"""Э6.3.3 -- what Power Blade 2 asked its sound driver for, picture by picture.

Solbrain writes a number into a cell of zero page and the driver picks it up
next picture; Power Blade 2 has no such cell.  A request there is a **call**,
and the door is `$ECE8` in the fixed bank -- so what a stand can compare is not
a byte but a stream: which number was asked for, in which picture, in what
order.

Two doors lead in, and both are requests:

  * `$ECE8` -- ask for the number in `A`.  Sixty-five places reach it through
    the trampoline `$C81C` and fifteen jump or call it outright.
  * `$EC0C` -- `LDA #$00 / JMP $ECE8`, which is "be quiet".  Twenty-seven
    places reach it through the trampoline `$C83D` and ten call it outright.
    Almost every request is a pair: be quiet, then ask.

A hundred and seventeen places in all, and the emulator names each of them:
`-sample ECE8=S` reports the `JSR` whose return is still on the stack, which
for a place that calls the door is the place itself, and for one that jumps
into it is whoever called the routine the jump is in.
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pb2_probe as P                                         # noqa: E402

DOOR = 'ECE8'


def asks(state, script, first, last, pokes=()):
    """Play `script` from `state` and return {frame: [(number, site, bank, slot)]}.

    `script` is a list of (frame, buttons) counted from `first`, the same as
    every other Power Blade 2 stand takes it.  The order inside one picture is
    kept: two requests in one picture are two entries, in the order the
    cartridge made them.
    """
    d = P.scratch('asks')
    inp = os.path.join(d, 'i.inp')
    log = os.path.join(d, 't.log')
    with open(inp, 'w') as f:
        for fr, keys in sorted(script):
            f.write('%d %s\n' % (first + fr, keys or '-'))
    cmd = P.emu('-loadstate', state, '-input', inp, '-frames', str(last + 1),
                '-trace', log, '-tracefrom', '999999', '-traceto', '999999',
                '-sample', '%s=A' % DOOR, '-sample', '%s=S' % DOOR,
                '-sample', '%s=X' % DOOR)
    for a, v, fr in pokes:
        cmd += ['-poke', '%04X=%02X@%d' % (a, v, first + fr)]
    try:
        subprocess.run(cmd, check=True, capture_output=True)
        out = {}
        # The three samples stand at the same address, so the emulator writes
        # them in the order they were asked for: number, place, slot.
        got = {}
        for line in open(log):
            if not line.startswith('SAMPLE'):
                continue
            fr, _pc, bank, what, val = line[7:].strip().split(',')
            got[what] = val
            if what == 'S':
                # For the place, the bank named is the caller's own.
                got['bank'] = bank
                continue
            if what != 'X':
                continue
            out.setdefault(int(fr), []).append(
                (int(got['A'], 16), int(got['S'], 16), int(got['bank']),
                 int(val, 16)))
        return out
    finally:
        P.sweep(d)


def main():
    """Every request of a plain run from the start of the game."""
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 2600
    d = P.scratch('asksmain')
    try:
        state = P.make_state(os.path.join(d, 'boot.state'))
        for fr, rows in sorted(asks(state, [(0, '-')], P.IN_LEVEL,
                                    P.IN_LEVEL + frames).items()):
            for n, site, bank, slot in rows:
                print('%6d  n=%02X  %2d:$%04X  slot=%02X'
                      % (fr, n, bank, site, slot))
    finally:
        P.sweep(d)


if __name__ == '__main__':
    main()
