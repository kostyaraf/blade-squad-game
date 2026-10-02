extends SceneTree
## Terminal-room fixtures; input-only playthroughs are recorded separately.
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: ", label)

func placed(stage: int, area: int, kinds: Array, offset: int = 0) -> Pb3Session:
	var s := Pb3Session.new(kinds)
	s.at = s.records().find([0, stage, area])
	s.two = Pb3Pair.new(0, stage, area, kinds)
	var spots := []
	var gate: Dictionary
	for record in s.two.pb2v.spawns:
		if int(record.type) == 3:
			gate = record
	for i in range(kinds.size()):
		spots.append(Vector2i(int(gate.along) * 16 + (offset if i == 1 else 0),
			int(gate.across) - (1 if kinds[i] == 0 else 0)))
	s.two.begin(spots, true)
	s.gear = Pb3Gear.new(kinds)
	s.prepare()
	return s

func gate_state(s: Pb3Session) -> int:
	for row in s.two.host_pb2.slots:
		if row[Pb2Objects.F_TYPE] == 3:
			return row[Pb2Objects.F_STATE]
	return -1

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--oracle="):
			var cases: Array = JSON.parse_string(FileAccess.get_file_as_string(arg.substr(9)))
			check(not cases.is_empty(), "NES oracle has executed calls")
			var native := Pb2Objects.new(Pb2Level.new(0,4))
			for case in cases:
				var gate: PackedByteArray = native.slots[6]
				gate[Pb2Objects.F_TYPE] = int(case.kind)
				gate[Pb2Objects.F_STATE] = int(case.state)
				gate[Pb2Objects.F_MARK] = int(case.mark)
				native.slots[0][Pb2Objects.F_MARK] = int(case.hero_mark)
				native.broken = int(case.switch)
				native.pad_held = int(case.pad)
				native._trip(6, native.slots[0], native.pad_held, true)
				check(gate[Pb2Objects.F_STATE] == int(case.expected_state)
					and gate[Pb2Objects.F_MARK] == int(case.expected_mark),
					"NES $B5A5 " + str(case))
	for site in [[0,4],[1,3],[2,2],[3,4]]:
		for kinds in [[0],[1],[0,0],[1,1],[0,1],[1,0]]:
			# Either controller can initiate the transition in every ordering.
			for owner in range(kinds.size()):
				var s := placed(site[0], site[1], kinds)
				var pads := []
				for i in range(kinds.size()): pads.append(Pad.UP if i == owner else 0)
				var event := "playing"
				for _frame in range(140):
					event = s.advance(s.tick, pads)
					if event != "playing": break
				check(event == "changed" and s.two != null
					and s.two.stage == 6 and s.two.area == site[0] + 6,
					"native gate destination " + str([site,kinds,owner,event]))
				s.leave()

	# Remote partner's UP must not activate the actor standing at the gate.
	for kinds in [[0,1],[1,0],[0,0],[1,1]]:
		var s := placed(0,4,kinds,64)
		for _frame in range(12): s.advance(s.tick,[0,Pad.UP])
		check(gate_state(s) == 1, "no borrowed input " + str(kinds))
		for _frame in range(3): s.advance(s.tick,[Pad.UP,0])
		check(gate_state(s) > 1, "local input enters " + str(kinds))
		s.leave()

	# A level switch is never UP, even with exactly the same bit set.
	for kind in [0,1]:
		var s := placed(0,4,[kind])
		s.two.host_pb2.broken = 8
		for _frame in range(10): s.advance(s.tick,[0])
		check(gate_state(s) == 1, "switch is not controller " + str(kind))
		check(s.two.host_pb2.broken == 8, "input does not overwrite switches")
		s.leave()

	# Ineligible guest poses do not bypass the native standing requirement.
	var s := placed(0,4,[1])
	var hero: SolPlayer = s.two.sol[0]
	check(s.two._pb2_gate_ready(0), "idle Solbrain can enter")
	hero.state = SolPlayer.ST_AIR
	check(not s.two._pb2_gate_ready(0), "air cannot enter")
	hero.state = SolPlayer.ST_CROUCH
	check(not s.two._pb2_gate_ready(0), "crouch cannot enter")
	hero.state = SolPlayer.ST_GROUND
	hero.scripted = 1
	check(not s.two._pb2_gate_ready(0), "punch cannot enter")
	hero.scripted = 0
	hero.bridge_slide = true
	check(not s.two._pb2_gate_ready(0), "slide cannot enter")
	hero.bridge_slide = false
	s.two.climbers[0] = Pb2Player.new(s.two.pb2v)
	check(not s.two._pb2_gate_ready(0), "ladder cannot enter")
	s.leave()

	# $A61D reads held RIGHT, independently of the persistent $3B switch.
	var world := Pb2Objects.new(Pb2Level.new(0,0))
	var platform := PackedByteArray()
	platform.resize(Pb2Objects.FIELDS)
	world.broken = 1
	world.pad_held = 0
	world._hold_0b(platform)
	check(world.slots[0][Pb2Objects.F_XFR] == 0x80, "platform ignores level switch")
	world.broken = 0
	world.pad_held = Pad.RIGHT
	world._hold_0b(platform)
	check(world.slots[0][Pb2Objects.F_XFR] == 0, "platform reads held direction")
	# The lever and breakable blocks write the same native byte $3B.
	world.broken = 0
	var lever: PackedByteArray = world.slots[6]
	lever[Pb2Objects.F_TYPE] = 0x0D
	lever[Pb2Objects.F_LIFE] = 3
	for _frame in range(65): world._mind_0d(6, lever)
	check(world.broken == 8, "lever updates the shared block-state byte")
	lever[Pb2Objects.F_TYPE] = 0x0D
	lever[Pb2Objects.F_STATE] = 0
	world.slots[6] = lever
	world._mind_0d(6, lever)
	check(world.slots[6][Pb2Objects.F_TYPE] == 0, "spent lever reads shared block state")
	print("%d of %d boss gate checks failed" % [failures, checks])
	quit(1 if failures else 0)
