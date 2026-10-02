-- Initial artwork construction in Aseprite. Subsequent edits belong in the
-- .aseprite masters; running this script explicitly replaces those masters.
local reference=app.open('art/solbrain/native-reference.aseprite')
local pal=reference.palettes[1]
local function stamp(im,rows,ox,oy)
  for y,row in ipairs(rows) do for x=1,#row do
    local c=row:sub(x,x)
    if c~='.' then im:drawPixel(ox+x-1,oy+y-1,tonumber(c)) end
  end end
end
local function line(im,x0,y0,x1,y1,c,r)
  local dx=math.abs(x1-x0); local sx=x0<x1 and 1 or -1
  local dy=-math.abs(y1-y0);local sy=y0<y1 and 1 or -1;local e=dx+dy
  while true do
    for y=y0-r,y0+r do for x=x0-r,x0+r do
      if x>=0 and y>=0 and x<im.width and y<im.height then im:drawPixel(x,y,c) end
    end end
    if x0==x1 and y0==y1 then break end
    local e2=2*e;if e2>=dy then e=e+dy;x0=x0+sx end
    if e2<=dx then e=e+dx;y0=y0+sy end
  end
end
local function limb(im,a,b,c,leg)
  line(im,a[1],a[2],b[1],b[2],1,leg and 2 or 1);line(im,b[1],b[2],c[1],c[2],1,1)
  line(im,a[1],a[2],b[1],b[2],3,leg and 1 or 0)
  if leg then
    line(im,b[1]-1,b[2]+2,c[1]-1,c[2]-1,3,0)
  else
    line(im,b[1],b[2],c[1],c[2],3,0)
    im:drawPixel(a[1],a[2],2)
  end
  im:drawPixel(b[1],b[2],1)
end
local function newdoc(w,h,names)
  local s=Sprite(w,h,ColorMode.INDEXED);s:setPalette(pal)
  s.layers[1].name=names[1]
  local layers={s.layers[1]}
  for i=2,#names do local l=s:newLayer();l.name=names[i];layers[i]=l end
  return s,layers
end
local function cel(s,l,n,im) s:newCel(l,n,im,Point(0,0)) end
local slide,layers=newdoc(32,16,{'Legs','Torso','Supporting arm','Helmet'})
local head={'..1111..','.111111.','.3312221','.131111.','.113131.','..111131','...1111.'}
for n=1,3 do
  if n>1 then slide:newEmptyFrame() end
  slide.frames[n].duration=n==1 and 4/60 or 6/60
  local legs=Image(32,16,ColorMode.INDEXED)
  -- Far knee is bent; the near shin and boot point along the floor.
  stamp(legs,{'.....11111.......','....1333331......','...133113331.....','..1331..113331...','.1111....111331..','133311111111331..','11133333333311311','11111111111112331','............13331','............11111'},14,6)
  cel(slide,layers[1],n,legs)
  local body=Image(32,16,ColorMode.INDEXED)
  stamp(body,{'...1111.....','..122221....','.12333211...','1233321331..','12222113331.','112211113331','.11113311331','..1133311111','...111111...'},7,n==1 and 5 or 6)
  cel(slide,layers[2],n,body)
  local arm=Image(32,16,ColorMode.INDEXED)
  stamp(arm,n==3 and {'......1111','.....13331','...111331.','..133111..','.13311....','11111.....'} or {'......1111','.....13331','....13331.','...11331..','.111131...','133111....'},1,9)
  cel(slide,layers[3],n,arm)
  local helmet=Image(32,16,ColorMode.INDEXED);stamp(helmet,head,n==1 and 5 or 4,n==1 and 1 or 2)
  cel(slide,layers[4],n,helmet)
end
local enter=slide:newTag(1,1);enter.name='slide_enter'
local loop=slide:newTag(2,3);loop.name='slide_loop'
slide:saveAs('art/solbrain/slide.aseprite')

local climb,parts=newdoc(24,48,{'Legs','Arms','Body','Helmet'})
local hand={1,5,9,13,17,11,5,1}
local foot={37,33,29,27,25,29,33,37}
for n=1,8 do
  if n>1 then climb:newEmptyFrame() end
  climb.frames[n].duration=2/60
  local legs=Image(24,48,ColorMode.INDEXED)
  local arms=Image(24,48,ColorMode.INDEXED)
  for side=0,1 do
    local phase=(n-1+side*4)%8+1
    local fy=foot[phase];local hy=hand[phase]
    local hx=side==0 and 5 or 18
    local shoulder=side==0 and 8 or 15
    local hip=side==0 and 10 or 13
    local knee=side==0 and 8 or 15
    local boot=side==0 and 8 or 15
    limb(legs,{hip,26},{knee,math.min(33,fy-6)},{boot,fy},true)
    stamp(legs,{'1211','1331','1111'},boot-1,fy)
    -- A bent elbow opens outward during recovery; planted arms extend.
    local elbow=side==0 and 6 or 17
    limb(arms,{shoulder,16},{elbow,math.floor((hy+16)/2)},{hx,hy})
    stamp(arms,{'111','131','111'},hx-1,math.max(0,hy-1))
  end
  cel(climb,parts[1],n,legs);cel(climb,parts[2],n,arms)
  local body=Image(24,48,ColorMode.INDEXED)
  stamp(body,{'..111111..','.12211221.','1233113321','1231111321','.11333311.','.13211231.','.13111131.','..133331..','..113311..','..122221..','..111111..','..133331..'},7,14)
  cel(climb,parts[3],n,body)
  local helmet=Image(24,48,ColorMode.INDEXED)
  stamp(helmet,{'..1111..','.133331.','13222231','13111131','11222211','.111111.','..1111..'},8,8)
  cel(climb,parts[4],n,helmet)
end
local t=climb:newTag(1,8);t.name='climb'
climb:saveAs('art/solbrain/climb.aseprite')
print('Created slide and climb Aseprite masters')
