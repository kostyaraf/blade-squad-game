-- Read saved masters; no drawing/generator rerun. Native and 4x evidence.
local dir='docs/qa/nova-net/'
local bg=app.pixelColor.rgba(55,60,72,255)
local function rgb(s,n)
  local im=Image(s.width,s.height,ColorMode.INDEXED);im:drawSprite(s,n)
  local out=Image(s.width,s.height,ColorMode.RGB)
  for p in im:pixels() do if p()>0 then
    local c=s.palettes[1]:getColor(p())
    out:drawPixel(p.x,p.y,app.pixelColor.rgba(c.red,c.green,c.blue,255))
  end end
  return out
end
local s=assert(app.open('art/nova/net.aseprite'))
local sheet=Image(256,64,ColorMode.RGB);sheet:clear(bg)
for v=0,1 do
  local loop=Sprite(48,64,ColorMode.RGB)
  for p=1,4 do
    if p>1 then loop:newEmptyFrame() end
    loop.frames[p].duration=s.frames[v*4+p].duration
    local im=Image(48,64,ColorMode.RGB);im:clear(bg)
    local art=rgb(s,v*4+p)
    im:drawImage(art,Point(8,8));loop:newCel(loop.layers[1],p,im)
    sheet:drawImage(art,Point((v*4+p-1)*32,8))
  end
  local name=v==0 and 'bare' or 'suit'
  loop:saveAs(dir..name..'-1x.gif')
  app.sprite=loop;app.command.SpriteSize{ui=false,width=192,height=256,method='nearest'}
  loop:saveAs(dir..name..'-4x.gif')
end
sheet:resize(1024,256);sheet:saveAs(dir..'poses.png')
-- The saved Solbrain master contains the native mesh action extracted from ROM.
local ref=assert(app.open('art/solbrain/net-reference.aseprite'))
local board=Image(ref.width*#ref.frames,ref.height,ColorMode.RGB);board:clear(bg)
for n=1,#ref.frames do board:drawImage(rgb(ref,n),Point((n-1)*ref.width,0)) end
board:resize(board.width*4,board.height*4);board:saveAs(dir..'solbrain-reference.png')
print('Saved Nova net previews and native Solbrain comparison')
