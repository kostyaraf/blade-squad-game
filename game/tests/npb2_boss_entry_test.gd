extends SceneTree
## NPB2-01: actual menu entries must call all four cartridge end bosses.
func _initialize() -> void:
	var failed := 0
	for area in range(6, 10):
		var session := Pb3Session.new([0])
		session.at = Pb3List.records().find([0, 6, area])
		session.enter()
		for tick in range(5):
			session.advance(session.tick, [0])
		var world: Pb2Objects = session.two.host_pb2
		# $87C3: $56 + the stage kept by the door ($84FE).
		var actual: int = world.slots[15][Pb2Objects.F_TYPE]
		if actual != 0x56 + area - 6 or world.boss != 1:
			failed += 1
			print("FAIL p6.%d: type=%02X boss=%d" % [area, actual, world.boss])
		session.leave()
	print("NPB2-01: %d boss entries failed" % failed)
	quit(1 if failed else 0)
