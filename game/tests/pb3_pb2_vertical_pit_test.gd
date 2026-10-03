extends SceneTree
## SPB-07: p2.0 (Power Blade 2 stage 2, area 0) scrolls downwards and its map
## runs on below the last view ($59/$5A). Solbrain walking off the start ledge
## used to hang at screen line $EF for ever; he must die like Nova does ($A17A).
func _go(pads: Array) -> Array:
	var session := Pb3Session.new([1])
	session.at = 15
	session.enter()
	var ev := "playing"
	for m in [[1, 16], [1, 4], [1, 16]] + pads:
		for _n in range(m[0]):
			ev = session.advance(session.tick, [m[1]])
			if ev != "playing":
				return [session, ev]
	return [session, ev]

func _initialize() -> void:
	var failed := 0
	var fell: Array = _go([[60, 1], [100, 0]])
	if fell[1] != "list":
		print("FAIL: Solbrain fell off the ledge and the room said ", fell[1],
				" at tick ", fell[0].tick)
		failed += 1
	var stood: Array = _go([[300, 0]])
	if stood[1] != "playing" or stood[0].two.gone[0]:
		print("FAIL: Solbrain standing at the start is gone: ", stood[1])
		failed += 1
	print("pb2 vertical pit: ", failed, " failed")
	quit(1 if failed else 0)
