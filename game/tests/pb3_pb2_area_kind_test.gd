extends SceneTree
## NPB-03/NPB-04: $B570 (area kind floor) and $A17A (off the foot of the
## screen) for Nova on her own maps.  Cartridge reference (emulator, stage 0
## area 5, idle): $04C6 stays $7F while the view climbs -- he rides the floor
## at line $29 -- and a jump lands back on it.
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", message)

func session(entry: int) -> Pb3Session:
	var s := Pb3Session.new([0])
	s.at = entry
	check(s.enter(), "enter %d" % entry)
	return s

func _initialize() -> void:
	# p0.5: the floor the screen carries.  Idle 40 ticks to settle, then the
	# hero's own line must stay put for 60 ticks while the view climbs.
	var s := session(5)
	for t in range(40):
		s.advance(s.tick, [0])
	var line: int = (s.two.pb2[0].y >> 8) & 0xFF
	var eye0: int = s.two.eye.pos
	for t in range(60):
		check(s.advance(s.tick, [0]) == "playing", "p0.5 alive while riding")
	check(s.two.eye.pos < eye0, "p0.5 view climbs by itself")
	check(absi(((s.two.pb2[0].y >> 8) & 0xFF) - line) <= 1, "p0.5 rides the floor")
	check(line == 0x7F, "p0.5 stands on line $29 ($7F), got %d" % line)
	# A jump comes back down onto the same carried floor.
	for t in range(20):
		s.advance(s.tick, [Pad.A])
	for t in range(60):
		s.advance(s.tick, [0])
	check(s.two != null and ((s.two.pb2[0].y >> 8) & 0xFF) == 0x7F, "p0.5 lands on the floor again")
	# $A17A: feet at $C7 or past it end the hero.
	var q: Pb2Player = s.two.pb2[0]
	q.y = 0xC7 << 8
	check(s.two._off_foot(0), "$C7 is off the foot")
	q.y = 0xC6 << 8
	check(not s.two._off_foot(0), "$C6 is still on screen")
	q.y = 0x011000
	check(s.two._off_foot(0), "a screen down is off the foot")
	print("pb3_pb2_area_kind_test: %s" % ("OK" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)
