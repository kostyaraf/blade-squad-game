extends SceneTree
## Replays only recorded controller input from normal menu entries.
## No state injection, warps, invulnerability, or direct transition calls.
var failures := 0

func _initialize() -> void:
	var cases: Array = JSON.parse_string(FileAccess.get_file_as_string(
			"res://../docs/qa/playthrough/cases.json"))
	for case in cases:
		play(case)
	print("%d of %d recorded playthroughs failed" % [failures, cases.size()])
	quit(1 if failures else 0)

func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", label)

func play(case: Dictionary) -> void:
	var rec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
			"res://../docs/qa/playthrough/" + case.file))
	# Recordings made before SPB2-04 carry no flag and replay the old spawn rule.
	Pb2Turn.exact_scan = bool(rec.get("exact_scan", false))
	var heroes: Array = []
	for hero in rec.heroes:
		heroes.append(int(hero))
	var session := Pb3Session.new(heroes)
	session.at = int(rec.entry)
	check(session.enter(), case.file + " entry")
	var events: Array = []
	var missing: Dictionary = {}
	var played := 0
	var expected_ticks := 0
	for part in rec.steps: expected_ticks += int(part[0])
	for part in rec.steps:
		if session.two == null: break
		var pad: Array = []
		for i in range(1, part.size()):
			pad.append(int(part[i]))
		for frame in range(int(part[0])):
			if session.two == null: break
			played += 1
			var event := session.advance(session.tick, pad)
			if session.two != null and session.two.host_pb2 != null:
				for row in session.two.host_pb2.slots.slice(Pb2Objects.FIRST_LIVE):
					var kind: int = row[Pb2Objects.F_TYPE]
					# $4E's native dispatch is an intentional RTS ($8042).
					if kind != 0 and kind != 0x4E and not Pb2Objects.MINDS.has(kind):
						if not missing.has(kind):
							missing[kind] = true
							check(false, case.file + " missing object handler $%02X" % kind)
			if event != "playing":
				events.append({"tick":session.tick,"entry":session.at,
						"event":event,"message":session.message})
			for point in case.get("checkpoints", []):
				if int(point.tick) != played:
					continue
				check(session.two != null, case.file + " still alive")
				if session.two == null:
					continue
				if point.has("position"):
					var at := session.two.world_of(int(point.player))
					check(at == Vector2i(int(point.position[0]), int(point.position[1])),
							case.file + " platform landing at " + str(played))
				if point.has("life"):
					check(session.two.things[0].slots[0][Pb2Objects.F_LIFE]
							== int(point.life), case.file + " damage at " + str(played))
				if point.has("broken"):
					check(not session.two.solv.whole(int(point.broken)),
							case.file + " bonus cube destroyed")
				if point.get("all_alive", false):
					for i in range(heroes.size()):
						var alive: bool = not session.two.gone[i]
						if heroes[i] == Pb3Pair.SOL:
							alive = alive and session.two.sol[i].state not in [0x0C, 0x0E]
						else:
							alive = alive and session.two.things[i].slots[0][Pb2Objects.F_LIFE] > 0
						check(alive, case.file + " player " + str(i + 1) + " survives")
	check(events.size() == rec.events.size(), case.file + " exit count")
	for i in range(mini(events.size(), rec.events.size())):
		var actual: Dictionary = events[i]
		var expected: Dictionary = rec.events[i]
		check(actual.tick == int(expected.tick)
				and actual.entry == int(expected.entry)
				and actual.event == expected.event
				and actual.message == expected.message, case.file + " actual exit event")
	check(session.tick == expected_ticks, case.file + " every input consumed")
	print(case.file, ": ", played, " ticks, ", events)
	session.leave()
