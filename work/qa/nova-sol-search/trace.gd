extends SceneTree
# trace.gd rec.json every : print world pos/life/events
func _initialize():
	var a := OS.get_cmdline_user_args()
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(a[0]))
	var every := int(a[1])
	var s := Pb3Session.new([0]); s.at = int(rec.entry); s.enter()
	for part in rec.steps:
		for f in range(int(part[0])):
			if s.two == null: quit(); return
			var e := s.advance(s.tick, [int(part[1])])
			if e != "" and e != "playing": print("EVENT ", e, " @", s.tick, " at=", s.at)
			if s.two != null and s.tick % every == 0:
				print(s.tick, " ", s.two.world_of(0), " life=", s.two.things[0].slots[0][Pb2Objects.F_LIFE], " en=", s.gear.energy)
	quit()
