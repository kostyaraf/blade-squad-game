extends SceneTree
## Search controller sequences by replaying each candidate from its normal entry.
## No changes to player, objects, health or positions.
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(cfg.prefix))
	var results: Array = []
	for pattern in cfg.patterns:
		var s := Pb3Session.new([0])
		s.at = int(rec.entry)
		s.enter()
		var events: Array = []
		for part in rec.steps + pattern:
			if s.two == null: break
			for f in range(int(part[0])):
				if s.two == null: break
				var event := s.advance(s.tick, [int(part[1])])
				if event != "playing": events.append({"tick":s.tick,"event":event,"entry":s.at,"message":s.message})
		var result := {"tick":s.tick,"entry":s.at,"message":s.message,"events":events,"alive":s.two != null}
		if s.two != null:
			var p: Pb2Player = s.two.pb2[0]
			var w: Pb2Objects = s.two.host_pb2
			result.merge({"pos":[s.two.world_of(0).x,s.two.world_of(0).y],"sub":p.sub,"charge":p.charge,"state":p.state,"hp":w.slots[0][Pb2Objects.F_LIFE],"suit":p.suit,"energy":s.gear.energy,"boss":[],"enemies":[],"view":[s.two.view_x(),s.two.eye.pos if s.two.pb2v.vertical else 0]})
			for n in range(Pb2Objects.FIRST_LIVE,Pb2Objects.SLOTS):
				var row: PackedByteArray = w.slots[n]
				if row[Pb2Objects.F_TYPE] == 0: continue
				var info := [row[Pb2Objects.F_TYPE],row[Pb2Objects.F_LIFE],row[Pb2Objects.F_X],row[Pb2Objects.F_Y],row[Pb2Objects.F_STATE],row[Pb2Objects.F_SELF]]
				result.enemies.append(info)
				if row[Pb2Objects.F_TYPE] >= 0x50: result.boss.append(info)
		results.append(result)
		s.leave()
	var out := FileAccess.open(cfg.output,FileAccess.WRITE)
	out.store_string(JSON.stringify(results))
	print("Input trials: ", results.size())
	quit()
