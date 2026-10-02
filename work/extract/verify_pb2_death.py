#!/usr/bin/env python3
"""Differential NES oracle for the formerly missing defeated-enemy lifecycle.
Fixture injection isolates type 01; this is NOT a playthrough certificate.
Every subsequent instruction is the unmodified cartridge's own code.
"""
import json, os, subprocess, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'tools'))
import pb2_probe as P
GODOT = '/Applications/Godot_mono.app/Contents/MacOS/Godot'
def main():
    tmp = P.scratch('death')
    try:
        state = P.make_state(os.path.join(tmp,'start.state'), stage=0, area=0)
        cases=[]
        for name,keep,clock in [('no-loot',1,0),('sequence-high',0,0),('sequence-low',0,1),('sequence-next',0,2)]:
            row=[0]*29
            row[0]=1;row[1]=128;row[9]=100;row[12]=100;row[23]=keep
            pokes=[(P.field(f,20),v,2) for f,v in enumerate(row)]
            pokes += [(0x98,clock,2)]
            writes=P.run(state,[(1,'-')],360,pokes=pokes)
            addrs=[P.field(f,20) for f in range(29)]+[0x1c,0x98,0x66,0x67]
            # Initial RAM values absent from WATCH are read from the fixture.
            cur={P.field(f,20):v for f,v in enumerate(row)}
            cur.update({0x98:clock,0x1c:0,0x66:2,0x67:0})
            frames=[];initial=None;last=0
            for fr,values in P.table(writes,addrs,2,360):
                cur.update(values)
                vals=[cur[a] for a in addrs[:29]]
                if initial is None:
                    initial=vals;drop=cur[0x98];cam=cur[0x66]*256+cur[0x67]
                else:
                    frames.append(dict(frame=fr,turns=(cur[0x1c]-last)&255,row=vals,drop_clock=cur[0x98]))
                last=cur[0x1c]
            cases.append(dict(name=name,initial=initial,drop_clock=drop,cam=cam,frames=frames))
        path=os.path.join(tmp,'oracle.json');json.dump(dict(cases=cases),open(path,'w'))
        r=subprocess.run([GODOT,'--headless','--path',os.path.join(P.ROOT,'game'),'--script','res://tests/pb2_death_test.gd','--',path],capture_output=True,text=True,timeout=40)
        print(r.stdout,end='');print(r.stderr,end='')
        return r.returncode or int('SCRIPT ERROR' in r.stderr)
    finally:
        P.sweep(tmp)
if __name__=='__main__':sys.exit(main())
