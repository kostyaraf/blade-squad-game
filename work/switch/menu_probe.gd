extends SceneTree
var main
var ticks = 0
var errors = 0
func _init(): call_deferred("start")
func start():
 main = load("res://src/main.tscn").instance()
 get_root().add_child(main)
 main.set_process(false)
func _idle(_dt):
 ticks += 1
 if main == null: return false
 main.pads[0].handed = 4 if ticks in [20, 40] else (16 if ticks == 60 else 0)
 main._process(1.0 / 60.0)
 if ticks == 10:
  if main.bg.visible: errors += 1
  if main.snd.made != 0: errors += 1
  for label in main.menu._rows:
   if label.get_font("font").get_string_size(label.text).x <= 0: errors += 1
  screenshot("root-menu")
 if ticks == 55 and main.menu.at != 2: errors += 1
 if ticks == 90:
  if main.menu != null or main.pb3 == null: errors += 1
  if main.bg.visible: errors += 1
  screenshot("pb3-menu")
  print("MENU PROBE: ", "PASS" if errors == 0 else "FAIL", " errors=", errors)
  quit(0 if errors == 0 else 1)
 return false
func screenshot(name_):
 var img = get_root().get_texture().get_data()
 img.flip_y()
 img.save_png("user://switch-check-" + name_ + ".png")
