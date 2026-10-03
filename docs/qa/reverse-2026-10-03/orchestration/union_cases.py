# Resolve cases.json conflict: union of ours+theirs entries by "file".
import json, subprocess, sys
p = "docs/qa/playthrough/cases.json"
def side(s): return json.loads(subprocess.check_output(["git", "show", f":{s}:{p}"]))
out, seen = [], set()
for e in side(2) + side(3):
    if e["file"] not in seen:
        seen.add(e["file"]); out.append(e)
open(p, "w").write(json.dumps(out, indent=2, ensure_ascii=False) + "\n")
subprocess.check_call(["git", "add", p])
print(len(out), "cases")
