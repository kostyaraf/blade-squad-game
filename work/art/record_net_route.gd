extends SceneTree
## Controller-only recorder: observe positions and emit ordinary pad words.
## Never mutates actors, health, enemies, camera, or transition state.
var heroes: Array = [1]
var name := "s0-sol"
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--heroes="):
			heroes=[]
			for h in arg.trim_prefix("--heroes=").split(","): heroes.append(int(h))
		if arg.begins_with("--name="): name=arg.trim_prefix("--name=")
	var session := Pb3Session.new(heroes)
	session.at=63
	session.enter()
	var steps: Array = []
	var stalls: Array = []
	var old: Array = []
	var caught: Array = []
	var phase: Array = []
	var jump_ticks: Array = []
	var done: Array = []
	var capture: Array = []
	for i in range(heroes.size()):
		stalls.append(0);old.append(-1);caught.append(0);phase.append(0);jump_ticks.append(0);done.append(false)
	for f in range(10000):
		if session.two==null: break
		var words: Array = []
		var all_done := true
		for i in range(heroes.size()):
			var at:=session.two.world_of(i)
			var grip: bool = session.two.pb2[i].sub==Pb2Player.SUB_NET if heroes[i]==0 else session.two.sol[i].state in [8,9,10,11]
			if at.x==int(old[i]): stalls[i]+=1
			else: stalls[i]=0
			old[i]=at.x
			var pad := 0
			if grip:
				caught[i]+=1
				if int(caught[i])==1: capture.append([maxi(1,session.tick-10),session.tick+25])
				phase[i]=2
				if int(caught[i])<24: pad=0
				elif int(caught[i])==24: pad=Pad.DOWN|Pad.A
				else: pad=Pad.RIGHT|Pad.A
			elif int(phase[i])==2:
				pad=Pad.RIGHT
				if at.x>1360: done[i]=true;pad=0
				elif int(stalls[i])>20: pad|=Pad.A
			elif at.x>=1228 and at.x<=1260:
				if int(phase[i])==0:
					phase[i]=1;jump_ticks[i]=0
				jump_ticks[i]+=1
				pad=Pad.A if int(jump_ticks[i])<=20 else Pad.UP
				if int(jump_ticks[i])>100: phase[i]=0
			else:
				pad=Pad.RIGHT
				# Tap attacks; a held B does not repeat on either cartridge.
				if f%18<9: pad|=Pad.B
				if int(stalls[i])>20 and f%50<25: pad|=Pad.A
				# Keep a faster partner within the camera's shared screen.
				if heroes.size()==2:
					var other:=session.two.world_of(1-i)
					if at.x>other.x+64: pad=0
			words.append(pad)
			all_done=all_done and bool(done[i])
		var event:=session.advance(session.tick,words)
		if steps.size()>0 and steps[-1].slice(1)==words: steps[-1][0]+=1
		else: steps.append([1]+words)
		if f%200==0:
			var positions: Array=[]
			for i in range(heroes.size()): positions.append(str(session.two.world_of(i)))
			print(session.tick," ",positions," grip=",caught)
		if event!="playing" or all_done: break
		var dead := false
		for i in range(heroes.size()): dead=dead or session.two.gone[i]
		if dead: break
	var folder:="res://../docs/qa/nova-net/"+name
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var file:=FileAccess.open(folder+"/input.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"entry":63,"heroes":heroes,"steps":steps,"events":[],"capture":capture,"grip_ticks":caught,"done":done},"  "))
	print("FINAL ",session.tick," grip=",caught," done=",done)
	session.leave()
	quit(0 if done.all(func(ok):return ok) else 1)
