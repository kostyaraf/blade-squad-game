extends Reference
class_name NXCompat
const READ = File.READ
const WRITE = File.WRITE
static func open(path, mode):
 if mode == WRITE:
  Directory.new().make_dir_recursive(path.get_base_dir())
 var f = File.new()
 if f.open(path, mode) != OK: return null
 return f
static func file_exists(path):
 return File.new().file_exists(path)
static func get_file_as_string(path):
 var f = open(path, READ)
 if f == null: return ""
 var s = f.get_as_text()
 f.close()
 return s
static func get_file_as_bytes(path):
 var f = open(path, READ)
 if f == null: return PoolByteArray()
 var a = f.get_buffer(f.get_len())
 f.close()
 return a
static func remove_file(path):
 return Directory.new().remove(path)
static func resize_array(a, n):
 var old = a.size()
 a.resize(n)
 for i in range(old, n): a[i] = 0
static func fill_array(a, v):
 for i in range(a.size()): a[i] = v
static func slice_array(a, begin, end = 2147483647):
 var n = a.size()
 if begin < 0: begin = max(0, n + begin)
 if end < 0: end = max(0, n + end)
 if begin >= min(n, end): return []
 return a.slice(begin, min(n, end) - 1)
static func append_array(a, b):
 for v in b: a.append(v)
static func join_array(separator, a):
 return PoolStringArray(a).join(separator)
static func decode_s16(a, i):
 var v = int(a[i]) | (int(a[i + 1]) << 8)
 return v - 65536 if v >= 32768 else v
static func encode_s16(a, i, v):
 a[i] = int(v) & 255
 a[i + 1] = (int(v) >> 8) & 255
static func image(w, h, mip, format_):
 var img = Image.new()
 img.create(w, h, mip, format_)
 img.lock()
 return img
static func image_from_data(w, h, mip, format_, data):
 var img = Image.new()
 img.create_from_data(w, h, mip, format_, PoolByteArray(data))
 img.lock()
 return img
static func texture(img):
 img.unlock()
 var tex = ImageTexture.new()
 tex.create_from_image(img, 0)
 img.lock()
 return tex
static func font_size(label, _key, size_):
 var font = DynamicFont.new()
 font.font_data = load("res://fonts/NotoSansUI_Regular.woff2")
 font.size = size_
 font.use_filter = false
 label.add_font_override("font", font)
static func shader_param(material, name_, value):
 if name_ in ["banks", "banks2", "banks3", "band_at", "band_bank", "bar_banks"]:
  for i in range(value.size()):
   material.set_shader_param(name_ + "_" + str(i), int(value[i]))
 else:
  material.set_shader_param(name_, value)
static func min_i(a: int, b: int) -> int:
 return a if a < b else b
static func max_i(a: int, b: int) -> int:
 return a if a > b else b
static func abs_i(a: int) -> int:
 return -a if a < 0 else a
static func clamp_i(a: int, lo: int, hi: int) -> int:
 return lo if a < lo else (hi if a > hi else a)
static func sign_i(a: int) -> int:
 return -1 if a < 0 else (1 if a > 0 else 0)
static func ints(values = []):
 var out = []
 for v in values: out.append(int(v))
 return out
static func script(path):
 if not NXState.script_cache.has(path):
  NXState.script_cache[path] = load(path)
 return NXState.script_cache[path]
