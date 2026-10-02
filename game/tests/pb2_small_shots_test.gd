extends SceneTree
func _initialize() -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var failed := 0
	var checks := 0
	for case in cfg.cases:
		var w := Pb2Objects.new(Pb2Level.new(0,0))
		w.cam = int(case.cam)
		w.clock = int(case.clock)
		w.slots[6] = PackedByteArray(case.initial)
		for frame in case.frames:
			w.slots[20][Pb2Objects.F_TYPE] = int(frame.parent)
			for _t in range(int(frame.turns)):
				w.clock = (w.clock + 1) & 0xFF
				var row: PackedByteArray = w.slots[6]
				if row[Pb2Objects.F_TYPE] != 0:
					if w._cull_one(row):
						w.clear(6)
					elif w._may_move(row):
						w.call(w.MINDS[row[Pb2Objects.F_TYPE]], 6, row)
			var actual: PackedByteArray = w.slots[6]
			for f in range(actual.size()):
				checks += 1
				if actual[f] != int(frame.row[f]):
					if failed < 15:
						print("FAIL ",case.name," frame=",frame.frame," field=",f," got=",actual[f]," NES=",frame.row[f])
					failed += 1
	print("NES small shots: ",failed," / ",checks," fields differ")
	quit(1 if failed else 0)
