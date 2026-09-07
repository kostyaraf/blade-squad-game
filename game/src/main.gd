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
## The map as the shader has it.  A block knocked out of the background
## ($8AF0) changes the map, so the picture of it has to be made again.
var map_tex: ImageTexture
var clock := Clock.new()
var pads: Array[Pad] = []


func _ready() -> void:
	var shots := ""
	var replay := ""
	var spawns := ""
	var weapon := ""
	var hud := ""
	var hudscreen := ""
	var water := ""
	var oam := ""
	var demo := ""
	var play := ""
	var give := ""
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
		elif a.begins_with("--weapon="): weapon = a.substr(9)
		elif a.begins_with("--hud="): hud = a.substr(6)
		elif a.begins_with("--hudscreen="): hudscreen = a.substr(12)
		elif a.begins_with("--water="): water = a.substr(8)
		elif a.begins_with("--oam="): oam = a.substr(6)
		elif a.begins_with("--demo="): demo = a.substr(7)
		elif a.begins_with("--play="): play = a.substr(7)
		elif a.begins_with("--give="): give = a.substr(7)
	if replay != "":
		_run_replay(replay)
		get_tree().quit()
		return
	if spawns != "":
		_run_spawns(spawns)
		get_tree().quit()
		return
	if hud != "":
		_run_hud(hud)
		get_tree().quit()
		return
	if hudscreen != "":
		_run_hud_screen(hudscreen)
		get_tree().quit()
		return
	if weapon != "":
		_run_weapon(weapon)
		get_tree().quit()
		return
	if water != "":
		_run_water(water)
		get_tree().quit()
		return
	if oam != "":
		_run_oam(oam)
		get_tree().quit()
		return
	if shots != "":
		await _run_shots(shots)
		get_tree().quit()
		return
	if give != "":
		# A study aid, and nothing the game itself would ever do: the suits a
		# player would have to find first, handed over at the door.
		# --give=owned,energy,tanks -- owned is the bitmask $56 keeps.
		var g := give.split(",")
		status = Pb2Status.new()
		status.owned = int(g[0])
		status.energy = int(g[1]) if g.size() > 1 else 0x10
		status.tanks = int(g[2]) if g.size() > 2 else 0
	if play != "":
		_run_play(play, stage, area)
		get_tree().quit()
		return
	if demo != "":
		await _run_demo(demo, stage, area)
		get_tree().quit()
		return
	pads = [Pad.player_one(), Pad.player_two()]
	# The bar is drawn by this node itself, and a node draws under its own
	# children unless it is told otherwise.
	bg.z_index = -1
	if game == "pb2":
		_start_play(stage, area)
	else:
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
		# $9A -- which suit he has on.  The recording says it; putting it on is
		# the pause menu's business and not this hero's.
		p.suit = int(f["suit"])
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


# --- the bar along the bottom ----------------------------------------

## What the bar reads: the numbers the game keeps, each from the place the
## cartridge keeps it.
func _bar_feed() -> void:
	bar.boss = world.boss
	bar.stage = came
	bar.area = world.area
	bar.health_tanks = status.life_tanks
	bar.suit_tanks = status.tanks
	bar.lives = lives
	bar.health = world.slots[0][Pb2Objects.F_LIFE]
	bar.fuel = status.energy
	bar.charge = hero.charge
	bar.boss_life = world.slots[Pb2Objects.NOISE_SLOT][Pb2Objects.F_LIFE]
	bar.suit = status.suit


## The pieces and the numbers each of them is drawn from.
func _bar_pieces() -> Dictionary:
	return {
		"stage_area": [bar.boss, bar.stage, bar.area],
		"boss_bar": [bar.boss, bar.boss_life],
		"score": [bar.score_hi, bar.score_lo],
		"right_1": [bar.health_tanks],
		"right_2": [bar.suit_tanks],
		"right_3": [bar.lives],
		"health_bar": [bar.health],
		"suit_bar": [bar.fuel],
		"charge_bar": [bar.charge],
		"face": [bar.suit],
	}


func _bar_remember() -> void:
	var now := _bar_pieces()
	for name in now:
		_bar_was[name] = now[name]


## $D252, $D05D, $D30F and the ten other places that redraw one piece of the
## bar when its number has moved.  The cartridge has a call at each of them;
## here the numbers themselves are watched, which comes to the same thing --
## a piece whose number has not moved is not drawn again.
func _bar_step() -> void:
	if bar == null or world == null:
		return
	_bar_feed()
	var now := _bar_pieces()
	for name in now:
		if _bar_was.get(name) == now[name]:
			continue
		_bar_was[name] = now[name]
		match name:
			"stage_area": bar.stage_area()
			"boss_bar":
				if bar.boss != 0:
					bar.boss_bar()
			"score": bar.score()
			"right_1": bar.number(int(bar.cfg["numbers"]["right_1"]["addr"]),
					bar.health_tanks)
			"right_2": bar.number(int(bar.cfg["numbers"]["right_2"]["addr"]),
					bar.suit_tanks)
			"right_3": bar.number(int(bar.cfg["numbers"]["right_3"]["addr"]),
					bar.lives)
			"health_bar": bar.health_bar()
			"suit_bar": bar.suit_bar()
			"charge_bar": bar.charge_bar()
			"face": bar.face()
	bar.flush()


func _apply() -> void:
	var m: ShaderMaterial = bg.material
	var img: Image
	var size: Vector2
	var banks: Array
	if level_pb2 != null:
		img = level_pb2.map_image
		size = Vector2(level_pb2.width_tiles, level_pb2.height_tiles)
		# Eight banks go to the shader, not four: the four the background is
		# drawn out of and the four the sprites are, because a sprite whose
		# tile number is even comes out of the background's half of the tile
		# memory and must be able to reach it.
		banks = level_pb2.banks + level_pb2.spr_banks
	else:
		img = level_sol.map_image
		size = Vector2(level_sol.width_tiles, level_sol.height_tiles)
		# Solbrain draws no sprites here yet, so its own four are padded out.
		banks = level_sol.banks + [0, 0, 0, 0]
	m.set_shader_parameter("sheet", Nes.sheet(game))
	map_tex = ImageTexture.create_from_image(img)
	m.set_shader_parameter("map", map_tex)
	m.set_shader_parameter("palette", pal_tex)
	m.set_shader_parameter("map_size", size)
	m.set_shader_parameter("sheet_size", Nes.sheet(game).get_size())
	m.set_shader_parameter("banks", PackedInt32Array(banks))
	m.set_shader_parameter("sprites_on", false)
	_bar_show(m)
	if world != null:
		# The hero's own bank and the sprite table are settled a picture at a
		# time, so the last word on both is his, not the level's.
		_show()
	m.set_shader_parameter("scroll", Vector2(scroll - origin))
	m.set_shader_parameter("view_top", float(origin.y))
	m.set_shader_parameter("view_bottom", float(origin.y + view_h))


func _process(dt: float) -> void:
	if pads.is_empty():
		return
	# The logic runs on the console's clock, not the monitor's.
	for _i in range(clock.tick(dt)):
		_step()
	_bar_show(bg.material)
	bg.material.set_shader_parameter("scroll", Vector2(scroll - origin))
	if world != null:
		_show()
		queue_redraw()


func _step() -> void:
	for p in pads:
		p.poll()
	if world == null:
		_walk_camera()
		return
	_step_pb2()
	_bar_step()


## Э1 left this here so that scrolling and the clock could be watched working,
## and Solbrain still has nothing else.
func _walk_camera() -> void:
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
	# $53 -- see `came`.  A room opened cold has to be told it.
	if cfg.has("came"):
		things.came = int(cfg["came"])
	for n in range(cfg["slots"].size()):
		var r: Dictionary = cfg["slots"][n]
		var s: PackedByteArray = things.slots[n]
		s[Pb2Objects.F_TYPE] = int(r["type"])
		s[Pb2Objects.F_REC] = int(r["rec"])
		s[Pb2Objects.F_X] = int(r["x"])
		s[Pb2Objects.F_XHI] = int(r["xhi"])
		s[Pb2Objects.F_Y] = int(r["y"])
		s[Pb2Objects.F_YHI] = int(r["yhi"])
	# $0184, $0190, $019C and $01A8 -- the road one boss writes as it flies and
	# the two pieces of its tail walk a dozen ticks behind.  A run that begins
	# with the boss already in the air begins with the road already written, so
	# it is handed over like the table.
	if cfg.has("rings"):
		var ring: Dictionary = cfg["rings"]
		for i in range(Pb2Objects.TRAIL):
			things.trail_x[i] = int(ring["trail_x"][i])
			things.trail_y[i] = int(ring["trail_y"][i])
			things.trail_pic[i] = int(ring["trail_pic"][i])
			things.trail_bits[i] = int(ring["trail_bits"][i])
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
	# How many tables have been handed over, and which of them the hero was
	# made to touch something on.
	var tables := 0
	var touches := {}
	for t in cfg.get("touch", []):
		var k: int = int(t[0])
		if not touches.has(k):
			touches[k] = []
		touches[k].append(int(t[1]))
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
			things.held = int(f["helds"][i_tbl])
			things.suit = int(f["suits"][i_tbl])
			# $29 -- the line the water or the lava has climbed to.  What
			# moves it lives in the level's own frame, which the harness does
			# not run, so it comes with the table.
			things.water = int(f["waters"][i_tbl])
			# $FC -- how far down the level the screen has been drawn.  The
			# drawing is the level's own frame, which the harness does not
			# run, so it comes with the table.
			things.draw = int(f["draws"][i_tbl])
			# His forty pictures of grace were counted down on the cartridge
			# before the row was written down, so the sweep must not count
			# them again.
			things.hero_told = true
			things.contact()
			things.shift(int(f["shifts"][i_tbl]))
			# $66:$67 -- where the view stood when the sweep looked.  The
			# engine's own view is judged a step at a time, but a step can run
			# over two frames of the console and the view slides in each of
			# them, so which frame laid down which pixel it cannot say.  A mind
			# that snaps itself to a sixteen-line grid down a level reads the
			# low byte straight ($FD16), so it is handed over with the table,
			# for the same reason the slide is.
			things.cam = int(f["cams"][i_tbl])
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
							wrong.append("%d/%02X:%d:%d:%d" % [n, had, k,
									s[k], was_told[k]])
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
			# $B5A5 -- the hero has touched something with a box of its own.
			# The sweep finds these for itself; this is for the runs that
			# reach a thing the buttons cannot, where the cartridge was made
			# to touch it and the engine has to be told the same.  It goes in
			# after the turn, where the cartridge's own touch goes: the sweep
			# runs at $CF08 and the table is written down after it, at $CF14.
			for hit in touches.get(tables, []):
				var t: PackedByteArray = things.slots[int(hit)]
				t[Pb2Objects.F_MARK] = 0x80
				t[Pb2Objects.F_STATE] = 0x02
			tables += 1
			# $1A := 6 -- the level has been told to build itself again.  What
			# is judged from here on is not the table any more but the flow:
			# which area was chosen, and where it puts him and the view.
			if things.live == 6:
				var to_stage: int = 6 if things.boss != 0 else level_pb2.stage
				_load("pb2", to_stage, things.area)
				out.append("%d|%d|%d|%d|%d|%d|%d|%d" % [-1, to_stage,
						things.area, things.boss, level_pb2.start_x,
						level_pb2.start_y, level_pb2.start_face,
						(level_pb2.cam_start_page << 8)
								| level_pb2.cam_start_low])
				print("\n".join(out))
				return
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


## Э3.7 acceptance -- the status bar, a turn of one piece at a time.
##
## Nothing the bar does reaches the screen directly: every piece of it fills
## the queue at $0300 and the blanking empties the queue ($CC41).  So the queue
## is what is judged.  The piece is handed the numbers the cartridge held when
## it drew, and the bytes it pushes must be the cartridge's own.
## Э3.7 acceptance, the second half -- the emptying.
##
## The cartridge's own queues are handed over one after another, exactly as it
## held them at the moment of each blanking, and read the way $CC41 reads
## them.  What is left in the screen is then set against the picture unit's
## own memory, over every cell the reading touched.
func _run_hud_screen(path: String) -> void:
	var doc: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var bar := Pb2Hud.new()
	bar.mirror = int(doc["mirror"])
	for q in doc["queues"]:
		var n: int = q.size()
		for i in range(n):
			bar.queue[i] = int(q[i])
		bar.head = n
		bar.flush()
	var out := PackedStringArray()
	for k in bar.touched.keys():
		out.append("c %04X %02X" % [int(k), bar.screen[int(k)]])
	for k in bar.painted.keys():
		out.append("p %02X %02X" % [int(k), bar.palette[int(k)]])
	print("\n".join(out))


func _run_hud(path: String) -> void:
	var calls: Array = JSON.parse_string(FileAccess.get_file_as_string(path))
	var bar := Pb2Hud.new()
	var out := PackedStringArray()
	for c in calls:
		bar.boss = int(c["boss"])
		bar.stage = int(c["stage"])
		bar.area = int(c["area"])
		bar.score_hi = int(c["score_hi"])
		bar.score_lo = int(c["score_lo"])
		bar.health_tanks = int(c["health_tanks"])
		bar.suit_tanks = int(c["suit_tanks"])
		bar.lives = int(c["lives"])
		bar.health = int(c["health"])
		bar.fuel = int(c["fuel"])
		bar.charge = int(c["charge"])
		bar.boss_life = int(c["boss_life"])
		bar.suit = int(c["suit"])
		var was: int = bar.head
		match String(c["piece"]):
			"stage_area": bar.stage_area()
			"boss_bar": bar.boss_bar()
			"score": bar.score()
			"right_1": bar.number(int(bar.cfg["numbers"]["right_1"]["addr"]),
					bar.health_tanks)
			"right_2": bar.number(int(bar.cfg["numbers"]["right_2"]["addr"]),
					bar.suit_tanks)
			"right_3": bar.number(int(bar.cfg["numbers"]["right_3"]["addr"]),
					bar.lives)
			"suit_bar": bar.suit_bar()
			"health_bar": bar.health_bar()
			"charge_bar": bar.charge_bar()
			"face": bar.face()
		var line := PackedStringArray()
		var i: int = was
		while i != bar.head:
			line.append("%02X" % bar.queue[i])
			i = (i + 1) & 0xFF
		out.append("q " + " ".join(line))
	print("\n".join(out))


## Э3.3 acceptance -- what he throws, judged a frame at a time.
##
## The hero is driven by his own module, as `_run_replay` drives him, and the
## three places his throws take are driven by the engine's own weapon code and
## by nothing else.  Everything the weapon code reads and does not yet work out
## -- where he stands, what the level declared solid, the suit, the blade's
## power -- is told from the recording; the three places themselves are never
## told before they have been judged.
##
## The order is the cartridge's own.  Inside one picture $D23A counts the
## button at $CF00, $D34D writes the table down at $CF14, and only after that
## does the step of the game run: $8E26 moves what is already in the air and
## $8E29 -- his state machine, and $A1C2 inside it -- lets go of the next one.
## So the table handed over at the head of a picture is what the engine must
## already have answered, and the step that follows it is the next answer.
func _run_weapon(path: String) -> void:
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
	p.charge = int(cfg["charge"])
	var view := Pb2Camera.new(level_pb2)
	view.place(int(cfg["cam"]) >> 8, int(cfg["cam"]) & 0xFF,
			int(cfg["cam_pend"]), int(cfg["clock"]))
	var things := Pb2Objects.new(level_pb2)
	# With the table in his hands he takes a place in it for every throw and
	# what he throws is really thrown.
	p.world = things
	var out := PackedStringArray()
	# Nothing has been handed over yet, so the first table is told and not
	# judged: the throws in it were made over steps the engine never saw.
	var told := false
	for f in cfg["frames"]:
		var bad := PackedStringArray()
		var wholes: Array = f["whole"]
		# A step with no table of its own still ran on the cartridge, and what
		# he threw moved in it: it is taken blind -- nothing judged, nothing
		# told -- so that the next table finds the throw where it should be.
		for i in range(maxi(wholes.size(), 1)):
			things.power = int(f["power"])
			things.second = int(f["second"])
			things.extra = int(f["lim"])
			# $CF00 -- how long the button has been down, counted once every
			# fourth picture and never past the blade's own ceiling.
			p.step_charge(int(f["clocks"][i]))
			var tbl: Array = wholes[i] if i < wholes.size() else []
			# $CF14 -- the cartridge's own answer for this picture.
			if told and not tbl.is_empty():
				for k in range(1, 4):
					var s: PackedByteArray = things.slots[k]
					var w: Array = tbl[k]
					# An empty place is not a throw.  The cartridge leaves the
					# fields of a place it has taken away as they were and goes
					# on writing in some of them for its own reasons -- $04DF
					# of a dead place slides a quarter of a pixel a picture in
					# several areas -- and none of it is ever read: the birth
					# of the next throw fills the place in.  So an empty place
					# is judged empty and no further.
					if s[Pb2Objects.F_TYPE] == 0 and int(w[Pb2Objects.F_TYPE]) == 0:
						continue
					for fl in range(Pb2Objects.FIELDS):
						if fl == Pb2Objects.F_REC:
							continue
						if s[fl] != int(w[fl]):
							bad.append("%d:%d:%d:%d"
									% [k, fl, s[fl], int(w[fl])])
			# Judged, then told: a step that went wrong is reported once and
			# does not go on to spoil every step after it, so every line put
			# out is one step of the throw's flight and nothing else.
			for n in range(Pb2Objects.SLOTS if not tbl.is_empty() else 0):
				var s2: PackedByteArray = things.slots[n]
				var w2: Array = tbl[n]
				for fl in range(Pb2Objects.FIELDS):
					s2[fl] = int(w2[fl])
			told = told or not tbl.is_empty()
			if i != 0:
				continue
			# $8E15 -- the step of the game, which runs in the first picture
			# of its own count and in no other.
			things.frame = int(f["clocks"][0])
			things.clock = int(f["turns"][0])
			things.seed = int(f["seeds"][0])
			things.suit = int(f["suits"][0])
			things.water = int(f["waters"][0])
			things.held = int(f["helds"][0])
			things.draw = int(f["draws"][0])
			things.cam = int(f["cams"][0])
			things.solids = f["solids"]
			p.suit = things.suit
			p.solids = f["solids"]
			p.held = int(f["hold"])
			p.push_x = int(f["push"][0])
			p.push_y = int(f["push"][1])
			# $A671 -- a throw aimed down rides him down, and the fall speed
			# it rides on is neither the one the table was written down with
			# nor the one it is left holding: $B294 changes it after the table
			# is written and $91EF changes it again after the sweep.  So it is
			# handed over as the sweep itself read it.
			if f.has("fall") and f["fall"][0] != null:
				var h0: PackedByteArray = things.slots[0]
				h0[Pb2Objects.F_VY] = int(f["fall"][0])
				h0[Pb2Objects.F_VYFR] = int(f["fall"][1])
			# $A764 -- and where he stands as the sweep reads him.  A
			# boomerang steers by his place, and $8E23 has already moved
			# him this frame: the table written down at $D34D still holds
			# the place he had a step ago.
			if f.has("aim") and f["aim"][0] != null:
				var h1: PackedByteArray = things.slots[0]
				h1[Pb2Objects.F_Y] = int(f["aim"][0])
				h1[Pb2Objects.F_X] = int(f["aim"][1])
			# $CF1C -- the turn of the things, of which only the blocks are
			# driven here: one knocked out of the wall opens the cell it sat
			# on, and a throw that would have died on that cell flies on.  It
			# goes before the throws move, where the cartridge has it.
			things.blocks_turn()
			# $8E26 -- what is already in the air moves first, and only then
			# does $8E29 let go of the next one.  He is still where the table
			# left him: $A945 does not move him until $8E2C, after both.
			things.shots_turn()
			view.drive()
			p.shift = view.shift
			p.step(int(f["pad"]), int(f["hit"]), view.pos,
					int(f["shots"]), int(f["lim"]))
			view.decide(((p.y if level_pb2.vertical else p.x) >> 8) & 0xFF)
		out.append("%d %s" % [p.charge, " ".join(bad) if bad.size() else "-"])
	print("\n".join(out))


## Э3.2i: the water and the lava that rise.
##
## Nothing here is told but the two the level itself decides -- the picture
## count $1C and whether the level is being played -- and the engine must
## answer with the line the water has climbed to, the screen's drawing point
## and which way the two are going.
func _run_water(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	_load("pb2", int(cfg["stage"]), int(cfg["area"]))
	var things := Pb2Objects.new(level_pb2)
	var view := Pb2Camera.new(level_pb2)
	things.water = int(cfg["water"])
	things.flow = int(cfg["flow"])
	things.draw = int(cfg["draw"])
	view.wait = int(cfg["still"])
	view.grip = int(cfg["grip"])
	var out := PackedStringArray()
	for f in cfg["frames"]:
		things.frame = int(f["clock"])
		things.playing = int(f["mode"])
		things.live = int(f["live"])
		things.water_turn(view)
		# $D924 -- and then the view takes its hold and counts the same wait
		# down a second time.
		view.drive()
		out.append("%d %d %d" % [things.water, things.draw, things.flow])
	print("\n".join(out))


## Build the table the console draws from, once a picture, out of the table of
## things -- and nothing else.  The things themselves are told, because what is
## on trial here is $8038 and the little pictures it reads, not the minds.
func _run_oam(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var was := PackedByteArray()
	for v in cfg["seed"]:
		was.append(int(v))
	var out := PackedStringArray()
	for f in cfg["frames"]:
		var slots: Array = []
		for row in f["slots"]:
			var s := PackedByteArray()
			for v in row:
				s.append(int(v))
			slots.append(s)
		was = Pb2Sprites.build(slots, int(f["rot"]), was)
		out.append(was.hex_encode())
	print("\n".join(out))


# --------------------------------------------------------- Э3.9: playing it

## The hero, the view and the table of things, all of them the engine's own.
var world: Pb2Objects = null
var hero: Pb2Player = null
var view: Pb2Camera = null
## $28 -- where in the console's sprite table this picture starts writing.
var rot := 0
## The console's own sprite table, kept from one picture to the next: what the
## drawing does not touch keeps what it said last time.
var oam := PackedByteArray()
var oam_tex: ImageTexture
## $94 of the picture before: the scan reads last picture's slide, not this
## one's ($CF0E runs before $CF11).
var slid := 0
## $9F -- how many more times he may be brought back.  $D090 gives him two at
## the start of a game.
var lives := 2
## The counters that are his and not the level's -- $9A, $56, $A0, $9E and the
## blade's three.  It outlives an area and a life both.
var status: Pb2Status = null
## The bar along the bottom of the screen, and what it last drew.  The
## cartridge builds it whole in four pictures when a level opens and afterwards
## touches only the piece whose number moved; that is what `_bar_step` does.
var bar: Pb2Hud = null
var bar_tex: ImageTexture
var _bar_was := {}
## $53 -- the stage in the game's own count.  A boss room is built out of the
## seventh table, so `level_pb2.stage` is six there and this is not: it holds
## the stage the hero walked in from, which is what the room reads.
var came := 0


## Open an area and put a hero in it, where the area's own walk-on says.
##
## $E23F reads the area's record -- where the view begins -- and $F04C the one
## byte that says where he stands in it.  Both are the cartridge's own, so an
## area opened by itself opens exactly as it does when the door before it is
## walked through.
func _start_play(st: int, ar: int) -> void:
	_load("pb2", st, ar)
	Pb2Sprites.load_data()
	view = Pb2Camera.new(level_pb2)
	world = Pb2Objects.new(level_pb2)
	# The boss rooms are the seventh table and belong to no stage of their own,
	# so walking into one leaves $53 where it was ($86F0 and $84F6 set $79 and
	# $9C, and neither touches $53).
	if st != Pb2Objects.BOSS_STAGE:
		came = st
	world.came = came
	hero = Pb2Player.new(level_pb2)
	hero.world = world
	# What he carries from one area to the next, and from one life to the
	# next: the suits, the energy, the tanks, the blade.  A new game makes it
	# ($C9E1 wipes $48..$EF); an area does not.
	if status == null:
		status = Pb2Status.new()
	world.status = status
	world.suit = status.suit
	world.power = status.power_level
	world.second = status.second_blade
	world.extra = status.extra_shot
	view.place(level_pb2.cam_start_page, level_pb2.cam_start_low, 0, 0)
	hero.place(level_pb2.start_x, level_pb2.start_y, view.pos)
	hero.face_left = level_pb2.start_face != 0
	# $04C6 of his own place is the health bar; the cartridge gives him this
	# much at the start of a life ($E1B4).
	world.slots[0][Pb2Objects.F_LIFE] = 0x10
	world.slots[0][Pb2Objects.F_TYPE] = 0x01
	# $CE11 -- the level's first turn is the bar's: four pictures, a quarter
	# of it in each, and then it stands until a number moves.
	bar = Pb2Hud.new()
	_bar_was.clear()
	_bar_feed()
	while not bar.schedule():
		bar.flush()
	bar.flush()
	if bar.boss != 0:
		bar.boss_bar()
		bar.flush()
	_bar_remember()
	# The area has just opened, so everything already on the screen comes out
	# at once rather than waiting for the view to move ($E3F3 reads $2C).
	world.fill = 1
	oam = PackedByteArray()
	oam.resize(Pb2Sprites.OAM)
	oam.fill(Pb2Sprites.HIDDEN)
	var img := Image.create(Pb2Sprites.SPRITES, 1, false, Image.FORMAT_RGBA8)
	oam_tex = ImageTexture.create_from_image(img)
	bg.material.set_shader_parameter("oam", oam_tex)
	_mirror_hero()
	# The area brought its own palette with it, so the suit's three colours
	# have to be put back over sprite palette one.
	_wear_suit()


## One step of the game, in the cartridge's own order ($CEF0).
func _step_pb2() -> void:
	var pad: Pad = pads[0]
	# $EE5D -- SELECT spends one spare health tank on the health bar.  It only
	# looks like the suit menu; the suits are on START.
	if pad.pressed & Pad.SELECT:
		status.life = world.slots[0][Pb2Objects.F_LIFE]
		status.spend_life_tank()
	# $CDBB and $CEFD -- the suits: the pause menu, and the wearing out of
	# whichever one he has on.  While either has something to say the level
	# itself does not run at all.
	status.life = world.slots[0][Pb2Objects.F_LIFE]
	status.stage = level_pb2.stage
	# Pad already keeps the console's own order of the eight, so what it
	# reports is what $48 would hold.
	var play: bool = status.step(pad.pressed)
	# $27 -- the level's things write it as well as read it: the boss's meter
	# puts it out of play while it fills and back into play when it is full.
	world.playing = status.mode
	world.slots[0][Pb2Objects.F_LIFE] = status.life
	world.suit = status.suit
	world.power = status.power_level
	world.second = status.second_blade
	world.extra = status.extra_shot
	if status.repaint:
		status.repaint = false
		_wear_suit()
	if status.clear_shots:
		# $D768 -- what he had in the air belonged to the suit he was wearing.
		status.clear_shots = false
		for k in range(1, Pb2Objects.FIRST_LIVE):
			world.clear(k)
	if not play:
		return
	world.frame = (world.frame + 1) & 0xFF          # $0110
	world.status = status
	# $CF00 -- how long the button has been down.
	hero.step_charge(world.frame)
	# $CF08 -- what touches what.
	world.contact()
	# $CF0E -- what the view has uncovered since the last step.
	world.scan(view.pos, slid)
	# $CF11 -- the view follows him.
	view.drive()
	slid = view.shift
	world.cam = view.pos
	# $CF14 -- the view slid, so everything standing on it slid back.
	world.shift(view.shift)
	# $CF1C -- every thing gets its turn.
	world.turns()
	status.mode = world.playing
	# $1A := 6 -- something has told the level to build itself again.  The
	# door at the end of an area is what usually does it.
	if world.live == 6:
		_next_area()
		return
	# $8E26 -- what is already in the air moves first, and only then does
	# $8E29 let go of the next one; $8E2C moves him after both.
	world.shots_turn()
	hero.shift = view.shift
	hero.held = world.held
	hero.suit = world.suit
	hero.step(pad.held, pad.pressed, view.pos,
			hero_shots_out(), world.extra)
	view.decide(((hero.y if level_pb2.vertical else hero.x) >> 8) & 0xFF)
	_mirror_hero()
	if world.slots[0][Pb2Objects.F_LIFE] == 0:
		_die()
		return
	# $8038 -- and then the picture of it all.
	oam = Pb2Sprites.build(world.slots, rot, oam)
	rot = (rot + Pb2Sprites.ROTATE) & 0xFF


## $D28E and $D8E4 -- a suit is a thousand bytes of tiles and three colours,
## and nothing else.  The tiles are handed to the picture through the sprite
## banks; the colours go into sprite palette one, where $8080 puts them.
func _wear_suit() -> void:
	var pal: PackedByteArray = level_pb2.palette
	var c: Array = status.palette()
	pal[20] = 0x0F                                  # $8096
	for i in range(3):
		pal[21 + i] = int(c[i])
	Nes.update_palette(pal_tex, pal)


## $CF3C -- the level was told to build itself again, so it does: the area the
## door chose, or the stage's boss room, and the hero stood where that area's
## own walk-on says.
func _next_area() -> void:
	var st: int = 6 if world.boss != 0 else level_pb2.stage
	var ar: int = world.area
	_start_play(st, ar)
	_apply()


## $D022 -- a life is spent and the area is opened again; when there are none
## left the game is over and the stage begins from its first area.
func _die() -> void:
	if lives > 0:
		lives -= 1
		_start_play(level_pb2.stage, level_pb2.area)
	else:
		lives = 2                                   # $D090: $18 := 2
		_start_play(level_pb2.stage, 0)
	_apply()


## How many of his throws are still in the air ($A1C2 counts them).
func hero_shots_out() -> int:
	var n := 0
	for k in range(1, Pb2Objects.FIRST_LIVE):
		if world.slots[k][Pb2Objects.F_TYPE] != 0:
			n += 1
	return n


## His own place in the table is his picture and where he stands; the rest of
## that row -- his health, his forty pictures of grace, which way a blow threw
## him -- belongs to the sweep and is left alone.
func _mirror_hero() -> void:
	var s: PackedByteArray = world.slots[0]
	s[Pb2Objects.F_KIND] = hero.pose
	s[Pb2Objects.F_BITS] = (s[Pb2Objects.F_BITS] & ~0x40) \
			| (0x40 if hero.face_left else 0)
	s[Pb2Objects.F_X] = (hero.x >> 8) & 0xFF
	s[Pb2Objects.F_XHI] = (hero.x >> 16) & 0xFF
	s[Pb2Objects.F_Y] = (hero.y >> 8) & 0xFF
	s[Pb2Objects.F_YHI] = (hero.y >> 16) & 0xFF
	# $0534:$054A -- how fast he is falling.  A blade thrown straight down
	# rides down with him ($A671 reads it), so it has to be in the table.
	#
	# It is a picture behind what the cartridge reads there, and cannot yet be
	# anything else: the cartridge moves him ($8E20), then sweeps what he has
	# thrown ($8E26), then changes his fall speed again ($8E29 -> $91EF), and
	# here his whole picture is one call.  Splitting him in two belongs with
	# the rest of the step's order and is left for later.
	s[Pb2Objects.F_VY] = (hero.vy >> 8) & 0xFF
	s[Pb2Objects.F_VYFR] = hero.vy & 0xFF
	# $0416 outright.  `Pb2Player.state` is that byte and nothing else: every
	# place the cartridge writes it -- $9E26 with the state ($8EBE $00/$04,
	# $8F89 $08/$05, $8FF5 $10/$07, $A000 $01/$08, $94A6 $04/$10 and the rest),
	# $8EC1 while he swings, $A21A when a throw begins, $99C1 when it ends --
	# has a line of its own in the hero's module.  The sweep reads it for his
	# box ($B2C1, bits three and four), for whether something has hold of him
	# (bits five and six), for whether he is off the ground (bit nought, which
	# a blade thrown down rides on) and for his pose ($BA44 counts the noughts
	# under it), so it is handed over whole rather than rebuilt bit by bit.
	s[Pb2Objects.F_MARK] = hero.state


## Hand the picture to the shader: where the view stands, which tile banks the
## sprites come out of, and the console's sprite table.
func _show() -> void:
	var m: ShaderMaterial = bg.material
	if level_pb2 != null and level_pb2.map_dirty:
		level_pb2.map_dirty = false
		map_tex.update(level_pb2.map_image)
	var w: int = world._world(view.pos)
	scroll = Vector2i(0, w) if level_pb2.vertical else Vector2i(w, 0)
	m.set_shader_parameter("scroll", Vector2(scroll - origin))
	m.set_shader_parameter("banks", PackedInt32Array(level_pb2.banks
			+ Pb2Sprites.banks_for(level_pb2, hero.pose, world.suit)))
	m.set_shader_parameter("sprites_on", true)
	var img := Image.create(Pb2Sprites.SPRITES, 1, false, Image.FORMAT_RGBA8)
	for i in range(Pb2Sprites.SPRITES):
		img.set_pixel(i, 0, Color8(oam[i * 4], oam[i * 4 + 1],
				oam[i * 4 + 2], oam[i * 4 + 3]))
	oam_tex.update(img)


## The game playing itself with no picture at all: the same script of buttons
## as `--demo`, but what comes out is a line of numbers and not a screenshot.
## Headless Godot has no renderer to wait on, so this is the one that can be
## run from a terminal.
func _run_play(spec: String, st: int, ar: int) -> void:
	pads = [Pad.player_one(), Pad.player_two()]
	_start_play(st, ar)
	var bits := {"A": Pad.A, "B": Pad.B, "UP": Pad.UP, "DOWN": Pad.DOWN,
			"LEFT": Pad.LEFT, "RIGHT": Pad.RIGHT, "START": Pad.START,
			"SELECT": Pad.SELECT}
	var n := 0
	for part in spec.split(","):
		var f := part.split(":")
		var down := 0
		for nm in f[0].split("+"):
			if bits.has(nm):
				down |= int(bits[nm])
		for _i in range(int(f[1])):
			pads[0].pressed = down & ~pads[0].held
			pads[0].held = down
			_step_pb2()
			n += 1
			print("%4d %-12s x %3d y %3d pose %02X suit %d energy %2d "
					% [n, f[0], hero.x >> 8, hero.y >> 8, hero.pose,
					status.suit, status.energy]
					+ "tanks %d mode %d menu %d life %2d"
					% [status.tanks, status.mode, status.menu,
					world.slots[0][Pb2Objects.F_LIFE]])


## A picture of the game playing itself, so that what it looks like can be
## argued with from a script.  `spec` is buttons:frames:...,path -- the buttons
## are the names Pad knows, or a dash.
func _run_demo(spec: String, st: int, ar: int) -> void:
	var parts := spec.split(",")
	pads = [Pad.player_one(), Pad.player_two()]
	_start_play(st, ar)
	var bits := {"A": Pad.A, "B": Pad.B, "UP": Pad.UP, "DOWN": Pad.DOWN,
			"LEFT": Pad.LEFT, "RIGHT": Pad.RIGHT, "START": Pad.START}
	for i in range(parts.size() - 1):
		var f := parts[i].split(":")
		var down := 0
		for name in f[0].split("+"):
			if bits.has(name):
				down |= int(bits[name])
		for _n in range(int(f[1])):
			pads[0].pressed = down & ~pads[0].held
			pads[0].held = down
			_step_pb2()
			_bar_step()
	for n in range(Pb2Objects.SLOTS):
		var s: PackedByteArray = world.slots[n]
		if s[Pb2Objects.F_KIND] != 0 or s[Pb2Objects.F_TYPE] != 0:
			print("slot %d type %d kind %d bits %02X x %d.%d y %d.%d" % [n,
					s[Pb2Objects.F_TYPE], s[Pb2Objects.F_KIND],
					s[Pb2Objects.F_BITS], s[Pb2Objects.F_XHI],
					s[Pb2Objects.F_X], s[Pb2Objects.F_YHI], s[Pb2Objects.F_Y]])
	print("hero x %d y %d pose %d state %02X sub %d charge %d  view %d" % [
			hero.x >> 8, hero.y >> 8, hero.pose, hero.state, hero.sub,
			hero.charge, view.pos])
	_apply()
	bg.z_index = -1
	queue_redraw()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(parts[-1])


## The pause menu, and nothing else: the bar itself is drawn where the
## cartridge draws it, in the eight rows below the level (Э3.7).
func _draw() -> void:
	if world == null or status.menu == 0:
		return
	draw_rect(Rect2(Vector2(14, 210), Vector2(160, 12)),
			Color8(0xFC, 0xFC, 0xFC), false)



## Hand the bar to the shader: its own little map of eight rows, and the four
## thousand-byte banks the interrupt draws it out of.
func _bar_show(m: ShaderMaterial) -> void:
	if bar == null:
		m.set_shader_parameter("bar_on", false)
		return
	bar_tex = ImageTexture.create_from_image(bar.bar_image())
	m.set_shader_parameter("bar", bar_tex)
	m.set_shader_parameter("bar_banks", PackedInt32Array(bar.bar_banks()))
	m.set_shader_parameter("bar_on", true)
