#!/usr/bin/env python3
"""Linear disassembly of one window of one bank.

  python3 lin.py <rom> <bank> <start_hex> <end_hex>

The banks are the 8K windows the cartridge switches, so an address is read as
bank*0x2000 + (addr - base) where base is $8000 for even banks in this game's
layout -- both games map a chosen bank at $8000 and $A000.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import decode

rom = open(sys.argv[1], 'rb').read()
bank = int(sys.argv[2], 0)
start = int(sys.argv[3], 16)
end = int(sys.argv[4], 16)
base = 0x8000 + 0x2000 * ((start >> 13) & 3 if start >= 0x8000 else 0)
base = start & 0xE000
data = rom[16 + bank * 0x2000: 16 + (bank + 1) * 0x2000]
pc = start
while pc < end:
    off = pc - base
    ln, txt = decode(data, off, pc)[:2]
    raw = ' '.join('%02X' % b for b in data[off:off + ln])
    print('%04X: %-9s %s' % (pc, raw, txt))
    pc += ln
