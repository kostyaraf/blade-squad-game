-- Construct a new net-grab animation from Nova's native wall-climb anatomy.
-- Explicitly running this replaces the .aseprite master.
local native=dofile('work/art/nova_native.lua')
local s=Sprite(32,48,ColorMode.INDEXED);s:setPalette(native.palette)
s.layers[1].name='Native proportions / net poses'
local ids={45,46,44,45}
for variant=0,1 do for phase,id in ipairs(ids) do
  local n=variant*4+phase
  if n>1 then s:newEmptyFrame() end
  local im=native.pose(id,variant==1)
  if variant==0 then
    -- Bare Nova: skin on the raised arms/head, blue trousers and white boots.
    -- Keep the native wall pose's narrow contour and joint locations.
    for p in im:pixels() do
      if p()>0 and p.y<25 then p((p()&3)+4) end
    end
    -- Original unarmoured hair/face, rather than the power-suit helmet.
    local head=native.pose(17,false)
    local offset=id==45 and 6 or 0
    for y=11,18 do for x=12,21 do
      local v=head:getPixel(x,y)
      im:drawPixel(x-1,y-3+offset,v)
    end end
  end
  s:newCel(s.layers[1],n,im)
  s.frames[n].duration=({5/60,5/60,12/60,5/60})[phase]
end end
for n,name in ipairs({'bare_reach','bare_catch','bare_hold','bare_release','suit_reach','suit_catch','suit_hold','suit_release'}) do
  local t=s:newTag(n,n);t.name=name
end
s:saveAs('art/nova/net.aseprite')
print('Created Nova net master')
