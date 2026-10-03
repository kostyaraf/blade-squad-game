"""accept.py RESULT.json NAME : replay search result on the live stand, save as docs/qa/playthrough/NAME."""
import json,sys,pathlib
sys.path.insert(0,str(pathlib.Path(__file__).parent))
import qa
r=json.load(open(sys.argv[1]));name=sys.argv[2]
p=qa.F/name;p.mkdir(exist_ok=True)
json.dump({'entry':r['entry'],'steps':r['steps'],'heroes':[0],'events':[]},open(p/'replay.json','w'))
st=qa.command(r['steps'],r['entry'],timeout=300)
print(qa.short(st));qa.save(name)
d=json.load(open(qa.F/'replay.json'));print(d['events'])
