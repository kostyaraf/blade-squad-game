extends SceneTree
## NPB-03/NPB-04: $B570 (area kind floor) and $A17A (off the foot of the
## screen) for Nova on her own maps.  Cartridge reference (emulator, stage 0
## area 5, idle): $04C6 stays $7F while the view climbs -- he rides the floor
## at line $29 -- and a jump lands back on it.
## NPB-05: the line $29 moves in PB3 ($CED2) and the hero reads it live.
## Cartridge reference, stage 1 area 0 (kind four): $29 starts at $69 and
## climbs a line every fourth frame to $7E, then sinks to $37 and back; the
## hero walking right from the start is killed by the ceiling at x $3B, and
## one who waits 130 frames first walks under it unharmed.
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
	# p1.0: the turned-about ceiling.
	s = session(7)
	var lo := 0xFF
	var hi := 0
	for t in range(400):
		s.advance(s.tick, [0])
		lo = mini(lo, s.two.host_pb2.water)
		hi = maxi(hi, s.two.host_pb2.water)
	check(hi == 0x7E and lo == 0x37, "p1.0 line swings $37..$7E, got %02X..%02X" % [lo, hi])
	s = session(7)
	var died := -1
	for t in range(10):
		s.advance(s.tick, [0])
	for t in range(80):
		if s.advance(s.tick, [Pad.RIGHT]) != "playing":
			died = t
			break
	check(died >= 20 and died <= 35, "p1.0 walking at once dies under the ceiling, at %d" % died)
	s = session(7)
	for t in range(130):
		s.advance(s.tick, [0])
	var alive := true
	for t in range(200):
		alive = alive and s.advance(s.tick, [Pad.RIGHT]) == "playing"
	check(alive and (s.two.pb2[0].x >> 8) > 0x60, "p1.0 waiting for the ceiling walks under it")
	print("pb3_pb2_area_kind_test: %s" % ("OK" if failures == 0 else "%d FAILED" % failures))
	quit(1 if failures else 0)
