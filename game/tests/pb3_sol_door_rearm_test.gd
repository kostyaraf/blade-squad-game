extends SceneTree
## NSB-06: the seventh stage's boss doors share metatiles $48-$57, so opening
## one door ($BE36 breaks its metatiles) turns every other door of the stage
## round as well.  The corridor between two boss rooms (room $45, $A58D) sets
## $0549/$054A back to $FF every picture, which makes the next door whole --
## open toward the hero, shut behind the boss.  The script's $0540 page was
## never carried to the stage, so the next door stayed shut and the room $46
## pocket (x1552-1583) could not be entered.
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", label)


func _initialize() -> void:
	var kinds := [0]
	var session := Pb3Session.new(kinds)
	session.at = 63 + 7
	session.two = Pb3Pair.new(Pb3Pair.SOL, 7, 0, kinds)
	session.two.begin([Vector2i(1450, 1151)], true)
	var view := session.two.sol_eye
	view.x = 0x5000
	view.x_min = 0x5000
	view.x_end = 0x6000
	view.y = 0x4000
	view.y_min = 0x4000
	view.y_end = 0x5000
	session.prepare()
	var lv: SolLevel = session.two.host_sol.level
	# The first boss's door has been opened: every $48-$57 broken.
	for m in range(0x48, 0x58):
		lv.smash(m)
	check(lv.collision_at(1540, 1100) >= 0x10, "fixture: the door at x1536 shut")
	for _f in range(4):
		session.advance(session.tick, [0])
	check(lv.whole(0x4C) and lv.whole(0x50), "$A58D set $0549/$054A whole")
	check(lv.collision_at(1540, 1100) < 0x10, "door at x1536 open in room $45")
	check(lv.collision_at(1590, 1100) >= 0x10, "door at x1584 shut in room $45")
	print("sol door rearm: ", failures, " failed")
	quit(1 if failures else 0)
