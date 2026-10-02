-- Assemble actual rendered captures; preserve game timing and contact blinking.
local dir=app.params['folder'] or 'docs/qa/nova-net/'
local f=assert(io.open(dir..'capture.json'));local rec=json.decode(f:read('*a'));f:close()
local groups={};local last=-2
for _,frame in ipairs(rec.frames) do
  if frame.tick~=last+1 then groups[#groups+1]={} end
  local group=groups[#groups];group[#group+1]=frame.tick;last=frame.tick
end
for index,ticks in ipairs(groups) do
  local s=Sprite(256,240,ColorMode.RGB)
  for n,tick in ipairs(ticks) do
    if n>1 then s:newEmptyFrame() end
    s.frames[n].duration=1/60
    s:newCel(s.layers[1],n,Image{fromFile=dir..string.format('game-%04d.png',tick)})
  end
  s:saveAs(dir..'game-'..index..'-1x.gif')
  app.sprite=s;app.command.SpriteSize{ui=false,width=768,height=720,method='nearest'}
  s:saveAs(dir..'game-'..index..'-3x.gif')
end
print('Saved '..#groups..' ordinary gameplay GIF segments')
