extends SceneTree
## Placed integration regressions; these do not certify room completion.
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print('FAIL: ',label)
func _initialize() -> void: call_deferred('run')
func run() -> void:
	contact_owner()
	room_clock()
	shared_pause()
	refill_once()
	pickup_state()
	shared_tank()
	paused_input()
	print('%d of %d contract checks failed'%[failures,checks])
	quit(1 if failures else 0)
func contact_owner() -> void:
	for host_suit in [0,1]:
		for guest_suit in [0,1]:
			var session := Pb3Session.new([0,0])
			session.enter()
			var pair := session.two
			pair.pb2[0].suit = host_suit
			pair.pb2[1].suit = guest_suit
			pair.pb2[1].state = 0x10
			pair._mirror_them()
			var row: PackedByteArray = pair.guest_row[1]
			check(row[Pb2Objects.F_MARK]==0x10,'guest native state mirrored')
			var world := pair.host_pb2
			world.suit = host_suit
			# Keep the host away; put a 3-HP enemy at the guest's collision centre.
			world.slots[0][Pb2Objects.F_X] = (row[Pb2Objects.F_X]+100)&255
			for k in range(1,Pb2Objects.SLOTS): world.clear(k)
			var enemy: PackedByteArray = world.slots[6]
			enemy[Pb2Objects.F_TYPE] = 0x10
			enemy[Pb2Objects.F_LIFE] = 3
			enemy[Pb2Objects.F_X] = row[Pb2Objects.F_X]
			enemy[Pb2Objects.F_Y] = (row[Pb2Objects.F_Y]-8)&255
			world.frame = 1
			world.contact()
			check((enemy[Pb2Objects.F_LIFE]==0)==(guest_suit!=0),
					'contact uses guest suit, host=%d guest=%d'%[host_suit,guest_suit])
			check((row[Pb2Objects.F_LIFE]==16)==(guest_suit!=0),'guest strike protects only its owner')
			session.leave()
func room_clock() -> void:
	for kinds in [[0],[1],[0,1],[1,0]]:
		var s := Pb3Session.new(kinds)
		s.enter()
		var status := s.two.host_status
		status.time_hi=0
		status.time_lo=0x29
		status.warn=1
		status.clock=31
		s.two.host_pb2.area=1
		s.two.ended=Pb2Turn.NEXT_AREA
		check(s.resolve()=='changed','door transitions')
		status=s.two.host_status
		check([status.time_hi,status.time_lo,status.warn,status.clock]==[0,0x29,1,31],
				'door preserves remaining time and fractional frame '+str(kinds))
		s.two.host_pb2.boss=1
		s.two.host_pb2.area=0
		s.two.ended=Pb2Turn.NEXT_AREA
		check(s.resolve()=='changed','boss entry transitions')
		check(s.two.host_status.time_lo==0x29 and s.two.host_status.clock==31,'boss keeps clock')
		s.two.host_pb2.phase=1
		s.two.ended=Pb2Turn.INTERLUDE
		check(s.resolve()=='changed','interlude transitions')
		var expected := Pb2Status.new()
		expected.restart_time(s.two.came,1)
		check(s.two.host_status.time_lo==expected.time_lo and s.two.host_status.time_hi==expected.time_hi,
				'interlude starts new half clock')
		s.leave()

func shared_pause() -> void:
	for kinds in [[0,0],[0,1],[1,0]]:
		for menu_player in range(2):
			var gear := Pb3Gear.new(kinds)
			for i in range(2):
				if kinds[i]==0:
					gear.st[i].suit=1
					gear.st[i].drain_hi=0
					gear.st[i].drain_lo=0
			var hits := [0,0]
			hits[menu_player]=Pad.START
			gear.step(hits)
			for f in range(600): gear.step([0,0])
			check(gear.energy==16,'either menu freezes shared wear '+str([kinds,menu_player]))
			check(not gear.playing and gear.menu_held,'global menu pause signalled')
			for i in range(2):
				check(gear.st[i].drain_hi==0 and gear.st[i].drain_lo==0,'wear fraction also frozen')

func refill_once() -> void:
	for kinds in [[0],[0,0],[0,1],[1,0]]:
		var session := Pb3Session.new(kinds)
		session.enter()
		var pair := session.two
		var status: Pb2Status = session.gear.st[pair.host]
		check(status==pair.host_status and status==pair.turn_pb2.status,'single host status owner')
		session.gear.energy=1
		session.gear.tanks=1
		status.suit=1
		var expected := Pb2Status.new()
		expected.energy=1
		expected.tanks=1
		expected.suit=1
		var positions := []
		for i in range(kinds.size()): positions.append(pair.world_of(i))
		pair.eye.pending=3
		var camera := pair.eye.pos
		var world_frame := pair.host_pb2.frame
		var held := []
		for i in range(kinds.size()): held.append(Pad.RIGHT|Pad.B)
		var paused := 0
		for f in range(65):
			var plays := expected.step(0)
			check(session.advance(session.tick,held)=='playing','refill keeps session')
			for field in ['clock','energy','tanks','suit','drain_hi','drain_lo','mode','refill_energy']:
				check(status.get(field)==expected.get(field),'native refill exactly once '+field+' frame '+str(f))
			check(session.gear.energy==expected.energy,'shared refill not overwritten')
			if not plays:
				paused+=1
				for i in range(kinds.size()): check(pair.world_of(i)==positions[i],'all actors frozen during refill')
				check(pair.eye.pos==camera and pair.eye.pending==3,'pending camera frozen')
				check(pair.host_pb2.frame==world_frame,'world clock frozen')
		check(paused>0 and paused<65,'refill completes and releases world')
		session.leave()

func pickup_state() -> void:
	var session := Pb3Session.new([0,1])
	session.enter()
	var pair := session.two
	var world := pair.host_pb2
	world.slots[0][Pb2Objects.F_LIFE]=12
	# Native contact with a health capsule, then the next full session frame.
	var bonus: PackedByteArray = world.slots[6]
	bonus[Pb2Objects.F_TYPE]=1
	bonus[Pb2Objects.F_MARK]=0x40
	bonus[Pb2Objects.F_LIFE]=0
	bonus[Pb2Objects.F_X]=world.slots[0][Pb2Objects.F_X]
	bonus[Pb2Objects.F_Y]=(world.slots[0][Pb2Objects.F_Y]-15)&255
	world.frame=1
	world.contact()
	check(pair.host_status.mode==Pb2Status.REFILL_LIFE,'capsule starts refill')
	check(world.playing==Pb2Status.REFILL_LIFE,'native shared mode receives refill')
	var before := pair.world_of(0)
	for f in range(16): session.advance(session.tick,[Pad.RIGHT,Pad.RIGHT])
	check(world.slots[0][Pb2Objects.F_LIFE]==16,'health refill reaches player')
	check(pair.world_of(0)==before,'capsule freezes actor through final refill frame')
	# Technical retention of existing native rewards; receiver policy is GAP-01.
	pair.host_status.power_level=2
	session.advance(session.tick,[0,0])
	check(session.gear.st[0].power_level==2 and world.power==2,'reward survives menu sync')
	world.area=1
	pair.host_status.mode=4 # Door mode belongs to the old room.
	pair.ended=Pb2Turn.NEXT_AREA
	session.resolve()
	check(session.two.host_status==session.gear.st[0] and session.two.host_status.power_level==2,
			'personal equipment survives ordinary door')
	check(session.two.host_status.mode==Pb2Status.PLAY,'new room releases old door mode')
	session.leave()

func shared_tank() -> void:
	var gear := Pb3Gear.new([0,0],1,3)
	gear.st[0].suit=1
	gear.st[1].suit=2
	for f in range(64): gear.step([0,0])
	check(gear.tanks==2 and gear.energy==16,'two suits consume one tank and one refill rate')
	gear=Pb3Gear.new([0,1],16,3)
	gear.st[0].suit=1
	for f in range(600): gear.step([0,0],[false,true])
	check(gear.energy==16 and gear.tanks==3,'dead suit does not consume shared resource')
	var session := Pb3Session.new([0,1])
	session.enter()
	var world := session.two.host_pb2
	world.slots[0][Pb2Objects.F_LIFE]=0
	session.two.gone[0]=true
	var bonus: PackedByteArray = world.slots[6]
	bonus[Pb2Objects.F_TYPE]=1
	bonus[Pb2Objects.F_LIFE]=0
	world._pick_up(6)
	check(session.two.host_status.mode==Pb2Status.PLAY,'health pickup cannot refill a dead host')
	session.leave()

func paused_input() -> void:
	for entry in [0,63]:
		var session := Pb3Session.new([0,1])
		session.at=entry
		session.enter()
		session.advance(session.tick,[Pad.START,0])
		session.advance(session.tick,[Pad.A,Pad.A])
		check(session.two.last_pad==[Pad.A,Pad.A],'menu polls both controllers')
		check(session.two.sol[1].pad_held==Pad.A,'Solbrain polls while paused')
		session.advance(session.tick,[Pad.START|Pad.A,Pad.A])
		check((session.two.pb2[0].hit & Pad.A)==0 and session.two.sol[1].vy>=0,'held pause input does not create jump '+str([entry,session.two.pb2[0].vy,session.two.sol[1].state,session.two.sol[1].vy]))
		session.leave()
