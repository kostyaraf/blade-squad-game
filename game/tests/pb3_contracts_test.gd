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
