extends SceneTree
## Input-only route search with backtracking: segment-by-segment depth-first over macro
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
			for dl in (cfg.get("delays", [0]) if int(j) > 0 else [0]):
				cands.append(_macro(int(d), int(j), seg, int(dl)))
	for e in cfg.get("extra", []):
		cands.append(e)
	var depth_best: Array = []
	var stack: Array = []            # per level: [next candidate index, result]
	var lazy_gain: float = float(cfg.get("min_gain", 0.0))
	var req: int = int(cfg.get("req_hp", -1))
	var cur: Dictionary = _run(steps)
	if req < 0: req = cur.hp
	var evals := 0
	var max_evals: int = int(cfg.get("max_evals", 20000))
	var max_segments: int = int(cfg.get("segments", 400))
	var order_seed: int = int(cfg.get("shuffle", 0))
	var base_len := steps.size()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(cfg.get("shuffle", 0))
	var shuf: bool = int(cfg.get("shuffle", 0)) != 0
	var levels: Array = [[0, cur, _order(cands.size(), rng, shuf)]]   # levels[i] = [next cand idx, state after i macros]
	var macros: Array = []           # accepted macros
	var best_tick: int = int(cur.tick)
	var fails := 0
	var best_macros: Array = []
	var best_results: Array = [cur]
	var since_best := 0
	var patience: int = int(cfg.get("patience", 300))
	var reopen: int = int(cfg.get("reopen", 4))
	while evals < max_evals and levels.size() <= max_segments:
		since_best += 1
		if since_best > patience and req > 0:
			# stuck: take one more point of damage and reopen the last levels
			req -= 1
			since_best = 0
			macros = best_macros.duplicate()
			levels = []
			for i in range(best_results.size()):
				levels.append([0 if i >= best_results.size() - reopen else cands.size(), best_results[i], _order(cands.size(), rng, shuf)])
			print("RELAX req ", req, " from tick ", best_tick)
			continue
		var lv: Array = levels[-1]
		if lv[0] >= cands.size():
			# exhausted: backtrack
			levels.pop_back()
			if levels.is_empty(): break
			if not macros.is_empty(): macros.pop_back()
			fails += 1
			continue
		var c: Array = cands[lv[2][lv[0]]]
		lv[0] += 1
		var trial: Array = steps.duplicate(true)
		for m in macros: trial.append_array(m)
		trial.append_array(c)
		var r: Dictionary = _run(trial)
		evals += 1
		if r.event != "" and (r.score > 1.0e8):
			macros.append(c)
			for m in macros: _append(steps, m)
			print("WIN tick ", r.tick, " evals ", evals)
			_save(steps, [], r)
			quit(0)
			return
		if r.score < -1.0e8 or r.hp < req or r.prog < (lv[1].prog + lazy_gain):
			continue
		macros.append(c)
		levels.append([0, r, _order(cands.size(), rng, shuf)])
		if r.tick > best_tick:
			best_tick = r.tick
			since_best = 0
			best_macros = macros.duplicate()
			best_results = []
			for L in levels: best_results.append(L[1])
			var out_steps: Array = steps.duplicate(true)
			for m in macros: _append(out_steps, m)
			_save(out_steps, [{"tick": r.tick, "x": r.x, "y": r.y, "hp": r.hp, "evals": evals, "depth": levels.size(), "boss": r.get("boss", -1)}], r)
	print("END evals ", evals, " best tick ", best_tick)
	quit(0)

func _order(n: int, rng: RandomNumberGenerator, shuf: bool) -> Array:
	var o: Array = range(n)
	if shuf:
		for i in range(n - 1, 0, -1):
			var j: int = rng.randi_range(0, i)
			var t = o[i]; o[i] = o[j]; o[j] = t
	return o

func _append(steps: Array, part: Array) -> void:
	for p in part:
		if not steps.is_empty() and int(steps[-1][1]) == int(p[1]): steps[-1][0] += int(p[0])
		else: steps.append([int(p[0]), int(p[1])])

func _macro(dir: int, jump: int, seg: int, delay: int = 0) -> Array:
	var out: Array = []
	var shoot: int = int(cfg.get("shoot", 8))
	for t in range(seg):
		var pad := dir
		if t >= delay and t < delay + jump: pad |= 128
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
	var win := false
	for part in steps:
		for _f in range(int(part[0])):
			if s.two == null: break
			var e := s.advance(s.tick, [int(part[1])])
			if e != "playing":
				event = e
				win = "CLEAR" in s.message
				break
		if s.two == null or event != "": break
	var res := {"tick": s.tick, "event": event, "x": 0, "y": 0, "hp": 0, "view": 0, "score": -1.0e9, "prog": -1.0e9}
	if event != "" or s.at != entry:
		res.score = 1.0e9 if (event == "changed" or win) else -1.0e9
		if s.two != null: s.leave()
		return res
	var p: Vector2i = s.two.world_of(0)
	var h: SolPlayer = s.two.sol[0]
	res.x = p.x; res.y = p.y; res.hp = h.suit
	res.view = s.two.eye.pos if s.two.pb2v.vertical else 0
	var g: Dictionary = cfg.get("goal", {})
	var score: float = 0.0
	if g.has("y") and (not g.has("y_when_y_below") or p.y < int(g.y_when_y_below)): score -= absf(float(p.y) - float(g.y)) * 10.0
	elif not g.has("y") and not cfg.get("no_y", false): score -= float(p.y) * 10.0
	if g.has("x") and (not g.has("x_when_y_below") or p.y < int(g.x_when_y_below)):
		score -= absf(float(p.x) - float(g.x)) * 10.0
	if cfg.get("boss", false):
		var life := 0
		var bx := -1
		for n in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
			var r: PackedByteArray = s.two.host_pb2.slots[n]
			if r[Pb2Objects.F_TYPE] >= 0x50 and r[Pb2Objects.F_TYPE] < 0x60:
				life = maxi(life, r[Pb2Objects.F_LIFE])
				bx = r[Pb2Objects.F_X]
		res["boss"] = life
		if s.tick >= int(cfg.get("boss_from", 150)): score -= float(life) * 400.0
		if bx >= 0:
			score -= absf(float(bx) - float(res.x - s.two.view_x())) * float(cfg.get("boss_dist", 2.0))
	if cfg.has("broken_bonus"):
		var bits: int = int(s.two.host_pb2.broken)
		var cnt := 0
		while bits != 0:
			cnt += bits & 1
			bits >>= 1
		score += float(cnt) * float(cfg.broken_bonus)
	res.prog = score
	res.score = score + float(h.suit) * 100000.0
	s.leave()
	return res

func _save(steps: Array, log: Array, best: Dictionary) -> void:
	var f := FileAccess.open(cfg.out, FileAccess.WRITE)
	f.store_string(JSON.stringify({"steps": steps, "log": log, "last": best}))
