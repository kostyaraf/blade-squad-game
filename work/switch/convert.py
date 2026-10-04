#!/usr/bin/env python3
"""Generate an isolated Godot 3 homebrew project from the Godot 4 sources."""
from pathlib import Path
import re, shutil, json, argparse, hashlib
ROOT=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source',type=Path,default=ROOT/'game')
SRC=parser.parse_args().source.resolve()
OUT=ROOT/'build/switch-project'
TOK=re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*|\b[A-Za-z_]\w*\b')
def names(text, changes):
 return TOK.sub(lambda m: changes.get(m[0],m[0]) if not m[0].startswith(('"',"'",'#')) else m[0], text)

def method(text, name, replacement):
 # Move a method receiver into the first argument of a compatibility function.
 pattern=re.compile(r'\.'+name+r'\(')
 pos=0
 while (m:=pattern.search(text,pos)):
  end=m.start(); start=end-1; depth=0
  while start>=0:
   c=text[start]
   if c in ')]': depth+=1
   elif c in '([':
    if depth==0: break
    depth-=1
   elif depth==0 and not (c.isalnum() or c in '_.'): break
   start-=1
  start+=1
  receiver=text[start:end]
  if not receiver: pos=m.end();continue
  comma='' if text[m.end():].lstrip().startswith(')') else ', '
  sub=f'{replacement}({receiver}{comma}'
  text=text[:start]+sub+text[m.end():]
  pos=start+len(sub)
 return text

files={p.name:p.read_text() for p in (SRC/'src').glob('*.gd')}
source_hashes={str(p.relative_to(SRC)):hashlib.sha256(p.read_bytes()).hexdigest() for p in SRC.rglob('*') if p.is_file() and '.godot' not in p.parts}
classes={re.search(r'^class_name (\w+)',s,re.M)[1]:n for n,s in files.items() if re.search(r'^class_name (\w+)',s,re.M)}
# Test entry points are not included in the shipping menu. Keep runtime functions
# and fields; validation uses a separate deterministic harness.
s=files['main.gd']
chunks=re.split(r'(?=^(?:static )?func )',s,flags=re.M)
main=chunks[0]
for chunk in chunks[1:]:
 name=re.match(r'(?:static )?func (\w+)',chunk)[1]
 if name=='_ready':
  main+='func _ready() -> void:\n\tpads = [Pad.player_one(), Pad.player_two()]\n\t_snd_raise()\n\tbg.z_index = -1\n\t_start_menu()\n\n'
 elif name.startswith('_run_') or 'func(' in chunk:
  # Preserve any top-level fields that follow a function.
  lines=chunk.splitlines(True)
  start=next((i for i,l in enumerate(lines[1:],1) if re.match(r'^(?:var|const|class|signal) ',l)),len(lines))
  main+=''.join(lines[start:])
 else: main+=chunk
# Retain only functions reachable from the interactive game.
funcs={}; spans=[]
for m in re.finditer(r'^(?:static )?func (\w+)\(',main,re.M):
 end=m.end()
 newline=main.index('\n',end)+1
 end=newline
 for line in main[newline:].splitlines(True):
  if line.strip() and not line.startswith(('\t','#')): break
  end+=len(line)
 funcs[m[1]]=main[m.start():end]
 spans.append((m.start(),end,m[1]))
reachable={'_ready','_input','_process','_draw','_exit_tree','_menu_took'}
while True:
 more=set()
 for key in reachable:
  more.update(set(re.findall(r'\b_\w+\b',funcs.get(key,''))) & funcs.keys())
 if more <= reachable: break
 reachable |= more
for start,end,name in reversed(spans):
 if name not in reachable: main=main[:start]+main[end:]
files['main.gd']=main
# Static storage lives in an autoload; Godot 3 has no static variables.
state=[]; statics={}
for filename,s in files.items():
 cls=re.search(r'^class_name (\w+)',s,re.M)
 if not cls: continue
 cls=cls[1]; fields={}
 for m in re.finditer(r'^static var (\w+)([^\n]*)',s,re.M):
  name,tail=m[1],m[2]
  value=tail.split('=',1)[1].split('#')[0].strip() if '=' in tail else ('{}' if 'Dictionary' in tail else 'null')
  fields[name]=f'NXState.{cls}_{name}'
  state.append(f'var {cls}_{name} = {value}\n')
 statics[cls]=fields
 s=re.sub(r'^static var [^\n]*\n','',s,flags=re.M)
 # All these field names are class fields; avoid qualified members and literal text.
 def replace(m):
  word=m[0]
  if word in fields and (m.start()==0 or s[m.start()-1]!='.'):
   return fields[word]
  return word
 s=TOK.sub(replace,s)
 files[filename]=s
for filename,s in files.items():
 for cls,fields in statics.items():
  for field,new in fields.items(): s=re.sub(r'\b'+cls+r'\.'+field+r'\b',new,s)
 files[filename]=s
files['nx_state.gd']='extends Node\nvar script_cache = {}\n'+''.join(state)

mapping={'RefCounted':'Reference','Variant':'Variant','Vector2i':'NXVec','Rect2i':'Rect2','Callable':'NXCallable',
 'PackedByteArray':'Array','PackedInt32Array':'Array','PackedInt64Array':'Array','PackedFloat32Array':'Array','PackedFloat64Array':'Array','PackedColorArray':'Array','PackedStringArray':'Array',
 'Sprite2D':'Sprite','Texture2D':'Texture','RenderingServer':'VisualServer',
 'HORIZONTAL_ALIGNMENT_CENTER':'Label.ALIGN_CENTER', 'KEY_ENTER':'KEY_ENTER',
 'JOY_BUTTON_A':'JOY_XBOX_A','JOY_BUTTON_X':'JOY_XBOX_X','JOY_BUTTON_BACK':'JOY_SELECT','JOY_BUTTON_START':'JOY_START',
 'JOY_BUTTON_DPAD_UP':'JOY_DPAD_UP','JOY_BUTTON_DPAD_DOWN':'JOY_DPAD_DOWN','JOY_BUTTON_DPAD_LEFT':'JOY_DPAD_LEFT','JOY_BUTTON_DPAD_RIGHT':'JOY_DPAD_RIGHT',
 'JOY_AXIS_LEFT_X':'JOY_AXIS_0','JOY_AXIS_LEFT_Y':'JOY_AXIS_1',
 'mini':'NXCompat.min_i','maxi':'NXCompat.max_i','minf':'min','maxf':'max','absi':'NXCompat.abs_i','absf':'abs','clampi':'NXCompat.clamp_i','clampf':'clamp','signi':'NXCompat.sign_i','signf':'sign',
 'seed':'rng_seed','atan':'atan_table','sign':'sign_byte','unicode_at':'ord_at','queue_redraw':'update','is_empty':'empty','set_shader_parameter':'set_shader_param','get_image':'get_data',
 'add_theme_color_override':'add_color_override','horizontal_alignment':'align','physical_keycode':'physical_scancode','keycode':'scancode',
 'get_cmdline_user_args':'get_cmdline_args'}
OUT.mkdir(parents=True,exist_ok=True)
(OUT/'src').mkdir(exist_ok=True)
shutil.copytree(SRC/'data',OUT/'data',dirs_exist_ok=True)
shutil.copytree(Path(__file__).parent/'fonts',OUT/'fonts',dirs_exist_ok=True)
for filename,s in files.items():
 # Packed integer constructors must preserve their integer coercion.
 s=re.sub(r'\bPacked(?:Byte|Int32|Int64)Array\(', 'NXCompat.ints(',s)
 s=names(s,mapping)
 s=s.replace('@onready','onready')
 s=re.sub(r'^\s*@warning_ignore[^\n]*\n','',s,flags=re.M)
 s=re.sub(r'Array\[[\w]+\]','Array',s)
 # Remove custom class type annotations to break Godot 3 cyclic parser dependencies.
 hints='|'.join(list(classes)+['Variant','NXVec','NXCallable'])
 s=re.sub(r':[ \t]*(?:'+hints+r')(?:\.\w+)?\b','',s)
 s=re.sub(r'[ \t]*->[ \t]*(?:'+hints+r')(?:\.\w+)?\b','',s)
 s=s.replace(':=','=')
 s=s.replace('bg.z_index = -1','pass')
 s=s.replace('ARROWS AND START','D-PAD AND +')
 s=s.replace('ARROWS CHANGE  ENTER NEXT  Z BACK\\nP1 ARROWS Z/X  P2 WASD ;/\'\\nDOWN + JUMP: SLIDE','D-PAD CHANGE  + NEXT  Y BACK\\nB JUMP  Y ATTACK\\nDOWN + B: SLIDE')
 s=re.sub(r'(?m)([^\\\n])\n([ \t]+else\b(?![ \t]*:))',r'\1 \\\n\2',s)
 s=re.sub(r'(signal \w+\([^\n]*)',lambda m: re.sub(r': *\w+','',m[0]),s)
 s=re.sub(r'func _init\(([^\n]*)\) -> void:\n\tsuper\(([^\n]*)\)',r'func _init(\1).(\2):\n\tpass',s)
 s=s.replace('super.', '.')
 # Godot 3 accepts `not value in ...`, but not Godot 4's `value not in ...`.
 s=re.sub(r'\b(\w+(?:\.\w+)*) not in\b', r'not \1 in', s)
 s=re.sub(r'^(\t+)(\d+): ([^;\n]+); ([^\n]+)',r'\1\2:\n\1\t\3\n\1\t\4',s,flags=re.M)
 # Translate Godot 4 property blocks into Godot 3 setget accessors.
 properties=[]
 pattern=re.compile(r'^var (\w+)([^\n]*):\n((?:\t[^\n]*\n|\n)+)',re.M)
 def prop(m):
  name, typ, body=m[1],m[2],m[3]
  getters=re.search(r'\tget:\n((?:\t\t[^\n]*\n|\n)+)',body)
  setters=re.search(r'\tset\((\w+)\):\n((?:\t\t[^\n]*\n|\n)+)',body)
  setter='_set_'+name if setters else ''
  getter='_get_'+name if getters else ''
  if getters: properties.append('func '+getter+'():\n'+re.sub(r'^\t','',getters[1],flags=re.M)+'\n')
  if setters: properties.append('func '+setter+'('+setters[1]+'):\n'+re.sub(r'^\t','',setters[2],flags=re.M)+'\n')
  return 'var '+name+typ+' setget '+setter+', '+getter+'\n'
 s=pattern.sub(prop,s)+'\n'+''.join(properties)
 s=s.replace('NXVec.ZERO','NXVec.new(0, 0)').replace('NXVec(', 'NXVec.new(')
 s=s.replace('NXCallable()', 'NXCallable.new()')
 s=s.replace('FileAccess.', 'NXCompat.').replace('DirAccess.remove_absolute','NXCompat.remove_file')
 s=s.replace('JSON.parse_string','parse_json').replace('JSON.stringify','to_json')
 s=s.replace('Image.create_from_data','NXCompat.image_from_data').replace('Image.create(', 'NXCompat.image(')
 s=s.replace('ImageTexture.create_from_image','NXCompat.texture')
 s=s.replace('Color.html(', 'Color(').replace('Color.BLACK','Color.black').replace('Color.WHITE','Color.white')
 s=s.replace('await VisualServer.frame_post_draw','yield(VisualServer, "frame_post_draw")')
 s=s.replace('menu.picked.connect(_menu_took)','menu.connect("picked", self, "_menu_took")')
 s=s.replace('picked.emit(', 'emit_signal("picked", ')
 s=re.sub(r'(?m)^(\s*\w+(?:\.\w+)*\.walk = )(_\w+)$',r'\1NXCallable.new(self, "\2")',s)
 s=s.replace('two._break_sol_terrain', 'NXCallable.new(two, \"_break_sol_terrain\")')
 s=s.replace('_arm_spent.bind(i)','NXCallable.new(self, "_arm_spent", [i])')
 s=s.replace('.call(', '.invoke(') # only callable uses in this project
 s=s.replace('.update(img)', '.set_data(img)')
 s=re.sub(r'\b(map_tex|pal2_tex|oam_tex|oam2_tex)\.update\(',r'\1.set_data(',s)
 for old,new in [('set_shader_param','shader_param'),('resize','resize_array'),('fill','fill_array'),('slice','slice_array'),('decode_s16','decode_s16'),('encode_s16','encode_s16'),('append_array','append_array'),('join','join_array'),('add_theme_font_size_override','font_size')]:
  s=method(s,old,'NXCompat.'+new)
 # Pure integer two-dimensional coordinates (Godot 3 has no Vector2i).
 s=s.replace('scroll - origin','scroll.sub(origin)').replace('scroll += d','scroll = scroll.add(d)')
 s=re.sub(r'Vector2\((scroll|at)\)',r'\1.to_vector()',s)
 s=s.replace('Vector2(select.road())','select.road().to_vector()')
 s=s.replace('Vector2(scroll.sub(origin))','scroll.sub(origin).to_vector()')
 s=s.replace('Vector2(scroll if paged else scroll.sub(origin))','(scroll if paged else scroll.sub(origin)).to_vector()')
 s=s.replace('Vector2(scroll if level_pb2.vertical else scroll.sub(origin))','(scroll if level_pb2.vertical else scroll.sub(origin)).to_vector()')
 s=s.replace('Vector2(scroll if (world != null and level_pb2 != null and level_pb2.vertical) else scroll.sub(origin))','(scroll if (world != null and level_pb2 != null and level_pb2.vertical) else scroll.sub(origin)).to_vector()')
 if filename=='pb3_list.gd':
  s=s.replace('var spot = home','var spot = NXVec.new(home)')
 if filename=='pb3_pair.gd':
  s=re.sub(r'mid \+= ([^\n]+)',r'mid = mid.add(\1)',s)
  s=re.sub(r'mid /= ([^\n]+)',r'mid = mid.div(\1)',s)
  s=s.replace('at + NXVec.new(dx, dy) * 16','at.add(NXVec.new(dx * 16, dy * 16))')
  s=s.replace('var at = before','var at = NXVec.new(before)').replace('var next = at','var next = NXVec.new(at)')
  s=s.replace('wanted[axis] - at[axis]','wanted.axis(axis) - at.axis(axis)')
  s=s.replace('next[axis] += delta','next.set_axis(axis, next.axis(axis) + delta)')
  s=s.replace('push == NXVec.new(0, 0)','push.is_zero()').replace('_solid(w + push)','_solid(w.add(push))')
 if filename in ('pb3_board.gd','pb3_menu.gd'):
  s=names(s,{'position':'rect_position'})
  s=re.sub(r'\bsize =','rect_size =',s)
 if filename=='sol_sprites.gd':
  s=s.replace('oam[i] = HIDDEN','oam[i] = '+json.loads((ROOT/'build/switch-tools/constants.json').read_text())['SolSprites']['HIDDEN'])
 if filename=='pad.gd':
  s=s.replace('Input.is_physical_key_pressed','Input.is_physical_key_pressed')
 # Image pixel access must be locked in Godot 3. Compatibility constructors lock.
 s=s.replace('native, Rect2(0, 0, native.get_width(), native.get_height()), NXVec.new(0, 0)', 'native, Rect2(0, 0, native.get_width(), native.get_height()), Vector2.ZERO')
 s=s.replace('rect, NXVec.new(0, 0)', 'rect, Vector2.ZERO').replace('rect, NXVec.new(0, 1)', 'rect, Vector2(0, 1)')
 # Avoid quoted identifiers and comments influencing the rewrites above.
 # Inline immutable exported constants and resolve cross-class methods lazily,
 # avoiding cyclic script dependencies rejected by the older parser.
 constants=json.loads((ROOT/'build/switch-tools/constants.json').read_text())
 def member(m):
  cls,key=m[1],m[2]
  if key in constants.get(cls,{}): return '('+constants[cls][key]+')'
  return 'NXCompat.script("res://src/'+classes[cls]+'").'+key
 s=re.sub(r'\b('+'|'.join(classes)+r')\.(\w+)',member,s)
 (OUT/'src'/filename).write_text(s)
for p in Path(__file__).parent.glob('nx_*.gd'):
 shutil.copy2(p,OUT/'src'/p.name)
shader=(SRC/'src/nes_bg.gdshader').read_text().replace(' : filter_nearest','')
# Godot 3 shaders do not expose uniform arrays.
shader_arrays={}
def uniforms(m):
 name,n=m[1],int(m[2]); shader_arrays[name]=n
 return '\n'.join('uniform int %s_%d;'%(name,i) for i in range(n))
shader=re.sub(r'uniform int (\w+)\[(\d+)\];',uniforms,shader)
helpers=''
for name,n in shader_arrays.items():
 shader=re.sub(r'\b'+name+r'\[([^\]]+)\]',name+'_get(\\1)',shader)
 helpers+='int '+name+'_get(int i) {\n'
 for i in range(n-1): helpers+='if (i == %d) return %s_%d;\n'%(i,name,i)
 helpers+='return %s_%d;\n}\n'%(name,n-1)
shader=shader.replace('void fragment()',helpers+'\nvoid fragment()')
# Helpers must precede all functions that read these uniforms.
i=shader.find('int bg_bank(')
if i>=0:
 shader=shader.replace(helpers,''); shader=shader[:i]+helpers+'\n'+shader[i:]
shader=shader.replace('FRAGCOORD.xy','pixel').replace('FRAGCOORD.x','pixel.x').replace('FRAGCOORD.y','pixel.y')
shader=shader.replace('void fragment() {','void fragment() {\n    vec2 pixel = UV * vec2(256.0, 240.0);')
(OUT/'src/nes_bg.shader').write_text(shader)
scene=(SRC/'src/main.tscn').read_text().replace('format=3','format=2').replace('.gdshader','.shader').replace('offset_right','margin_right').replace('offset_bottom','margin_bottom')
scene=re.sub(r'(ExtResource|SubResource)\("(\d+)"\)',r'\1( \2 )',scene)
scene=re.sub(r'id="(\d+)"',r'id=\1',scene)
(OUT/'src/main.tscn').write_text(scene)
registry=''
if (OUT/'project.godot').exists():
 old=(OUT/'project.godot').read_text()
 m=re.search(r'(_global_script_classes=.*?)(?=\n\[application\])',old,re.S)
 if m: registry=m[1]
(OUT/'project.godot').write_text('config_version=4\n'+registry+''' 

[application]
config/name="PB3"
run/main_scene="res://src/main.tscn"
config/description="PB3 homebrew"
config/use_custom_user_dir=true
config/custom_user_dir_name="PB3/saves"

[autoload]
NXState="*res://src/nx_state.gd"

[display]
window/size/width=256
window/size/height=240
window/size/test_width=768
window/size/test_height=720
window/stretch/mode="viewport"
window/stretch/aspect="keep"

[rendering]
quality/driver/driver_name="GLES3"
textures/default_filters/use_nearest_mipmap_filter=false
''')
(OUT/'source-manifest.json').write_text(json.dumps(source_hashes,indent=2)+'\n')
print(OUT)
