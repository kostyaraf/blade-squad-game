extends SceneTree
## Interactive QA runner: only normal input frames, never pokes game state.
## Commands: {id, start: menu_index, heroes: [0|1]} or {id, steps:[[ticks,pad...]]}.
## An explicit start resets the run; input batches never reset or teleport.
var app: Node
var session: Pb3Session
var seen := -1
var busy := false
var replay: Dictionary
var folder := "res://../docs/qa/playthrough"

func _initialize() -> void:
	call_deferred("boot")

func boot() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	app = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	if app.menu != null:
		app._menu_took("pb3")
	else:
		app._start_pb3()
	app.pb3_setup = false
	process_frame.connect(poll)

func poll() -> void:
	if busy or not FileAccess.file_exists(folder + "/command.json"):
		return
	var cmd = JSON.parse_string(FileAccess.get_file_as_string(folder + "/command.json"))
	if not cmd is Dictionary or int(cmd.get("id", -1)) <= seen:
		return
	busy = true
	seen = int(cmd.id)
	if cmd.has("start"):
		if session != null:
			session.leave()
		var kinds: Array = []
		for hero in cmd.heroes:
			kinds.append(int(hero))
		session = Pb3Session.new(kinds)
		session.at = int(cmd.start)
		session.enter()
		app.pb3_session = session
		app.pb3 = session
		app._pb3_enter()
		replay = {"entry": int(cmd.start), "heroes": cmd.heroes, "steps": [], "events": []}
	var trace: Array = []
	for part in cmd.get("steps", []):
		var words: Array = []
		for i in range(1, part.size()):
			words.append(int(part[i]))
		var consumed := 0
		var remaining := int(part[0])
		while remaining > 0:
			if session.two == null:
				break
			var event := session.advance(session.tick, words)
			consumed += 1
			# Optional controller macro: wait out a refill/final suit-change
			# frame with the same buttons. Record EVERY actual input frame.
			var waiting := false
			if cmd.get("settle_pauses",false) and session.two != null:
				waiting = session.two.ended == Pb2Turn.HELD
				for i in range(words.size()):
					if session.gear.menu_open(i): waiting = false
			if not waiting or consumed > int(part[0])+300: remaining -= 1
			if event != "playing":
				replay.events.append({"tick":session.tick,"event":event,"entry":session.at,"message":session.message})
				if event == "changed":
					app._pb3_enter()
			trace.append(status())
			if session.two != null:
				app.pb3_draw.after_step(app.pb3_gear)
				app.pb3_board.show_bar(app.pb3_gear, session.two)
				app._pb3_show()
			# Render every simulated frame; waits are not game ticks.
			if not cmd.get("fast", false) or session.tick % 30 == 0:
				await process_frame
		if consumed > 0:
			replay.steps.append([consumed] + words)
	if session != null and session.two != null:
		app.pb3_draw.after_step(app.pb3_gear)
		app.pb3_board.show_bar(app.pb3_gear, session.two)
		app._pb3_show()
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(folder + "/current.png")
	write_json("replay.json", replay)
	write_json("trace.json", trace)
	var result := status()
	result["id"] = seen
	write_json("state.json", result)
	print(JSON.stringify(result))
	busy = false

func status() -> Dictionary:
	var result := {"tick":session.tick,"entry":session.at,"message":session.message,"players":[],"enemies":[]}
	if session.two == null:
		return result
	var pair := session.two
	result["ended"] = pair.ended
	result["view"] = [pair.view_x(), pair.sol_eye.y >> 4 if pair.game == 1 else pair.eye.pos if pair.pb2v.vertical else 0]
	for i in range(pair.who.size()):
		var pos := pair.world_of(i)
		var player := {"x":pos.x,"y":pos.y,"alive":not pair.gone[i]}
		if pair.who[i] == 0:
			var p: Pb2Player = pair.pb2[i]
			player.alive = player.alive and pair.things[i].slots[0][Pb2Objects.F_LIFE] > 0
			player.merge({"sub":p.sub,"vy":p.vy,"state":p.state,"life":pair.things[i].slots[0][Pb2Objects.F_LIFE],
					"suit":p.suit,"menu":session.gear.st[i].menu,"status_mode":session.gear.st[i].mode,
					"energy":session.gear.energy,"owned":session.gear.st[i].owned})
		else:
			var p: SolPlayer = pair.sol[i]
			player.alive = player.alive and p.state not in [0x0C, 0x0E]
			player.merge({"state":p.state,"life":p.suit,
					"traversal_frame":p.bridge_frame,"slide_attack":p.bridge_slide})
		result.players.append(player)
	if pair.host_pb2 != null:
		for n in range(Pb2Objects.FIRST_LIVE,Pb2Objects.SLOTS):
			var s: PackedByteArray = pair.host_pb2.slots[n]
			if s[Pb2Objects.F_TYPE] != 0:
				result.enemies.append({"slot":n,"type":s[Pb2Objects.F_TYPE],"life":s[Pb2Objects.F_LIFE],"stun":s[Pb2Objects.F_STUN],"state":s[Pb2Objects.F_STATE],"x":s[Pb2Objects.F_X],"y":s[Pb2Objects.F_Y]})
	if pair.host_sol != null:
		var o := pair.host_sol
		result["sol_bonus"] = o.hero_bonus
		result["sol_letters"] = o.letters
		result["projectiles"] = []
		result["projectile_render_connected"] = o.table != null
		for n in range(SolObjects.SHOTS):
			if o.s_kind[n] != 0:
				result.projectiles.append({"slot":n,"kind":o.s_kind[n],"x":o.s_x[n] >> 4,"y":o.s_y[n] >> 4})
		for n in range(16):
			if o.id[n] != 0:
				result.enemies.append({"slot":n,"id":o.id[n],"mind":o.mind[n],"life":o.life[n],"x":o.x[n]>>4,"y":o.y[n]>>4})
	return result

func write_json(name: String, value: Variant) -> void:
	var f := FileAccess.open(folder + "/" + name, FileAccess.WRITE)
	f.store_string(JSON.stringify(value))
