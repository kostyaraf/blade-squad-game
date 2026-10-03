extends SceneTree

var failures: Array = []
var coverage: Array = []
var frames := 0
var cases := 0

func _initialize() -> void:
	call_deferred("run")

func solid(pair: Pb3Pair, p: Vector2i) -> bool:
	if pair.game == 0:
		return pair.pb2v.class_byte(p.x, p.y) == 0x80
	return pair.solv.collision_at(p.x, p.y) >= 0x10

func points(pair: Pb3Pair) -> Array:
	var found: Array = []
	var width: int = pair.solv.width_tiles * 8
	var height: int = pair.solv.height_tiles * 8
	var low := Vector2i(16, 48)
	var high := Vector2i(width - 16, height - 16)
	if pair.game == 1:
		low = Vector2i(maxi(16, (pair.sol_eye.x_min >> 4) + 16), maxi(48, (pair.sol_eye.y_min >> 4) + 48))
		high = Vector2i(mini(high.x, (pair.sol_eye.x_end >> 4) - 16), mini(high.y, (pair.sol_eye.y_end >> 4) - 16))
	for y in range(low.y, high.y, 16):
		if pair.game == 0 and pair.pb2v.vertical and y % 256 >= 240:
			continue
		for x in range(low.x + 8, high.x, 16):
			var foot := Vector2i(x, y)
			if not solid(pair, foot) or solid(pair, foot + Vector2i(0, -1)):
				continue
			var clear := true
			for dx in [-6, 0, 5]:
				for dy in [-1, -16, -32, -40]:
					if solid(pair, foot + Vector2i(dx, dy)):
						clear = false
			if clear:
				found.append(foot + Vector2i(0, -2))
	var sample: Array = []
	for n in range(mini(3, found.size())):
		sample.append(found[(n * (found.size() - 1)) / maxi(1, mini(3, found.size()) - 1)])
	return sample

## REV-02 -- a live session's hero rules (net, combo slide, Solbrain on a
## Power Blade map) without the level's things.  `begin(.., false)` raises no
## pools, but a live Solbrain stage hands every guest a contact carrier
## ($948D timer, $8354 wound; `Pb3Pair._raise_flow`).  The stand gives each
## guest the same idle carrier, so the empty stage is a whole live one.
func live_without_flow(pair: Pb3Pair) -> void:
	pair.live_session = true
	if pair.game != 1:
		return
	pair.guest_sol.resize(pair.who.size())
	for i in range(pair.who.size()):
		if i == pair.host:
			continue
		var carrier := SolPlayer.new(pair.solv)
		carrier.timer = 0xFF
		pair.guest_sol[i] = carrier


func run() -> void:
	for rec in Pb3List.records():
		var look := Pb3Pair.new(rec[0], rec[1], rec[2], [0, 1])
		var sites: Array = points(look)
		var row := {"level": Pb3List.say(rec), "sites": [], "cases": 0, "ticks": 0, "failures": 0}
		for spot in sites:
			row.sites.append([spot.x, spot.y])
			for kinds in [[0, 1], [1, 0]]:
				for mode in range(5):
					var pair := Pb3Pair.new(rec[0], rec[1], rec[2], kinds)
					if rec[0] == 0:
						pair.solv.continuous_vertical = true
					pair.begin([spot, spot])
					live_without_flow(pair)
					var bad := ""
					for f in range(180):
						var word: int = 0 if mode == 0 else (Pad.RIGHT if mode % 2 else Pad.LEFT)
						if mode >= 3 and f % 45 < 5:
							word |= Pad.A
						if mode == 4:
							word |= Pad.DOWN
						pair.step([word, word])
						frames += 1
						row.ticks += 1
						for slot in range(2):
							if pair.gone[slot]:
								continue
							var p: Vector2i = pair.world_of(slot)
							var probe: Vector2i = p + Vector2i(0, -8)
							if pair.game == 0 and pair.pb2v.vertical:
								var fy: int = pair.flat_of(slot).y - 8
								probe.y = (fy / 240) * 256 + fy % 240
							if solid(pair, probe):
								bad = "slot=%d hero=%d frame=%d pos=%s mode=%d" % [slot, kinds[slot], f, p, mode]
						if bad != "" or not pair.alive():
							break
					cases += 1
					row.cases += 1
					if bad != "":
						row.failures += 1
						failures.append({"level": row.level, "start": [spot.x, spot.y], "kinds": kinds, "detail": bad})
						print("FAIL ", row.level, " start=", spot, " ", bad)
					pair.release()
		look.release()
		coverage.append(row)
		print("COVER ", row.level, " sites=", sites.size(), " cases=", row.cases, " ticks=", row.ticks, " failures=", row.failures)
	var out := FileAccess.open("res://../docs/qa/traversal.json", FileAccess.WRITE)
	out.store_string(JSON.stringify({"scope": "Static geometry only; no enemies or end-to-end completion claim", "coverage": coverage, "failures": failures}, "  "))
	print("%d of %d traversal cases failed; %d ticks, %d level records" % [failures.size(), cases, frames, coverage.size()])
	quit(1 if not failures.is_empty() else 0)
