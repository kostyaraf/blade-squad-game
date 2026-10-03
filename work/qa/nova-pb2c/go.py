"""go.py BEAM_OUT.json CHAIN [NEED_EVENT] : replay beam result on the stand into CHAIN-cand;
if it has more room changes than CHAIN (or reaches NEED_EVENT text), promote it into CHAIN."""
import json,sys,os,subprocess,pathlib
HERE=pathlib.Path(__file__).resolve().parent;sys.path.insert(0,str(HERE));import qa
src=sys.argv[1]
if not src.startswith('/'): src=os.environ['TMPDIR']+'/nova-pb2c/'+src
chain=sys.argv[2]
subprocess.run([str(HERE/'stand.sh')])
r=subprocess.run(['python3',str(HERE/'accept.py'),src,chain+'-cand'],capture_output=True,text=True)
print(r.stdout[-600:],r.stderr[-600:])
new=json.load(open(qa.F/(chain+'-cand')/'replay.json'))['events']
old=json.load(open(qa.F/chain/'replay.json'))['events'] if (qa.F/chain/'replay.json').exists() else []
ch=lambda ev:[e for e in ev if e['event']=='changed']
ok=len(ch(new))>len(ch(old)) or any(e['event']=='list' and e['message'].startswith('STAGE CLEAR') for e in new)
if ok:
  subprocess.run(['python3',str(HERE/'promote.py'),chain+'-cand',chain],check=True)
  import shutil;shutil.rmtree(qa.F/(chain+'-cand'))
  print('PROMOTED',new[-1])
else: print('NOT PROMOTED')
