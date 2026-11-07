extends SceneTree

## PB3 hybrid levels (docs/hybrid/authoring.md): every hybrid record is in the
## list after both games' own, every segment can be raised for every team,
## and a finished segment hands over to the next one.

var failed := 0


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, what: String) -> void:
	if not ok:
		failed += 1
		print("FAIL: ", what)


func run() -> void:
	var recs: Array = Pb3List.records()
	var levels: Array = Pb3Pair.hybrid_levels()
	check(levels.size() > 0, "hybrid index is empty")
	for h in range(levels.size()):
		var at: int = recs.find([Pb3Pair.HYB, h, 0])
		check(at >= 63 + 20, "hybrid %d is not after both games" % h)
		for seg in range(Pb3Pair.hybrid_segments(h)):
			var want: Dictionary = Pb3Pair.hybrid_segment(h, seg)
			for kinds in [[0], [1], [0, 1]]:
				var two := Pb3Pair.new(Pb3Pair.HYB, h, seg, kinds)
				var game: int = Pb3Pair.SOL if String(want["game"]) == "sol" else Pb3Pair.PB2
				check(two.game == game and two.hyb == h and two.hyb_seg == seg,
						"segment %d.%d raised as its own game" % [h, seg])
				check(two.stage == int(want["stage"]), "segment %d.%d stage" % [h, seg])
				two.release()
		# From the menu: walk right without health cheats, as pb3_session_test does.
		for kinds in [[0], [1], [0, 1]]:
			var s := Pb3Session.new(kinds)
			s.at = at
			check(s.enter(), "enter %s %s" % [Pb3List.say(recs[at]), kinds])
			check(s.two.hyb == h and s.two.hyb_seg == 0, "menu enters segment 0")
			for f in range(240):
				var words: Array = []
				for i in range(kinds.size()):
					words.append(Pad.RIGHT | (Pad.A if f % 30 < 3 else 0))
				var ev: String = s.advance(s.tick, words)
				check(ev != "rejected", "input rejected")
				if ev == "list":
					break
			s.leave()
		# A finished first segment raises the second one, keeping the record.
		if Pb3Pair.hybrid_segments(h) > 1 \
				and String(Pb3Pair.hybrid_segment(h, 0)["game"]) == "pb2":
			var s := Pb3Session.new([0])
			s.at = at
			s.enter()
			s.two.ended = Pb2Turn.NEXT_AREA
			check(s.resolve() == "changed", "segment 0 hands over")
			check(s.two != null and s.two.hyb_seg == 1, "segment 1 raised")
			check(s.at == at, "the menu record stays the hybrid one")
			s.leave()
	print("PB3 HYBRID: %d levels, %d failures" % [levels.size(), failed])
	quit(1 if failed else 0)
