extends SceneTree
# trial.gd -- rec.json N patterns.json [every]: replay rec to tick N, then each pattern.
func boss(s) -> String:
	var o: SolObjects = s.two.host_sol
	var t := ""
	for k in range(16):
		if o.id[k] == 65:
			t += "[m=%x %d,%d L%d]" % [o.mind[k], o.x[k] >> 4, o.y[k] >> 4, o.life[k]]
	return t
func trial(rec: Dictionary, n: int, pat: Array, every: int) -> String:
	var s := Pb3Session.new([0]); s.at = int(rec.entry); s.enter()
	var done := false
	for part in rec.steps:
		for f in range(int(part[0])):
			if s.tick >= n: done = true; break
			s.advance(s.tick, [int(part[1])])
		if done: break
	var out := ""
	for part in pat:
		for f in range(int(part[0])):
			var e := s.advance(s.tick, [int(part[1])])
			if e != "" and e != "playing": return out + " EVENT %s@%d" % [e, s.tick]
			if s.two == null: return out + " gone@%d" % s.tick
			if s.tick % every == 0:
				out += "\n  %d nova=%s hp=%d sub=%d %s" % [s.tick, str(s.two.world_of(0)), s.two.things[0].slots[0][Pb2Objects.F_LIFE], s.two.pb2[0].sub, boss(s)]
	return out
func _initialize():
	var a := OS.get_cmdline_user_args()
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(a[0]))
	var pats: Array = JSON.parse_string(FileAccess.get_file_as_string(a[2]))
	var every := int(a[3]) if a.size() > 3 else 40
	for p in pats:
		print("PAT ", JSON.stringify(p).left(80), " =>", trial(rec, int(a[1]), p, every))
	quit()
