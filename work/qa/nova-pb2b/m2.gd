extends SceneTree
func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var lv := Pb2Level.new(int(a[0]), int(a[1]))
	var x0 := int(a[2]); var x1 := int(a[3])
	for y in range(0, lv.height_tiles * 8, 8):
		var s := "%4d " % y
		for x in range(x0, x1, 8):
			s += "%02X " % lv.class_byte(x, y)
		print(s)
	quit()
