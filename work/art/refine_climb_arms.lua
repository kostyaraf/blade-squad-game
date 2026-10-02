-- Edit only the arm layer of the existing master; preserve all other artwork.
local s=assert(app.open('art/solbrain/climb.aseprite'))
local arms
for _,layer in ipairs(s.layers) do if layer.name=='Arms' then arms=layer end end
assert(arms and #s.frames==8 and s.width==24 and s.height==48)
local hand_y={1,5,9,13,17,11,5,1}
local elbow_y={9,12,16,20,21,18,12,9}
local function stroke(im,x,y,tx,ty,c,r)
  local dx=math.abs(tx-x);local sx=x<tx and 1 or -1
  local dy=-math.abs(ty-y);local sy=y<ty and 1 or -1;local err=dx+dy
  while true do
    for yy=y-r,y+r do for xx=x-r,x+r do
      if xx>=0 and yy>=0 and xx<24 and yy<48 then im:drawPixel(xx,yy,c) end
    end end
    if x==tx and y==ty then break end
    local e2=err*2
    if e2>=dy then err=err+dy;x=x+sx end
    if e2<=dx then err=err+dx;y=y+sy end
  end
end
for n=1,8 do
  local im=Image(24,48,ColorMode.INDEXED)
  for side=0,1 do
    local phase=(n-1+side*4)%8+1
    local shoulder=side==0 and 8 or 15
    local elbow=side==0 and 4 or 19
    local hand=side==0 and 5 or 18
    local ey=elbow_y[phase];local hy=hand_y[phase]
    -- Upper arm and forearm turn in opposite horizontal directions.
    -- The outline makes the elbow readable before applying armour highlights.
    stroke(im,shoulder,16,elbow,ey,1,1)
    stroke(im,elbow,ey,hand,hy,1,1)
    stroke(im,shoulder,16,elbow,ey,3,0)
    stroke(im,elbow,ey,hand,hy,3,0)
    im:drawPixel(elbow,ey,1)
    im:drawPixel(elbow,ey+(hy<ey and -1 or 1),2)
    im:drawPixel(shoulder,16,2)
    for yy=math.max(0,hy-1),hy+1 do for xx=hand-1,hand+1 do
      im:drawPixel(xx,yy,xx==hand and yy==hy and 3 or 1)
    end end
  end
  local old=arms:cel(n)
  if old then s:deleteCel(old) end
  s:newCel(arms,n,im,Point(0,0))
end
s:saveAs('art/solbrain/climb.aseprite')
print('Refined eight arm poses with explicit elbow bends')
