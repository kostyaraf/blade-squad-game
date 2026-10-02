extends Pb3List
class_name Pb3Session

## PB3's live lifecycle. Cartridge transitions are described in
## work/re/pb3_session.md; input and rendering stay outside this object.
var tick := 0
var previous: Array[int] = [0, 0]
var message := ""
var armed: Array[int] = []


func _init(heroes: Array) -> void:
	super(heroes)


func leave() -> void:
	if two != null:
		two.release()
	super.leave()


func enter(flow: bool = true) -> bool:
	if not super.enter(flow):
		return false
	gear = Pb3Gear.new(kinds)
	prepare()
	message = ""
	return true


func prepare() -> void:
	two.live_session = true
	if two.game == Pb3Pair.SOL:
		two.host_fade = SolFade.new()
		two.host_fade.table = PackedByteArray(two.solv.palette)
		two.host_fade.out = PackedByteArray(two.solv.palette)
		two.host_fade.at_pace(6) # $F8AD, the native stage palette clock.
	if two.game == Pb3Pair.PB2 and two.pb2v.vertical:
		var level: Pb2AsSol = two.solv
		if not level.continuous_vertical:
			level.continuous_vertical = true
			for i in range(two.who.size()):
				if two.who[i] == Pb3Pair.SOL:
					var h: SolPlayer = two.sol[i]
					h.y = (level.hero_y((h.y + SolPlayer.FOOT_DY) >> 4) << 4) + (h.y & 15) - SolPlayer.FOOT_DY
	armed.clear()
	for _hero in kinds:
		armed.append(-1)
	for i in range(two.who.size()):
		if two.who[i] == Pb3Pair.PB2:
			# $D05D: live heroes start with health and an active sprite slot.
			# The old pilot supplied life externally, hiding this omission.
			if two.game == Pb3Pair.SOL:
				two.things[i].terrain_strike = two._break_sol_terrain
			two.things[i].slots[0][Pb2Objects.F_TYPE] = 1
			two.things[i].slots[0][Pb2Objects.F_LIFE] = 0x10
			if i != two.host:
				if two.game == Pb3Pair.PB2:
					two.guest_row[i][Pb2Objects.F_LIFE] = 0x10
				else:
					two.guest_sol[i].suit = 0x10
		elif i != two.host:
			two.sol[i].pool = two.guest_pool[i]
	two._mirror_them()
	_sync_gear()


## A future authoritative server can feed the same ordered input frames.
## Reject gaps and duplicates before mutating anything.
func advance(frame: int, words: Array) -> String:
	if frame != tick or two == null or words.size() != kinds.size():
		return "rejected"
	for word in words:
		if not word is int or word < 0 or word > 255:
			return "rejected"
	var hits: Array = []
	for i in range(words.size()):
		hits.append(int(words[i]) & ~previous[i])
		previous[i] = int(words[i])
	tick += 1
	gear.step(hits)
	_sync_gear()
	# A menu freezes both players, so its arrows cannot move the other hero.
	for i in range(kinds.size()):
		if gear.menu_open(i):
			return "playing"
	var play_words: Array = []
	for word in words:
		play_words.append(int(word) & ~(Pad.START | Pad.SELECT))
	two.step(play_words)
	return resolve()


## Consume the actual outcome once, rather than continuing a finished room.
func resolve() -> String:
	if two == null:
		return "list"
	for i in range(two.who.size()):
		if two.who[i] == Pb3Pair.PB2:
			if two.things[i].slots[0][Pb2Objects.F_LIFE] == 0:
				two.gone[i] = true
		else:
			# $97A7: suit zero is still a living, unarmoured hero.
			if two.sol[i].state == 0x0E:
				two.gone[i] = true
	if two.host_status != null and two.host_status.out_of_time:
		two.gone.fill(true)
	if not two.alive():
		message = "TEAM DOWN - CHOOSE A LEVEL TO RETRY"
		leave()
		return "list"
	if two.game == Pb3Pair.PB2:
		var world: Pb2Objects = two.host_pb2
		if two.ended == Pb2Turn.NEXT_AREA:
			if world.beat and two.stage == Pb2Objects.BOSS_STAGE:
				return _cleared()
			return _travel(Pb3Pair.PB2,
					Pb2Objects.BOSS_STAGE if world.boss != 0 else two.stage,
					world.area, world.phase, world.boss)
		if two.ended == Pb2Turn.INTERLUDE:
			return _travel(Pb3Pair.PB2, two.stage, world.area,
					world.phase, world.boss)
	else:
		# $CAA0 / $ACB1 name the destination in $55. The free-level
		# mode uses an immediate transition instead of the solo cutscene.
		var mode: int = two.host_script.g(0x02)
		if mode == SolFlow.DOOR or mode == 0x40:
			return _travel(Pb3Pair.SOL, two.host_sol.stage, 0)
		if mode == SolFlow.CLEAR or mode == SolFlow.END_PAY:
			return _cleared()
	return "playing"


func _cleared() -> String:
	message = "STAGE CLEAR - CHOOSE A LEVEL"
	leave()
	return "list"


func _travel(game: int, stage: int, area: int, phase: int = 0,
		boss: int = 0) -> String:
	var rec: Array = [game, stage, area]
	var index: int = records().find(rec)
	if index < 0:
		message = "INVALID LEVEL TRANSITION"
		leave()
		return "list"
	var came: int = two.came
	two.release()
	two = Pb3Pair.new(game, stage, area, kinds)
	two.came = came if game == Pb3Pair.PB2 else stage
	var spots: Array = []
	for _hero in kinds:
		spots.append(two.home())
	two.begin(spots, true)
	if two.host_pb2 != null:
		two.host_pb2.phase = phase
		two.host_pb2.boss = boss
		two.host_status.restart_time(two.came, phase)
	at = index
	came_from = index
	prepare()
	return "changed"


func _sync_gear() -> void:
	for i in range(two.who.size()):
		if two.who[i] == Pb3Pair.SOL:
			if armed[i] != gear.gun[i]:
				gear.arm(two.host_sol if i == two.host
						else two.guest_pool[i], i)
				armed[i] = gear.gun[i]
			continue
		var status: Pb2Status = gear.st[i]
		var pool: Pb2Objects = two.things[i]
		two.pb2[i].suit = status.suit
		pool.suit = status.suit
		pool.power = status.power_level
		pool.second = status.second_blade
		pool.extra = status.extra_shot
		if i == two.host:
			# $CEFD reads the live status, not the menu's display model.
			two.host_status.suit = status.suit
			two.host_status.owned = status.owned
			two.host_status.energy = gear.energy
			two.host_status.tanks = gear.tanks
		if gear.clear_shots[i]:
			for k in range(1, Pb2Objects.FIRST_LIVE):
				pool.clear(k)
			gear.clear_shots[i] = false
