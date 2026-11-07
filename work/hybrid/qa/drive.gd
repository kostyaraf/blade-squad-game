extends SceneTree
## Headless helper for finding a hybrid playthrough: plays ordinary pad
## frames from a menu entry (no pokes) and prints where the heroes are.
##   Godot --headless --path game --script res://../work/hybrid/qa/drive.gd \
##       -- --start=83 --heroes=0 --steps=/path/steps.json [--every=20]
## The proof itself is recorded with game/tests/playthrough.gd.

func _initialize() -> void:
	call_deferred("run")

func arg(name: String, def: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--" + name + "="):
			return a.substr(name.length() + 3)
	return def

func run() -> void:
	var kinds: Array = []
	for h in arg("heroes", "0").split(","):
		kinds.append(int(h))
	var s := Pb3Session.new(kinds)
	s.at = int(arg("start", "83"))
	s.enter()
	var steps: Array = JSON.parse_string(FileAccess.get_file_as_string(arg("steps", "")))
	var every := int(arg("every", "20"))
	for part in steps:
		var words: Array = []
		for i in range(1, part.size()):
			words.append(int(part[i]))
		for _n in range(int(part[0])):
			if s.two == null:
				break
			var ev := s.advance(s.tick, words)
			if ev != "playing":
				print("EVENT ", s.tick, " ", ev, " ", s.message, " seg=", s.two.hyb_seg if s.two != null else -1)
			if s.two != null and (s.tick % every == 0):
				var line := "t=%d seg=%d g=%d" % [s.tick, s.two.hyb_seg, s.two.game]
				for i in range(kinds.size()):
					var p := s.two.world_of(i)
					var life: int = s.two.things[i].slots[0][Pb2Objects.F_LIFE] if kinds[i] == 0 else s.two.sol[i].suit
					line += " h%d=(%d,%d) L=%d" % [i, p.x, p.y, life]
				if arg("enemies", "0") == "1" and s.two.host_pb2 != null:
					for n in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
						var e: PackedByteArray = s.two.host_pb2.slots[n]
						if e[Pb2Objects.F_TYPE] != 0:
							line += " [%02X %d,%d L%d]" % [e[Pb2Objects.F_TYPE], e[Pb2Objects.F_X], e[Pb2Objects.F_Y], e[Pb2Objects.F_LIFE]]
				print(line)
	if arg("plan", "") != "":
		steps = steps + plan(s, kinds, JSON.parse_string(FileAccess.get_file_as_string(arg("plan", ""))), every)
		var f := FileAccess.open(arg("out", "user://plan_steps.json"), FileAccess.WRITE)
		f.store_string(JSON.stringify(steps))
		f.close()
		print("PLAN END t=", s.tick)
		quit(0)
		return
	if s.two != null:
		var line := "END t=%d seg=%d" % [s.tick, s.two.hyb_seg]
		for i in range(kinds.size()):
			var p := s.two.world_of(i)
			line += " h%d=(%d,%d)" % [i, p.x, p.y]
		print(line)
	quit(0)


## A plan is a list of [pad, until, value, limit]: hold `pad` (bit 0x40 is
## tapped 4 on / 4 off) until hero 0's x >= value ("x>"), x <= value ("x<"),
## y <= value ("y<"), y >= value ("y>"), or for value ticks ("t").  Only pad
## frames are produced; the result is the plain step list.
func plan(s: Pb3Session, kinds: Array, items: Array, every: int) -> Array:
	var out: Array = []
	var start := s.tick
	# the steps file was played first by the caller of run()
	for it in items:
		var pad := int(it[0])
		var until := String(it[1])
		var v := int(it[2])
		var limit := int(it[3]) if it.size() > 3 else 2000
		var n := 0
		while n < limit and s.two != null:
			var p := s.two.world_of(0)
			if until == "x>" and p.x >= v: break
			if until == "x<" and p.x <= v: break
			if until == "y<" and p.y <= v: break
			if until == "y>" and p.y >= v: break
			if until == "t" and n >= v: break
			if until == "seg" and s.two.hyb_seg >= v: break
			var w := pad
			if (pad & 0x40) != 0 and (s.tick / 4) % 2 == 1:
				w = pad & ~0x40
			var words: Array = []
			for _k in kinds:
				words.append(w)
			var ev := s.advance(s.tick, words)
			n += 1
			if out.size() > 0 and int(out.back()[1]) == w:
				out.back()[0] = int(out.back()[0]) + 1
			else:
				out.append([1, w])
			if ev != "playing":
				print("EVENT ", s.tick, " ", ev, " ", s.message)
			if s.two != null and s.tick % every == 0:
				var q := s.two.world_of(0)
				var line := "t=%d seg=%d h0=(%d,%d) L=%d" % [s.tick, s.two.hyb_seg, q.x, q.y,
						s.two.things[0].slots[0][Pb2Objects.F_LIFE] if kinds[0] == 0 else s.two.sol[0].suit]
				if s.two.host_pb2 != null:
					for m in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
						var e: PackedByteArray = s.two.host_pb2.slots[m]
						if e[Pb2Objects.F_TYPE] != 0:
							line += " [%02X %d,%d L%d]" % [e[Pb2Objects.F_TYPE], e[Pb2Objects.F_X], e[Pb2Objects.F_Y], e[Pb2Objects.F_LIFE]]
				print(line)
		if s.two != null:
			var q := s.two.world_of(0)
			print("  step %s done t=%d at (%d,%d)" % [JSON.stringify(it), s.tick, q.x, q.y])
	return out
