extends SceneTree
## SPB-03: the p0.5 elevator (area kind 5, $B570 -> $B5E7) is a solid box under
## the $29 line. The Power Blade hero stands on it at screen line 127 as the
## view climbs; Solbrain, a guest who lives in level lines, is carried up with it.
func _go(heroes: Array, ticks: int) -> Pb3Session:
	var session := Pb3Session.new(heroes)
	session.at = 5
	session.enter()
	var menu := [[1, 16], [1, 4], [1, 16]]
	for m in menu:
		for _n in range(m[0]):
			session.advance(session.tick, [m[1]])
	for _n in range(ticks):
		session.advance(session.tick, [0])
	return session

func _initialize() -> void:
	var failed := 0
	var nova := _go([0], 200)
	# $04C6 -- 127 on the lift; on a frame the view climbs he sinks to 128
	# and $0652 = $FF lifts him back, the cartridge does the same.
	for _n in range(16):
		nova.advance(nova.tick, [0])
		var y: int = nova.two.host_pb2.slots[0][Pb2Objects.F_Y]
		if y < 127 or y > 128:
			print("FAIL: Nova stands at screen line ", y, ", not 127")
			failed += 1
			break
	var s1 := _go([1], 40)
	var h: SolPlayer = s1.two.sol[0]
	var y1: int = s1.two.world_of(0).y
	for _n in range(160):
		s1.advance(s1.tick, [0])
	var y2: int = s1.two.world_of(0).y
	if h.state != SolPlayer.ST_GROUND:
		print("FAIL: Solbrain is not standing on the lift, state ", h.state)
		failed += 1
	if y1 - y2 < 18 or y1 - y2 > 22:
		print("FAIL: Solbrain rose ", y1 - y2, " in 160 ticks, the lift 20")
		failed += 1
	if s1.two.screen_of(0).y < 120 or s1.two.screen_of(0).y > 134:
		print("FAIL: Solbrain is at screen line ", s1.two.screen_of(0).y)
		failed += 1
	print("pb2 lift: ", failed, " failed")
	quit(1 if failed else 0)
