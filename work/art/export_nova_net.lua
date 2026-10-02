-- Export indexed art as palette-separated 8x16 pieces. Two palettes can
-- share a cell without quantization: transparent pieces overlap geometrically.
local s=assert(app.open('art/nova/net.aseprite'))
assert(s.width==32 and s.height==48 and #s.frames==8 and s.colorMode==ColorMode.INDEXED)
local output={description='Generated from art/nova/net.aseprite; native Nova palettes and proportions.',
  animations={reach_ticks=5,catch_ticks=5,hold=2,release=3,variant_frames=4,probe_y=-16},frames={}}
local tile=0
for n=1,#s.frames do
  local im=Image(32,48,ColorMode.INDEXED);im:drawSprite(s,n)
  local frame={name=s.tags[n].name,parts={},tiles={}}
  for y=0,32,16 do for x=0,24,8 do for pal=0,1 do
    local rows={};local any=false
    for yy=0,15 do
      local row=''
      for xx=0,7 do
        local v=im:getPixel(x+xx,y+yy)
        assert(v>=0 and v<=7 and v~=4,'Only native palette indices 0,1,2,3,5,6,7')
        local use=v>0 and v//4==pal
        row=row..(use and tostring(v&3) or '.');any=any or use
      end
      rows[#rows+1]=row
    end
    if any then
      assert(tile<256,'Custom tile bank exceeds OAM index capacity')
      frame.parts[#frame.parts+1]={y-44,x-16,tile|1,16|pal}
      frame.tiles[#frame.tiles+1]=rows
      tile=tile+2
    end
  end end end
  output.frames[#output.frames+1]=frame
end
local f=assert(io.open('game/data/pb3/nova_net.json','w'));f:write(json.encode(output));f:write('\n');f:close()
print('Exported Nova net art: '..tile..' CHR tiles')
