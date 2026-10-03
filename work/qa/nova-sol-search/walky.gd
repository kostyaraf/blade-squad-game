extends SceneTree
# walk.gd rec.json N patterns.json every : replay to N, then each pattern, print world/sub.
func trial(rec: Dictionary, n: int, pat: Array, every: int) -> String:
	var s := Pb3Session.new([0]); s.at = int(rec.entry); s.enter()
	var done := false
	for part in rec.steps:
		for f in range(int(part[0])):
			if s.tick >= n: done = true; break
			s.advance(s.tick, [int(part[1])])
		if done: break
	var out := " start=%s sub=%d" % [str(s.two.world_of(0)), s.two.pb2[0].sub]
	for part in pat:
		for f in range(int(part[0])):
			var e := s.advance(s.tick, [int(part[1])])
			if e != "" and e != "playing": return out + " EVENT %s@%d" % [e, s.tick]
			if s.two == null: return out + " gone"
			if s.tick % every == 0:
				out += " %s/%d/sy%d" % [str(s.two.world_of(0)), s.two.pb2[0].sub, s.two.pb2[0].y >> 8]
	return out
func _initialize():
	var a := OS.get_cmdline_user_args()
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(a[0]))
	var pats: Array = JSON.parse_string(FileAccess.get_file_as_string(a[2]))
	for p in pats:
		print("PAT ", JSON.stringify(p), " =>", trial(rec, int(a[1]), p, int(a[3])))
	quit()
