#!/usr/bin/env python3
"""Follow-the-code disassembly of one object's mind.

  python3 objdis.py <type-hex>

A linear disassembler is no use on these: the two dispatch trampolines lay a
word table in the middle of the code, right after the JSR, so everything past
it comes out as nonsense.  This one walks the code instead of reading straight
through, knows both conventions, and stops where the code stops.

  JSR $C97E   the next 2*n bytes are handlers, one per state ($058C,X)
  JSR $C84F   the same, but the row is whatever was in A

Neither returns to the JSR: $CA0B pulls the return address off the stack and
jumps.  How long the table is nobody writes down, so it is taken to end at the
first word that does not point into the same bank window as the code, or at
the first address the walk has already reached as code.
"""
import os
import sys

HERE = '/Users/hropl/pr/mypr/PB3/work/tools'
sys.path.insert(0, HERE)
from m6502 import decode                                     # noqa: E402

ROM = open('/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes', 'rb').read()[16:]
AI = 0x8080                     # the table of minds, bank 10
TRAMP = {0xC97E: 'state', 0xC84F: 'word'}
# The trampolines, so a call reads as what it does rather than as a number.
NAMES = {}


def bank_of(addr):
    """Which bank holds this address.  The two fixed ones are known; the object
    banks are 10 for $8000-$9FFF and 11 for $A000-$BFFF."""
    if addr >= 0xE000:
        return 15
    if addr >= 0xC000:
        return 14
    if addr >= 0xA000:
        return 11
    return 10


def data(bank):
    return ROM[bank * 0x2000:(bank + 1) * 0x2000]


def read(addr, n=1):
    b = data(bank_of(addr))
    o = addr - (addr & 0xE000)
    return b[o:o + n]


def word(addr):
    lo, hi = read(addr, 2)
    return lo | (hi << 8)


def load_names():
    """$C810..$C9BD is a run of JMPs; name each by where it goes."""
    a = 0xC810
    while a < 0xC9C0:
        if read(a)[0] != 0x4C:
            break
        NAMES[a] = '$%04X' % word(a + 1)
        a += 3


ENDS = (0x60, 0x40, 0x6C)       # RTS, RTI, JMP (ind)

# The other convention: a helper that reads its argument out of the code that
# called it.  $BE45 takes one byte, $BE4E two, $BEEF three; each of the little
# routines around them is one of those followed by a store, so a call to any of
# them is followed by that many bytes that are not code.  All of them live in
# bank 11, and the object banks are the only callers.
INLINE = {0xBE45: 1, 0xBE4E: 2, 0xBEEF: 3}
for _a in (0xBE5A, 0xBE63, 0xBE6E, 0xBE75, 0xBE7C, 0xBE83, 0xBE8A, 0xBE91,
           0xBE98, 0xBE9F, 0xBEA6, 0xBEAD):
    INLINE[_a] = 1
for _a in (0xBEB3, 0xBEB9, 0xBEBF, 0xBEC5, 0xBECB, 0xBED1, 0xBED7, 0xBEDD,
           0xBEE3, 0xBEE9):
    INLINE[_a] = 2
for _a in (0xBF00, 0xBF06, 0xBF0C, 0xBF12):
    INLINE[_a] = 3


def walk(start, bank):
    """Disassemble from `start`, following branches and JMPs inside the bank."""
    base = start & 0xE000
    b = data(bank)
    seen = {}
    tables = {}
    args = {}
    todo = [start]
    while todo:
        pc = todo.pop()
        while True:
            if pc in seen or pc < base or pc >= base + 0x2000:
                break
            ln, txt = decode(b, pc - base, pc)[:2]
            seen[pc] = (ln, txt)
            op = b[pc - base]
            nxt = pc + ln
            if op == 0x20:                      # JSR
                dst = b[pc - base + 1] | (b[pc - base + 2] << 8)
                kind = TRAMP.get(NAMES.get(dst) and int(NAMES[dst][1:], 16))
                if dst in NAMES and int(NAMES[dst][1:], 16) in ():
                    pass
                if dst in (0xC97E, 0xC84F) or NAMES.get(dst) in (
                        '$FD10', '$CA0B'):
                    # Nobody writes down how long the table is.  It ends
                    # where the code it points at begins: the first state
                    # handler that lies after the table is the table's own
                    # end, because there is nothing between them.
                    n = 0
                    stop = base + 0x2000
                    while nxt + 2 * n < stop:
                        w = word(nxt + 2 * n)
                        if w < base or w >= base + 0x2000:
                            break
                        n += 1
                        if w > nxt:
                            stop = min(stop, w)
                        if n > 24:
                            break
                    tables[nxt] = [word(nxt + 2 * i) for i in range(n)]
                    todo.extend(tables[nxt])
                    pc = nxt + 2 * n
                    continue
                if dst in INLINE:
                    args[nxt] = INLINE[dst]
                    pc = nxt + INLINE[dst]
                    continue
                if base <= dst < base + 0x2000:
                    todo.append(dst)
                pc = nxt
                continue
            if op == 0x4C:                      # JMP abs
                dst = b[pc - base + 1] | (b[pc - base + 2] << 8)
                if base <= dst < base + 0x2000:
                    todo.append(dst)
                break
            if op in ENDS:
                break
            if (op & 0x1F) == 0x10:             # branch
                dst = pc + 2 + (b[pc - base + 1] - 256
                                if b[pc - base + 1] > 127
                                else b[pc - base + 1])
                todo.append(dst)
            pc = nxt
    return seen, tables, args


def main():
    load_names()
    t = int(sys.argv[1], 16)
    start = word(AI + 2 * t) if AI else 0
    b10 = data(10)
    start = b10[AI - 0x8000 + 2 * t] | (b10[AI - 0x8000 + 2 * t + 1] << 8)
    bank = bank_of(start)
    print('type $%02X -> $%04X (bank %d)' % (t, start, bank))
    seen, tables, args = walk(start, bank)
    # A branch that was never really a branch can point into the middle of a
    # real instruction, and the walk will decode from there too.  Printed in
    # order, those overlaps read as nonsense between the true lines, so an
    # address that falls inside the line before it is dropped.
    end = -1
    for a in sorted(set(seen) | set(args) | set(tables)):
        if a < end:
            continue
        if a in tables:
            end = a + 2 * len(tables[a])
        elif a in seen:
            end = a + seen[a][0]
        elif a in args:
            end = a + args[a]
        if a in args:
            n = args[a]
            print('%04X: %-9s <- argument of the call above'
                  % (a, ' '.join('%02X' % x for x in read(a, n))))
        if a in tables:
            print('%04X: --- %d states: %s' % (
                a, len(tables[a]),
                ' '.join('$%04X' % w for w in tables[a])))
            continue
        if a not in seen:
            continue
        ln, txt = seen[a]
        raw = ' '.join('%02X' % x for x in data(bank)[a - (a & 0xE000):
                                                     a - (a & 0xE000) + ln])
        note = ''
        op = data(bank)[a - (a & 0xE000)]
        if op in (0x20, 0x4C):
            d = data(bank)
            dst = d[a - (a & 0xE000) + 1] | (d[a - (a & 0xE000) + 2] << 8)
            if dst in NAMES:
                note = '-> ' + NAMES[dst]
        print('%04X: %-9s %-18s %s' % (a, raw, txt, note))


main()
