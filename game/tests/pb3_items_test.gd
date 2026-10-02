extends SceneTree
## Предметы PB3 (размещённый стенд): кто получает то, что выпало, и где оно
## появляется.  Каждый случай собирает пару прямо у места на уровне.

var failed := 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, what: String) -> void:
	if not ok:
		failed += 1
		printerr("FAIL: ", what)


func stand(at: int, game: int, area: int, kinds: Array, spots: Array) -> Pb3Session:
	var s := Pb3Session.new(kinds)
	s.at = at
	s.two = Pb3Pair.new(game, 0, area, kinds)
	s.two.begin(spots, true)
	s.gear = Pb3Gear.new(kinds)
	s.prepare()
	return s


func items(o: SolObjects) -> Array:
	var r := []
	if o == null:
		return r
	for n in range(0x0C):
		if o.id[n] != 0:
			r.append(o.mind[n])
	return r


## ITM-01 -- s0: the bonus cube at (640,384) punched by each Solbrain of
## each pair.  What comes out is the stage's: it is in the stage's pool, the
## one that is drawn and touched, and the striker's own pool holds nothing.
func cube_item_is_the_stages() -> void:
	for kinds in [[1], [1, 1], [0, 1], [1, 0]]:
		for puncher in range(kinds.size()):
			if kinds[puncher] != 1:
				continue
			var spots := []
			for i in range(kinds.size()):
				spots.append(Vector2i(634 if i == puncher else 590,
						415 if kinds[i] == 0 else 416))
			var s := stand(63, 1, 0, kinds, spots)
			var pads := []
			for i in kinds:
				pads.append(0)
			for t in range(40):
				s.advance(s.tick, pads)
			var p := pads.duplicate()
			p[puncher] = Pad.RIGHT
			s.advance(s.tick, p)
			for t in range(60):
				p[puncher] = Pad.B if (t % 8) < 2 else 0
				s.advance(s.tick, p)
			var tag := "%s puncher %d" % [str(kinds), puncher]
			check(not s.two.solv.whole(116), tag + ": the cube broke")
			check(items(s.two.host_sol).has(5), tag + ": the coin is in the stage's pool")
			if puncher != s.two.host:
				check(items(s.two.guest_pool[puncher]).is_empty(),
						tag + ": nothing is left in the striker's own pool")
			# And it can be taken: the one who broke it walks into it.
			var before: int = s.two.host_sol.hero_bonus
			# The coin settles over the step right of him; a short hop takes
			# him onto the step and through it.
			p[puncher] = 0
			for t in range(40):
				s.advance(s.tick, p)
			for t in range(60):
				p[puncher] = (Pad.RIGHT if t < 25 else 0) | (Pad.A if t < 3 else 0)
				s.advance(s.tick, p)
			check(not items(s.two.host_sol).has(5), tag + ": the coin was picked up")
			check(s.two.host_sol.hero_bonus > before, tag + ": and it counted (%d -> %d)" % [before, s.two.host_sol.hero_bonus])
			s.leave()


## ITM-02 -- a door keeps $2B:$2C (capsules already taken) and $98 (which
## drop the next death gives): only a new game wipes them ($86C5, $D06C).
func door_keeps_taken_and_drops() -> void:
	for kinds in [[0], [1], [0, 1], [0, 0]]:
		var s := Pb3Session.new(kinds)
		s.at = 0
		s.enter()
		var pads := []
		for i in kinds:
			pads.append(0)
		for t in range(5):
			s.advance(s.tick, pads)
		s.two.host_pb2.got = 0x0204
		s.two.host_pb2.drop_clock = 5
		var tag := "%s door S0A0 -> S0A1" % str(kinds)
		check(s._travel(Pb3Pair.PB2, 0, 1) == "changed", tag + ": travelled")
		for t in range(5):
			s.advance(s.tick, pads)
		check(s.two.host_pb2.got == 0x0204, tag + ": taken capsules kept (%X)" % s.two.host_pb2.got)
		check(s.two.host_pb2.drop_clock == 5, tag + ": drop order kept (%d)" % s.two.host_pb2.drop_clock)
		s.leave()
		# And a new run from the list starts both afresh.
		s = Pb3Session.new(kinds)
		s.at = 1
		s.enter()
		check(s.two.host_pb2.got == 0 and s.two.host_pb2.drop_clock == 0,
				str(kinds) + ": a new run starts afresh")
		s.leave()


## ITM-03 -- s0: the shield panel at (1216,400).  The map names metatile 142
## there; the probe hands back what is shown, its alternate 68, and 68 is the
## stage's shield tile ($9D6E).  Ducking on it buys the shield for ten.
func panel_sells_the_shield() -> void:
	for kinds in [[1], [1, 1], [0, 1]]:
		for buyer in range(kinds.size()):
			if kinds[buyer] != 1:
				continue
			var spots := []
			for i in range(kinds.size()):
				spots.append(Vector2i(1224 if i == buyer else 1180,
						400 if i == buyer else (415 if kinds[i] == 0 else 416)))
			var s := stand(63, 1, 0, kinds, spots)
			var hero: SolPlayer = s.two.sol[buyer]
			hero.pool.hero_bonus = 20
			var pads := []
			for i in kinds:
				pads.append(0)
			for t in range(30):
				s.advance(s.tick, pads)
			var tag := "%s buyer %d" % [str(kinds), buyer]
			check(hero.shield == 0, tag + ": no shield before")
			var p := pads.duplicate()
			p[buyer] = Pad.DOWN
			for t in range(20):
				s.advance(s.tick, p)
			check(hero.shield == SolPanels.one("shield_full"), tag + ": shield bought (%d)" % hero.shield)
			check(hero.pool.hero_bonus - hero.pool.z56 == 10 or hero.pool.hero_bonus == 10,
					tag + ": ten paid (%d, tab %d)" % [hero.pool.hero_bonus, hero.pool.z56])
			s.leave()


func run() -> void:
	cube_item_is_the_stages()
	door_keeps_taken_and_drops()
	panel_sells_the_shield()
	if failed == 0:
		print("pb3_items_test: ok")
	quit(1 if failed else 0)
