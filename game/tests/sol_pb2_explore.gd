extends SceneTree
## Go-Explore style input-only search for Solbrain in a Power Blade 2 room.
## A cell archive (position bucket) keeps one full-state snapshot per cell
## (sol_pb2_snap.gd); random pad macros are played from archived cells, so
## local minima of the route do not matter.  Only pad words go into
## Pb3Session.advance; nothing is written into the game state.
## Usage: --script res://tests/sol_pb2_explore.gd -- /abs/config.json
## cfg: entry, gun, exact_scan, prefix [[n,pad]..], goal [x,y] (selection bias
## only), layer, cell (px), macros [names], seconds, hp_min, seed, out,
## log_every, hp_cell (bool: separate cells per HP), max_chain.
const Snap = preload("res://tests/sol_pb2_snap.gd")
var cfg: Dictionary
var macro_pads: Array = []

func rep(p: int, n: int) -> Array:
	var a := []
	for i in range(n): a.append(p)
	return a

func pulse(on: int, off: int, n: int) -> Array:
	var a := []
	for i in range(n): a.append(on if i % 4 == 0 else off)
	return a

func _initialize() -> void:
	cfg = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var L: int = int(cfg.get("layer", 6))
	var defs := {
		"N": rep(0, L), "R": rep(1, L), "L": rep(2, L), "D": rep(4, L), "U": rep(8, L),
		"RA": rep(129, L), "LA": rep(130, L), "A": rep(128, L), "UA": rep(136, L),
		"RAt": [129] + rep(1, L - 1), "LAt": [130] + rep(2, L - 1), "At": [128] + rep(0, L - 1),
		"RB": pulse(65, 1, L), "LB": pulse(66, 2, L), "B": pulse(64, 0, L),
		"RAB": pulse(193, 129, L), "LAB": pulse(194, 130, L), "AB": pulse(192, 128, L),
		"UR": rep(9, L), "UL": rep(10, L), "DR": rep(5, L), "DL": rep(6, L),
		"DA": rep(132, L), "DRA": rep(133, L), "DLA": rep(134, L),
		"UB": pulse(72, 8, L), "DB": pulse(68, 4, L), "URA": rep(137, L), "ULA": rep(138, L),
		"RAtB": [193] + pulse(65, 1, L - 1), "LAtB": [194] + pulse(66, 2, L - 1),
		"NN": rep(0, 30), "RR": rep(1, 24), "LL": rep(2, 24), "BB": pulse(64, 0, 24), "DD": rep(4, 24),
		"RRB": pulse(65, 1, 24), "LLB": pulse(66, 2, 24), "A20": rep(128, 20), "RA20": rep(129, 20), "LA20": rep(130, 20),
		"RAt20": [129] + rep(1, 19), "LAt20": [130] + rep(2, 19), "UU": rep(8, 24), "DDR": rep(5, 24), "DDL": rep(6, 24),
	}
	var names: Array = cfg.get("macros", ["N", "R", "L", "RA", "LA", "A", "RAt", "LAt", "RB", "LB", "B", "RAB", "LAB", "D", "DA", "DRA", "DLA", "U", "UR", "UL"])
	for n in names: macro_pads.append(defs[n])
	Pb2Turn.exact_scan = bool(cfg.get("exact_scan", false))
	var rng := RandomNumberGenerator.new()
	rng.seed = int(cfg.get("seed", 1))
	var s := Pb3Session.new([1])
	s.at = int(cfg.entry)
	s.enter()
	if cfg.has("gun"): s.gear.gun[0] = int(cfg.gun)
	var entry: int = s.at
	var path: Array = []
	for part in cfg.get("prefix", []):
		for i in range(int(part[0])):
			s.advance(s.tick, [int(part[1])])
			path.append(int(part[1]))
	var cell: int = int(cfg.get("cell", 16))
	var hp_min: int = int(cfg.get("hp_min", 1))
	var hp_cell: bool = cfg.get("hp_cell", false)
	var has_goal: bool = cfg.has("goal")
	var gx := 0.0
	var gy := 0.0
	if has_goal:
		gx = float(cfg.goal[0])
		gy = float(cfg.goal[1])
	var max_chain: int = int(cfg.get("max_chain", 3))
	var archive := {}      # key -> node
	var keys: Array = []
	var root := {"snap": Snap.take(s), "parent": null, "mac": -1, "hp": s.two.sol[0].suit, "ticks": 0, "chosen": 0, "dist": 1.0e9}
	var w0: Vector2i = s.two.world_of(0)
	var k0 := _key(w0, root.hp, cell, hp_cell, s)
	archive[k0] = root
	keys.append(k0)
	var t0 := Time.get_ticks_msec()
	var deadline: int = int(cfg.get("seconds", 600)) * 1000
	var iters := 0
	var best_dist := 1.0e9
	var best_pos := Vector2i.ZERO
	while Time.get_ticks_msec() - t0 < deadline:
		iters += 1
		# choose a cell: half uniformly weighted by rarity, half near the goal
		var pick: Dictionary
		var roll := rng.randf()
		if has_goal and roll < 0.4:
			var bestn: Dictionary = {}
			var bd := 1.0e18
			for _t in range(8):
				var cand: Dictionary = archive[keys[rng.randi_range(0, keys.size() - 1)]]
				var d: float = cand.dist + cand.chosen * 3.0
				if d < bd:
					bd = d
					bestn = cand
			pick = bestn
		else:
			var bestn2: Dictionary = {}
			var bc := 1 << 30
			for _t in range(4):
				var cand2: Dictionary = archive[keys[rng.randi_range(0, keys.size() - 1)]]
				if cand2.chosen < bc:
					bc = cand2.chosen
					bestn2 = cand2
			pick = bestn2
		pick.chosen += 1
		Snap.put(pick.snap)
		var node: Dictionary = pick
		var chain: int = rng.randi_range(1, max_chain)
		for _c in range(chain):
			var mi: int = rng.randi_range(0, macro_pads.size() - 1)
			var done := false
			var dead := false
			for pad in macro_pads[mi]:
				var ev := s.advance(s.tick, [pad])
				if ev == "changed" or (ev == "list" and s.message.begins_with("STAGE CLEAR")):
					done = true
					break
				if ev != "playing" or s.two == null:
					dead = true
					break
			if dead: break
			if done:
				print("WIN iters ", iters, " ticks ", node.ticks + L, " cells ", keys.size())
				_save({"parent": node, "mac": mi}, path, entry, true)
				quit(0)
				return
			var h: SolPlayer = s.two.sol[0]
			if h.suit < hp_min or h.state == 0x0E or h.state == 0x0C: break
			var w: Vector2i = s.two.world_of(0)
			var key := _key(w, h.suit, cell, hp_cell, s)
			var nticks: int = node.ticks + L
			var old = archive.get(key)
			var better: bool = old == null or h.suit > old.hp or (h.suit == old.hp and nticks < old.ticks - 8)
			var dist := 0.0
			if has_goal: dist = absf(w.x - gx) + absf(w.y - gy)
			if better:
				var nn := {"snap": Snap.take(s), "parent": node, "mac": mi, "hp": h.suit, "ticks": nticks, "chosen": 0 if old == null else old.chosen, "dist": dist, "sig": "%d %s %d" % [s.tick, w, h.suit]}
				if old == null: keys.append(key)
				archive[key] = nn
				node = nn
			else:
				# keep walking from the live state, but do not archive it
				node = {"snap": null, "parent": node, "mac": mi, "hp": h.suit, "ticks": nticks, "chosen": 0, "dist": dist}
			if dist < best_dist:
				best_dist = dist
				best_pos = w
		if iters % int(cfg.get("log_every", 2000)) == 0:
			print("iters ", iters, " cells ", keys.size(), " best_dist ", int(best_dist), " at ", best_pos, " s ", (Time.get_ticks_msec() - t0) / 1000)
	print("TIMEOUT cells ", keys.size(), " best_dist ", int(best_dist))
	# save the archive node closest to the goal
	var bestk = null
	var bdd := 1.0e9
	for k in keys:
		var nd: Dictionary = archive[k]
		if nd.dist < bdd:
			bdd = nd.dist
			bestk = nd
	if bestk != null: _save({"parent": bestk, "mac": -1}, path, entry, false)
	quit(1)

func _key(w: Vector2i, hp: int, cell: int, hp_cell: bool, s: Pb3Session) -> String:
	var h: SolPlayer = s.two.sol[0]
	var air := 1 if h.state not in [0, 1, 2] else 0
	var tb: int = int(cfg.get("time_cell", 0))
	var tk: int = (s.tick / tb) if tb > 0 else 0
	if hp_cell: return "%d,%d,%d,%d,%d" % [w.x / cell, w.y / cell, hp, air, tk]
	return "%d,%d,%d,%d" % [w.x / cell, w.y / cell, air, tk]

func _save(last: Dictionary, path: Array, entry: int, done: bool) -> void:
	var macs: Array = []
	var sigs: Array = []
	var n = last
	while n != null:
		if n.mac >= 0: macs.append(n.mac)
		if n.has("sig"): sigs.append(n.sig)
		n = n.parent
	sigs.reverse()
	macs.reverse()
	var pads: Array = path.duplicate()
	for m in macs: pads.append_array(macro_pads[m])
	var steps: Array = []
	for p in pads:
		if not steps.is_empty() and steps[-1][1] == p: steps[-1][0] += 1
		else: steps.append([1, p])
	var f := FileAccess.open(cfg.out, FileAccess.WRITE)
	f.store_string(JSON.stringify({"entry": entry, "steps": steps, "done": done, "sigs": sigs}))
