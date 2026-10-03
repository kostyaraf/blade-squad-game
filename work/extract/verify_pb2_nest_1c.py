#!/usr/bin/env python3
"""Compare every child $1C state to the unmodified NES. Fixtures are diagnostic."""
import json,os,pathlib,struct,subprocess,sys,tempfile
ROOT=pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/"work/tools"));import pb2_probe as P
P.SCRATCH=str(pathlib.Path(os.environ.get("TMPDIR","/tmp"))/"sol-pb2b")
G="/Applications/Godot_mono.app/Contents/MacOS/Godot"
def records(path):
 data=pathlib.Path(path).read_bytes()
 if len(data)%2056:raise RuntimeError("Incomplete RAM capture")
 for at in range(0,len(data),2056):
  f,pc,bank=struct.unpack("<IHH",data[at:at+8]);yield f,list(data[at+8:at+2056])
def main():
 tmp=P.scratch("nest1c-")
 try:
  state=P.make_state(os.path.join(tmp,"start.st"),stage=0,area=0)
  first=P.IN_LEVEL+2;fixtures=[]
  d=json.loads((ROOT/"game/data/pb2/objects.json").read_text())
  for phase in range(4):
   for name,st,x,y,vx,vy,frac in [("birth",0,140,64,0,0,0),("fall",1,180,82,255,1,93),("walk-left",2,160,143,255,0,0),("walk-right",2,210,143,1,0,0),("edge",2,130,95,255,0,141),("finish",3,160,143,0,0,0)]:
    r=[0]*29;r[0]=0x1C;r[12]=x;r[9]=y;r[18]=st;r[16]=vx;r[14]=vy;r[10]=frac;r[13]=frac
    if st:
     r[1]=1;r[7]=1;an=d["anims"][13 if st<3 else 1];r[4]=13 if st<3 else 1;r[3]=an["first"];r[19]=an["hold"];r[24]=an["first"]
    if st==3:r[21]=3
    fixtures.append((name+str(phase),r,phase))
  cases=[];seen=set()
  for name,row,phase in fixtures:
   pokes=[(P.field(0,n),0,first) for n in range(6,22)]
   pokes +=[(P.field(f,6),v,first) for f,v in enumerate(row)]+[(0x119,phase,first)]
   dump=os.path.join(tmp,name+".bin");cmd=P.emu("-loadstate",state,"-frames",str(first+160),"-ramat",dump+"@CF1C")
   for a,v,fr in pokes:cmd +=["-poke",f"{a:04X}={v:02X}@{fr}"]
   subprocess.run(cmd,check=True,capture_output=True,timeout=30)
   snaps=[(f,m) for f,m in records(dump) if f>=first]
   if len(snaps)<159:raise RuntimeError("Too few captured turns")
   if snaps[0][1][P.field(18,6)]!=row[18]:raise RuntimeError("Bad fixture")
   seen.update(m[P.field(18,6)] for f,m in snaps if m[P.field(0,6)]==0x1C)
   cases.append(dict(name=name,snaps=[dict(frame=f,ram=m[:0x700]) for f,m in snaps]))
  if not {0,1,2,3}<=seen:raise RuntimeError("Missing native child states")
  path=os.path.join(tmp,"oracle.json");pathlib.Path(path).write_text(json.dumps(dict(cases=cases)))
  result=subprocess.run([G,"--headless","--path",str(ROOT/"game"),"--script","res://tests/pb2_nest_1c_test.gd","--",path],capture_output=True,text=True,timeout=90)
  print(result.stdout,end="");print(result.stderr,end="")
  return result.returncode or int("SCRIPT ERROR" in result.stdout+result.stderr or "ERROR:" in result.stderr or "NES nest $1C: 0 / " not in result.stdout)
 finally:P.sweep(tmp)
if __name__=="__main__":sys.exit(main())
