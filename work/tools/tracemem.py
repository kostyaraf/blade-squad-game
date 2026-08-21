"""Analyze a nesemu trace: find all RAM reads/writes performed inside a call
to a given entry PC (bank:addr), following the stack."""
import sys,re
from collections import defaultdict

LINE=re.compile(r'^F(\d+) (\d+):([0-9A-F]{4}) ((?:[0-9A-F]{2} ?)+)\s*(\S+)\s*(.*?)\s+A=([0-9A-F]{2}) X=([0-9A-F]{2}) Y=([0-9A-F]{2}) P=([0-9A-F]{2}) SP=([0-9A-F]{2})$')
W={'STA','STX','STY','INC','DEC','ASL','LSR','ROL','ROR','SAX','SLO','RLA','SRE','RRA','DCP','ISC'}
R={'LDA','LDX','LDY','CMP','CPX','CPY','ADC','SBC','AND','ORA','EOR','BIT','LAX','INC','DEC','ASL','LSR','ROL','ROR','SLO','RLA','SRE','RRA','DCP','ISC'}

def parse(path):
    for ln in open(path):
        m=LINE.match(ln.rstrip())
        if m: yield m.groups()

def ea(op, a,x,y, ram):
    """op is the operand text; returns effective address or None"""
    op=op.strip()
    m=re.match(r'^\$([0-9A-F]{4})$',op)
    if m: return int(m.group(1),16)
    m=re.match(r'^\$([0-9A-F]{4}),X$',op)
    if m: return (int(m.group(1),16)+x)&0xFFFF
    m=re.match(r'^\$([0-9A-F]{4}),Y$',op)
    if m: return (int(m.group(1),16)+y)&0xFFFF
    m=re.match(r'^\$([0-9A-F]{2})$',op)
    if m: return int(m.group(1),16)
    m=re.match(r'^\$([0-9A-F]{2}),X$',op)
    if m: return (int(m.group(1),16)+x)&0xFF
    m=re.match(r'^\$([0-9A-F]{2}),Y$',op)
    if m: return (int(m.group(1),16)+y)&0xFF
    m=re.match(r'^\(\$([0-9A-F]{2}),X\)$',op)
    if m:
        z=(int(m.group(1),16)+x)&0xFF
        return ram.get(z,0)|ram.get((z+1)&0xFF,0)<<8
    m=re.match(r'^\(\$([0-9A-F]{2})\),Y$',op)
    if m:
        z=int(m.group(1),16)
        return ((ram.get(z,0)|ram.get((z+1)&0xFF,0)<<8)+y)&0xFFFF
    return None

def run(path, entries, ramfile=None):
    ram={}
    if ramfile:
        b=open(ramfile,'rb').read()
        for i in range(0x800): ram[i]=b[i]
    inside=False; entry_sp=None
    writes=defaultdict(set); reads=defaultdict(set)
    calls=set()
    cnt=0
    for fr,bk,pc,raw,mn,opnd,A,X,Y,P,SP in parse(path):
        a=int(A,16); x=int(X,16); y=int(Y,16); sp=int(SP,16)
        key=f"{int(bk)}:{pc}"
        if not inside:
            if key in entries or pc in entries:
                inside=True; entry_sp=sp; cnt+=1
            else: continue
        e=ea(opnd,a,x,y,ram)
        if e is not None and e<0x800:
            if mn in W: writes[e].add((bk,pc,mn))
            if mn in R: reads[e].add((bk,pc,mn))
        if mn in ('STA','STX','STY') and e is not None and e<0x800:
            ram[e]= a if mn=='STA' else (x if mn=='STX' else y)
        if mn in ('RTS','RTI') and sp>=entry_sp:
            inside=False
    return writes,reads,cnt

if __name__=='__main__':
    path=sys.argv[1]; ents=set(sys.argv[2].split(','))
    ramf=sys.argv[3] if len(sys.argv)>3 else None
    w,r,c=run(path,ents,ramf)
    print(f"# {c} invocations")
    print("== WRITES ==")
    for e in sorted(w):
        srcs=sorted(w[e])[:6]
        print(f"${e:04X}  "+', '.join(f"b{b}:{p} {m}" for b,p,m in srcs))
    print("== READS (not written) ==")
    for e in sorted(r):
        if e in w: continue
        srcs=sorted(r[e])[:6]
        print(f"${e:04X}  "+', '.join(f"b{b}:{p} {m}" for b,p,m in srcs))
