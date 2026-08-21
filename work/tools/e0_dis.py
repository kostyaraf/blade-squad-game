import sys
sys.path.insert(0,'/Users/hropl/pr/mypr/PB3/work/tools')
from m6502 import decode
def load(p):
    d=open(p,'rb').read(); return d[16:16+d[4]*16384]
prg=load(sys.argv[1]); bank=int(sys.argv[2]); a=int(sys.argv[3],16); n=int(sys.argv[4])
base=0xC000 if bank==14 else (0xE000 if bank==15 else (0x8000 if bank%2==0 else 0xA000))
off=bank*8192+(a-base)
addr=a
while addr < a+n:
    r=decode(prg,off,addr)
    print(f"{addr:04X}  {prg[off:off+r[0]].hex(' '):<9} {r[1]}")
    off+=r[0]; addr+=r[0]
