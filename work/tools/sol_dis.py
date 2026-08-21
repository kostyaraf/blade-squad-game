"""Solbrain disassembler: recursive descent with cross-bank fixed region support.

Regions:
  'fixed'  = PRG banks 14+15 mapped at $C000-$FFFF (16KB)
  bank N   = mapped at $8000 (R6) or $A000 (R7)

Usage:
  python3 sol_dis.py fixed [entry...]         -> listing of $C000-$FFFF
  python3 sol_dis.py <bank> <base> [entry...] -> listing of one 8K bank
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom, decode, T, MODELEN, BRANCHES, IMP,ACC,IMM,ZP,ZPX,ZPY,ABS,ABX,ABY,IND,IZX,IZY,REL

ROM = "/Users/hropl/pr/mypr/PB3/Tokkyuu Shirei Solbrain (Japan).nes"

class Dis:
    def __init__(self, data, base, name=''):
        self.data=data; self.base=base; self.name=name; self.size=len(data)
        self.code=set(); self.xrefs={}; self.datarefs={}; self.entries=set(); self.subs=set()
        self.jumptabs={}     # addr -> nentries  (manually declared)
        self.forced_data=set()
        self.inline_disp=set()   # addresses of JSR-dispatch routines with inline word table
    def inrange(self,a): return self.base<=a<self.base+self.size
    def off(self,a): return a-self.base
    def trace(self, addr):
        stack=[addr]
        while stack:
            a=stack.pop()
            while True:
                if not self.inrange(a): break
                o=self.off(a)
                if o in self.code or o in self.forced_data: break
                ln,txt,mn,md,operand,tgt=decode(self.data,o,a)
                if mn is None: break
                for k in range(ln): self.code.add(o+k) if False else None
                self.code.add(o)
                if mn=='JSR':
                    self.xrefs.setdefault(tgt,set()).add(a)
                    if self.inrange(tgt): self.subs.add(tgt); stack.append(tgt)
                    if tgt in self.inline_disp:
                        ta=a+ln
                        n=0; to=self.off(ta)
                        while n<128:
                            if to+n*2+1>=self.size: break
                            t=self.data[to+n*2]|self.data[to+n*2+1]<<8
                            if not self.inrange(t): break
                            n+=1
                        if n:
                            self.add_jumptable(ta,n)
                        break
                    a=a+ln; continue
                if mn=='JMP':
                    if md==ABS:
                        self.xrefs.setdefault(tgt,set()).add(a)
                        if self.inrange(tgt): stack.append(tgt)
                    break
                if mn in BRANCHES:
                    self.xrefs.setdefault(tgt,set()).add(a)
                    if self.inrange(tgt): stack.append(tgt)
                    a=a+ln; continue
                if mn in ('RTS','RTI','BRK'): break
                if md in (ABS,ABX,ABY,IND,ZP,ZPX,ZPY) and operand is not None:
                    self.datarefs.setdefault(operand,set()).add((a,mn))
                a=a+ln
    def add_jumptable(self, addr, n, kind='addr'):
        if n<=0: return
        """kind='addr' little-endian words; trace each."""
        self.jumptabs[addr]=(n,kind)
        o=self.off(addr)
        for i in range(n):
            if kind=='addr':
                t=self.data[o+i*2]|self.data[o+i*2+1]<<8
            else:
                t=self.data[o+i]|(self.data[o+n+i]<<8)
            self.xrefs.setdefault(t,set()).add(addr)
            if self.inrange(t): self.subs.add(t); self.trace(t)
    def listing(self, symbols=None, annotate=None, comments=None):
        symbols=symbols or {}; annotate=annotate or {}; comments=comments or {}
        out=[]; o=0
        while o<self.size:
            a=self.base+o
            if a in self.jumptabs:
                n,kind=self.jumptabs[a]
                out.append(''); out.append(f"; ---- jump table ${a:04X} ({n} entries) ----")
                if kind=='addr':
                    for i in range(n):
                        t=self.data[o+i*2]|self.data[o+i*2+1]<<8
                        out.append(f"{a+i*2:04X}  .word ${t:04X}   ; [{i:02X}] {symbols.get(t,'')}")
                    o+=n*2
                else:
                    for i in range(n):
                        t=self.data[o+i]|(self.data[o+n+i]<<8)
                        out.append(f"  [{i:02X}] ${t:04X}  {symbols.get(t,'')}")
                    o+=n*2
                continue
            if o in self.code:
                ln,txt,mn,md,operand,tgt=decode(self.data,o,a)
                if a in self.xrefs or a in self.entries:
                    kind='sub' if a in self.subs else 'loc'
                    lab=symbols.get(a) or f"{kind}_{a:04X}"
                    out.append('')
                    xs=sorted(self.xrefs.get(a,()))
                    out.append(f"{lab}:  ; xrefs({len(xs)}): "+' '.join(f"${x:04X}" for x in xs[:10]))
                    if a in comments: out.append("; "+comments[a])
                stxt=txt
                if operand is not None and md in (ABS,ABX,ABY,IND,ZP,ZPX,ZPY,IZX,IZY):
                    s=symbols.get(operand)
                    if s:
                        pat=f"${operand:04X}" if md in (ABS,ABX,ABY,IND) else f"${operand:02X}"
                        stxt=txt.replace(pat,s)
                if tgt is not None and (md==REL or mn in ('JMP','JSR')):
                    s=symbols.get(tgt)
                    if s: stxt=stxt.replace(f"${tgt:04X}",s)
                raw=' '.join(f'{b:02X}' for b in self.data[o:o+ln])
                cm=annotate.get(a,'')
                out.append(f"{a:04X}  {raw:<8} {stxt:<26}"+(f" ; {cm}" if cm else ''))
                o+=ln
            else:
                st=o
                while o<self.size and o not in self.code and (self.base+o) not in self.jumptabs: o+=1
                out.append(''); out.append(f"; ---- data ${self.base+st:04X}-${self.base+o-1:04X} ({o-st} bytes) ----")
                for i in range(st,o,16):
                    chunk=self.data[i:min(i+16,o)]
                    txt=''.join(chr(c) if 32<=c<127 else '.' for c in chunk)
                    out.append(f"{self.base+i:04X}  "+' '.join(f'{b:02X}' for b in chunk).ljust(48)+" |"+txt)
        return '\n'.join(out)

def fixed_region(rom):
    return rom.bank(14)+rom.bank(15)

if __name__=='__main__':
    rom=Rom(ROM)
    if sys.argv[1]=='fixed':
        d=Dis(fixed_region(rom),0xC000,'fixed')
        v=rom.vectors(); ents=[v['nmi'],v['reset'],v['irq']]+[int(x,16) for x in sys.argv[2:]]
    else:
        b=int(sys.argv[1]); base=int(sys.argv[2],16)
        d=Dis(rom.bank(b),base,f'bank{b}')
        ents=[int(x,16) for x in sys.argv[3:]]
    for e in ents: d.entries.add(e); d.trace(e)
    print(d.listing())
