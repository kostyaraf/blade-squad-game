extends SceneTree
## Offline rollout worker: plays ONLY controller input from the normal menu
## entry (prefix + random policy rollouts). Output is a candidate input list;
## acceptance is always a fresh replay through tests/playthrough.gd.
var cfg: Dictionary
var rng := RandomNumberGenerator.new()

func _initialize() -> void:
	cfg = JSON.parse_string(FileAccess.get_file_as_string(OS.get_environment("WORKER_CFG")))
	rng.seed = int(cfg.get("seed", 1))
	var results: Array = []
	for r in range(int(cfg.get("rollouts", 4))):
		results.append(rollout())
	var f := FileAccess.open(cfg.out, FileAccess.WRITE)
	f.store_string(JSON.stringify(results))
	f.close()
	quit(0)

class Sim:
	var s: Pb3Session
	var dead := false
	var won := false
	var wi := 0
	var best_wi := 0
	var hits := 0
	var changes := 0

func make() -> Sim:
	var sim := Sim.new()
	var heroes: Array = []
	for h in cfg.get("heroes", [0]): heroes.append(int(h))
	sim.s = Pb3Session.new(heroes)
	sim.s.at = int(cfg.entry)
	sim.s.enter()
	return sim

func life(sim: Sim) -> int:
	var two := sim.s.two
	if two == null or two.gone[0]: return 0
	return two.things[0].slots[0][Pb2Objects.F_LIFE]

func boss(sim: Sim) -> int:
	var two := sim.s.two
	if two == null or two.host_sol == null: return 0
	var o := two.host_sol
	var t := 0
	for n in range(16):
		if cfg.has("boss_ids"):
			if float(o.id[n]) in cfg.boss_ids and (o.mind[n] & 0x80) == 0 and int(o.life[n]) < 250:
				t += int(o.life[n])
			continue
		if o.id[n] != 0 and int(o.life[n]) >= int(cfg.get("boss_min_life", 12)) and int(o.life[n]) < 250:
			t += int(o.life[n])
	return t

func play(sim: Sim, steps: Array) -> void:
	for part in steps:
		var pad: Array = []
		for i in range(1, part.size()): pad.append(int(part[i]))
		for _f in range(int(part[0])):
			if sim.s.two == null or sim.dead or sim.won: return
			var e := sim.s.advance(sim.s.tick, pad)
			if e == "changed" and (bool(cfg.get("only_clear", false)) \
					or sim.s.at != int(cfg.get("goal_entry", -1)) and sim.changes < int(cfg.get("skip_changes", 0))):
				sim.changes += 1
			elif e == "changed":
				var ge := int(cfg.get("goal_entry", -1))
				if ge < 0 or sim.s.at == ge: sim.won = true
				else: sim.dead = true   # wrong exit
			elif e == "list":
				if sim.s.message.begins_with("STAGE CLEAR"): sim.won = true
				else: sim.dead = true
			if sim.s.two == null:
				if not sim.won: sim.dead = true
				return
			if life(sim) <= 0: sim.dead = true
			_advance_wp(sim)

func _advance_wp(sim: Sim) -> void:
	var wps: Array = cfg.waypoints
	if sim.wi >= wps.size(): return
	var p := sim.s.two.world_of(0)
	var w: Array = wps[sim.wi]
	var tx: int = int(w[2]) if w.size() > 2 else 16
	var ty: int = int(w[3]) if w.size() > 3 else 4096
	if absi(p.x - int(w[0])) <= tx and absi(p.y - int(w[1])) <= ty:
		sim.wi += 1
		sim.best_wi = maxi(sim.best_wi, sim.wi)

func score(sim: Sim) -> float:
	if sim.dead: return -1e9
	if sim.won: return 1e8 + life(sim) * 1000.0 - sim.s.tick
	var wps: Array = cfg.waypoints
	var sc := sim.wi * 4000.0
	if sim.wi < wps.size():
		var p := sim.s.two.world_of(0)
		var w: Array = wps[sim.wi]
		sc -= absf(p.x - float(w[0])) + absf(p.y - float(w[1])) * float(cfg.get("y_weight", 1.0))
	sc += life(sim) * float(cfg.get("life_weight", 60.0))
	sc -= boss(sim) * float(cfg.get("boss_weight", 0.0))
	sc += sim.s.gear.energy * float(cfg.get("energy_weight", 0.0))
	return sc

func pick_action(sim: Sim, stuck: int) -> Array:
	var wps: Array = cfg.waypoints
	var p := sim.s.two.world_of(0)
	var dx := 0
	var dy := 0
	if sim.wi < wps.size():
		dx = int(wps[sim.wi][0]) - p.x
		dy = int(wps[sim.wi][1]) - p.y
	var fwd := 1 if dx > 0 else 2
	var back := 2 if dx > 0 else 1
	if absi(dx) <= 4: fwd = 0
	var fire: int = int(cfg.get("fire", 0x40))
	if rng.randf() < float(cfg.get("no_fire", 0.15)): fire = 0
	if cfg.has("suits") and rng.randf() < float(cfg.get("suit_rate", 0.02)):
		var want: int = int(cfg.suits[rng.randi() % cfg.suits.size()])
		var have: int = sim.s.two.pb2[0].suit
		if want != have and (want == 0 or sim.s.gear.energy > 0):
			var m2: Array = [[1, 16], [1, 0]]
			for _k in range((have - want + 5) % 5):
				m2.append([1, 4])
				m2.append([1, 0])
			m2.append_array([[1, 16], [24, 0]])
			return m2
	if cfg.has("macros") and rng.randf() < float(cfg.get("macro_rate", 0.05)):
		var m: Array = cfg.macros
		return m[rng.randi() % m.size()]
	var n: int = [8, 16, 24, 24, 32][rng.randi() % 5]
	var r := rng.randf()
	var w: Dictionary = cfg.get("weights", {})
	var jump_p: float = float(w.get("jump", 0.25)) + 0.2 * stuck
	if dy < -24: jump_p += float(w.get("up_jump", 0.2))
	var pad := 0
	if r < float(w.get("walk", 0.45)):
		pad = fwd | fire
	elif r < float(w.get("walk", 0.45)) + jump_p:
		pad = fwd | 0x80 | fire
		if rng.randf() < 0.15: pad = 0x80 | fire
	elif r < 0.85:
		pad = fire | (0x04 if dy > 24 and rng.randf() < 0.3 else 0)
	elif r < 0.93:
		pad = back | fire
	else:
		pad = back | 0x80 | fire
	if rng.randf() < float(w.get("net", 0.0)):
		var choice := rng.randi() % 3
		if choice == 0: pad = fwd | 0x80 | 0x08
		elif choice == 1: pad = 0x08 | fwd
		else: pad = 0x04 | 0x80
	if cfg.has("extra_pads") and rng.randf() < float(cfg.get("extra_rate", 0.1)):
		var ex: Array = cfg.extra_pads
		pad = int(ex[rng.randi() % ex.size()])
	return [[n - 1, pad], [1, pad & ~0xC0]]

func rollout() -> Dictionary:
	var sim := make()
	play(sim, cfg.get("prefix", []))
	var seg: Array = []
	var length := int(cfg.get("length", 200))
	var t0 := sim.s.tick
	var stuck := 0
	var last := sim.s.two.world_of(0) if sim.s.two != null else Vector2i.ZERO
	var marks: Array = []   # score after each action
	while sim.s.tick - t0 < length and not sim.dead and not sim.won:
		var act := pick_action(sim, stuck)
		play(sim, act)
		seg.append_array(act)
		if sim.s.two != null:
			var now := sim.s.two.world_of(0)
			stuck = stuck + 1 if (absi(now.x - last.x) + absi(now.y - last.y)) < 4 else 0
			stuck = mini(stuck, 3)
			last = now
		marks.append([seg.size(), score(sim)])
	var desc := ""
	if sim.s.two != null:
		desc = "t=%d pos=%s life=%d wi=%d boss=%d en=%d" % [sim.s.tick, str(sim.s.two.world_of(0)), life(sim), sim.wi, boss(sim), sim.s.gear.energy]
	return {"wi": sim.wi, "score": score(sim), "seg": seg, "won": sim.won, "dead": sim.dead, "desc": desc, "marks": marks}
