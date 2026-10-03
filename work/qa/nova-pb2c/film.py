"""film.py START_ENTRY PREFIX_STEPS_JSON_FILE 'EXTRA_STEPS' EVERY OUT.png : replay prefix on stand, then
run extra steps in chunks of EVERY ticks, grab current.png each chunk, build a grid image."""
import json,sys,os,shutil
sys.path.insert(0,os.path.dirname(__file__));import qa
from PIL import Image
pre=json.load(open(sys.argv[1]));extra=json.loads(sys.argv[2]);every=int(sys.argv[3]);out=sys.argv[4]
st=qa.command(pre['steps'],pre['entry'],timeout=300)
frames=[Image.open(qa.F/'current.png').copy()];info=[qa.short(st)]
flat=[]
for s in extra:
  for _ in range(s[0]): flat.append(s[1:])
i=0
while i<len(flat):
  chunk=flat[i:i+every];i+=every
  steps=[];
  for w in chunk:
    if steps and steps[-1][1:]==w: steps[-1][0]+=1
    else: steps.append([1]+w)
  st=qa.command(steps,timeout=120);frames.append(Image.open(qa.F/'current.png').copy());info.append(qa.short(st))
  if not st.get('players'): break
w,h=frames[0].size;cols=4;rows=(len(frames)+cols-1)//cols
g=Image.new('RGB',(w*cols,h*rows))
for k,f in enumerate(frames): g.paste(f,((k%cols)*w,(k//cols)*h))
g.save(out)
for k,x in enumerate(info): print(k,x)
