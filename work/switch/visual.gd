extends SceneTree
var main
var count = 0
var mode = "pb3"
func _init():
 for arg in OS.get_cmdline_args():
  if arg.begins_with('--mode='): mode = arg.substr(7)
 call_deferred("start")
func start():
 main = load("res://src/main.tscn").instance()
 get_root().add_child(main)
 main.set_process(false)
func _idle(_dt):
 count += 1
 if main == null: return false
 if count == 10:
  if mode == "pb2":
   main.menu.queue_free()
   main.menu = null
   main._start_play(0, 0)
   main._apply()
   main._snd_use("pb2")
  elif mode == "sol":
   main.menu.queue_free()
   main.menu = null
   main._load("sol", 0, 0)
   main._start_sol()
   main._apply()
   main._snd_use("sol")
  else:
   main._menu_took("pb3")
 if mode == "pb3":
  if count in [20, 30]: main.pads[0].handed = 16
  elif count < 35: main.pads[0].handed = 0
 if count > 40:
  main.pads[0].handed = 1 | (128 if count % 40 < 5 else 0) | (64 if count % 15 < 4 else 0)
 main._process(1.0 / 60.0)
 if count == 180:
  var img = get_root().get_texture().get_data()
  img.flip_y()
  img.save_png("user://switch-check-" + mode + ".png")
  print("VISUAL COMPLETE: ",mode)
  quit()
 return false
