extends Reference
class_name NXVec
var x: int = 0
var y: int = 0
func _init(a = 0, b = null):
 if b == null and a is Object:
  x = a.x
  y = a.y
 else:
  x = int(a)
  y = int(b) if b != null else 0
func add(b):
 return get_script().new(x + b.x, y + b.y)
func sub(b):
 return get_script().new(x - b.x, y - b.y)
func div(n: int):
 return get_script().new(x / n, y / n)
func is_zero():
 return x == 0 and y == 0
func axis(n: int):
 return x if n == 0 else y
func set_axis(n: int, v: int):
 if n == 0: x = v
 else: y = v
func to_vector():
 return Vector2(x, y)
