extends SceneTree
## Input-only route exploration. Replays normal menu entries and reports
## outcomes; candidates still require visual replay in playthrough.gd.
func _initialize() -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var results: Array = []
	for c in cfg.cases:
		var s := Pb3Session.new([1])
		s.at = int(c.get("entry", 5))
		s.enter()
		var steps: Array = []
		var events: Array = []
		var samples: Array = []
		for part in c.get("steps", []):
			var consumed := 0
			for _f in range(int(part[0])):
				if s.two == null: break
				var e := s.advance(s.tick, [int(part[1])])
				consumed += 1
				if e != "playing": events.append({"tick":s.tick,"entry":s.at,"event":e,"message":s.message})
				if s.tick % 100 == 0: samples.append(snapshot(s))
			if consumed > 0: steps.append([consumed,int(part[1])])
			if s.two == null: break
		if c.has("lift_policy"):
			var opts: Dictionary = c.lift_policy
			var policy_entry := s.at
			var air_ticks := 0
			var crossed: bool = bool(opts.get("crossed", false))
			for k in range(int(opts.get("frames", 3800))):
				if s.two == null: break
				var h: SolPlayer = s.two.sol[0]
				var p: Vector2i = s.two.world_of(0)
				if p.y < 250 and p.x > 200: crossed = true
				var target: int = 52 if k < int(opts.get("cross_at",540)) else 216
				if crossed: target = 56 if p.y >= int(opts.get("upper_cross_y", 144)) else 240
				if k < int(opts.get("guard_right",0)): target = 216
				var pad := 0
				if p.x < target-1: pad |= 1
				elif p.x > target+1: pad |= 2
				if h.state in [0,2]:
					air_ticks = 0
					if (h.pad_held & 128) == 0: pad |= 128
				else:
					air_ticks += 1
					if air_ticks < int(opts.get("hold",24)): pad |= 128
				if air_ticks == int(opts.get("shoot_at",20)): pad |= 64
				if opts.has("shoot_every") and k % int(opts.shoot_every) == 0: pad |= 64
				var e := s.advance(s.tick,[pad])
				if not steps.is_empty() and int(steps[-1][1]) == pad: steps[-1][0] += 1
				else: steps.append([1,pad])
				if e != "playing": events.append({"tick":s.tick,"entry":s.at,"event":e,"message":s.message})
				if s.tick % 100 == 0: samples.append(snapshot(s))
				if s.at != policy_entry: break
		var result := snapshot(s)
		result["name"] = c.name
		result["replay"] = {"entry":c.get("entry",5),"heroes":[1],"steps":steps,"events":events}
		result["samples"] = samples
		results.append(result)
		print(c.name, ": ", JSON.stringify(snapshot(s)))
		s.leave()
	var f := FileAccess.open(cfg.out,FileAccess.WRITE)
	f.store_string(JSON.stringify(results))
	quit(0)

func snapshot(s: Pb3Session) -> Dictionary:
	var out := {"tick":s.tick,"entry":s.at,"message":s.message}
	if s.two == null: return out
	var p: Vector2i = s.two.world_of(0)
	out.merge({"x":p.x,"y":p.y,"hp":s.two.sol[0].suit,"state":s.two.sol[0].state,"view":[s.two.view_x(),s.two.eye.pos if s.two.pb2v.vertical else 0]})
	var h: SolPlayer = s.two.sol[0]
	out["gun"] = s.gear.gun[0]
	out["energy"] = s.gear.energy
	var o: SolObjects = s.two.guest_pool[0]
	out["sat"] = {"id":o.id[SolObjects.SAT],"life":o.life[SolObjects.SAT],"mind":o.mind[SolObjects.SAT]}
	out["hero"] = {"scripted":h.scripted,"pad":h.pad_held,"timer":h.timer,"speed":h.speed,"rise":h.rise,"vy":h.vy,"pose":h.pose,"hold":h.hold,"hurt":h.hurt}
	var enemies: Array = []
	for n in range(Pb2Objects.FIRST_LIVE,Pb2Objects.SLOTS):
		var r: PackedByteArray = s.two.host_pb2.slots[n]
		if r[0] != 0: enemies.append([r[0],r[7],r[12],r[9]])
	out["enemies"] = enemies
	var rows: Array = []
	for n in range(Pb2Objects.FIRST_LIVE,Pb2Objects.SLOTS):
		var r: PackedByteArray = s.two.host_pb2.slots[n]
		if r[Pb2Objects.F_TYPE] != 0:
			rows.append({"slot":n,"type":r[Pb2Objects.F_TYPE],"life":r[Pb2Objects.F_LIFE],"state":r[Pb2Objects.F_STATE],"x":r[Pb2Objects.F_X],"y":r[Pb2Objects.F_Y]})
	out["rows"] = rows
	return out
