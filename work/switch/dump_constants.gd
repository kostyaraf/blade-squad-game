extends SceneTree
func _initialize():
 var constants = {}
 for item in ProjectSettings.get_global_class_list():
  if not item.path.begins_with("res://src/"): continue
  var script = load(item.path)
  var values = {}
  for name in script.get_script_constant_map():
   var v = script.get_script_constant_map()[name]
   if v is int or v is String or v is bool or v is float or v is Array or v is Dictionary:
    values[name] = var_to_str(v)
  constants[item.class] = values
 var output = ""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--output="): output = arg.substr(9)
 if output == "":
  quit(2)
  return
 var f = FileAccess.open(output, FileAccess.WRITE)
 f.store_string(JSON.stringify(constants))
 quit()
