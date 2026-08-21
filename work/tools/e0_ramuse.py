"""Report free/used RAM from an -ramuse dump written by e0_ramemu."""
import sys
def load(p):
    d=open(p,'rb').read()
    return dict(w=d[0:0x800], r=d[0x800:0x1000],
                ww=d[0x1000:0x3000], wr=d[0x3000:0x5000], stk=d[0x5000:0x5100])
def runs(mask, lo, hi, want=0):
    out=[];i=lo
    while i<hi:
        if mask[i]==want:
            s=i
            while i<hi and mask[i]==want: i+=1
            out.append((s,i-1))
        else: i+=1
    return out
def rep(tag,p):
    d=load(p)
    touched=[1 if (d['w'][i] or d['r'][i]) else 0 for i in range(0x800)]
    print(f"=== {tag} ===")
    for name,lo,hi in [("zero page $0000-$00FF",0,0x100),
                       ("stack   $0100-$01FF",0x100,0x200),
                       ("$0200-$02FF (OAM buf)",0x200,0x300),
                       ("$0300-$07FF",0x300,0x800),
                       ("ALL $0000-$07FF",0,0x800)]:
        w=sum(d['w'][lo:hi]); r=sum(d['r'][lo:hi]); t=sum(touched[lo:hi])
        print(f" {name}: written {w}, read {r}, touched {t}, FREE {hi-lo-t}")
    print(" free runs in $0000-$00FF:", [f"${a:02X}-${b:02X}({b-a+1})" for a,b in runs(touched,0,0x100) if b-a+1>=2])
    fz=[f"${a:02X}" for a,b in runs(touched,0,0x100) for _ in [0] if b==a]
    print("  singles:", ",".join(fz) if fz else "none")
    big=[(a,b) for a,b in runs(touched,0x200,0x800) if b-a+1>=8]
    print(f" free runs >=8 bytes in $0200-$07FF: {len(big)}, total {sum(b-a+1 for a,b in big)} bytes")
    for a,b in big[:40]: print(f"   ${a:04X}-${b:04X}  {b-a+1}")
    ww=sum(d['ww']); wr=sum(d['wr'])
    print(f" WRAM $6000-$7FFF: writes {ww}, reads {wr}  -> {'USED' if ww or wr else 'NOT USED AT ALL'}")
    print(f" stack depth used: {sum(d['stk'])} of 256 bytes; lowest SP page byte touched ${min([i for i in range(256) if d['stk'][i]],default=-1):02X}")
    print()
for a in range(1,len(sys.argv),2): rep(sys.argv[a+1],sys.argv[a])
