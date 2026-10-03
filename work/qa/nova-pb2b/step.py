"""step.py CHAIN CODE WP [beam args...]: beam-search the next room from the end of CHAIN
(or from a fresh normal entry if CHAIN does not exist yet: --entry=N), replay the result on
the live playthrough.gd stand, seal into CHAIN (report row + cases.json + commit)."""
import json,sys,subprocess,pathlib,os,shutil
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];F=ROOT/'docs/qa/playthrough'
TMP=pathlib.Path(os.environ.get('TMPDIR','/tmp'))/'nova-pb2b';TMP.mkdir(exist_ok=True)
chain,code,wp=sys.argv[1:4];rest=sys.argv[4:]
entry=[a for a in rest if a.startswith('--entry=')];rest=[a for a in rest if not a.startswith('--entry=') and a!='--nosave']
note=os.environ.get('NOTE','поиск лучом обычных нажатий')
pre=F/chain/'replay.json'
if not pre.exists():
  pre=TMP/(chain+'-start.json');pre.write_text(json.dumps({'entry':int(entry[0][8:]),'steps':[],'heroes':[0],'events':[]}))
name=chain+'-'+code
r=subprocess.run(['python3',str(HERE/'route.py'),'beam',str(pre),name,wp]+rest,capture_output=True,text=True)
print(r.stdout[-900:])
if 'done=true' not in r.stdout: print('NO WIN');sys.exit(1)
if '--nosave' in sys.argv: sys.exit(0)
cand=chain+'-cand'
a=subprocess.run(['python3',str(HERE/'accept.py'),str(TMP/(name+'.json')),cand],capture_output=True,text=True)
print(a.stdout[-600:],a.stderr[-600:])
log=(TMP/'stand.log').read_text() if (TMP/'stand.log').exists() else ''
if 'SCRIPT ERROR' in log: print('SCRIPT ERROR on stand');sys.exit(2)
s=subprocess.run(['python3',str(HERE/'seal.py'),cand,chain,code,note],capture_output=True,text=True,cwd=ROOT)
print(s.stdout[-400:],s.stderr[-800:])
shutil.rmtree(F/cand,ignore_errors=True)
sys.exit(s.returncode)
