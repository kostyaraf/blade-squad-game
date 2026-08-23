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
		var s: PackedByteArray = things.slots[n]
		s[Pb2Objects.F_TYPE] = int(r["type"])
		s[Pb2Objects.F_REC] = int(r["rec"])
		s[Pb2Objects.F_X] = int(r["x"])
		s[Pb2Objects.F_XHI] = int(r["xhi"])
		s[Pb2Objects.F_Y] = int(r["y"])
		s[Pb2Objects.F_YHI] = int(r["yhi"])
	# The running copy of the cartridge's own table, which the steps below
	# keep up to date and against which the engine is judged.
	var truth: Array = []
	for n in range(Pb2Objects.SLOTS):
		truth.append(Pb2Objects.empty_row())
	# $E3F3 runs before $D924, so the scroll it looks at is the one before.
	var before := int(cfg["shift_before"])
	# The things that were already out when the recording began were handed
	# above only their type and their place: the rest of what they are is
	# whatever the cartridge had made of them over turns the engine never saw.
	# So the first hand-over tells everything, minds and all, and only from
	# the second is the engine held to its own work.
	var first_told := false
	var out := PackedStringArray()
	for f in cfg["frames"]:
		var was := {}
		for n in range(Pb2Objects.FIRST_PLACED, Pb2Objects.LAST_PLACED + 1):
			was[n] = things.slots[n][Pb2Objects.F_REC]
		# The engine has no minds, so nothing it puts out is ever picked
		# up and nothing ever reports itself done: both are told.
		things.got = int(f["got"])
		# Every number JSON hands back is a float; the list is put
		# back into words the engine can compare here, once.
		var d := []
		for v in f["done"]:
			d.append(int(v))
		things.done = d
		things.scan(view.pos, before)
		var born := PackedStringArray()
		for n in range(Pb2Objects.FIRST_PLACED, Pb2Objects.LAST_PLACED + 1):
			var s: PackedByteArray = things.slots[n]
			if s[Pb2Objects.F_REC] != was[n] and s[Pb2Objects.F_TYPE] != 0:
				born.append("%d:%d:%d:%d:%d" % [n, s[Pb2Objects.F_TYPE],
						s[Pb2Objects.F_REC], s[Pb2Objects.F_X],
						s[Pb2Objects.F_Y]])
		view.drive()
		before = view.shift
		# The minds read the map through the view, as the hero does.
		things.cam = view.pos
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
		# How many times a place was left to a mind of the engine's own.  A
		# run in which this is nought has proved nothing about the minds.
		var mine := 0
		var gone := []
		# Every field of every place whose type the engine drives itself and
		# got wrong: place, field, what it said, what the cartridge said.
		var wrong := PackedStringArray()
		# $CF14 -- the view has moved, so everything standing on it moves back.
		#
		# A step of the game can run over more than one frame of the console,
		# and the view slides a pixel at a time in each of them, so the slide
		# of a step is not one number but a handful, and it is told.  The
		# engine's own view is not asked for it: where the view stands at the
		# head of a step is the engine's answer and is judged as such above,
		# but which frame inside the step laid down which pixel of the slide
		# it has no way to say -- the cartridge counts steps of its own that
		# do not line up with the console's frames at all.
		var i_tbl := -1
		for tbl in f["whole"]:
			i_tbl += 1
			# What changed since the last hand-over: the place's number and
			# then its twenty-nine bytes.  Everything else still stands.
			for chg in tbl:
				var row: PackedByteArray = truth[int(chg[0])]
				for k in range(Pb2Objects.FIELDS):
					row[k] = int(chg[k + 1])
			# The table is written down at $CF14, and three things run before
			# it: the hero's own step at $CEFD, the touch sweep at $CF08 and
			# the slide back at $CF14 itself.  So the row handed over is his
			# as he stood when the sweep looked at him, and the engine has to
			# put him there before it runs its own sweep.
			# The first six places are his and his alone: himself and the
			# five shots he throws.  All six are made and moved by the code
			# that runs before the sweep, and none of them is touched by the
			# sweep itself, so all six can be handed over here -- and must be,
			# or a shot thrown this very step would be a step late in hurting
			# what it hit.
			for n_his in range(Pb2Objects.FIRST_LIVE):
				var his: PackedByteArray = things.slots[n_his]
				var his_told: PackedByteArray = truth[n_his]
				if his[Pb2Objects.F_TYPE] != his_told[Pb2Objects.F_TYPE]:
					things.take(n_his, his_told[Pb2Objects.F_TYPE])
					his = things.slots[n_his]
				for k in range(Pb2Objects.FIELDS):
					if k != Pb2Objects.F_REC:
						his[k] = his_told[k]
			# $1C -- which half of the table the sweep looks at this time.
			things.frame = int(f["ticks"][i_tbl])
			things.suit = int(f["suits"][i_tbl])
			# His forty pictures of grace were counted down on the cartridge
			# before the row was written down, so the sweep must not count
			# them again.
			things.hero_told = true
			things.contact()
			things.shift(int(f["shifts"][i_tbl]))
			# $0119 -- half the questions a thing asks about the ground it
			# only asks on the frames where this and its own place in the
			# table agree in the lowest bit, and takes a settled answer on
			# the rest.  It is the cartridge's count, not the engine's, so
			# it comes with the table.
			things.clock = int(f["turns"][i_tbl])
			# The seed is one for the whole game and every mind that takes
			# a number leaves the next one behind, so an engine holding only
			# some of the minds cannot keep it in step: it is told until
			# they are all here.
			things.seed = int(f["seeds"][i_tbl])
			for n in range(Pb2Objects.SLOTS):
				var was_told: PackedByteArray = truth[n]
				var s: PackedByteArray = things.slots[n]
				var had: int = s[Pb2Objects.F_TYPE]
				# The hero keeps nought in the field that says what a thing
				# is -- he is not one of the things the list puts out -- so an
				# empty place is only empty from the sixth on.  His own row
				# has to be handed over all the same: the minds look at where
				# he stands to decide which way to face.
				if was_told[Pb2Objects.F_TYPE] == 0 \
						and n >= Pb2Objects.FIRST_LIVE:
					continue
				if had != was_told[Pb2Objects.F_TYPE]:
					# Either something the engine never put out -- a shot, or
					# a piece of a thing that broke -- or a thing that has
					# turned into something else.  Both are told, place and
					# all, so that the sweep is asked what the cartridge asked:
					# what a thing is decides how far past the edge it is let.
					things.take(n, was_told[Pb2Objects.F_TYPE])
				if had != 0:
					seen += 1
					if s[Pb2Objects.F_XHI] == was_told[Pb2Objects.F_XHI] \
							and s[Pb2Objects.F_X] == was_told[Pb2Objects.F_X] \
							and s[Pb2Objects.F_YHI] == was_told[Pb2Objects.F_YHI] \
							and s[Pb2Objects.F_Y] == was_told[Pb2Objects.F_Y]:
						same += 1
				# Judged only where the engine could have got it right by
				# itself: a place the turn walks over at all (the first six
				# are the hero and his shots, which no mind drives), holding
				# a thing the engine put out itself and has held since.  A
				# place the engine never filled, or filled with something
				# else, it has never had a turn at, and telling it is the
				# only honest thing to do.
				if first_told \
						and had == was_told[Pb2Objects.F_TYPE] \
						and n >= Pb2Objects.FIRST_LIVE \
						and Pb2Objects.MINDS.has(had):
					mine += 1
					# This one drives itself, so it is judged, not told.  The
					# record's number is the engine's own and is left out of
					# both; so is the type, which take() above has settled.
					for k in range(Pb2Objects.FIELDS):
						if k == Pb2Objects.F_REC or k == Pb2Objects.F_TYPE:
							continue
						if s[k] != was_told[k]:
							wrong.append("%d:%d:%d:%d" % [n, k, s[k],
									was_told[k]])
					if wrong.size() > 0:
						wrong.append("hero=%d.%d thing=%d.%d/%d.%d" % [
								things.slots[0][Pb2Objects.F_XHI],
								things.slots[0][Pb2Objects.F_X],
								s[Pb2Objects.F_XHI], s[Pb2Objects.F_X],
								was_told[Pb2Objects.F_XHI],
								was_told[Pb2Objects.F_X]])
					continue
				# The rest have no mind of their own yet, so all of it is
				# told -- every field but the record's number, which is the
				# engine's own answer and must not be handed to it.
				for k in range(Pb2Objects.FIELDS):
					if k != Pb2Objects.F_REC:
						s[k] = was_told[k]
			first_told = true
			gone.append_array(things.turns())
		# Where the view ended the step, what came alive in it, and what the
		# sweep threw away.  The view is put out too: it drives the scan, so a
		# scan that agrees only because the view was wrong in both would prove
		# nothing.
		out.append("%d|%s|%s|%d/%d/%d|%s" % [view.pos,
				" ".join(born) if born.size() else "-",
				" ".join(PackedStringArray(gone)) if gone.size() else "-",
				same, seen, mine,
				" ".join(wrong) if wrong.size() else "-"])
		for n in f["died"]:
			things.clear(int(n))
		for t in f["taken"]:
			things.take(int(t[0]), int(t[1]))
	print("\n".join(out))
