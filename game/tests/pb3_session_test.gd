extends SceneTree

var failed := 0
var checks := 0
var sessions: Array[Pb3Session] = []


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, what: String) -> void:
	checks += 1
	if not ok:
		failed += 1
		print("FAIL: ", what)


func session(kinds: Array, at: int = 0) -> Pb3Session:
	var s := Pb3Session.new(kinds)
	s.at = at
	check(s.enter(), "enter %s %d" % [kinds, at])
	sessions.append(s)
	return s


func run() -> void:
	var configurations := [[0], [1], [0, 0], [0, 1], [1, 0], [1, 1]]
	if "--quick" in OS.get_cmdline_user_args():
		configurations = []
	var frames := 0
	# Every entry point and player arrangement, without health cheats.
	for kinds in configurations:
		for at in range(Pb3List.records().size()):
			var s: Pb3Session = session(kinds, at)
			for f in range(120):
				var words: Array = []
				for i in range(kinds.size()):
					words.append(Pad.RIGHT | (Pad.A if f % 30 < 3 else 0)
							| (Pad.B if (f + i * 4) % 12 < 3 else 0))
				var event: String = s.advance(s.tick, words)
				frames += 1
				if event == "list":
					break
				check(event != "rejected", "valid input rejected")
			check(s.tick > 0, "entry played %s %d" % [kinds, at])
			s.leave()
	print("Played %d entries without invulnerability: %d ticks"
			% [configurations.size() * 83, frames])
	transitions()
	deaths()
	ladders()
	equipment()
	replay()
	var pad := Pad.player_one()
	var tap := InputEventKey.new()
	tap.keycode = KEY_X
	tap.pressed = true
	pad.capture(tap)
	tap.pressed = false
	pad.capture(tap)
	pad.poll()
	check(pad.pressed == Pad.A, "short tap survives between ticks")
	pad.poll()
	check(pad.pressed == 0, "short tap is delivered once")
	await ui()
	for s in sessions:
		s.leave()
	sessions.clear()
	print("%d of %d session checks failed" % [failed, checks])
	quit(1 if failed else 0)


func transitions() -> void:
	var s: Pb3Session = session([0, 1])
	var old: Pb3Pair = s.two
	s.two.host_pb2.area = 1
	s.two.ended = Pb2Turn.NEXT_AREA
	check(s.resolve() == "changed", "PB2 door consumed")
	check(s.two != old and s.two.area == 1, "PB2 destination loaded")
	check(s.two.came == 0, "PB2 origin preserved")
	s.two.host_pb2.phase = 1
	s.two.ended = Pb2Turn.INTERLUDE
	check(s.resolve() == "changed", "interlude consumed")
	check(s.two.host_pb2.phase == 1, "interlude phase preserved")
	s.two.host_pb2.boss = 1
	s.two.host_pb2.area = 0
	s.two.ended = Pb2Turn.NEXT_AREA
	check(s.resolve() == "changed" and s.two.stage == 6,
			"boss destination loaded")
	s.two.host_pb2.beat = true
	s.two.ended = Pb2Turn.NEXT_AREA
	check(s.resolve() == "list" and s.two == null, "boss returns to list")
	for mode in [SolFlow.DOOR, 0x40]:
		s = session([0, 1], 63)
		s.two.host_sol.stage = 1
		s.two.host_script.p(0x02, mode)
		check(s.resolve() == "changed" and s.two.stage == 1,
				"Solbrain destination %d" % mode)
		check(s.two.host_script.g(0x02) == 0, "transition consumed once")
	for mode in [SolFlow.CLEAR, SolFlow.END_PAY]:
		s = session([1], 63)
		s.two.host_script.p(0x02, mode)
		check(s.resolve() == "list", "Solbrain clear returns to list")
	# Exercise a real script exit, not only an injected outcome. $A87C
	# requires suit != 0; a team of Novas used to have an inert dummy here.
	s = session([0, 0], 64)
	s.two._stand_in()
	check(s.two.turn_sol.script_proxy, "foreign team has script actor")
	s.two.host_script.pack(s.two.host_sol, s.two.spare_sol,
			s.two.sol_eye, s.two.host_table, null)
	s.two.host_script.p(0x81, 0xEE)
	s.two.host_script._xA87C()
	s.two.host_script.unpack(s.two.host_sol, s.two.spare_sol,
			s.two.sol_eye, s.two.host_table, null)
	check(s.resolve() == "changed" and s.two.stage == 2,
			"foreign team can trigger native Solbrain exit")


func deaths() -> void:
	var s: Pb3Session = session([0, 1])
	s.two.things[0].slots[0][Pb2Objects.F_LIFE] = 0
	check(s.resolve() == "playing" and s.two.gone[0],
			"one death keeps teammate playing")
	var draw := Pb3Draw.new(s.two)
	var without_hero: Array = s.two.host_pb2.slots.duplicate()
	without_hero[0] = Pb2Objects.empty_row()
	var blank := PackedByteArray()
	blank.resize(Pb2Sprites.OAM)
	blank.fill(Pb2Sprites.HIDDEN)
	var expected := Pb2Sprites.build(without_hero, 0, blank)
	check(draw.oam == expected, "dead Nova contributes no sprites to the host table")
	s.two.sol[1].state = 0x0E
	check(s.resolve() == "list" and s.two == null, "team death exits")
	check(s.enter() and s.two.alive(), "retry restores players")
	s = session([1], 63)
	s.two.sol[0].suit = 0
	check(s.resolve() == "playing", "unarmoured Solbrain is alive")
	s.two.sol[0].state = 0x0E
	check(s.resolve() == "list", "solo death exits")
	s = session([1, 0], 63)
	s.two.sol[0].state = 0x0E
	s.resolve()
	s.two._stand_in()
	check(s.two.turn_sol.hero == s.two.spare_sol,
			"dead host no longer anchors surviving guest's script")


func equipment() -> void:
	for at in [0, 63]:
		var s: Pb3Session = session([0, 1], at)
		s.gear.st[0].suit = 2
		s.gear.gun[1] = 3
		s.advance(0, [0, 0])
		check(s.two.pb2[0].suit == 2, "selected suit reaches physics")
		var pool: SolObjects = s.two.host_sol if s.two.host == 1 \
				else s.two.guest_pool[1]
		check(pool.mind[SolObjects.SAT] == 2, "selected gun reaches pool")
		var pos: Vector2i = s.two.world_of(0)
		s.advance(1, [0, Pad.START])
		s.advance(2, [Pad.RIGHT, 0])
		check(s.two.world_of(0) == pos, "equipment menu pauses team")


func ladders() -> void:
	# Find an actual exported ladder, with at least three consecutive cells.
	var tested := false
	for at in range(63):
		var rec: Array = Pb3List.records()[at]
		var lv := Pb2Level.new(rec[1], rec[2])
		for y in range(48, lv.height_tiles * 8 - 32, 16):
			for x in range(8, lv.width_tiles * 8, 16):
				if lv.class_byte(x, y) != 1 or lv.class_byte(x, y - 16) != 1 \
						or lv.class_byte(x, y - 32) != 1:
					continue
				var s: Pb3Session = session([1], at)
				s.two.release()
				s.two = Pb3Pair.new(0, rec[1], rec[2], [1])
				s.two.begin([Vector2i(x, y)], true)
				s.prepare()
				var before: Vector2i = s.two.world_of(0)
				for _f in range(6):
					check(s.two._sol_traversal(0, Pad.UP), "Solbrain grabs ladder")
				check(s.two.world_of(0).y < before.y, "Solbrain climbs up")
				var hold: Vector2i = s.two.world_of(0)
				s.two._sol_traversal(0, 0)
				check(s.two.world_of(0).y == hold.y, "ladder holds without input")
				s.two._sol_traversal(0, Pad.A)
				check(s.two.climbers.is_empty(), "jump releases ladder")
				tested = true
				break
			if tested:
				break
		if tested:
			break
	check(tested, "tested a real PB2 ladder")
	# Reproduce p0.1's climb-to-floor handoff, then wait and walk off the lip.
	# Diagnostic placement, not a room-completion certificate.
	var top: Pb3Session = session([1], 1)
	top.two.place_at(0, Vector2i(56, 128))
	for f in range(100):
		top.advance(top.tick, [Pad.UP])
	check(top.two.world_of(0).y == 64, "Solbrain dismounts ladder onto surface")
	for f in range(30):
		top.advance(top.tick, [0])
	check(top.two.world_of(0).y == 64, "Solbrain stands on ladder top without falling back")
	for f in range(20):
		top.advance(top.tick, [Pad.RIGHT])
	check(top.two.world_of(0).x > 64 and top.two.world_of(0).y == 64,
			"Solbrain walks from ladder onto adjacent platform")
	top.leave()
	var s: Pb3Session = session([1])
	s.two.place_at(0, Vector2i(100, s.two.solv.height_tiles * 8 + 1))
	s.two._hold_them_in()
	check(s.two.gone[0], "fall below map is not held by camera")


func replay() -> void:
	var a: Pb3Session = session([0, 1])
	var b: Pb3Session = session([0, 1])
	check(a.advance(1, [0, 0]) == "rejected" and a.tick == 0,
			"out of order frame rejected")
	check(a.advance(0, [-1, 0]) == "rejected" and a.tick == 0,
			"invalid button word rejected")
	for f in range(100):
		var words := [Pad.RIGHT | (Pad.A if f % 23 < 4 else 0), Pad.RIGHT]
		check(a.advance(f, words) == b.advance(f, words), "same event")
		if a.two == null or b.two == null:
			break
		for i in range(2):
			check(a.two.world_of(i) == b.two.world_of(i), "replayed position")
	check(a.advance(0, [0, 0]) == "rejected", "duplicate tick rejected")


func press(app: Node, one: int, two: int = 0) -> void:
	app.pads[0].handed = one
	app.pads[1].handed = two
	app._step()
	app.pads[0].handed = 0
	app.pads[1].handed = 0
	app._step()


func ui() -> void:
	var app: Node = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	# The test starts by command line, so use the same route as the menu.
	if app.menu != null:
		app._menu_took("pb3")
	else:
		app._start_pb3()
	check(app.pb3_setup, "PB3 opens character selection")
	await capture("setup")
	press(app, Pad.START)
	check(not app.pb3_setup, "selection leads to level list")
	await capture("levels")
	press(app, Pad.DOWN)
	check(app.pb3.at == 1, "down navigates list")
	press(app, Pad.UP)
	press(app, Pad.START)
	check(app.pb3.two.who.size() == 1, "solo starts one hero")
	press(app, Pad.SELECT)
	check(app.pb3.two == null, "return from level")
	press(app, Pad.B)
	check(app.pb3_setup, "return to character selection")
	press(app, Pad.RIGHT)
	check(app.pb3_players == 2, "two players selectable")
	press(app, Pad.START)
	press(app, Pad.A)
	check(app.pb3.two.who.size() == 2, "co-op starts two heroes")
	app.pb3.two.place_at(1, app.pb3.two.world_of(0) + Vector2i(-48, 0))
	for _f in range(12):
		app.pb3_session.advance(app.pb3_session.tick, [0, 0])
	app.pb3_draw.after_step(app.pb3_gear)
	app._pb3_show()
	await capture("coop")
	app.pb3.two.host_pb2.area = 1
	app.pb3.two.host_pb2.live = 6
	app._step()
	check(app.pb3.two.area == 1, "live UI consumes door transition")
	press(app, Pad.SELECT)
	# Both foreign characters require two guest render tables.
	app.pb3_session = Pb3Session.new([1, 1])
	app.pb3 = app.pb3_session
	app.pb3.enter()
	app._pb3_enter()
	app.pb3.two.place_at(1, app.pb3.two.world_of(0) + Vector2i(-48, 0))
	for _f in range(12):
		app.pb3_session.advance(app.pb3_session.tick, [0, 0])
	app.pb3_draw.after_step(app.pb3_gear)
	app.pb3_extra.after_step(app.pb3_gear)
	for i in range(2):
		check(app.pb3.two.sol[i].draw_id >= 0,
				"foreign hero has body animation, not only a weapon")
	check(app.pb3_extra != null and app.pb3_extra.guest == 1,
			"second foreign character has render layer")
	app._pb3_show()
	check(app.bg.material.get_shader_parameter("sprites3_on"),
			"third render layer enabled")
	var both: Image = await capture("two_foreign_heroes")
	if both != null:
		app.bg.material.set_shader_parameter("sprites3_on", false)
		var one: Image = await capture("one_foreign_hero")
		var changed := 0
		var feet: Vector2i = app.pb3.two.screen_of(1)
		for y in range(feet.y - 32, feet.y):
			for x in range(feet.x - 8, feet.x + 8):
				if both.get_pixel(x, y) != one.get_pixel(x, y):
					changed += 1
		check(changed > 50, "second foreign body is rendered at its position")
		app.bg.material.set_shader_parameter("sprites3_on", true)
	press(app, Pad.SELECT)
	check(not app.bg.material.get_shader_parameter("sprites3_on"),
			"third layer cleared on exit")
	app.queue_free()
	await process_frame


func capture(name: String) -> Image:
	if "--capture" not in OS.get_cmdline_user_args():
		return null
	await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var path: String = ProjectSettings.globalize_path("res://../docs/qa")
	DirAccess.make_dir_recursive_absolute(path)
	img.save_png(path.path_join(name + ".png"))
	return img
