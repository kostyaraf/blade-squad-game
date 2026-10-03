#!/usr/bin/env python3
"""Submit ordinary input to the running playthrough.gd and wait at most 75s."""
import json,pathlib,sys,time
folder=pathlib.Path(__file__).resolve().parents[3]/'docs/qa/playthrough'
cmd=json.loads(sys.argv[1]);cmd.setdefault('id',time.time_ns()//1000);cmd.setdefault('fast',True)
(folder/'command.json').write_text(json.dumps(cmd))
end=time.monotonic()+75
while time.monotonic()<end:
 try:
  s=json.loads((folder/'state.json').read_text())
  if s.get('id')==cmd['id']:
   print(json.dumps(s));break
 except (ValueError,FileNotFoundError):pass
 time.sleep(.1)
else:raise TimeoutError('playthrough command')
