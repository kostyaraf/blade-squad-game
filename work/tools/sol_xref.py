"""Global RAM cross-reference over all disassembled regions."""
import sys, os, re, collections, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom, decode, ABS,ABX,ABY,ZP,ZPX,ZPY,IZX,IZY,IND
from sol_dis import Dis, ROM, fixed_region
from sol_pair import pair, head_entries

STORE={'STA','STX','STY','INC','DEC','ASL','LSR','ROL','ROR','SLO','RLA','SRE','RRA','SAX','DCP','ISC'}
READ={'LDA','LDX','LDY','CMP','CPX','CPY','ADC','SBC','AND','ORA','EOR','BIT','LAX','NOP'}

def regions():
    rom=Rom(ROM)
    out=[]
    # fixed
    d=Dis(fixed_region(rom),0xC000,'fixed'); d.inline_disp={0xC7F9,0xC81F}
    v=rom.vectors()
    ents=[v['nmi'],v['reset'],v['irq']]+[0xC000+3*i for i in range(48)]
    for i in range(48):
        b=d.data[3*i:3*i+3]
        if b[0]==0x4C: ents.append(b[1]|b[2]<<8)
    # state table
    o=0xC9C1-0xC000; n=0
    while True:
        t=d.data[o+n*2]|d.data[o+n*2+1]<<8
        if not (0xC000<=t<0xFFFF): break
        n+=1
    d.add_jumptable(0xC9C1,n)
    for e in ents:
        if d.inrange(e): d.entries.add(e); d.trace(e)
    out.append(('fixed',d))
    for even in (0,2,4,6,8,10,12):
        data=pair(rom,even)
        dd=Dis(data,0x8000,f'pair{even}')
        for e in head_entries(data):
            if 0x8000<=e<0xC000: dd.entries.add(e); dd.trace(e)
        out.append((f'pair{even}',dd))
    return out

def build(regs):
    xr=collections.defaultdict(list)
    for name,d in regs:
        for o in sorted(d.code):
            a=d.base+o
            ln,txt,mn,md,operand,tgt=decode(d.data,o,a)
            if operand is None or mn is None: continue
            if md in (ZP,ZPX,ZPY,IZX,IZY):
                addr=operand
            elif md in (ABS,ABX,ABY,IND):
                addr=operand
            else: continue
            kind='W' if mn in STORE else 'R'
            if mn in ('ASL','LSR','ROL','ROR','INC','DEC') : kind='RW'
            xr[addr].append((name,a,mn,md,kind))
    return xr

if __name__=='__main__':
    regs=regions()
    xr=build(regs)
    if len(sys.argv)>1:
        for spec in sys.argv[1:]:
            if '-' in spec:
                lo,hi=[int(x,16) for x in spec.split('-')]
            else:
                lo=hi=int(spec,16)
            for a in range(lo,hi+1):
                if a in xr:
                    e=xr[a]
                    w=[x for x in e if x[4]!='R']
                    print(f"${a:04X}: {len(e)} refs, {len(w)} writes")
                    for name,ad,mn,md,k in e:
                        print(f"    {name:8} ${ad:04X} {mn} {k}")
    else:
        import pickle
        pickle.dump({k:v for k,v in xr.items()}, open('/Users/hropl/pr/mypr/PB3/work/re/sol_xref.pkl','wb'))
        print("wrote pkl", len(xr))
