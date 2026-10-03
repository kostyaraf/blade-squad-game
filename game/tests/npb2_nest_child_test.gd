extends SceneTree
## NPB2-40: native nest $1B hands a live, animated child to the regular sweep.
## This fixture checks spawning/dispatch/expiry, not room completion.
var failed := 0
var checks := 0

func check(ok: bool, what: String) -> void:
	checks += 1
	if not ok:
		failed += 1
		print("FAIL ", what)

func _initialize() -> void:
	var world := Pb2Objects.new(Pb2Level.new(1, 7))
	var hero: PackedByteArray = world.slots[0]
	hero[Pb2Objects.F_X] = 110
	hero[Pb2Objects.F_Y] = 80
	hero[Pb2Objects.F_LIFE] = 16
	var nest: PackedByteArray = world.slots[14]
	nest[Pb2Objects.F_TYPE] = 0x1B
	nest[Pb2Objects.F_MARK] = 0x80
	nest[Pb2Objects.F_STATE] = 1
	nest[Pb2Objects.F_X] = 100
	nest[Pb2Objects.F_Y] = 80
	world.turns()
	var child: PackedByteArray = world.slots[6]
	check(child[Pb2Objects.F_TYPE] == 0x1C, "nest spawned child in native pool")
	check(child[Pb2Objects.F_STATE] == 0, "child waits until next sweep")
	check(nest[Pb2Objects.F_STATE] == 2, "nest enters cooldown")
	world.turns()
	check(child[Pb2Objects.F_STATE] == 1, "registered child enters falling state")
	check(child[Pb2Objects.F_LIFE] == 1, "child receives native HP")
	check(child[Pb2Objects.F_MARK] == 1, "child becomes visible")
	check(child[Pb2Objects.F_KIND] != 0, "child has native animation")
	check(child[Pb2Objects.F_VX] == 1, "child walks towards hero on right")
	check(child[Pb2Objects.F_VY] == 1, "child starts falling at one pixel")
	child[Pb2Objects.F_STATE] = 3
	child[Pb2Objects.F_COUNT] = int(world.nest_child_1c_cfg["burst_ticks"])
	world.start_anim(child, int(world.nest_child_1c_cfg["burst_anim"]))
	for _tick in range(15):
		world.turns()
	check(world.slots[6][Pb2Objects.F_TYPE] == 0x1C, "burst lives for first fifteen ticks")
	world.turns()
	check(world.slots[6] == Pb2Objects.empty_row(), "sixteenth burst tick releases complete slot")
	print("NPB2-40: ", failed, " / ", checks, " checks failed")
	quit(1 if failed else 0)
