extends SceneTree
## The pod $33 and its children $30/$31 against NES RAM taken before every
## turn of the things.  Each step starts from the cartridge's own RAM: hero,
## clock, view, seed and the child places, so one wrong field does not spread.

func _row(ram: Array, slot: int) -> PackedByteArray:
	var r := PackedByteArray()
	r.resize(Pb2Objects.FIELDS)
	for f in range(Pb2Objects.FIELDS):
		r[f] = int(ram[0x400 + 22 * f + slot])
	return r

func _initialize() -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var failed := 0
	var checks := 0
	for case in cfg.cases:
		var snaps: Array = case.snaps
		var w := Pb2Objects.new(Pb2Level.new(0, 0))
		var ram0: Array = snaps[0].ram
		for slot in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
			w.slots[slot] = _row(ram0, slot)
		for k in range(snaps.size() - 1):
			var ram: Array = snaps[k].ram
			w.slots[0] = _row(ram, 0)
			w.cam = int(ram[0x66]) * 256 + int(ram[0x67])
			w.clock = int(ram[0x119])
			w.seed = int(ram[0x169]) * 256 + int(ram[0x168])
			w.turns()
			var want: Array = snaps[k + 1].ram
			for slot in range(Pb2Objects.FIRST_LIVE, Pb2Objects.FIRST_PLACED):
				var got: PackedByteArray = w.slots[slot]
				var nes := _row(want, slot)
				for f in range(Pb2Objects.FIELDS):
					checks += 1
					if got[f] != nes[f]:
						if failed < 15:
							print("FAIL ", case.name, " frame=", snaps[k + 1].frame,
									" slot=", slot, " field=", f, " got=", got[f], " NES=", nes[f])
						failed += 1
				w.slots[slot] = nes
	print("NES pod $33: ", failed, " / ", checks, " fields differ")
	quit(1 if failed else 0)
