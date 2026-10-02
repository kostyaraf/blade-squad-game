extends SceneTree
## Diagnostics placed on isolated belts; not a room-completion certificate.
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		if failures < 20: print("FAIL: ",label)
		failures += 1
class Belt extends Pb2Level:
	var belt_kind := 0x87
	func _init() -> void:
		super(-1,-1)
		width_tiles = 128
		height_tiles = 30
	func class_byte(_x: int, y: int) -> int:
		return 0x80 if y >= 128 else 0
	func terrain_at(_x: int, y: int) -> int:
		return belt_kind if y >= 128 else 0
func walk(kind: int, hero: int, pad: int) -> int:
	var floor := Belt.new()
	floor.belt_kind = kind
	if hero == 1:
		var h := SolPlayer.new(Pb2AsSol.new(floor))
		h.place(200<<4,112<<4)
		h.timer = 112
		for _f in range(20): h.step(pad)
		check(h.y==112<<4,'Sol walk stays on floor')
		return h.x<<4
	var h := Pb2Player.new(floor)
	h.place(160,143,0)
	for f in range(20): h.step(pad,pad if f==0 else 0,0)
	check(h.y==143<<8,'Nova walk stays on floor')
	return h.x

func _initialize() -> void:
	call_deferred('run')
func run() -> void:
	var cases: Array = JSON.parse_string(FileAccess.get_file_as_string(OS.get_cmdline_user_args()[0]))
	for case in cases:
		var lv := Pb2Level.new(int(case.stage),int(case.area))
		var w := Pb2Objects.new(lv)
		w.came = int(case.stage)
		w.area = int(case.area)
		var initial: Array = case.rows[0]
		w.frame = int(initial[1])
		w.storm = int(initial[3])
		for row in case.rows.slice(1):
			var turns := (int(row[1])-w.frame)&255
			for _i in range(turns):
				w.frame = (w.frame+1)&255
				w.step_colour(int(row[4]) != 0)
			check(w.storm == int(row[3]),'NES clock '+str([case.stage,case.area,row[0],w.storm,row[3]]))
			check(lv.background_banks(w.storm)[2] == int(row[2])*2,
					'NES CHR bank '+str([case.stage,case.area,row[0]]))
	# Every real area has valid phases; frozen bit preserves the selected bank.
	for stage in range(7):
		var count: int = [7,8,7,7,10,14,10][stage]
		for area in range(count):
			var lv := Pb2Level.new(stage,area)
			var original := lv.banks.duplicate()
			for phase in range(3):
				check(lv.background_banks(phase) == lv.background_banks(phase|128),'freeze keeps CHR')
			check(original == lv.banks,'static banks unmodified')
	# Actual room surfaces must remain solid AND carry; inspect all cells.
	var room := Pb2Level.new(0,2)
	var adapted := Pb2AsSol.new(room)
	var found := {}
	for y in range(0,room.height_tiles*8,16):
		for x in range(0,room.width_tiles*8,16):
			var terrain := room.terrain_at(x,y)
			if terrain in [0x87,0x88]:
				found[terrain] = true
				check(adapted.collision_at(x,y)==(0x16 if terrain==0x87 else 0x17),'solid belt cell')
	check(found.size()==2,'room includes both belt directions')
	# Native Solbrain controller must stand on a belt and move half a pixel/tick.
	for kind in [0x87,0x88]:
		var floor := Belt.new()
		floor.belt_kind = kind
		var level := Pb2AsSol.new(floor)
		var h := SolPlayer.new(level)
		h.place(200<<4,112<<4)
		h.timer = 112
		for _f in range(20): h.step(0)
		check(h.x == (200<<4)+(160 if kind==0x87 else -160),'Sol belt drift '+str(kind)+' '+str(h.x))
		check(h.y == 112<<4,'Sol belt supports feet')
		# Once airborne, the belt underneath cannot change his horizontal speed.
		var before := h.x
		h.step(Pad.A)
		var after := h.x
		h.step(Pad.A)
		check(h.x == after and h.y < 112<<4,'no airborne belt drag '+str([before,after,h.x]))
	for hero in [0,1]:
		for pad in [0,Pad.LEFT,Pad.RIGHT]:
			var plain := walk(0,hero,pad)
			for kind in [0x87,0x88]:
				check(walk(kind,hero,pad)-plain==(2560 if kind==0x87 else -2560),
						'with/against belt '+str([hero,pad,kind]))
	# PB3 uses the HOST clock for BOTH sheets, including a solo guest.
	for heroes in [[0],[1],[0,1]]:
		var s := Pb3Session.new(heroes)
		s.at = 2
		s.enter()
		var draw := Pb3Draw.new(s.two)
		var phases := {}
		for _f in range(24):
			s.advance(s.tick,[0] if heroes.size()==1 else [0,0])
			draw.after_step(s.gear)
			phases[draw.banks[2]] = true
			check(draw.banks.slice(0,4)==s.two.pb2v.background_banks(s.two.host_pb2.storm),'host render clock')
		check(phases.size()==3,'all phases rendered '+str(heroes))
		var phase := s.two.host_pb2.storm
		var words: Array = [Pad.START] if heroes.size()==1 else [Pad.START,0]
		s.advance(s.tick,words)
		for f in range(24): s.advance(s.tick,[0] if heroes.size()==1 else [0,0])
		check(s.two.host_pb2.storm == phase,'equipment menu freezes animation')
		s.leave()
	print('%d of %d environment checks failed'%[failures,checks])
	quit(1 if failures else 0)
