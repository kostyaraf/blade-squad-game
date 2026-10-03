extends SceneTree
## NPB2-20: p5.0 is passed by falling into the door with no buttons
## (cartridge: door touched at frame 1333, hero frozen at line $C3 until
## $1A := 6 at 1365). The hero must stop when $2A is set, not fall to death.
func _initialize() -> void:
	var failed := 0
	var session := Pb3Session.new([0])
	session.at = Pb3List.records().find([0, 5, 0])
	session.enter()
	var frozen_at := -1
	var y_frozen := -1
	var changed := -1
	for tick in range(400):
		var ev := session.advance(session.tick, [0])
		if ev == "changed":
			changed = session.tick
			break
		if ev != "playing":
			print("FAIL: %s at %d (%s)" % [ev, session.tick, session.message])
			failed += 1
			break
		var w: Pb2Objects = session.two.host_pb2
		var y: int = (session.two.pb2[0].y >> 8) & 0xFF
		if w.frozen != 0:
			if frozen_at < 0:
				frozen_at = session.tick
				y_frozen = y
			elif y != y_frozen:
				print("FAIL: moved while frozen at %d: %d -> %d" % [session.tick, y_frozen, y])
				failed += 1
				break
	if changed < 0 or session.at != Pb3List.records().find([0, 5, 1]):
		print("FAIL: no door into p5.1 (changed=%d at=%d)" % [changed, session.at])
		failed += 1
	# $86E7 counts $20 frames from the touch before $1A := 6 (1333 -> 1365).
	if frozen_at >= 0 and changed - frozen_at != 32:
		print("FAIL: door closing took %d ticks, cartridge 32" % (changed - frozen_at))
		failed += 1
	print("NPB2-20: frozen at %d (line %d), next area at %d; %d failed" % [frozen_at, y_frozen, changed, failed])
	session.leave()
	quit(1 if failed else 0)
