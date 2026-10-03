extends SceneTree
## NPB2-41: diagnostic PPU snapshots certify raster rendering, not a route.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	var app: Node = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	if app.menu != null:
		app._menu_took("pb3")
	else:
		app._start_pb3()
	app.pb3_setup = false
	for case in cfg.cases:
		var session := Pb3Session.new([0])
		session.at = Pb3List.records().find([0, 1, 0])
		session.enter()
		app.pb3_session = session
		app.pb3 = session
		app._pb3_enter()
		var world: Pb2Objects = session.two.host_pb2
		world.water = int(case.water)
		world.draw = int(case.draw)
		world.storm = int(case.cycle)
		session.two.eye.pos = int(case.cam)
		app.pb3_draw.after_step(session.gear)
		app.pb3_draw.palette = PackedByteArray(case.palette)
		app._pb3_show()
		app.pb3_board.hide()
		var m: ShaderMaterial = app.bg.material
		m.set_shader_parameter("sprites_on", false)
		m.set_shader_parameter("sprites2_on", false)
		m.set_shader_parameter("sprites3_on", false)
		await process_frame
		await RenderingServer.frame_post_draw
		var image: Image = app.get_viewport().get_texture().get_image()
		image.save_png(case.out)
		session.leave()
	print("NPB2-41 raster: ", cfg.cases.size(), " GPU frames saved")
	quit(0)
