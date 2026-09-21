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

## Э6.3.1 -- the sound, and nothing of it unless somebody is playing.  A stand
## walks pictures by the hundred thousand and wants none of this, so `snd` is
## left null there and every seam below falls through.
var snd: SndPlay = null
var snd_out: AudioStreamPlayer = null


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
	var bar := ""
	var flow := ""
	var play := ""
	var run := ""
	var give := ""
	var sel := ""
	var orbit := ""
	var solplay := ""
	var soloam := ""
	var solstrip := ""
	var solcam := ""
	var solshot := ""
	var solobj := ""
	var soldraw := ""
	var sollive := ""
	var solrun := ""
	var pb3floor := ""
	var pb3pair := ""
	var pb3hits := ""
	var pb3pick := ""
	var pb3gear := ""
	var pb3list := ""
	var pb3run := ""
	var pb3arms := ""
	var solflow := ""
	var solscript := ""
	var solscene := ""
	var solboot := false
	var solwalk := ""
	var sound := ""
	var apu := ""
	var sndplay := ""
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
		elif a.begins_with("--bar="): bar = a.substr(6)
		elif a.begins_with("--flow="): flow = a.substr(7)
		elif a.begins_with("--play="): play = a.substr(7)
		elif a.begins_with("--run="): run = a.substr(6)
		elif a.begins_with("--give="): give = a.substr(7)
		elif a.begins_with("--select="): sel = a.substr(9)
		elif a.begins_with("--orbit="): orbit = a.substr(8)
		elif a.begins_with("--solplay="): solplay = a.substr(10)
		elif a.begins_with("--soloam="): soloam = a.substr(9)
		elif a.begins_with("--solstrip="): solstrip = a.substr(11)
		elif a.begins_with("--solcam="): solcam = a.substr(9)
		elif a.begins_with("--solshot="): solshot = a.substr(10)
		elif a.begins_with("--solobj="): solobj = a.substr(9)
		elif a.begins_with("--soldraw="): soldraw = a.substr(10)
		elif a.begins_with("--sollive="): sollive = a.substr(10)
		elif a.begins_with("--solrun="): solrun = a.substr(9)
		elif a.begins_with("--pb3floor="): pb3floor = a.substr(11)
		elif a.begins_with("--pb3pair="): pb3pair = a.substr(10)
		elif a.begins_with("--pb3hits="): pb3hits = a.substr(10)
		elif a.begins_with("--pb3pick="): pb3pick = a.substr(10)
		elif a.begins_with("--pb3gear="): pb3gear = a.substr(10)
		elif a.begins_with("--pb3list="): pb3list = a.substr(10)
		elif a.begins_with("--pb3run="): pb3run = a.substr(9)
		elif a.begins_with("--pb3arms="): pb3arms = a.substr(10)
		elif a.begins_with("--solflow="): solflow = a.substr(10)
		elif a.begins_with("--solscript="): solscript = a.substr(12)
		elif a.begins_with("--solscene="): solscene = a.substr(11)
		elif a == "--solboot": solboot = true
		elif a.begins_with("--solwalk="): solwalk = a.substr(10)
		elif a.begins_with("--sound="): sound = a.substr(8)
		elif a.begins_with("--apu="): apu = a.substr(6)
		elif a.begins_with("--sndplay="): sndplay = a.substr(10)
	if flow != "":
		_run_flow(flow)
		get_tree().quit()
		return
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
	if solscript != "":
		_run_sol_script(solscript)
		get_tree().quit()
		return
	if sound != "":
		_run_sound(sound)
		get_tree().quit()
		return
	if apu != "":
		_run_apu(apu)
		get_tree().quit()
		return
	if sndplay != "":
		_run_sndplay(sndplay)
		get_tree().quit()
		return
	if solwalk != "":
		await _run_sol_boot(solwalk)
		get_tree().quit()
		return
	if solscene != "":
		await _run_sol_scene(solscene)
		get_tree().quit()
		return
	if solflow != "":
		_run_sol_flow(solflow)
		get_tree().quit()
		return
	if soloam != "":
		_run_sol_oam(soloam)
		get_tree().quit()
		return
	if solstrip != "":
		_run_sol_strip(solstrip)
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
	if soldraw != "":
		_run_sol_draw(soldraw)
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
	if solrun != "":
		_run_sol_whole(solrun)
		get_tree().quit()
		return
	if pb3floor != "":
		_run_pb3_floor(pb3floor)
		get_tree().quit()
		return
	if pb3pair != "":
		_run_pb3_pair(pb3pair)
		get_tree().quit()
		return
	if pb3hits != "":
		_run_pb3_hits(pb3hits)
		get_tree().quit()
		return
	if pb3pick != "":
		_run_pb3_pick(pb3pick)
		get_tree().quit()
		return
	if pb3gear != "":
		_run_pb3_gear(pb3gear)
		get_tree().quit()
		return
	if pb3run != "":
		_run_pb3_run(pb3run)
		get_tree().quit()
		return
	if pb3list != "":
		_run_pb3_list(pb3list)
		get_tree().quit()
		return
	if pb3arms != "":
		_run_pb3_arms(pb3arms)
		get_tree().quit()
		return
	if sollive != "":
		await _run_sol_live(sollive, stage)
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
	if bar != "":
		_run_bar(bar)
		get_tree().quit()
		return
	if demo != "":
		await _run_demo(demo, stage, area)
		get_tree().quit()
		return
	pads = [Pad.player_one(), Pad.player_two()]
	_snd_raise()
	# The bar is drawn by this node itself, and a node draws under its own
	# children unless it is told otherwise.
	bg.z_index = -1
	if game == "pb2":
		_start_play(stage, area)
	elif solboot:
		_start_sol_boot()
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


## $91DD -- the two things on the strip that are sprites and not background:
## the mark of the suit he is wearing, in the top corner, and the five figures
## of what he has still to be paid, along the bottom.
##
## They go into the first eight entries of the table, which is the only part
## $C72D does not wipe at the top of the frame -- that corner of the table
## belongs to the strip and nothing else is ever put there.
func _sol_bar(pool: SolObjects) -> void:
	_sol_strip(pool.hero_suit, pool.clock, pool.hero_bonus, sol_table)


## The strip itself, with nothing round it: what $91DD does to the table, given
## only the three cells it reads ($05C5, $0C and $05C6:$05C7).  The stand asks
## for exactly this ($91DD to $923B) and the game calls it once a picture.
static func _sol_strip(suit: int, clock: int, bonus: int,
		t: SolSprites.Table) -> void:
	SolTurn.strip(suit, clock, bonus, t)


## A look at the whole live Solbrain picture, run through $02 from the stage
## being raised: --sollive=BUTTONS,FRAMES[,LETTERS][,PNG][,KILL],
## where BUTTONS is one pad byte in hex held the whole way and LETTERS, when it
## is given, is a set of the three letters put straight into $05A4 so the
## satellite is handed over without having to be walked to.  A fourth field is
## a path, and the picture as it stands at the end is saved there.  What is printed is how
## much of the frame is actually filled -- how many object slots are alive, how
## many shots and how many things the satellite has thrown, and how many
## sprites the table came out holding.  It is a smoke test, not a stand: the
## stands compare against the cartridge, this only says the parts are wired.
## Э4.6 acceptance, the whole of Solbrain run by the engine alone:
## --solrun=STEPS,LIMIT.  Every other stand holds the engine against the
## cartridge on a short stretch and hands it what it cannot work out itself.
## This one hands it nothing: it is stood at the raising of the first stage
## and left to run -- its own hero, its own view, its own pool, its own minds,
## its own script, its own clearing and its own picking of what comes next.
##
## A pilot holds him towards the far edge and taps the two buttons.  The pilot
## is not on trial and cannot play the game: where a stage is not played out
## inside STEPS pictures it is ended where it stands, the same $1B the stage's
## own script writes at $9398, and that is counted and put out.
##
## What is on trial is the run: every stage must raise, put him together, run
## its minds and its script for hundreds of pictures without the engine
## falling over, and hand on to the stage the picking names.  A stage the run
## cannot get out of is a failure, and so is a run that comes round to a stage
## it has already played.
func _run_sol_whole(spec: String) -> void:
	var f := spec.split(",")
	var steps: int = int(f[0])
	var limit: int = int(f[1])
	# A third field asks for every change of mode to be put out as it happens.
	var loud: bool = f.size() > 2 and f[2] != ""
	pads = [Pad.player_one(), Pad.player_two()]
	sol_flow = SolFlow.new()
	sol_flow.stage = 0
	# Nine tries, so a pilot that cannot fight does not end the run by dying.
	sol_flow.lives = 0x09
	sol_flow.mode = SolFlow.RAISE
	var order := PackedStringArray()
	var seen := {}
	var at := -1
	var spent := 0
	var forced := 0
	var doors := 0
	var stuck := 0
	var over := 0
	var deaths := 0
	var last := false
	var i := 0
	# The whole run is given an end: a flow that sits in one mode for ever
	# would otherwise never come back.
	while i < steps * limit + 0x8000:
		i += 1
		# The pilot.  Right is held all the way; the two buttons are let go
		# every eighth picture, or nothing would ever be fired twice.
		var want: int = Pad.RIGHT
		if (i & 0x1F) < 0x0C:
			want |= Pad.A
		if (i & 0x07) < 0x04:
			want |= Pad.B
		# Where a screen waits on a button, START is what walks it on.  On
		# STAGE SELECT that is not enough: $DC1B says START on a stage
		# already done with does nothing at all, so the pointer is walked
		# round the five until it stands on one that is left.
		if sol_flow.mode != SolFlow.PLAY:
			want = Pad.START if (i & 0x0F) < 0x08 else 0
			if sol_flow.mode == SolFlow.CHOSEN \
					and ((sol_flow.z2d >> sol_flow.z4c) & 1) != 0:
				want = Pad.RIGHT if (i & 0x0F) < 0x08 else 0
		pads[0].held = want
		sol_pad_edge = want & ~sol_flow_was
		sol_flow_was = want
		var was: int = sol_flow.mode
		sol_flow.step(self)
		if loud and sol_flow.mode != was:
			print("  %d  %02X -> %02X  stage %d"
					% [i, was, sol_flow.mode, sol_flow.stage])
		if sol_flow.stuck >= 0:
			order.append("%d stage %d stopped at mode %02X on picture %d"
					% [order.size(), sol_flow.stage, sol_flow.stuck, i])
			stuck += 1
			break
		if sol_flow.mode == SolFlow.PLAY:
			if at != sol_flow.stage:
				at = sol_flow.stage
				spent = 0
				if seen.has(at):
					# $DBE3 -- once every area is done with, the board picks
					# for itself, and what it picks is the last stage.  That
					# is not a loop: it is the way to the end of the game.
					if (sol_flow.z2d & 0x1F) == 0x1F and not last:
						last = true
					else:
						order.append("%d stage %d played a second time"
								% [order.size(), at])
						stuck += 1
						break
				seen[at] = true
			spent += 1
			# $978A -- he is dying, and $97A7 spends the try and raises the
			# stage again.  The pilot cannot fight, so this is counted and
			# the stage keeps its budget.
			if sol_hero != null and sol_hero.state == 0x0C:
				deaths += 1
			if spent > steps and last:
				# $E33A -- what the last stage's own script writes once the
				# last of them is down ($02 = $4C).
				sol_flow.mode = SolFlow.END_PAY
				order.append("%d the last stage ended where it stood after %d"
						% [order.size(), spent])
				at = -1
				continue
			if spent > steps:
				# The pilot cannot play the game, so the stage is ended
				# where it stands, the two ways the stage's own script ends
				# one: a stage with another of its own area left goes out
				# through the passage ($55 and $02 = $35, which is what
				# $A89A and its five like write), and the last of an area
				# through the clearing ($02 = $1B, $9398).
				var nxt := -1
				for k in range(20):
					if not seen.has(k) \
							and SolOver.area_of(k) == SolOver.area_of(at):
						nxt = k
						break
				if nxt >= 0:
					if sol_pool != null:
						sol_pool.stage = nxt          # $55
					sol_flow.mode = SolFlow.DOOR
					doors += 1
					order.append("%d stage %d out to %d after %d"
							% [order.size(), at, nxt, spent])
				else:
					sol_flow.mode = SolFlow.CLEAR
					forced += 1
					order.append("%d stage %d ended where it stood after %d"
							% [order.size(), at, spent])
				at = -1
				continue
		elif was == SolFlow.PLAY and sol_flow.mode == SolFlow.CLEAR:
			order.append("%d stage %d played out in %d" % [order.size(), at, spent])
			at = -1
		if sol_flow.mode == SolFlow.OVER or sol_flow.mode == SolFlow.OVER_WAIT:
			over += 1
			break
		# $D4AD -- the ending has run out into the asking about the five
		# best, which is where the game goes when it is won.  The run is
		# home: everything the game has was walked to get here, and the
		# typing of a name is its own stand (verify_sol_name.py).
		if sol_flow.mode == SolFlow.TOP_ASK_END \
				or sol_flow.mode == SolFlow.NAME_SLIDE_END \
				or sol_flow.mode == SolFlow.CHOOSE \
				or sol_flow.mode == SolFlow.TITLE:
			order.append("%d the game is out" % order.size())
			break
		if order.size() >= limit:
			break
	for l in order:
		print(l)
	print(("%d of 20 stages played, %d out through the passage,"
			+ " %d ended where they stood, %d stuck, %d over, %d deaths")
			% [seen.size(), doors, forced, stuck, over, deaths])


var pb3_loud := false


## Э5.1 -- each hero made to walk somebody else's level.
##
## The spec names the hero, the level he is put in and how long he walks.  The
## places are not named: they are found here, out of the level's own answers,
## so the same code finds them whichever way round the pair is.  A place is a
## cell with nothing in it, nothing over it, something solid under it, and four
## clear cells to its right, which is what makes "he did not move" a fair
## question to ask afterwards.
func _run_pb3_floor(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	pb3_loud = bool(cfg.get("loud", false))
	var out := PackedStringArray()
	for one in cfg["runs"]:
		var run: Dictionary = one
		var who := String(run["hero"])
		var spots := int(run.get("spots", 20))
		var frames := int(run.get("frames", 180))
		var pads: Array = run.get("pads", [Pad.RIGHT])
		var tag := "%d.%d" % [int(run["stage"]), int(run.get("area", 0))]
		if who == "sol":
			var src := Pb2Level.new(int(run["stage"]), int(run["area"]))
			var lvl := Pb2AsSol.new(src)
			var solid := func(cx: int, cy: int) -> bool:
				return lvl.collision_at(cx * 16 + 8, cy * 16 + 8) >= Pb2AsSol.SOLID
			var w: int = lvl.width_tiles / 2
			var h: int = lvl.height_tiles / 2
			for at in _pb3_spots(solid, w, h, spots):
				for pad in pads:
					var p := SolPlayer.new(lvl)
					# $82:$83 stands sixteen pixels above his feet, so this is
					# his feet on the top of the cell below him.
					p.place(at.x * 256 + 128, at.y * 256)
					# $948D -- under two and thirty the pad does not reach him
					# at all ($94A5); he is meant to be already standing here,
					# not just arrived.
					p.timer = 0xFF
					out.append(_pb3_walk_sol(p, lvl, int(pad), frames, at, tag))
		else:
			var src := SolLevel.new(int(run["stage"]))
			var lvl := SolAsPb2.new(src)
			var solid := func(cx: int, cy: int) -> bool:
				return lvl.class_byte(cx * 16 + 8, cy * 16 + 8) == 0x80
			var w: int = lvl.width_tiles / 2
			var h: int = lvl.height_tiles / 2
			for at in _pb3_spots(solid, w, h, spots):
				for pad in pads:
					out.append(_pb3_walk_pb2(lvl, int(pad), frames, at, tag))
	print("\n".join(out))


## Places worth standing in, found out of the level's own answers.
## `room` is how many cells to the right of a place have to be empty; five is
## enough for one hero and the pair wants room for two.  `band` is the part of
## the level the view is able to show, in cells: outside it the game itself
## never puts anybody, so a place found there would be judged against a screen
## that cannot be brought to it.
## `stand` names the other columns, counted from the place, that have to have
## a floor under them as well: with two heroes the second one is put down a
## few cells along and starting him over a hole means a walk that spends all
## its pictures falling and says nothing about anything else.
func _pb3_spots(solid: Callable, w: int, h: int, want: int,
		room: int = 5, band: Rect2i = Rect2i(),
		stand: Array = []) -> Array:
	if band.size == Vector2i.ZERO:
		band = Rect2i(0, 0, w, h)
	var found: Array = []
	var step: int = maxi(1, w / (want * 2))
	var cx: int = maxi(1, band.position.x)
	while cx < mini(w - room, band.end.x) and found.size() < want:
		for cy in range(maxi(1, band.position.y), mini(h - 1, band.end.y)):
			if solid.call(cx, cy) or solid.call(cx, cy - 1):
				continue
			if not solid.call(cx, cy + 1):
				continue
			var clear := true
			for k in stand:
				if not solid.call(cx + int(k), cy + 1):
					clear = false
					break
			if not clear:
				continue
			for k in range(1, room):
				if solid.call(cx + k, cy) or solid.call(cx + k, cy - 1) \
						or solid.call(cx + k, cy - 2):
					clear = false
					break
			if not clear:
				continue
			found.append(Vector2i(cx, cy))
			break
		cx += step
	return found


## One walk of the Solbrain hero, and what came of it.
##
## Walking off the end of a ledge is not a fault -- it is what a ledge is for,
## and the level has an end below.  The fault is the floor not holding him:
## ending a picture inside something solid.  That one test is enough to catch
## going through a floor as well, and here is why: a cell is sixteen lines
## tall, his own place is read at the middle of him, and the biggest he ever
## falls in one picture is reported alongside.  While that stays under sixteen
## he cannot step over a floor without being inside it for at least one
## picture, so "never inside" and "never through" are the same answer.
func _pb3_walk_sol(p: SolPlayer, lvl: Pb2AsSol, pad: int, frames: int,
		at: Vector2i, tag: String) -> String:
	var floor_px: int = lvl.height_tiles * 8
	var stuck := 0
	var worst := 0
	var drop := 0
	var left := 0
	var was: int = (p.y >> 4) & 0xFFFF
	for i in range(frames):
		p.step(pad)
		var px: int = (p.x >> 4) & 0xFFFF
		var py: int = (p.y >> 4) & 0xFFFF
		if pb3_loud:
			print("    %3d x %5d y %5d st %02X sp %4d vx %6d gnd %02X seen %02X"
					% [i, px, py, p.state, p.speed, p.vx, p.ground, p.seen])
		if py > was and py - was > drop and py < floor_px:
			drop = py - was
		was = py
		if py >= floor_px:
			left = 1
			break
		if lvl.collision_at(px, py) >= Pb2AsSol.SOLID:
			stuck += 1
			worst = maxi(worst, stuck)
		else:
			stuck = 0
	# Standing still is only a fault where there was somewhere to go, so what
	# is in front of him at the end is part of the answer.
	var ex: int = (p.x >> 4) & 0xFFFF
	var ey: int = (p.y >> 4) & 0xFFFF
	var front: int = 1 if lvl.collision_at(ex + 12, ey) >= Pb2AsSol.SOLID \
			or lvl.collision_at(ex + 12, ey + 8) >= Pb2AsSol.SOLID else 0
	return ("sol %-6s %3d %3d pad %02X x0 %5d x1 %5d y1 %5d walled %3d"
			+ " drop %3d left %d front %d") % [
			tag, at.x, at.y, pad, at.x * 16 + 8, ex, ey, worst, drop, left,
			front]


## And one walk of the Power Blade hero, whose own place is on the screen and
## not in the level: the view is what says where in the level the screen is.
## The same question is asked of him, and answered the same way -- by where he
## ends each picture, with the biggest fall of one picture reported beside it.
## His own place is at his feet, so what he is inside is read eight lines up.
func _pb3_walk_pb2(lvl: SolAsPb2, pad: int, frames: int, at: Vector2i,
		tag: String) -> String:
	var top: int = 16
	var world_x: int = at.x * 16 + 8
	var world_y: int = at.y * 16 + 8
	var eye := Pb2Camera.new(lvl)
	# The view is put so that he stands in the middle of it, and the level's
	# own far end is not walked past.
	var want: int = clampi(world_x - 0x80, 0, maxi(0, lvl.width_tiles * 8 - 0x100))
	eye.place(want >> 8, want & 0xFF, 0, 0)
	# And the window downwards, which his own game never has to say: he is put
	# in the middle of one screen's worth of the stage.
	lvl.cam_y = clampi(world_y - 0x70, 0, maxi(0, lvl.height_tiles * 8 - 0xE0))
	var things := Pb2Objects.new(lvl)
	var p := Pb2Player.new(lvl)
	p.world = things
	p.place(world_x - eye.pos, world_y - lvl.cam_y + top, eye.pos)
	var stuck := 0
	var worst := 0
	var drop := 0
	var left := 0
	var was: int = world_y - lvl.cam_y
	for i in range(frames):
		eye.drive()
		things.cam = eye.pos
		p.shift = eye.shift
		p.step(pad, pad if i == 0 else 0, eye.pos, 0, 0)
		eye.decide(((p.y if lvl.vertical else p.x) >> 8) & 0xFF)
		var px: int = eye.pos + ((p.x >> 8) & 0xFF)
		var py: int = ((p.y >> 8) & 0xFF) - top
		if pb3_loud:
			print("    %3d x %5d y %5d st %02X vy %6d gnd %02X cam %5d"
					% [i, px, py + lvl.cam_y, p.state, p.vy, p.floor_kind, eye.pos])
		if py > was and py - was > drop and py < 0xE0:
			drop = py - was
		was = py
		if py >= 0xE0 or py < -0x40:
			left = 1
			break
		if lvl.class_byte(px, py - 8) == 0x80:
			stuck += 1
			worst = maxi(worst, stuck)
		else:
			stuck = 0
	var ex: int = eye.pos + ((p.x >> 8) & 0xFF)
	var ey: int = ((p.y >> 8) & 0xFF) - top
	var front: int = 1 if lvl.class_byte(ex + 12, ey - 8) == 0x80 \
			or lvl.class_byte(ex + 12, ey - 1) == 0x80 else 0
	return ("pb2 %-6s %3d %3d pad %02X x0 %5d x1 %5d y1 %5d walled %3d"
			+ " drop %3d left %d front %d") % [
			tag, at.x, at.y, pad, world_x, ex, ey + lvl.cam_y, worst, drop,
			left, front]


## Э5.2 -- two heroes in one level, and the view that has to hold both.
##
## The same shape as `_run_pb3_floor`: the mode is handed a list of runs, finds
## places to stand out of the level's own answers, and prints one line a walk.
## What is judged is in `verify_pb3_pair.py`.
func _run_pb3_pair(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	pb3_loud = bool(cfg.get("loud", false))
	var out := PackedStringArray()
	for one in cfg["runs"]:
		var run: Dictionary = one
		var from: int = Pb3Pair.PB2 if String(run["game"]) == "pb2" \
				else Pb3Pair.SOL
		var stage := int(run["stage"])
		var area := int(run.get("area", 0))
		var spots := int(run.get("spots", 4))
		var frames := int(run.get("frames", 100))
		var pads: Array = run.get("pads", [[Pad.RIGHT, Pad.RIGHT]])
		var kinds: Array = run.get("kinds", [["pb2", "sol"]])
		var tag := "%s%d.%d" % ["p" if from == Pb3Pair.PB2 else "s",
				stage, area]
		# Where to stand is asked of the level once, through whichever of the
		# two classes the level is: the answers are the same either way.
		var look := Pb3Pair.new(from, stage, area, ["sol"])
		var lvl: SolLevel = look.solv
		var solid := func(cx: int, cy: int) -> bool:
			return lvl.collision_at(cx * 16 + 8, cy * 16 + 8) >= Pb2AsSol.SOLID
		var at: Array = _pb3_spots(solid, lvl.width_tiles / 2,
				lvl.height_tiles / 2, spots, 8, _pb3_band(look), [3])
		for pair in kinds:
			for pad in pads:
				for spot in at:
					out.append(_pb3_walk_pair(from, stage, area, pair, pad,
							Vector2i(spot), frames, tag))
	print("\n".join(out))


## Which cells of the level the view is able to bring to the screen.
##
## A Power Blade area is never bigger than its view can cover, so the whole of
## it counts.  A Solbrain stage is sixteen screens tall and its own record
## ($E72D) says how far the view may go each way; above the first line it may
## reach, and below the last, the game never puts anybody, and there is no
## screen to judge them against either.
func _pb3_band(two: Pb3Pair) -> Rect2i:
	if two.game == Pb3Pair.PB2:
		return Rect2i()
	var eye: SolCamera = two.sol_eye
	var x0: int = eye.x_min >> 4
	var x1: int = maxi(x0, (eye.x_end >> 4) - 0x100)
	var y0: int = eye.y_min >> 4
	var y1: int = maxi(y0, (eye.y_end >> 4) - 0x100)
	# The cells whose middle a reachable view can hold, his shoulder and his
	# head inside the screen (`Pb3Pair.EDGE` and `HEAD`).
	return Rect2i((x0 + Pb3Pair.EDGE) / 16,
			(y0 + Pb3Pair.HEAD) / 16,
			maxi(1, (x1 + 0x100 - Pb3Pair.EDGE) / 16 - (x0 + Pb3Pair.EDGE) / 16),
			maxi(1, (y1 + 0xF0 - Pb3Pair.EDGE) / 16 - (y0 + Pb3Pair.HEAD) / 16))


## One walk of the two of them.
##
## They start four cells apart on the same ledge -- `_pb3_spots` has already
## made sure the four cells to the right of a place are clear -- so the view
## begins with the middle of them in the middle of the screen and neither of
## them at an edge.  What is written down is what the two questions of Э5.2
## need: how far outside the screen anybody ever ended a picture, and the same
## two counts Э5.1 kept about the floor.
func _pb3_walk_pair(from: int, stage: int, area: int, kinds: Array,
		pads: Array, at: Vector2i, frames: int, tag: String) -> String:
	var two := Pb3Pair.new(from, stage, area, kinds)
	# Both are put down in the middle of the cell rather than on the floor of
	# it, and each game's own weight drops him the last eight pixels.  Power
	# Blade's hero will not walk while his feet are on the line itself: $A036
	# reads the cell his feet are in and finds the floor.
	two.begin([Vector2i(at.x * 16 + 8, at.y * 16 + 8),
			Vector2i((at.x + 3) * 16 + 8, at.y * 16 + 8)])
	var bottom: int = two.solv.height_tiles * 8
	var off := 0
	var below := 0
	var walled := [0, 0]
	var stuck := [0, 0]
	var drop := 0
	var was := [two.flat_of(0).y, two.flat_of(1).y]
	var apart := 0
	var began: int = (two.world_of(0).x + two.world_of(1).x) / 2
	var i := 0
	while i < frames and two.alive():
		two.step(pads)
		for k in range(2):
			if two.gone[k]:
				continue
			var w: Vector2i = two.world_of(k)
			var s: Vector2i = two.screen_of(k)
			if pb3_loud:
				print("    %3d %d w %5d %5d s %4d %4d view %5d %4d st %02X"
						% [i, k, w.x, w.y, s.x, s.y, two.view_x(),
						two.line_at(0),
						two.sol[k].state if two.who[k] == Pb3Pair.SOL
						else two.pb2[k].sub])
			# Off the side of the screen, which the edge is there to prevent,
			# and off the top or bottom, which it is not: that one is only
			# written down, to show the view keeping up with a fall.
			off = maxi(off, maxi(-s.x, s.x - 0x100))
			below = maxi(below, maxi(-s.y, s.y - 0xF0))
			# The edge moving him is not a fall, so what it moved him by is
			# taken back out before the picture's fall is measured.  Both
			# ways are measured, not only downwards: a Power Blade hero is
			# kept as one byte of the screen, and a hero who went off the
			# bottom of it and came round the top would show here as a leap
			# upwards and nowhere else.
			var fell: int = absi(two.flat_of(k).y - two.shoved[k].y - was[k])
			if fell > drop and w.y < bottom:
				drop = fell
			was[k] = two.flat_of(k).y
			if two.solv.collision_at(w.x, w.y - 8) >= Pb2AsSol.SOLID:
				stuck[k] += 1
				walled[k] = maxi(walled[k], stuck[k])
			else:
				stuck[k] = 0
		apart = maxi(apart, absi(two.world_of(0).x - two.world_of(1).x))
		i += 1
	var left := 0
	for k in range(2):
		if two.gone[k]:
			left += 1
	# How far the middle of them got, which is how far the view was made to
	# travel: a pair that never moved proves nothing about a view that follows
	# them.
	var went: int = absi((two.world_of(0).x + two.world_of(1).x) / 2 - began)
	return ("%-6s %s %s %3d %3d pads %02X %02X ran %3d off %4d walled %3d"
			+ " drop %3d apart %4d left %d held %4d stuck %3d went %4d"
			+ " below %4d") % [
			tag, String(kinds[0]), String(kinds[1]), at.x, at.y,
			int(pads[0]), int(pads[1]), i, off, maxi(walled[0], walled[1]),
			drop, apart, left, two.held_in, two.could_not, went, below]



## Э5.4 -- a foreign enemy against a foreign hero.
##
## Neither game ever saw the other's things, so there is nothing to compare
## against and the stand asks four mechanical questions instead
## (`work/extract/verify_pb3_hits.py`).  What is put out here is one line per
## placement: the level, the kind of thing, whose hero was stood in front of
## it, which of the eight places round its box he stood in, whether a blow had
## to land there, whether one did, whether a second one straight after did too,
## and what the first took off him.
##
## The eight places are not guessed.  The reach of a touch is the thing's own
## box grown by the hero's own box, which is the sum each game already does;
## the hero is put on each of its four edges and one step outside each.  A step
## is one pixel in a Power Blade area and one sixteenth of a pixel in a
## Solbrain stage, because that is the grid each game's places are kept on.
func _run_pb3_hits(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var edges: Array = cfg["edges"]
	var out := PackedStringArray()
	for r in cfg["runs"]:
		if String(r["game"]) == "pb2":
			_pb3_hits_pb2(int(r["stage"]), int(r["area"]), edges, out)
		else:
			_pb3_hits_sol(int(r["stage"]), edges, out)
	print("\n".join(out))


## One line of the stand's own shape.
func _pb3_hit_line(where: String, t: int, guest: String, edge: String,
		want: int, hit: int, again: int, dmg: int) -> String:
	return ("hit %s type %02X guest %s edge %s want %d hit %d again %d dmg %d"
			% [where, t, guest, edge, want, hit, again, dmg])


## The eight places round a reach that runs from `lo` to `hi` both ways, by the
## names the stand knows them by.
static func _pb3_edges(xlo: int, xhi: int, ylo: int, yhi: int) -> Dictionary:
	var cx: int = (xlo + xhi) / 2
	var cy: int = (ylo + yhi) / 2
	return {
		"in_left": [Vector2i(xlo, cy), 1],
		"in_right": [Vector2i(xhi, cy), 1],
		"in_top": [Vector2i(cx, ylo), 1],
		"in_bottom": [Vector2i(cx, yhi), 1],
		"out_left": [Vector2i(xlo - 1, cy), 0],
		"out_right": [Vector2i(xhi + 1, cy), 0],
		"out_top": [Vector2i(cx, ylo - 1), 0],
		"out_bottom": [Vector2i(cx, yhi + 1), 0],
	}


## A Power Blade area, with the Solbrain hero standing in it.
##
## His box is the one his own game builds out of his picture ($80DE), read
## through Э5.1's window and then said in this game's numbers: whole pixels,
## two halves, and how far above his feet the middle of it lies.  $82:$83
## stands sixteen pixels above his feet, which is where that sixteen comes
## from.
func _pb3_hits_pb2(stage: int, area: int, edges: Array,
		out: PackedStringArray) -> void:
	_load("pb2", stage, area)
	var where := "p%d.%d" % [stage, area]
	var lent := Pb2AsSol.new(level_pb2)
	var him := SolPlayer.new(lent)
	him.place(0x8000, 0x8000)
	# $B7F5 -- his box comes off his picture, and his picture off the step of
	# the animation he is on, so he has to have stood somewhere for a picture
	# before there is anything to read.
	for _i in range(4):
		him.step(0)
	var borrowed := SolObjects.new(lent)
	borrowed.hero = him
	borrowed.hero_box()
	if borrowed.hero_box_flags == 0:
		out.append("untranslated sol type 00 why box")
		return
	var half_w: int = (borrowed.hero_bw >> 4) / 2
	var half_h: int = (borrowed.hero_bh >> 4) / 2
	var dy: int = ((borrowed.hero_by - him.y + 0x8000) & 0xFFFF) - 0x8000
	var up: int = 16 - (dy >> 4) - half_h
	var things := Pb2Objects.new(level_pb2)
	things.playing = 3
	things.cam = 0
	things.frame = 1                                # $B23D starts at slot six
	# Only the guest is in the room: the area's own hero is not here at all,
	# and a row with no life left is how $B23D is told so.
	things.slots[0][Pb2Objects.F_LIFE] = 0
	var guest := Pb2Objects.empty_row()
	things.guest_row = guest
	things.guest_box = [up, half_w, half_h]
	for t in range(things.hurt.size()):
		if t == 0:
			continue                    # $B250 -- an empty place in the table
		if t == 0x0C:
			continue                    # $B28B -- a breakable block is scenery
		if things.hurt[t] == 0:
			continue                                # it does not hurt at all
		if t >= things.box.size() or things.box[t].is_empty():
			out.append("untranslated pb2 type %02X why box" % t)
			continue
		var b: Array = things.box[t][0]
		var rw: int = int(b[0]) + half_w
		var rh: int = int(b[1]) + half_h
		if rw > 0x60 or rh > 0x60:
			continue                # bigger than the screen; no room to stand
		# The thing is put where the middle of it comes out at $80,$80.
		var s: PackedByteArray = things.slots[6]
		var place := _pb3_edges(0x80 - rw, 0x80 + rw, 0x80 - rh, 0x80 + rh)
		for e in edges:
			var at: Vector2i = place[String(e)][0]
			var want: int = int(place[String(e)][1])
			for i in range(s.size()):
				s[i] = 0
			s[Pb2Objects.F_TYPE] = t
			s[Pb2Objects.F_MARK] = 0x01     # $C99F -> $FD76: it simply hurts
			s[Pb2Objects.F_LIFE] = 0x40
			s[Pb2Objects.F_X] = 0x80
			s[Pb2Objects.F_Y] = (0x80 - up + things.middle[t]) & 0xFF
			for i in range(guest.size()):
				guest[i] = 0
			guest[Pb2Objects.F_LIFE] = 0x10
			guest[Pb2Objects.F_X] = at.x & 0xFF
			guest[Pb2Objects.F_Y] = at.y & 0xFF
			things.contact()
			var hit: int = 1 if guest[Pb2Objects.F_STUN] != 0 else 0
			# What it cost him is counted in this area's numbers, so it is
			# said in his own before it is put out: sixteen against eight.
			var dmg: int = Pb3Pair.hurt_to_sol(0x10 - guest[Pb2Objects.F_LIFE])
			# And a second blow straight after, which the grace has to refuse.
			s[Pb2Objects.F_TYPE] = t
			s[Pb2Objects.F_MARK] = 0x01
			s[Pb2Objects.F_LIFE] = 0x40
			var was: int = guest[Pb2Objects.F_LIFE]
			things.contact()
			var again: int = 1 if guest[Pb2Objects.F_LIFE] != was else 0
			out.append(_pb3_hit_line(where, t, "sol", String(e), want, hit,
					again, dmg))


## A Solbrain stage, with the Power Blade hero standing in it.
##
## His box is his own game's ($B2C1) -- two halves in whole pixels, and a
## middle so far above his feet -- said here in sixteenths and as the four
## numbers $88..$8F hold: a corner and a size.
func _pb3_hits_sol(stage: int, edges: Array, out: PackedStringArray) -> void:
	_load("sol", stage, 0)
	var where := "s%d.0" % stage
	var mine: Array = Pb2Objects.own_box(Pb2Objects.empty_row())
	var up: int = int(mine[0])
	var half_w: int = int(mine[1])
	var half_h: int = int(mine[2])
	var bw: int = (half_w * 2 + 1) << 4
	var bh: int = (half_h * 2 + 1) << 4
	var pool := SolObjects.new(level_sol)
	# The stage's own hero is not here: a suit of nought is how $CFDB is told
	# so, and it stops at him without reaching anything after him.
	var absent := SolPlayer.new(level_sol)
	absent.suit = 0
	pool.hero = absent
	pool.clock = 0
	var carrier := SolPlayer.new(level_sol)
	pool.guest = carrier
	for k in pool.hit_kinds():
		var pic: int = int(k[0])
		var flags: int = int(k[1])
		var shape: int = int(k[2])
		var box: Array = k[3]
		if (flags & 0x80) != 0:
			continue                            # something to pick up
		if (flags & 0x40) != 0 and (flags & 0x0F) != 0:
			continue                            # $824E -- it never touches
		if (flags & 0x40) == 0 and (flags & 0x0F) == 0:
			continue                            # and it hurts for nothing
		pool.id[0] = 1
		pool.kind[0] = 1
		pool.mind[0] = 0
		pool.face[0] = 0
		pool.x[0] = 0x8000
		pool.y[0] = 0x8000
		pool.pic_lo[0] = pic & 0xFF
		pool.pic_hi[0] = (pic >> 8) & 0xFF
		if not pool.touch_box(0):
			continue
		# $81B7 -- the reach, said in the corner of his own box.  Where the
		# thing's box landed is asked of $CF96 rather than worked out again:
		# it chains the carry of the across sum into the down one, so the two
		# are not two sums but one.
		var place := _pb3_edges(pool.z61 - bw - 1, pool.z61 + pool.z65,
				pool.z63 - bh - 1, pool.z63 + pool.z67)
		for e in edges:
			var at: Vector2i = place[String(e)][0]
			var want: int = int(place[String(e)][1])
			pool.mind[0] = 0
			pool.cool[0] = 0x40
			pool.life[0] = 0x40
			carrier.suit = 0x10
			carrier.hurt = 0
			carrier.shield = 0
			carrier.swim = 0
			carrier.timer = 0xFF
			pool.guest_box = [0x01, at.x & 0xFFFF, at.y & 0xFFFF, bw, bh]
			pool.touch_box(0)
			pool.touch(0)
			# $8354 -- a blow that lands puts the count back to nought, and
			# nothing here ever counts it up again, so the second one is
			# refused by the grace and not by the boxes.
			var hit: int = 1 if carrier.timer == 0 else 0
			var dmg: int = Pb3Pair.hurt_to_pb2(0x10 - carrier.suit)
			var was: int = carrier.suit
			pool.touch_box(0)
			pool.touch(0)
			var again: int = 1 if carrier.suit != was else 0
			out.append(_pb3_hit_line(where, shape, "pb2", String(e), want, hit,
					again, dmg))


## Э5.8 -- a foreign weapon against a foreign thing, which is Э5.4 the other
## way about.
##
## Nothing to compare against here either, so the questions are mechanical
## (`work/extract/verify_pb3_arms.py`).  One line a placement: the level, the
## kind of thing, which sort of weapon was laid over it, which of the eight
## places round its reach the weapon stood in, whether a blow had to land,
## whether one did, whether a second straight after did too, what it took off
## the thing, and what the thing said it cost the weapon.
##
## The eight places are the ones Э5.4 uses, for the same reason: the reach is
## the thing's own box grown by what the weapon reaches, which is the sum both
## games already do, and the weapon is put on each of its four edges and one
## step outside each.
func _run_pb3_arms(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var edges: Array = cfg["edges"]
	var out := PackedStringArray()
	for r in cfg["runs"]:
		if String(r["game"]) == "pb2":
			_pb3_arms_pb2(int(r["stage"]), int(r["area"]), edges, out)
		else:
			_pb3_arms_sol(int(r["stage"]), edges, out)
	# And the second leg: the same weapons in a level that is really running,
	# to say that a guest ever has anything in the air at all.
	if cfg.has("live"):
		_pb3_arms_live(cfg["live"], out)
	print("\n".join(out))


## Э5.8, the second leg -- a guest firing in a live level.
##
## The first leg says the seam is right; this says it is used.  The whole list
## is walked in each pairing, as Э5.7 walks it, with every hero armed -- a
## Power Blade one has his blade from the first picture, and a Solbrain one is
## handed one of the eight satellites by Э5.5's own door (`Pb3Gear.arm`), which
## is the only way either game ever gives him one.  What is counted is how many
## pictures a guest had anything of his own in the air and how many of those
## reached a thing of the level.
func _pb3_arms_live(cfg: Dictionary, out: PackedStringArray) -> void:
	var frames: int = int(cfg["frames"])
	for kinds in cfg["kinds"]:
		var lst := Pb3List.new(kinds)
		var recs: Array = Pb3List.records()
		for n in range(recs.size()):
			lst.at = 0
			lst.last_pad = 0
			for _s in range(n):
				lst.step(Pb3List.RIGHT)
				lst.step(0)
			var where: String = Pb3List.say(recs[n])
			if not lst.enter(true):
				continue
			out.append(_pb3_arms_one(lst, where, kinds, frames))
			lst.leave()


## One record, played out with both of them armed.
func _pb3_arms_one(lst: Pb3List, where: String, kinds: Array,
		frames: int) -> String:
	var two: Pb3Pair = lst.two
	# $92CD -- the satellite a finished combination gives him, and the one
	# place in the engine that hands one over.
	var gear := Pb3Gear.new(kinds)
	for i in range(two.who.size()):
		if two.who[i] != Pb3Pair.SOL:
			continue
		if i == two.host:
			gear.arm(two.host_sol, i)
		else:
			gear.arm(two.guest_pool[i], i)
	var down: bool = two.game == Pb3Pair.PB2 \
			and (two.pb2v as Pb2Level).vertical
	var along: int = Pad.RIGHT
	var still := 0
	var furthest := 0
	var began: Array[Vector2i] = []
	for i in range(two.who.size()):
		began.append(two.world_of(i))
	var went: Array[int] = [0, 0]
	var ran := 0
	for f in range(frames):
		var way: int = along | (Pad.DOWN if down else 0)
		var pads_now: Array = [way, way]
		for i in range(2):
			if f % 24 == 8:
				pads_now[i] |= Pad.A
			# Э5.8 -- and they do not throw in step.  Э5.7's pilot held one pad
			# and handed it to both, which in a Power Blade area makes two
			# heroes standing in the same place throw the same blade at the
			# same thing on the same picture; the first of the two ends it
			# ($B698) or sets it ringing ($B5D8), and the second finds nothing
			# left to reach.  Half a throw apart and each has things of his own
			# to hit.
			if (f + i * 4) % 8 < 2:
				pads_now[i] |= Pad.B
		_pb3_keep_alive(two)
		two.step(pads_now)
		ran += 1
		for i in range(two.who.size()):
			if two.gone[i]:
				continue
			went[i] = maxi(went[i], absi(two.world_of(i).x - began[i].x))
		var far: int = maxi(went[0], went[1])
		if far > furthest:
			furthest = far
			still = 0
		else:
			still += 1
			if still >= 120:
				still = 0
				along = Pad.LEFT if along == Pad.RIGHT else Pad.RIGHT
	return ("live %s %s %s ran %d flying %d landed %d"
			% [where, kinds[0], kinds[1], ran, two.arms_flying,
			two.arms_landed])


## One line of the stand's own shape.
func _pb3_arm_line(where: String, t: int, arm: String, edge: String,
		want: int, hit: int, again: int, took: int, cost: int,
		owed: int, power: int) -> String:
	return ("arm %s kind %02X sort %s edge %s want %d hit %d again %d took %d "
			+ "cost %d owed %d power %d") % [where, t, arm, edge, want, hit,
			again, took, cost, owed, power]


## The sorts of weapon a guest can be carrying, `[name, reach, power]` in whole
## pixels.  Not guessed: the four of Power Blade come out of its own two tables
## ($A84D by type), and the three of Solbrain out of its own code -- $87BC
## takes one off a thing and the shot is a point, while $84B0 grows the thing's
## box by eight pixels before his own four are asked and by eight again before
## the last two of them.
func _pb3_arm_kinds(w: Pb2Objects) -> Array:
	var out: Array = []
	for t in range(1, w.shot_size.size()):
		out.append(["blade%d" % t, int(w.shot_size[t]), int(w.shot_power[t])])
	out.append(["gun", 0, 1])
	out.append(["sat", 8, 1])
	out.append(["swing", 16, 2])
	return out


## A Power Blade area, with a guest's weapons flying in it.
func _pb3_arms_pb2(stage: int, area: int, edges: Array,
		out: PackedStringArray) -> void:
	_load("pb2", stage, area)
	var where := "p%d.%d" % [stage, area]
	var things := Pb2Objects.new(level_pb2)
	things.playing = 3
	things.cam = 0
	things.frame = 1                                # $B23D starts at slot six
	# Nobody of this area's own game is in the room, which a row with no life
	# left is how $B23D is told; what is here is only what a guest threw.
	things.slots[0][Pb2Objects.F_LIFE] = 0
	var arms: Array = []
	var cost: Array = [-1]
	things.guest_arms = [[arms,
			func(_j: int, c: int) -> void: cost[0] = c]]
	for kind in _pb3_arm_kinds(things):
		var sort: String = String(kind[0])
		var reach: int = int(kind[1])
		var power: int = int(kind[2])
		for t in range(things.hurt.size()):
			if t == 0:
				continue                # $B250 -- an empty place in the table
			if t >= things.box.size() or things.box[t].is_empty():
				out.append("unreached pb2 type %02X why box" % t)
				continue
			var b: Array = things.box[t][0]
			var rw: int = int(b[0]) + reach
			var rh: int = int(b[1]) + reach
			if rw > 0x60 or rh > 0x60:
				continue            # bigger than the screen; no room to stand
			var s: PackedByteArray = things.slots[6]
			var place := _pb3_edges(0x80 - rw, 0x80 + rw, 0x80 - rh, 0x80 + rh)
			for e in edges:
				var at: Vector2i = place[String(e)][0]
				var want: int = int(place[String(e)][1])
				for i in range(s.size()):
					s[i] = 0
				s[Pb2Objects.F_TYPE] = t
				s[Pb2Objects.F_MARK] = 0x01     # $C99F: it simply hurts
				s[Pb2Objects.F_LIFE] = 0x40
				s[Pb2Objects.F_X] = 0x80
				s[Pb2Objects.F_Y] = (0x80 + things.middle[t]) & 0xFF
				arms.clear()
				arms.append([at.x, at.y, reach, power])
				cost[0] = -1
				# Whether the blow landed is whether the row changed at all,
				# and not whether its health went down: a breakable block has
				# no health to take off and $B688 simply ends it.
				var before: PackedByteArray = s.duplicate()
				things.contact()
				var hit: int = 1 if s != before else 0
				var took: int = (0x40 - s[Pb2Objects.F_LIFE]) & 0xFF
				var said: int = cost[0]
				# And a second blow straight after, which the ringing has to
				# refuse ($B5D8).
				var was: PackedByteArray = s.duplicate()
				things.contact()
				var again: int = 1 if s != was else 0
				out.append(_pb3_arm_line(where, t, sort, String(e), want, hit,
						again, took, said, things.hurt[t], power))


## And a Solbrain stage, with a guest's weapons flying in it.
func _pb3_arms_sol(stage: int, edges: Array, out: PackedStringArray) -> void:
	_load("sol", stage, 0)
	var where := "s%d.0" % stage
	var lent := SolAsPb2.new(level_sol)
	var tables := Pb2Objects.new(lent)
	var pool := SolObjects.new(level_sol)
	# The stage's own hero is not here: a suit of nought is how $CFDB is told
	# so, and it stops at him without reaching anything after him.
	var absent := SolPlayer.new(level_sol)
	absent.suit = 0
	pool.hero = absent
	pool.clock = 0
	var arms: Array = []
	var cost: Array = [-1]
	pool.guest_arms = [[arms,
			func(_j: int, c: int) -> void: cost[0] = c]]
	for kind in _pb3_arm_kinds(tables):
		var sort: String = String(kind[0])
		var reach: int = int(kind[1]) << 4
		var power: int = int(kind[2])
		for k in pool.hit_kinds():
			var pic: int = int(k[0])
			var flags: int = int(k[1])
			var shape: int = int(k[2])
			if (flags & 0x80) != 0:
				continue                    # $869C -- something to pick up
			if (flags & 0x3F) == 0:
				continue                    # and it hurts for nothing
			if (flags & 0x20) != 0:
				continue                    # $86A0 -- no gun ever reaches it
			pool.id[0] = 1
			pool.kind[0] = 1
			pool.mind[0] = 0
			pool.face[0] = 0
			pool.x[0] = 0x8000
			pool.y[0] = 0x8000
			pool.pic_lo[0] = pic & 0xFF
			pool.pic_hi[0] = (pic >> 8) & 0xFF
			if not pool.touch_box(0):
				continue
			var place := _pb3_edges(pool.z61 - reach,
					pool.z61 + pool.z65 + reach,
					pool.z63 - reach, pool.z63 + pool.z67 + reach)
			for e in edges:
				var at: Vector2i = place[String(e)][0]
				var want: int = int(place[String(e)][1])
				pool.mind[0] = 0
				pool.cool[0] = 0x40
				pool.life[0] = 0x40
				arms.clear()
				arms.append([at.x & 0xFFFF, at.y & 0xFFFF, reach, power])
				cost[0] = -1
				pool.touch_box(0)
				pool.touch(0)
				var hit: int = 1 if pool.life[0] != 0x40 else 0
				var took: int = 0x40 - pool.life[0]
				var said: int = cost[0]
				# $87BA -- the nine pictures of rest the last blow left have
				# to refuse the second.
				var was: int = pool.life[0]
				pool.touch_box(0)
				pool.touch(0)
				var again: int = 1 if pool.life[0] != was else 0
				out.append(_pb3_arm_line(where, shape, sort, String(e), want,
						hit, again, took, said, flags & 0x0F, power))


## Э5.3 -- the screen the two of them choose on.
##
## Four questions, and the first of them the engine has to walk out for itself
## (`work/extract/verify_pb3_pick.py`).  Nothing here knows which buttons do
## what: the walk tries every pad the two of them can hold between them and
## lets the picker say where that put it, so a button the picker stops reading
## would show as a way that was never found.
func _run_pb3_pick(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var ways: Array = cfg["ways"]
	var quiet: int = int(cfg["quiet"])
	var out := PackedStringArray()
	# Every pad worth holding: the four ways across and the two buttons, alone
	# and two at a time, for each of the two of them.
	var one: Array = [0x00, 0x01, 0x02, 0x40, 0x80]
	var pads: Array = []
	for a in one:
		for b in one:
			pads.append([a, b])
	for from in ways:
		# Shortest first, over everything the picker holds and not only over
		# what was chosen: a walk that forgot the "ready" of each of them
		# would call two different places the same one.
		var seen := {}
		var reached := {}
		var settled := {}
		var start := Pb3Pick.new()
		start.set_say(String(from))
		seen[start.where()] = 0
		reached[start.say()] = 0
		var edge: Array = [[start.where(), _pb3_pick_keep(start), 0]]
		while not edge.is_empty():
			var next: Array = []
			for e in edge:
				for p in pads:
					var w := Pb3Pick.new()
					_pb3_pick_put(w, e[1])
					w.step(p)
					var k: String = w.where()
					if seen.has(k):
						continue
					seen[k] = int(e[2]) + 1
					if not reached.has(w.say()):
						reached[w.say()] = int(e[2]) + 1
					if w.done() and not settled.has(w.say()):
						settled[w.say()] = int(e[2]) + 1
					next.append([k, _pb3_pick_keep(w), int(e[2]) + 1])
			edge = next
		for to in ways:
			out.append("reach %s %s steps %d"
					% [from, to, reached[to] if reached.has(to) else -1])
			# And reached with both of them saying they are done with it:
			# an arrangement nobody can settle on is one nobody can play.
			out.append("settle %s %s steps %d"
					% [from, to, settled[to] if settled.has(to) else -1])
		# A pad that presses nothing, held for a second.
		var still := Pb3Pick.new()
		still.set_say(String(from))
		var was: String = still.where()
		var drawn: PackedByteArray = still.picture()
		for _i in range(quiet):
			still.step([0, 0])
		var changed: int = 0 if still.where() == was \
				and still.picture() == drawn else 1
		out.append("quiet %s changed %d" % [from, changed])
		# The same buttons twice over, and the two pictures compared whole.
		var script: Array = [[0x01, 0x02], [0x00, 0x00], [0x80, 0x01],
				[0x00, 0x00], [0x02, 0x80], [0x40, 0x00]]
		var shots: Array = []
		for _t in range(2):
			var w := Pb3Pick.new()
			w.set_say(String(from))
			var all := PackedByteArray()
			for p in script:
				w.step(p)
				all.append_array(w.picture())
			shots.append(all)
		out.append("picture %s same %d bytes %d"
				% [from, 1 if shots[0] == shots[1] else 0,
						(shots[0] as PackedByteArray).size() / script.size()])
		# And what was chosen, handed to the pair and asked back.
		var pick := Pb3Pick.new()
		pick.set_say(String(from))
		var two := Pb3Pair.new(Pb3Pair.PB2, 0, 0, pick.kinds())
		var back := PackedStringArray()
		for k in two.who:
			back.append("sol" if k == Pb3Pair.SOL else "pb2")
		out.append("handed %s who %s" % [from, ",".join(back)])
	print("\n".join(out))


## Everything the picker holds, so that a walk can put it back.
func _pb3_pick_keep(w: Pb3Pick) -> Array:
	return [w.chose[0], w.chose[1], w.ready[0], w.ready[1],
			w.last_pad[0], w.last_pad[1]]


func _pb3_pick_put(w: Pb3Pick, k: Array) -> void:
	w.chose[0] = int(k[0])
	w.chose[1] = int(k[1])
	w.ready[0] = bool(k[2])
	w.ready[1] = bool(k[3])
	w.last_pad[0] = int(k[4])
	w.last_pad[1] = int(k[5])


## Э5.5 -- one bar for the two of them.
##
## Two of the four questions compare against the class that owns the answer
## rather than against a mechanical rule, so the same input is run twice: once
## through a plain `Pb2Status`, which is the cartridge's own $CDB8, and once
## through `Pb3Gear`.  `work/extract/verify_pb3_gear.py` says what each line
## means.
func _run_pb3_gear(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var suits: int = int(cfg["suits"])
	var guns: int = int(cfg["guns"])
	var frames: int = int(cfg["frames"])
	var out := PackedStringArray()
	# Which of them can be reached from the menu, by each of the two, walked
	# out rather than asserted.
	for i in range(2):
		for k in range(suits):
			out.append("choose p%d suit n %d got %d"
					% [i, k, 1 if _pb3_gear_reach(i, Pb3Gear.PB2, k) else 0])
		for k in range(1, guns + 1):
			out.append("choose p%d gun n %d got %d"
					% [i, k, 1 if _pb3_gear_reach(i, Pb3Gear.SOL, k) else 0])
	# The wear, suit by suit, against the cartridge's own class alone.
	for k in range(1, suits):
		out.append("wear suit n %d alone %s shared %s"
				% [k, _pb3_gear_alone(k, frames), _pb3_gear_shared(k, frames)])
	# And two of them on the one bar: what came off between them is what each
	# would have taken alone.
	out.append(_pb3_gear_both(frames))
	# The ending, when the bar runs dry.
	for k in range(1, suits):
		out.append("empty suit n %d alone %s shared %s"
				% [k, _pb3_gear_end_alone(k), _pb3_gear_end_shared(k)])
	for k in range(1, guns + 1):
		out.append("empty gun n %d alone %s shared %s"
				% [k, _pb3_gear_gun_alone(k), _pb3_gear_gun_shared(k)])
	print("\n".join(out))


## Is this suit, or this gun, one the menu can be walked to?  Nothing here
## knows which button does what: every pad the player can hold is tried, in
## the breadth-first way Э5.3's own walk goes, and the gear is asked what it
## is holding.
func _pb3_gear_reach(i: int, kind: int, want: int) -> bool:
	var pads: Array = [0x00, 0x04, 0x08, 0x10]
	var kinds: Array = [Pb3Gear.PB2, Pb3Gear.PB2]
	kinds[i] = kind
	var seen := {}
	var edge: Array = [_pb3_gear_seed(kinds, i)]
	seen[_pb3_gear_word(edge[0], i)] = true
	if int(edge[0].pick(i)) == want:
		return true
	for _round in range(8):
		var next: Array = []
		for g in edge:
			for p in pads:
				var w: Pb3Gear = _pb3_gear_copy(g, kinds)
				var hits: Array = [0, 0]
				hits[i] = p
				w.step(hits)
				var key: String = _pb3_gear_word(w, i)
				if seen.has(key):
					continue
				seen[key] = true
				if int(w.pick(i)) == want:
					return true
				next.append(w)
		if next.is_empty():
			return false
		edge = next
	return false


func _pb3_gear_seed(kinds: Array, i: int) -> Pb3Gear:
	var g := Pb3Gear.new(kinds)
	if kinds[i] == Pb3Gear.SOL:
		g.gun[i] = 1
	return g


## Everything of his side of the gear that a walk has to tell apart.
func _pb3_gear_word(g: Pb3Gear, i: int) -> String:
	return "%d %d %d" % [g.pick(i), 1 if g.menu_open(i) else 0, g.last_pad[i]]


func _pb3_gear_copy(g: Pb3Gear, kinds: Array) -> Pb3Gear:
	var w := Pb3Gear.new(kinds, g.energy, g.tanks)
	for i in range(kinds.size()):
		w.gun[i] = g.gun[i]
		w.open[i] = g.open[i]
		w.last_pad[i] = g.last_pad[i]
		var a: Pb2Status = g.st[i]
		var b: Pb2Status = w.st[i]
		b.suit = a.suit
		b.menu = a.menu
		b.came_in = a.came_in
		b.mode = a.mode
		b.drain_hi = a.drain_hi
		b.drain_lo = a.drain_lo
		b.clock = a.clock
	return w


## The cells, picture by picture, as one word.  A suit that took the same
## total by a different road is not the same suit, so the whole run is kept
## and not just how much is left at the end.
func _pb3_gear_alone(suit: int, frames: int) -> String:
	var s := Pb2Status.new()
	s.stage = Pb2Status.LAST_STAGE
	s.area = 0
	s.suit = suit
	s.energy = 16
	var out := PackedStringArray()
	for f in range(frames):
		s.step(0)
		out.append(str(s.energy))
	return _pb3_gear_runs(out)


func _pb3_gear_shared(suit: int, frames: int) -> String:
	var g := Pb3Gear.new([Pb3Gear.PB2], 16, 0)
	(g.st[0] as Pb2Status).suit = suit
	var out := PackedStringArray()
	for f in range(frames):
		g.step([0])
		out.append(str(g.energy))
	return _pb3_gear_runs(out)


## The same run of numbers, said short: a number and how many pictures it
## stood for.  A long word compares the same and prints readably.
static func _pb3_gear_runs(v: PackedStringArray) -> String:
	var out := PackedStringArray()
	var i := 0
	while i < v.size():
		var j: int = i
		while j < v.size() and v[j] == v[i]:
			j += 1
		out.append("%s:%d" % [v[i], j - i])
		i = j
	return ",".join(out)


## Two of them wearing two suits on the one bar, and what each would have
## taken alone.  Both are counted in cells and not in what is left, because
## the bar is refilled under them as it empties.
func _pb3_gear_both(frames: int) -> String:
	var a: int = _pb3_gear_took(1, frames)
	var b: int = _pb3_gear_took(4, frames)
	var g := Pb3Gear.new([Pb3Gear.PB2, Pb3Gear.PB2], 16, 0)
	(g.st[0] as Pb2Status).suit = 1
	(g.st[1] as Pb2Status).suit = 4
	var took := 0
	for f in range(frames):
		var was: int = g.energy
		g.step([0, 0])
		took += maxi(0, was - g.energy)
		if g.energy == 0:
			g.energy = 16
			for s in g.st:
				(s as Pb2Status).suit = 1 if s == g.st[0] else 4
	return "shared cells %d apart %d %d" % [took, a, b]


## How many cells one suit takes off in that many pictures, alone, with the
## bar filled again each time it empties so that the suit never comes off.
func _pb3_gear_took(suit: int, frames: int) -> int:
	var s := Pb2Status.new()
	s.stage = Pb2Status.LAST_STAGE
	s.area = 0
	s.suit = suit
	s.energy = 16
	var took := 0
	for f in range(frames):
		var was: int = s.energy
		s.step(0)
		took += maxi(0, was - s.energy)
		if s.energy == 0:
			s.energy = 16
			s.suit = suit
	return took


## What $D312 leaves when the bar runs out, said as the fields it touches.
func _pb3_gear_end_alone(suit: int) -> String:
	var s := Pb2Status.new()
	s.stage = Pb2Status.LAST_STAGE
	s.area = 0
	s.suit = suit
	s.energy = 1
	s.tanks = 0
	while s.suit != 0:
		s.step(0)
	return "%d,%d,%d,%d" % [s.suit, s.energy, s.chr_bank,
			1 if s.clear_shots else 0]


func _pb3_gear_end_shared(suit: int) -> String:
	var g := Pb3Gear.new([Pb3Gear.PB2], 1, 0)
	var s: Pb2Status = g.st[0]
	s.suit = suit
	while s.suit != 0:
		g.step([0])
	return "%d,%d,%d,%d" % [s.suit, g.energy, s.chr_bank,
			1 if g.clear_shots[0] else 0]


## And what $9347 leaves when the satellite is given no life, which is how his
## own game takes it away.
func _pb3_gear_gun_alone(gun: int) -> String:
	_load("sol", 0, 0)
	var pool := SolObjects.new(level_sol)
	var him := SolPlayer.new(level_sol)
	him.pool = pool
	var d: Dictionary = Nes._load_json(Nes.DATA + "/sol/sat.json")
	pool.mind[SolObjects.SAT] = gun - 1
	pool.id[SolObjects.SAT] = int(d["weapon_of"][gun - 1])
	pool.life[SolObjects.SAT] = 0x10
	SolSat.lose(pool)                       # $9359 and $A4FD
	return _pb3_gear_sat(pool)


func _pb3_gear_gun_shared(gun: int) -> String:
	_load("sol", 0, 0)
	var pool := SolObjects.new(level_sol)
	var g := Pb3Gear.new([Pb3Gear.SOL], 16, 0)
	g.gun[0] = gun
	g.arm(pool, 0)
	# Sixteen off the sixteen, which is the whole bar.
	g.hurt_gun(0, 16)
	g.arm(pool, 0)
	return _pb3_gear_sat(pool)


## Slot twelve, as the numbers $9359 and $A4FD touch between them.
static func _pb3_gear_sat(pool: SolObjects) -> String:
	var s: int = SolObjects.SAT
	return ("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d"
			% [pool.id[s], pool.b[s], pool.c[s], pool.d[s], pool.kind[s],
					pool.left[s], pool.frame[s], pool.anim_a[s],
					pool.anim_b[s], pool.pic_lo[s], pool.pic_hi[s]])


## Э5.6 -- the fifty three areas and the twenty stages behind one cursor.
##
## Every record in every pairing, raised, played and left again.  See
## `work/extract/verify_pb3_list.py` for what each line is asked about.
func _run_pb3_list(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var frames: int = int(cfg["frames"])
	var pads: Array = cfg["pads"]
	var out := PackedStringArray()
	for kinds in cfg["kinds"]:
		var lst := Pb3List.new(kinds)
		var recs: Array = Pb3List.records()
		for n in range(recs.size()):
			# The cursor is walked to the record rather than set, so that
			# every line below is about a record the list could actually
			# offer.
			lst.at = 0
			lst.last_pad = 0
			for _s in range(n):
				lst.step(Pb3List.RIGHT)
				lst.step(0)
			var from: int = lst.at
			var up: int = 1 if lst.enter() else 0
			var where: String = Pb3List.say(recs[n])
			if up == 0:
				out.append(("rec %s %s %s up 0 solid 0 ran 0 alive 0 "
						+ "ground 0 back %d from %d")
						% [where, kinds[0], kinds[1], from, from])
				continue
			var two: Pb3Pair = lst.two
			# Nobody put inside something, counted the way Э5.1 and Э5.2
			# count it: at the start and after every picture.
			var walled := 0
			for i in range(two.who.size()):
				if not two.standing(two.world_of(i)):
					walled += 1
			# Whether the level has anything under the place it opens on:
			# one area opens over water with no floor in that column at all,
			# and a hero who sinks out of it there was not dropped by the
			# engine.  Asked of the level, not decided here.
			var ground := 0
			for i in range(two.who.size()):
				if two.ground_under(two.world_of(i)):
					ground += 1
			# Every picture is played whatever becomes of the two of them:
			# a record that stops early is the fault this is looking for, and
			# a pair with nobody left in it still has to step without
			# falling over.
			var ran := 0
			for f in range(frames):
				two.step(pads)
				ran += 1
				for i in range(two.who.size()):
					if two.gone[i]:
						continue
					if not two.standing(two.world_of(i)):
						walled += 1
			var alive: int = 1 if two.alive() else 0
			lst.leave()
			out.append(("rec %s %s %s up 1 solid %d ran %d alive %d "
					+ "ground %d back %d from %d")
					% [where, kinds[0], kinds[1], walled, ran, alive,
							ground, lst.at, from])
		# And that the cursor reaches every one of them, walked and not
		# counted: a record nobody can walk to is a record missing.
		var seen := {}
		var walker := Pb3List.new(kinds)
		for _s in range(recs.size() * 2):
			seen[walker.at] = true
			walker.step(Pb3List.RIGHT)
			walker.step(0)
		out.append("walked %d of %d" % [seen.size(), recs.size()])
	print("\n".join(out))

## Э5.7 -- the whole list played by two, with the levels themselves running.
##
## Э5.6 walked the same eighty three records with the levels empty: two heroes
## and a view and nothing else in the room.  This raises each record with its
## own game round it -- its things, its order, and in a Solbrain stage its
## script -- and plays it out with both heroes in it, whichever games they came
## from.  Whoever came from the game the level did stands in the one place that
## game keeps for a hero; the other is a guest of it (Э5.4).
##
## A pilot holds the two of them apart and taps the buttons.  The pilot is not
## on trial and cannot play either game: it keeps both of them alive, the way
## every other run here does, because a pilot that cannot fight would otherwise
## spend the record dying rather than playing it.
##
## What is on trial is the run.  One line per record and pairing: how many
## pictures it played, the most things the level had out at once, how far each
## of the two was carried, how many pictures either of them spent inside
## something solid, what the order said the picture ended as, and what the
## engine did not know -- a behaviour it has never read, a routine that ran off
## the end of its own table, a record the export has never seen.
func _run_pb3_run(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var frames: int = int(cfg["frames"])
	# The level's own game can be left out, which is Э5.6's empty room played
	# by this run's pilot: it is how a thing the level did is told from a thing
	# the two of them would have done anyway.
	var flow: bool = not cfg.has("flow") or int(cfg["flow"]) != 0
	var out := PackedStringArray()
	for kinds in cfg["kinds"]:
		var lst := Pb3List.new(kinds)
		var recs: Array = Pb3List.records()
		for n in range(recs.size()):
			lst.at = 0
			lst.last_pad = 0
			for _s in range(n):
				lst.step(Pb3List.RIGHT)
				lst.step(0)
			var where: String = Pb3List.say(recs[n])
			if not lst.enter(flow):
				out.append("run %s %s %s ran 0 things 0 went 0 0 solid 0 "
						% [where, kinds[0], kinds[1]]
						+ "ends none owed 0 wild 0 lost 0 up 0")
				continue
			out.append(_pb3_one_run(lst, where, kinds, frames))
			lst.leave()
	print("\n".join(out))


## One record, played out.
func _pb3_one_run(lst: Pb3List, where: String, kinds: Array,
		frames: int) -> String:
	var two: Pb3Pair = lst.two
	var began: Array[Vector2i] = []
	for i in range(two.who.size()):
		began.append(two.world_of(i))
	var went: Array[int] = [0, 0]
	var walled := 0
	var most := 0
	var ends := {}
	var ran := 0
	# The pilot holds them along the level and, in an area that scrolls
	# downwards, down it as well -- the same two the accepted runs hold.  It
	# cannot climb, so when neither of them has got anywhere for two seconds
	# it turns them round: a level walked into a wall for four hundred pictures
	# would never be made to put its things out, and what is on trial is the
	# level and not the pilot.
	var down: bool = two.game == Pb3Pair.PB2 \
			and (two.pb2v as Pb2Level).vertical
	var along: int = Pad.RIGHT
	var still := 0
	var furthest := 0
	# How many of the level's own things came out over the whole run, counted
	# as a place in the pool going from empty to taken, and how many its own
	# data holds to put out at all.  A record with nothing to put out is not
	# a record that failed to put anything out.
	var born := 0
	# And, in a Solbrain stage, how many of its sixteen rooms the view stood
	# in: a stage puts out the group its room names ($9A), so a stage that
	# never left the room it opened in was never asked for a second group.
	var rooms := {}
	var was_out: Array[bool] = []
	for k in range(maxi(Pb2Objects.SLOTS, SolObjects.SLOTS)):
		was_out.append(false)
	for f in range(frames):
		# The pilot: both of them are held the same way and turned round every
		# so often, so that the middle of them -- which is what the view
		# follows -- really travels and the level is made to put its things
		# out where it keeps them, rather than sitting still between two
		# heroes pulling apart.  The buttons are tapped on a rhythm neither
		# game reads as a hold.
		var way: int = along | (Pad.DOWN if down else 0)
		var pads_now: Array = [way, way]
		for i in range(2):
			if f % 24 == 8:
				pads_now[i] |= Pad.A
			if f % 8 < 2:
				pads_now[i] |= Pad.B
		_pb3_keep_alive(two)
		two.step(pads_now)
		ran += 1
		ends[two.ended] = true
		for i in range(two.who.size()):
			if two.gone[i]:
				continue
			went[i] = maxi(went[i], absi(two.world_of(i).x - began[i].x))
			if not two.standing(two.world_of(i)):
				walled += 1
		var far: int = maxi(went[0], went[1])
		if far > furthest:
			furthest = far
			still = 0
		else:
			still += 1
			if still >= 120:
				still = 0
				along = Pad.LEFT if along == Pad.RIGHT else Pad.RIGHT
		if two.host_sol != null:
			rooms[two.host_sol.room] = true
		var now: Array[bool] = _pb3_who_is_out(two)
		var n := 0
		for k in range(now.size()):
			if now[k]:
				n += 1
				if not was_out[k]:
					born += 1
			was_out[k] = now[k]
		most = maxi(most, n)
	# What the engine did not know.  A Power Blade area has no such count --
	# every one of its minds is ported -- so the three below are a Solbrain
	# stage's, and a Power Blade area answers them with noughts.
	var owed := 0
	var wild := 0
	var lost := 0
	if two.host_sol != null:
		owed = 1 if two.host_script.owed else 0
		wild = 1 if two.host_script.wild else 0
		for d in [two.host_sol.skipped, two.host_sol.shots_skipped,
				two.host_sol.weapons_skipped, two.host_sol.sat_skipped]:
			lost += (d as Dictionary).size()
	var named := PackedStringArray()
	for e in ends.keys():
		named.append(_pb3_end_name(int(e)))
	named.sort()
	return ("run %s %s %s ran %d things %d born %d has %d first %d reach %d "
			+ "rooms %d went %d %d solid %d ends %s owed %d wild %d lost %d "
			+ "up 1") % [
			where, kinds[0], kinds[1], ran, most, born, _pb3_has(two),
			_pb3_first(two), two.host_pb2.reached if two.host_pb2 != null
			else -1, rooms.size(), went[0], went[1], walled,
			"+".join(named), owed, wild, lost]


## `Pb2Turn`'s five, by name.  Anything else is a mode the engine does not
## know, and that is the whole point of putting it out.
func _pb3_end_name(e: int) -> String:
	match e:
		Pb2Turn.NONE: return "none"
		Pb2Turn.NEXT_AREA: return "door"
		Pb2Turn.INTERLUDE: return "scene"
		Pb2Turn.DIED: return "died"
		Pb2Turn.HELD: return "held"
	return "unknown%d" % e


## Which places of the level's own pool are taken, asked of the pool itself.
func _pb3_who_is_out(two: Pb3Pair) -> Array[bool]:
	var out: Array[bool] = []
	if two.host_pb2 != null:
		for k in range(Pb2Objects.SLOTS):
			out.append(k >= Pb2Objects.FIRST_LIVE
					and two.host_pb2.slots[k][Pb2Objects.F_TYPE] != 0)
	elif two.host_sol != null:
		for k in range(SolObjects.SLOTS):
			out.append(two.host_sol.id[k] != 0)
	return out


## And how many the level's own data holds to put out at all: the records of a
## Power Blade area ($B0D7's table), and of a Solbrain stage the groups its
## rooms name ($9C).
## Which column of a Power Blade area its earliest thing stands in ($E44D
## counts in sixteens), and below nought where the level has no such list: a
## Solbrain stage puts its things out of the groups its rooms name and out of
## its own script, and neither is a column.
func _pb3_first(two: Pb3Pair) -> int:
	if two.game != Pb3Pair.PB2:
		return -1
	var first := -1
	for rec in (two.pb2v as Pb2Level).spawns:
		var along: int = int((rec as Dictionary)["along"])
		if along == Pb2Objects.END_OF_LIST:
			break
		if first < 0 or along < first:
			first = along
	return first


func _pb3_has(two: Pb3Pair) -> int:
	if two.game == Pb3Pair.PB2:
		return (two.pb2v as Pb2Level).spawns.size()
	var n := 0
	for g in (two.solv as SolLevel).object_groups.values():
		n += (g as Array).size()
	return n


## The pilot cannot fight, so it keeps both of them standing: the same poking
## every other run here does ($D0F1 for Power Blade, $05C5 for Solbrain).
func _pb3_keep_alive(two: Pb3Pair) -> void:
	for i in range(two.who.size()):
		if two.who[i] == Pb3Pair.SOL:
			two.sol[i].suit = 0x08
			two.sol[i].hurt = 0
		else:
			var w: Pb2Objects = two.things[i]
			w.slots[0][Pb2Objects.F_LIFE] = 0x10
	if two.host_status != null:
		two.host_status.life = 0x10
		# $0470 -- and the clock, which a pilot has no way of beating.
		two.host_status.restart_time(two.came, 0)


func _run_sol_live(spec: String, st: int) -> void:
	bg.z_index = -1
	var f := spec.split(",")
	var pad: int = f[0].hex_to_int()
	var n: int = int(f[1])
	pads = [Pad.player_one(), Pad.player_two()]
	pads[0].held = pad
	# The whole game and not one stage: $02 raises the stage, flies the four
	# pieces in and only then starts playing it, and a death raises it again.
	sol_flow = SolFlow.new()
	sol_flow.stage = st
	sol_flow.lives = 0x02
	sol_flow.mode = SolFlow.RAISE
	var letters: int = f[2].hex_to_int() if f.size() > 2 else -1
	# A fifth field is the picture on which he is killed, which is how the
	# whole of $97A7 -- the try spent, the stage raised again -- is walked
	# without having to find something in the stage that can do it.
	var kill: int = int(f[4]) if f.size() > 4 else -1
	var slots := 0
	var shot := 0
	var wep := 0
	var drawn := 0
	var born := -1
	for i in range(n):
		# The buttons that are read on the press and not on the hold are let
		# go every eighth picture, or nothing would ever be fired twice.
		pads[0].held = pad if ((i >> 3) & 1) == 0 else pad & ~0xC0
		if i == kill and sol_hero != null:
			sol_hero.state = 0x0C                        # $978A, dying
		sol_flow.step(self)
		if sol_flow.stuck >= 0:
			print("stage %d  the flow stopped at mode %02X on picture %d"
					% [st, sol_flow.stuck, i])
			return
		if sol_pool == null:
			continue
		if born < 0 and sol_flow.mode == SolFlow.PLAY:
			born = i
			if letters >= 0:
				sol_pool.letters = letters
		var a := 0
		for k in range(SolObjects.SLOTS):
			if sol_pool.id[k] != 0:
				a += 1
		var b := 0
		var c := 0
		for k in range(SolObjects.WALKED):
			if sol_pool.s_kind[k] != 0:
				b += 1
			if sol_pool.w_kind[k] != 0:
				c += 1
		var d := 0
		for k in range(64):
			if sol_table.oam[k * 4] != SolSprites.HIDDEN:
				d += 1
		slots = maxi(slots, a)
		shot = maxi(shot, b)
		wep = maxi(wep, c)
		drawn = maxi(drawn, d)
	print(("stage %d  he arrives on %d  tries %d  slots %d  shots %d"
			+ "  weapons %d  sprites %d  state %02X fuel %02X hero %04X %04X")
			% [st, born, sol_flow.lives, slots, shot, wep, drawn,
			sol_hero.state, sol_hero.fuel, sol_hero.x, sol_hero.y])
	if f.size() > 3 and f[3] != "":
		_apply()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(f[3])


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
	view.hold = int(cfg["born_wait"]) if cfg.has("born_wait") else 0
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


## One byte of the pool written by hand, named the way the cartridge names it.
## The crate stand needs a whole slot moved, not only its behaviour flipped.
func _poke_pool(pool: SolObjects, a: int, v: int) -> void:
	var s: int = a & 0x0F
	match a & 0xFFF0:
		0x00A0: pool.x[s] = (pool.x[s] & 0xFF00) | v
		0x00B0: pool.x[s] = (pool.x[s] & 0x00FF) | (v << 8)
		0x00C0: pool.y[s] = (pool.y[s] & 0xFF00) | v
		0x00D0: pool.y[s] = (pool.y[s] & 0x00FF) | (v << 8)
		0x0600: pool.id[s] = v
		0x0610: pool.a[s] = v
		0x0620: pool.b[s] = v
		0x0630: pool.c[s] = v
		0x0640: pool.d[s] = v
		0x0650: pool.mind[s] = v
		0x0660: pool.pic_lo[s] = v
		0x0670: pool.pic_hi[s] = v
		0x0680: pool.face[s] = v
		0x0690: pool.kind[s] = v
		0x06A0: pool.anim_a[s] = v
		0x06B0: pool.anim_b[s] = v
		0x06C0: pool.left[s] = v
		0x06D0: pool.frame[s] = v
		0x06E0: pool.cool[s] = v
		0x06F0: pool.life[s] = v
		# $0780 -- the other pool, which the shot stand writes by hand
		0x0780: pool.s_kind[s] = v
		0x0790: pool.s_x[s] = (pool.s_x[s] & 0xFF00) | v
		0x07A0: pool.s_x[s] = (pool.s_x[s] & 0x00FF) | (v << 8)
		0x07B0: pool.s_y[s] = (pool.s_y[s] & 0xFF00) | v
		0x07C0: pool.s_y[s] = (pool.s_y[s] & 0x00FF) | (v << 8)
		0x07D0: pool.s_a[s] = v
		0x07E0: pool.s_b[s] = v
		0x07F0: pool.s_life[s] = v


## Э4.5 -- one byte of the hero himself, named by the address the cartridge
## keeps it at.  The state stand pokes $05A2 by hand to ask for a state the
## first seconds of a stage would never reach on their own.
func _poke_hero(p: SolPlayer, a: int, v: int) -> void:
	match a:
		0x0080: p.x = (p.x & 0xFF00) | v
		0x0081: p.x = (p.x & 0x00FF) | (v << 8)
		0x0082: p.y = (p.y & 0xFF00) | v
		0x0083: p.y = (p.y & 0x00FF) | (v << 8)
		0x0035: p.speed = v - 0x100 if v >= 0x80 else v
		0x005B: p.step_down = v
		0x05A2: p.state = v
		0x05A3: p.timer = v
		0x05A4: p.step_t = v
		0x05A5: p.scripted = v
		0x05AB: p.burst = v
		0x05AC: p.hold = v
		0x05AD: p.rise = _s16((p.rise & 0xFF00) | v)
		0x05AE: p.rise = _s16((p.rise & 0x00FF) | (v << 8))
		0x05AF: p.fuel = v
		0x05B2: p.face = v
		0x05B4: p.step_i = v
		0x05B5: p.pose = v
		0x05B6: p.vx = _s16((p.vx & 0xFF00) | v)
		0x05B7: p.vx = _s16((p.vx & 0x00FF) | (v << 8))
		0x05B8: p.vy = _s16((p.vy & 0xFF00) | v)
		0x05B9: p.vy = _s16((p.vy & 0x00FF) | (v << 8))
		0x05C2: p.hurt = v
		0x05C5: p.suit = v
		0x05C8: p.shield = v
		0x05C9: p.jump_flags = v
		0x05CA: p.seen = v
		0x05CB: p.flags = v
		0x05CC: p.swim = v
		0x05CD: p.ground = v
		0x05CE: p.anim = v
		0x05E8: p.jump = v
		0x05E9: p.gravity = v
		0x05EA: p.hold_max = v


## Э4.15 -- the bytes a panel pays out of, which are the pool's, not his.
func _poke_odd(pool: SolObjects, a: int, v: int) -> void:
	match a:
		0x0056: pool.z56 = v
		0x00F8: pool.zf8 = v
		0x0112: pool.shine_to(v)
		0x05C6: pool.hero_bonus = (pool.hero_bonus & 0xFF00) | v
		0x05C7: pool.hero_bonus = (pool.hero_bonus & 0x00FF) | (v << 8)
		0x071C: pool.w_x[0x0C] = (pool.w_x[0x0C] & 0xFF00) | v


## A sixteen bit number the cartridge keeps as two bytes, read back signed.
func _s16(v: int) -> int:
	v &= 0xFFFF
	return v - 0x10000 if v >= 0x8000 else v

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
	view.hold = int(cfg["born_wait"]) if cfg.has("born_wait") else 0
	view.fall = int(cfg["ride_fall"]) if cfg.has("ride_fall") else 0
	p.vx = int(cfg["vx"])
	p.vy = int(cfg["vy"])
	var pool := _sol_pool_from(cfg)
	p.burst = pool.z5ab
	# $0C is a plain count of pictures, but $0E is a hash of the whole of RAM
	# ($CD57) and is not ported yet, so both are handed over as the cartridge
	# had them.  `work/re/sol_minds.md` says what that still owes.
	var clocks: Array = cfg["clock_at"]
	var noises: Array = cfg["noise_at"]
	var sixes: Array = cfg["six_at"] if cfg.has("six_at") else noises
	var steps: Array = cfg["step_at"] if cfg.has("step_at") else noises
	var rides: Array = cfg["ride_at"] if cfg.has("ride_at") else []
	# $26 is what the screen still owes, and it is the blanking that pays it
	# off -- machinery this stand has no model of at all.  Where a stand cares
	# (the two borers sit still all the while it is not nought) the byte is
	# handed over picture by picture, as the clocks above are.
	var news: Array = cfg["new_at"] if cfg.has("new_at") else cfg["pads"]
	var oweds: Array = cfg["owed_at"] if cfg.has("owed_at") else []
	# $74 -- what the blanking is to move the lift's line by before the next
	# picture.  See $C3E0 below.
	var lines: Array = cfg["line_at"] if cfg.has("line_at") else []
	var out := PackedStringArray()
	var shots := PackedStringArray()
	var arms := PackedStringArray()
	var heroes := PackedStringArray()
	var hands := PackedStringArray()
	var odds := PackedStringArray()
	# Where the view stands, so that a stand can say whether a difference in
	# the pool came from the pool or from the view under it.
	var views := PackedStringArray()
	# All eighteen numbers of all sixteen slots.  The unprefixed rows above
	# carry seven of them, which is enough for who is where but not for what a
	# thing has left of its life; Э4.18 needs that.
	var fulls := PackedStringArray()
	# The death stand kills a pool by hand: on one named picture bit 7 goes on
	# the behaviour of every slot that holds something, which is what sends
	# $81B7 to its second table.  The cartridge is poked at the top of the same
	# frame, so it is done here before anything else of the picture.
	var kill_at: int = int(cfg["kill_at"]) if cfg.has("kill_at") else -1
	var kill: Array = cfg["kill"] if cfg.has("kill") else []
	# Э4.4 -- the crate stand writes a whole slot rather than one byte of it,
	# and names each byte by the address the cartridge keeps it at.
	var put: Array = cfg["put"] if cfg.has("put") else []
	# Э4.5 -- and the same for the hero, whose bytes are not in the pool.
	var hero_put: Array = cfg["hero_put"] if cfg.has("hero_put") else []
	# Э4.15 -- what a panel is paid with lives outside him: the bonus he has
	# not been counted yet, what a panel has taken of it, and his tries.
	var odd_put: Array = cfg["odd_put"] if cfg.has("odd_put") else []
	var want_crates: bool = cfg.has("crates")
	# Whether the stage's own script is to run.  The stands that came before
	# Э4.23 stood without it and are left standing without it.
	var want_script: bool = cfg.has("script")
	if want_script and cfg.has("ram0"):
		# A third of what the script touches has no home in the pool, and it
		# carries that third from one picture to the next itself, so the
		# shadow starts as the cartridge's own memory rather than as nought.
		sol_script.m = PackedByteArray(String(cfg["ram0"]).hex_decode())
	# Э6.3.2 -- the sound driver, where a stand is judging what the game asks
	# it for.  Only the driver runs, not the chip: what is compared is the two
	# requests themselves, picture by picture, and a wave nobody listens to
	# would cost seven hundred samples a picture for nothing.
	var want_sound: bool = cfg.has("sound")
	var snd_drv: SndPlay = null
	var snd_rows := PackedStringArray()
	if want_sound:
		snd_drv = SndPlay.new("sol")
	var crates := PackedStringArray()
	var n := 0
	for f in cfg["pads"]:
		if n == kill_at:
			for e in kill:
				pool.mind[int(e[0])] = int(e[1])
			for e in put:
				_poke_pool(pool, int(e[0]), int(e[1]))
			for e in hero_put:
				_poke_hero(p, int(e[0]), int(e[1]))
			for e in odd_put:
				_poke_odd(pool, int(e[0]), int(e[1]))
		# A picture the cartridge did not have time for: $0C does not move on,
		# and neither does anything else.  The stand still asks for a row, so
		# the one before is given again.
		# Э4.15 -- and the first picture is no different: what it is held
		# against is the clock the seed was taken on, which a stand passes in
		# when the frame it seeds from may itself be a half picture.
		var before: int = int(clocks[n - 1]) if n > 0 \
				else (int(cfg["clock0"]) if cfg.has("clock0") else -1)
		# A picture the cartridge finished is played; on one it did not the
		# state is left where it stood and the same row is given again.
		var done_pic: bool = int(clocks[n]) != before
		if done_pic:
			pool.clock = int(clocks[n])
			pool.noise = int(noises[n])
			pool.six = int(sixes[n])
			# $7F, $26 and $58 are the stage script's own.  A stand that runs
			# the script lets it keep them; one that does not is handed them.
			if not want_script:
				pool.z7f = int(steps[n])
				if n < oweds.size():
					pool.z26 = int(oweds[n])
				if n < rides.size():
					pool.z58 = int(rides[n])
			pool.drew()
			view.step(p.vx, p.vy, p.x, p.y)
			pool.hero = p
			# Seventeen of his twenty one states read and write slot $0C, so he is
			# handed the pool the same way the pool is handed him.
			p.pool = pool
			pool.born_wait = view.hold
			pool.map_kind = view.map_kind
			# $70 is the hero's too: on the stage that is all water it is what
			# takes the ceiling away from him ($A26E).
			p.map_kind = view.map_kind
			pool.stage = int(cfg["stage"]) if cfg.has("stage") else 0
			pool.z34 = view.fall
			pool.cam_x = view.x
			pool.cam_y = view.y
			# $CDB3 -- the stage's own script, and with it his breath and the
			# bubbles it leaves behind ($A7B0): the script calls them, so
			# nothing here does.  The script is not scenery to a stand of the
			# pool: $A211 is one of several steps that write a slot's own kind,
			# and without it a stage's own machinery never moves on.
			if want_script:
				sol_script.run(pool, p, view, null, null)
			else:
				SolShots.breathe(pool, p)
			pool.scrolled(view.x, view.y)
			pool.room = pool.room_of(view.x, view.y)
			_hero_into(pool, p)
			pool.scan(view.x, view.y, p.x, p.state)          # $CDBB
			# $CDBE -- his box is built once, and every slot is laid over the same
			# one; $CDCC then asks what has already been thrown at him.
			pool.hero_box()
			pool.shots_hit_hero()
			# $06 is the buttons the cartridge's own hero saw.  It is the pad as
			# read at $C895, except that a stage's own script may wipe it ($9E73
			# in bank 8 does, all through stage twenty's opening), and that script
			# is not ported yet -- so the hero is handed the byte rather than the
			# pad.  Where no script interferes the two are the same.
			# $91AC -- while the wait for a satellite is between one and $2F he
			# does not move at all: $9477 is simply not called.
			var pad: int = int(sixes[n]) if cfg.has("six_at") else int(f)
			if view.hold == 0 or view.hold >= 0x30:
				p.step(pad)                                      # $91B5
			else:
				p.skip(pad)
			_hero_into(pool, p)
			# $B862 -- one step of a handful of his animations strikes, and what it
			# strikes with goes into slot fifteen while he is still the one running.
			if p.punch >= 0:
				SolSat.strike(pool, p.punch, p.punch_x, p.punch_y)
				p.punch = -1
			# $923B -- the tail of $9159: the three letter boxes, and what a
			# finished combination gives him.
			SolSat.letters(pool)
			view.hold = pool.born_wait
			p.state = pool.hero_state
			# $847E -- the one that rides him off the stage takes the wire with it
			p.fuel = pool.hero_fuel
			p.burst = pool.z5ab
			# $CDD2 is one call, $9150, and drawing him is only its first half:
			# the second is $B168, the pool his satellite throws into.
			SolWeapon.step(pool)
			# $9156 -- and the third half: the hero's own four slots, $0C to $0F.
			pool.pad_new = int(news[n])
			SolSat.step(pool)
			# $AD45 writes back into $05B2, which he reads again next picture --
			# the whole byte of it, not only the bit that says which way he looks.
			p.face = pool.hero_face
			SolShots.step(pool)                              # $CDDA
			# $B984 -- the shot that turns the world over writes his own numbers,
			# so they are taken back out of the pool once the shots have run.
			p.flags = pool.hero_flags
			p.rise = pool.hero_rise - 0x10000 \
					if pool.hero_rise >= 0x8000 else pool.hero_rise
			p.ground = pool.hero_ground
			p.jump = pool.hero_jump
			p.gravity = pool.hero_grav
			p.hold_max = pool.hero_hold_max
			pool.step(view.x, view.y)                        # $CDDD
			# $D065 -- the carrying map answers the pool's own looks and
			# writes his falling while it does, so it comes back out too.
			p.vy = pool.hero_vy - 0x10000 \
					if pool.hero_vy >= 0x8000 else pool.hero_vy
			_sol_tab(pool)                                   # $CDE3
			# $C3E0 -- the blanking pays off what the stage's own script asked
			# of the lift's line.  Neither the script nor the blanking is this
			# stand's business, so what it asked for is handed over; what the
			# pool itself wrote into $75 this picture is the engine's own.
			if want_script:
				# $74 has no home in the pool, so it lives in the script's own
				# shadow from one picture to the next.
				pool.z74 = sol_script.g(0x74)
				sol_script.p(0x74, 0)                    # $C39F
				# $FBDB -- the blanking keeps $7D of the picture just gone in
				# $70, so what kind of stage this is lags the script's own
				# byte by one picture.
				view.map_kind = sol_script.g(0x7D)
			elif n < lines.size():
				pool.z74 = int(lines[n])
			pool.z75 = (pool.z75 + pool.z74) & 0xFF
			pool.z74 = 0
		var row := PackedStringArray()
		for i in range(SolObjects.SLOTS):
			row.append("%d,%d,%d,%d,%d,%d,%d" % [pool.id[i], pool.x[i],
					pool.y[i], pool.mind[i], pool.kind[i],
					pool.pic_lo[i], pool.pic_hi[i]])
		out.append(" ".join(row))
		var srow := PackedStringArray()
		for i in range(SolObjects.SHOTS):
			srow.append("%d,%d,%d,%d,%d,%d" % [pool.s_kind[i], pool.s_x[i],
					pool.s_y[i], pool.s_a[i], pool.s_b[i], pool.s_life[i]])
		shots.append("S " + " ".join(srow))
		var wrow := PackedStringArray()
		for i in range(SolObjects.WALKED):
			wrow.append("%d,%d,%d,%d,%d,%d" % [pool.w_kind[i], pool.w_x[i],
					pool.w_y[i], pool.w_vx[i], pool.w_vy[i], pool.w_pen[i]])
		arms.append("W " + " ".join(wrow))
		# A row of the hero himself, for when a stand has to be told where a
		# difference in his own slots came from.  It is kept apart from the
		# arms so that a picture the cartridge did not finish repeats one row
		# of each and not two of one.
		heroes.append("P %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d"
				% [p.x, p.y, p.vx, p.vy, p.state, p.speed, p.pose, p.scripted,
				p.step_t, p.step_i, p.pic_lo, p.pic_hi, p.anim, p.face,
				p.timer, p.fuel])
		var hrow := PackedStringArray()
		for i in range(SolSat.FIRST, SolSat.LAST + 1):
			hrow.append("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d"
					% [pool.id[i], pool.x[i], pool.y[i], pool.mind[i],
					pool.kind[i], pool.a[i], pool.b[i], pool.c[i], pool.d[i],
					pool.face[i], pool.anim_a[i], pool.anim_b[i], pool.left[i],
					pool.frame[i], pool.cool[i], pool.life[i],
					pool.pic_lo[i], pool.pic_hi[i]])
		hands.append("H " + " ".join(hrow))
		var frow := PackedStringArray()
		for i in range(SolObjects.SLOTS):
			frow.append("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d"
					% [pool.id[i], pool.x[i], pool.y[i], pool.mind[i],
					pool.kind[i], pool.a[i], pool.b[i], pool.c[i], pool.d[i],
					pool.face[i], pool.anim_a[i], pool.anim_b[i], pool.left[i],
					pool.frame[i], pool.cool[i], pool.life[i],
					pool.pic_lo[i], pool.pic_hi[i]])
		fulls.append("O " + " ".join(frow))
		if snd_drv != null:
			# What the picture asked its driver for, written down before the
			# driver is let at it -- the driver takes both cells and puts
			# nought back, the way the cartridge's does, so this is the only
			# moment the request exists.  It runs where the interrupt handler
			# ran it: after the picture the game has just finished.  A picture
			# the cartridge did not finish had no interrupt either.
			if done_pic:
				snd_rows.append("Q %02X %02X"
						% [SolSound.want_tune, SolSound.want_noise])
				snd_drv.drive()
			else:
				snd_rows.append("Q -")
		elif done_pic:
			# No driver to run, and the two cells still have to be emptied:
			# the cartridge's interrupt handler empties them whatever else it
			# is doing, and the game itself reads them ($87F6, $8459).
			SolSound.forget()
		# Э4.14 and Э4.15 -- what the hero writes that lives nowhere else:
		# what the game is to be put to next ($F8), the colour the shimmer of
		# the shield walks ($0112), what a panel took and has not been paid
		# off yet ($56), and the four a panel buys with and into.
		odds.append("Y %d %d %d %d %d %d %d" % [pool.zf8, pool.z0112, pool.z56,
				pool.hero_bonus, p.suit, p.shield, pool.w_x[0x0C] & 0xFF])
		views.append("V %d %d %d %d %d %d" % [view.x, view.y, p.hurt, p.timer, p.jump_flags, p.clock])
		if want_crates:
			var crow := PackedStringArray()
			for i in range(level_sol.present.size()):
				crow.append(str(level_sol.present[i]))
			crates.append("C " + " ".join(crow))
		n += 1
	print("\n".join(out))
	if want_crates:
		print("\n".join(crates))
	print("\n".join(shots))
	print("\n".join(arms))
	print("\n".join(heroes))
	print("\n".join(hands))
	print("\n".join(odds))
	print("\n".join(views))
	print("\n".join(fulls))
	if snd_drv != null:
		print("\n".join(snd_rows))
	if not pool.skipped.is_empty():
		printerr("minds not read yet: ", pool.skipped)
	if not pool.shots_skipped.is_empty():
		printerr("shots not read yet: ", pool.shots_skipped)
	if not pool.weapons_skipped.is_empty():
		printerr("weapons not read yet: ", pool.weapons_skipped)
	if not pool.sat_skipped.is_empty():
		printerr("satellite not read yet: ", pool.sat_skipped)


## $CDE3 -- what a panel took is paid off a point a picture, out of the bonus
## he has not been counted yet.  Anything else that picture's tail does --
## the wait a suitless hero puts the game through ($CE09) -- is the frame's
## own pacing and not the game's state.
func _sol_tab(pool: SolObjects) -> void:
	SolTurn.tick_bonus(pool)


## The hero's own numbers, copied into the pool.  $CDBB and $CDBE read them
## before his step and $CDDD after it, so the pool is handed them twice.
func _hero_into(pool: SolObjects, p: SolPlayer) -> void:
	SolTurn.hero_into(pool, p)


## Everything the cartridge had in the hero when the buttons started, put back
## into him.  Two stands lean on this, so it is written once.
## The pool as a record of work memory has it.  Both the stand that walks a
## whole picture (--solobj) and the one that only draws the hero's own four
## slots (--soldraw) are handed the same numbers, so they read them the same
## way.
func _sol_pool_from(cfg: Dictionary) -> SolObjects:
	var pool := SolObjects.new(level_sol)
	pool.due = int(cfg["due"])
	pool.col_due = int(cfg["col_due"])
	pool.row_due = int(cfg["row_due"])
	pool.seen_x = int(cfg["seen_x"])
	pool.seen_y = int(cfg["seen_y"])
	pool.room = int(cfg["room"])
	pool.z75 = int(cfg["z75"]) if cfg.has("z75") else 0
	pool.z72 = int(cfg["z72"]) if cfg.has("z72") else 0
	pool.z7c = int(cfg["z7c"]) if cfg.has("z7c") else 0
	pool.z58 = int(cfg["z58"]) if cfg.has("z58") else 0
	pool.z7f = int(cfg["z7f"]) if cfg.has("z7f") else 0
	pool.z26 = int(cfg["z26"]) if cfg.has("z26") else 0
	pool.z399 = int(cfg["z399"]) if cfg.has("z399") else 0
	pool.letters = int(cfg["letters"]) if cfg.has("letters") else 0
	pool.hero_bonus = int(cfg["bonus"]) if cfg.has("bonus") else 0
	pool.z5ab = int(cfg["z5ab"]) if cfg.has("z5ab") else 0
	pool.z5fa = int(cfg["z5fa"]) if cfg.has("z5fa") else 0
	pool.zf8 = int(cfg["zf8"]) if cfg.has("zf8") else 0
	pool.z0112 = int(cfg["z0112"]) if cfg.has("z0112") else 0
	pool.z56 = int(cfg["z56"]) if cfg.has("z56") else 0
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
	if cfg.has("skind"):
		for i in range(SolObjects.SHOTS):
			pool.s_kind[i] = int(cfg["skind"][i])
			pool.s_x[i] = int(cfg["sx"][i])
			pool.s_y[i] = int(cfg["sy"][i])
			pool.s_a[i] = int(cfg["sa"][i])
			pool.s_b[i] = int(cfg["sb"][i])
			pool.s_life[i] = int(cfg["slife"][i])
	if cfg.has("wkind"):
		for i in range(SolObjects.WEAPONS):
			pool.w_kind[i] = int(cfg["wkind"][i])
			pool.w_x[i] = int(cfg["wx"][i])
			pool.w_y[i] = int(cfg["wy"][i])
			pool.w_vx[i] = int(cfg["wvx"][i])
			pool.w_vy[i] = int(cfg["wvy"][i])
			pool.w_pen[i] = int(cfg["wpen"][i])
	return pool

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
	if cfg.has("face"):
		p.face = int(cfg["face"])
	elif cfg.has("face_left"):
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
## What the flow stand hands `SolFlow` in place of a whole game: a hero, a view
## and a sprite table, and nothing that steps a stage.  The run stops the
## moment the flow asks for a stage or for a picture of one.
class FlowStand:
	var hero := SolPlayer.new(null)
	var view := SolCamera.new(null)
	var table := SolSprites.Table.new()
	var asked := ""

	func flow_hero() -> SolPlayer:
		return hero

	func flow_view() -> SolCamera:
		return view

	func flow_table() -> SolSprites.Table:
		return table

	func flow_pool():
		return null

	func flow_tune_end() -> bool:
		return true

	func flow_play() -> void:
		asked = "play"

	func flow_raise(st: int) -> void:
		asked = "raise %d" % st

	func flow_door(st: int) -> void:
		asked = "door %d" % st

	func flow_tune() -> int:
		return 0

	func flow_palette() -> PackedByteArray:
		var out := PackedByteArray()
		out.resize(32)
		return out

	func flow_pad_new() -> int:
		return 0

	func flow_pad() -> int:
		return 0

	func flow_poke(_addr: int, _tile: int) -> void:
		pass


## Э4.6 acceptance: --solflow=FILE, the four pieces he arrives as.
##
## The file holds one picture of the cartridge as it stood at $CC77, and the
## engine answers with every picture from the next one on: the mode, the two
## counts the arriving keeps, where the four pieces are, where the view is and
## the whole sprite table.
func _run_sol_flow(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var h := FlowStand.new()
	var f := SolFlow.new()
	f.mode = int(cfg["mode"])
	f.z03 = int(cfg["z03"])
	f.z57 = int(cfg["z57"])
	f.z2e = int(cfg["z2e"])
	f.stage = int(cfg["stage"])
	f.lives = int(cfg["lives"])
	f.home_x = int(cfg["home_x"])
	f.home_y = int(cfg["home_y"])
	var px: Array = cfg["px"]
	var py: Array = cfg["py"]
	for i in range(4):
		f.piece_x[i] = int(px[i])
		f.piece_y[i] = int(py[i])
	h.hero.x = int(cfg["hero_x"])
	h.hero.y = int(cfg["hero_y"])
	h.hero.hurt = int(cfg["hurt"])
	h.hero.state = int(cfg["state"])
	h.view.x = int(cfg["cam_x"])
	h.view.y = int(cfg["cam_y"])
	h.table.count = int(cfg["count"])
	h.table.turn = int(cfg["turn"])
	h.table.fwd = int(cfg["fwd"])
	h.table.back = int(cfg["back"])
	h.table.start = int(cfg["start"])
	var bk: Array = cfg["banks"]
	for i in range(4):
		h.table.banks[i] = int(bk[i])
	var was: Array = cfg["oam"]
	for i in range(256):
		h.table.oam[i] = int(was[i])
	var ticks: Array = cfg["ticks"]
	var out := PackedStringArray()
	for i in range(ticks.size()):
		# $C72D reads $00, which is not a count the engine keeps; the stand
		# hands over the cartridge's own for each picture, and it stands
		# still while the console is held.
		f.tick_held = true
		f.tick = int(ticks[i])
		f.step(h)
		out.append("%02X %02X %02X %d %d %d %d %d %d %d %d %d %d %s %d %d %d %d"
				% [f.mode, f.z03, f.z57,
				f.piece_x[0], f.piece_x[1], f.piece_x[2], f.piece_x[3],
				f.piece_y[0], f.piece_y[1], f.piece_y[2], f.piece_y[3],
				h.view.x, h.view.y, h.table.oam.hex_encode(),
				h.table.count, h.table.turn, h.table.fwd, h.table.back])
		if h.asked != "":
			break
	print("\n".join(out))


## Э4.5 acceptance: --solscript=FILE, the stage's own script.
##
## The file holds a list of pictures, each one the whole two kilobytes of the
## console's memory as it stood the moment $93B5 was entered.  The engine seeds
## its own shadow from each in turn, runs the script once, and hands the two
## kilobytes back; what is compared is picked on the other side.
## Э4.5 -- one screen of Solbrain that is not a stage, photographed.
##
## The spec is the name of the scene and where to write the picture; the names
## are `data/sol/scenes.json`'s own.  The screen is built the way the cartridge
## builds it -- a wiped board, then each of its screens laid on -- and handed
## to the shader with the colours and the banks the cartridge had.
func _run_sol_scene(spec: String) -> void:
	var parts := spec.split(",")
	sol_screen = SolScreen.make(parts[0])
	_show_sol_screen(sol_screen.scroll)
	bg.z_index = -1
	queue_redraw()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	if parts.size() > 1:
		get_viewport().get_texture().get_image().save_png(parts[1])
	print("%s  %d bands  mirror %d  scroll %d,%d"
			% [parts[0], sol_screen.bands.size(), sol_screen.mirror,
			sol_screen.scroll.x, sol_screen.scroll.y])


## The screen now up, handed to the shader.  A screen is not a level: it rides
## over the console's own name map put up four times and wraps at the far edge,
## it may swap the four kilobytes it is drawn out of as the beam goes down, and
## it owns the whole of the picture -- no bar under it and no level behind it.
##
## What the mode has asked for since the screen went up is taken over the top:
## the four kilobytes when it has named a pair of its own ($C925), and the few
## bytes of the colour shadow the change writes itself.
func _show_sol_screen(at: Vector2i) -> void:
	var sc := sol_screen
	var m: ShaderMaterial = bg.material
	Nes.load_palette_table()
	var colours := PackedByteArray(sc.palette)
	var four: Array = sc.banks
	if sol_flow != null:
		# $0100 -- what the mode has walked the colours to.  The scene's own
		# thirty two are only the ones the cartridge had when the scene was
		# written down, and a mode that is walking them is past that.
		colours = sol_flow.fade.out
		if not sol_flow.chr.is_empty():
			four = Array(sol_flow.chr)
	pal_tex = Nes.palette_texture(colours)
	map_tex = ImageTexture.create_from_image(sc.map_image)
	m.set_shader_parameter("sheet", Nes.sheet("sol"))
	m.set_shader_parameter("sheet_size", Nes.sheet("sol").get_size())
	m.set_shader_parameter("map", map_tex)
	m.set_shader_parameter("palette", pal_tex)
	m.set_shader_parameter("map_size",
			Vector2(SolScreen.WIDE_ALL, SolScreen.TALL_ALL))
	m.set_shader_parameter("wrap", Vector2(SolScreen.WIDE_ALL * 8,
			SolScreen.TALL_ALL * 8))
	# $42..$45 -- the four the sprites come out of are the table's own, because
	# every picture drawn may take one of them for itself; only where there is
	# no table at all are the scene's used.
	var spr: Array = Array(sol_table.banks) if sol_table != null else sc.spr_banks
	m.set_shader_parameter("banks", PackedInt32Array(four + spr))
	# A pair of its own is one band the whole way down; only where the mode has
	# asked for nothing is the screen left the bands the cartridge had.
	var own: bool = four == sc.banks
	m.set_shader_parameter("bands_on", own)
	if own and sol_flow != null and sol_flow.blank:
		# $C14F -- the row of words put out, which is $C357 setting both of the
		# background's pairs to the blank one and the beam's next stop putting
		# the first of them back.
		m.set_shader_parameter("band_at",
				PackedInt32Array(SolScreen.BLANK_LINES))
		m.set_shader_parameter("band_bank", sc.blank_banks())
	else:
		m.set_shader_parameter("band_at", sc.band_lines())
		m.set_shader_parameter("band_bank", sc.band_banks())
	m.set_shader_parameter("bar_on", false)
	m.set_shader_parameter("split_at", 1000.0)
	m.set_shader_parameter("clip_left", 0.0)
	m.set_shader_parameter("view_top", 0.0)
	m.set_shader_parameter("view_bottom", 240.0)
	m.set_shader_parameter("scroll", Vector2(at))
	m.set_shader_parameter("sprites_on", sol_table != null)
	if sol_table != null:
		var img := Image.create(Pb2Sprites.SPRITES, 1, false,
				Image.FORMAT_RGBA8)
		for i in range(Pb2Sprites.SPRITES):
			img.set_pixel(i, 0, Color8(sol_table.oam[i * 4],
					sol_table.oam[i * 4 + 1], sol_table.oam[i * 4 + 2],
					sol_table.oam[i * 4 + 3]))
		if oam_tex == null:
			oam_tex = ImageTexture.create_from_image(img)
			m.set_shader_parameter("oam", oam_tex)
		else:
			oam_tex.update(img)


## Э4.6 acceptance: the chain of modes the game walks from the switch being
## turned on.  The spec is how many pictures to walk and, after it, a button
## and the picture it goes down on, over and over -- `1200,START:640`.  What
## comes out is one line per change of mode, which is what the cartridge is
## asked for as well ($02 written).
func _run_sol_boot(spec: String) -> void:
	var f := spec.split(",")
	var n := int(f[0])
	var down := {}
	var up := {}
	var shots := {}
	var start := {}
	var bests: Array = []
	# Turn -> the dumps asked for at it.  A turn may be asked for both its
	# board and what the flow is holding, so one key holds a list.
	var writes := {}
	# The cartridge's own $00 for each turn, when a stand hands it over.
	var ticks: Array = []
	for k in range(1, f.size()):
		var g := f[k].split(":")
		if g[0] == "shot":
			shots[int(g[1])] = g[2]
			continue
		# `ticks:PATH` -- the cartridge's own $00 for every turn of the walk,
		# one number to a line.  $00 is a count of pictures shown and $0C a
		# count of turns of the main loop, and on a heavy turn -- a screen
		# being written -- the console shows more than one picture while the
		# loop goes round once.  The engine has no way to know how many, so a
		# stand that wants the sprite table's own turn ($6B, which $C72D takes
		# from $00) right to the picture hands the count over.  Without this
		# the walk raises its own every turn, which is what both games do
		# while nothing heavy is happening.
		if g[0] == "ticks":
			for row in FileAccess.get_file_as_string(g[1]).split("\n"):
				if row.strip_edges() != "":
					ticks.append(int(row))
			continue
		if g[0] == "dump":
			shots[int(g[1])] = "?"
			continue
		# `board:N:PATH` -- the two kilobytes of name map as they stand at turn
		# N, written out raw.  It is what a stand compares against the
		# cartridge's own dump when a picture says two screens differ and not
		# where.
		if g[0] == "board" or g[0] == "state":
			var at := int(g[1])
			if not writes.has(at):
				writes[at] = []
			writes[at].append(g[0] + ":" + g[2])
			continue
		# `state:N:PATH` -- what the flow keeps in memory at turn N, written
		# out as a little table.  It is the other half of a board dump: the
		# board says what is written, this says what the mode is holding.
		# `set:NAME:VALUE` -- the walk begun part way along instead of at the
		# reset, which is how a mode only reached with a stage behind it is
		# stood up: the cartridge is poked to the same place.
		if g[0] == "set":
			start[g[1]] = int(g[2])
			continue
		# `best:I:COUNT:A:B:C` -- one of the five lines of BEST 5, the count
		# and the three letters of the name.  A stand that wants to see them
		# put in order hands over five that are out of it.
		if g[0] == "best":
			bests.append([int(g[1]), int(g[2]),
					[int(g[3]), int(g[4]), int(g[5])]])
			continue
		var bit := 0
		match g[0]:
			"A": bit = Pad.A
			"B": bit = Pad.B
			"SELECT": bit = Pad.SELECT
			"START": bit = Pad.START
			"UP": bit = Pad.UP
			"DOWN": bit = Pad.DOWN
			"LEFT": bit = Pad.LEFT
			"RIGHT": bit = Pad.RIGHT
		var at := int(g[1])
		down[at] = int(down.get(at, 0)) | bit
		up[at + 4] = int(up.get(at + 4, 0)) | bit
	pads = [Pad.player_one(), Pad.player_two()]
	sol_walking = true
	_start_sol_boot()
	for k in start:
		match k:
			"mode": sol_flow.mode = int(start[k])
			"stage": sol_flow.stage = int(start[k])
			"clock": sol_flow.clock = int(start[k])
			"lives": sol_flow.lives = int(start[k])
			"done": sol_flow.z2d = int(start[k])
			"score": sol_flow.score = int(start[k])
			"z4c": sol_flow.z4c = int(start[k])
			"tick": sol_flow.tick = int(start[k])
			"suit": sol_flow.set_suits_of(self, int(start[k]))
			"bonus": sol_flow.set_owed_of(self, int(start[k]))
			"fd": sol_fd_at = int(start[k])
			"sat": sol_flow.set_sat_of(self, int(start[k]))
			"seen": sol_flow.z59 = int(start[k])
	for one in bests:
		sol_flow.best_scores[int(one[0])] = int(one[1])
		sol_flow.best_names[int(one[0])] = one[2]
	var held := 0
	var was := -1
	for i in range(n):
		held |= int(down.get(i, 0))
		held &= ~int(up.get(i, 0))
		sol_pad_edge = held & ~sol_flow_was
		sol_flow_was = held
		# $06 -- what is held, which the maker's code on the title reads as
		# well as what went down this turn.  A walk has no keyboard behind it,
		# so the pad itself is written.
		pads[0].held = held
		pads[0].pressed = sol_pad_edge
		sol_walk_turn = i
		if i < ticks.size():
			sol_flow.tick_held = true
			sol_flow.tick = int(ticks[i])
		sol_flow.step(self)
		# The picture is drawn every turn in the game, and it is the drawing
		# that hands a screen its own thirty two ($C6E9 with X = $1F).  A walk
		# that only draws now and then would leave the colours of a screen it
		# never drew standing when the next screen takes only some of them.
		if sol_flow.screen != "":
			_sol_screen_now()
		if sol_flow.mode != was:
			was = sol_flow.mode
			print("%d %02X %s" % [i, was, sol_flow.screen])
		if writes.has(i):
			for one in writes[i]:
				var path: String = str(one).substr(6)
				if str(one).begins_with("state:"):
					var sf := FileAccess.open(path, FileAccess.WRITE)
					sf.store_string(JSON.stringify(_sol_flow_state()))
					sf.close()
				else:
					var bf := FileAccess.open(path, FileAccess.WRITE)
					# A mode standing on no screen at all has no board: what
					# goes out is two kilobytes of nought, and the state dump
					# beside it says the screen is none.
					if sol_flow.screen == "":
						var none := PackedByteArray()
						none.resize(0x0800)
						bf.store_buffer(none)
					else:
						_sol_screen_now()
						bf.store_buffer(sol_screen.board)
					# and the thirty two colours that stand with it, so a
					# stand can tell a right board under a wrong fade from a
					# right one.
					bf.store_buffer(sol_flow.fade.out)
					bf.close()
			continue
		if shots.has(i) and shots[i] == "?":
			print("dump %d banks %s" % [i, str(sol_table.banks)])
			print("  fade kind=%02X mask=%02X pace=%d cnt=%d lv=%s out=%s" % [
					sol_flow.fade.kind, sol_flow.fade.mask, sol_flow.fade.pace,
					sol_flow.fade.count, str(sol_flow.fade.level),
					sol_flow.fade.out.slice(0, 16).hex_encode()])
			print("  4c=%02X 4d=%02X 4e=%02X 4f=%02X 0a=%02X clk=%02X" % [
					sol_flow.z4c, sol_flow.z4d, sol_flow.z4e, sol_flow.z4f,
					sol_flow.scroll_x, sol_flow.clock])
			print("  fwd=%02X back=%02X cnt=%02X turn=%02X start=%02X" % [
					sol_table.fwd, sol_table.back, sol_table.count,
					sol_table.turn, sol_table.start])
			if sol_hero != null:
				print("  hero %04X %04X view %04X %04X home %04X %04X" % [
						sol_hero.x, sol_hero.y, sol_view.x, sol_view.y,
						sol_flow.home_x, sol_flow.home_y])
				print("  px %s py %s z03=%02X z57=%02X" % [
						str(sol_flow.piece_x), str(sol_flow.piece_y),
						sol_flow.z03, sol_flow.z57])
			for q in range(64):
				if sol_table.oam[q * 4] != 0xF7:
					print("  %d y=%d t=%02X a=%02X x=%d" % [q,
							sol_table.oam[q * 4], sol_table.oam[q * 4 + 1],
							sol_table.oam[q * 4 + 2], sol_table.oam[q * 4 + 3]])
			continue
		if shots.has(i):
			_apply()
			queue_redraw()
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(shots[i])
		if sol_flow.stuck >= 0:
			print("stuck %02X at %d" % [sol_flow.stuck, i])
			return


func _run_sol_script(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var sc := SolScript.new()
	var out := PackedStringArray()
	for rec in cfg["ram"]:
		sc.m = PackedByteArray(String(rec).hex_decode())
		sc.cf = 0
		sc.wild = false
		sc.owed = false
		sc.trail.clear()
		sc.step()
		var mark := "!" if sc.wild else ("?" if sc.owed else "")
		var seen := PackedStringArray()
		for a in sc.trail:
			seen.append("%04X" % a)
		out.append(mark + sc.m.hex_encode() + " " + ",".join(seen))
	print("\n".join(out))


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
		p.fuel = int(f["fuel"])
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


## Э4.20 acceptance: --soldraw=FILE, the hero's own four slots put into the
## sprite table.  One record per picture, each one the whole of work memory as
## it stood at $A489 -- just before the four are walked -- and the engine must
## answer with the same table, the same four cursors and the same four tile
## banks the cartridge had at $A52E.
func _run_sol_draw(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var out := PackedStringArray()
	for f in cfg["frames"]:
		var p := _seed_sol(f)
		var pool := _sol_pool_from(f)
		pool.clock = int(f["clock"])
		pool.cam_x = int(f["cam_x"])
		pool.cam_y = int(f["cam_y"])
		pool.born_wait = int(f["born_wait"])
		pool.six = int(f["six"])
		pool.pad_new = int(f["pad_new"])
		# $05AB is the hero's own, and _seed_sol does not carry it: without it
		# _hero_into would wipe the burst the letters had just paid out.
		p.burst = pool.z5ab
		_hero_into(pool, p)
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
		pool.table = t
		SolSat.step(pool)
		var row := PackedStringArray()
		for i in range(SolSat.FIRST, SolSat.LAST + 1):
			row.append("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d"
					% [pool.id[i], pool.x[i], pool.y[i], pool.mind[i],
					pool.kind[i], pool.a[i], pool.b[i], pool.c[i], pool.d[i],
					pool.face[i], pool.anim_a[i], pool.anim_b[i], pool.left[i],
					pool.frame[i], pool.cool[i], pool.life[i],
					pool.pic_lo[i], pool.pic_hi[i]])
		out.append("%s %d %d %d %d %d %d %d %d %s" % [t.oam.hex_encode(),
				t.count, t.turn, t.fwd, t.back,
				t.banks[0], t.banks[1], t.banks[2], t.banks[3],
				" ".join(row)])
	print("\n".join(out))


## Э4.11 acceptance: --solstrip=FILE, the strip at the bottom of the picture.
## One record per picture, and each one is the whole table as it stood at $91DD
## plus the three cells the strip reads.
func _run_sol_strip(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var out := PackedStringArray()
	for f in cfg["frames"]:
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
		_sol_strip(int(f["suit"]), int(f["clock"]), int(f["bonus"]), t)
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
	# Э6.3.4 -- and the noises his own step asked for, when the stand wants
	# them: one field more on the line, in the order they were asked.
	var noise := bool(cfg.get("noise", false))
	var out := PackedStringArray()
	Pb2Sound.forget()
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
		var line := "%d %d %d %d %d %d %d %d" % [p.x, p.y, p.vx, p.vy,
				p.state, p.sub, p.pose, 1 if p.face_left else 0]
		if noise:
			var say := PackedStringArray()
			for n in Pb2Sound.asked:
				say.append("%02X" % int(n))
			line += " |%s" % (" ".join(say) if say.size() else "-")
			Pb2Sound.forget()
		out.append(line)
	print("\n".join(out))


## Э6.3.1 -- the sound, raised for the game that is about to be played.
##
## The node is made here and not put in `main.tscn`: a stand runs Godot with
## no sound card at all (`--headless`), and a scene with a player in it would
## have to carry one for nothing.  Without a card `get_stream_playback` hands
## back nothing, the chip goes on counting, and the samples simply pile up and
## are dropped -- which is what `SndPlay.dropped` is for.
func _snd_raise() -> void:
	snd = SndPlay.new(game)
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = SndPlay.RATE
	# A twelfth of a second of room.  Less and a picture that took too long on
	# the monitor's side is heard as a hole; more and a sound lags its picture.
	gen.buffer_length = 0.08
	snd_out = AudioStreamPlayer.new()
	snd_out.stream = gen
	add_child(snd_out)
	snd_out.play()


## The level's game changed, so the driver does.  A driver holds a tune in its
## own tables, and the other game's tables are not the same tables, so nothing
## is carried over: the old one stops and the new one starts silent.
func _snd_use(g: String) -> void:
	if snd == null or snd.game == g:
		return
	snd = SndPlay.new(g)


var _cache := {}


func _load(g: String, stage: int, area: int) -> void:
	game = g
	_snd_use(g)
	stage_sol = stage
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
	if sol_flow != null and (sol_flow.screen != "" or level_sol == null):
		_sol_screen_frame()
		return
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
		# $0100..$011F -- what a stage is drawn in is not its own table but
		# where the walk of the colours stands: $CB96 blacks the background
		# out while he arrives and $CCC5 walks it back up.
		if sol_flow != null:
			pal_tex = Nes.palette_texture(sol_flow.fade.out)
			if sol_flow.wiped:
				size = Vector2.ZERO
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
	# Only a screen outside a level swaps the background's banks as the beam
	# goes down; a level has the four it has.
	m.set_shader_parameter("bands_on", false)
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
	# The logic runs on the console's clock, not the monitor's.  While a walk
	# is being taken picture by picture it owns the stepping and the monitor
	# must not add any of its own, or the picture asked for at a given step
	# would be the one a step or two later.
	if sol_walking:
		# A mode with no screen of its own is a stage: $19 raises it and $3E
		# and $3F stand in it while he arrives, so what is drawn there is the
		# level and its sprite table, not the dark of two screens changing.
		_apply()
		queue_redraw()
		return
	for _i in range(clock.tick(dt)):
		_step()
	if snd != null and snd_out != null:
		snd.pump(snd_out.get_stream_playback())
	if sol_flow != null and (sol_flow.screen != "" or level_sol == null):
		_sol_screen_frame()
		queue_redraw()
		return
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


## One picture.  The game moves first and the driver last, the way the console
## has it: the cartridge's own driver runs out of the interrupt handler, after
## the picture the game has just finished asking for.
func _step() -> void:
	_step_game()
	if snd != null:
		snd.step()


func _step_game() -> void:
	for p in pads:
		p.poll()
	if choosing:
		_choice_step()
		return
	if world == null:
		if sol_flow != null:
			# $C882 -- the mode reads the pad itself, and what it reads is two
			# bytes: $04 is what has just gone down and $06 what is held.
			sol_pad_edge = pads[0].held & ~sol_flow_was
			sol_flow_was = pads[0].held
			sol_flow.step(self)
		elif sol_hero != null:
			_step_sol()
		else:
			_walk_camera()
		return
	_step_pb2()
	_bar_step()


## Э4.5 -- Solbrain with a hero in it, and now the pool along with him: what
## the stage puts out, his own satellite in slots $0C to $0F, what he throws
## and what is thrown at him.  Still missing is the stage's own script (the
## bar, the bosses, the doors between stages) and the drawing of the two flat
## pools, so a shot and its smoke are felt but not seen.
func _start_sol() -> void:
	sol_hero = SolPlayer.new(level_sol)
	sol_hero.place(level_sol.start.x, level_sol.start.y)
	sol_view = SolCamera.new(level_sol)
	sol_view.place(level_sol.start.x, level_sol.start.y)
	sol_pool = SolObjects.new(level_sol)
	# $E788 gave it an empty pool and every spawn still to come; what is left
	# is where the view stands and that the first picture owes a scan, so the
	# things the stage opens on are put out before he can walk past them.
	sol_pool.seen_x = sol_view.x
	sol_pool.seen_y = sol_view.y
	sol_pool.col_due = 0xFF
	sol_pool.row_due = 0xFF
	sol_pool.stage = stage_sol
	sol_pool.room = sol_pool.room_of(sol_view.x, sol_view.y)
	sol_pool.hero = sol_hero
	sol_hero.pool = sol_pool
	sol_table = SolSprites.Table.new()
	for i in range(4):
		sol_table.banks[i] = level_sol.spr_banks[i]
	# $C72D never wipes the first eight entries: that corner of the table
	# belongs to the strip, and in the cartridge the strip's own code fills it
	# every frame.  Only two of the eight are written here so far, so the rest
	# are parked off the picture once and left there.
	for i in range(0, SolSprites.FWD_START, 4):
		sol_table.oam[i] = SolSprites.HIDDEN
	# The two flat pools draw straight into the table ($C01B/$C030); a stand
	# that runs the pool for the numbers alone leaves this nought and then
	# nothing of theirs is drawn at all.
	sol_pool.table = sol_table
	oam = PackedByteArray()
	oam.resize(Pb2Sprites.OAM)
	oam.fill(Pb2Sprites.HIDDEN)
	var img := Image.create(Pb2Sprites.SPRITES, 1, false, Image.FORMAT_RGBA8)
	oam_tex = ImageTexture.create_from_image(img)
	bg.material.set_shader_parameter("oam", oam_tex)
	scroll = Vector2i(sol_view.x >> 4, sol_view.y >> 4)


## What `SolFlow` asks of whoever holds the game.  $E520 raises a stage out of
## its record; here that is the level file, which is the same record read out.
func flow_raise(st: int) -> void:
	stage_sol = st
	_load("sol", st, 0)
	_start_sol()
	sol_pool.w_x[0x0C] = (sol_pool.w_x[0x0C] & 0xFF00) | (sol_flow.lives & 0xFF)
	sol_pool.flow = sol_flow


## $E69B alone -- the record of the stage, and nothing round it.  The way out
## of a stage into the next one of the same area reads it while the hero is
## still standing, so neither the screen nor the colours are touched here.
func flow_door(st: int) -> void:
	flow_raise(st)


func flow_play() -> void:
	_step_sol()


## $E520 -- the thirty two the stage is drawn in, which the walk copies into
## $0790 and reads from there on.
func flow_palette() -> PackedByteArray:
	return level_sol.palette


func flow_hero() -> SolPlayer:
	return sol_hero


func flow_view() -> SolCamera:
	return sol_view


func flow_table() -> SolSprites.Table:
	return sol_table


func flow_pool() -> SolObjects:
	return sol_pool


## $FD -- the sound driver counts a tune it has played to its end into this,
## and the paying out of a clearing waits on it once.  No tune is made here, so
## it is over as soon as it is asked for; a walk that wants the cartridge's own
## waiting names the turn with `fd:N`.
func flow_tune_end() -> bool:
	return sol_fd_at < 0 or sol_walk_turn >= sol_fd_at


## $E776 -- the tune the stage's own record names, which the stage raised is
## played to.  No tune is made, so the number is carried and nothing else.
func flow_tune() -> int:
	return 0


func flow_pad_new() -> int:
	return sol_pad_edge


## $06 -- and what is held.
## $0300 -- what the typing of the tale hands the picture unit, which here is
## written straight into the screen it is standing on.
func flow_poke(addr: int, tile: int) -> void:
	if sol_flow.screen == "":
		return
	_sol_screen_now()
	sol_screen.poke(addr, tile)


func flow_pad() -> int:
	return pads[0].held if not pads.is_empty() else 0


## $EF8C over a screen already up -- one more of the cartridge's screens laid
## on top of what stands.  The mode names the whole list because a plate laid
## over another plate would leave the other's tiles where the new one writes
## nothing: the board is wiped and the list laid on it from the start.
func flow_relay(numbers: Array) -> void:
	if sol_flow.screen == "":
		return
	_sol_screen_now()
	sol_screen.relay(numbers)


## $EF8C once more with nothing wiped -- one screen laid over what already
## stands.  NAME ENTRY does that: BEST 5 is laid whole and then a sixth screen
## goes on top of it, which is the panel a name is typed in.
## What a stand compares besides the board: the bytes the flow holds.
func _sol_flow_state() -> Dictionary:
	var t := flow_table()
	var names := []
	for one in sol_flow.best_names:
		names.append([int(one[0]), int(one[1]), int(one[2])])
	var scores := []
	for one in sol_flow.best_scores:
		scores.append(int(one))
	return {
		"4c": sol_flow.z4c, "4d": sol_flow.z4d,
		"4e": sol_flow.z4e, "4f": sol_flow.z4f,
		"75": sol_flow.z75, "7d": sol_flow.z7d,
		"72": sol_flow.z72, "73": sol_flow.z73, "74": sol_flow.z74,
		"76": sol_flow.z76, "77": sol_flow.z77,
		"010a": sol_flow.fade.out[0x0A],
		"010b": sol_flow.fade.out[0x0B],
		# $0100..$011F -- the thirty two as the game holds them, which is not
		# the same as the thirty two the picture unit shows: four of those are
		# wired to four others and never take what is written to them.
		"0100": Array(sol_flow.fade.out),
		"0a": sol_flow.scroll_x, "0b": sol_flow.scroll_y,
		# What the names typed at the end move, which in every other mode is
		# something else: how many of the beat's lines are left, the walk the
		# man is doing and how far into it he is, and where he stands.
		"58": sol_flow.z58, "05ab": sol_flow.z05ab,
		"80": sol_flow.man_x & 0xFF, "81": (sol_flow.man_x >> 8) & 0xFF,
		"82": sol_flow.man_y & 0xFF, "83": (sol_flow.man_y >> 8) & 0xFF,
		"05a4": sol_flow.man_t, "05b4": sol_flow.man_i,
		"05b5": sol_flow.man_pose,
		"05a6": sol_flow.man_pic_lo, "05a7": sol_flow.man_pic_hi,
		"25": sol_flow.fade.count, "26": sol_flow.fade.kind,
		"27": sol_flow.fade.mask, "28": sol_flow.fade.pace,
		"0740": Array(sol_flow.z0740),
		"0750": Array(sol_flow.z0750),
		"0760": Array(sol_flow.z0760),
		"mark": [t.oam[4], t.oam[5], t.oam[6], t.oam[7]],
		# TEST MODE's own: the cursor is the first sprite and not the fifth,
		# the number under test is the second pair of kilobytes ($41), and
		# the screen that dying returns to is $0D.
		"cur": [t.oam[0], t.oam[1], t.oam[2], t.oam[3]],
		"2e": sol_flow.z2e, "59": sol_flow.z59, "0d": sol_flow.z0d,
		"41": (int(sol_flow.chr[2]) if sol_flow.chr.size() > 2 else 0),
		"stage": sol_flow.stage,
		"names": names, "scores": scores,
		"lives": sol_flow.lives, "score": sol_flow.score,
		"screen": sol_flow.screen,
		# What the paying out of a clearing moves: the suits still on him, what
		# is still to be paid, and which areas are done with.
		"05c5": sol_flow.suits_of(self),
		"05c6": sol_flow.owed_of(self),
		"2d": sol_flow.z2d,
	}


func flow_lay_more(n: int) -> void:
	if sol_flow.screen == "":
		return
	_sol_screen_now()
	sol_screen.lay_more(n)


## The picture a screen makes: the scene built afresh whenever the mode has put
## a different one up, and then handed over with where the mode says it stands.
func _sol_screen_frame() -> void:
	if sol_flow.screen == "":
		_sol_dark()
		return
	_sol_screen_now()
	_show_sol_screen(Vector2i(sol_flow.scroll_x, sol_flow.scroll_y))


## The screen the mode is standing on, built if it is not built yet.  It is
## asked for by the drawing and by the typing of the tale alike: a screen that
## is written into must be the same one from the first letter to the last, and
## a walk that only draws now and then would otherwise build it afresh at the
## first picture it is asked for and lose everything typed before that.
func _sol_screen_now() -> void:
	# $C5C9 with no screen after it -- both kilobytes wiped and whatever was
	# laid on them gone, the scene itself left standing.
	if sol_flow.screen_wipe:
		sol_flow.screen_wipe = false
		if sol_screen != null:
			for i in range(sol_screen.board.size()):
				sol_screen.board[i] = 0
			sol_screen.build()
	if sol_screen != null and sol_screen.name == sol_flow.screen:
		return
	var was: PackedByteArray = (sol_screen.board if sol_screen != null
			else PackedByteArray())
	sol_screen = SolScreen.make(sol_flow.screen)
	# A kilobyte the mode says was never wiped keeps what stood in it.
	if sol_flow.screen_keep != 0 and was.size() == sol_screen.board.size():
		for k in range(2):
			if (sol_flow.screen_keep & (1 << k)) == 0:
				continue
			for i in range(0x400):
				sol_screen.board[k * 0x400 + i] = was[k * 0x400 + i]
	if sol_flow.pal_direct:
		sol_flow.fade.out = PackedByteArray(sol_screen.palette)
	# $42..$45 -- a screen arrives with the four the cartridge had when it
	# was written down, and what is drawn on it takes them from there.
	for i in range(4):
		sol_table.banks[i] = int(sol_screen.spr_banks[i])


## $C578 -- between two screens the picture is turned off, and a console with
## its picture off shows nothing but black.  Which is what a map of no tiles at
## all comes to: every point of it is outside, and outside is the backdrop.
func _sol_dark() -> void:
	var m: ShaderMaterial = bg.material
	Nes.load_palette_table()
	var black := PackedByteArray()
	for _i in range(32):
		black.append(0x0F)
	pal_tex = Nes.palette_texture(black)
	m.set_shader_parameter("palette", pal_tex)
	m.set_shader_parameter("map_size", Vector2.ZERO)
	m.set_shader_parameter("wrap", Vector2.ZERO)
	m.set_shader_parameter("sprites_on", false)
	m.set_shader_parameter("bands_on", false)
	m.set_shader_parameter("bar_on", false)
	m.set_shader_parameter("split_at", 1000.0)
	m.set_shader_parameter("clip_left", 0.0)
	m.set_shader_parameter("view_top", 0.0)
	m.set_shader_parameter("view_bottom", 240.0)
	m.set_shader_parameter("scroll", Vector2.ZERO)


## Э4.6 -- the game from the switch being turned on.  Nothing is loaded: the
## flow opens on the mode the reset leaves behind ($D153 puts $01 in $02) and
## raises a stage itself when it gets that far.
func _start_sol_boot() -> void:
	game = "sol"
	sol_flow = SolFlow.new()
	sol_flow.mode = SolFlow.MAKER
	sol_flow.lives = 0x02
	sol_table = SolSprites.Table.new()
	for i in range(0, SolSprites.FWD_START, 4):
		sol_table.oam[i] = SolSprites.HIDDEN
	bg.z_index = -1


## One picture, in the order $CDB0 keeps it, and the same order the object
## stand runs above: what the background owes is paid at the top, then the
## view moves ($CD9C), then his breath ($CDB3), the scan ($CDBB), his own box
## ($CDBE) and what has been thrown at him ($CDCC) -- and only then does he
## take his step ($CDD2), the shots theirs ($CDDA) and the pool its own
## ($CDDD).  The one difference is that the stand is handed the cartridge's
## $0C, $0E, $06, $26, $58 and $7F picture by picture and here they are made.
func _step_sol() -> void:
	# The order itself is `SolTurn` ($CDB3); what it needs is whatever
	# `_start_sol` last built, because a new stage builds a new hero, a new
	# pool and a new view, while what was pressed last picture belongs to the
	# turn and carries across.
	if sol_turn == null:
		sol_turn = SolTurn.new(sol_hero, sol_pool, sol_view, sol_script,
				sol_table, sol_flow)
	else:
		sol_turn.hero = sol_hero
		sol_turn.pool = sol_pool
		sol_turn.view = sol_view
		sol_turn.script_ = sol_script
		sol_turn.table = sol_table
		sol_turn.flow = sol_flow
	sol_turn.step(pads[0].held)


func _show_sol() -> void:
	var m: ShaderMaterial = bg.material
	if level_sol.map_dirty:
		level_sol.map_dirty = false
		map_tex.update(level_sol.map_image)
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
	# Э6.3.3 -- when the stand is watching the sound, every step puts out a
	# seventh field: which places the engine drove itself, and what they and
	# everything else asked the driver for, in order.  The stand that judges
	# the table alone does not ask for it and still reads six.
	var noise := bool(cfg.get("noise", false))
	Pb2Sound.forget()
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
		# The places whose turn was the engine's own this step: only what they
		# asked for can be judged, the rest is named.
		var own := PackedStringArray()
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
					own.append(str(n))
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
		var line := "%d|%s|%s|%d/%d/%d|%s|%d,%d,%s" % [view.pos,
				" ".join(born) if born.size() else "-",
				" ".join(PackedStringArray(gone)) if gone.size() else "-",
				same, seen, mine,
				" ".join(wrong) if wrong.size() else "-",
				things.push_x - 256 if things.push_x > 127 else things.push_x,
				things.push_y - 256 if things.push_y > 127 else things.push_y,
				" ".join(boxes) if boxes.size() else "-"]
		if noise:
			var say := PackedStringArray()
			for i in range(Pb2Sound.asked.size()):
				say.append("%d:%02X" % [int(Pb2Sound.asked_by[i]),
						int(Pb2Sound.asked[i])])
			line += "|%s;%s" % [
					" ".join(own) if own.size() else "-",
					" ".join(say) if say.size() else "-"]
			Pb2Sound.forget()
		out.append(line)
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
	# Э6.3.5 -- and the noises the throws asked for, when the stand wants
	# them: one field more on the line, in the order they were asked.
	var noise := bool(cfg.get("noise", false))
	# Nothing has been handed over yet, so the first table is told and not
	# judged: the throws in it were made over steps the engine never saw.
	var told := false
	Pb2Sound.forget()
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
			# $A57D -- the blade's whirr counts its frames in $0400, which is
			# the type of his own place and belongs to nobody.  The port keeps
			# it in a field of its own, so the count is not carried over with
			# the table: it is set once, out of the first table handed over,
			# and after that the engine runs it itself.
			if not told and not tbl.is_empty():
				things.whirr = int(tbl[0][Pb2Objects.F_TYPE])
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
		var line := "%d %s" % [p.charge,
				" ".join(bad) if bad.size() else "-"]
		if noise:
			var say := PackedStringArray()
			for n in Pb2Sound.asked:
				say.append("%02X" % int(n))
			line += " |%s" % (" ".join(say) if say.size() else "-")
			Pb2Sound.forget()
		out.append(line)
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
	# Э6.3.6 -- and the noise the swinging water asks for, when the stand
	# wants it: one field more on the line.
	var noise := bool(cfg.get("noise", false))
	Pb2Sound.forget()
	for f in cfg["frames"]:
		things.frame = int(f["clock"])
		things.playing = int(f["mode"])
		things.live = int(f["live"])
		things.water_turn(view)
		# $D924 -- and then the view takes its hold and counts the same wait
		# down a second time.
		view.drive()
		var line := "%d %d %d" % [things.water, things.draw, things.flow]
		if noise:
			var say := PackedStringArray()
			for n in Pb2Sound.asked:
				say.append("%02X" % int(n))
			line += " |%s" % (" ".join(say) if say.size() else "-")
			Pb2Sound.forget()
		out.append(line)
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
## $CEF0 itself: the order one picture of an area is played in.
var turn: Pb2Turn = null
## $28 -- where in the console's sprite table this picture starts writing.
var rot := 0
## The console's own sprite table, kept from one picture to the next: what the
## drawing does not touch keeps what it said last time.
var oam := PackedByteArray()
var oam_tex: ImageTexture

# Э4.1 -- Solbrain walking about for real: the hero, the view and the table
# the console draws him out of.  Э4.3 will hand the same table to the things.
var sol_hero: SolPlayer
var sol_pool: SolObjects
var stage_sol := 0
## Э5.7 -- the order of one picture ($CDB3), which the paired mode plays as
## well.  $04 -- the pad now against the pad last time -- is kept inside it:
## the stands are handed the cartridge's own byte, the live game has to work
## the one before out for itself, and now the turn is what does.
var sol_turn: SolTurn = null
## $04 -- what has just gone down, as the mode reads it.  A stage reads the pad
## for itself and keeps its own $06; the screens read it through here.
var sol_pad_edge := 0
var sol_flow_was := 0
## While `--solwalk` is walking, the monitor's own stepping is off.
var sol_walking := false
## Which turn of a walk is running, and the turn $FD is to stand on from ($FD
## is the end of a tune, which no engine here plays).  Below nought the tune is
## over the moment it is asked for, which is what the live game wants.
var sol_walk_turn := 0
var sol_fd_at := -1
var sol_view: SolCamera
var sol_table: SolSprites.Table
## $02 -- what the game is doing.  A stand that only wants one stage leaves it
## nought and steps the stage itself; a whole game hands the picture to this.
var sol_flow: SolFlow
## The screen now up, when the flow has one up: `SolFlow.screen` names it and
## this is it built.
var sol_screen: SolScreen
## Э4.5 -- the stage's own script, $93B5.  It keeps its own two kilobytes from
## one picture to the next, because a third of what it touches has no home in
## the engine at all.
var sol_script := SolScript.new()
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
		Pb2Flow.stage_tune(came, ar)                # $CE22 -> $CE25
	turn = Pb2Turn.new(level_pb2, world, hero, view, status)
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
	turn._mirror_hero()
	# The area brought its own palette with it, so the suit's three colours
	# have to be put back over sprite palette one.
	_wear_suit()


## One step of the game.  The order itself is `Pb2Turn` ($CEF0); what is left
## here is what comes after it -- the sprite table, the colours a suit brings,
## and what the three ways a picture can end mean to the mode.
func _step_pb2() -> void:
	var pad: Pad = pads[0]
	turn.came = came
	turn.slid = slid
	var how: int = turn.step(pad.held, pad.pressed)
	slid = turn.slid
	if turn.repaint:
		turn.repaint = false
		_wear_suit()
	if how == Pb2Turn.NEXT_AREA:
		_next_area()
		return
	if how == Pb2Turn.INTERLUDE:
		phase = world.phase
		interludes += 1
		_start_play(level_pb2.stage, world.area)
		# $CE45 -- the other half of a stage is given its own time.
		status.restart_time(came, phase)
		Pb2Flow.stage_again(came, world.area)       # $CFCF
		_apply()
		return
	if how == Pb2Turn.DIED:
		_die()
		return
	if how == Pb2Turn.HELD:
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
	# $79 -- whether a boss's room is what is being built, which the door set
	# before it asked for the building and the building does not touch.
	var boss: int = world.boss
	var st: int = 6 if boss != 0 else level_pb2.stage
	var ar: int = world.area
	_start_play(st, ar)
	# $CF42 -- the one area with a tune of its own, and then a boss's room if
	# a boss's room is what was built.
	Pb2Flow.area_again(came, ar, phase, boss)
	_apply()


## $D022 -- a life is spent and the area is opened again; when there are none
## left the game is over and the stage begins from its first area.
func _die() -> void:
	died_count += 1
	# $CFF7 and $D01C -- steps eight and ten: the tune of it, and then be
	# quiet once the tune has finished.  The cartridge sits on step nine for
	# two hundred pictures between the two of them; the engine has nothing to
	# show there yet, so it does both at once.
	Pb2Flow.died()
	Pb2Flow.mourned()
	if lives > 0:
		lives -= 1
		# $D7AB -- where a spent life puts him, which is not the area he died
		# in: the top of the stage, or its middle if he had got past it and
		# owns the suit that is kept there.
		var to: Array = Pb2Flow.life_area(came, level_pb2.area, phase,
				status.owned)
		phase = int(to[1])
		_start_play(level_pb2.stage, int(to[0]))
	else:
		lives = 2                                   # $D090: $18 := 2
		phase = 0
		_start_play(level_pb2.stage, 0)
	# $D063 -- a life lost is a clock wound up again.
	status.restart_time(came, phase)
	# $D066 -- and the stage's tune again, read from where the life starts.
	Pb2Flow.stage_tune(came, level_pb2.area)
	Pb2Flow.area_again(came, level_pb2.area, phase, 0)   # $D069, $79 nought
	_apply()


## How many of his throws are still in the air ($A1C2 counts them).
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
## Э6.3.6: the bar, the clock and what he picks up -- $CDB8 and nothing else.
##
## `Pb2Status` alone, driven one step at a time: the picture count is handed
## over from the recording (the two refills and the clock are all measured on
## it), and so is every byte the cartridge was poked with -- the mode it was
## put into, the time it was given, the collectable it was handed.  What is put
## out is the counters, and after them the noises the step asked for.
func _run_bar(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	status = Pb2Status.new()
	status.stage = int(cfg.get("stage", 0))
	status.area = int(cfg.get("area", 0))
	status.boss = int(cfg.get("boss", 0))
	status.suit = int(cfg.get("suit", 0))
	status.owned = int(cfg.get("owned", 0))
	status.life = int(cfg.get("life", 0x10))
	status.energy = int(cfg.get("energy", 0))
	status.tanks = int(cfg.get("tanks", 0))
	status.life_tanks = int(cfg.get("life_tanks", 0))
	status.power_level = int(cfg.get("power", 0))
	status.second_blade = int(cfg.get("second", 0))
	status.extra_shot = int(cfg.get("extra", 0))
	status.drain_hi = int(cfg.get("drain_hi", 0))
	status.drain_lo = int(cfg.get("drain_lo", 0))
	status.time_hi = int(cfg.get("time_hi", 0))
	status.time_lo = int(cfg.get("time_lo", 0))
	status.warn = int(cfg.get("warn", 0))
	status.mode = int(cfg.get("mode", Pb2Status.PLAY))
	var out := PackedStringArray()
	Pb2Sound.forget()
	for f in cfg["frames"]:
		# Whatever the cartridge was poked with at this step, poked here too.
		if f.has("mode"):
			status.mode = int(f["mode"])
		if f.has("fill_life"):
			status.refill_life = int(f["fill_life"])
		if f.has("fill_energy"):
			status.refill_energy = int(f["fill_energy"])
		if f.has("life"):
			status.life = int(f["life"])
		if f.has("energy"):
			status.energy = int(f["energy"])
		if f.has("time_hi"):
			status.time_hi = int(f["time_hi"])
			status.time_lo = int(f["time_lo"])
			status.warn = int(f["warn"])
		# $B4AF -- a collectable he walked into, handed over by its subtype.
		if f.has("take"):
			status.take(int(f["take"]))
		# $CD -- the driver's fifth track, which the change of suit waits
		# on.  The driver is not on trial here, so its cell is handed over.
		if f.has("tune"):
			status.tune_busy = int(f["tune"])
		# $9A -- the suit, which the menu's own picking ($D259) is not in
		# this harness: the stand writes it where the picking would have.
		if f.has("suit"):
			status.suit = int(f["suit"])
		status.frozen = bool(f.get("frozen", false))
		# $1C -- the count itself, and step() takes it on by one as $CD5A
		# does, so it is put back one to land on the recording's own.
		status.clock = (int(f["clock"]) - 1) & 0xFF
		status.bell = false
		# $48 -- what has just gone down this picture, which is all $D0A6
		# reads of the pad.
		status.step(int(f.get("hit", 0)))
		var say := PackedStringArray()
		for n in Pb2Sound.asked:
			say.append("%02X" % int(n))
		out.append("%d %d %d %d %02X %02X %d %d %d |%s"
				% [status.mode, status.life, status.energy, status.warn,
				status.time_hi, status.time_lo, status.life_tanks,
				status.menu, status.came_in,
				" ".join(say) if say.size() else "-"])
		Pb2Sound.forget()
	print("\n".join(out))


## The tunes of the level's own flow, asked for one step at a time.
##
## `Pb2Flow` is the whole of what is under test and it keeps nothing, so there
## is no level here and no picture: each line of the config names a step of
## $1A and the four bytes that step's gates read, and what comes out is the
## numbers that step asked the driver for, in order.
func _run_flow(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var out := PackedStringArray()
	for e in cfg["events"]:
		var st: int = int(e.get("stage", 0))
		var ar: int = int(e.get("area", 0))
		var ph: int = int(e.get("phase", 0))
		var bs: int = int(e.get("boss", 0))
		Pb2Sound.forget()
		# $9C and $AD -- where a spent life puts him, which step eleven works
		# out for itself ($D7AB) and the other steps are handed.
		var said_to := ""
		match int(e["step"]):
			2: Pb2Flow.stage_tune(st, ar)               # $CE14 -> $CE25
			6: Pb2Flow.area_again(st, ar, ph, bs)       # $CF3C
			7: Pb2Flow.stage_again(st, ar)              # $CFBA
			8: Pb2Flow.died()                           # $CFF7
			10: Pb2Flow.mourned()                       # $D017
			11:
				var to: Array = Pb2Flow.life_spent(st, ar, ph,
						int(e.get("owned", 0)))         # $D022
				said_to = " %d %d" % [int(to[0]), int(to[1])]
			12: Pb2Flow.continued(st, ar, bs)           # $CFB4
		var say := PackedStringArray()
		for n in Pb2Sound.asked:
			say.append("%02X" % int(n))
		out.append("%d%s |%s" % [int(e["step"]), said_to,
				" ".join(say) if say.size() else "-"])
	Pb2Sound.forget()
	print("\n".join(out))


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
	var cleared_out := 0
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
			#
			# And the level's own things have eight places ($0E..$15), which
			# fill up where the pilot cannot kill.  The door's own record is
			# then dropped for want of one ($E4BA), and it is offered only for
			# the one or two steps in which it crosses the edge of the view --
			# so a table that is full just then loses the door for the whole
			# pass.  A player would have cleared the road; the pilot keeps one
			# of the eight free instead.
			if not opening and _make_room():
				cleared_out += 1
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
			% [areas, forced, stepped, deaths]
			+ "%d stuck, %d places made" % [stuck, cleared_out])
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
	Pb2Flow.stage_tune(came, 0)                     # $CE25
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


## $E4BA -- the scan drops a record it can find no place for, and the level's
## own things have only eight.  The pilot cannot kill, so where they pile up the
## door's record is dropped over and over and the area never puts out a door.
## Taking the first of the eight away is the pilot's way of clearing the road,
## and it is done only while all eight are busy and the door is not among them.
func _make_room() -> bool:
	var full := true
	for n in range(Pb2Objects.FIRST_PLACED, Pb2Objects.LAST_PLACED + 1):
		var t: int = world.slots[n][Pb2Objects.F_TYPE]
		if t == 0:
			full = false
		elif t == 0x04:
			return false
	if not full:
		return false
	world.clear(Pb2Objects.FIRST_PLACED)
	return true


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


## Э6.1 -- the two ported sound drivers on the same bare stand the cartridge
## is booted into.
##
## `work/tools/sndprobe.py` runs the cartridge's driver with nothing else
## running at all: the two banks it reads mapped, the page cleared, and one
## turn of a small loop a picture.  On each turn the loop first hands in
## whatever the table of requests says for that picture and then calls the
## driver's per-picture entry, so a request always comes before the tick it
## belongs to.  This is the same loop, with the ported driver in place of the
## cartridge's, and what comes out is the same tape: every write to
## $4000..$4017, in order, one line a picture.
##
## `work/extract/verify_sound.py` lays the two tapes side by side.
## The chip stand (Э6.2).  `nesemu` runs a cartridge and writes down two
## things: every write to $4000..$4017 with the cycle it landed on, and the
## wave it made of them.  Here the same tape is put through the engine's own
## chip -- the same bytes on the same cycles -- and the wave it makes is
## written out to be compared sample for sample.
func _run_apu(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	var cfg: Dictionary = JSON.parse_string(f.get_as_text())
	for r: Dictionary in cfg["runs"]:
		var cycles := int(r["cycles"])
		var chip := SndChip.new(SndRom.dmc(String(r["game"])))
		chip.reset()
		chip.reserve(cycles / SndChip.SND_EVERY + 2)
		var lf := FileAccess.open(String(r["log"]), FileAccess.READ)
		assert(lf != null, "no tape at %s" % r["log"])
		var at := 0
		while not lf.eof_reached():
			var ln := lf.get_line().strip_edges()
			if ln == "":
				continue
			var w := ln.split(" ", false)
			var c := int(w[0])
			if c > cycles:
				break
			if c > at:
				chip.run(c - at)
				at = c
			chip.write(w[1].hex_to_int(), w[2].hex_to_int(), c)
		lf.close()
		if cycles > at:
			chip.run(cycles - at)
		var of := FileAccess.open(String(r["out"]), FileAccess.WRITE)
		of.store_buffer(chip.wave())
		of.close()
		print("apu %s %d %d" % [r["say"], cycles, chip.out_n / 2])


## Э6.3.1 -- the seat, with nobody sitting in it.  Each run is a game and a
## number of pictures; what comes back is how many cycles of the chip those
## pictures were worth and how many samples came out of them.  Nothing here
## listens: `verify_snd_play.py` counts.
func _run_sndplay(path: String) -> void:
	var cfg: Dictionary = JSON.parse_string(
			FileAccess.get_file_as_string(path))
	for r in cfg["runs"]:
		var s := SndPlay.new(String(r["game"]))
		if r.has("ask"):
			s.ask(int(r["ask"]))
		for _i in range(int(r["pictures"])):
			s.step()
			# Nobody is taking them, so they are thrown away by the handful,
			# the way the player would if the monitor stopped.  What is being
			# counted is `made`, which is every sample the chip ever made.
			s.pump(null)
		print("play %s %d %d %d %d" % [r["game"], int(r["pictures"]),
				s.cycles, s.made, s.dropped])


func _run_sound(path: String) -> void:
	var f := FileAccess.open(path, FileAccess.READ)
	var cfg: Dictionary = JSON.parse_string(f.get_as_text())
	var runs: Array = cfg["runs"]
	for i in range(runs.size()):
		var r: Dictionary = runs[i]
		var apu := SndApu.new()
		var pb2: Pb2Sound = null
		var sol: SolSound = null
		if r["game"] == "pb2":
			pb2 = Pb2Sound.new(apu)
			pb2.boot()
		else:
			sol = SolSound.new(apu)
			sol.boot()
		# The stand's own table of requests: at most four, walked in order,
		# each waiting for its picture.  $10 is how far down the table the
		# loop has got and $11:$12 is the picture.
		var script: Array = r["script"]
		var slot := 0
		for p in range(int(r["pictures"])):
			apu.clear()
			if slot < script.size() and int(script[slot][0]) == p:
				var kind := int(script[slot][1])
				var num := int(script[slot][2])
				slot += 1
				if pb2 != null:
					pb2.ask(num)
				elif kind == 0:
					sol.ask_tune(num)
				else:
					sol.ask_sound(num)
			if pb2 != null:
				pb2.tick()
			else:
				sol.tick()
			var line := "snd %d %d" % [i, p]
			for w in apu.writes:
				line += " %04X=%02X" % [w[0], w[1]]
			print(line)
