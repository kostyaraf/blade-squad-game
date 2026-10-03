extends SceneTree
## SPB-02: Solbrain crouched on the p0.4 lift fits under the low ledge that a
## crouching PB2 hero passes under; standing, the same spot is still blocked.
func _initialize() -> void:
	var session := Pb3Session.new([1])
	session.at = 4
	session.enter()
	var pair: Pb3Pair = session.two
	var h: SolPlayer = pair.sol[0]
	# Feet at 122 on the lift, the ledge's underside at 95, x past its edge.
	var at := Vector2i(1028 << 4, 106 << 4)
	var failed := 0
	h.state = SolPlayer.ST_CROUCH
	if not pair._sol_clear(h, at):
		print("FAIL: crouched Solbrain is stopped by the ledge")
		failed += 1
	h.state = SolPlayer.ST_GROUND
	if pair._sol_clear(h, at):
		print("FAIL: standing Solbrain passes through the ledge")
		failed += 1
	print("sol crouch clear: ", failed, " failed")
	quit(1 if failed else 0)
