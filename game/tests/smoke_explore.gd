extends SceneTree
## QAI smoke explorer: plays every level from its normal menu entry with
## deterministic, seeded heuristic controller input and reports anomalies.
## Only pad words are fed to Pb3Session.advance -- no teleports, no state
## pokes, no invulnerability -- so every finding replays from its seed.
##
## Arguments (after `--`):
##   --jobs=E:T,E:T,...  entry index (0..82) and team (nova|sol|coop|sol+nova)
##   --ticks=N           input frames per run (default 3000)
##   --seed=S            base seed; each run uses hash(S, entry, team)
##   --out=PATH          JSONL, one line per finished run (appended, flushed)
##   --replays=DIR       write a playthrough.gd-format replay for runs with
##                       anomalies (open it with game/tests/playthrough.gd)
##   --trace=TICK        print the state of every frame from TICK-30 to TICK+10
## The Python driver is work/qa/smoke.py.

const TEAMS := {"nova": [0], "sol": [1], "coop": [0, 1], "sol+nova": [1, 0]}
## Detection thresholds, in input frames.
const STUCK_WINDOW := 600
const EMBED_TICKS := 30
const LOST_TICKS := 45
const OOB_TICKS := 10
const HELD_TICKS := 1200
const FROZEN_TICKS := 900
const SLOW_STEP_MS := 100
const EARLY_DEATH := 120

class ErrorTrap extends Logger:
	var lock := Mutex.new()
	var errors: Array = []
	func _log_error(function: String, file: String, line: int, code: String,
			rationale: String, _editor_notify: bool, error_type: int,
			_backtraces: Array[ScriptBacktrace]) -> void:
		lock.lock()
		errors.append({"type": error_type, "where": "%s:%d %s" % [file, line, function],
				"text": (rationale if rationale != "" else code).left(160)})
		lock.unlock()
	func _log_message(_message: String, _error: bool) -> void:
		pass
	func take() -> Array:
		lock.lock()
		var out := errors.duplicate()
		errors.clear()
		lock.unlock()
		return out

var trap := ErrorTrap.new()
var out_path := ""
var replay_dir := ""
var trace_tick := -1

func _initialize() -> void:
	OS.add_logger(trap)
	var jobs: Array = []
	var ticks := 3000
	var base_seed := 1
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--jobs="):
			for part in arg.substr(7).split(",", false):
				var bits := part.split(":")
				jobs.append([int(bits[0]), bits[1]])
		elif arg.begins_with("--ticks="):
			ticks = int(arg.substr(8))
		elif arg.begins_with("--seed="):
			base_seed = int(arg.substr(7))
		elif arg.begins_with("--out="):
			out_path = arg.substr(6)
		elif arg.begins_with("--replays="):
			replay_dir = arg.substr(10)
		elif arg.begins_with("--trace="):
			trace_tick = int(arg.substr(8))
	for job in jobs:
		var result := play(int(job[0]), String(job[1]), ticks, base_seed)
		emit(result)
	quit(0)

func emit(result: Dictionary) -> void:
	var line := JSON.stringify(result)
	if out_path == "":
		print(line)
		return
	var f := FileAccess.open(out_path, FileAccess.READ_WRITE if FileAccess.file_exists(out_path) else FileAccess.WRITE)
	f.seek_end()
	f.store_line(line)
	f.close()

static func run_seed(base: int, entry: int, team: String) -> int:
	return hash([base, entry, team]) & 0x7FFFFFFF

# ---- input -----------------------------------------------------------------

## One player's heuristic.  Mostly "go somewhere": hold a direction and
## swing the weapon; when that stops making progress escalate through jump,
## long jump, climb up, climb down, and finally turn round for a while.
## Seeded random bursts of arbitrary buttons are mixed in throughout.
class Driver:
	var rng := RandomNumberGenerator.new()
	var dir := Pad.RIGHT
	var t := 0
	var plan: Array = []          # queued [frames, word] chunks
	var burst := 0
	var word := 0
	var last_x := -99999
	var last_y := -99999
	var still := 0
	var escalation := 0
	var turned := 0
	func _init(seed_: int, lean_left: bool) -> void:
		rng.seed = seed_
		# Head for the far side of the level, with a seeded exception.
		if lean_left != (rng.randf() < 0.15):
			dir = Pad.LEFT
	func queue(frames: int, w: int) -> void:
		plan.append([frames, w])
	func next(at: Vector2i) -> int:
		t += 1
		if absi(at.x - last_x) + absi(at.y - last_y) > 0:
			still = 0
			if absi(at.x - last_x) > 0:
				escalation = 0
		else:
			still += 1
		last_x = at.x
		last_y = at.y
		if turned > 0:
			turned -= 1
			if turned == 0:
				dir = Pad.LEFT if dir == Pad.RIGHT else Pad.RIGHT
		if not plan.is_empty():
			var chunk: Array = plan[0]
			chunk[0] -= 1
			if chunk[0] <= 0:
				plan.pop_front()
			return chunk[1]
		if burst > 0:
			burst -= 1
			if burst % 5 == 4:
				word = rng.randi() & 0xCF
				if (word & Pad.LEFT) and (word & Pad.RIGHT): word &= ~Pad.LEFT
				if (word & Pad.UP) and (word & Pad.DOWN): word &= ~Pad.DOWN
			return word
		if rng.randf() < 0.004:
			burst = rng.randi_range(10, 60)
		if still >= 12:
			still = 0
			escalation += 1
			match escalation:
				1:
					queue(1, 0); queue(rng.randi_range(8, 30), dir | Pad.A)
				2:
					queue(1, 0); queue(30, dir | Pad.A); queue(10, dir)
				3:
					queue(rng.randi_range(30, 90), Pad.UP | (dir if rng.randf() < 0.3 else 0))
				4:
					queue(rng.randi_range(20, 60), Pad.DOWN)
					queue(1, 0); queue(10, Pad.DOWN | Pad.A)
				5:
					queue(1, 0); queue(24, Pad.UP | Pad.A); queue(40, Pad.UP | dir)
				_:
					escalation = 0
					dir = Pad.LEFT if dir == Pad.RIGHT else Pad.RIGHT
					turned = rng.randi_range(120, 400)
		var w := dir
		if (t / 6) % 2 == 0: w |= Pad.B
		if rng.randf() < 0.01:
			queue(1, w & ~Pad.A); queue(rng.randi_range(5, 30), w | Pad.A)
		if rng.randf() < 0.003:
			queue(rng.randi_range(10, 40), Pad.DOWN | (Pad.B if rng.randf() < 0.5 else 0))
		return w

# ---- one run ---------------------------------------------------------------

func play(entry: int, team: String, ticks: int, base_seed: int) -> Dictionary:
	var seed_ := run_seed(base_seed, entry, team)
	var heroes: Array = TEAMS[team]
	var rec: Array = Pb3List.records()[entry]
	var result := {"entry": entry, "level": Pb3List.say(rec), "team": team,
			"seed": seed_, "base_seed": base_seed, "ticks": 0, "outcome": "playing",
			"events": [], "anomalies": [], "ms": 0}
	var started := Time.get_ticks_msec()
	trap.take()
	Pb2Turn.exact_scan = true
	var session := Pb3Session.new(heroes)
	session.at = entry
	if not session.enter():
		note(result, "entry_failed", 0, -1, "Pb3Session.enter returned false")
		return result
	for e in trap.take():
		note(result, "script_error" if e.type == Logger.ERROR_TYPE_SCRIPT else "engine_error", 0, -1, e.where + " " + e.text)
	var drivers: Array = []
	for i in range(heroes.size()):
		var home: Vector2i = session.two.world_of(i)
		drivers.append(Driver.new(seed_ + 7919 * i, home.x * 2 > session.two.solv.width_tiles * 8))
	var steps: Array = []
	var events: Array = []
	var st := Watch.new(heroes.size())
	for frame in range(ticks):
		if session.two == null:
			break
		var words: Array = []
		for k in range(drivers.size()):
			words.append(drivers[k].next(session.two.world_of(k)))
		if steps.is_empty() or steps[-1].slice(1) != words:
			steps.append([1] + words)
		else:
			steps[-1][0] += 1
		var t0 := Time.get_ticks_usec()
		var event := session.advance(session.tick, words)
		var took := (Time.get_ticks_usec() - t0) / 1000
		var tick: int = session.tick
		result.ticks = tick
		for e in trap.take():
			note(result, "script_error" if e.type == Logger.ERROR_TYPE_SCRIPT else "engine_error",
					tick, -1, e.where + " " + e.text)
		if took > SLOW_STEP_MS:
			note(result, "slow_step", tick, -1, "%d ms" % took)
		if event == "rejected":
			note(result, "rejected_input", tick, -1, str(words))
			break
		if event != "playing":
			events.append({"tick": tick, "event": event, "entry": session.at, "message": session.message})
			result.events.append("%d:%s:%s" % [tick, event, Pb3List.say(Pb3List.records()[session.at]) if event == "changed" else session.message])
			st.reset()
			if event == "list":
				result.outcome = "died" if session.message.begins_with("TEAM DOWN") else session.message
				if result.outcome == "died" and tick < EARLY_DEATH:
					note(result, "early_death", tick, -1, "team down %d frames after entry" % tick)
				break
			continue
		inspect(session, words, tick, st, result)
		if trace_tick >= 0 and tick >= trace_tick - 30 and tick <= trace_tick + 10:
			print("TRACE ", tick, " ", words, " ", trace_state(session))
	if result.outcome == "playing":
		result.outcome = "timeout"
	result.ms = Time.get_ticks_msec() - started
	result["final"] = signature(session) if session.two != null else ""
	result["span"] = st.span
	if session.two != null:
		session.leave()
	if replay_dir != "" and not result.anomalies.is_empty():
		var path := "%s/%s-%s-%d.replay.json" % [replay_dir, result.level, team, base_seed]
		var f := FileAccess.open(path, FileAccess.WRITE)
		f.store_string(JSON.stringify({"entry": entry, "heroes": heroes, "steps": steps,
				"events": events, "exact_scan": true, "smoke_seed": seed_}))
		f.close()
		result["replay"] = path
	return result

## Per-run detector state.
class Watch:
	var hist: Array = []          # per player: Array of Vector2i, last STUCK_WINDOW
	var lr: Array = []            # per player: frames with L, frames with R in window
	var embedded: Array = []
	var lost: Array = []
	var oob: Array = []
	var reported: Dictionary = {}
	var span: Array = []          # per player: [min x, max x, min y, max y] seen
	var held := 0
	var same := 0
	var last_sig := ""
	func _init(n: int) -> void:
		for i in range(n):
			hist.append([])
			lr.append([])
			embedded.append(0)
			lost.append(0)
			oob.append(0)
			span.append([])
	func reset() -> void:
		for i in range(hist.size()):
			hist[i] = []
			lr[i] = []
			embedded[i] = 0
			lost[i] = 0
			oob[i] = 0
		held = 0
		same = 0
		last_sig = ""

func note(result: Dictionary, kind: String, tick: int, player: int, detail: String, at: Variant = null) -> void:
	# Keep reports short: at most 3 of a kind per run.
	var n := 0
	for a in result.anomalies:
		if a.kind == kind:
			n += 1
	if n >= 3:
		return
	var item := {"kind": kind, "tick": tick, "player": player, "detail": detail}
	if at != null:
		item["at"] = [at.x, at.y]
	result.anomalies.append(item)

func inspect(session: Pb3Session, words: Array, tick: int, st: Watch, result: Dictionary) -> void:
	var two: Pb3Pair = session.two
	var w_px: int = two.solv.width_tiles * 8
	var h_px: int = two.solv.height_tiles * 8
	var held: bool = two.ended == Pb2Turn.HELD or two.force_hold \
			or (two.host_script != null and two.host_script.controls_locked)
	st.held = st.held + 1 if two.ended == Pb2Turn.HELD else 0
	if st.held == HELD_TICKS:
		note(result, "held_forever", tick, -1, "turn HELD for %d frames" % HELD_TICKS)
	for i in range(two.who.size()):
		if two.gone[i]:
			continue
		var w: Vector2i = two.world_of(i)
		if st.span[i].is_empty():
			st.span[i] = [w.x, w.x, w.y, w.y]
		else:
			st.span[i] = [mini(st.span[i][0], w.x), maxi(st.span[i][1], w.x), mini(st.span[i][2], w.y), maxi(st.span[i][3], w.y)]
		# Health.
		var life: int = two.things[i].slots[0][Pb2Objects.F_LIFE] if two.who[i] == Pb3Pair.PB2 else two.sol[i].suit
		var cap: int = 0x10 if two.who[i] == Pb3Pair.PB2 else 0x08
		if two.who[i] == Pb3Pair.PB2 and i != two.host and two.game == Pb3Pair.PB2 and two.guest_row[i] != null:
			life = two.guest_row[i][Pb2Objects.F_LIFE]
		if life < 0 or life > cap:
			once(st, result, "bad_health", tick, i, "life=%d cap=%d" % [life, cap], w)
		if two._sol_departing(i):
			continue
		# Out of the level.
		var out := w.x < 0 or w.x >= w_px or w.y < -32 or w.y >= h_px + 16
		st.oob[i] = st.oob[i] + 1 if out else 0
		if st.oob[i] == OOB_TICKS:
			once(st, result, "out_of_level", tick, i, "level %dx%d" % [w_px, h_px], w)
		# Inside something solid (feet pixel - 8, the pair's own question).
		var inside: bool = two._solid(w) and two._solid(w + Vector2i(0, -8))
		st.embedded[i] = st.embedded[i] + 1 if inside else 0
		if st.embedded[i] == EMBED_TICKS:
			once(st, result, "inside_solid", tick, i, "state=%s" % hero_state(two, i), w)
		# Off the screen.
		var s: Vector2i = two.screen_of(i)
		var off := s.x < -8 or s.x > 264 or s.y < -16 or s.y > 256
		st.lost[i] = st.lost[i] + 1 if off else 0
		if st.lost[i] == LOST_TICKS:
			once(st, result, "camera_lost", tick, i, "screen=%s view=%d" % [s, two.view_x()], w)
		# Stuck: the controller asked for both directions, nothing moved.
		var h: Array = st.hist[i]
		h.append(two.flat_of(i))
		var pad: int = words[i]
		st.lr[i].append((1 if pad & Pad.LEFT else 0) | (2 if pad & Pad.RIGHT else 0) | (4 if held else 0))
		if h.size() > STUCK_WINDOW:
			h.pop_front()
			st.lr[i].pop_front()
			var lo: Vector2i = h[0]
			var hi: Vector2i = h[0]
			for p in h:
				lo = Vector2i(mini(lo.x, p.x), mini(lo.y, p.y))
				hi = Vector2i(maxi(hi.x, p.x), maxi(hi.y, p.y))
			if hi.x - lo.x <= 2 and hi.y - lo.y <= 2:
				var nl := 0
				var nr := 0
				var nh := 0
				for v in st.lr[i]:
					nl += v & 1
					nr += (v >> 1) & 1
					nh += (v >> 2) & 1
				if nl > 60 and nr > 60 and nh < STUCK_WINDOW / 2:
					once(st, result, "stuck", tick, i, "no movement for %d frames with L=%d R=%d; state=%s" % [STUCK_WINDOW, nl, nr, hero_state(two, i)], w)
	# Objects without a handler.
	if two.host_pb2 != null:
		for row in two.host_pb2.slots.slice(Pb2Objects.FIRST_LIVE):
			var kind: int = row[Pb2Objects.F_TYPE]
			if kind != 0 and kind != 0x4E and not Pb2Objects.MINDS.has(kind):
				once(st, result, "missing_handler", tick, -1, "PB2 object $%02X" % kind)
	var pools: Array = []
	if two.host_sol != null:
		pools.append(two.host_sol)
	for p in two.guest_pool:
		if p is SolObjects:
			pools.append(p)
	for pool in pools:
		for d in [pool.skipped, pool.shots_skipped, pool.weapons_skipped, pool.sat_skipped]:
			for key in d:
				once(st, result, "missing_handler", tick, -1, "Solbrain behaviour %s" % str(key))
		if two.host_sol == pool:
			for n in range(16):
				if pool.id[n] != 0:
					var ox: int = pool.x[n] >> 4
					var oy: int = pool.y[n] >> 4
					if ox < -256 or oy < -256 or ox > w_px + 256 or oy > h_px + 256:
						once(st, result, "object_out_of_level", tick, -1, "slot %d id $%02X mind $%02X at %d,%d" % [n, pool.id[n], pool.mind[n], ox, oy])
	# Frozen: nothing at all changes although the controller is busy.
	var sig := signature(session)
	st.same = st.same + 1 if sig == st.last_sig else 0
	st.last_sig = sig
	if st.same == FROZEN_TICKS:
		once(st, result, "frozen", tick, -1, "state unchanged for %d frames; ended=%d" % [FROZEN_TICKS, two.ended])

func once(st: Watch, result: Dictionary, kind: String, tick: int, player: int, detail: String, at: Variant = null) -> void:
	var key := "%s/%d/%s" % [kind, player, detail if kind == "missing_handler" else ""]
	if st.reported.has(key):
		return
	st.reported[key] = true
	note(result, kind, tick, player, detail, at)

func hero_state(two: Pb3Pair, i: int) -> String:
	if two.who[i] == Pb3Pair.SOL:
		return "sol:$%02X" % two.sol[i].state
	return "pb2:sub%d" % two.pb2[i].sub

func signature(session: Pb3Session) -> String:
	var two: Pb3Pair = session.two
	var parts: Array = [two.view_x(), two.ended, session.at]
	for i in range(two.who.size()):
		parts.append(two.world_of(i))
		parts.append(hero_state(two, i))
	if two.host_pb2 != null:
		for row in two.host_pb2.slots.slice(Pb2Objects.FIRST_LIVE):
			if row[Pb2Objects.F_TYPE] != 0:
				parts.append([row[Pb2Objects.F_TYPE], row[Pb2Objects.F_X], row[Pb2Objects.F_Y], row[Pb2Objects.F_STATE]])
	if two.host_sol != null:
		var o: SolObjects = two.host_sol
		for n in range(16):
			if o.id[n] != 0:
				parts.append([o.id[n], o.x[n], o.y[n], o.mind[n]])
	return str(parts).md5_text()

func trace_state(session: Pb3Session) -> String:
	var two: Pb3Pair = session.two
	var out: Array = ["view=%d" % two.view_x(), "ended=%d" % two.ended]
	if two.host_status != null:
		out.append("time=%02X%02X%s" % [two.host_status.time_hi, two.host_status.time_lo, " OUT" if two.host_status.out_of_time else ""])
	for i in range(two.who.size()):
		var life: int = two.things[i].slots[0][Pb2Objects.F_LIFE] if two.who[i] == Pb3Pair.PB2 else two.sol[i].suit
		out.append("p%d=%s %s life=%d scr=%s gone=%s" % [i, two.world_of(i), hero_state(two, i), life, two.screen_of(i), two.gone[i]])
	if two.host_pb2 != null:
		for n in range(Pb2Objects.FIRST_LIVE, Pb2Objects.SLOTS):
			var r: PackedByteArray = two.host_pb2.slots[n]
			if r[Pb2Objects.F_TYPE] != 0:
				out.append("o%d:$%02X@%d,%d" % [n, r[Pb2Objects.F_TYPE], r[Pb2Objects.F_X], r[Pb2Objects.F_Y]])
	if two.host_sol != null:
		var o: SolObjects = two.host_sol
		for n in range(16):
			if o.id[n] != 0:
				out.append("o%d:id$%02X/m$%02X@%d,%d" % [n, o.id[n], o.mind[n], o.x[n] >> 4, o.y[n] >> 4])
	return " ".join(out)
