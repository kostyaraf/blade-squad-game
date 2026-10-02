extends SceneTree
## Diagnostic module comparison with real cartridge pickup writes.
func _initialize() -> void:
	var cases: Array = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	for one in cases:
		var pool := SolObjects.new(SolLevel.new(0))
		pool.id[0] = 0x41
		pool.mind[0] = int(one.mind)
		pool.letters = int(one.letters)
		pool.z60 = int(one.flags)
		pool._pick_up(0)
		var row := {"id":pool.id[0], "mind":pool.mind[0], "a":pool.a[0],
			"b":pool.b[0], "letters":pool.letters, "blink0":pool.w_kind[12],
			"blink1":pool.w_kind[13], "blink2":pool.w_kind[14]}
		print("PICKUP ", JSON.stringify({"name":one.name,"got":row}))
		for f in range(32): SolSat._boxes(pool)
		if pool.w_kind[12] != 0 or pool.w_kind[13] != 0 or pool.w_kind[14] != 0:
			print("FAIL: pickup blink never expires")
			quit(1)
			return
	quit(0)
