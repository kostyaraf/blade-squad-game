"""Free space inside the original 128K PRG: runs of one repeated byte."""
import sys
MIN=32
def banks(p):
    d=open(p,'rb').read(); prg=d[16:16+d[4]*16384]
    return [prg[i*8192:(i+1)*8192] for i in range(len(prg)//8192)]
def addr(bank,off):
    return (0x8000 if bank%2==0 else 0xA000)+off if bank<14 else (0xC000 if bank==14 else 0xE000)+off
for tag,p in [("Power Blade 2",'Power Blade 2 (USA).nes'),
              ("Solbrain",'Tokkyuu Shirei Solbrain (Japan).nes')]:
    bs=banks(p); tot=0; tail=0
    print(f"=== {tag} — repeated-byte runs >= {MIN} bytes ===")
    for i,b in enumerate(bs):
        rs=[];j=0
        while j<len(b):
            k=j
            while k+1<len(b) and b[k+1]==b[j]: k+=1
            if k-j+1>=MIN: rs.append((j,k-j+1,b[j]))
            j=k+1
        n=sum(r[1] for r in rs); tot+=n
        f=b[-1]; t=0
        while t<len(b) and b[len(b)-1-t]==f: t+=1
        if i==15: t=max(0,t-6)
        tail+=t if t>=8 else 0
        s=" ".join(f"${addr(i,o):04X}+{ln}(0x{v:02X})" for o,ln,v in rs)
        print(f" bank {i:2}: {n:5} bytes in {len(rs)} runs   {s}")
    print(f" TOTAL filler >= {MIN}B: {tot} bytes ({tot/1024:.1f} KB);"
          f" of it at bank tails: {tail} bytes")
    print()
