extends SceneTree
## Input-only route search for one room: segment-by-segment greedy over macro
## actions, every candidate replayed from the normal entry.  No game state is
## written; the result is an ordinary button list to be re-recorded in
## playthrough.gd.  Config: {"out","entry","gun","prefix":[[n,pad]],"seg":40,
## "segments":80,"goal":{"x":..,"y":..},"jumps":[0,8,24],"dirs":[0,1,2],"shoot":8,
## "extra":[[[n,pad],..],..]}  (extra = raw macro sequences added as candidates)
var cfg: Dictionary

func _initialize() -> void:
	cfg = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var steps: Array = cfg.get("prefix", []).duplicate(true)
	var seg: int = int(cfg.get("seg", 40))
	var cands: Array = []
	for d in cfg.get("dirs", [0, 1, 2]):
		for j in cfg.get("jumps", [0, 8, 24]):
			cands.append(_macro(int(d), int(j), seg))
	for e in cfg.get("extra", []):
		cands.append(e)
	var log: Array = []
	for k in range(int(cfg.get("segments", 80))):
		var best: Dictionary = {}
		for c in cands:
			var r := _run(steps + c)
			if best.is_empty() or r.score > best.score:
				best = r
				best["cand"] = c
		for part in best.cand:
			if not steps.is_empty() and int(steps[-1][1]) == int(part[1]): steps[-1][0] += int(part[0])
			else: steps.append([int(part[0]), int(part[1])])
		log.append({"tick": best.tick, "x": best.x, "y": best.y, "hp": best.hp, "view": best.view, "score": best.score})
		print("seg ", k, " tick ", best.tick, " pos ", best.x, ",", best.y, " hp ", best.hp, " ev ", best.event)
		_save(steps, log, best)
		if best.event != "" and best.event != "playing":
			break
		if best.hp <= 0:
			break
	quit(0)

func _macro(dir: int, jump: int, seg: int) -> Array:
	var out: Array = []
	var shoot: int = int(cfg.get("shoot", 8))
	for t in range(seg):
		var pad := dir
		if t < jump: pad |= 128
		if shoot > 0 and t % shoot == 0: pad |= 64
		if not out.is_empty() and int(out[-1][1]) == pad: out[-1][0] += 1
		else: out.append([1, pad])
	return out

func _run(steps: Array) -> Dictionary:
	Pb2Turn.exact_scan = bool(cfg.get("exact_scan", true))
	var s := Pb3Session.new([1])
	var entry: int = int(cfg.get("entry", 5))
	s.at = entry
	s.enter()
	if cfg.has("gun"): s.gear.gun[0] = int(cfg.gun)
	var event := ""
	for part in steps:
		for _f in range(int(part[0])):
			if s.two == null: break
			var e := s.advance(s.tick, [int(part[1])])
			if e != "playing":
				event = e
				break
		if s.two == null or event != "": break
	var res := {"tick": s.tick, "event": event, "x": 0, "y": 0, "hp": 0, "view": 0, "score": -1.0e9}
	if event != "" or s.at != entry:
		res.score = 1.0e9 if event == "changed" else -1.0e9
		if s.two != null: s.leave()
		return res
	var p: Vector2i = s.two.world_of(0)
	var h: SolPlayer = s.two.sol[0]
	res.x = p.x; res.y = p.y; res.hp = h.suit
	res.view = s.two.eye.pos if s.two.pb2v.vertical else 0
	var g: Dictionary = cfg.get("goal", {})
	var score: float = float(h.suit) * 100000.0
	if g.has("y"): score -= absf(float(p.y) - float(g.y)) * 10.0
	else: score -= float(p.y) * 10.0
	if g.has("x"): score -= absf(float(p.x) - float(g.x))
	res.score = score
	s.leave()
	return res

func _save(steps: Array, log: Array, best: Dictionary) -> void:
	var f := FileAccess.open(cfg.out, FileAccess.WRITE)
	f.store_string(JSON.stringify({"steps": steps, "log": log, "last": best}))
