extends SceneTree
## NSB-05: when a stage's boss falls the script holds the heroes ($9E73) and
## waits for $05A2 to say a hero on his feet ($9371).  Nova left on a wall
## (or under a ceiling, or on a net) holds on with no button, so with her
## buttons taken she never came down and the stage stood locked forever.
## Placed fixture: s17's boss room after the boss, Nova on the wall at x3290.
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", label)


func run_one(sub: int) -> void:
	var kinds := [0]
	var session := Pb3Session.new(kinds)
	session.at = 63 + 17
	session.two = Pb3Pair.new(Pb3Pair.SOL, 17, 0, kinds)
	session.two.begin([Vector2i(3290, 1661)], true)
	var view := session.two.sol_eye
	view.x = 0xC000
	view.x_min = 0xC000
	view.x_end = 0xD000
	view.y = 0x6000
	view.y_min = 0x6000
	view.y_end = 0x7000
	session.prepare()
	var two := session.two
	var o: SolObjects = two.host_sol
	var q: Pb2Player = two.pb2[0]
	# The first picture of the room puts the boss in ($AA83); it is taken
	# out again as though it had been beaten, and Nova set on the wall.
	for _f in range(4):
		session.advance(session.tick, [0])
	for k in range(o.id.size()):
		o.id[k] = 0
	q.sub = sub
	q.state = 0
	# Her first suit and some of its bar: the wall is the suit's ($97A0).
	session.gear.st[0].suit = 1
	session.gear.st[0].energy = 16
	var landed := false
	for _f in range(900):
		session.advance(session.tick, [0])
		if q.sub == Pb2Player.SUB_GROUND:
			landed = true
	check(landed, "Nova came down from sub %d" % sub)
	# $9371 -> $9385 -> $9398: on her feet, the wait, then the fade out.
	check(two.host_script.g(0x05FA) >= 3, "the stage went on after the boss, sub %d" % sub)


func _initialize() -> void:
	for sub in [Pb2Player.SUB_WALL, Pb2Player.SUB_GROUND]:
		run_one(sub)
	print("sol end hold: ", failures, " failed")
	quit(1 if failures else 0)
