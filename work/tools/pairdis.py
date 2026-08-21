"""Disassemble an MMC3 PRG bank pair as a 16K unit at $8000-$BFFF (+ optional
fixed banks 14@C000 / 15@E000 appended for context)."""
import sys,os,json
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom
from dis2 import Dis
ROM="/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes"
SYMFILE=os.path.join(os.path.dirname(os.path.abspath(__file__)),'syms.json')

def symbols():
    try: return json.load(open(SYMFILE))
    except Exception: return {}

def covseeds(pair):
    import glob, covseed
    paths=glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','dyn','*.cov'))
    if not paths: return set()
    m=covseed.load(paths)
    out=set()
    if pair=='C000': banks={14:0xC000}
    elif pair=='E000': banks={15:0xE000}
    else: p=int(pair); banks={p:0x8000, p+1:0xA000}
    for s0,e0 in covseed.ranges(m):
        b=s0//8192
        if b in banks and e0//8192==b:
            out.add(banks[b]+(s0%8192))
    return out

def build(pair, extra=(), data=(), seedsrc=None):
    rom=Rom(ROM)
    if pair=='C000':
        data_img=rom.bank(14); base=0xC000; own={14}
    elif pair=='E000':
        data_img=rom.bank(15); base=0xE000; own={15}
    else:
        p=int(pair)
        data_img=rom.bank(p)+rom.bank(p+1); base=0x8000; own={p,p+1}
    d=Dis(data_img, base)
    for r in data:
        s=int(r[0],16); e=int(r[1],16)
        for x in range(d.off(s),d.off(e)+1): d.forced_data.add(x)
    lim=base+len(data_img)
    ss=set()
    src = own | set(seedsrc or [14,15])
    for i in range(len(rom.prg)-2):
        if (i//8192) not in src: continue
        if rom.prg[i] in (0x20,0x4C):
            t=rom.prg[i+1]|rom.prg[i+2]<<8
            if base<=t<lim: ss.add(t)
    ss|=set(extra)
    ss|=covseeds(pair)
    if base==0x8000:
        # entry jump table at $8000
        for k in range(0,64,3):
            if data_img[k]==0x4C: ss.add(0x8000+k)
            else: break
    if base==0xE000:
        v=rom.vectors(); ss|=set(v.values())
    for e in sorted(ss): d.entries.add(e)
    for e in sorted(ss): d.trace(e)
    return d

if __name__=='__main__':
    pair=sys.argv[1]; out=sys.argv[2] if len(sys.argv)>2 else None
    extra=[int(x,16) for x in sys.argv[3:]]
    d=build(pair,extra)
    txt=d.listing(symbols())
    if out: open(out,'w').write(txt)
    else: print(txt)
    print(f"pair {pair}: coverage {len(d.code)/d.size*100:.1f}% subs={len(d.subs)} entries={len(d.entries)}",file=sys.stderr)
