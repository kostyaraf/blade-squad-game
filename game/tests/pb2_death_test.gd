extends SceneTree
func _initialize() -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var failed := 0
	var checks := 0
	if cfg.cases.is_empty():
		push_error('Empty NES oracle')
		quit(1)
		return
	for case in cfg.cases:
		var steps := 0
		for row in case.frames: steps += int(row.turns)
		if steps == 0:
			push_error('NES oracle contains no executed steps: '+str(case.name))
			quit(1)
			return
		var w := Pb2Objects.new(Pb2Level.new(0,0))
		w.cam = int(case.cam)
		w.drop_clock = int(case.drop_clock)
		w.slots[20] = PackedByteArray(case.initial)
		for frame in case.frames:
			for _t in range(int(frame.turns)):
				if w.slots[20][Pb2Objects.F_TYPE] != 0:
					w._mind_01(20, w.slots[20])
			var actual: PackedByteArray = w.slots[20]
			for f in range(actual.size()):
				checks += 1
				if actual[f] != int(frame.row[f]):
					if failed < 12:
						print("FAIL ",case.name," frame=",frame.frame," field=",f," got=",actual[f]," NES=",frame.row[f])
					failed += 1
			checks += 1
			if w.drop_clock != int(frame.drop_clock):
				failed += 1
	print("NES death: ",failed," / ",checks," fields differ")
	quit(1 if failed else 0)
