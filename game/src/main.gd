extends Node2D

## Э1: the picture.
##
## Loads a level of either game out of the exported data and draws it the way
## the console would.  Given `--shots=FILE` it draws a list of views and quits,
## which is how the acceptance check compares this engine against the original.

@onready var bg: ColorRect = $BG

var level_pb2: Pb2Level
var level_sol: SolLevel
var game := "pb2"
var scroll := Vector2i.ZERO
var origin := Vector2i.ZERO      # where on the screen the level's top left goes
var view_h := 240
var pal_tex: ImageTexture
var clock := Clock.new()
var pads: Array[Pad] = []


func _ready() -> void:
	var shots := ""
	var replay := ""
	var spawns := ""
	var stage := 0
	var area := 0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--game="): game = a.substr(7)
		elif a.begins_with("--stage="): stage = int(a.substr(8))
		elif a.begins_with("--area="): area = int(a.substr(7))
		elif a.begins_with("--scroll="):
			var p := a.substr(9).split(",")
			scroll = Vector2i(int(p[0]), int(p[1]))
		elif a.begins_with("--shots="): shots = a.substr(8)
		elif a.begins_with("--replay="): replay = a.substr(9)
		elif a.begins_with("--spawns="): spawns = a.substr(9)
	if replay != "":
		_run_replay(replay)
		get_tree().quit()
		return
	if spawns != "":
		_run_spawns(spawns)
		get_tree().quit()
		return
	if shots != "":
		await _run_shots(shots)
		get_tree().quit()
		return
	pads = [Pad.player_one(), Pad.player_two()]
	_load(game, stage, area)
	_apply()


## One line per picture: game stage area scroll_x scroll_y output_path
func _run_shots(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)
	for line in text.split("\n"):
		var f := line.strip_edges().split(" ")
		if f.size() < 6:
			continue
		_load(f[0], int(f[1]), int(f[2]))
		scroll = Vector2i(int(f[3]), int(f[4]))
		_apply()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(f[5])


## Play a recorded script of buttons and print what the hero did each frame.
##
## The file says which area to stand in, where to stand, and then one line per
## frame: the buttons held, the buttons pressed this frame, and where the
## camera was -- all taken off the real cartridge.  The engine must answer with
## the same positions.
func _run_replay(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	_load("pb2", int(cfg["stage"]), int(cfg["area"]))
	var p := Pb2Player.new(level_pb2)
	p.place(int(cfg["x"]), int(cfg["y"]), int(cfg["cam"]))
	p.x = int(cfg["x"])
	p.y = int(cfg["y"])
	p.vx = int(cfg["vx"])
	p.vy = int(cfg["vy"])
	p.anim_t = int(cfg["anim_t"])
	p.anim_i = int(cfg["anim_i"])
	p.state = int(cfg["state"])
	p.sub = int(cfg["sub"])
	p.pose = int(cfg["pose"])
	p.face_left = bool(cfg["face_left"])
	p.fall = int(cfg["fall"])
	p.ticks = int(cfg["tick"])
	# The view is the engine's own now: it is put where the recording found it
	# and after that decides for itself.
	var view := Pb2Camera.new(level_pb2)
	view.place(int(cfg["cam"]) >> 8, int(cfg["cam"]) & 0xFF,
			int(cfg["cam_pend"]), int(cfg["clock"]))
	var out := PackedStringArray()
	for f in cfg["frames"]:
		p.solids = f["solids"]
		p.held = int(f["hold"])
		p.push_x = int(f["push"][0])
		p.push_y = int(f["push"][1])
		# One step of the game slides the view once, moves him once and decides
		# once.  A step that spills over the end of a picture is seen twice by
		# the recording, but it is still the one step, not two.
		view.drive()
		p.shift = view.shift
		p.step(int(f["pad"]), int(f["hit"]), view.pos,
				int(f["shots"]), int(f["lim"]))
		view.decide(((p.y if level_pb2.vertical else p.x) >> 8) & 0xFF)
		out.append("%d %d %d %d %d %d %d %d" % [p.x, p.y, p.vx, p.vy,
				p.state, p.sub, p.pose, 1 if p.face_left else 0])
	print("\n".join(out))


var _cache := {}


func _load(g: String, stage: int, area: int) -> void:
	game = g
	var key := "%s/%d/%d" % [g, stage, area]
	if game == "pb2":
		level_pb2 = _cache.get(key, null)
		if level_pb2 == null:
			level_pb2 = Pb2Level.new(stage, area)
			_cache[key] = level_pb2
		level_sol = null
		pal_tex = Nes.palette_texture(level_pb2.palette)
		# Power Blade 2 hangs its level sixteen pixels below the top of the
		# screen and keeps the bottom sixty-four for the status bar.
		origin = Vector2i(0, 16)
		view_h = 160
	else:
		level_sol = _cache.get(key, null)
		if level_sol == null:
			level_sol = SolLevel.new(stage)
			_cache[key] = level_sol
		level_pb2 = null
		pal_tex = Nes.palette_texture(level_sol.palette)
		# Solbrain gives the level everything but the bottom sixteen lines.
		origin = Vector2i.ZERO
		view_h = 224


func _apply() -> void:
	var m: ShaderMaterial = bg.material
	var img: Image
	var size: Vector2
	var banks: Array
	if level_pb2 != null:
		img = level_pb2.map_image
		size = Vector2(level_pb2.width_tiles, level_pb2.height_tiles)
		banks = level_pb2.banks
	else:
		img = level_sol.map_image
		size = Vector2(level_sol.width_tiles, level_sol.height_tiles)
		banks = level_sol.banks
	m.set_shader_parameter("sheet", Nes.sheet(game))
	m.set_shader_parameter("map", ImageTexture.create_from_image(img))
	m.set_shader_parameter("palette", pal_tex)
	m.set_shader_parameter("map_size", size)
	m.set_shader_parameter("sheet_size", Nes.sheet(game).get_size())
	m.set_shader_parameter("banks", PackedInt32Array(banks))
	m.set_shader_parameter("scroll", Vector2(scroll - origin))
	m.set_shader_parameter("view_top", float(origin.y))
	m.set_shader_parameter("view_bottom", float(origin.y + view_h))


func _process(dt: float) -> void:
	if pads.is_empty():
		return
	# The logic runs on the console's clock, not the monitor's.
	for _i in range(clock.tick(dt)):
		_step()
	bg.material.set_shader_parameter("scroll", Vector2(scroll - origin))


## Until the players exist (Э2) this just walks the camera, so that scrolling
## and the clock can be watched working.
func _step() -> void:
	for p in pads:
		p.poll()
	var d := Vector2i.ZERO
	if pads[0].held & Pad.RIGHT: d.x += 2
	if pads[0].held & Pad.LEFT: d.x -= 2
	if pads[0].held & Pad.DOWN: d.y += 2
	if pads[0].held & Pad.UP: d.y -= 2
	scroll += d
	_clamp_camera()


func _clamp_camera() -> void:
	var w: int
	var h: int
	if level_pb2 != null:
		w = level_pb2.width_tiles * 8
		h = level_pb2.height_tiles * 8
	else:
		w = level_sol.width_tiles * 8
		h = level_sol.height_tiles * 8
	scroll.x = clampi(scroll.x, 0, max(0, w - 256))
	scroll.y = clampi(scroll.y, 0, max(0, h - view_h))


## Play the same recorded script, but watch the level's own list instead of the
## hero: which record turns into which slot, and where it lands.
##
## The engine has no minds for the things yet, so nothing it puts out ever dies
## of its own accord -- the deaths come from the recording, one list per step.
## Everything else is the engine's: the view, the walk of the list, the choice
## of slot.
func _run_spawns(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	_load("pb2", int(cfg["stage"]), int(cfg["area"]))
	var view := Pb2Camera.new(level_pb2)
	view.place(int(cfg["cam"]) >> 8, int(cfg["cam"]) & 0xFF,
			int(cfg["cam_pend"]), int(cfg["clock"]))
	var things := Pb2Objects.new(level_pb2)
	for n in range(cfg["slots"].size()):
		var r: Dictionary = cfg["slots"][n]
		var s: Pb2Objects.Slot = things.slots[n]
		s.type = int(r["type"])
		s.rec = int(r["rec"])
		s.x = int(r["x"])
		s.xhi = int(r["xhi"])
		s.y = int(r["y"])
		s.yhi = int(r["yhi"])
	# $E3F3 runs before $D924, so the scroll it looks at is the one before.
	var before := int(cfg["shift_before"])
	var out := PackedStringArray()
	for f in cfg["frames"]:
		var was := {}
		for n in range(Pb2Objects.FIRST_PLACED, Pb2Objects.LAST_PLACED + 1):
			was[n] = things.slots[n].rec
		things.scan(view.pos, before)
		var born := PackedStringArray()
		for n in range(Pb2Objects.FIRST_PLACED, Pb2Objects.LAST_PLACED + 1):
			var s: Pb2Objects.Slot = things.slots[n]
			if s.rec != was[n] and s.type != 0:
				born.append("%d:%d:%d:%d:%d" % [n, s.type, s.rec, s.x, s.y])
		view.drive()
		before = view.shift
		# $CF14 -- the view has moved, so everything standing on it moves back.
		things.shift(view.shift)
		view.decide(int(f["screen"]))
		# $CF1C, before any of them gets a turn.
		# The cartridge sweeps once a frame and a step of the game can take
		# two of them, so there is one table for each frame the sweep ran in,
		# and the sweep runs once against each.
		#
		# The table is told, not worked out: a thing that moves itself the
		# engine cannot yet place, and what is on trial here is the sweep's
		# answer, not the places.  How many it had right by itself is counted
		# and put out with the rest.
		var same := 0
		var seen := 0
		var gone := []
		for tbl in f["place"]:
			var place: Array = tbl
			for n in range(place.size()):
				# [type, $04F2, $0508, $04B0, $04C6].
				var p: Array = place[n]
				var s: Pb2Objects.Slot = things.slots[n]
				var had: int = s.type
				if int(p[0]) == 0:
					continue
				if had != int(p[0]):
					# Either something the engine never put out -- a shot, or
					# a piece of a thing that broke -- or a thing that has
					# turned into something else.  Both are told, place and
					# all, so that the sweep is asked what the cartridge asked:
					# what a thing is decides how far past the edge it is let.
					things.take(n, int(p[0]))
				if had != 0:
					seen += 1
					if s.xhi == int(p[1]) and s.x == int(p[2]) \
							and s.yhi == int(p[3]) and s.y == int(p[4]):
						same += 1
				s.xhi = int(p[1])
				s.x = int(p[2])
				s.yhi = int(p[3])
				s.y = int(p[4])
			gone.append_array(things.cull())
		# Where the view ended the step, what came alive in it, and what the
		# sweep threw away.  The view is put out too: it drives the scan, so a
		# scan that agrees only because the view was wrong in both would prove
		# nothing.
		out.append("%d|%s|%s|%d/%d" % [view.pos,
				" ".join(born) if born.size() else "-",
				" ".join(PackedStringArray(gone)) if gone.size() else "-",
				same, seen])
		for n in f["died"]:
			things.clear(int(n))
		for t in f["taken"]:
			things.take(int(t[0]), int(t[1]))
	print("\n".join(out))
