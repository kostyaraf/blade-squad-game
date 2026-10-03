extends SceneTree
# gridat.gd rec.json N x0 x1 y0 y1 : collision grid after replaying rec to tick N.
func _initialize():
	var a := OS.get_cmdline_user_args()
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(a[0]))
	var n := int(a[1])
	var s := Pb3Session.new([0]); s.at = int(rec.entry); s.enter()
	var done := false
	for part in rec.steps:
		for f in range(int(part[0])):
			if s.tick >= n: done = true; break
			s.advance(s.tick, [int(part[1])])
		if done: break
	var lv: SolLevel = s.two.solv
	print("z57=%d 7f=%d room=%x" % [s.two.host_script.g(0x57), s.two.host_script.g(0x7F), s.two.host_script.g(0x5EB)])
	for y in range(int(a[4]), int(a[5]), 16):
		var row := "%5d " % y
		for x in range(int(a[2]), int(a[3]), 16):
			row += "%3x" % lv.collision_at(x + 8, y + 8)
		print(row)
	quit()
