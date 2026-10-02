extends SceneTree

var failed := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failed += 1
		print("FAIL ", label)

func visible(oam: PackedByteArray) -> Array:
	var rows: Array = []
	for n in range(0, 256, 4):
		if oam[n] < 224:
			rows.append("%03d:%03d:%03d:%03d" % [oam[n], oam[n+1], oam[n+2], oam[n+3]])
	rows.sort()
	return rows

func run() -> void:
	# Same-game guests must be placed by the real camera, independently of
	# the fake camera used to keep foreign weapons alive.
	for st in range(20):
		var s := Pb3Session.new([1, 1])
		s.at = 63 + st
		s.enter()
		var p: SolPlayer = s.two.sol[1]
		p.timer = 255
		p._pose(0)
		p._picture()
		s.two._arms_turn_sol(1, 0)
		s.two.guest_pool[1].id.fill(0)
		var actual := Pb3Draw.new(s.two, 1)
		actual.guest_arms_off = true
		actual.lay_guest_again()
		var expected := SolSprites.Table.new()
		SolSprites.reset(expected, 0)
		SolSprites.hero(p, (p.x - s.two.sol_eye.x) & 65535,
				(p.y - s.two.sol_eye.y) & 65535, expected)
		check(visible(actual.guest_oam) == visible(expected.oam),
				"Sol P2 sprite location stage %d" % st)
		s.leave()
	await backgrounds()
	print("%d of %d geometry checks failed" % [failed, checks])
	quit(1 if failed else 0)

func backgrounds() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var app: Node = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	if app.menu != null:
		app._menu_took("pb3")
	else:
		app._start_pb3()
	app.pb3_setup = false
	for at in range(83):
		var s := Pb3Session.new([0, 1])
		s.at = at
		s.enter()
		app.pb3_session = s
		app.pb3 = s
		app._pb3_enter()
		var two: Pb3Pair = s.two
		var offsets: Array = [0]
		if two.game == 0 and two.pb2v.vertical:
			offsets = [0, 128, 224, 256]
		for offset in offsets:
			if two.game == 0 and two.pb2v.vertical:
				two.eye.pos = offset
			app._pb3_show()
			var mat: ShaderMaterial = app.bg.material
			mat.set_shader_parameter("sprites_on", false)
			mat.set_shader_parameter("sprites2_on", false)
			mat.set_shader_parameter("sprites3_on", false)
			await process_frame
			RenderingServer.force_draw()
			var img := root.get_texture().get_image()
			var sheet: Image = Nes.sheet("pb2" if two.game == 0 else "sol").get_image()
			var map: Image = two.pb2v.map_image if two.game == 0 else two.solv.map_image
			var banks: Array = two.pb2v.banks if two.game == 0 else two.solv.banks
			var pal: PackedByteArray = two.pb2v.palette if two.game == 0 else two.solv.palette
			var errors := 0
			for sy in range(24, 160, 3):
				for sx in range(8, 248, 5):
					# Independent oracle: use the collision system's world point,
					# then decode the original tile and palette, not shader scroll.
					var wx: int = two.view_x() + sx
					var wy: int = two.line_at(sy)
					var color: Color = Nes.colour(pal[0])
					if wx >= 0 and wy >= 0 and wx / 8 < map.get_width() and wy / 8 < map.get_height():
						var cell: Color = map.get_pixel(wx / 8, wy / 8)
						var tile: int = cell.r8
						var idx: int = int(banks[tile / 64]) * 64 + tile % 64
						var c: int = roundi(sheet.get_pixel((idx % 128) * 8 + wx % 8,
								(idx / 128) * 8 + wy % 8).r * 3)
						color = Nes.colour(pal[0 if c == 0 else cell.g8 * 4 + c])
					if img.get_pixel(sx, sy).to_rgba32() != color.to_rgba32():
						errors += 1
			check(errors == 0, "background %s camera=%d mismatched pixels=%d" % [Pb3List.say(Pb3List.records()[at]), offset, errors])
		s.leave()
	app.queue_free()
	await process_frame
