extends SceneTree
func _init():
 call_deferred("run")
func run():
 for kinds in [[0], [1], [0, 1], [1, 1]]:
  for at in [0, 63]:
   var s = load("res://src/pb3_session.gd").new(kinds)
   s.at = at
   if not s.enter():
    print("FAILED ENTER")
    quit(1)
    return
   for f in range(120):
    var words = []
    for i in range(kinds.size()):
     words.append(1 | (128 if f % 30 < 3 else 0) | (64 if (f + i * 4) % 12 < 3 else 0))
    var event = s.advance(s.tick, words)
    var positions = []
    if s.two != null:
     for i in range(kinds.size()):
      var p = s.two.world_of(i)
      positions.append([p.x, p.y])
    print("TRACE:", to_json([kinds, at, f, event, positions]))
    if event == "list": break
   s.leave()
 print("LOGIC COMPLETE")
 quit()
