extends SceneTree
# pos.gd rec.json every : print tick, world, sub, hp, energy each `every`.
func _initialize():
	var a := OS.get_cmdline_user_args()
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(a[0]))
	var every := int(a[1])
	var s := Pb3Session.new([0]); s.at = int(rec.entry); s.enter()
	for part in rec.steps:
		for f in range(int(part[0])):
			s.advance(s.tick, [int(part[1])])
			if s.two == null: quit(); return
			if s.tick % every == 0:
				print("t=%d pad=%x w=%s sub=%d hp=%d en=%d" % [s.tick, int(part[1]), str(s.two.world_of(0)), s.two.pb2[0].sub, s.two.things[0].slots[0][Pb2Objects.F_LIFE], s.gear.energy])
	quit()
