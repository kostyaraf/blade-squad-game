"""Per-PRG-bank census: executed bytes (code), read-only bytes (data), untouched."""
import sys
N=131072
def bits(p):
    b=open(p,'rb').read()
    m=bytearray(N//8)
    for i in range(min(len(b),N//8)): m[i]=b[i]
    return m
def get(m,i): return (m[i>>3]>>(i&7))&1
def census(cov,rd,label):
    c=bits(cov); r=bits(rd)
    print(f"=== {label} ===")
    print(f"{'bank':>4} {'exec':>7} {'read-only':>10} {'untouched':>10}  {'exec%':>6} {'ro%':>6}")
    tc=tr=tu=0
    for b in range(16):
        e=ro=un=0
        for i in range(b*8192,(b+1)*8192):
            x=get(c,i); y=get(r,i)
            if x: e+=1
            elif y: ro+=1
            else: un+=1
        tc+=e; tr+=ro; tu+=un
        print(f"{b:4} {e:7} {ro:10} {un:10}  {e/8192*100:5.1f}% {ro/8192*100:5.1f}%")
    print(f" tot {tc:7} {tr:10} {tu:10}  {tc/N*100:5.1f}% {tr/N*100:5.1f}%")
    print()
census(sys.argv[1],sys.argv[2],sys.argv[3])
