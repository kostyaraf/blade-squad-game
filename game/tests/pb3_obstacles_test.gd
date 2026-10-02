extends SceneTree

# Controlled fixtures isolate a wall, moving platform and 16px tunnel.
# The hero controllers and co-op step are the production ones.
class LabFloor extends Pb2Level:
	var tunnel := false
	var material := 0
	func _init() -> void:
		super(0, 0)
		width_tiles = 64
		height_tiles = 32
	func class_byte(px: int, py: int) -> int:
		return 0x80 if py >= 128 or (tunnel and px >= 96 and px < 160 and py < 112) else 0
	func terrain_at(_px: int, _py: int) -> int:
		return material

class WetSol extends SolLevel:
	func _init() -> void:
		super(0)
	func collision_at(_px: int, _py: int) -> int:
		return 0x0D

var checks := 0
var failed := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failed += 1
		print("FAIL ", label)
func lab(kinds: Array, tunnel: bool = false) -> Pb3Pair:
	var pair := Pb3Pair.new(0, 0, 0, kinds)
	var floor := LabFloor.new()
	floor.tunnel = tunnel
	pair.pb2v = floor
	pair.solv = Pb2AsSol.new(floor)
	pair.eye = Pb2Camera.new(floor)
	for i in range(kinds.size()):
		if kinds[i] == 0:
			pair.pb2[i].lvl = floor
		else:
			pair.sol[i] = SolPlayer.new(pair.solv)
	pair.begin([Vector2i(64, 127), Vector2i(64, 127)], true)
	pair.live_session = true
	return pair
func walk(pair: Pb3Pair, pads: Array) -> void:
	pair.pads_now = pads
	pair._walk_them()
func run() -> void:
	for kinds in [[0, 1], [1, 0], [0, 0], [1, 1]]:
		for slot in range(2):
			var pair := lab(kinds)
			pair.host_pb2.solids = [[96, 112, 80, 143]]
			var pads := [0, 0]
			pads[slot] = Pad.RIGHT
			for f in range(70):
				walk(pair, pads)
			check(pair.world_of(slot).x < 96, "wall hero=%d slot=%d x=%d" % [kinds[slot], slot, pair.world_of(slot).x])
			pair.release()
			pair = lab(kinds)
			pair.host_pb2.solids = [[32, 120, 117, 127]]
			pair.place_at(slot, Vector2i(64, 70))
			for f in range(90):
				walk(pair, [0, 0])
			check(pair.world_of(slot).y <= 101 and pair.world_of(slot).y >= 99,
					"platform hero=%d slot=%d feet=%d" % [kinds[slot], slot, pair.world_of(slot).y])
			pair.release()
			pair = lab(kinds, true)
			for f in range(8):
				walk(pair, [0, 0])
			pads = [0, 0]
			pads[slot] = Pad.DOWN | Pad.A | Pad.RIGHT
			walk(pair, pads)
			pads[slot] = Pad.DOWN | Pad.RIGHT
			var sliding := false
			for f in range(90):
				walk(pair, pads)
				if kinds[slot] == 0:
					sliding = sliding or pair.pb2[slot].sub == Pb2Player.SUB_SLIDE
				else:
					sliding = sliding or pair.climbers.has(slot)
			check(sliding and pair.world_of(slot).x >= 168,
					"tunnel hero=%d slot=%d x=%d sliding=%s" % [kinds[slot], slot, pair.world_of(slot).x, sliding])
			pair.release()
	water_translation()
	moving_platforms()
	real_tunnels()
	print("%d of %d obstacle checks failed" % [failed, checks])
	quit(1 if failed else 0)

func moving_platforms() -> void:
	for kinds in [[0, 1], [1, 0], [0, 0], [1, 1]]:
		var pair := lab(kinds)
		var slot: int = 1 if pair.host == 0 else 0
		pair.place_at(slot, Vector2i(64, 100 if kinds[slot] == 0 else 101))
		for f in range(20):
			var box: Array = [33 + f, 121 + f, 116 - f, 126 - f]
			pair.host_pb2.solids = []
			pair.host_pb2.guest_surfaces = [[box, 1, -1]]
			walk(pair, [0, 0])
		var pos: Vector2i = pair.world_of(slot)
		check(absi(pos.x - 84) <= 1 and absi(pos.y - (80 if kinds[slot] == 0 else 81)) <= 1,
				"moving platform hero=%d slot=%d pos=%s" % [kinds[slot], slot, pos])
		pair.release()

func real_tunnels() -> void:
	# Real cartridge map segments found by scanning for floor + 16px gap.
	for entry in [[0,1,72,303,160], [0,2,584,127,672], [2,2,168,127,256], [3,1,72,191,160]]:
		for kinds in [[0,1], [1,0]]:
			var pair := Pb3Pair.new(0, entry[0], entry[1], kinds)
			pair.solv.continuous_vertical = true
			var at := Vector2i(entry[2], entry[3])
			pair.begin([at, at])
			pair.live_session = true
			for f in range(8):
				pair.step([0,0])
			pair.step([Pad.DOWN | Pad.A | Pad.RIGHT, Pad.DOWN | Pad.A | Pad.RIGHT])
			var crossed := [false, false]
			for f in range(90):
				pair.step([Pad.DOWN | Pad.RIGHT, Pad.DOWN | Pad.RIGHT])
				for slot in range(2):
					crossed[slot] = crossed[slot] or (not pair.gone[slot] and pair.world_of(slot).x >= entry[4] - 8)
				if crossed[0] and crossed[1]:
					break
			for slot in range(2):
				check(crossed[slot],
						"real tunnel p%d.%d hero=%d slot=%d end=%s" % [entry[0], entry[1], kinds[slot], slot, pair.world_of(slot)])
			pair.release()

func water_translation() -> void:
	var floor := LabFloor.new()
	floor.material = 4
	var borrowed := Pb2AsSol.new(floor)
	check(borrowed.collision_at(64,64) == Pb2AsSol.WATER and not borrowed.hurts_at(64,64),
			"PB2 water stays water, not a death tile")
	floor.material = 2
	check(borrowed.collision_at(64,64) != Pb2AsSol.WATER and borrowed.hurts_at(64,64),
			"PB2 hazard is not converted to water")
	var source := WetSol.new()
	var level := SolAsPb2.new(source)
	var nova := Pb2Player.new(level)
	nova.place(64,100,0)
	nova.step(0,0,0)
	check(not nova.dead and nova.scale == 0x40, "Nova wades in Solbrain water without dying")
