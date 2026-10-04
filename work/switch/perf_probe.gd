extends SceneTree
# CPU-замер отдельно от GPU; его нельзя считать FPS консоли.
var main
func _init(): call_deferred("start")
func start():
 main = load("res://src/main.tscn").instance()
 get_root().add_child(main)
 main.set_process(false)
 main.menu.queue_free()
 main.menu = null
 main._start_play(0, 0)
 main._apply()
 var logic = 0
 var sound = 0
 for _i in range(60):
  var start_us = OS.get_ticks_usec()
  main._step_game()
  logic += OS.get_ticks_usec() - start_us
  start_us = OS.get_ticks_usec()
  main.snd.step()
  sound += OS.get_ticks_usec() - start_us
 print("BENCH logic_ms=", logic / 60000.0, " sound_ms=", sound / 60000.0)
 quit()
