extends SceneTree
## Ordinary-input route evidence through the real gameplay renderer.
## --trace-only avoids rendering while finding controller timings.
var app: Node
var session: Pb3Session
var folder := "res://../docs/qa/nova-net"
var trace_only := false
var route := "res://../docs/qa/playthrough/s0-nova/replay.json"
var max_ticks := 2800
var captured: Array = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--trace-only": trace_only = true
		elif arg.begins_with("--route="): route = arg.trim_prefix("--route=")
		elif arg.begins_with("--folder="): folder = arg.trim_prefix("--folder=")
		elif arg.begins_with("--ticks="): max_ticks = int(arg.trim_prefix("--ticks="))
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	if not trace_only:
		app = load("res://src/main.tscn").instantiate()
		root.add_child(app)
		app.set_process(false)
		if app.menu != null: app._menu_took("pb3")
		else: app._start_pb3()
		app.pb3_setup = false
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(route))
	var kinds: Array = []
	for hero in rec.heroes: kinds.append(int(hero))
	session = Pb3Session.new(kinds)
	session.at = int(rec.entry)
	session.enter()
	if not trace_only:
		app.pb3_session = session
		app.pb3 = session
		app._pb3_enter()
	var trace: Array = []
	var events: Array = []
	var grip_ticks := 0
	for part in rec.steps:
		var words: Array = []
		for i in range(1,part.size()): words.append(int(part[i]))
		for _frame in range(int(part[0])):
			if session.two == null or session.tick >= max_ticks: break
			var event := session.advance(session.tick,words)
			if event != "playing": events.append({"tick":session.tick,"entry":session.at,"event":event,"message":session.message})
			if session.two == null: break
			if event == "changed" and not trace_only: app._pb3_enter()
			var players: Array = []
			var gripping := false
			for i in range(kinds.size()):
				var at := session.two.world_of(i)
				var p := {"world":[at.x,at.y],"alive":not session.two.gone[i]}
				if kinds[i] == 0:
					var q: Pb2Player = session.two.pb2[i]
					p.merge({"sub":q.sub,"pose":q.pose,"drawing":q.drawing_pose(),"vy":q.vy,"suit":q.suit,"life":session.two.things[i].slots[0][Pb2Objects.F_LIFE]})
					gripping = gripping or q.sub==Pb2Player.SUB_NET
				else:
					var q: SolPlayer = session.two.sol[i]
					p.merge({"state":q.state,"frame":q.draw_id,"life":q.suit})
					gripping = gripping or q.state in [8,9,10,11]
				players.append(p)
			var row := {"tick":session.tick,"pads":words,"players":players,"view":[session.two.view_x(),session.two.sol_eye.y>>4],"held":session.two.ended==Pb2Turn.HELD}
			trace.append(row)
			if gripping: grip_ticks += 1
			if trace_only:
				if session.tick%100==0 or (gripping and grip_ticks<4): print(JSON.stringify(row))
			else:
				app.pb3_draw.after_step(app.pb3_gear)
				if app.pb3_extra != null: app.pb3_extra.after_step(app.pb3_gear)
				app.pb3_board.show_bar(app.pb3_gear,session.two)
				app._pb3_show()
				# Capture all ticks explicitly selected by the input recording.
				var selected := false
				for span in rec.get("capture",[]):
					selected = selected or (session.tick>=int(span[0]) and session.tick<=int(span[1]))
				if selected or session.tick%60==0: await process_frame
				if selected:
					RenderingServer.force_draw()
					root.get_texture().get_image().save_png(folder+"/game-%04d.png"%session.tick)
					captured.append(row)
	var f := FileAccess.open(folder+"/trace.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(trace))
	f = FileAccess.open(folder+"/capture.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"source":route,"evidence":"ordinary input from native entry","events":events,"final_entry":session.at,"final_tick":session.tick,"grip_ticks":grip_ticks,"frames":captured},"  "))
	print("Ordinary input: ",session.tick," ticks, ",grip_ticks," grip ticks, events ",events)
	session.leave()
	quit()
