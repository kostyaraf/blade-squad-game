extends SceneTree
## ASCII map of one PB2 area: args stage area. # wall, L ladder, ^ hurt, . empty;
## spawns drawn as hex digit of type low nibble in separate list.
func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var lv := Pb2Level.new(int(a[0]), int(a[1]))
	print("vertical=", lv.vertical, " w=", lv.width_tiles, " h=", lv.height_tiles, " start=", lv.start_x, ",", lv.start_y, " door=", lv.door_hi, ",", lv.door_lo, " kind=", lv.kind, " cam=", lv.cam_start_page, ":", lv.cam_start_low, "..", lv.cam_limit_page, ":", lv.cam_limit_low)
	var rows := lv.height_tiles / 2
	var cols := lv.width_tiles / 2
	for r in range(rows):
		var s := "%4d " % (r * 16)
		for c in range(cols):
			var b := lv.class_byte(c * 16, r * 16)
			s += "#" if b == 0x80 else ("L" if b == 1 else ("^" if b == 2 else "."))
		print(s)
	var sp := []
	for o in lv.spawns: sp.append("%d/%d:%02X f%d" % [o.along, o.across, o.type, o.flags])
	print(" ".join(sp))
	quit()
