-- Aseprite -b --script work/art/export_traversal.lua (repository root).
-- Read editable masters; reject incompatible art instead of quantizing it.
local specs={
  {file='slide',w=32,h=16,origin={16,16},names={'slide_enter','slide','slide_brace'}},
  {file='climb',w=24,h=48,origin={12,40},names={'climb_0','climb_1','climb_2','climb_3','climb_4','climb_5','climb_6','climb_7'}}
}
local frames={}
local native=assert(app.open('art/solbrain/native-reference.aseprite'))
local durations={}
for _,spec in ipairs(specs) do
  local s=assert(app.open('art/solbrain/'..spec.file..'.aseprite'))
  assert(s.colorMode==ColorMode.INDEXED,'Use indexed NES colours')
  assert(s.width==spec.w and s.height==spec.h,'Canvas dimensions changed')
  assert(#s.frames==#spec.names,'Frame count does not match the controller')
  assert(s.transparentColor==0,'Transparent index must be zero')
  for i=0,3 do
    local c=s.palettes[1]:getColor(i);local expected=native.palettes[1]:getColor(i)
    assert(c.red==expected.red and c.green==expected.green and c.blue==expected.blue and c.alpha==expected.alpha,'Native palette changed')
  end
  if spec.file=='slide' then
    for n=1,#s.frames do durations[n]=math.floor(s.frames[n].duration*60+0.5) end
    assert(durations[2]==durations[3] and durations[2]>0,'Slide loop frames need equal nonzero duration')
  end
  for _,layer in ipairs(s.layers) do
    assert(not layer.isGroup,'Flatten layer groups before export')
    if layer.isVisible then assert(layer.opacity==255 and layer.blendMode==BlendMode.NORMAL,'Only opaque normal layers are supported') end
  end
  for n,name in ipairs(spec.names) do
    local im=Image(s.width,s.height,ColorMode.INDEXED)
    -- Explicit indexed compositing preserves index 0 even though it has RGB 0.
    for _,layer in ipairs(s.layers) do
      local c=layer:cel(n)
      if layer.isVisible and c then
        assert(c.opacity==255,'Cel opacity must be 255')
        for p in c.image:pixels() do
          local v=p();assert(v>=0 and v<=3,'Palette index outside native 0..3')
          local x=p.x+c.position.x;local y=p.y+c.position.y
          if v>0 then
            assert(x>=0 and y>=0 and x<s.width and y<s.height,'Opaque pixel outside canvas')
            im:drawPixel(x,y,v)
          end
        end
      end
    end
    local rows={}
    for y=0,s.height-1 do
      local row='';for x=0,s.width-1 do local v=im:getPixel(x,y);row=row..(v==0 and '.' or tostring(v)) end
      rows[#rows+1]=row
    end
    frames[#frames+1]={name=name,width=s.width,height=s.height,origin=spec.origin,pixels=rows}
  end
end
local output={description='Generated from art/solbrain/*.aseprite by work/art/export_traversal.lua. 0 transparent; indices 1/2/3 use native Solbrain palette.',frames=frames,
  animations={slide={first=0,enter_ticks=durations[1],loop_first=1,loop_count=2,loop_ticks=durations[2],rest=2},climb={first=3,count=8,pixels_per_frame=4}}}
local path=app.params.output or 'game/data/pb3/sol_traversal.json'
local f=assert(io.open(path,'w'));f:write(json.encode(output));f:write('\n');f:close()
print('Exported '..#frames..' traversal frames to '..path)
