import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from m6502 import decode
raw=open("Tokkyuu Shirei Solbrain (Japan).nes",'rb').read()
PRG=raw[16:16+128*1024]
def base_of(b): return 0xC000 if b==14 else (0xE000 if b==15 else (0x8000 if b%2==0 else 0xA000))
b=int(sys.argv[1]); start=int(sys.argv[2],16); n=int(sys.argv[3]) if len(sys.argv)>3 else 40
data=PRG[b*0x2000:(b+1)*0x2000]; base=base_of(b)
o=start-base
for i in range(n):
    d=decode(data,o,base+o)
    ln=d[0] or 1
    print(f"{b}:{base+o:04X}  "+' '.join(f"{x:02X}" for x in data[o:o+ln]).ljust(9)+f" {d[1]}")
    o+=ln
