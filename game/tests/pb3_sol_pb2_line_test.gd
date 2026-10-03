extends SceneTree
## SPB2-61: Solbrain on a PB2 map asks the map the way PB2 does in areas with
## a moving line ($AC1D kind 4, $B34A kinds 6/8/10).  Ordinary input only for
## the p1.0 walks; the line checks read the live room after it is entered.
var failed := 0

func check(ok: bool, what: String) -> void:
	if not ok:
		failed += 1
		print("FAIL ", what)

func walk(wait: int, ticks: int) -> Pb3Session:
	var s := Pb3Session.new([1])
	s.at = 7
	s.enter()
	for t in range(ticks):
		if s.two == null or s.advance(s.tick, [0 if t < wait else 1]) != "playing":
			break
	return s

func room(entry: int) -> Pb2AsSol:
	var s := Pb3Session.new([1])
	s.at = entry
	s.enter()
	s.advance(s.tick, [0])
	return s.two.solv as Pb2AsSol

func _initialize() -> void:
	# p1.0: straight on, the ceiling at line $69..$7E kills him (NES: $3B, +38).
	var s := walk(0, 120)
	check(s.two == null or s.two.gone[0], "p1.0 at once must die under the ceiling")
	# Waiting for the ceiling to rise lets him walk under it ($29 <= $71).
	s = walk(140, 420)
	check(s.two != null and not s.two.gone[0] and s.two.world_of(0).x >= 380, "p1.0 after the wait must pass the first spikes")
	# Kind 4 turned rows: with the line at $37 the spike row 96 is asked at 96+89-128.
	var a := room(7)
	a.live_line = 0x37
	check(not a.hurts_at(100, 100), "kind 4: under a raised ceiling is empty")
	check(a.hurts_at(100, 30), "kind 4: the turned spikes sit above the line")
	a.live_line = -1
	check(a.hurts_at(100, 100), "no line: the map as drawn")
	# Kind 6 (p1.5): below line - 4 + ... is the fall that kills.
	a = room(12)
	a.live_line = 0x60
	check(a.hurts_at(100, 0x60 - 16 + 4), "kind 6: at the line kills")
	check(not a.hurts_at(100, 0x60 - 16 + 3 - 8), "kind 6: above the line is safe")
	# Kind 10 (p6.1): water from the line down to $98.
	a = room(54)
	a.live_line = 0x50
	check(a.collision_at(100, 0x60 - 16) == Pb2AsSol.WATER or a.collision_at(100, 0x60 - 16) == Pb2AsSol.SOLID, "kind 10: water under the line")
	print("SPB2-61 line areas: ", failed, " failures")
	quit(1 if failed else 0)
