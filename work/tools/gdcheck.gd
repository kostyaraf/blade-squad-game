extends SceneTree

## Read every script of the game once and say so, or say why not.
##
## Headless Godot does not stop on a script it cannot read: it prints the
## complaint and then waits for a window that will never come, so a sweep that
## calls the engine hangs for its whole fifteen minutes and says nothing.  One
## pass of this before a sweep costs a second and turns that into a line.
##
##     Godot --path game --headless --script res://../work/tools/gdcheck.gd
func _init() -> void:
	var bad := 0
	var dir := DirAccess.open("res://src")
	for name in dir.get_files():
		if not name.ends_with(".gd"):
			continue
		var path := "res://src/" + name
		var script: GDScript = ResourceLoader.load(path, "GDScript",
				ResourceLoader.CACHE_MODE_IGNORE)
		if script == null or not script.can_instantiate():
			# A class that is only ever held by another one still reloads, so
			# what marks the bad ones is the reload itself failing.
			pass
		if script == null:
			print("BAD  ", path)
			bad += 1
			continue
		var err: int = script.reload()
		if err != OK:
			print("BAD  ", path)
			bad += 1
		else:
			print("ok   ", path)
	print(bad, " of the scripts will not read")
	quit(1 if bad else 0)
