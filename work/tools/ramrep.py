import sys,os,pickle
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from m6502 import decode, ABS,ABX,ABY,IND,ZP,ZPX,ZPY,IZX,IZY
import db
WRITE={'STA','STX','STY','INC','DEC','ASL','LSR','ROL','ROR','SAX','SLO','RLA','SRE','RRA','DCP','ISC'}
def collect():
    units=db.build()
    zpr={}; zpw={}; absr={}; absw={}
    for name,d in units.items():
        for o in sorted(d.starts):
            a=d.base+o
            ln,txt,mn,md,operand,tgt=decode(d.data,o,a)
            if operand is None or mn is None: continue
            w = mn in WRITE
            if md in (ZP,ZPX,ZPY,IZX,IZY):
                # (zp),Y and (zp,X) are pointer uses -> record as pointer
                (zpw if w else zpr).setdefault(operand,[]).append((name,a,txt))
            elif md in (ABS,ABX,ABY,IND):
                if operand<0x8000:
                    (absw if w else absr).setdefault(operand,[]).append((name,a,txt))
    return units,zpr,zpw,absr,absw
if __name__=='__main__':
    units,zpr,zpw,absr,absw=collect()
    print("=== ZERO PAGE ===")
    for v in range(0x100):
        r=len(zpr.get(v,())); w=len(zpw.get(v,()))
        if r or w: print(f"${v:02X}: r={r:<4} w={w:<4}")
    print("\n=== RAM $0100-$07FF (absolute refs) ===")
    for v in range(0x100,0x800):
        r=len(absr.get(v,())); w=len(absw.get(v,()))
        if r or w: print(f"${v:04X}: r={r:<4} w={w:<4}")
    print("\n=== other abs <$8000 ===")
    for v in sorted(set(absr)|set(absw)):
        if v>=0x800 and not (0x2000<=v<0x2008) and not (0x4000<=v<0x4020):
            print(f"${v:04X}: r={len(absr.get(v,()))} w={len(absw.get(v,()))}")
