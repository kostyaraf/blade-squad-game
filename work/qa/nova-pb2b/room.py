"""room.py CHAIN ENTRY 'WAYPOINTS_JSON' [extra cfg json] : search one room starting from the chain's end,
then replay on live stand into folder CHAIN-cand. Entry = current room index (goal = ENTRY+1)."""
import json,sys,pathlib,subprocess,time
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[2];F=ROOT/'docs/qa/playthrough'
S=pathlib.Path('/private/tmp/claude-501/nova2b');S.mkdir(exist_ok=True)
chain,at,wps=sys.argv[1],int(sys.argv[2]),json.loads(sys.argv[3])
extra=json.loads(sys.argv[4]) if len(sys.argv)>4 else {}
d=json.load(open(F/chain/'replay.json'))
cfg={"entry":d['entry'],"prefix":d['steps'],"goal_entry":at+1,"skip_changes":len([e for e in d['events'] if e['event']=='changed']),
"waypoints":wps,"weights":{"net":0.3},"extra_pads":[136,137,138,8,9,10,129,130],"extra_rate":0.2,"min_gain":5,"slack":200,
"length":240,"rollouts":4,"workers":1,"commit":0.5,"max_ticks":d_t if (d_t:=sum(s[0] for s in d['steps'])+extra.pop('budget',4000)) else 0,
"y_weight":1.0,"life_weight":60,"energy_weight":20,"seed":int(time.time())%100000,"max_fails":12}
cfg.update(extra)
name=f'{chain}-r{at}';cfg['name']=name;cfg['out']=str(S/f'{name}.json')
(S/f'{name}.json').unlink(missing_ok=True)
(S/f'{name}.cfg').write_text(json.dumps(cfg))
r=subprocess.run(['python3',str(HERE/'search/orch.py'),str(S/f'{name}.cfg')],capture_output=True,text=True)
print('\n'.join(r.stdout.strip().split('\n')[-4:]))
if 'WON' not in r.stdout: print('NO WIN');sys.exit(1)
subprocess.run(['python3',str(HERE/'accept.py'),str(S/f'{name}.json'),chain+'-cand'])
