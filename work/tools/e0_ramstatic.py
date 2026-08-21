"""Static scan: which RAM addresses are store targets in code the game actually
executes.  Instruction boundaries are taken from nesemu -cov executed-byte runs."""
import sys
sys.path.insert(0,'/Users/hropl/pr/mypr/PB3/work/tools')
from m6502 import T, MODELEN, ZP,ZPX,ZPY,ABS,ABX,ABY,IZX,IZY,IMM,IMP,ACC,REL,IND
WRITERS={'STA','STX','STY','INC','DEC','ASL','LSR','ROL','ROR',
         'SLO','RLA','SRE','RRA','SAX','DCP','ISC'}
def load_cov(paths,n=131072):
    m=bytearray(n//8)
    for p in paths:
        b=open(p,'rb').read()
        for i in range(min(len(b),n//8)): m[i]|=b[i]
    return m
def ex(m,i): return (m[i>>3]>>(i&7))&1
def scan(rom_path, cov_paths):
    raw=open(rom_path,'rb').read()
    prg=raw[16:16+raw[4]*16384]
    m=load_cov(cov_paths,len(prg))
    direct=set(); indexed=set(); ind_ptr=set()
    i=0; ninst=0
    while i<len(prg):
        if not ex(m,i): i+=1; continue
        s=i
        while i<len(prg) and ex(m,i): i+=1
        j=s
        while j<i:
            op=prg[j]; e=T[op]
            if e is None: j+=1; continue
            mn,md=e; L=MODELEN[md]
            if j+L>i: break
            if mn in WRITERS:
                if md in (ZP,ZPX,ZPY):
                    a=prg[j+1]
                    (direct if md==ZP else indexed).add(a)
                elif md in (ABS,ABX,ABY):
                    a=prg[j+1]|(prg[j+2]<<8)
                    if a<0x0800 or 0x6000<=a<0x8000:
                        (direct if md==ABS else indexed).add(a)
                elif md in (IZX,IZY):
                    ind_ptr.add(prg[j+1])
            ninst+=1; j+=L
    return direct,indexed,ind_ptr,ninst
for tag,rom,covs in [("Power Blade 2",'/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes',
                      ['work/tmp/e0/pb2.cov','work/tmp/e0/pb22.cov','work/tmp/e0/pb2k.cov']),
                     ("Solbrain",'/Users/hropl/pr/mypr/PB3/Tokkyuu Shirei Solbrain (Japan).nes',
                      ['work/tmp/e0/sol.cov','work/tmp/e0/sol2.cov'])]:
    d,ix,ip,n=scan(rom,covs)
    zp_d={a for a in d if a<0x100}; zp_i={a for a in ix if a<0x100}
    hi_d={a for a in d if 0x200<=a<0x800}; hi_i={a for a in ix if 0x200<=a<0x800}
    wr={a for a in d|ix if 0x6000<=a<0x8000}
    print(f"=== {tag} ({n} decoded instructions in executed regions) ===")
    print(f" zero page store targets: {len(zp_d)} direct + {len(zp_i)} indexed-base"
          f" = {len(zp_d|zp_i)} distinct")
    free=[a for a in range(0x100) if a not in zp_d and a not in zp_i and a not in ip]
    print(f" zero page never a store target and never an indirect pointer: {len(free)}")
    print("  ", " ".join(f"${a:02X}" for a in free))
    print(f" $0200-$07FF store targets: {len(hi_d)} direct + {len(hi_i)} indexed bases")
    print(f" $6000-$7FFF store targets: {len(wr)}  {sorted(hex(a) for a in wr)}")
    print()
