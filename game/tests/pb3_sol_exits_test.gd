extends SceneTree
## Placed exit diagnostics: never a claim of full stage completion.
var checks := 0
var failures := 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: ", label)


func _initialize() -> void:
	call_deferred("run")


func placed(stage: int, x: int, feet: int, kinds: Array) -> Pb3Session:
	var session := Pb3Session.new(kinds)
	session.at = 63 + stage
	session.two = Pb3Pair.new(Pb3Pair.SOL, stage, 0, kinds)
	var spots := []
	for kind in kinds:
		spots.append(Vector2i(x, feet - 1 if kind == Pb3Pair.PB2 else feet))
	session.two.begin(spots, true)
	# Preceding room scripts normally unlock these bounds during traversal.
	# The placed fixture must not clamp back to the initial room's camera.
	var view := session.two.sol_eye
	view.x_min = mini(view.x_min, view.x)
	view.x_end = maxi(view.x_end, view.x + 4096)
	view.y_min = mini(view.y_min, view.y)
	view.y_end = maxi(view.y_end, view.y + 4096)
	session.prepare()
	return session


func run() -> void:
	# Six equality-based standing-height entrances. Stage indices are zero-based.
	# stage, platform x, support y, first ROM routine, destination stage
	var sites := [
		[2, 1456, 1168, 0xA98C, 13], [9, 2256, 1136, 0xA294, 18],
		[11, 2000, 1632, 0xADF4, 14], [17, 2128, 1680, 0xA774, 17],
		[7, 2256, 1712, 0xA6A1, 12], [16, 3248, 368, 0x9DBF, 19]]
	for site in sites:
		for kinds in [[0], [1], [0, 0], [1, 1], [0, 1], [1, 0]]:
			var session := placed(site[0], site[1], site[2], kinds)
			var event := "playing"
			var fired := false
			var words := []
			for _kind in kinds:
				words.append(0)
			var destination := -1
			for _frame in range(500):
				event = session.advance(session.tick, words)
				if session.two != null:
					var script := session.two.host_script
					if script.trail.has(site[3]):
						fired = fired or script.g(0x7F) > 0
				if event != "playing":
					destination = session.at - 63
					break
			check(fired, "standing trigger " + str([site[0], kinds]))
			check(event == "changed" and destination == site[4],
				"full native exit sequence " + str([site[0], kinds, event, session.tick]))
			print("exit ", site[0], " ", kinds, " -> ", destination, " at ", session.tick)
			session.leave()

	# The conversion is conditional on support and never changes world/art.
	var session := placed(9, 2256, 1136, [0])
	var pair := session.two
	var before := pair.world_of(0)
	pair._stand_in()
	check(pair.spare_sol.y == 1120 << 4, "standing actor uses support height")
	check(pair.world_of(0) == before, "script conversion does not move Nova")
	pair.pb2[0].sub = Pb2Player.SUB_AIR
	pair._stand_in()
	check(pair.spare_sol.y == 1119 << 4, "airborne actor is not snapped to support")
	check(pair.spare_sol.state == SolPlayer.ST_AIR, "airborne actor cannot satisfy standing gate")
	session.leave()

	# Off-platform and airborne actors must not open this exact-row gate.
	for spot in [[2240, 1136, false], [2256, 1104, true]]:
		session = placed(9, spot[0], spot[1], [0])
		if spot[2]:
			session.two.pb2[0].sub = Pb2Player.SUB_AIR
		session.advance(session.tick, [0])
		check(session.two.host_script.g(0x7F) == 0, "invalid standing gate " + str(spot))
		session.leave()

	# Ordinary live actors still participate in camera/fall safety.
	session = placed(9, 2256, 1136, [1])
	check(not session.two._sol_departing(0), "ordinary Solbrain is not departing")
	session.two.sol[0].y = 0xFFFF
	session.two._hold_them_in()
	check(session.two.gone[0], "ordinary out-of-map fall still ends the run")
	session.leave()
	print("%d of %d exit checks failed" % [failures, checks])
	quit(1 if failures else 0)
