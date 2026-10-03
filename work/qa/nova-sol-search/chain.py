import json,sys
sys.path.insert(0,'.')
from qa import F,command,short,save
def trim(steps,n):
 out=[];t=0
 for s in steps:
  if t>=n:break
  k=min(s[0],n-t);out.append([k]+s[1:]);t+=k
 return out
def load(name): return json.loads((F/name/'replay.json').read_text())
