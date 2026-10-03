import sys,json;sys.path.insert(0,'.')
from qa import command,short,save,F
# rec.py out.json savename [extra_steps_json]
d=json.load(open(sys.argv[1]))
steps=d['steps']+(json.loads(sys.argv[3]) if len(sys.argv)>3 else [])
command([],d['entry'],d.get('heroes',[0]))
st=command(steps)
print(short(st))
print(json.loads((F/'replay.json').read_text())['events'])
save(sys.argv[2])
tr=json.loads((F/'trace.json').read_text())
print('min life',min((p['life'] for t in tr for p in t['players'] if 'life' in p),default=None),'ticks',len(tr))
