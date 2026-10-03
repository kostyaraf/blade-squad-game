-- Run from repository root with Aseprite -b --script work/art/reference.lua.
local function read(path)
  local f = assert(io.open(path)); local v = json.decode(f:read('*a')); f:close(); return v
end
local hero = read('game/data/sol/hero.json')
local rgb = read('game/data/nes_palette.json').rgb
local native = read('game/data/sol/levels/stage0.json').palette
local pal = Palette(4)
pal:setColor(0, Color{r=0,g=0,b=0,a=0})
for i=1,3 do
  local hex=rgb[native[17+i]+1]
  pal:setColor(i,Color{r=tonumber(hex:sub(1,2),16),g=tonumber(hex:sub(3,4),16),b=tonumber(hex:sub(5,6),16),a=255})
end
local tiles = Image{fromFile='game/data/sol/tiles.png'}
local spr = Sprite(48,64,ColorMode.INDEXED); spr:setPalette(pal)
spr.layers[1].name='Native reference'
local ids={100,108,122,160,162,164,166,168,170}
for n,id in ipairs(ids) do
  if n>1 then spr:newEmptyFrame() end
  local im=Image(48,64,ColorMode.INDEXED)
  local pic=hero.pictures[id+1]
  for _,p in ipairs(pic.parts) do
    for y=0,15 do for x=0,7 do
      local tile=pic.chr*64+(p[3]&0xFE)+math.floor(y/8)
      local v=(tiles:getPixel((tile%128)*8+x,math.floor(tile/128)*8+y%8)&255)//85
      if v>0 then im:drawPixel(24+p[2]+x,24+p[1]+y,v) end
    end end
  end
  spr:newCel(spr.layers[1],n,im)
  local tag=spr:newTag(n,n); tag.name=string.format('native_%02X',id)
end
spr:saveAs('art/solbrain/native-reference.aseprite')
local grid=Image(#ids*48,64,ColorMode.INDEXED)
for n=1,#ids do grid:drawImage(spr.cels[n].image,Point((n-1)*48,0)) end
grid:resize(#ids*48*3,64*3)
grid:saveAs{filename='docs/qa/solbrain-animation/native-reference.png',palette=pal}
print('Saved native reference poses')
