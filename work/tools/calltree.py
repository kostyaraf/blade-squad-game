import sys,re
f=sys.argv[1]
maxdepth=int(sys.argv[2]) if len(sys.argv)>2 else 6
depth=0
out=[]
prev=None
lines=open(f).read().splitlines()
seen={}
for ln in lines:
    if not ln.startswith('F'): continue
    m=re.match(r'F(\d+) (\d+):([0-9A-F]{4}) ([0-9A-F ]{8}) (\S+)(.*)',ln)
    if not m: continue
    fr,bk,pc,raw,mn,rest=m.groups()
    if mn=='JSR':
        tgt=rest.strip().split()[0]
        if depth<=maxdepth:
            out.append(('  '*depth)+f"{bk:>2}:{pc} JSR {tgt}")
        depth+=1
    elif mn in ('RTS','RTI'):
        depth=max(0,depth-1)
print('\n'.join(out))
