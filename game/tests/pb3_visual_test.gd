extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func shot(app: Node, name: String) -> void:
	app.pb3_draw.after_step(app.pb3_gear)
	app._pb3_show()
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://../docs/qa/" + name + ".png")

func run() -> void:
	var app: Node = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	if app.menu != null:
		app._menu_took("pb3")
	else:
		app._start_pb3()
	app.pb3_setup = false
	for kinds in [[0,1], [1,0]]:
		var s := Pb3Session.new(kinds)
		s.two = Pb3Pair.new(0,0,1,kinds)
		s.two.begin([Vector2i(72,303), Vector2i(72,303)], true)
		s.prepare()
		app.pb3_session = s
		app.pb3 = s
		app._pb3_enter()
		for f in range(36):
			var pads: Array = []
			for i in range(2):
				var start: int = 8 + i * 12
				pads.append(0 if f < start else Pad.DOWN | Pad.RIGHT | (Pad.A if f == start else 0))
			s.advance(s.tick, pads)
		await shot(app, "tunnel_%d_%d" % kinds)
		print("VISUAL tunnel ", kinds, " positions=", s.two.world_of(0), ",", s.two.world_of(1), " compact=", s.two.sol[1 if kinds[1] == 1 else 0].bridge_compact)
		s.leave()
	var s := Pb3Session.new([1,1])
	s.at = 63
	s.enter()
	s.two.place_at(1, s.two.world_of(0) + Vector2i(48,0))
	app.pb3_session = s
	app.pb3 = s
	app._pb3_enter()
	for f in range(40):
		s.advance(s.tick, [0,0])
	await shot(app, "solbrain_two_players_fixed")
	s.leave()
	app.queue_free()
	await process_frame
	print("Visual captures complete")
	quit()
