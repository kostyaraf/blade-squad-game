extends SceneTree
func _init(): call_deferred("start")
func start():
 var compat = load("res://src/nx_compat.gd")
 seed(905)
 var checked = 0
 for test in range(8):
  var img = compat.image(64, 2, false, Image.FORMAT_RGBA8)
  for row in range(2):
   for i in range(64):
    var y = int(randi() & 255) if test > 0 else 32
    img.set_pixel(i, row, Color(y / 255.0, i / 255.0,
      int(randi() & 255) / 255.0, int(randi() & 255) / 255.0))
  var raw = img.get_data()
  var queue = compat.oam_scanlines(img).get_data()
  for table in range(2):
   for line in range(240):
    var slot = 0
    for sprite in range(64):
     var source = (table * 64 + sprite) * 4
     var first = int(raw[source]) + 1
     if line >= first and line < first + 16:
      if slot < 8:
       var target = ((table * 256 + line) * 8 + slot) * 4
       for channel in range(4):
        if queue[target + channel] != raw[source + channel]:
         printerr("OAM DIFFERENCE test=",test," line=",line," slot=",slot)
         quit(1); return
       slot += 1
    if slot < 8:
     var target = ((table * 256 + line) * 8 + slot) * 4
     if queue[target] != 247:
      printerr("OAM NONEMPTY SLOT"); quit(1); return
    checked += 1
 print("OAM PROBE: PASS scanlines=", checked)
 quit()
