extends SceneTree
## SPB2-04: the pair slid the view before the scan, so what came over the edge
## stood one slide too far and the second pair of p3.0 breakable blocks sat 17
## apart, leaving one wall cell closed.  Normal inputs only.
func _initialize() -> void:
	var failures := 0
	for mode in [false, true]:
		Pb2Turn.exact_scan = mode
		var s := Pb3Session.new([1])
		s.at = 22
		s.enter()
		var gap_bad := false
		var seen_pair := false
		var t := 0
		while t < 700 and s.two != null:
			s.advance(s.tick, [_pad(t)])
			t += 1
			if s.two == null: break
			var xs := {}
			for n in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
				var r: PackedByteArray = s.two.host_pb2.slots[n]
				if r[Pb2Objects.F_TYPE] == 12 and r[Pb2Objects.F_STATE] == 1:
					xs[r[Pb2Objects.F_LIFE]] = (r[Pb2Objects.F_XHI] << 8) | r[Pb2Objects.F_X]
			if xs.has(2) and xs.has(3):
				seen_pair = true
				if xs[3] - xs[2] != 16: gap_bad = true
		var x: int = s.two.world_of(0).x if s.two != null else -1
		print("exact=", mode, " pair seen=", seen_pair, " gap bad=", gap_bad, " x=", x)
		if mode and (gap_bad or x < 520 or not seen_pair):
			failures += 1
			print("FAIL: exact scan must keep the pair 16 apart and open the wall")
		if s.two != null: s.leave()
	print("%d failures" % failures)
	quit(1 if failures else 0)

func _pad(t: int) -> int:
	var steps: Array = [[1,16],[1,4],[1,16],[18,1],[1,129],[30,129],[20,0],[55,1]]
	for i in range(8): steps.append_array([[1,68],[11,4]])
	steps.append_array([[25,1],[1,0],[1,5],[1,133],[30,5]])
	steps.append_array([[20,1],[1,0],[1,129],[30,129],[140,1]])
	for i in range(8): steps.append_array([[1,68],[11,4]])
	steps.append_array([[10,0],[1,0],[1,5],[1,133],[30,5],[60,1]])
	var k := t
	for p in steps:
		if k < int(p[0]): return int(p[1])
		k -= int(p[0])
	return 1
