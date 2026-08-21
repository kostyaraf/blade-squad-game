"""Conservative free-RAM estimate.

An address counts FREE only if
  (a) it is never read and never written in ANY emulator run (gameplay window
      only, so the power-on RAM wipe does not mask everything), AND
  (b) it is never the operand of a direct (non-indexed) store in code the
      emulator actually executed, AND
  (c) it is not the low or high byte of a zero-page pointer used indirectly.
Indexed stores are reported separately: an untouched byte that lies inside a
known object array is free only in the sense "this field of this slot was idle".
"""
import sys
sys.path.insert(0,'/Users/hropl/pr/mypr/PB3/work/tools')
import e0_ramstatic as S

def touched(paths):
    t=bytearray(0x800); w=bytearray(0x2000)
    for p in paths:
        d=open(p,'rb').read()
        for i in range(0x800):
            if d[i] or d[0x800+i]: t[i]=1
        for i in range(0x2000):
            if d[0x1000+i] or d[0x3000+i]: w[i]=1
    return t,w

def runs(free,lo,hi):
    out=[];i=lo
    while i<hi:
        if free[i]:
            s=i
            while i<hi and free[i]: i+=1
            out.append((s,i-1))
        else: i+=1
    return out

CASES=[("Power Blade 2",'/Users/hropl/pr/mypr/PB3/Power Blade 2 (USA).nes',
        ['work/tmp/e0/pb2.cov','work/tmp/e0/pb22.cov','work/tmp/e0/pb2k.cov'],
        ['work/tmp/e0/pb2k.ramuse','work/tmp/e0/pb2h.ramuse','work/tmp/e0/pb2g.ramuse'],
        (0x0400,0x0600,"22-slot object table $0400+22*field")),
       ("Solbrain",'/Users/hropl/pr/mypr/PB3/Tokkyuu Shirei Solbrain (Japan).nes',
        ['work/tmp/e0/sol.cov','work/tmp/e0/sol2.cov'],
        ['work/tmp/e0/solh.ramuse','work/tmp/e0/solg.ramuse'],
        (0x0600,0x0780,"16-slot main pool $0600.. + 8-slot shot pool $0700.."))]

for tag,rom,covs,uses,(plo,phi,pname) in CASES:
    d,ix,ip,n=S.scan(rom,covs)
    t,w=touched(uses)
    hit=set(d)
    for a in ip: hit.add(a); hit.add((a+1)&0xFF)
    free=[0 if (t[a] or a in hit) else 1 for a in range(0x800)]
    zp=sum(free[0:0x100]); pg2=sum(free[0x200:0x300]); rest=sum(free[0x300:0x800])
    inpool=sum(free[plo:phi]); outpool=rest-inpool
    print(f"### {tag}")
    print(f" zero page   $0000-$00FF free {zp}/256")
    print("   runs:", ", ".join(f"${a:02X}-${b:02X}({b-a+1})" if b>a else f"${a:02X}"
          for a,b in runs(free,0,0x100)) or "none")
    print(f" OAM shadow  $0200-$02FF free {pg2}/256")
    print(f" $0300-$07FF free {rest}/1280   of which {inpool} inside {pname}"
          f" (idle slots, NOT reusable) and {outpool} outside it")
    print("   runs outside the pool, >=8 bytes:", ", ".join(
        f"${a:04X}-${b:04X}({b-a+1})" for a,b in runs(free,0x300,0x800)
        if b-a+1>=8 and not (plo<=a<phi)) or "none")
    print(f" REUSABLE TOTAL (zp + $0200-$07FF outside pool): {zp+pg2+outpool} bytes")
    print(f" WRAM $6000-$7FFF: {sum(w)} bytes accessed -> "
          f"{'present' if sum(w) else 'no PRG-RAM in header, 0 accesses in any run'}")
    print()
