extends SceneTree
## Isolated regressions, not full-level completion.
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: ", label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for stage in [10,11]:
		for heroes in [[0],[1],[0,0],[1,1],[0,1],[1,0]]:
			var s := Pb3Session.new(heroes)
			s.at = 63 + stage
			s.enter()
			var draw := Pb3Draw.new(s.two)
			var phases := {}
			var native_phases := {}
			var pads: Array = [0] if heroes.size()==1 else [0,0]
			for f in range(32):
				s.advance(s.tick,pads)
				draw.after_step(s.gear)
				phases[draw.banks[2]] = true
				native_phases[s.two.host_script.g(0x41)&254] = true
				check(draw.banks[2] == (s.two.host_script.g(0x41)&254), "script CHR reaches renderer " + str([stage,heroes,f]))
			check(phases.size()==4 and native_phases.size()==4,"four visible phases " + str([stage,heroes,phases,native_phases]))
			var frozen := draw.banks.duplicate()
			var menu: Array = [Pad.START] if heroes.size()==1 else [Pad.START,0]
			s.advance(s.tick,menu)
			for f in range(20):
				s.advance(s.tick,pads)
				draw.after_step(s.gear)
				check(draw.banks.slice(0,4)==frozen.slice(0,4),"menu freezes CHR")
			s.advance(s.tick,menu)
			var resumed := {}
			for f in range(20):
				s.advance(s.tick,pads)
				draw.after_step(s.gear)
				resumed[draw.banks[2]]=true
			check(resumed.size()==4,"CHR resumes after menu")
			s.leave()
	for stage in range(20):
		var session := Pb3Session.new([1])
		session.at = 63+stage
		session.enter()
		var original: Array = session.two.solv.banks.duplicate()
		check(original == SolLevel.new(stage).banks,"fresh stage has initial CHR "+str(stage))
		for f in range(16):
			session.advance(session.tick,[0])
			var draw := Pb3Draw.new(session.two)
			for bank in range(2):
				check(draw.banks[bank*2]==(session.two.host_script.g(0x40+bank)&254),"all-stage CHR propagation")
		session.leave()
	animated_cells()
	for heroes in [[0],[0,1],[1,0],[0,0]]:
		crates(heroes)
	fast_beam()
	spawn_floor()
	orbit_crate()
	print("%d of %d Sol environment checks failed" % [failures,checks])
	quit(1 if failures else 0)

func crates(heroes: Array) -> void:
	var owner: int = heroes.find(0)
	for suit in range(5):
		var s := Pb3Session.new(heroes)
		s.at = 63
		s.two = Pb3Pair.new(1,0,0,heroes)
		s.two.begin([Vector2i(612,415)] if heroes.size()==1 else [Vector2i(612,415),Vector2i(612,415)],true)
		s.gear = Pb3Gear.new(heroes)
		s.prepare()
		# Diagnostic placement; use real menu input, then a standing shot at the crate.
		advance_owner(s,owner,Pad.START)
		advance_owner(s,owner,0)
		for n in range(suit):
			advance_owner(s,owner,Pad.UP)
			advance_owner(s,owner,0)
		advance_owner(s,owner,Pad.START)
		for f in range(20): advance_owner(s,owner,0)
		check(s.two.pb2[owner].suit==suit,"equipment selection "+str(suit))
		var tile: int = s.two.solv.raw_at(648,392)
		check(s.two.solv.whole(tile),"crate initially whole "+str(suit))
		var original_map: PackedByteArray = s.two.solv.map_image.get_data()
		var broke := false
		for f in range(30):
			advance_owner(s,owner,Pad.B)
			if not broke and not s.two.solv.whole(tile):
				broke = true
				check(s.two.host_sol.z7c==1,"one native crate drop")
				check(s.two.solv.map_image.get_data()!=original_map,"destroyed crate repainted")
		check(broke,"weapon hits actual crate "+str([heroes,suit]))
		var drops: int = s.two.host_sol.z7c
		for f in range(30): advance_owner(s,owner,Pad.B)
		check(s.two.host_sol.z7c==drops,"no repeated drops from destroyed crate")
		check(not s.two.solv.whole(tile),"suit breaks crate "+str(suit))
		s.leave()

func advance_owner(s: Pb3Session, owner: int, pad: int) -> void:
	var pads: Array = [0] if s.kinds.size()==1 else [0,0]
	pads[owner]=pad
	s.advance(s.tick,pads)

func animated_cells() -> void:
	var atlas: Image = Nes.sheet("sol").get_image()
	var cols: int = atlas.get_width()/8
	for stage in [10,11]:
		var level := SolLevel.new(stage)
		var found := {}
		for cell in range(level._metatile.size()):
			var x: int = (cell%256)*16
			var y: int = (cell/256)*16
			var collision := level.collision_at(x,y)
			var category := "belt" if collision in [0x16,0x17] else ("fire" if (collision&8)!=0 and (collision&0x1C)!=0x0C else "")
			if category=="" or found.has(category): continue
			var phases := {}
			for base in SolScript.data.chr_b:
				var pixels := PackedByteArray()
				for dy in range(16):
					for dx in range(16):
						var tile: int = level.map_image.get_pixel((x+dx)/8,(y+dy)/8).r8
						var bank: int = (int(base)&254)+tile/64-2 if tile>=128 else int(level.banks[tile/64])
						var index := bank*64+tile%64
						pixels.append(atlas.get_pixel((index%cols)*8+dx%8,(index/cols)*8+dy%8).r8)
				phases[pixels.hex_encode()]=true
			if phases.size()==4:
				found[category]=true
				print("animated ",stage," ",category," cell ",Vector2i(x,y))
		check(found.has("belt"),"actual conveyor pixels animate stage "+str(stage))
		check(found.has("fire"),"actual fire pixels animate stage "+str(stage))

func orbit_crate() -> void:
	var s := Pb3Session.new([0])
	s.at=63
	s.two=Pb3Pair.new(1,0,0,[0])
	s.two.begin([Vector2i(612,415)],true)
	s.gear=Pb3Gear.new([0])
	s.prepare()
	for f in range(2): s.advance(s.tick,[0])
	var w: Pb2Objects = s.two.things[0]
	var row := Pb2Objects.empty_row()
	row[Pb2Objects.F_X]=648-s.two.view_x()
	row[Pb2Objects.F_Y]=392-s.two.line_at(0)
	row[Pb2Objects.F_XHI]=255
	var before := s.two.solv.present.duplicate()
	w._orbit_sweep(4,row)
	check(s.two.solv.present==before,"offscreen satellite cannot hit wrapped terrain")
	row[Pb2Objects.F_XHI]=0
	w._orbit_sweep(4,row)
	check(not s.two.solv.whole(116),"satellite destroys foreign crate")
	check(s.two.host_sol.z7c==1,"satellite native drop")
	w._orbit_sweep(4,row)
	check(s.two.host_sol.z7c==1,"satellite cannot duplicate drop")
	# All non-breakable tiles remain intact even when a suit weapon touches them.
	for cell in range(s.two.solv._metatile.size()):
		var tile: int = s.two.solv._metatile[cell]
		var prop: int = s.two.solv.props[tile]&31
		if prop<16: continue
		var was: bool = s.two.solv.whole(tile)
		SolSat.break_at(s.two.host_sol,(cell%256)*256,(cell/256)*256)
		check(s.two.solv.whole(tile)==was,"weapon respects solid non-breakable terrain")
		break
	s.leave()

func spawn_floor() -> void:
	for heroes in [[0],[0,1],[1,0],[0,0]]:
		var s := Pb3Session.new(heroes)
		s.at=74
		s.enter()
		var owner: int=heroes.find(0)
		var start := s.two.world_of(owner)
		check(start.y==895,"Nova spawn above Stage12 floor "+str(heroes))
		for f in range(20): advance_owner(s,owner,Pad.RIGHT)
		check(s.two.world_of(owner).x>start.x,"walk from Stage12 entry without jump "+str(heroes))
		s.leave()

func fast_beam() -> void:
	var s := Pb3Session.new([0])
	s.at=63
	s.two=Pb3Pair.new(1,0,0,[0])
	s.two.begin([Vector2i(612,415)],true)
	s.gear=Pb3Gear.new([0])
	s.prepare()
	for f in range(2): s.advance(s.tick,[0])
	var w: Pb2Objects=s.two.things[0]
	var row := Pb2Objects.empty_row()
	row[Pb2Objects.F_TYPE]=3
	row[Pb2Objects.F_X]=648-s.two.view_x()
	row[Pb2Objects.F_Y]=382-s.two.line_at(0)
	row[Pb2Objects.F_VY]=20
	row[Pb2Objects.F_SELF]=3
	row[Pb2Objects.F_HOLD]=2
	w.slots[1]=row
	w._beam_step(1)
	check(not s.two.solv.whole(116),"fast downward beam cannot skip crate")
	check(row[Pb2Objects.F_TYPE]==3 and row[Pb2Objects.F_HOLD]==1,"beam keeps native penetration and lifetime")
	s.leave()
