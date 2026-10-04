from pathlib import Path
import subprocess,re,sys
root=Path(__file__).resolve().parents[2]
log=root/'build/switch-check.log'
with log.open('w') as f:
 p=subprocess.Popen([str(root/'build/switch-tools/editor/godot.osx.opt.tools.64'),'--path',str(root/'build/switch-project')]+(['--editor'] if '--editor' in sys.argv else []),stdout=f,stderr=subprocess.STDOUT)
 try:p.wait(timeout=12)
 except subprocess.TimeoutExpired:p.terminate();p.wait(timeout=8)
s=re.sub(r'\x1b\[[0-9;]*m','',log.read_text());seen=set()
for msg,f,n in re.findall(r'SCRIPT ERROR: (.*?)\n\s*at: (?:GDScript::reload|\w+) \(res://src/(.*?):(\d+)\)',s):
 if (f,n) in seen:continue
 seen.add((f,n));lines=(root/'build/switch-project/src'/f).read_text().splitlines()
 print(f,n,msg,'\n ',lines[int(n)-1] if int(n)<=len(lines) else 'EOF')
for line in s.splitlines():
 if 'SHADER ERROR' in line or line.startswith('ERROR:'): print(line)
print('Unique errors:',len(seen))
