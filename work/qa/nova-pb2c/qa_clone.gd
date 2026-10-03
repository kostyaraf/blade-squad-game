extends RefCounted
## QA helper: deep copy of a running game (Pb3Session and everything it owns)
## so a search can branch from a moment instead of replaying from the entry.
## Only for tests; the game itself never uses it.

static var _shells := {}
static var _is_shell := {}


static func _shell(script: Script) -> Object:
	if _is_shell.has(script.get_instance_id()):
		script = script.get_base_script()
	var key := script.get_instance_id()
	if not _shells.has(key):
		var sc := GDScript.new()
		var base: String = script.resource_path
		sc.source_code = "extends \"%s\"\nfunc _init() -> void:\n\tpass\n" % base
		sc.reload()
		_shells[key] = sc
		_is_shell[sc.get_instance_id()] = true
	return _shells[key].new()


static func copy(o: Object) -> Object:
	var memo := {}
	return _obj(o, memo)


static func _obj(o: Object, memo: Dictionary) -> Object:
	if o == null:
		return null
	var id := o.get_instance_id()
	if memo.has(id):
		return memo[id]
	var sc: Script = o.get_script()
	if sc == null or not (o is RefCounted) or (sc.resource_path == "" and not _is_shell.has(sc.get_instance_id())):
		memo[id] = o
		return o
	var n := _shell(sc)
	memo[id] = n
	for p in o.get_property_list():
		if not (p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		n.set(p.name, _val(o.get(p.name), memo))
	return n


static func _val(v: Variant, memo: Dictionary) -> Variant:
	match typeof(v):
		TYPE_OBJECT:
			return _obj(v, memo)
		TYPE_ARRAY:
			var a: Array = v
			var b: Array = a.duplicate(false)
			for i in range(a.size()):
				var t := typeof(a[i])
				if t == TYPE_OBJECT or t == TYPE_ARRAY or t == TYPE_DICTIONARY or t >= TYPE_PACKED_BYTE_ARRAY or t == TYPE_CALLABLE:
					b[i] = _val(a[i], memo)
			return b
		TYPE_DICTIONARY:
			var d: Dictionary = v
			var e: Dictionary = d.duplicate(false)
			for k in d:
				e[k] = _val(d[k], memo)
			return e
		TYPE_CALLABLE:
			var c: Callable = v
			if c.is_null() or c.is_custom():
				return c
			return Callable(_obj(c.get_object(), memo), c.get_method())
		TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, \
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY, \
		TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY, TYPE_PACKED_COLOR_ARRAY, \
		TYPE_PACKED_VECTOR4_ARRAY:
			return v.duplicate()
	return v
