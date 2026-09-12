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
	var timing := ""
	var play := ""
	var run := ""
	var give := ""
	var sel := ""
	var orbit := ""
	var solplay := ""
	var soloam := ""
	var solcam := ""
	var solshot := ""
	var solobj := ""
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
		elif a.begins_with("--time="): timing = a.substr(7)
		elif a.begins_with("--play="): play = a.substr(7)
		elif a.begins_with("--run="): run = a.substr(6)
		elif a.begins_with("--give="): give = a.substr(7)
		elif a.begins_with("--select="): sel = a.substr(9)
		elif a.begins_with("--orbit="): orbit = a.substr(8)
		elif a.begins_with("--solplay="): solplay = a.substr(10)
		elif a.begins_with("--soloam="): soloam = a.substr(9)
		elif a.begins_with("--solcam="): solcam = a.substr(9)
		elif a.begins_with("--solshot="): solshot = a.substr(10)
		elif a.begins_with("--solobj="): solobj = a.substr(9)
	if replay != "":
		_run_replay(replay)
		get_tree().quit()
		return
	if spawns != "":
		_run_spawns(spawns)
		get_tree().quit()
		return
	if orbit != "":
		_run_orbit(orbit)
		get_tree().quit()
		return
	if soloam != "":
		_run_sol_oam(soloam)
		get_tree().quit()
		return
	if solcam != "":
		_run_sol_cam(solcam)
		get_tree().quit()
		return
	if solobj != "":
		_run_sol_objects(solobj)
		get_tree().quit()
		return
	if solshot != "":
		await _run_sol_shot(solshot, stage)
		get_tree().quit()
		return
	if solplay != "":
		_run_sol_play(solplay)
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
	if run != "":
		_run_through(run, stage, area)
		return
	if sel != "":
		await _run_select(sel, stage)
		get_tree().quit()
		return
	if timing != "":
		_run_time(timing, stage, area)
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
		_start_sol()
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
## Э4.1 -- Solbrain's hero alone, given a stage, a place and a list of buttons,
## putting out where he stood on every frame.  The stand that holds him against
## the cartridge is work/extract/verify_sol_player.py.
func _run_sol_play(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var p := _seed_sol(cfg)
	var out := PackedStringArray()
	for f in cfg["pads"]:
		p.step(int(f))
		out.append("%d %d %d %d %d %d %d %d %d %d %d %d %d"
				% [p.x, p.y, p.vx, p.vy, p.state, p.speed,
				p.pose, p.scripted, p.step_t, p.step_i,
				p.pic_lo, p.pic_hi, p.anim])
	print("\n".join(out))


## Э4.1 -- the view, $F1EA and $F24B, held against the cartridge picture by
## picture.  The hero is seeded exactly as the movement stand seeds him and
## then walks; what is printed is only where the view stood and which way it
## was told it could go.  The stand is work/extract/verify_sol_camera.py.
func _run_sol_cam(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var p := _seed_sol(cfg)
	var view := SolCamera.new(level_sol)
	view.x = int(cfg["cam_x"])
	view.y = int(cfg["cam_y"])
	view.map_kind = int(cfg["map_kind"]) if cfg.has("map_kind") else 0
	view.hold = int(cfg["ride_hold"]) if cfg.has("ride_hold") else 0
	view.fall = int(cfg["ride_fall"]) if cfg.has("ride_fall") else 0
	# $CD9C runs before the hero does, so the view always moves on the picture
	# he has already finished, not the one being drawn.
	p.vx = int(cfg["vx"])
	p.vy = int(cfg["vy"])
	var out := PackedStringArray()
	for f in cfg["pads"]:
		view.step(p.vx, p.vy, p.x, p.y)
		p.step(int(f))
		out.append("%d %d %d" % [view.x, view.y, view.want])
	print("\n".join(out))


## Э4.2 -- who is in the sixteen slots and where, held against the cartridge
## picture by picture.  The hero and the view are seeded and driven exactly as
## the other two stands drive them; what is printed is the pool.  The stand is
## work/extract/verify_sol_spawns.py.
func _run_sol_objects(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var p := _seed_sol(cfg)
	var view := SolCamera.new(level_sol)
	view.x = int(cfg["cam_x"])
	view.y = int(cfg["cam_y"])
	view.map_kind = int(cfg["map_kind"]) if cfg.has("map_kind") else 0
	view.hold = int(cfg["ride_hold"]) if cfg.has("ride_hold") else 0
	view.fall = int(cfg["ride_fall"]) if cfg.has("ride_fall") else 0
	p.vx = int(cfg["vx"])
	p.vy = int(cfg["vy"])
	var pool := SolObjects.new(level_sol)
	pool.due = int(cfg["due"])
	pool.col_due = int(cfg["col_due"])
	pool.row_due = int(cfg["row_due"])
	pool.seen_x = int(cfg["seen_x"])
	pool.seen_y = int(cfg["seen_y"])
	pool.room = int(cfg["room"])
	pool.z75 = int(cfg["z75"]) if cfg.has("z75") else 0
	pool.z58 = int(cfg["z58"]) if cfg.has("z58") else 0
	pool.z26 = int(cfg["z26"]) if cfg.has("z26") else 0
	pool.hero_suits = int(cfg["suits"]) if cfg.has("suits") else 0
	pool.hero_bonus = int(cfg["bonus"]) if cfg.has("bonus") else 0
	for i in range(SolObjects.MARKS):
		pool.mark[i] = int(cfg["mark"][i])
	for i in range(SolObjects.SLOTS):
		pool.id[i] = int(cfg["id"][i])
		pool.x[i] = int(cfg["ox"][i])
		pool.y[i] = int(cfg["oy"][i])
		pool.mind[i] = int(cfg["omind"][i])
		pool.kind[i] = int(cfg["okind"][i])
		pool.a[i] = int(cfg["oa"][i])
		pool.b[i] = int(cfg["ob"][i])
		pool.c[i] = int(cfg["oc"][i])
		pool.d[i] = int(cfg["od"][i])
		pool.face[i] = int(cfg["oface"][i])
		pool.anim_a[i] = int(cfg["oanim_a"][i])
		pool.anim_b[i] = int(cfg["oanim_b"][i])
		pool.left[i] = int(cfg["oleft"][i])
		pool.frame[i] = int(cfg["oframe"][i])
		pool.cool[i] = int(cfg["ocool"][i])
		pool.life[i] = int(cfg["olife"][i])
		pool.pic_lo[i] = int(cfg["opic_lo"][i])
		pool.pic_hi[i] = int(cfg["opic_hi"][i])
	# $0C is a plain count of pictures, but $0E is a hash of the whole of RAM
	# ($CD57) and is not ported yet, so both are handed over as the cartridge
	# had them.  `work/re/sol_minds.md` says what that still owes.
	var clocks: Array = cfg["clock_at"]
	var noises: Array = cfg["noise_at"]
	var sixes: Array = cfg["six_at"] if cfg.has("six_at") else noises
	var steps: Array = cfg["step_at"] if cfg.has("step_at") else noises
	var rides: Array = cfg["ride_at"] if cfg.has("ride_at") else []
	var out := PackedStringArray()
	var n := 0
	for f in cfg["pads"]:
		# A picture the cartridge did not have time for: $0C does not move on,
		# and neither does anything else.  The stand still asks for a row, so
		# the one before is given again.
		if n > 0 and int(clocks[n]) == int(clocks[n - 1]):
			out.append(out[n - 1])
			n += 1
			continue
		# The order of one picture: what the background owed is paid at the
		# top, then the view moves, then the hero, then the scroll is looked
		# at again, then the room, then the scan, then the pool itself.
		pool.clock = int(clocks[n])
		pool.noise = int(noises[n])
		pool.six = int(sixes[n])
		pool.z7f = int(steps[n])
		if n < rides.size():
			pool.z58 = int(rides[n])
		pool.drew()
		view.step(p.vx, p.vy, p.x, p.y)
		# $06 is the buttons the cartridge's own hero saw.  It is the pad as
		# read at $C895, except that a stage's own script may wipe it ($9E73
		# in bank 8 does, all through stage twenty's opening), and that script
		# is not ported yet -- so the hero is handed the byte rather than the
		# pad.  Where no script interferes the two are the same.
		p.step(int(sixes[n]) if cfg.has("six_at") else int(f))
		pool.hero = p
		pool.ride_hold = view.hold
		pool.hero_x = p.x
		pool.hero_y = p.y
		pool.hero_vx = p.vx
		pool.hero_face = 0x80 if p.face_left else 0x00
		pool.hero_suit = p.suit
		pool.hero_flags = p.flags
		pool.hero_state = p.state
		pool.map_kind = view.map_kind
		pool.stage = int(cfg["stage"]) if cfg.has("stage") else 0
		pool.z34 = view.fall
		pool.scrolled(view.x, view.y)
		pool.room = pool.room_of(view.x, view.y)
		pool.scan(view.x, view.y, p.x, p.state)
		# $CDBE -- the hero's own box is built once, before the pool is walked,
		# so every slot is laid over the same one.
		pool.hero_box()
		pool.step(view.x, view.y)
		var row := PackedStringArray()
		for i in range(SolObjects.SLOTS):
			row.append("%d,%d,%d,%d,%d,%d,%d" % [pool.id[i], pool.x[i],
					pool.y[i], pool.mind[i], pool.kind[i],
					pool.pic_lo[i], pool.pic_hi[i]])
		out.append(" ".join(row))
		n += 1
	print("\n".join(out))
	if not pool.skipped.is_empty():
		printerr("minds not read yet: ", pool.skipped)


## Everything the cartridge had in the hero when the buttons started, put back
## into him.  Two stands lean on this, so it is written once.
func _seed_sol(cfg: Dictionary) -> SolPlayer:
	_load("sol", int(cfg["stage"]), 0)
	var p := SolPlayer.new(level_sol)
	p.place(int(cfg["x"]), int(cfg["y"]))
	if cfg.has("state"):
		p.state = int(cfg["state"])
	if cfg.has("speed"):
		p.speed = int(cfg["speed"])
	if cfg.has("jump"):
		p.jump = int(cfg["jump"])
	if cfg.has("face_left"):
		p.face_left = bool(cfg["face_left"])
	if cfg.has("timer"):
		p.timer = int(cfg["timer"])
	if cfg.has("hold"):
		p.hold = int(cfg["hold"])
	if cfg.has("rise"):
		p.rise = int(cfg["rise"])
	if cfg.has("ground"):
		p.ground = int(cfg["ground"])
	if cfg.has("hurt"):
		p.hurt = int(cfg["hurt"])
	if cfg.has("scripted"):
		p.scripted = int(cfg["scripted"])
	if cfg.has("suit"):
		p.suit = int(cfg["suit"])
	if cfg.has("gravity"):
		p.gravity = int(cfg["gravity"])
	if cfg.has("hold_max"):
		p.hold_max = int(cfg["hold_max"])
	if cfg.has("flags"):
		p.flags = int(cfg["flags"])
	if cfg.has("jump_flags"):
		p.jump_flags = int(cfg["jump_flags"])
	if cfg.has("seen"):
		p.seen = int(cfg["seen"])
	if cfg.has("swim"):
		p.swim = int(cfg["swim"])
	if cfg.has("shield"):
		p.shield = int(cfg["shield"])
	if cfg.has("fuel"):
		p.fuel = int(cfg["fuel"])
	if cfg.has("step_down"):
		p.step_down = int(cfg["step_down"])
	if cfg.has("clock"):
		p.clock = int(cfg["clock"])
	if cfg.has("pad_held"):
		p.pad_held = int(cfg["pad_held"])
	if cfg.has("map_kind"):
		p.map_kind = int(cfg["map_kind"])
	if cfg.has("pose"):
		p.pose = int(cfg["pose"])
	if cfg.has("step_t"):
		p.step_t = int(cfg["step_t"])
	if cfg.has("step_i"):
		p.step_i = int(cfg["step_i"])
	if cfg.has("pic_lo"):
		p.pic_lo = int(cfg["pic_lo"])
	if cfg.has("pic_hi"):
		p.pic_hi = int(cfg["pic_hi"])
	if cfg.has("anim"):
		p.anim = int(cfg["anim"])
	return p


## Э4.1 -- the hero laid out into the console's sprite table.  Each picture is
## handed over whole: the hero as the cartridge had him just before $937A, the
## place on screen, the table as it stood and the four cursors the drawing
## carries.  The stand that holds it against the cartridge is
## work/extract/verify_sol_oam.py.
func _run_sol_oam(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var out := PackedStringArray()
	for f in cfg["frames"]:
		var p := SolPlayer.new(null)
		p.state = int(f["state"])
		p.timer = int(f["timer"])
		p.step_t = int(f["step_t"])
		p.step_i = int(f["step_i"])
		p.pic_lo = int(f["pic_lo"])
		p.pic_hi = int(f["pic_hi"])
		p.hurt = int(f["hurt"])
		p.suit = int(f["suit"])
		p.flags = int(f["flags"])
		p.jump_flags = int(f["jump_flags"])
		p.clock = int(f["clock"])
		p.face_left = bool(f["face_left"])
		p._picture()
		var t := SolSprites.Table.new()
		t.count = int(f["count"])
		t.turn = int(f["turn"])
		t.fwd = int(f["fwd"])
		t.back = int(f["back"])
		var bk: Array = f["banks"]
		for i in range(4):
			t.banks[i] = int(bk[i])
		var was: Array = f["oam"]
		for i in range(256):
			t.oam[i] = int(was[i])
		SolSprites.hero(p, int(f["x"]), int(f["y"]), t)
		out.append("%s %d %d %d %d %d %d %d %d" % [t.oam.hex_encode(),
				t.count, t.turn, t.fwd, t.back,
				t.banks[0], t.banks[1], t.banks[2], t.banks[3]])
	print("\n".join(out))


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
		# $05A2 as the things left it: this stand has no table of things, so
		# what one of them wrote into his cell has to be handed over.
		p.grip = int(f["grip"]) if f.has("grip") else 0
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
	bar.score_hi = status.time_hi
	bar.score_lo = status.time_lo


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
	if select != null:
		# The screen a stage is picked on owns the whole of the picture: no
		# bar under it and no level behind it.
		img = select.map_image
		size = Vector2(Pb2Select.WIDTH, Pb2Select.HEIGHT)
		banks = select.banks + select.spr_banks
	elif level_pb2 != null:
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
		# The hero's own four banks are settled a picture at a time, so until
		# he is standing they are the ones the stage came in with.
		banks = level_sol.banks + (Array(sol_table.banks)
				if sol_table != null else level_sol.spr_banks)
	m.set_shader_parameter("sheet", Nes.sheet(game))
	map_tex = ImageTexture.create_from_image(img)
	m.set_shader_parameter("map", map_tex)
	m.set_shader_parameter("palette", pal_tex)
	m.set_shader_parameter("map_size", size)
	m.set_shader_parameter("sheet_size", Nes.sheet(game).get_size())
	m.set_shader_parameter("banks", PackedInt32Array(banks))
	m.set_shader_parameter("sprites_on", false)
	# A level is handed one place to stand in and keeps it the whole frame,
	# and it draws the leftmost eight points like any other.
	m.set_shader_parameter("split_at", 1000.0)
	m.set_shader_parameter("clip_left", 0.0)
	_bar_show(m)
	if select != null:
		_choice_show()
	elif world != null:
		# The hero's own bank and the sprite table are settled a picture at a
		# time, so the last word on both is his, not the level's.
		_show()
	elif sol_hero != null:
		_show_sol()
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
	if select != null:
		_choice_show()
		queue_redraw()
		return
	bg.material.set_shader_parameter("scroll", Vector2(scroll - origin))
	if world != null:
		_show()
		queue_redraw()
	elif sol_hero != null:
		_show_sol()
		queue_redraw()


func _step() -> void:
	for p in pads:
		p.poll()
	if choosing:
		_choice_step()
		return
	if world == null:
		if sol_hero != null:
			_step_sol()
		else:
			_walk_camera()
		return
	_step_pb2()
	_bar_step()


## Э4.1 -- Solbrain with a hero in it: he is set down where the stage says and
## the view is put where the stage raises it.  Nothing else of the game is
## here yet -- no things, no weapons, no bar -- so what this is good for is
## walking, jumping and looking at him.
func _start_sol() -> void:
	sol_hero = SolPlayer.new(level_sol)
	sol_hero.place(level_sol.start.x, level_sol.start.y)
	sol_view = SolCamera.new(level_sol)
	sol_view.place(level_sol.start.x, level_sol.start.y)
	sol_table = SolSprites.Table.new()
	for i in range(4):
		sol_table.banks[i] = level_sol.spr_banks[i]
	oam = PackedByteArray()
	oam.resize(Pb2Sprites.OAM)
	oam.fill(Pb2Sprites.HIDDEN)
	var img := Image.create(Pb2Sprites.SPRITES, 1, false, Image.FORMAT_RGBA8)
	oam_tex = ImageTexture.create_from_image(img)
	bg.material.set_shader_parameter("oam", oam_tex)
	scroll = Vector2i(sol_view.x >> 4, sol_view.y >> 4)


## One picture: the view first, because $CD9C runs before the hero does, then
## the hero, then what he puts into the sprite table.
func _step_sol() -> void:
	sol_view.step(sol_hero.vx, sol_hero.vy, sol_hero.x, sol_hero.y)
	sol_hero.step(pads[0].held)
	# A picture starts with an empty table: the game walks it from both ends
	# every frame ($F4E2 forward, $F5E1 back) and nothing is kept.
	sol_table.count = 0
	sol_table.turn = 0
	sol_table.fwd = 0
	sol_table.back = SolSprites.BACK_WRAP
	for i in range(sol_table.oam.size()):
		sol_table.oam[i] = Pb2Sprites.HIDDEN
	# $91C0 -- where he is, counted from the corner of the view.
	SolSprites.hero(sol_hero, (sol_hero.x - sol_view.x) & 0xFFFF,
			(sol_hero.y - sol_view.y) & 0xFFFF, sol_table)


func _show_sol() -> void:
	var m: ShaderMaterial = bg.material
	scroll = Vector2i(sol_view.x >> 4, sol_view.y >> 4)
	m.set_shader_parameter("scroll", Vector2(scroll - origin))
	m.set_shader_parameter("banks",
			PackedInt32Array(level_sol.banks + Array(sol_table.banks)))
	m.set_shader_parameter("sprites_on", true)
	var img := Image.create(Pb2Sprites.SPRITES, 1, false, Image.FORMAT_RGBA8)
	for i in range(Pb2Sprites.SPRITES):
		img.set_pixel(i, 0, Color8(sol_table.oam[i * 4],
				sol_table.oam[i * 4 + 1], sol_table.oam[i * 4 + 2],
				sol_table.oam[i * 4 + 3]))
	oam_tex.update(img)


## A look at Solbrain with a hero in it: --solshot=BUTTONS,FRAMES,FILE, where
## BUTTONS is one pad byte in hex held the whole way.  Nothing but a look.
func _run_sol_shot(spec: String, st: int) -> void:
	var f := spec.split(",")
	var pad := int("0x%s" % f[0])
	var n := int(f[1])
	_load("sol", st, 0)
	_start_sol()
	for _i in range(n):
		sol_view.step(sol_hero.vx, sol_hero.vy, sol_hero.x, sol_hero.y)
		sol_hero.step(pad)
		sol_table.count = 0
		sol_table.turn = 0
		sol_table.fwd = 0
		sol_table.back = SolSprites.BACK_WRAP
		for i in range(sol_table.oam.size()):
			sol_table.oam[i] = Pb2Sprites.HIDDEN
		SolSprites.hero(sol_hero, (sol_hero.x - sol_view.x) & 0xFFFF,
				(sol_hero.y - sol_view.y) & 0xFFFF, sol_table)
	_apply()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(f[2])
	print("hero %04X %04X  view %04X %04X  state %d pic %d"
			% [sol_hero.x, sol_hero.y, sol_view.x, sol_view.y,
			sol_hero.state, sol_hero.draw_id])
	print("count %d banks %s oam %s" % [sol_table.count,
			str(Array(sol_table.banks)),
			sol_table.oam.slice(0, 32).hex_encode()])


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
			# $5C -- which colours the background wears, and in bit 7 whether
			# the storm is out.  What the hero grabs hold of in the three
			# storm areas ($A50B) reads it, and the walk through the colours
			# lives in the level's own frame, which this stand does not run.
			things.storm = int(f["colours"][i_tbl])
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
		# $011F and $0120..$0150, $063C and $0652 as the sweep of this step
		# left them.  In the cartridge the things take their turn first and
		# his own update reads what they left straight after, in the same
		# step, so the line belongs to the step it stands in.
		var boxes := PackedStringArray()
		for b in things.solids:
			boxes.append("%d:%d:%d:%d" % [int(b[0]), int(b[1]), int(b[2]),
					int(b[3])])
		out.append("%d|%s|%s|%d/%d/%d|%s|%d,%d,%s" % [view.pos,
				" ".join(born) if born.size() else "-",
				" ".join(PackedStringArray(gone)) if gone.size() else "-",
				same, seen, mine,
				" ".join(wrong) if wrong.size() else "-",
				things.push_x - 256 if things.push_x > 127 else things.push_x,
				things.push_y - 256 if things.push_y > 127 else things.push_y,
				" ".join(boxes) if boxes.size() else "-"])
		# $8E43 and $8E46 -- the hero's own update wipes the two pushes at the
		# end of the step.  This stand does not run his update, so the wiping
		# is done here, in its place and where it stands: after the sweep.
		things.push_x = 0
		things.push_y = 0
		for n in f["died"]:
			things.clear(int(n))
		for t in f["taken"]:
			things.take(int(t[0]), int(t[1]))
	print("\n".join(out))


## Э3.4 acceptance -- the fourth suit's two satellites, $A945 alone.
##
## Every other stand hands the first six places over whole, so the two
## satellites are told and never judged.  Here they are the only thing judged:
## the world is set to what the cartridge held the instant before $8E2C called
## $A945 -- the whole table, the two bytes of marks the things left, the suit
## and the picture count -- and the engine must answer with the two places as
## the cartridge left them, and with the same things eaten.
func _run_orbit(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	_load("pb2", int(cfg["stage"]), int(cfg["area"]))
	var things := Pb2Objects.new(level_pb2)
	if cfg.has("came"):
		things.came = int(cfg["came"])
	var out := PackedStringArray()
	for f in cfg["frames"]:
		var was: Array = f["before"]
		for n in range(Pb2Objects.SLOTS):
			var s: PackedByteArray = things.slots[n]
			var w: Array = was[n]
			for k in range(Pb2Objects.FIELDS):
				s[k] = int(w[k])
		things.suit = int(f["suit"])                # $9A
		things.frame = int(f["tick"])               # $0110
		things.marks = int(f["marks"])              # $0117
		things.marks2 = int(f["marks2"])            # $0118
		things.orbit()                              # $A945
		var rows := PackedStringArray()
		for n in [4, 5]:
			var s2: PackedByteArray = things.slots[n]
			var b := PackedStringArray()
			for k in range(Pb2Objects.FIELDS):
				b.append(str(s2[k]))
			rows.append(",".join(b))
		# $AB44 -- what the satellites ate on the way past.  A place the
		# cartridge had already emptied is not one of them.
		var ate := PackedStringArray()
		for n in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
			if things.slots[n][Pb2Objects.F_TYPE] == 0 \
					and int(was[n][Pb2Objects.F_TYPE]) != 0:
				ate.append(str(n))
		out.append("%s|%s|%s" % [rows[0], rows[1],
				" ".join(ate) if ate.size() else "-"])
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

# Э4.1 -- Solbrain walking about for real: the hero, the view and the table
# the console draws him out of.  Э4.3 will hand the same table to the things.
var sol_hero: SolPlayer
var sol_view: SolCamera
var sol_table: SolSprites.Table
## $94 of the picture before: the scan reads last picture's slide, not this
## one's ($CF0E runs before $CF11).
var slid := 0
## $9F -- how many more times he may be brought back.  $D090 gives him two at
## the start of a game.
var lives := 2
## How many times a life has been spent since the game began.  Nothing
## in the game reads it; it is how a run of its own can tell a death
## from a door, both of which open an area again.
var died_count := 0
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
## $AD -- which half of the stage is being played.  The table of things is
## made afresh for every area, so this is where it lives between them.
var phase := 0
## How many times the scene between the two halves has built the area again.
## A study run watches the table to tell a rebuild from an ordinary step, and
## this is how it tells that rebuild from the one a door makes.
var interludes := 0


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
	world.phase = phase
	hero = Pb2Player.new(level_pb2)
	hero.world = world
	# What he carries from one area to the next, and from one life to the
	# next: the suits, the energy, the tanks, the blade.  A new game makes it
	# ($C9E1 wipes $48..$EF); an area does not.
	var opened := false
	if status == null:
		status = Pb2Status.new()
		opened = true
	world.status = status
	world.suit = status.suit
	world.power = status.power_level
	world.second = status.second_blade
	world.extra = status.extra_shot
	# $CE45 -- an area opened on its own is the top of a stage as far as the
	# clock is concerned; a door goes through $1A := 6 and never touches it.
	if opened:
		status.restart_time(came, phase)
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
	# $53 is the stage the hero walked in from, not the table the room was
	# built out of: a boss room is the seventh table and no stage at all.
	status.stage = came
	# $CEEC and $CA3A -- what the clock has to know: whose room this is, and
	# whether the level is standing still.
	status.boss = world.boss
	status.area = world.area
	status.frozen = world.frozen != 0
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
	world.step_colour(status.menu != 0)             # $BF32
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
	# $18 := 6 -- the scene between the two halves of the fifth stage.  There
	# is nothing to show here yet, so it is over at once and the same area is
	# built again with $AD one, where the same record is a door ($B0D7).
	if world.interlude:
		phase = world.phase
		interludes += 1
		_start_play(level_pb2.stage, world.area)
		# $CE45 -- the other half of a stage is given its own time.
		status.restart_time(came, phase)
		_apply()
		return
	# $8E26 -- what is already in the air moves first, and only then does
	# $8E29 let go of the next one; $8E2C moves him after both.
	world.shots_turn()
	hero.shift = view.shift
	hero.held = world.held
	hero.suit = world.suit
	# $011F and $0120..$0150, $063C and $0652 -- what the level worked out
	# about him during the turns of the things.  The two pushes are bytes with
	# a sign in them and his own step reads them as numbers.
	hero.solids = world.solids
	hero.push_x = world.push_x - 256 if world.push_x > 127 else world.push_x
	hero.push_y = world.push_y - 256 if world.push_y > 127 else world.push_y
	# $8BBE -- the break in the middle of the fifth stage takes the pad away
	# and holds it towards the left itself ($48 := 0, $4A := 2).
	if world.take_pad:
		hero.step(Pad.LEFT, 0, view.pos, hero_shots_out(), world.extra)
	else:
		hero.step(pad.held, pad.pressed, view.pos,
				hero_shots_out(), world.extra)
	view.decide(((hero.y if level_pb2.vertical else hero.x) >> 8) & 0xFF)
	_mirror_hero()
	# $8E2C -- the fourth suit's two satellites take their turn last of all,
	# after his step has moved him, because the ellipse they walk is measured
	# from where he stands now.
	world.orbit()
	# $8E32..$8E52 -- everything the level said about him this frame ends with
	# his step; the head of the next sweep would wipe it again anyway.
	world.push_x = 0
	world.push_y = 0
	world.solids = []
	world.claimed = 0
	# $8E4C and $8E4F -- and so do the marks the things left for the
	# satellites, which is why a thing has to set its bit on every turn.
	world.marks = 0
	world.marks2 = 0
	# $A17A -- no health left, or no time left, and he dies either way.
	if world.slots[0][Pb2Objects.F_LIFE] == 0 or status.out_of_time:
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
	# $AD belongs to the stage, not to the area, and the table of things that
	# knew it is about to be thrown away ($88EB puts it back to nought).
	phase = world.phase
	# $88F0 -- a boss that has fallen opens no area.  $BE22 sets the stage's
	# bit in $5B, and the game leaves for the map and the screen the next
	# stage is picked on.  The same types stand about in the middle of a
	# stage as well, so it is only a boss room that ends the stage.
	if world.beat and level_pb2.stage == Pb2Objects.BOSS_STAGE:
		status.cleared |= 1 << came
		_start_choice()
		return
	var st: int = 6 if world.boss != 0 else level_pb2.stage
	var ar: int = world.area
	_start_play(st, ar)
	_apply()


## $D022 -- a life is spent and the area is opened again; when there are none
## left the game is over and the stage begins from its first area.
func _die() -> void:
	died_count += 1
	if lives > 0:
		lives -= 1
		_start_play(level_pb2.stage, level_pb2.area)
	else:
		lives = 2                                   # $D090: $18 := 2
		_start_play(level_pb2.stage, 0)
	# $D063 -- a life lost is a clock wound up again.
	status.restart_time(came, phase)
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


## The picking screen's own picture: the ground where the ride has left it and
## the two sprites -- the man and the sign over the stage he is standing at.
func _choice_show() -> void:
	var m: ShaderMaterial = bg.material
	scroll = select.scroll()
	m.set_shader_parameter("scroll", Vector2(scroll))
	# $87 := 3 -- the screen is drawn in slices, and the road below the line is
	# handed nought while the sky above it rides.
	m.set_shader_parameter("split_at", float(Pb2Select.SPLIT))
	m.set_shader_parameter("scroll2", Vector2(select.road()))
	m.set_shader_parameter("clip_left", float(Pb2Select.CLIP_LEFT))
	m.set_shader_parameter("banks",
			PackedInt32Array(select.banks + select.spr_banks))
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


## The clock, frame by frame, so that it can be set against the cartridge.
## `spec` is clock:frames[:time] -- where the cartridge's own $1C stood when
## the run began, how many pictures to play, and a time to start from instead
## of the one the stage gives.  One line a picture: the time as the
## bar would show it, and whether the bell is ringing.
func _run_time(spec: String, st: int, ar: int) -> void:
	var f := spec.split(":")
	pads = [Pad.player_one(), Pad.player_two()]
	_start_play(st, ar)
	status.clock = int(f[0])
	if f.size() > 2:
		status.time_hi = (int(f[2]) >> 8) & 0xFF
		status.time_lo = int(f[2]) & 0xFF
		status.warn = 0
	var out := PackedStringArray()
	for n in range(int(f[1])):
		pads[0].pressed = 0
		pads[0].held = 0
		var lost := died_count
		_step_pb2()
		_bar_step()
		# The cartridge takes two hundred and fifty pictures to die and winds
		# the clock up again at the end of them ($D063); the engine does the
		# whole of it in the one picture, so the run stops here instead.
		if died_count != lost:
			out.append("%d out" % [n + 1])
			break
		out.append("%d %02X %02X %d" % [n + 1, status.time_hi, status.time_lo,
				status.warn])
	print("\n".join(out))


## A picture of the screen a stage is picked on, so that it can be argued with
## from a script.  `spec` is cleared:owned,buttons:frames,...,path -- the same
## button names the demo knows.
func _run_select(spec: String, st: int) -> void:
	var parts := spec.split(",")
	var f := parts[0].split(":")
	pads = [Pad.player_one(), Pad.player_two()]
	status = Pb2Status.new()
	status.cleared = int(f[0])
	status.owned = int(f[1]) if f.size() > 1 else 0
	# Where in the sprite table the writing starts ($28).  It is a running
	# count the screen inherits from whatever was on before it, so a run that
	# is set against the cartridge has to be handed the cartridge's own.
	if f.size() > 2:
		rot = (int(f[2]) - Pb2Sprites.ROTATE) & 0xFF
	# The screen is opened as the game opens it: out of the area just left,
	# because $46/$47 are that area's and the screen does not touch them.
	came = st
	# The picture is taken between one step and the next, and taking it costs
	# a real frame or two: the game must not play itself in them.
	set_process(false)
	_start_play(st, 0)
	_start_choice()
	# The buttons, picture by picture, and then the pictures a shot is wanted
	# at.  Frame nought is the screen as it stands before anything is pressed.
	var bits := {"START": Pad.START, "LEFT": Pad.LEFT, "RIGHT": Pad.RIGHT}
	var script := []
	for i in range(1, parts.size() - 2):
		var g := parts[i].split(":")
		var down := 0
		for nm in g[0].split("+"):
			if bits.has(nm):
				down |= int(bits[nm])
		for _n in range(int(g[1])):
			script.append(down)
	var want := []
	var last := 0
	for w in parts[-2].split("+"):
		want.append(int(w))
		last = max(last, int(w))
	var n := 0
	while true:
		if n in want:
			_apply()
			bg.z_index = -1
			queue_redraw()
			# One frame hands the shader what has just been set, and the next
			# is the one that shows it.
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			var img := get_viewport().get_texture().get_image()
			img.save_png("%s_%d.png" % [parts[-1], n])
			if select != null:
				print("%4d  step %2d  choice %d  scroll %3d  sign %3d  "
						% [n, select.step_no, select.choice,
						select.scroll().x, select.slots[1][Pb2Objects.F_X]]
						+ "man %02X  left %s"
						% [select.slots[0][Pb2Objects.F_KIND],
						str(select.facing_left)])
			else:
				print("%4d  picked %d -- the level is up" % [n, status.stage])
		if n >= last:
			break
		# The cartridge reads the pad and then takes its step, both inside the
		# one picture, so the buttons written down for picture n are the ones
		# that make the screen picture n is.
		n += 1
		var down: int = script[n] if n < script.size() else 0
		pads[0].pressed = down & ~pads[0].held
		pads[0].held = down
		if select != null:
			_choice_step()


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


## Э3.8 -- the whole game played by the engine and nothing else.
##
## It is stood in the first area of the first stage and left to run.  A pilot
## holds it towards the far edge and taps A; where the hero gets stuck against
## something the pilot cannot climb it shoves him a few points on, and where
## the door is still not reached in time the door is made to open where it
## stands -- the same two bytes $B5A5 writes when he walks into it.
##
## What is on trial is not the pilot.  It is whether every area of the seven
## stages loads, runs its own minds for hundreds of steps without falling over,
## puts out its door, and hands on to the area the door names -- the whole
## game, end to end, out of the engine alone.  One line per area is put out:
## where it began, how many steps it took, where the hero ended, and which
## area it handed on to.
const OPENING := 260


func _run_through(spec: String, from_stage: int = 0, from_area: int = 0) -> void:
	var f := spec.split(",")
	var steps: int = int(f[0]) if f[0] != "" else 900
	var limit: int = int(f[1]) if f.size() > 1 else 200
	var trace: bool = f.size() > 2 and f[2] == "trace"
	pads = [Pad.player_one(), Pad.player_two()]
	_start_play(from_stage, from_area)
	var seen := {}
	var out := PackedStringArray()
	var areas := 0
	var stuck := 0
	var forced := 0
	var deaths := 0
	var stepped := 0
	while areas < limit:
		var st: int = level_pb2.stage
		var ar: int = level_pb2.area
		var key := "%d:%d" % [st, ar]
		# A boss room is filed under the stage it belongs to as well: the last
		# stage's own room is $C894's area nought, which is also the first
		# stage's, and the two are not the same visit.
		var been := "%d/%s" % [came, key]
		if seen.has(been):
			out.append("%-6s seen already -- the run has come round" % key)
			break
		seen[been] = true
		var down: bool = level_pb2.vertical
		# Which end of the area the door is at is written down nowhere, so the
		# run goes one way until the edge stops it and then the other.
		var far := true
		var was: int = view.pos
		var still := 0
		var turns := 0
		# An area that carries the view along by itself ($2E) moves it one
		# point every fourth, eighth or sixteenth step, and the hero cannot
		# hurry it; such an area is given that many times as long.
		var allow: int = steps
		if level_pb2.auto != 0:
			if level_pb2.auto in [3, 4, 5]:
				allow = steps * 4
			elif level_pb2.auto in [2, 7]:
				allow = steps * 8
			else:
				allow = steps * 16
		var n := 0
		var died := 0
		var d_was: int = died_count
		var opened := ""
		var over := false
		var opening := false
		# A boss room is not left through a door: when the meter is empty the
		# cartridge hands the game back to the map of the stages ($18 := 5,
		# $8912), and from there the player picks the next one.  The engine has
		# no map yet, so the run walks on to the first area of the next stage
		# itself and the map is written down as a debt.
		var room_done := false
		# Which step the door was made to open on.  The whole opening is a
		# hundred and thirty frames and the level takes another sixty to come
		# back; a door that has not handed on well past that was the wrong
		# door, or was carried off the screen before it finished, so the pilot
		# takes hold again and looks for another.
		var open_at := 0
		while n < allow:
			# Once the door has been made to open the pilot lets go of
			# everything: the opening is a hundred and thirty frames long and
			# the door has to stay where it is for all of them, so the hero is
			# neither pinned nor steered any more.  This is what the study runs
			# do -- the pin is held exactly until the door is opened.
			var b := 0
			if not opening:
				b = (Pad.DOWN if far else Pad.UP) if down \
						else (Pad.RIGHT if far else Pad.LEFT)
				if n % 24 == 8:
					b |= Pad.A
				# And it throws, without pause.  A boss room has no door: the
				# only way out of one is to empty the boss's meter.
				if n % 8 < 2:
					b |= Pad.B
			pads[0].pressed = b & ~pads[0].held
			pads[0].held = b
			# An area that builds itself again makes a new table; that is how
			# the run tells a rebuild from an ordinary step.
			var world_was: Pb2Objects = world
			var mid_was := interludes
			# The pilot cannot play, so it pins him: his place on the screen
			# is written every step to one edge of it and the view chases him
			# the whole length of the area.  This is what the study runs do to
			# the cartridge ($0508 and $04C6, `PIN_ALONG` and `PIN_DOWN`);
			# nothing else about him is touched.
			if not opening:
				if down:
					hero.y = (hero.y & 0xFF) | ((0xC0 if far else 0x20) << 8)
				else:
					hero.x = (hero.x & 0xFF) | ((0xE0 if far else 0x00) << 8)
			# ...and keeps him alive, the way $D0F1 is poked out for a study
			# run.  A pilot that cannot dodge would otherwise spend the game's
			# three lives in the first area.
			world.slots[0][Pb2Objects.F_LIFE] = 0x10
			status.life = 0x10
			_step_pb2()
			_bar_step()
			n += 1
			if choosing:
				# $88F0 -- the room's boss fell and the game has left for the
				# choosing screen.  That is the area done, and done properly.
				room_done = true
				break
			if died_count != d_was:
				d_was = died_count
				died += 1
				still = 0
				was = view.pos
				if level_pb2.stage != st or level_pb2.area != ar:
					over = true
					break
				continue
			if world != world_was:
				# $18 := 6 -- the scene in the middle of the stage builds the
				# same area again with the other half's things in it.  The
				# area is not over; it has only changed under the hero, so the
				# run goes on playing it.
				if interludes != mid_was:
					still = 0
					was = view.pos
					opening = false
					continue
				if level_pb2.stage != st or level_pb2.area != ar:
					opened = "%d:%d" % [level_pb2.stage, level_pb2.area]
				else:
					room_done = true
				break
			# The pinned hero stands still by definition, so what says the run
			# is getting anywhere is the view.
			if trace and n % 60 == 0:
				out.append("   %-6s step %4d  hero %d,%d  view %d  pend %d  "
						% [key, n, hero.x >> 8, hero.y >> 8, view.pos,
						view.pending]
						+ "shift %d auto %d mode %d  out: %s"
						% [view.shift, view.auto, status.mode, _types()])
			var now: int = view.pos
			if now != was:
				still = 0
				was = now
			else:
				still += 1
			# Held against the end of the area for half a second: that end has
			# no door, so the run turns round and walks the other way.
			if still >= 30 and not opening:
				still = 0
				turns += 1
				far = not far
			# A door standing and waiting is made to open where it is: the
			# pilot cannot walk into it, and what is on trial is the opening
			# and the handing on, not the walking.
			# A boss room has no door.  The pilot cannot fight, so the boss is
			# put into the first of its six dying states -- where a spent
			# meter puts it ($BDE9) -- and the room ends as it would have.
			if not opening and (_force_door() or _force_boss()):
				opening = true
				open_at = n
				forced += 1
			elif opening and n - open_at > OPENING:
				opening = false
		deaths += died
		if room_done:
			# $88F0 -- the stage the room belonged to is $53, which the engine
			# keeps in `came`; the next one begins at its first area.  Stage
			# five is the last, and its rooms are a chain of their own.
			areas += 1
			if came >= 5:
				out.append("%-6s ok    %4d steps -- the boss is down and the "
						% [key, n] + "game is over")
				break
			out.append("%-6s ok    %4d steps, %d deaths  ->  the choice, "
					% [key, n, died] + "and on to %d:0" % [came + 1])
			# The pilot picks the next stage the way a player would, so the
			# choosing screen is on trial here too.
			_pick(came + 1)
			if choosing:
				stuck += 1
				out.append("%-6s STUCK -- the choice would not take %d"
						% [key, came + 1])
				break
			continue
		if opened == "":
			# The area never put out a door in the time it was given.  Three do
			# not put one out for the cartridge either, walked from a standing
			# start; the run steps over into the next area of the stage -- the
			# door leads to $9C + 1 and nowhere else -- and says so.
			var walk: int = Pb2Level.walk_count(st)
			if st != Pb2Objects.BOSS_STAGE and not over:
				stepped += 1
				areas += 1
				out.append("%-6s NO DOOR %4d steps, %d turns, %d deaths -- "
						% [key, n, turns, died]
						+ "stepped over  (out: %s)" % _types())
				if ar + 1 < walk:
					_start_play(st, ar + 1)
				else:
					_start_play(Pb2Objects.BOSS_STAGE, st)
				_apply()
				continue
			stuck += 1
			out.append("%-6s STUCK %4d steps, %d turns, %d deaths -- %s"
					% [key, n, turns, died,
					"the last life was spent" if over else "no door opened"]
					+ "  (hero %d,%d  view %d  out: %s)"
					% [hero.x >> 8, hero.y >> 8, view.pos, _types()])
			break
		areas += 1
		out.append("%-6s ok    %4d steps, %d turns, %d deaths  ->  %s"
				% [key, n, turns, died, opened])
	print("\n".join(out))
	print("%d areas played, %d doors forced, %d stepped over, %d deaths, "
			% [areas, forced, stepped, deaths] + "%d stuck" % stuck)
	get_tree().quit()


## ------------------------------------------------- Э3.10: picking a stage
##
## $859D is the screen a stage is picked on, and $9EC8 -- the map -- is only
## the walk that leads to it.  What is here is its flow and nothing else: the
## picture of it ($A860 and what draws it) is Э3.10b, so while the choice is
## open the last room stands frozen behind it.

var choosing := false
var choice := 0                                     ## $22
## Э3.10b -- the screen itself, while it is up.
var select: Pb2Select = null


## $88F0 -> $18 := 5 -> the map -> $18/$19 := 3/20.  The stage the choice opens
## on is the one just finished, as $8838 does ($22 := $53).
func _start_choice() -> void:
	choosing = true
	choice = came
	# $88CE leaves $46/$47 alone, so the last two kilobytes of sprites are
	# still whatever the area just left gave them.
	select = Pb2Select.new(came, status.cleared, status.owned,
			[level_pb2.spr_banks[2], level_pb2.spr_banks[3]])
	pal_tex = Nes.palette_texture(select.palette)
	# $8881 -- the screen is the whole of the picture: no bar and no level.
	origin = Vector2i.ZERO
	view_h = 240
	bar = null
	oam = PackedByteArray()
	oam.resize(Pb2Sprites.OAM)
	oam.fill(Pb2Sprites.HIDDEN)
	var img := Image.create(Pb2Sprites.SPRITES, 1, false, Image.FORMAT_RGBA8)
	oam_tex = ImageTexture.create_from_image(img)
	bg.material.set_shader_parameter("oam", oam_tex)
	oam = Pb2Sprites.build(select.slots, rot, oam)
	rot = (rot + Pb2Sprites.ROTATE) & 0xFF
	_apply()


## $8969 -- a stage is refused only when it is both finished ($5B) and its suit
## already taken ($56); a finished stage whose suit was missed is still open.
func _may_pick(n: int) -> bool:
	var bit := 1 << n
	return (status.cleared & bit) == 0 or (status.owned & bit) == 0


## $871C -- the pad on the choosing screen.  Left and right walk between the
## five stages, and the fifth is only there once the first four are done
## ($5B == $0F); START takes the pick.
func _choice_step() -> void:
	if select != null:
		# The screen keeps $22 itself, and the walk from one sign to the next
		# is its own, so all it is given is the pad.
		var took: int = select.step(pads[0].pressed)
		choice = select.choice
		# $8038 -- and then the picture of it all, written round and round
		# from wherever the last picture left off.
		oam = Pb2Sprites.build(select.slots, rot, oam)
		rot = (rot + Pb2Sprites.ROTATE) & 0xFF
		if took >= 0:
			_pick(took)
		return
	var p: Pad = pads[0]
	var last := 4 if (status.cleared & 0x0F) == 0x0F else 3
	if p.pressed & Pad.RIGHT and choice < last:
		choice += 1
	elif p.pressed & Pad.LEFT and choice > 0:
		choice -= 1
	elif p.pressed & Pad.START:
		_pick(choice)


## $8816 and $882F -- the pick is put into $53 and the level begins.
func _pick(n: int) -> void:
	if not _may_pick(n):
		return
	choosing = false
	select = null
	status.stage = n
	phase = 0                                       # $A08F -- a fresh stage
	_start_play(n, 0)
	status.restart_time(came, phase)                # $CE45
	_apply()


## $B5A5 -- the two bytes the hero's touch writes into the door: the mark that
## says it has been opened, and the step that starts the opening.
func _force_door() -> bool:
	for n in range(Pb2Objects.SLOTS):
		var s: PackedByteArray = world.slots[n]
		if s[Pb2Objects.F_TYPE] == 0x04 and s[Pb2Objects.F_STATE] == 0x01:
			s[Pb2Objects.F_MARK] = 0x80
			s[Pb2Objects.F_STATE] = 0x02
			return true
	return false


## $BDE9 -- a boss whose meter is empty is put into the first of the six states
## every boss dies through.  Only in a boss room: the same types stand about in
## the middle of a stage as well, and there they are ordinary things of an area
## the pilot walks past.
func _force_boss() -> bool:
	if level_pb2.stage != Pb2Objects.BOSS_STAGE:
		return false
	var cfg: Dictionary = world.cfg_boss
	var first: int = int(cfg["mid_first"])
	for n in range(Pb2Objects.SLOTS):
		var s: PackedByteArray = world.slots[n]
		var t: int = s[Pb2Objects.F_TYPE]
		if t < first or t > 0x59:
			continue
		# The six in the middle of a stage keep three states of their own and
		# the four at the end six; the dying begins where those run out.
		var own: int = int(cfg["mid_states"]) if t < int(cfg["end_first"]) \
				else int(cfg["end_states"])
		if s[Pb2Objects.F_STATE] < own:
			s[Pb2Objects.F_STATE] = own
			s[Pb2Objects.F_LIFE] = 0
			return true
	return false


## What is out in the table, as type:state, for a line of the run's report.
func _types() -> String:
	var out := PackedStringArray()
	for k in range(Pb2Objects.SLOTS):
		var s: PackedByteArray = world.slots[k]
		if s[Pb2Objects.F_TYPE] != 0:
			out.append("%02X.%d" % [s[Pb2Objects.F_TYPE],
					s[Pb2Objects.F_STATE]])
	return " ".join(out)
