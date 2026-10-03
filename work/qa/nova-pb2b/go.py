"""go.py CHAIN CODE AT 'WPS' [extra]: search room, accept, promote, update report row, commit."""
import sys,json,subprocess,re,pathlib
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
chain,code,at,wps=sys.argv[1:5];extra=sys.argv[5:6]
r=subprocess.run(['python3',str(HERE/'room.py'),chain,at,wps]+extra,capture_output=True,text=True)
print(r.stdout[-700:])
if r.returncode: sys.exit(1)
F=ROOT/'docs/qa/playthrough'
st=json.load(open(F/(chain+'-cand')/'state.json'))
ev=json.load(open(F/(chain+'-cand')/'replay.json'))['events']
tick=[e for e in ev if e['event']=='changed'][-1]['tick'] if ev else 0
if 'message' in ev[-1] and ev[-1]['event']!='changed': tick=ev[-1]['tick']
subprocess.run(['python3',str(HERE/'promote.py'),chain+'-cand',chain],check=True)
rep=ROOT/'docs/qa/reverse-2026-10-03/nova-pb2b.md';t=rep.read_text()
life=st['players'][0]['life'] if st['players'] else '-'
row=f"| {code} | ☑ | [цепочка {chain}](../playthrough/{chain}/replay.json) | {tick} | обычный ввод, враги и урон; поиск маршрута перебором нажатий; HP на входе следующей {life} |"
t2=re.sub(r'^\| %s \|.*$'%re.escape(code),row,t,flags=re.M);rep.write_text(t2)
subprocess.run(['git','add',str(F/chain),'docs/qa/playthrough/cases.json',str(rep)],cwd=ROOT,check=True)
subprocess.run(['git','commit','-q','-m',f'QA Nova PB2: {code} пройдена в цепочке {chain}'],cwd=ROOT,check=True)
print('committed',code,tick)
