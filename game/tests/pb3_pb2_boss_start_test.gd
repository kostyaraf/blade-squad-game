extends SceneTree
## SPB2-01: native $875D readiness and input-only guest entrance regression.
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: ", label)

func run() -> void:
	# Isolated readiness fixtures are module evidence, not playthroughs.
	for native_pic in [0, 1]:
		for guest in [false, true]:
			var world := Pb2Objects.new(Pb2Level.new(6, 0))
			world.slots[0][Pb2Objects.F_KIND] = native_pic
			world.guest_drawn = guest
			var trigger: PackedByteArray = world.slots[6]
			trigger[Pb2Objects.F_STATE] = 1
			world._hold_boss(trigger)
			var ready: bool = native_pic != 0 or guest
			check(trigger[Pb2Objects.F_STATE] == (2 if ready else 1),
				"native/guest readiness " + str([native_pic, guest]))
			check(not ready or world.playing == 4, "ready entrance starts meter pause")
	for kinds in [[0], [1], [1, 1], [0, 1], [1, 0]]:
		var session := Pb3Session.new(kinds)
		session.at = session.records().find([0, 6, 0])
		check(session.enter(), "normal p6.0 entrance " + str(kinds))
		var words := []
		for _hero in kinds: words.append(0)
		var full := false
		var seen := false
		for _frame in range(200):
			var event := session.advance(session.tick, words)
			if event != "playing": break
			var world := session.two.host_pb2
			var boss: PackedByteArray = world.slots[int(world.cfg_boss.slot)]
			if boss[Pb2Objects.F_TYPE] == 0x50:
				seen = true
				if boss[Pb2Objects.F_LIFE] == int(world.cfg_boss.mid_life[0]):
					full = true
		check(seen and full, "ordinary input fills boss HP " + str(kinds))
		var world := session.two.host_pb2
		var trigger_present := false
		for row in world.slots:
			if row[Pb2Objects.F_TYPE] == 5: trigger_present = true
		check(not trigger_present, "filled meter removes trigger " + str(kinds))
		if session.two.host < 0:
			check(world.slots[0][Pb2Objects.F_LIFE] == 0,
				"guest readiness keeps dummy non-colliding " + str(kinds))
			session.two.gone.fill(true)
			session.two._pb2_living_target()
			check(not world.guest_drawn, "dead party cannot signal sprite readiness")
		session.leave()
	print("%d of %d PB2 boss start checks failed" % [failures, checks])
	quit(1 if failures else 0)
