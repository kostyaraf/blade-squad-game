extends SceneTree
## NES OAM oracle and isolated live-session fixtures, not level completion.
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		if failures<20: print("FAIL: ",label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--oracle="):
			var cases: Array = JSON.parse_string(FileAccess.get_file_as_string(arg.substr(9)))
			var pool := SolObjects.new(SolLevel.new(0))
			for case in cases:
				var table := SolSprites.Table.new()
				table.oam = PackedByteArray(case.before)
				table.banks = PackedByteArray(case.banks)
				table.count=int(case.cursors[0]); table.turn=int(case.cursors[1])
				table.fwd=int(case.cursors[2]); table.back=int(case.cursors[3])
				pool.table=table
				pool.at_x[0]=int(case.x); pool.at_y[0]=int(case.y)
				pool.face[0]=int(case.face)
				SolMinds._aed9(pool,0,int(case.phase))
				check(table.oam==PackedByteArray(case.after),"NES OAM frame "+str(case.frame))
				check(PackedInt32Array([table.count,table.turn,table.fwd,table.back])==PackedInt32Array(case.want),"NES OAM cursors")
				check(table.banks==PackedByteArray(case.want_banks),"NES preserves CHR banks")
	for heroes in [[0],[1],[0,0],[1,1],[0,1],[1,0]]:
		integration(heroes)
	recorded_encounter()
	print("%d of %d hatch rendering checks failed"%[failures,checks])
	quit(1 if failures else 0)

func integration(heroes: Array) -> void:
	var s := Pb3Session.new(heroes)
	s.at=74
	s.two=Pb3Pair.new(1,11,0,heroes)
	var positions := []
	for h in heroes: positions.append(Vector2i(368,895 if h==0 else 896))
	s.two.begin(positions,true)
	s.gear=Pb3Gear.new(heroes)
	# Keep automatic satellites from killing the diagnostic hatch before it opens.
	for i in range(heroes.size()):
		if heroes[i]==1: s.gear.gun[i]=0
	s.prepare()
	# Isolated native type-3 hatch over the actual entry platform. Only the
	# initial placement is artificial; its opening and both births run normally.
	var host := s.two.host_sol
	for field in host._types[3]:
		host.get(field)[11]=int(host._types[3][field])
	host.id[11]=128
	host.cool[11]=255
	host.x[11]=400<<4
	host.y[11]=850<<4
	var pads: Array=[0] if heroes.size()==1 else [0,0]
	var born := {}
	var visible := 0
	var modes := {}
	var damaged := false
	for f in range(240):
		if s.two==null: break
		s.advance(s.tick,pads)
		if s.two==null: break
		var o:=s.two.host_sol
		for slot in range(12):
			if o.id[slot]==0 or (o.mind[slot]&63) not in [12,14]: continue
			born[slot]=true
			modes[o.mind[slot]&63]=true
			# These numbered pictures deliberately contain no visible sprites.
			# The native flat pair must still be present in the live host OAM.
			for at in range(32,256,4):
				if o.table.oam[at]<240 and o.table.oam[at+1] in [177,179,181]:
					visible += 1
		for i in range(heroes.size()):
			if s.two._health_sol(i)<(16 if heroes[i]==0 else 8): damaged=true
	print("hatch fixture ",heroes," children=",born.size()," visible=",visible," modes=",modes," damage=",damaged)
	check(born.size()>=2,"native hatch emits two children "+str(heroes))
	check(visible>0,"children draw in live OAM "+str(heroes))
	check(damaged,"visible children retain native contact damage "+str(heroes))
	check(modes.has(12) and modes.has(14),"both flight modes "+str(heroes))
	s.leave()

func recorded_encounter() -> void:
	var rec: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(
		"res://../docs/qa/solbrain-hatch/replay.json"))
	var s:=Pb3Session.new([0])
	s.at=int(rec.entry)
	s.enter()
	for part in rec.steps:
		for f in range(int(part[0])):
			if s.two==null: break
			s.advance(s.tick,[int(part[1])])
	check(s.two!=null,"recorded normal entry reaches hatch encounter alive")
	if s.two!=null:
		var children:=0
		var sprites:=0
		var o:=s.two.host_sol
		for slot in range(12):
			if o.id[slot]!=0 and o.mind[slot] in [12,14]: children+=1
		var draw:=Pb3Draw.new(s.two)
		for at in range(32,256,4):
			if draw.oam[at]<240 and draw.oam[at+1] in [177,179,181]: sprites+=1
		check(children==2 and sprites==4,"both real spawned children reach renderer")
	s.leave()
