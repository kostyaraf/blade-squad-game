extends Reference
class_name NXCallable
var target
var method: String
var bound: Array
func _init(obj = null, name_ = "", args = []):
 target = weakref(obj) if obj != null else null
 method = name_
 bound = args
func is_valid():
 return target != null and target.get_ref() != null
func invoke(a = null, b = null, c = null):
 var args = []
 if a != null: args.append(a)
 if b != null: args.append(b)
 if c != null: args.append(c)
 args += bound
 return target.get_ref().callv(method, args)
