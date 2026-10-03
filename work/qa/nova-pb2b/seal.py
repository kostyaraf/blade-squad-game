"""seal.py CAND CHAIN CODE NOTE: save accepted replay/report, commit explicit paths."""
import json,pathlib,sys,shutil,re,subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3];F=ROOT/'docs/qa/playthrough'
cand,chain,code,note=sys.argv[1:5]
d=json.loads((F/cand/'replay.json').read_text());st=json.loads((F/cand/'state.json').read_text())
assert st.get('message','')!='TEAM DOWN - CHOOSE A LEVEL TO RETRY'
assert d['events'], 'no normal exit'
(F/chain).mkdir(exist_ok=True)
for name in ['replay.json','state.json','current.png']:
 if cand!=chain:shutil.copy(F/cand/name,F/chain/name)
key=chain+'/replay.json';cases=json.loads((F/'cases.json').read_text())
points=[{'tick':e['tick']-1,'all_alive':True} for e in d['events'] if e['event']=='changed' or e.get('message','').startswith('STAGE CLEAR')]
if st.get('players'):points.append({'tick':st['tick'],'all_alive':True})
cases=[c for c in cases if c['file']!=key]+[{'file':key,'checkpoints':points}]
(F/'cases.json').write_text(json.dumps(cases,ensure_ascii=False,indent=2)+'\n')
r=ROOT/'docs/qa/reverse-2026-10-03/nova-pb2b.md';s=r.read_text()
areas=[7,8,7,7,10,14,10]; codes=[f'p{stage}.{a}' for stage,n in enumerate(areas) for a in range(n)]
prev=int(d['entry']);ticks={}
for ev in d['events']:
 if ev['event']=='changed' and int(ev['entry'])!=prev:
  ticks[codes[prev]]=ev['tick'];prev=int(ev['entry'])
 elif ev.get('message','').startswith('STAGE CLEAR'):ticks[codes[prev]]=ev['tick']
assert code in ticks,(code,ticks)
for c,t in ticks.items():
 row=f'| {c} | ☑ | [{chain}](../playthrough/{key}) | {t} | обычный ввод; враги и урон; {note if c==code else "повтор цепочки"} |'
 s=re.sub(r'^\| '+re.escape(c)+r' \|.*$',row,s,flags=re.M)
s+=f'\n### Передача после {code} (продолжение 3)\n\n{note}. Запись `{chain}`, штатный выход {ticks[code]}.\nПоследнее состояние: тик {st["tick"]}, вход {st["entry"]}, '+str(st.get('players',[]))+'.\nПринято повтором playthrough.gd с начала записи; SCRIPT ERROR в стенде отсутствует.\n'
r.write_text(s)
files=[str(F/chain/n) for n in ['replay.json','state.json','current.png']]+[str(F/'cases.json'),str(r)]
subprocess.run(['git','add']+files,cwd=ROOT,check=True)
subprocess.run(['git','commit','-m',f'QA Nova PB2: {code} — запись и передача'],cwd=ROOT,check=True)
