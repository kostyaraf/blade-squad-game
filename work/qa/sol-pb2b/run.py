"""Bounded search and live acceptance; only ordinary recorded input reaches QA stand."""
import json, os, pathlib, subprocess, sys, time, shutil
ROOT = pathlib.Path(__file__).resolve().parents[3]
F = ROOT / "docs/qa/playthrough"
T = pathlib.Path(os.environ.get("TMPDIR", "/tmp")) / "sol-pb2b"
T.mkdir(exist_ok=True)
G = "/Applications/Godot_mono.app/Contents/MacOS/Godot"
def run(script, args, seconds, tag, gui=False):
    log = T / (tag + ".log")
    with log.open("w") as f:
        p = subprocess.Popen([G] + ([] if gui else ["--headless"]) + ["--path", str(ROOT / "game"), "--script", script] + args, stdout=f, stderr=f)
        try: code = p.wait(timeout=seconds)
        except subprocess.TimeoutExpired:
            p.terminate()
            try: p.wait(timeout=5)
            except subprocess.TimeoutExpired: p.kill(); p.wait()
            code = 124
    txt = log.read_text()
    print("\n".join(txt.splitlines()[-6:]))
    print("exit", code, "SCRIPT_ERROR", "SCRIPT ERROR" in txt)
    if "SCRIPT ERROR" in txt: raise RuntimeError(log)
    return code
def accept(src, name, seconds=180):
    d = json.loads(pathlib.Path(src).read_text())
    cmd = {"id":time.time_ns()//1000,"start":d["entry"],"heroes":[1],"steps":d["steps"],"exact_scan":d.get("exact_scan",True),"fast":True,"quit":True}
    (F/"command.json").write_text(json.dumps(cmd))
    code = run("res://tests/playthrough.gd", [], seconds, "stand", True)
    if code != 0: raise RuntimeError("stand exit " + str(code))
    st = json.loads((F/"state.json").read_text())
    if st.get("id") != cmd["id"]: raise RuntimeError("stale state")
    target = F/name; target.mkdir(exist_ok=True)
    for x in ["replay.json","state.json","trace.json","current.png"]: shutil.copyfile(F/x,target/x)
    r = json.loads((target/"replay.json").read_text())
    print(name, "events", r["events"], "players", st["players"])
    return st, r
def promote(name):
    r=json.loads((F/name/"replay.json").read_text())
    cps=[{"tick":e["tick"]-1,"all_alive":True} for e in r["events"] if e["event"]=="changed"]
    cases=json.loads((F/"cases.json").read_text()); key=name+"/replay.json"
    for c in cases:
        if c["file"]==key: c["checkpoints"]=cps;break
    else: cases.append({"file":key,"checkpoints":cps})
    (F/"cases.json").write_text(json.dumps(cases,indent=2,ensure_ascii=False)+"\n")
if __name__=="__main__":
    mode=sys.argv[1]
    if mode=="accept": accept(sys.argv[2],sys.argv[3])
    elif mode=="promote": promote(sys.argv[2])
    elif mode=="search":
        cfg=pathlib.Path(sys.argv[2]);run("res://tests/sol_pb2_"+sys.argv[3]+".gd",["--",str(cfg)],int(sys.argv[4]),cfg.stem)
    elif mode=="probe":
        cfg=pathlib.Path(sys.argv[2]);run("res://tests/sol_pb2_route_probe.gd",["--",str(cfg)],int(sys.argv[3]),cfg.stem)
