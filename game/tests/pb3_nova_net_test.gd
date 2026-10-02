extends SceneTree
## Placed integration regressions on real stage-0 net tiles, not a playthrough.
var failures := 0
var checks := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: ",message)

func falling(suited: int = 0) -> Pb2Player:
	var level := SolAsPb2.new(SolLevel.new(0))
	level.cam_y = 256
	var q := Pb2Player.new(level)
	q.place(120,104,1104) # World feet (1224,344), centre on the actual net.
	q.net_enabled = true
	q.combo_slide = true
	q.suit = suited
	q.sub = Pb2Player.SUB_AIR
	q.state = 1
	q.vy = 256
	return q

func _initialize() -> void:
	Pb2Sprites.load_data()
	for suit in [0,1,2,3,4,5]:
		var q := falling(suit)
		q.step(Pad.UP,Pad.UP,q.cam)
		check(q.sub==Pb2Player.SUB_NET,"Up catches net in suit "+str(suit))
		check(q.pose==int(q.cfg.ladder_pose),"grip keeps native physical pose")
		var at := Vector2i(q.x,q.y)
		var poses := {}
		poses[q.drawing_pose()]=true
		for f in range(24):
			q.step(0,0,q.cam)
			poses[q.drawing_pose()]=true
		check(poses.size()==3,"reach/catch/hold art phases")
		check(Vector2i(q.x,q.y)==at and q.vx==0 and q.vy==0,"released pad holds without falling")
		check(q.drawing_pose()==Pb2Sprites.net_pose(2,suit!=0),"stable held pose")
		# Both camera axes move while the grip stays fixed in world space.
		q.shift=3
		q.shift_y=2
		(q.lvl as SolAsPb2).cam_y += 2
		q.step(0,0,q.cam+3)
		check(q.sub==Pb2Player.SUB_NET and q.x+(q.cam<<8)==at.x+(1104<<8)
			and q.y+((q.lvl as SolAsPb2).cam_y<<8)==at.y+(256<<8),"scrolling preserves grip")
		q.shift=0
		q.shift_y=0
		q.step(Pad.A,Pad.A,q.cam)
		check(q.sub==Pb2Player.SUB_AIR and q.vy<0,"Jump leaves net upwards")
		check(q.drawing_pose()==Pb2Sprites.net_pose(3,suit!=0),"release has authored pose")
	var q := falling()
	q.step(0,0,q.cam)
	check(q.sub==Pb2Player.SUB_AIR,"no automatic catch without Up")
	q=falling()
	q.vy=-512
	q.step(Pad.UP,Pad.UP,q.cam)
	check(q.sub==Pb2Player.SUB_AIR,"rising does not catch")
	q=falling()
	q.net_enabled=false
	q.step(Pad.UP,Pad.UP,q.cam)
	check(q.sub==Pb2Player.SUB_AIR,"native physics unchanged when extension disabled")
	q=falling()
	q.x=32<<8
	q.step(Pad.UP,Pad.UP,q.cam)
	check(q.sub!=Pb2Player.SUB_NET,"empty background is not a net")
	q=falling()
	q.step(Pad.UP,Pad.UP,q.cam)
	q.step(Pad.DOWN|Pad.A,Pad.DOWN|Pad.A,q.cam)
	check(q.sub==Pb2Player.SUB_AIR and q.vy==0,"Down+Jump drops")
	q=falling()
	q.step(Pad.UP,Pad.UP,q.cam)
	q.step(Pad.B,Pad.B,q.cam)
	check(q.sub==Pb2Player.SUB_NET and (q.state&0x80)!=0,"can attack while gripping")
	for f in range(60): q.step(0,0,q.cam)
	check(q.sub==Pb2Player.SUB_NET and q.drawing_pose()==Pb2Sprites.net_pose(2,false),"attack returns to hold")
	# Each authored palette overlay counts as an 8x16 hardware sprite.
	for frame in Pb2Sprites.net_art().frames:
		var peak := 0
		for y in range(-48,0):
			var on_line := 0
			for part in frame.parts:
				if y>=int(part[0]) and y<int(part[0])+16: on_line+=1
			peak=maxi(peak,on_line)
		check(peak<=4,"two Nova bodies fit eight sprites/line: "+str(frame.name))
	for suit in [0,1,2,3,4,5]:
		for left in [false,true]:
			q=falling(suit)
			q.face_left=left
			q.step(Pad.UP,Pad.UP,q.cam)
			for f in range(12): q.step(0,0,q.cam)
			check(q.sub==Pb2Player.SUB_NET and q.face_left==left,"hold either facing / suit")
			q.step(Pad.B,Pad.B,q.cam)
			check(q.drawing_pose()==q.pose and q.pose<int(q.cfg.probe_set.size()),"attack uses native art and physics")
			for f in range(35): q.step(0,0,q.cam)
			check(q.sub==Pb2Player.SUB_NET and q.drawing_pose()==Pb2Sprites.net_pose(2,suit!=0),"attack returns in either facing / suit")
			q.step(Pad.DOWN|Pad.A,Pad.DOWN|Pad.A,q.cam)
			for f in range(12): q.step(0,0,q.cam)
			check(q.sub!=Pb2Player.SUB_NET and q.pose<int(q.cfg.probe_set.size()),"drop resumes native physics")
	# Verify native tile bytes survive extension of the atlas.
	var original := Image.new()
	check(original.load_png_from_buffer(FileAccess.get_file_as_bytes('res://data/pb2/tiles.png'))==OK,
		"native CHR PNG loads from bytes")
	original.convert(Image.FORMAT_R8)
	var atlas := Nes.sheet('pb2').get_image()
	check(atlas.get_region(Rect2i(0,0,original.get_width(),original.get_height())).get_data()==original.get_data(),"native Nova CHR preserved")
	# Real session enables the feature and mirrors custom art into render OAM.
	var session := Pb3Session.new([0,0])
	session.two=Pb3Pair.new(1,0,0,[0,0])
	session.two.begin([Vector2i(1224,344),Vector2i(1256,344)],true)
	session.gear=Pb3Gear.new([0,0])
	session.prepare()
	for i in range(2):
		session.two.pb2[i]._step_off(256)
		session.two.guest_sol[i].timer=255
	session.advance(session.tick,[Pad.UP,Pad.UP])
	for i in range(2):
		check(session.two.pb2[i].sub==Pb2Player.SUB_NET,"co-op Nova catches independently "+str(i))
		check(session.two.things[i].slots[0][Pb2Objects.F_KIND]==session.two.pb2[i].pose,
			"object mirror keeps native pose "+str(i))
		var draw := Pb3Draw.new(session.two,i)
		var authored := false
		for n in range(0,256,4):
			if draw.guest_oam[n]<240 and (draw.guest_oam[n+2]&0x10)!=0: authored=true
		check(authored,"custom Nova tiles reach OAM "+str(i))
		check(session.two.things[i].slots[0][Pb2Objects.F_KIND]==session.two.pb2[i].pose,
			"OAM assembly does not change physical mirror "+str(i))
	# Opening either menu freezes both grip positions AND drawing phases.
	for owner in range(2):
		var before: Array = []
		for i in range(2):
			var h: Pb2Player = session.two.pb2[i]
			before.append([h.x,h.y,h.net_ticks,h.drawing_pose()])
		var words := [0,0]
		words[owner]=Pad.START
		session.advance(session.tick,words)
		check(session.gear.menu_open(owner),"menu opens on net "+str(owner))
		for f in range(12): session.advance(session.tick,[0,0])
		for i in range(2):
			var h: Pb2Player = session.two.pb2[i]
			check([h.x,h.y,h.net_ticks,h.drawing_pose()]==before[i],"menu freezes both grips "+str(owner)+"/"+str(i))
		session.advance(session.tick,words)
		session.advance(session.tick,[0,0])
		check(not session.gear.menu_open(owner),"menu closes on net "+str(owner))
	# Damage must release an attached player without altering the other one.
	session.two.guest_sol[0].suit -= 1
	session.two._harvest()
	check(session.two.pb2[0].sub==Pb2Player.SUB_AIR and session.two.pb2[1].sub==Pb2Player.SUB_NET,"damage releases only the struck player")
	session.leave()
	print('%d of %d Nova net checks failed'%[failures,checks])
	quit(1 if failures else 0)
