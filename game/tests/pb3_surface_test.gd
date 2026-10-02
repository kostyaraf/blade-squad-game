extends SceneTree
## Actual map cells, but placed controllers: proves surfaces, not completion.
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		if failures < 15: print('FAIL: ',label)
		failures += 1
class Surface extends SolLevel:
	var code := 0
	func _init() -> void:
		super(-1)
		camera = {"x_min":0,"x_end":65535,"y_min":0,"y_end":65535}
	func collision_at(_x: int, _y: int) -> int: return code
func _initialize() -> void:
	call_deferred('run')
func run() -> void:
	var fake := Surface.new()
	var adapter := SolAsPb2.new(fake)
	for code in range(32):
		fake.code = code
		var expected := 4 if code==13 else 0x87 if code==22 else 0x88 if code==23 else 0
		check(adapter.terrain_at(128,128)==expected,'surface meaning '+str(code))
		check(adapter.class_byte(128,128)==(128 if code>=16 else 0),'independent solidity '+str(code))
	# Scan all 20 level maps: only top surfaces with body clearance and room
	# on both sides qualify for the short drift comparison.
	var sites := []
	for stage in range(20):
		var level := SolLevel.new(stage)
		var foreign := SolAsPb2.new(level)
		var seen := {}
		for y in range(32,4096,16):
			for x in range(32,4096-32,16):
				var code := level.collision_at(x,y)
				if code not in [22,23] or seen.has(code): continue
				if x-32 <= int(level.camera.x_min)>>4 or x+32 >= int(level.camera.x_end)>>4: continue
				var clear := true
				for dx in [-16,0,16]:
					clear = clear and level.collision_at(x+dx,y)==code
					for dy in [-16,-32,-48]: clear = clear and level.collision_at(x+dx,y+dy)==0
				if not clear: continue
				seen[code] = true
				var direction := 1 if code==22 else -1
				foreign.cam_y = y-128
				var nova := Pb2Player.new(foreign)
				nova.place(128,143,x+8-128)
				var sol := SolPlayer.new(level)
				sol.place((x+8)<<4,(y-16)<<4)
				sol.timer = 112
				for _f in range(20):
					nova.step(0,0,x+8-128)
					sol.step(0)
				check(nova.x==(128<<8)+direction*2560,'Nova native belt '+str([stage,x,y,code,nova.x]))
				check(sol.x==((x+8)<<4)+direction*160,'Sol native belt '+str([stage,x,y,code,sol.x]))
				check(nova.y==143<<8 and sol.y==(y-16)<<4,'both stay on real floor')
				sites.append([stage,x+8,y,code])
	check(sites.size()>=4,'multiple real belt sites exercised')
	print('Real belt sites: ',sites)
	print('%d of %d surface checks failed'%[failures,checks])
	quit(1 if failures else 0)
