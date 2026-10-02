extends SceneTree
## Input-only combat/render regressions plus explicitly placed hazard diagnostics.
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
	recorded_combat()
	hazard_diagnostics()
	foreign_target()
	print("%d of %d combat checks failed" % [failures, checks])
	quit(1 if failures else 0)

func recorded_combat() -> void:
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
			"res://../docs/qa/playthrough/s0-nova/replay.json"))
	var s := Pb3Session.new([0])
	s.at = 63
	check(s.enter(), "Nova enters Solbrain normally")
	var flashes := 0
	var visible := 0
	var damaged := false
	for part in rec.steps:
		for f in range(int(part[0])):
			if s.tick >= 7820:
				break
			check(s.advance(s.tick, [int(part[1])]) == "playing", "recorded input advances")
			if s.tick == 196:
				check(s.two.things[0].slots[0][Pb2Objects.F_LIFE] == 15,
						"enemy contact costs Nova health")
				damaged = true
				var board := Pb3Board.new()
				board.show_bar(s.gear, s.two)
				check("HP 15" in board._strip.text and "ENERGY 16" in board._strip.text,
						"HUD distinguishes health and energy")
				board.free()
			if s.tick >= 197 and s.tick < 207:
				var draw := Pb3Draw.new(s.two)
				var found := false
				for at in range(0, draw.guest_oam.size(), 4):
					found = found or draw.guest_oam[at] < 240
				if found: visible += 1
				else: flashes += 1
		check(s.two != null, "Nova remains alive")
	check(damaged and flashes > 0 and visible > 0, "guest visibly flashes after damage")
	var o := s.two.host_sol
	check(o.s_kind[15] == 0xAD, "enemy fires actual projectile during recorded play")
	check(o.table == s.two.host_table, "flat projectiles share the displayed table")
	var sx := ((o.s_x[15] - o.cam_x - 0x40) & 0xFFFF) >> 4
	var sy := ((o.s_y[15] - o.cam_y - 0x40) & 0xFFFF) >> 4
	var found := false
	for at in range(0, o.table.oam.size(), 4):
		if o.table.oam[at] == sy and o.table.oam[at+1] == 0xFF \
				and o.table.oam[at+3] == sx:
			found = true
	check(found, "native $B4AB projectile tile reaches displayed OAM at actual coordinates")
	print("input-only s0 Nova: damage, flashing and projectile at tick ", s.tick)
	s.leave()

func hazard_diagnostics() -> void:
	# Actual spike tile in Solbrain s1. Artificial placement isolates damage;
	# it is not a claim of reaching this tile in a completed playthrough.
	for kind in [0, 1]:
		var s := Pb3Session.new([kind])
		s.two = Pb3Pair.new(1, 1, 0, [kind])
		s.two.begin([Vector2i(1960, 687 if kind == 0 else 688)], true)
		s.gear = Pb3Gear.new([kind])
		s.prepare()
		var initial: int = s.two._health_sol(0)
		for tick in range(113):
			s.advance(s.tick, [0])
			check(s.two._health_sol(0) == initial - (2 if tick == 112 else 1),
					"terrain damage and native 112-frame grace hero=%d tick=%d" % [kind,tick])
		s.leave()
	# The adapter must retain the native classification for all 32 properties.
	var level := SolLevel.new(1)
	var adapted := SolAsPb2.new(level)
	var native := SolPlayer.new(level)
	for bits in range(32):
		# Change one diagnostic cell's property; no production map is modified.
		var tile: int = level.raw_at(1960, 688)
		level._coll[tile] = bits
		native.suit = 8
		native.timer = 255
		native._react((bits << 3) & 255)
		check(adapted.hurts_at(1960, 688) == (native.suit < 8),
				"foreign hazard matches native classifier %02X" % bits)


func foreign_target() -> void:
	for heroes in [[1], [1,1], [0,1]]:
		var s := Pb3Session.new(heroes)
		s.at = 45
		s.enter()
		if heroes[0] == 0:
			# Diagnostic: a surviving guest must also replace a defeated host.
			s.two.gone[0] = true
			s.two.things[0].slots[0][Pb2Objects.F_LIFE] = 0
			s.two._mirror_them()
		var target := 1 if heroes[0] == 0 else 0
		for frame in range(120):
			var at := s.two.screen_of(target)
			var row: PackedByteArray = s.two.host_pb2.slots[0]
			check(row[Pb2Objects.F_X] == at.x and row[Pb2Objects.F_Y] == at.y,
					"PB2 AI targets living guest " + str(heroes))
			check(row[Pb2Objects.F_LIFE] == 0, "AI proxy cannot take duplicate contact hits")
			s.advance(s.tick, [0] if heroes.size()==1 else [0,0])
		s.leave()
