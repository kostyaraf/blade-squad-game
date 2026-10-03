extends SceneTree
## Visual evidence from the existing ordinary-input room route; no state injection.
var app: Node
var session: Pb3Session
var folder := "res://../docs/qa/solbrain-animation"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	app = load("res://src/main.tscn").instantiate()
	root.add_child(app)
	app.set_process(false)
	if app.menu != null:
		app._menu_took("pb3")
	else:
		app._start_pb3()
	app.pb3_setup = false
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
		"res://../docs/qa/playthrough/p0.1-sol/replay.json"))
	session = Pb3Session.new([1])
	session.at = int(rec.entry)
	session.enter()
	app.pb3_session = session
	app.pb3 = session
	app._pb3_enter()
	var captured: Array = []
	for part in rec.steps:
		for _frame in range(int(part[0])):
			var event := session.advance(session.tick,[int(part[1])])
			if event == "changed":
				app._pb3_enter()
			if session.two == null:
				break
			app.pb3_draw.after_step(app.pb3_gear)
			app.pb3_board.show_bar(app.pb3_gear,session.two)
			app._pb3_show()
			var tick: int = session.tick
			var selected: bool = (tick >= 128 and tick <= 166) or (tick >= 500 and tick <= 538)
			if selected or tick % 30 == 0:
				await process_frame
			if selected:
				RenderingServer.force_draw()
				root.get_texture().get_image().save_png(folder + "/game-%04d.png" % tick)
				captured.append({"tick":tick,"frame":session.two.sol[0].bridge_frame,
					"world":str(session.two.world_of(0)),"view":[session.two.view_x(),session.two.eye.pos if session.two.pb2v.vertical else 0]})
	var f := FileAccess.open(folder + "/game-capture.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"route":"p0.1-sol/replay.json","frames":captured,"final_entry":session.at,"final_tick":session.tick},"  "))
	print("Captured traversal from ordinary input; exit entry=",session.at," tick=",session.tick)
	quit()
