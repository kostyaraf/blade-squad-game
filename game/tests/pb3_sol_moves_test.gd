extends SceneTree
## Explicitly placed regressions; complete input-only room route is tested separately.
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print('FAIL: ',label)
func _initialize() -> void:
	call_deferred('run')
func placed(at: Vector2i, heroes: Array = [1]) -> Pb3Session:
	var s := Pb3Session.new(heroes)
	s.at = 1
	s.two = Pb3Pair.new(0,0,1,heroes)
	var places: Array = []
	for _hero in heroes: places.append(at)
	s.two.begin(places,true)
	s.gear = Pb3Gear.new(heroes)
	s.prepare()
	return s
func run() -> void:
	# Reproduce the reported door with walking input, independently for each hero.
	for hero in [0,1]:
		var s := placed(Vector2i(208,64),[hero])
		var changed := false
		for f in range(160):
			var event := s.advance(s.tick,[Pad.RIGHT])
			if event == 'changed':
				changed = s.at == 2
				break
			if event != 'playing': break
		check(changed,'walking reaches second-room exit hero='+str(hero))
		s.leave()
	# Climb motion/idle/jump and full-sized authored sprite tiles.
	var s := placed(Vector2i(56,128))
	var frames := {}
	for f in range(32):
		s.advance(s.tick,[Pad.UP])
		frames[s.two.sol[0].bridge_frame] = true
	check(frames.size() == 8 and not frames.has(-1),'climbing visits all eight authored poses')
	var frame: int = s.two.sol[0].bridge_frame
	var before := s.two.world_of(0)
	for f in range(10):
		s.advance(s.tick,[0])
		check(s.two.sol[0].bridge_frame == frame,'idle ladder holds pose')
	check(s.two.world_of(0) == before,'idle ladder holds position')
	# Descending must undo the visual phase by the actual distance travelled.
	var phase: int = s.two.sol[0].bridge_climb_distance
	var q: Pb2Player = s.two.climbers[0]
	var old_y: int = q.y
	s.advance(s.tick,[Pad.DOWN])
	var travelled: int = q.y - old_y
	check(travelled > 0,'ladder reverses to downward motion')
	check(s.two.sol[0].bridge_climb_distance == posmod(phase - travelled,32*256),
			'descending reverses distance-driven animation')
	var draw := Pb3Draw.new(s.two)
	var parts := 0
	for n in range(0,256,4):
		if draw.guest_oam[n] < 240 and (draw.guest_oam[n+2] & 0x10) != 0: parts += 1
	check(parts == 9,'ladder uses complete 24x48 art')
	s.advance(s.tick,[Pad.A])
	check(s.two.sol[0].bridge_frame == -1,'jump restores native art')
	s.leave()
	for case in ["enemy","block","armour","unbreakable","above"]:
		var target := 0x0C if case == "block" else 0x13
		s = placed(Vector2i(200,304))
		var h: SolPlayer = s.two.sol[0]
		h.face_left = true
		check(s.two._sol_traversal(0,Pad.DOWN|Pad.A|Pad.LEFT),'slide begins from floor')
		s.two._mirror_them()
		check(h.bridge_slide and h.bridge_frame == 0,'slide uses entry pose and attack')
		var a: Array = s.two.arms[0].filter(func(arm): return int(arm[3])==3)[0]
		var o := s.two.host_pb2
		var row := Pb2Objects.empty_row()
		row[Pb2Objects.F_TYPE] = target
		row[Pb2Objects.F_LIFE] = 3
		row[Pb2Objects.F_X] = int(a[0])
		row[Pb2Objects.F_Y] = int(a[1])
		row[Pb2Objects.F_MARK] = 0
		if case == "armour": row[Pb2Objects.F_MARK] = 0x20
		if case == "unbreakable": row[Pb2Objects.F_LIFE] = 0xFF
		if case == "above": row[Pb2Objects.F_Y] -= 64
		o.slots[17] = row
		# Whole contact sweep, including the live arm-spend callback.
		o.frame = 0
		o.contact()
		if case == 'block':
			check(row[Pb2Objects.F_STATE] == 2,'slide breaks low block')
		elif case == 'enemy':
			check(row[Pb2Objects.F_TYPE] == 1 and row[Pb2Objects.F_LIFE] == 0,'slide starts native enemy death')
		else:
			check(row[Pb2Objects.F_TYPE] == target and row[Pb2Objects.F_LIFE] == (255 if case=='unbreakable' else 3),'slide respects '+case)
		# Move through the low passage before releasing: a ceiling correctly
		# forces sliding until there is room to stand.
		for f in range(100): s.two._sol_traversal(0,Pad.LEFT|Pad.DOWN)
		for f in range(10): s.two._sol_traversal(0,0)
		s.two._arms_of(0)
		check(not s.two.arms_from[0].has([2,-1]),'no body attack outside moving slide')
		s.leave()
	# Appending custom CHR must preserve every native tile byte.
	var original := Image.new()
	original.load_png_from_buffer(FileAccess.get_file_as_bytes('res://data/sol/tiles.png'))
	original.convert(Image.FORMAT_R8)
	var atlas := Nes.sheet('sol').get_image()
	check(atlas.get_region(Rect2i(0,0,original.get_width(),original.get_height())).get_data()==original.get_data(),
			'original Solbrain CHR is unchanged')
	check(atlas.get_height()>original.get_height(),'authored frames appended to atlas')
	print('%d of %d traversal checks failed'%[failures,checks])
	quit(1 if failures else 0)
