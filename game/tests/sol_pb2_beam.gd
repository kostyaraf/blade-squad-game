extends SceneTree
## Input-only beam search for Solbrain in a Power Blade 2 room, using full-state
## snapshots (sol_pb2_snap.gd) so that a step costs a few frames, not a replay.
## Never writes HP, position or map: only pad words go into Pb3Session.advance.
## Usage: --script res://tests/sol_pb2_beam.gd -- /abs/config.json
## cfg: entry, gun, exact_scan, prefix [[n,pad]..], goals [[x,y,tol]..] (waypoints,
## the last one is the target; optional 4th/5th numbers = y/x weight of that waypoint), layer, beam, maxlayers, hp_w, yw, boss (bool),
## boss_w, macros [names], out, log_every, hp_min.
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
	var L: int = int(cfg.get("layer", 8))
	var defs := {
		"N": rep(0, L), "R": rep(1, L), "L": rep(2, L), "D": rep(4, L), "U": rep(8, L),
		"RA": rep(129, L), "LA": rep(130, L), "A": rep(128, L), "UA": rep(136, L),
		"RAt": [129] + rep(1, L - 1), "LAt": [130] + rep(2, L - 1), "At": [128] + rep(0, L - 1),
		"RB": pulse(65, 1, L), "LB": pulse(66, 2, L), "B": pulse(64, 0, L),
		"RAB": pulse(193, 129, L), "LAB": pulse(194, 130, L), "AB": pulse(192, 128, L),
		"UR": rep(9, L), "UL": rep(10, L), "DR": rep(5, L), "DL": rep(6, L),
		"DA": rep(132, L), "DRA": rep(133, L), "DLA": rep(134, L),
		"UB": pulse(72, 8, L), "DB": pulse(68, 4, L),
		"RAtB": [193] + pulse(65, 1, L - 1), "LAtB": [194] + pulse(66, 2, L - 1),
		"NN": rep(0, 30), "RR": rep(1, 24), "LL": rep(2, 24), "BB": pulse(64, 0, 24), "DD": rep(4, 24),
		"RRB": pulse(65, 1, 24), "LLB": pulse(66, 2, 24), "A20": rep(128, 20), "RA20": rep(129, 20), "LA20": rep(130, 20),
		"RAt20": [129] + rep(1, 19), "LAt20": [130] + rep(2, 19), "UU": rep(8, 24), "DDR": rep(5, 24), "DDL": rep(6, 24),
		"URA": rep(137, L), "ULA": rep(138, L),
	}
	var names: Array = cfg.get("macros", ["N", "R", "L", "RA", "LA", "A", "RAt", "LAt", "RB", "LB", "B", "RAB", "LAB", "D", "U", "UR", "UL"])
	for n in names: macro_pads.append(defs[n])
	Pb2Turn.exact_scan = bool(cfg.get("exact_scan", false))
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
	var goals: Array = cfg.get("goals", [])
	var boss: bool = cfg.get("boss", false)
	var hpw: float = float(cfg.get("hp_w", 400))
	var yw: float = float(cfg.get("yw", 1.0))
	var hp0: int = s.two.sol[0].suit
	var hp_min: int = int(cfg.get("hp_min", 1))
	var beam_n: int = int(cfg.get("beam", 24))
	var layers: Array = []
	var beam: Array = [{"snap": Snap.take(s), "wp": 0, "hp": hp0, "score": 0.0}]
	var t0 := Time.get_ticks_msec()
	for layer in range(int(cfg.get("maxlayers", 2000))):
		var cand: Array = []
		var seen := {}
		for bi in range(beam.size()):
			var node: Dictionary = beam[bi]
			for mi in range(macro_pads.size()):
				Snap.put(node.snap)
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
				if dead: continue
				if done:
					print("WIN layer ", layer, " tick ", s.tick)
					_save(layers, bi, mi, path, entry, true)
					quit(0)
					return
				var h: SolPlayer = s.two.sol[0]
				if h.suit < hp_min or h.state == 0x0E or h.state == 0x0C: continue
				var w: Vector2i = s.two.world_of(0)
				var wp: int = node.wp
				while wp < goals.size() - 1:
					var g: Array = goals[wp]
					if absi(w.x - int(g[0])) <= int(g[2]) and absi(w.y - int(g[1])) <= int(g[2]): wp += 1
					else: break
				var sc := wp * 10000.0 - (hp0 - h.suit) * hpw
				if not goals.is_empty():
					var g2: Array = goals[mini(wp, goals.size() - 1)]
					var ywg: float = float(g2[3]) if g2.size() > 3 else yw
					var xwg: float = float(g2[4]) if g2.size() > 4 else 1.0
					sc -= absf(w.x - float(g2[0])) * xwg + absf(w.y - float(g2[1])) * ywg
				if boss:
					var bl := 0
					for n in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
						var r: PackedByteArray = s.two.host_pb2.slots[n]
						if r[0] >= 0x50 and r[0] < 0x60: bl = maxi(bl, r[Pb2Objects.F_LIFE])
					sc -= bl * float(cfg.get("boss_w", 300))
				var key := "%d,%d,%d,%d,%d" % [w.x >> 3, w.y >> 3, h.state, h.suit, wp]
				if seen.has(key) and seen[key] >= sc: continue
				seen[key] = sc
				cand.append({"snap": null, "wp": wp, "hp": h.suit, "score": sc, "par": bi, "mac": mi, "key": key, "pos": w})
		cand.sort_custom(func(a, b): return a.score > b.score)
		var uniq := {}
		var sel: Array = []
		for c in cand:
			if uniq.has(c.key): continue
			uniq[c.key] = true
			sel.append(c)
			if sel.size() >= beam_n: break
		if sel.is_empty():
			print("DEAD END layer ", layer)
			break
		for c in sel:
			Snap.put(beam[c.par].snap)
			for pad in macro_pads[c.mac]: s.advance(s.tick, [pad])
			c.snap = Snap.take(s)
		var rec := []
		for c in sel: rec.append([c.par, c.mac])
		layers.append(rec)
		beam = sel
		if layer % int(cfg.get("log_every", 25)) == 0:
			var b0: Dictionary = beam[0]
			print("layer ", layer, " tick ", (layer + 1) * L, " wp ", b0.wp, " pos ", b0.pos, " hp ", b0.hp, " score ", int(b0.score), " ms ", Time.get_ticks_msec() - t0)
			_save(layers, 0, -1, path, entry, false)
	print("FAILED")
	_save(layers, 0, -1, path, entry, false)
	quit(1)

func _save(layers: Array, bi: int, last: int, path: Array, entry: int, done: bool) -> void:
	var macs: Array = []
	var idx := bi
	if last >= 0: macs.append(last)
	for li in range(layers.size() - 1, -1, -1):
		var r: Array = layers[li][idx]
		macs.append(r[1])
		idx = r[0]
	macs.reverse()
	var pads: Array = path.duplicate()
	for m in macs: pads.append_array(macro_pads[m])
	var steps: Array = []
	for p in pads:
		if not steps.is_empty() and steps[-1][1] == p: steps[-1][0] += 1
		else: steps.append([1, p])
	var f := FileAccess.open(cfg.out, FileAccess.WRITE)
	f.store_string(JSON.stringify({"entry": entry, "steps": steps, "done": done}))
