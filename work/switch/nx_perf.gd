extends Reference
# Последние интервалы сохраняются для проверки на самой консоли.
var elapsed = 0.0
var frames = 0
var cpu_us = 0
var samples = []
var enabled = false
func _init():
 enabled = OS.get_name() == "Switch" or OS.get_cmdline_args().has("--switch-perf")
func observe(main, dt, processing_us):
 if not enabled: return
 elapsed += dt
 frames += 1
 cpu_us += processing_us
 if elapsed < 5.0: return
 var skips = 0
 if main.snd_out != null:
  var playback = main.snd_out.get_stream_playback()
  if playback != null and playback.has_method("get_skips"):
   skips = playback.get_skips()
 var viewport = main.get_viewport_rect().size
 samples.append({"fps": frames / elapsed,
   "main_cpu_ms": cpu_us / (1000.0 * frames),
   "phase": "menu" if main.menu != null else main.game,
   "audio_skips_total": skips, "logic_frame": main.clock.frame,
   "viewport": [int(viewport.x), int(viewport.y)]})
 if samples.size() > 6: samples.pop_front()
 var f = NXCompat.open("user://switch-perf.json", NXCompat.WRITE)
 if f != null:
  f.store_string(to_json({"version": "0.1.2-switch-test", "samples": samples}))
  f.close()
 elapsed = 0.0
 frames = 0
 cpu_us = 0
