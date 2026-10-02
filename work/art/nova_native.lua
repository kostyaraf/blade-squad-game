-- Native Nova pixels and the two palettes used by unarmoured sprites.
local function read(p) local f=assert(io.open(p));local j=json.decode(f:read('*a'));f:close();return j end
local data=read('game/data/pb2/sprites.json')
local rgb=read('game/data/nes_palette.json').rgb
local colours=read('game/data/pb2/levels/stage0.json').areas[1].palette
local tiles=Image{fromFile='game/data/pb2/tiles.png'}
local palette=Palette(8)
for i=0,7 do
  local hex=rgb[colours[17+i]+1]
  palette:setColor(i,Color{r=tonumber(hex:sub(1,2),16),g=tonumber(hex:sub(3,4),16),b=tonumber(hex:sub(5,6),16),a=i==0 and 0 or 255})
end
local function pose(id,suit)
  local im=Image(32,48,ColorMode.INDEXED)
  for _,p in ipairs(data.hero[id+1]) do for y=0,15 do for x=0,7 do
    local fine=(p[3]&128)>0 and 15-y or y
    local index=(p[2]&254)+fine//8
    local bank=index<64 and (data.player_bank[id+1]+((suit and id<31) and 6 or 0)) or data.suit_bank[suit and 2 or 1]
    local tile=bank*64+index%64
    local col=(p[3]&64)>0 and 7-x or x
    local v=(tiles:getPixel((tile%128)*8+col,(tile//128)*8+fine%8)&255)//85
    if v>0 then im:drawPixel(16+p[4]+x,44+p[1]+y,v+4*(suit and 1 or (p[3]&3))) end
  end end end
  return im
end
return {palette=palette,pose=pose}
