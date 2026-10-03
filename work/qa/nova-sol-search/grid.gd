extends SceneTree
# grid.gd stage x0 x1 y0 y1 : collision class per 16px cell (hex), from the pair's Sol level.
func _initialize():
	var a := OS.get_cmdline_user_args()
	var st := int(a[0])
	var two := Pb3Pair.new(Pb3Pair.SOL, st, 0, [0])
	two.begin([Vector2i(int(a[1]), int(a[3]))], true)
	var lv: SolLevel = two.solv
	var hdr := "      "
	for x in range(int(a[1]), int(a[2]), 16): hdr += "%3d" % ((x / 16) % 100)
	print(hdr)
	for y in range(int(a[3]), int(a[4]), 16):
		var row := "%5d " % y
		for x in range(int(a[1]), int(a[2]), 16):
			row += "%3x" % lv.collision_at(x + 8, y + 8)
		print(row)
	quit()
