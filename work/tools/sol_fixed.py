import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6502 import Rom
from sol_dis import Dis, ROM, fixed_region

rom=Rom(ROM)
d=Dis(fixed_region(rom),0xC000,'fixed')
d.inline_disp={0xC7F9,0xC81F}
v=rom.vectors()
for e in (v['nmi'],v['reset'],v['irq']): d.entries.add(e); d.trace(e)
# game-state dispatch table after JSR $C7F9 at $C9BE
d.add_jumptable(0xC9C1, 0)   # placeholder, replaced below
del d.jumptabs[0xC9C1]
# determine table length heuristically: entries until an address outside C000-FFFF
data=d.data
o=0xC9C1-0xC000
n=0
while True:
    t=data[o+n*2]|data[o+n*2+1]<<8
    if not (0xC000<=t<0xFFFF): break
    n+=1
    if n>256: break
print(f"; state table $C9C1 length={n}", file=sys.stderr)
d.add_jumptable(0xC9C1,n)
for e in [int(x,16) for x in sys.argv[1:]]:
    d.entries.add(e); d.trace(e)
print(d.listing())
