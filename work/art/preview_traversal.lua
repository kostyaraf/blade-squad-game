-- Render review artefacts in Aseprite, without changing the editable masters.
local root='docs/qa/solbrain-animation/'
local bg=app.pixelColor.rgba(55,60,72,255)
local function rgbframe(s,n)
  local indexed=Image(s.width,s.height,ColorMode.INDEXED)
  indexed:drawSprite(s,n)
  local out=Image(s.width,s.height,ColorMode.RGB)
  for p in indexed:pixels() do if p()>0 then
    local c=s.palettes[1]:getColor(p())
    out:drawPixel(p.x,p.y,app.pixelColor.rgba(c.red,c.green,c.blue,255))
  end end
  return out
end
local board=Image(384,160,ColorMode.RGB);board:clear(bg)
for _,kind in ipairs({'slide','climb'}) do
  local s=app.open('art/solbrain/'..kind..'.aseprite')
  local preview=Sprite(48,64,ColorMode.RGB)
  for n=1,#s.frames do
    if n>1 then preview:newEmptyFrame() end
    preview.frames[n].duration=s.frames[n].duration
    local im=Image(48,64,ColorMode.RGB);im:clear(bg)
    im:drawImage(rgbframe(s,n),Point((48-s.width)//2,56-s.height))
    preview:newCel(preview.layers[1],n,im)
    board:drawImage(rgbframe(s,n),Point((n-1)*48+8,kind=='slide' and 16 or 48))
  end
  preview:saveAs(root..kind..'-1x.gif')
  app.sprite=preview
  app.command.SpriteSize{ui=false,width=192,height=256,method='nearest'}
  preview:saveAs(root..kind..'-4x.gif')
end
local native=app.open('art/solbrain/native-reference.aseprite')
for n=1,5 do board:drawImage(rgbframe(native,n),Point((n-1)*48,88)) end
board:resize(1536,640)
board:saveAs(root..'poses.png')
print('Exported animation previews and pose sheet')
