"""trunc.py CHAIN TICK [EXTRA_STEPS_JSON] : cut chain replay to TICK ticks (events kept if <=TICK), optionally append steps; no stand run (verify later)."""
import json,sys,pathlib
F=pathlib.Path(__file__).resolve().parents[3]/'docs/qa/playthrough'
d=json.load(open(F/sys.argv[1]/'replay.json'));n=int(sys.argv[2]);out=[];t=0
for s in d['steps']:
    k=min(s[0],n-t)
    if k<=0:break
    out.append([k]+s[1:]);t+=k
if len(sys.argv)>3: out+=json.loads(sys.argv[3])
d['steps']=out;d['events']=[e for e in d['events'] if e['tick']<=n]
json.dump(d,open(F/sys.argv[1]/'replay.json','w'));print(sum(s[0] for s in out))
