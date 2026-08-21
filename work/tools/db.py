"""Global code map + xref database for PB2."""
import sys,os,json,pickle
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom, decode, ABS,ABX,ABY,IND,ZP,ZPX,ZPY,IZX,IZY,REL
import pairdis
ROM=pairdis.ROM
UNITS=[('p0',0),('p2',2),('p4',4),('p6',6),('p8',8),('p10',10),('p12',12),('C000','C000'),('E000','E000')]
CACHE=os.path.join(os.path.dirname(os.path.abspath(__file__)),'db.pkl')
EXTRA=os.path.join(os.path.dirname(os.path.abspath(__file__)),'entries.json')

def build(force=False):
    if os.path.exists(CACHE) and not force:
        return pickle.load(open(CACHE,'rb'))
    extra=json.load(open(EXTRA)) if os.path.exists(EXTRA) else {}
    units={}
    for name,p in UNITS:
        ex=[int(x,16) for x in extra.get(name,{}).get('entries',[])]
        dat=extra.get(name,{}).get('data',[])
        d=pairdis.build(p,extra=ex,data=dat)
        d.unit=name; d.pair=p
        units[name]=d
    pickle.dump(units,open(CACHE,'wb'))
    return units

def refs(units, addr, zp=None):
    """all instructions referencing absolute addr (or zp byte)"""
    out=[]
    for name,d in units.items():
        for o in sorted(d.starts):
            a=d.base+o
            ln,txt,mn,md,operand,tgt=decode(d.data,o,a)
            if operand is None: continue
            if md in (ABS,ABX,ABY,IND) and operand==addr: out.append((name,a,txt))
            elif md in (ZP,ZPX,ZPY,IZX,IZY) and zp is not None and operand==zp: out.append((name,a,txt))
    return out

def bankof(unit,addr):
    if unit=='C000': return 14
    if unit=='E000': return 15
    p=int(unit[1:])
    return p if addr<0xA000 else p+1

if __name__=='__main__':
    units=build('-f' in sys.argv)
    args=[a for a in sys.argv[1:] if a!='-f']
    tot=0
    for name,d in units.items():
        c=len(d.code)/d.size*100; tot+=len(d.code)
        print(f"{name:6} coverage {c:5.1f}%  subs={len(d.subs)}",file=sys.stderr)
    for a in args:
        v=int(a,16)
        if v<0x100:
            r=refs(units,None,zp=v)
            print(f"=== ZP ${v:02X}  ({len(r)} refs)")
        else:
            r=refs(units,v)
            print(f"=== ${v:04X}  ({len(r)} refs)")
        for name,ad,txt in r:
            print(f"  {name:5} b{bankof(name,ad):02d} ${ad:04X}  {txt}")
