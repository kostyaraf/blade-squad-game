"""at.py NAME TICK : replay first TICK ticks of docs/qa/playthrough/NAME/replay.json on the stand (current.png shows result)."""
import json,sys,pathlib
sys.path.insert(0,str(pathlib.Path(__file__).parent))
import qa
d=json.load(open(qa.F/sys.argv[1]/'replay.json'));n=int(sys.argv[2]);out=[];t=0
for s in d['steps']:
    k=min(s[0],n-t)
    if k<=0:break
    out.append([k]+s[1:]);t+=k
print(qa.short(qa.command(out,d['entry'],timeout=300)))
