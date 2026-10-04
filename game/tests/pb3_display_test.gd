extends SceneTree
## GAP-17: real GPU rendering, native pixels translated without resampling.
## Placed entry fixtures verify presentation, not completed playthroughs.
var failures := 0
var checks := 0
var app: Node

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: ", label)

func frame() -> Image:
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func run() -> void:
	root.content_scale_size = Vector2i(256, 240)
	root.size = Vector2i(256, 240)
	app = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	app._menu_took("pb3")
	app.pb3_setup = false
	app.pb3_board.visible = false
	DirAccess.make_dir_recursive_absolute("/tmp/pb3-display")
	for entry in range(83):
		await fixture(entry, [0])
	for entry in [0, 1, 63]:
		await fixture(entry, [1])
		await fixture(entry, [0, 1])
	app._pb3_leave()
	check(not app.bg.material.get_shader_parameter("pb3_expanded"), "list resets presentation")
	print("GAP-17: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func fixture(entry: int, heroes: Array) -> void:
	if app.pb3.two != null:
		app.pb3.leave()
	var session := Pb3Session.new(heroes)
	session.at = entry
	check(session.enter(), "entry %d %s" % [entry, heroes])
	app.pb3_session = session
	app.pb3 = session
	app._pb3_enter()
	var m: ShaderMaterial = app.bg.material
	var expanded := await frame()
	var before: Array = []
	for i in range(heroes.size()):
		before.append(session.two.world_of(i))
	check(int(m.get_shader_parameter("view_bottom")) == 224, "224 lines %d" % entry)
	if entry < 63:
		check(m.get_shader_parameter("pb3_expanded"), "PB2 expanded")
		m.set_shader_parameter("pb3_expanded", false)
		m.set_shader_parameter("view_top", 16.0)
		m.set_shader_parameter("view_bottom", 176.0)
		var native := await frame()
		check(native.get_region(Rect2i(0,16,256,160)).get_data() ==
				expanded.get_region(Rect2i(0,32,256,160)).get_data(),
				"native background + both sprite tables unchanged %d %s" % [entry, heroes])
		if not session.two.pb2v.vertical:
			app._pb3_apply()
			for parameter in ["sprites_on", "sprites2_on", "sprites3_on"]:
				m.set_shader_parameter(parameter, false)
			var background := await frame()
			# Both extra strips repeat full source blocks, never invent tiles.
			check(background.get_region(Rect2i(0,16,256,16)).get_data() ==
					background.get_region(Rect2i(0,48,256,16)).get_data(), "top decoration %d" % entry)
			# No hero/object stands below the original room on entry.
			check(background.get_region(Rect2i(0,192,256,32)).get_data() ==
					background.get_region(Rect2i(0,160,256,32)).get_data(), "bottom decoration %d" % entry)
	else:
		check(not m.get_shader_parameter("pb3_expanded"), "Solbrain unchanged")
	for i in range(heroes.size()):
		check(before[i] == session.two.world_of(i), "presentation does not move hero")
	app._pb3_apply()
	if entry in [0,1,63] and heroes == [0,1]:
		app.pb3_board.visible = true
		var shown := await frame()
		shown.save_png("/tmp/pb3-display/entry-%d.png" % entry)
		app.pb3_board.visible = false
