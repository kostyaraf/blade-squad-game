-- Assemble the captured game frames in Aseprite, at their 60 Hz timing.
local dir='docs/qa/solbrain-animation/'
for _,range in ipairs({{'slide',128,166},{'climb',500,538}}) do
  local s=Sprite(256,240,ColorMode.RGB)
  for tick=range[2],range[3] do
    local n=tick-range[2]+1
    if n>1 then s:newEmptyFrame() end
    s.frames[n].duration=1/60
    local im=Image{fromFile=dir..string.format('game-%04d.png',tick)}
    s:newCel(s.layers[1],n,im)
  end
  app.sprite=s
  app.command.SpriteSize{ui=false,width=768,height=720,method='nearest'}
  s:saveAs(dir..range[1]..'-game.gif')
end
print('Saved game animation previews')
