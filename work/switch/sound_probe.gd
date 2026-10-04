extends SceneTree
var baseline_path = ""
func _init():
 for arg in OS.get_cmdline_args():
  if arg.begins_with("--baseline="): baseline_path = arg.substr(11)
 call_deferred("start")
func start():
 if baseline_path == "":
  printerr("Pass --baseline=<unoptimized Godot 3 snd_chip.gd>")
  quit(1); return
 var old_script = load(baseline_path)
 var new_script = load("res://src/snd_chip.gd")
 var rom = []
 for i in range(16384): rom.append((i * 113 + 17) & 255)
 var old = old_script.new(rom)
 var current = new_script.new(rom)
 old.reset(); current.reset()
 seed(904)
 var registers = [0x4000, 0x4001, 0x4002, 0x4003, 0x4004, 0x4005,
   0x4006, 0x4007, 0x4008, 0x400A, 0x400B, 0x400C, 0x400E,
   0x400F, 0x4010, 0x4011, 0x4012, 0x4013, 0x4015, 0x4017]
 var fields = ["ctr", "mode", "reset_delay", "length", "env_div", "env_decay",
   "p_count", "p_period", "p_seq", "t_count", "t_seq", "n_shift", "n_count",
   "d_sr", "d_bits", "d_count", "d_cur", "d_left", "d_level", "d_full",
   "d_silence", "odd", "div"]
 var samples = 0
 for frame in range(160):
  if frame >= 4:
   for address in registers:
    if frame % 8 == 0 or int(randi() % 7) == 0:
     var value = int(randi() & 255)
     old.write(address, value, frame)
     current.write(address, value, frame)
  var cycles = 100000 if frame % 31 == 0 else 29780 + (frame & 1)
  old.reserve(cycles / 40 + 2); current.reserve(cycles / 40 + 2)
  old.run(cycles); current.run(cycles)
  if old.out_n != current.out_n:
   printerr("SOUND LENGTH DIFFERENCE frame=", frame); quit(1); return
  for i in range(old.out_n):
   if old.out[i] != current.out[i]:
    printerr("SOUND BYTE DIFFERENCE frame=",frame," byte=",i," old=",old.out[i]," new=",current.out[i])
    quit(1); return
  for name_ in fields:
   if old.get(name_) != current.get(name_):
    printerr("SOUND STATE DIFFERENCE frame=",frame," field=",name_)
    quit(1); return
  samples += old.out_n / 2
 print("SOUND PROBE: PASS frames=160 samples=", samples, " byte_differences=0 state_differences=0")
 quit()
