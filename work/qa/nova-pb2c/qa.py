import json, pathlib, time, argparse, shutil
ROOT=pathlib.Path(__file__).resolve().parents[3]
F=ROOT/'docs/qa/playthrough'
def command(steps=[], start=None, heroes=[0], timeout=60):
 old=json.loads((F/'state.json').read_text()) if (F/'state.json').exists() else {}
 cid=max(int(old.get('id',0))+1,int(time.time()*1000))
 d={'id':cid,'fast':True,'steps':steps}
 if start is not None: d.update(start=start,heroes=heroes)
 tmp=F/'command.tmp';tmp.write_text(json.dumps(d));tmp.replace(F/'command.json')
 end=time.time()+timeout
 while time.time()<end:
  if (F/'state.json').exists():
   try: st=json.loads((F/'state.json').read_text())
   except Exception: time.sleep(.05); continue
   if st.get('id')==cid:return st
  time.sleep(.05)
 raise TimeoutError(cid)
def save(name):
 p=F/name;p.mkdir(exist_ok=True)
 for x in ['replay.json','state.json','current.png','trace.json']:
  if (F/x).exists():shutil.copy(F/x,p/x)
def short(st):
 p=[(h['x'],h['y'],h.get('life'),h.get('state'),h.get('suit'),h.get('energy')) for h in st['players']]
 return f"t={st['tick']} e={st['entry']} msg={st['message']!r} ended={st.get('ended')} view={st.get('view')} P={p} en={[(e.get('id',e.get('type')),e['x'],e['y'],e['life']) for e in st['enemies']][:8]}"
if __name__=='__main__':
 a=argparse.ArgumentParser();a.add_argument('--start',type=int);a.add_argument('--steps',default='[]');a.add_argument('--save');a.add_argument('--replay');a.add_argument('--full',action='store_true');o=a.parse_args()
 steps=json.loads(o.steps)
 if o.replay:
  d=json.loads((F/o.replay/'replay.json').read_text());o.start=d['entry'];steps=d['steps']+steps
 st=command(steps,o.start);print(json.dumps(st) if o.full else short(st))
 if o.save:save(o.save)
