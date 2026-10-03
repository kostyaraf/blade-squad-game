"""probe.py PREFIX_REPLAY 'PATTERNS_JSON' : run trial.gd, print compact results per pattern."""
import json,sys,subprocess,pathlib,os
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
S=pathlib.Path(os.environ.get('TMPDIR','/tmp'))/'nova-pb2c';S.mkdir(exist_ok=True)
pre=sys.argv[1]
if not pre.startswith('/'): pre=str(ROOT/'docs/qa/playthrough'/pre/'replay.json')
pats=json.loads(sys.argv[2])
cfg={'prefix':pre,'patterns':pats,'output':str(S/'probe_out.json')}
(S/'probe_cfg.json').write_text(json.dumps(cfg))
r=subprocess.run(['/Applications/Godot_mono.app/Contents/MacOS/Godot','--headless','--path',str(ROOT/'game'),'--script','../work/qa/nova-pb2c/trial.gd','--',str(S/'probe_cfg.json')],capture_output=True,text=True,timeout=900)
if 'SCRIPT ERROR' in r.stderr+r.stdout: print((r.stderr+r.stdout)[-1500:])
for i,x in enumerate(json.load(open(S/'probe_out.json'))):
  full='--full' in sys.argv
  print(i,{k:x.get(k) for k in (['tick','entry','alive','pos','screen','view','hp','suit','energy','state','events'] + (['enemies'] if full else []))})
