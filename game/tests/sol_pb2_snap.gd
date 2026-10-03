extends RefCounted
## Generic deep snapshot/restore of script-variable state of RefCounted graphs.
const SKIP := {"_types":1,"_anims":1,"_anims3":1,"_groups":1,"_hit_pic":1,"object_groups":1,"_quads":1,"_data":1,"_cells":1,"props":1,"alt":1,"_metatile":1,"_buf":1,"room_group":1}
static var BIG := 3000
static var skipped := {}
static var _cache := {}
static func _names(o: Object) -> Array:
	var sc = o.get_script()
	var id: int = sc.get_instance_id()
	if not _cache.has(id):
		var a := []
		for p in o.get_property_list():
			if (int(p.usage) & 4096) != 0:
				a.append(p.name)
		_cache[id] = a
	return _cache[id]

static func take(root: Object) -> Array:
	var seen := {}
	var queue: Array = [root]
	var out: Array = []
	seen[root.get_instance_id()] = true
	while not queue.is_empty():
		var o: Object = queue.pop_back()
		var props := {}
		for pn in _names(o):
			if SKIP.has(pn):
				continue
			var v = o.get(pn)
			var t := typeof(v)
			# packed bytes are cheap to copy and hold the breakable map (tiles)
			if (t == TYPE_ARRAY or t == TYPE_DICTIONARY or t > TYPE_PACKED_BYTE_ARRAY) and v.size() > BIG:
				if not skipped.has(pn):
					skipped[pn] = v.size()
				continue
			props[pn] = _cp(v, seen, queue)
		out.append([o, props])
	return out

static func _cp(v, seen: Dictionary, queue: Array):
	match typeof(v):
		TYPE_ARRAY:
			var a: Array = v.duplicate(false)
			for i in range(a.size()):
				var e = a[i]
				a[i] = _cp(e, seen, queue)
			return a
		TYPE_DICTIONARY:
			var d: Dictionary = v.duplicate(false)
			for k in d.keys():
				var e = d[k]
				d[k] = _cp(e, seen, queue)
			return d
		TYPE_OBJECT:
			if v != null and is_instance_valid(v) and v is RefCounted and v.get_script() != null:
				var id: int = v.get_instance_id()
				if not seen.has(id):
					seen[id] = true
					queue.append(v)
			return v
	if typeof(v) >= TYPE_PACKED_BYTE_ARRAY:
		return v.duplicate()
	return v

static func put(snap: Array) -> void:
	for item in snap:
		var o: Object = item[0]
		var props: Dictionary = item[1]
		for name in props:
			var cur = o.get(name)
			var nv = _merge(cur, props[name])
			if typeof(nv) != typeof(cur) or not is_same(nv, cur):
				o.set(name, nv)

## Write saved into cur, keeping the identity of containers and packed arrays
## (the game aliases rows between objects).  Returns the value to store.
static func _merge(cur, saved):
	var t := typeof(saved)
	if t == TYPE_ARRAY:
		if typeof(cur) != TYPE_ARRAY:
			return _cp(saved, {}, [])
		var a: Array = cur
		a.resize(saved.size())
		for i in range(saved.size()):
			a[i] = _merge(a[i], saved[i])
		return a
	if t == TYPE_DICTIONARY:
		if typeof(cur) != TYPE_DICTIONARY:
			return _cp(saved, {}, [])
		var d: Dictionary = cur
		for k in d.keys():
			if not saved.has(k): d.erase(k)
		for k in saved.keys():
			d[k] = _merge(d.get(k), saved[k])
		return d
	if t >= TYPE_PACKED_BYTE_ARRAY:
		if typeof(cur) == t and cur.size() == saved.size() and saved.size() <= 96:
			for i in range(saved.size()):
				cur[i] = saved[i]
			return cur
		return saved.duplicate()
	return saved
