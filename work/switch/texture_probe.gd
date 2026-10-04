extends SceneTree

# Проверка всех 256 значений четырёх каналов до и после обновления текстуры.
var compat
var tex
var source
var ticks = 0
var phase = 0
var errors = 0

func _init():
 call_deferred("start")

func bytes_for(i, offset):
 return [(i + offset) % 256, (i * 37 + offset) % 256,
   (255 - i + offset) % 256, (i * 91 + offset) % 256]

func make_image(offset):
 var img = compat.image(256, 1, false, Image.FORMAT_RGBA8)
 for i in range(256):
  var v = bytes_for(i, offset)
  img.set_pixel(i, 0, Color(v[0] / 255.0, v[1] / 255.0,
    v[2] / 255.0, v[3] / 255.0))
 return img

func start():
 compat = load("res://src/nx_compat.gd")
 source = make_image(0)
 tex = compat.texture(source)
 var shader = Shader.new()
 shader.code = """shader_type canvas_item;
render_mode unshaded;
uniform sampler2D data;
uniform int offset;
void fragment() {
 int x = int(UV.x * 256.0);
 ivec4 got = ivec4(texelFetch(data, ivec2(x, 0), 0) * 255.0 + 0.5);
 ivec4 want = ivec4((x + offset) % 256, (x * 37 + offset) % 256,
                  (255 - x + offset) % 256, (x * 91 + offset) % 256);
 COLOR = got == want ? vec4(0.0, 1.0, 0.0, 1.0) : vec4(1.0, 0.0, 0.0, 1.0);
}
"""
 var mat = ShaderMaterial.new()
 mat.shader = shader
 mat.set_shader_param("data", tex)
 mat.set_shader_param("offset", 0)
 var rect = ColorRect.new()
 rect.name = "Probe"
 rect.material = mat
 rect.margin_right = 256
 rect.margin_bottom = 240
 get_root().add_child(rect)

func check_gpu(offset):
 if tex.get_data().get_format() != Image.FORMAT_RGBAF:
  errors += 1
 if source.get_format() != Image.FORMAT_RGBA8:
  errors += 1
 var img = get_root().get_texture().get_data()
 img.lock()
 for i in range(256):
  var c = img.get_pixel(i, 120)
  if c.g < 0.99 or c.r > 0.01: errors += 1
 img.unlock()
 print("TEXTURE PHASE ", offset, ": errors=", errors)

func _idle(_dt):
 ticks += 1
 if ticks == 20:
  check_gpu(0)
  phase = 17
  source = make_image(phase)
  compat.texture_update(tex, source)
  get_root().get_node("Probe").material.set_shader_param("offset", phase)
 if ticks == 40:
  check_gpu(phase)
  print("TEXTURE PROBE: ", "PASS" if errors == 0 else "FAIL")
  quit(0 if errors == 0 else 1)
 return false
