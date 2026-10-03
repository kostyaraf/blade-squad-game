"""probe.py PREFIX 'PATTERNS_JSON' [--cut=T] [--full]: headless trial.gd, compact result per pattern.
PREFIX: playthrough name or path. --cut keeps only the first T ticks of the prefix."""
import json,sys,subprocess,pathlib,os
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2]
S=pathlib.Path(os.environ.get('TMPDIR','/tmp'))/'nova-pb2b';S.mkdir(exist_ok=True)
def load(pre):
  p=pathlib.Path(pre) if pre.startswith('/') else ROOT/'docs/qa/playthrough'/pre/'replay.json'
  return json.loads(p.read_text())
def cut(steps,n):
  out=[]
  for s in steps:
    k=min(int(s[0]),n)
    if k<=0: break
    out.append([k,s[1]]);n-=k
  return out
def tail(steps,n):
  out=[];t=0
  for s in steps:
    a,b=t,t+int(s[0]);t=b
    if b<=n: continue
    out.append([b-max(a,n),s[1]])
  return out
if __name__=='__main__':
  args=[a for a in sys.argv[1:] if not a.startswith('--')];opts=dict(a[2:].split('=',1) if '=' in a else (a[2:],'1') for a in sys.argv[1:] if a.startswith('--'))
  d=load(args[0])
  if 'cut' in opts: d['steps']=cut(d['steps'],int(opts['cut']))
  tag=opts.get('tag','probe')
  (S/(tag+'_pre.json')).write_text(json.dumps(d))
  pats=json.loads(args[1])
  cfg={'prefix':str(S/(tag+'_pre.json')),'patterns':pats,'output':str(S/(tag+'_out.json'))}
  (S/(tag+'_cfg.json')).write_text(json.dumps(cfg))
  r=subprocess.run(['/Applications/Godot_mono.app/Contents/MacOS/Godot','--headless','--path',str(ROOT/'game'),'--script','../work/qa/nova-pb2b/trial.gd','--',str(S/(tag+'_cfg.json'))],capture_output=True,text=True,timeout=int(opts.get('timeout','900')))
  if 'SCRIPT ERROR' in r.stderr+r.stdout: print((r.stderr+r.stdout)[-1500:])
  for i,x in enumerate(json.load(open(S/(tag+'_out.json')))):
    print(i,{k:x.get(k) for k in (['tick','entry','alive','pos','view','hp','suit','energy','state','events'] + (['enemies'] if 'full' in opts else []))})
