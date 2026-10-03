"""promote.py CAND CHAIN : copy candidate into chain folder, set checkpoints at every 'changed' event tick-1 (+ final live tick)."""
import json,sys,shutil,pathlib
F=pathlib.Path(__file__).resolve().parents[3]/'docs/qa/playthrough'
cand,chain=sys.argv[1],sys.argv[2]
(F/chain).mkdir(exist_ok=True)
if cand!=chain:
 for x in ['replay.json','state.json','current.png','trace.json']:
  if (F/cand/x).exists(): shutil.copy(F/cand/x,F/chain/x)
d=json.load(open(F/chain/'replay.json'))
cps=[{'tick':e['tick']-1,'all_alive':True} for e in d['events'] if e['event']=='changed']
cases=json.load(open(F/'cases.json'))
key=chain+'/replay.json'
for c in cases:
    if c['file']==key: c['checkpoints']=cps;break
else: cases.append({'file':key,'checkpoints':cps})
json.dump(cases,open(F/'cases.json','w'),indent=2,ensure_ascii=False)
print(cps)
