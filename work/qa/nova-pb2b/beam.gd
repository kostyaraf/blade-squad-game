extends SceneTree
## QA route search: beam search over ordinary controller input, branching from
## copies of the running game (tests/qa_clone.gd). Output is a plain replay of
## pad words from the normal entry -- nothing is poked.
## Args: --replay=<prefix> --out=<file> --wp="x,y,r;x,y,r;door"
##   --chunk=8 --beam=24 --iters=300 --acts=- ,L,R,AL,AR,A,BL,BR,...
##   --hurt=400 (score per point of life lost) --kill=0 --hero=0
const C := preload("res://../work/qa/nova-pb2c/qa_clone.gd")
const BITS := {"A": 0x80, "B": 0x40, "s": 0x20, "S": 0x10, "U": 0x08, "D": 0x04, "L": 0x02, "R": 0x01, "-": 0}

var args := {}
var wps: Array = []        # [Vector2i, r] or "door"
var chunk := 8
var hurt_w := 400.0
var kill_w := 0.0
var holes := {}            # 16px cells to treat as open (breakable walls)


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv: PackedStringArray = a.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	chunk = int(args.get("chunk", "8"))
	hurt_w = float(args.get("hurt", "400"))
	kill_w = float(args.get("kill", "0"))
	for hcell in String(args.get("holes", "")).split(";", false):
		var hp := hcell.split(",")
		holes[Vector2i(int(hp[0]) >> 4, int(hp[1]) >> 4)] = true
	for w in String(args.wp).split(";"):
		if w == "door" or w == "clear":
			wps.append(w)
		elif w.begins_with("g") or w.begins_with("d"):
			var q := w.substr(1).split(",")
			# "d" = a door: steer to it by walking distance, done only on the room change
			wps.append(["geo", Vector2i(int(q[0]), int(q[1])), -1 if w.begins_with("d") else (int(q[2]) if q.size() > 2 else 8), null])
		else:
			var p := w.split(",")
			wps.append([Vector2i(int(p[0]), int(p[1])), int(p[2]) if p.size() > 2 else 6])
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args.replay))
	var heroes: Array = []
	for h in rec.heroes:
		heroes.append(int(h))
	var s := Pb3Session.new(heroes)
	s.at = int(rec.entry)
	s.enter()
	var steps: Array = []
	for part in rec.steps:
		steps.append([int(part[0]), int(part[1])])
		for f in range(int(part[0])):
			s.advance(s.tick, [int(part[1])])
	var acts: Array = []
	for m in String(args.get("menus", "")).split(",", false):
		acts.append("M" + m)
	for a in String(args.get("acts", "-,L,R,AL,AR,A,BL,BR,ABL,ABR,UL,UR,AUL,AUR,U,~L,~R,ADL,ADR,^L,^R")).split(","):
		acts.append(a)
	var root := {"s": s, "steps": [], "wpi": 0, "life0": life(s), "lost": 0, "t": 0, "score": 0.0, "last": steps[-1][1] if steps.size() > 0 else 0}
	root.score = score(root)
	var beam: Array = [root]
	var width := int(args.get("beam", "24"))
	var best_done: Dictionary = {}
	var top := -1e18
	var last_beam: Array = []
	var stale := 0
	for it in range(int(args.get("iters", "300"))):
		var kids: Array = []
		for st in beam:
			for ai in range(acts.size()):
				var k := step(st, acts[ai], ai == acts.size() - 1)
				if k.is_empty():
					continue
				if k.get("done", false):
					if best_done.is_empty() or k.score > best_done.score:
						best_done = k
					continue
				kids.append(k)
		if not best_done.is_empty():
			break
		kids.sort_custom(func(a, b): return a.score > b.score)
		var seen := {}
		beam = []
		for k in kids:
			var w: Vector2i = k.s.two.flat_of(0)
			var key := "%d|%d|%d|%d|%d|%d|%d" % [k.wpi, w.x >> 2, w.y >> 2, k.s.two.pb2[0].sub, k.s.two.pb2[0].suit, k.s.gear.energy, k.lost]
			if seen.has(key):
				continue
			seen[key] = true
			beam.append(k)
			if beam.size() >= width:
				break
		if beam.is_empty():
			print("ALL DEAD at iter ", it)
			beam = last_beam
			break
		last_beam = beam
		var b: Dictionary = beam[0]
		if b.score > top + 1.0:
			top = b.score
			stale = 0
		else:
			stale += 1
			if stale > int(args.get("stale", "40")):
				print("STUCK at iter ", it)
				break
		if args.has("dbg"):
			var ids := {}
			for e in beam:
				ids[e.s.get_instance_id()] = ids.get(e.s.get_instance_id(), 0) + 1
			print("beam ", beam.size(), " distinct sessions ", ids.size())
		if it % 5 == 0:
			var checkpoint := FileAccess.open(args.out + ".partial", FileAccess.WRITE)
			checkpoint.store_string(JSON.stringify({"entry":int(rec.entry),"heroes":heroes,"steps":steps + b.steps,"events":[],"done":false}))
			checkpoint.close()
			print("it %d t=%d wpi=%d pos=%s life=%d lost=%d score=%.0f" % [it, b.t, b.wpi, str(b.s.two.flat_of(0)), life(b.s), b.lost, b.score])
	var fin: Dictionary = best_done if not best_done.is_empty() else (beam[0] if beam.size() > 0 else {})
	if fin.is_empty():
		quit(1)
		return
	print("RESULT done=%s t=%d wpi=%d lost=%d" % [str(fin.get("done", false)), fin.t, fin.wpi, fin.lost])
	for c in fin.steps:
		steps.append(c)
	var merged: Array = []
	for st in steps:
		if merged.size() > 0 and merged[-1][1] == st[1]:
			merged[-1][0] += st[0]
		else:
			merged.append([st[0], st[1]])
	var out := {"entry": int(rec.entry), "heroes": heroes, "steps": merged, "events": []}
	var f := FileAccess.open(args.out, FileAccess.WRITE)
	f.store_string(JSON.stringify(out))
	f.close()
	quit(0)


## Walking distance (in 16px cells, through open cells) from every cell to
## the goal; lets the search follow winding shafts instead of straight lines.
func geo_field(lv: Pb2Level, goal: Vector2i) -> Dictionary:
	var f := {}
	var start := Vector2i(goal.x >> 4, (goal.y - 1) >> 4)
	f[start] = 0
	var q: Array = [start]
	var h := 0
	var cols := lv.width_tiles / 2
	var rows := lv.height_tiles / 2
	while h < q.size():
		var c: Vector2i = q[h]
		h += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if lv.vertical:
				while n.y >= 0 and n.y < rows and ((n.y * 16) & 0xFF) >= 240:
					n.y += d.y
			if n.x < 0 or n.y < 0 or n.x >= cols or n.y >= rows or f.has(n):
				continue
			if lv.class_byte(n.x * 16, n.y * 16) == 0x80 and not holes.has(n):
				continue
			f[n] = f[c] + 1
			q.append(n)
	return f


func geo_dist(s: Pb3Session, wp: Array) -> float:
	if wp[3] == null:
		wp[3] = geo_field(s.two.pb2v, wp[1])
	var w: Vector2i = s.two.world_of(0)
	var cell := Vector2i(w.x >> 4, (w.y - 1) >> 4)
	var f: Dictionary = wp[3]
	var base: float = f.get(cell, 999)
	var best := base
	# smooth inside the cell: blend towards the best neighbour
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var v: float = f.get(cell + d, 999)
		if v < best:
			best = v
			var frac := 0.0
			if d.x != 0:
				frac = float((w.x & 15) if d.x > 0 else 15 - (w.x & 15)) / 16.0
			else:
				frac = float(((w.y - 1) & 15) if d.y > 0 else 15 - ((w.y - 1) & 15)) / 16.0
			return base * 16.0 - frac * 16.0
	return base * 16.0


func is_geo(wp: Variant) -> bool:
	return wp is Array and wp.size() == 4 and wp[0] is String


func life(s: Pb3Session) -> int:
	return s.two.things[0].slots[0][Pb2Objects.F_LIFE]


func pads_of(act: String, last: int) -> Array:
	if act.begins_with("~"):
		# slide: crouch towards the side, then a fresh A while crouched
		var d := int(BITS[act[1]]) | 0x04
		var o: Array = [d]
		for i in range(chunk - 1):
			o.append(d | 0x80)
		return o
	if act.begins_with("*"):
		# tap A every other tick pair (swimming), with the given direction
		var d3 := 0
		for ch in act.substr(1):
			d3 |= int(BITS[ch])
		var o3: Array = []
		for i in range(chunk):
			o3.append(d3 | (0x80 if (i & 2) == 0 else 0))
		return o3
	if act.begins_with("^"):
		# short hop: fresh A for only part of the chunk
		var d2 := 0
		for ch in act.substr(1):
			d2 |= int(BITS[ch])
		var o2: Array = []
		for i in range(chunk):
			o2.append(d2 | (0x80 if i < chunk / 2 else 0))
		return o2
	var p := 0
	for ch in act:
		p |= int(BITS[ch])
	var out: Array = []
	for i in range(chunk):
		var q := p
		if i > 0:
			q &= ~0x40           # B only on the first tick: one throw
		if (p & 0x80) and (last & 0x80) == 0 and false:
			pass
		out.append(q)
	return out


func step(st: Dictionary, act: String, reuse: bool) -> Dictionary:
	var s: Pb3Session = st.s if reuse else C.copy(st.s)
	var pads: Array
	if act.begins_with("M"):
		var want := int(act.substr(1))
		var cur: int = s.gear.st[0].suit
		if want == cur:
			return {}
		pads = [0x10, 0, 0]
		for i in range(posmod(cur - want, 5)):
			pads += [0x04, 0, 0]
		pads += [0x10, 0x10, 0, 0, 0, 0]
	else:
		pads = pads_of(act, st.last)
	var k := {"s": s, "steps": st.steps.duplicate(), "wpi": st.wpi, "life0": st.life0, "lost": st.lost, "t": st.t, "last": pads[-1]}
	var prev_life := life(s)
	var held0: int = s.two.held_in
	for p in pads:
		var ev := s.advance(s.tick, [p])
		k.steps.append([1, p])
		k.t += 1
		if ev == "changed" and args.has("goal") and s.at != int(args.goal):
			ev = "playing"
		if ev == "changed":
			if wps[k.wpi] is String or (is_geo(wps[k.wpi]) and wps[k.wpi][2] < 0):
				k.wpi += 1
				k.done = true
				k.score = 1e9 - k.t - k.lost * hurt_w
				return k
			return {}
		if ev == "list" and s.message.begins_with("STAGE CLEAR"):
			k.done = true
			k.score = 1e9 - k.t - k.lost * hurt_w
			return k
		if ev != "playing" or s.two == null:
			if args.has("dbg"):
				print("end t=%d ev=%s msg=%s" % [k.t, ev, s.message])
			return {}
		if false and s.two.held_in > held0:
			return {}                  # pinned at the screen edge: treat as lost
		var l := life(s)
		if l < prev_life:
			k.lost += prev_life - l
			if args.has("dbg"):
				print("hit t=%d %d->%d lost=%d" % [k.t, prev_life, l, k.lost])
		prev_life = l
		if k.wpi < wps.size() and is_geo(wps[k.wpi]):
			var wg: Vector2i = s.two.world_of(0)
			var cg: Vector2i = wps[k.wpi][1]
			if absi(wg.x - cg.x) <= wps[k.wpi][2] and absi(wg.y - cg.y) <= wps[k.wpi][2]:
				k.wpi += 1
				if k.wpi >= wps.size():
					k.done = true
					k.score = 1e9 - k.t - k.lost * hurt_w
					return k
		elif k.wpi < wps.size() and not (wps[k.wpi] is String):
			var w: Vector2i = s.two.flat_of(0)
			var c: Vector2i = wps[k.wpi][0]
			if absi(w.x - c.x) <= wps[k.wpi][1] and absi(w.y - c.y) <= wps[k.wpi][1]:
				k.wpi += 1
				if k.wpi >= wps.size():
					k.done = true
					k.score = 1e9 - k.t - k.lost * hurt_w
					return k
	k.score = score(k)
	return k


func score(k: Dictionary) -> float:
	var s: Pb3Session = k.s
	var sc: float = k.wpi * 1e6 - k.lost * hurt_w - k.t * 0.3
	if k.wpi < wps.size() and is_geo(wps[k.wpi]):
		sc -= geo_dist(s, wps[k.wpi]) * 10.0
	elif k.wpi < wps.size() and not (wps[k.wpi] is String):
		var w: Vector2i = s.two.flat_of(0)
		var c: Vector2i = wps[k.wpi][0]
		sc -= (absi(w.x - c.x) + absi(w.y - c.y) * 1.5) * 10.0
	elif k.wpi < wps.size():
		var lv: Pb2Level = s.two.pb2v
		var w2: Vector2i = s.two.flat_of(0)
		if args.has("fight"):
			var target := String(args.fight).split(",")
			sc -= (absi(w2.x - int(target[0])) + absi(w2.y - int(target[1]))) * 2.0
		else:
			sc -= absi(w2.x - (lv.width_tiles * 8 - 16)) * 10.0
	if kill_w > 0 and s.two.host_pb2 != null:
		var o: Pb2Objects = s.two.host_pb2
		for n in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
			if o.slots[n][Pb2Objects.F_TYPE] == 0x0C and o.slots[n][Pb2Objects.F_STATE] < 2:
				sc -= 3 * kill_w
			elif o.slots[n][Pb2Objects.F_TYPE] != 0 and o.slots[n][Pb2Objects.F_LIFE] < 128:
				if not args.has("boss-type") or o.slots[n][Pb2Objects.F_TYPE] == int(args["boss-type"]):
					sc -= o.slots[n][Pb2Objects.F_LIFE] * kill_w
	return sc
