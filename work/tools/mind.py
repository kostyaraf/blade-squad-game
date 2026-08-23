#!/usr/bin/env python3
"""Recursive-descent listing of one mind, following the cartridge's three
inline-argument conventions and the word table laid after JSR $C97E.

  python3 mind.py <bank> <entry_hex> [more entries...]
"""
import sys, os
sys.path.insert(0, '/Users/hropl/pr/mypr/PB3/work/tools')
from m6502 import decode

ROM = '/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes'
ARGS = {}
for a in (0xBE5A, 0xBE63, 0xBE6A, 0xBE6E, 0xBE75, 0xBE7C, 0xBE83, 0xBE8A,
          0xBE91, 0xBE98, 0xBE9F, 0xBEA6, 0xBEAD):
    ARGS[a] = 1
for a in (0xBEB3, 0xBEB9, 0xBEBF, 0xBEC5, 0xBECB, 0xBED1, 0xBED7, 0xBEDD,
          0xBEE3, 0xBEE9):
    ARGS[a] = 2
for a in (0xBF00, 0xBF06, 0xBF0C, 0xBF12):
    ARGS[a] = 3
TABLE = 0xC97E                       # a word table follows, one per state
STOP = {0x60, 0x40, 0x4C, 0x6C}      # RTS, RTI, JMP


def main():
    bank = int(sys.argv[1], 0)
    rom = open(ROM, 'rb').read()
    entries = [int(a, 16) for a in sys.argv[2:]]
    base = entries[0] & 0xE000
    data = rom[16 + bank * 0x2000: 16 + (bank + 1) * 0x2000]

    seen = {}
    args = set()
    todo = list(entries)
    while todo:
        pc = todo.pop()
        while True:
            if pc in seen or not (base <= pc < base + 0x2000):
                break
            off = pc - base
            size, text = decode(data, off, pc)[:2]
            seen[pc] = (text, size)
            op = data[off]
            nxt = pc + size
            if op == 0x20:                     # JSR
                t = data[off + 1] | data[off + 2] << 8
                if t in ARGS:
                    for k in range(ARGS[t]):
                        args.add(nxt + k)
                    nxt += ARGS[t]
                elif t == TABLE:
                    # The table runs until the first word in it that points
                    # into the table itself or past it -- the entries are all
                    # in the same bank and none is below the table's head.
                    n = 0
                    lowest = 0xFFFF
                    while True:
                        w = (data[nxt - base + 2 * n]
                             | data[nxt - base + 2 * n + 1] << 8)
                        if not (base <= w < base + 0x2000):
                            break
                        if nxt + 2 * n >= lowest:
                            break
                        if w > nxt:
                            lowest = min(lowest, w)
                        todo.append(w)
                        n += 1
                    for k in range(2 * n):
                        args.add(nxt + k)
                    nxt += 2 * n
                if t in ARGS or t == TABLE or (base <= t < base + 0x2000):
                    if base <= t < base + 0x2000 and t not in ARGS \
                            and t != TABLE:
                        todo.append(t)
            elif 0x10 <= op <= 0xF0 and (op & 0x1F) == 0x10:   # Bxx
                d = data[off + 1]
                todo.append(pc + 2 + (d - 256 if d > 127 else d))
            elif op in STOP:
                if op == 0x4C:
                    t = data[off + 1] | data[off + 2] << 8
                    if base <= t < base + 0x2000:
                        todo.append(t)
                break
            pc = nxt

    for pc in sorted(seen):
        if pc in args:
            continue
        text, size = seen[pc]
        raw = ' '.join('%02X' % data[pc - base + k] for k in range(size))
        tail = ''
        if size == 3 and data[pc - base] == 0x20:
            t = data[pc - base + 1] | data[pc - base + 2] << 8
            n = ARGS.get(t, 0)
            if n:
                tail = '   ; ' + ' '.join(
                    '%02X' % data[pc - base + 3 + k] for k in range(n))
        print('%04X: %-9s %-16s%s' % (pc, raw, text, tail))


main()
