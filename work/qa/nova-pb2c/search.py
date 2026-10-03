"""search.py PREFIX.json GOAL_ENTRY 'WAYPOINTS' ['{extra cfg}'] -> $TMPDIR/nova-pb2c/<name>.json (entry, steps, won).
PREFIX: {'entry','steps'} replay; GOAL_ENTRY: room index to reach (or -1 with only_clear for boss)."""
import json,sys,pathlib,subprocess,time,os
HERE=pathlib.Path(__file__).resolve().parent
S=pathlib.Path(os.environ.get('TMPDIR','/tmp'))/'nova-pb2c';S.mkdir(exist_ok=True)
pre,goal,wps=sys.argv[1],int(sys.argv[2]),json.loads(sys.argv[3])
extra=json.loads(sys.argv[4]) if len(sys.argv)>4 else {}
d=json.load(open(pre))
t0=sum(s[0] for s in d['steps'])
cfg={"entry":d['entry'],"prefix":d['steps'],"goal_entry":goal,"skip_changes":max(0,goal-d['entry']-1) if goal>=0 else 0,
"waypoints":wps,"weights":{"net":0.0},"extra_pads":[136,137,138,8,9,10,129,130,4,132],"extra_rate":0.15,"min_gain":5,"slack":200,
"length":240,"rollouts":4,"workers":2,"commit":0.5,"max_ticks":t0+extra.pop('budget',4000),
"y_weight":1.0,"life_weight":60,"energy_weight":0,"seed":int(time.time())%100000,"max_fails":12}
cfg.update(extra)
name=extra.get('name','s%d'%goal);cfg['name']=name;cfg['out']=str(S/f'{name}.json')
if not extra.get('resume'): (S/f'{name}.json').unlink(missing_ok=True)
(S/f'{name}.cfg').write_text(json.dumps(cfg))
p=subprocess.Popen(['python3','-u',str(HERE/'search/orch.py'),str(S/f'{name}.cfg')],stdout=subprocess.PIPE,text=True)
for line in p.stdout: print(line.rstrip(),flush=True)
p.wait()
