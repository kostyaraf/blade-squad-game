#!/usr/bin/env python3
"""Linear disassembly of a Solbrain PRG bank at a CPU address."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import decode

ROM = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..',
                   'Tokkyuu Shirei Solbrain (Japan).nes')

def load():
    d = open(ROM, 'rb').read()
    return d[16:16+128*1024]

def dis(bank, base, addr, n):
    prg = load()
    data = prg[bank*8192:(bank+1)*8192]
    off = addr - base
    end = off + n
    out = []
    while off < end and off < len(data):
        ln, txt = decode(data, off, base + off)[:2]
        raw = ' '.join('%02X' % b for b in data[off:off+ln])
        out.append('%04X  %-9s %s' % (base+off, raw, txt))
        off += ln
    return '\n'.join(out)

if __name__ == '__main__':
    bank = int(sys.argv[1])
    addr = int(sys.argv[2], 16)
    n = int(sys.argv[3], 16) if len(sys.argv) > 3 else 0x40
    base = 0xA000 if (addr >= 0xA000 and addr < 0xC000) else 0x8000
    if addr >= 0xC000: base = 0xC000 if addr < 0xE000 else 0xE000
    print(dis(bank, base, addr, n))
