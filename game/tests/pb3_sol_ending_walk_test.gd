extends SceneTree
## NSB-20: the last boss of s19 down, the ending's step $9EB5 holds the hero
## ($9E73 takes the player's buttons) and hands him $06 = towards the boss,
## waiting until the two stand closer than $0280 sixteenths.  PB3 took the
## buttons away and handed him nothing, so a hero further off never walked
## and $58 stood at 7 for ever.
## Ordinary input from the menu entry: suit 1, walk in, kill the boss from
## x924, then keep pressing B; the ending must walk Nova on past step 7.
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", label)


func _initialize() -> void:
	var s := Pb3Session.new([0])
	s.at = 63 + 19
	s.enter()
	var steps: Array = [[1, 16], [1, 0], [1, 8], [1, 0], [1, 16], [400, 1], [30, 2]]
	for _i in range(110):
		steps.append_array([[1, 66], [1, 2], [1, 64], [12, 0]])
	var reached := 0
	for part in steps:
		for _f in range(int(part[0])):
			s.advance(s.tick, [int(part[1])])
			if s.two == null:
				break
			reached = maxi(reached, s.two.host_script.g(0x58))
		if s.two == null:
			break
	check(s.two != null, "Nova alive through the fight")
	check(reached > 7, "ending walked past $9EB5 (reached $58=%d)" % reached)
	print("pb3_sol_ending_walk: $58 reached %d, failures %d" % [reached, failures])
	quit(1 if failures else 0)
