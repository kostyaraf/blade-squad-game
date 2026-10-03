"""Bounded QA commands; temporary files exclusively in TMPDIR/nova-pb2b.
Search results contain only input; accept them separately with playthrough.gd.
"""
import argparse, json, os, pathlib, subprocess, sys
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
TMP = pathlib.Path(os.environ.get("TMPDIR", "/tmp")) / "nova-pb2b"
TMP.mkdir(exist_ok=True)
GODOT = "/Applications/Godot_mono.app/Contents/MacOS/Godot"

def path(name):
    p = pathlib.Path(name)
    if p.is_absolute(): return p
    if (TMP / name).exists(): return TMP / name
    return ROOT / "docs/qa/playthrough" / name / "replay.json"

def run(script, args, name, timeout):
    log = TMP / (name + ".log")
    with log.open("w") as f:
        try:
            r = subprocess.run([GODOT, "--headless", "--path", str(ROOT / "game"), "--script", str(script), "--"] + args, stdout=f, stderr=subprocess.STDOUT, timeout=timeout)
            code = r.returncode
        except subprocess.TimeoutExpired: code = 124
    lines = log.read_text().splitlines()
    print("exit", code)
    print("\n".join(lines[-8:]))
    if any("SCRIPT ERROR" in l for l in lines): raise SystemExit(1)
    return code

if __name__ == "__main__":
    action = sys.argv[1]
    if action == "beam":
        prefix, name, wp = sys.argv[2:5]
        code = run(HERE / "beam.gd", ["--replay=" + str(path(prefix)), "--out=" + str(TMP / (name + ".json")), "--wp=" + wp] + sys.argv[5:], name, 1200)
        raise SystemExit(code)
    if action == "probe":
        prefix, name, patterns = sys.argv[2:5]
        cfg = {"prefix":str(path(prefix)),"output":str(TMP / (name + ".json")),"patterns":json.loads(patterns)}
        cf = TMP / (name + ".cfg"); cf.write_text(json.dumps(cfg))
        code = run(HERE / "trial.gd", [str(cf)], name, 60)
        print((TMP / (name + ".json")).read_text()[-6000:])
        raise SystemExit(code)
    if action == "cut":
        prefix,name,ticks = sys.argv[2:5]; n = int(ticks)
        d = json.loads(path(prefix).read_text()); parts = []
        for s in d["steps"]:
            k = min(int(s[0]), n)
            if k <= 0: break
            parts.append([k]+s[1:]); n -= k
        d["steps"] = parts
        d["events"] = [e for e in d.get("events",[]) if e["tick"] <= int(ticks)]
        (TMP / (name + ".json")).write_text(json.dumps(d))
    if action == "append":
        prefix,name,steps = sys.argv[2:5]
        d = json.loads(path(prefix).read_text()); d["steps"] += json.loads(steps)
        (TMP / (name + ".json")).write_text(json.dumps(d))
