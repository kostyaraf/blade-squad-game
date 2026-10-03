"""Read-only ASCII PB2 collision map from extracted cartridge JSON."""
import json,sys,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[3]
st,ar=map(int,sys.argv[1:3]);d=json.loads((ROOT/f"game/data/pb2/levels/stage{st}.json").read_text());a=d["areas"][ar]
h=d["screens"][a["screens"][0]]["h"]*32
w=256 if a["vertical"] else 256*len(a["screens"]);hh=h*len(a["screens"]) if a["vertical"] else h
print("start",a["start"],"cam",a["cam_screen"],a["cam_sub"],"kind",a["kind"],"line",a["line"])
for y in range(0,hh,16):
 row=""
 for x in range(0,w,16):
  n=y//h if a["vertical"] else x//256;xx=x%256;yy=y%h
  sc=d["screens"][a["screens"][n]];b=sc["blocks"][(yy//32)*8+xx//32];blk=d["blocks"][b];tile=blk[(yy%32//8)*4+xx%32//8];c=a["terrain_class"][tile];ter=a["terrain"][tile]
  row+=".L#^"[c] if ter not in (3,4) else ("m" if ter==3 else "w")
 print(f"{y:4} {row}")
print("objects", " ".join(f"{s['along']*16}/{s['across']}:{s['type']:02X}" for s in a["spawns"]))
