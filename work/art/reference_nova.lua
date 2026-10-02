-- Native Nova reference: slide $0D, ladder $1A/$1B, wall $2C/$2D/$2E/$2F.
local function read(p) local f=assert(io.open(p));local j=json.decode(f:read('*a'));f:close();return j end
local sprites=read('game/data/pb2/sprites.json')
local colours=read('game/data/nes_palette.json').rgb
local palette=read('game/data/pb2/levels/stage0.json').areas[1].palette
local tiles=Image{fromFile='game/data/pb2/tiles.png'}
local s=Sprite(48,48,ColorMode.RGB)
local specs={{13,0},{13,1},{26,0},{27,0},{44,1},{45,1},{46,1},{47,1}}
local board=Image(#specs*48,48,ColorMode.RGB);board:clear(app.pixelColor.rgba(55,60,72,255))
local measurements={}
for n,spec in ipairs(specs) do
  if n>1 then s:newEmptyFrame() end
  local id,suit=spec[1],spec[2]
  local im=Image(48,48,ColorMode.RGB)
  for _,p in ipairs(sprites.hero[id+1]) do
    for y=0,15 do for x=0,7 do
      local fine=(p[3]&128)>0 and 15-y or y
      local index=(p[2]&254)+fine//8
      local bank=index<64 and (sprites.player_bank[id+1]+((suit>0 and id<31) and 6 or 0)) or sprites.suit_bank[suit>0 and 2 or 1]
      local tile=bank*64+index%64
      local col=(p[3]&64)>0 and 7-x or x
      local v=(tiles:getPixel((tile%128)*8+col,(tile//128)*8+fine%8)&255)//85
      if v>0 then
        local pi=suit>0 and 1 or p[3]&3
        local hex=colours[palette[17+pi*4+v]+1]
        im:drawPixel(24+p[4]+x,39+p[1]+y,app.pixelColor.rgba(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16),255))
      end
    end end
  end
  local left,right,top,bottom,count=48,0,48,0,0
  for p in im:pixels() do if app.pixelColor.rgbaA(p())>0 then
    count=count+1;left=math.min(left,p.x);right=math.max(right,p.x);top=math.min(top,p.y);bottom=math.max(bottom,p.y)
  end end
  measurements[#measurements+1]={pose=id,suit=suit,width=right-left+1,height=bottom-top+1,pixels=count}
  s:newCel(s.layers[1],n,im)
  local t=s:newTag(n,n);t.name=string.format('nova_%02X_suit%d',id,suit)
  board:drawImage(im,Point((n-1)*48,0))
end
s:saveAs('art/solbrain/nova-reference.aseprite')
board:resize(board.width*4,board.height*4)
board:saveAs('docs/qa/solbrain-animation/nova-reference.png')
local f=assert(io.open('docs/qa/solbrain-animation/nova-measurements.json','w'));f:write(json.encode(measurements));f:close()
print(json.encode(measurements))
