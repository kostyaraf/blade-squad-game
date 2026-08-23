"""Recursive-descent 6502 disassembler for PB2/Solbrain.

Usage:
  python3 dis6502.py <rom> <bank> <base_hex> [entry_hex ...]     -> listing to stdout
Entries default to: all addresses in-range referenced by JSR/JMP from bank 15,
plus vectors if bank is the fixed bank.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom, decode, T, MODELEN, BRANCHES, IMP,ACC,IMM,ZP,ZPX,ZPY,ABS,ABX,ABY,IND,IZX,IZY,REL

class Dis:
    def __init__(self, data, base, name=''):
        self.data = data
        self.base = base
        self.name = name
        self.size = len(data)
        self.code = set()     # offsets that start an instruction
        self.labels = {}      # addr -> label name
        self.xrefs = {}       # addr -> set of source addrs
        self.datarefs = {}    # addr -> set of (src, kind)
        self.entries = set()
        self.subs = set()

    def inrange(self, addr):
        return self.base <= addr < self.base + self.size

    def off(self, addr):
        return addr - self.base

    def trace(self, addr, depth=0):
        stack = [addr]
        while stack:
            a = stack.pop()
            while True:
                if not self.inrange(a): break
                o = self.off(a)
                if o in self.code: break
                ln, txt, mn, md, operand, tgt = decode(self.data, o, a)
                if mn is None:
                    break
                self.code.add(o)
                # mark following bytes as consumed
                if mn == 'JSR':
                    self.xrefs.setdefault(tgt, set()).add(a)
                    if self.inrange(tgt):
                        self.subs.add(tgt)
                        stack.append(tgt)
                    a = a + ln
                    continue
                if mn == 'JMP':
                    if md == ABS:
                        self.xrefs.setdefault(tgt, set()).add(a)
                        if self.inrange(tgt):
                            stack.append(tgt)
                    break
                if mn in BRANCHES:
                    self.xrefs.setdefault(tgt, set()).add(a)
                    if self.inrange(tgt): stack.append(tgt)
                    a = a + ln
                    continue
                if mn in ('RTS','RTI','BRK'):
                    break
                if md in (ABS,ABX,ABY,IND,ZP,ZPX,ZPY) and operand is not None:
                    self.datarefs.setdefault(operand, set()).add((a, mn))
                a = a + ln

    def listing(self, symbols=None, annotate=None):
        symbols = symbols or {}
        annotate = annotate or {}
        out = []
        o = 0
        while o < self.size:
            a = self.base + o
            if o in self.code:
                ln, txt, mn, md, operand, tgt = decode(self.data, o, a)
                lab = ''
                if a in self.xrefs or a in self.entries:
                    kind = 'sub' if a in self.subs else 'loc'
                    lab = f"{kind}_{a:04X}"
                    out.append('')
                    n = len(self.xrefs.get(a,()))
                    out.append(f"{lab}:  ; xrefs={n} " + ' '.join(f"${x:04X}" for x in sorted(self.xrefs.get(a,()))[:8]))
                # symbolize
                stxt = txt
                if operand is not None and md in (ABS,ABX,ABY,IND,ZP,ZPX,ZPY,IZX,IZY):
                    s = symbols.get(operand)
                    if s: stxt = txt.replace(f"${operand:04X}" if md in (ABS,ABX,ABY,IND) else f"${operand:02X}", s)
                if tgt is not None and (md==REL or mn in ('JMP','JSR')):
                    s = symbols.get(tgt)
                    if s: stxt = stxt.replace(f"${tgt:04X}", s)
                raw = ' '.join(f'{b:02X}' for b in self.data[o:o+ln])
                cm = annotate.get(a,'')
                out.append(f"{a:04X}  {raw:<9} {stxt:<20}" + (f" ; {cm}" if cm else ''))
                o += ln
            else:
                # gather data run
                st = o
                while o < self.size and o not in self.code: o += 1
                out.append('')
                out.append(f"; ---- data ${self.base+st:04X}-${self.base+o-1:04X} ({o-st} bytes) ----")
                for i in range(st, o, 16):
                    chunk = self.data[i:min(i+16,o)]
                    out.append(f"{self.base+i:04X}  " + ' '.join(f'{b:02X}' for b in chunk))
        return '\n'.join(out)

def load(rompath):
    return Rom(rompath)

if __name__ == '__main__':
    rom = Rom(sys.argv[1])
    bank = int(sys.argv[2])
    base = int(sys.argv[3], 16)
    d = Dis(rom.bank(bank), base, f'bank{bank}')
    ents = [int(x,16) for x in sys.argv[4:]]
    if not ents and base == 0xE000:
        v = rom.vectors(); ents = [v['nmi'], v['reset'], v['irq']]
    for e in ents:
        d.entries.add(e); d.trace(e)
    print(d.listing())
