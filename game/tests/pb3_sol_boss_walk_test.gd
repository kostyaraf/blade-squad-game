extends SceneTree
## NSB-04: in the first room of the seventh stage's boss ($A426, room $43)
## the script holds the hero and walks the view itself ($A4BB, $30 += $10 a
## picture) until $31 + 8 = $81.  The shared view must not pull it back, or
## step three never ends, the boss never breaks the gate at x 1008 and Nova
## is shut in.  Placed fixture: Nova stands in the trigger column $3E.
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", label)


func run_one(kinds: Array) -> void:
	var session := Pb3Session.new(kinds)
	session.at = 63 + 7
	session.two = Pb3Pair.new(Pb3Pair.SOL, 7, 0, kinds)
	var spots := []
	for kind in kinds:
		spots.append(Vector2i(998, 1215 if kind == Pb3Pair.PB2 else 1216))
	session.two.begin(spots, true)
	var view := session.two.sol_eye
	# The arena as the earlier rooms leave it: one screen, locked at $3000.
	view.x = 0x3000
	view.x_min = 0x2000
	view.x_end = 0x4000
	view.y = 0x4100
	view.y_min = 0x4100
	view.y_end = 0x5100
	session.prepare()
	var level: SolLevel = session.two.solv
	var words := []
	for _k in kinds:
		words.append(0)
	var walked := false
	var opened := false
	for _f in range(600):
		session.advance(session.tick, words)
		if session.two == null:
			break
		if session.two.host_script.g(0x31) > 0x30:
			walked = true
		if level.collision_at(1012, 1180) < 0x10:
			opened = true
			break
	check(walked, "view walked by $A4BB " + str(kinds))
	check(opened, "boss broke the gate at x1008 " + str(kinds))


func _initialize() -> void:
	for kinds in [[0], [1], [0, 1]]:
		run_one(kinds)
	print("sol boss walk: ", failures, " failed")
	quit(1 if failures else 0)
