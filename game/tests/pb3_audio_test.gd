extends SceneTree
## Exercise the live scene and ordinary controller input, then inspect PCM.
var app: Node
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)

func peak(player: SndPlay) -> float:
	var value := 0.0
	for sample in player._pend:
		value = maxf(value, absf(sample))
	player._pend.clear()
	return value

func run() -> void:
	app = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	app._menu_took("pb3")
	app.pb3_setup = false
	for entry in [0, 63]:
		for heroes in [[0], [1], [0, 1]]:
			app.pb3_session = Pb3Session.new(heroes)
			app.pb3 = app.pb3_session
			app.pb3.at = entry
			check(app.pb3.enter(), "enter")
			app._pb3_enter()
			var music := 0.0
			var effects := 0.0
			for frame in range(150):
				for pad in app.pads:
					pad.handed = Pad.B if frame >= 60 and frame % 20 < 10 else 0
				app._step()
				var host_peak := peak(app.snd)
				var guest_peak := peak(app.snd_guest)
				if frame >= 30 and frame < 60: # Music before any attacks.
					music = maxf(music, host_peak)
				if frame >= 60: # Exclude the filters' power-on DC transient.
					effects = maxf(effects, guest_peak)
			check(music > 0.001, "silent host %s/%s" % [entry, heroes])
			var foreign: bool = heroes.has(1 if entry == 0 else 0)
			if foreign:
				check(effects > 0.001, "silent guest %s/%s" % [entry, heroes])
			if not foreign:
				check(effects < 0.001, "unexpected guest audio")
			print("audio entry=%d heroes=%s music=%.4f guest=%.4f" % [entry, heroes, music, effects])
			app._pb3_leave()
			check(app.snd == null and app.snd_guest == null, "sound persists on list")
			await process_frame
	# Every selectable room must name a valid native tune, including boss rooms.
	for entry in range(Pb3List.records().size()):
		app.pb3.at = entry
		check(app.pb3.enter(), "room enter %d" % entry)
		app._pb3_enter()
		check(app.pb3_tune > 0, "room tune %d" % entry)
		app._pb3_leave()
		await process_frame
	# Switching back to either standalone game must restore its driver.
	app._start_menu()
	app._menu_took("sol")
	check(app.snd != null and app.snd.game == "sol", "standalone sound not restored")
	app.queue_free()
	await process_frame
	print("PB3 AUDIO: %d failures" % failures)
	quit(1 if failures else 0)
