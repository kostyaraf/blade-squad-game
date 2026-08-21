"""Auto-seeded recursive descent: seeds from all JSR/JMP-abs targets found
anywhere in the PRG that land in [base, base+8K)."""
import sys,os,json
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom
from dis2 import Dis
ROM="/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes"

def seeds(prg, base, srcbanks=None):
    s=set()
    lim=base+0x2000
    for i in range(len(prg)-2):
        if srcbanks is not None and (i//8192) not in srcbanks: continue
        if prg[i] in (0x20,0x4C):
            t=prg[i+1]|prg[i+2]<<8
            if base<=t<lim: s.add(t)
    return s

def run(bank, base, extra=(), datar=(), srcbanks=None, out=None, symbols=None):
    rom=Rom(ROM)
    d=Dis(rom.bank(bank), base)
    for r in datar:
        s=int(r[0],16); e=int(r[1],16)
        for x in range(d.off(s),d.off(e)+1): d.forced_data.add(x)
    ss=seeds(rom.prg, base, srcbanks)|set(extra)
    if base==0xE000:
        v=rom.vectors(); ss|={v['nmi'],v['reset'],v['irq']}
    for e in sorted(ss): d.entries.add(e)
    for e in sorted(ss): d.trace(e)
    txt=d.listing(symbols)
    if out: open(out,'w').write(txt)
    return d,txt

if __name__=='__main__':
    bank=int(sys.argv[1]); base=int(sys.argv[2],16); out=sys.argv[3] if len(sys.argv)>3 else None
    d,txt=run(bank,base,out=out)
    print(f"bank {bank} @ ${base:04X}: coverage {len(d.code)/d.size*100:.1f}%  subs={len(d.subs)} seeds={len(d.entries)}")
