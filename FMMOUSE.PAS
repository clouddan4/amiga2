(* mouse.lib *)
unit fmmouse;
{$F+}
{$O+}
Interface
uses crt,DOS,agraph2,framelib;

const
  mousevector = $99;

type
  mousecursorformt = record
                       xpos : byte;
                       ypos : byte;
                       form : array[0..67 ] of byte;
                     end;

  mouseregt = registers;
  sflags = array[0..15] of boolean;
  anystring = string[80];

var gridx,gridy,temp_gridx,temp_gridy,
    oldgridx,oldgridy : byte;
    oldmousexyshow,mousexyshow : boolean;
    kanjibuffer : array[0..31] of byte;
    ankbuffer : array[0..15] of byte;
    smx,smy,emx,emy,tmx,tmy : integer;

(* ------------ menu ----------------- *)
type
  menustrtype = string[80];
  menutype = record
    menustr1 : menustrtype;
    menustr2 : menustrtype;
    orgcol   : integer;
    itemcols : integer;
    lastitem : integer;
  end;
  undermenu = array[0..maxplane,0..15] of lustert;

const
  pointnothing = -1;

function mousealive : boolean;
procedure showmouse;
procedure hidemouse;
procedure mousestat(var x,y : integer ; var ron,lon : boolean );
procedure mouseposition(x,y:integer);
procedure offbutton;
procedure mousecursorform(cursorform: mousecursorformt );
procedure mickeymouse(xm,ym : integer);
procedure MouseClose;
procedure mouseinit;
procedure kanjipatnget(d1,d2 : byte);
procedure ankpatnget(d1 : byte);
function isK1(c:char):Boolean;
function isK2(c:char):Boolean;
procedure SJtoJ(S1,S2: integer; VAR J1,J2: integer);
procedure keybufferclear;

procedure revpset( x,y:integer);
procedure xorpset(x,y: integer);
procedure crosscursor(x,y:integer);
procedure revbox(x1,y1,x2,y2 : integer);
procedure revxyline(x,y:integer);
procedure revLine( x1,y1,x2,y2: integer);
procedure revCircle( xc,yc,xx,yy: integer);
function select2point(var xx,yy,x,y :integer):boolean;

procedure openmenuwindow( var temp:undermenu);
procedure closemenuwindow( var temp : undermenu );
procedure putmenu( themenu: menutype; markitem: integer);
function touchitem(var themenu: menutype; var item: integer): boolean;
function getitem(themenu : menutype; var item : integer ): boolean;
function askok( msg : menustrtype ) : boolean;


Implementation

function mousealive : boolean;
var reg : mouseregt;
begin
  reg.ah := 0;
  intr( mousevector,reg);
  mousealive := (reg.ah = $00);
end;

procedure showmouse;
var reg : mouseregt;
begin
  reg.ah := $02;
  reg.al := $00;
  intr( mousevector,reg);
end;

procedure hidemouse;
var reg : mouseregt;
begin
  reg.ah := $02;
  reg.al := $01;
  intr( mousevector,reg);
end;

procedure mousestat(var x,y : integer ; var ron,lon : boolean );
var reg : mouseregt;
var butt : byte;
begin
  reg.ah := $03;
  intr( mousevector,reg);
  x := reg.dx;
  if gridx <> 1 then x := x - (x mod gridx);
  y := reg.bx;
  if gridy <> 1 then y := y - (y mod gridy);
  butt := reg.ch;
  ron := (butt = 2 );
  lon := (butt = 1 );
  if mousexyshow = true then
  begin
    gotoxy(65,1);
    write(x,':',y,'   ')
  end;

end;

procedure mouseposition(x,y:integer);
var reg : mouseregt;
begin
  reg.ah := $04;
  reg.dx := x;
  reg.bx := y;
  intr( mousevector,reg);
end;

procedure offbutton;
var reg : mouseregt;
begin
  repeat
    reg.ah := $06;
    intr(mousevector,reg);
  until reg.ch = $00;
end;



procedure mousecursorform(cursorform: mousecursorformt );
var reg : mouseregt;
begin
  reg.ah := $09;
  with cursorform do
  begin
    reg.dh := xpos;
    reg.dl := ypos;
    reg.ds := seg(form);
    reg.di := ofs(form);
  end;
  intr(mousevector,reg);
end;


procedure mickeymouse(xm,ym : integer);
var reg : mouseregt;
begin
  reg.ah := $0C;
  reg.dh := xm;
  reg.dl := ym;
  intr(mousevector,reg);
end;

procedure MouseClose;
var reg : mouseregt;
begin
  reg.ah := $01;
  intr(mousevector,reg);
end;

procedure mouseinit;
const
  defaultcursor : mousecursorformt = (
    xpos : 0;
    ypos : 0;
    form : ( 16,
             16,
             7,0,
             $00,$1f,$00,$1f,$00,$3f,$00,$7f,
             $00,$ff,$00,$7f,$00,$3f,$00,$1f,
             $08,$0f,$1c,$07,$3e,$03,$ff,$01,
             $ff,$80,$ff,$c1,$ff,$e3,$ff,$f7,

             $00,$00,$7f,$c0,$7f,$80,$7f,$00,
             $7e,$00,$7f,$00,$7f,$80,$77,$c0,
             $63,$e0,$41,$f0,$00,$f8,$00,$7c,
             $00,$3e,$00,$1c,$00,$08,$00,$00 ));
begin
  mickeymouse(8,8);
  mousecursorform(defaultcursor);
end;
(* ------------------------------------------------- *)
procedure kanjipatnget(d1,d2 : byte);
var   reg : registers;
begin
  reg.ah := $07;
  reg.dh := 16;
  reg.dl := 16;
  reg.bh := d2;
  reg.bl := d1;
  reg.ds := seg(kanjibuffer);
  reg.di := ofs(kanjibuffer);
  intr($91,reg);
end;
procedure ankpatnget(d1 : byte);
var   reg : registers;
begin
  reg.ah := $07;
  reg.dh := 8;
  reg.dl := 16;
  reg.bx := d1;
  reg.ds := seg(ankbuffer);
  reg.di := ofs(ankbuffer);
  intr($91,reg);
end;

function isK1(c:char):Boolean;
begin
  case c of
    #$81..#$9F, #$E0..#$FC: isK1 := true;
  else
    isK1 := false
  end
end {isK1};

function isK2(c:char):Boolean;
begin
  isK2 := (c>=#$40) and (c<=#$FC) and (c<>#$7F)
end {isK2};

procedure SJtoJ(S1,S2: integer; VAR J1,J2: integer);
begin
  if S2 < $9F then
  begin              (* J1Ê ·½³ *)
    J1 := 1;
    if S2 > $7F then J2 := S2 - $20 else J2 := S2 - $1F
  end else
  begin
    J1 := 2; J2 := S2 - $7E
  end ;
  if S1<=$9F then J1 := J1 + (S1-$71)*2 else J1 := J1 + (S1-$B1)*2
end ;

procedure keybufferclear;
var   reg : registers;
begin
  reg.ah := $06;
  reg.al := 0;
  intr($90,reg);
end;

procedure revpset( x,y:integer);
var
  xpos,daddr,onpattern,offpattern,dumy: byte;
begin
  if (x > rmaxhor) or (x < 0) or (y > rmaxver) or (y < 0 ) then exit;
  xpos := x shr 3;
  daddr := x and 7;
  onpattern := $80 shr daddr;
  offpattern := not onpattern;
  mem[$c000:$ff81] := $c8;
  dumy := vram0[y,xpos];
  vram0[ y,xpos ] := (not(dumy and onpattern)) and (dumy or onpattern);
  mem[$c000:$ff81] := $84;
  dumy := vram0[y,xpos];
  vram0[ y,xpos ] := (not(dumy and onpattern)) and (dumy or onpattern)
end;

procedure xorpset(x,y: integer);
var
  c : byte;
begin
  c := point(x,y);
  c := c xor $0F;
  pset(x,y,c)
end;

procedure crosscursor(x,y:integer);
begin
  revpset(x-4,y); revpset(x-3,y);
  revpset(x-2,y); revpset(x-1,y);
  revpset(x+1,y); revpset(x+2,y);
  revpset(x+3,y); revpset(x+4,y);
  revpset(x,y-4); revpset(x,y-3);
  revpset(x,y-2); revpset(x,y-1);
  revpset(x,y-2); revpset(x,y+2);
  revpset(x,y+3); revpset(x,y+4)
end;

procedure revbox(x1,y1,x2,y2 : integer);
var i,xx1,yy1,xx2,yy2 : integer;
begin
  if (x1 <> x2) or (x1 <> x2) then
  begin
    if x1 > x2 then
    begin
      xx1 := x1;
      xx2 := x2
    end else
    begin
      xx1 := x2;
      xx2 := x1
    end;
    if y1 > y2 then
    begin
      yy1 := y1;
      yy2 := y2
    end else
    begin
      yy1 := y2;
      yy2 := y1
    end;
    for i := x1 to x2 do
    begin
      revpset(i,y1);
      revpset(i,y2)
    end;
    for i := y1 to y2 do
    begin
      revpset(x1,i);
      revpset(x2,i)
    end
  end
end;

procedure revxyline(x,y:integer);
var i : integer;
begin
 for i := 0 to rmaxhor do
   revpset(i,y);
 for i := 0 to rmaxver do
   revpset(x,i);
end;

procedure revLine( x1,y1,x2,y2: integer);
var sx,sy,dx,dy,i,s,x,y: integer;
begin
  if x2>x1 then sx := 1
           else sx := -1;
  if y2>y1 then sy := 1
           else sy := -1;
  dx := abs( x2 - x1 );
  dy := abs( y2 - y1 );
  if dx > dy then
  begin
    s := dx shr 1;
    for i := 0 to dx do
    begin
      revPset( x1,y1);
      s := s + dy;
      if s > dx then
      begin
        s := s - dx;
        y1 := y1 + sy
      end;
      x1 := x1 + sx
    end
  end else
  begin
    s := dy shr 1;
    for i := 0 to dy do
    begin
      revPset( x1,y1);
      s := s + dx;
      if s > dy then
      begin
        s := s - dy;
        x1 := x1 + sx
      end;
      y1 := y1 + sy
    end
  end
end;
procedure revCircle( xc,yc,xx,yy: integer);
var r,xi,yi,delta,deltaI,Limit: integer;
    realx,realy,realr : real;
begin
  realx := xx-xc;
  realx := realx*realx;
  realy := yy-yc;
  realy := realy*realy;
  realr := sqrt(realx+realy);
  r := round(realr);
  xi := 0;
  yi := R;
  deltaI := (1-R) shl 1;
  Limit := 0;
  while yi>=Limit do
    begin
      revPset(xc+xi,yc+yi);
      revPset(xc+xi,yc-yi);
      revPset(xc-xi,yc+yi);
      revPset(xc-xi,yc-yi);
      if deltaI<0 then
        begin
          delta := deltaI shl 1 + yi shl 1 - 1;
          if delta<=0 then
            begin
              inc(xi);
              deltaI := deltaI + xi shl 1 + 1;
            end
          else {delta>0}
            begin
              inc(xi);
              dec(yi);;
              deltaI := deltaI + xi shl 1 - yi shl 1 + 2;
            end;
        end
      else if deltaI>0 then
        begin
          delta := deltaI shl 1 - xi shl 1 - 1;
          if delta<=0 then
            begin
              inc(xi);
              dec(yi);
              deltaI := deltaI + xi shl 1 - yi shl 1 + 2;
            end
          else {delta>0}
            begin
              dec(yi);
              deltaI := deltaI - yi shl 1 + 1;
            end
        end
      else {deltaI=0}
        begin
          inc(xi);
          dec(yi);
          deltaI := deltaI + xi shl 1 - yi shl 1 + 2;
        end;
    end;
end;{of cirlce}

function select2point(var xx,yy,x,y :integer):boolean;
var
  rbutton,lbutton : boolean;
begin
  repeat
    mousestat(xx,yy,rbutton,lbutton);
    revxyline(xx,yy); revxyline(xx,yy);
    if lbutton then
    begin
      repeat
        mousestat(x,y,rbutton,lbutton);
        revxyline(x,y); revxyline(x,y);
        revline(xx,yy,x,y); revline(xx,yy,x,y);
      until not lbutton;
      select2point := true;
      exit;
    end
  until rbutton;
  select2point := false
end;

(* ------------ menu ----------------- *)
procedure openmenuwindow( var temp:undermenu);
var
  p,y : integer;
begin
  oldgridx := gridx;
  oldgridy := gridy;
  gridx := 1;
  gridy := 1;
  oldmousexyshow := mousexyshow;
  mousexyshow := false;
  for p := 0 to maxplane do
  begin
    if p = 0 then mem[$c000:$ff81] := $1;
    if p = 1 then mem[$c000:$ff81] := $42;
    if p = 2 then mem[$c000:$ff81] := $84;
    if p = 3 then mem[$c000:$ff81] := $c8;
          Frame[0, p] := Ptr(VramSeg[p], 0);
    for y := 0 to 15 do
      temp[p,y] := frame[0,p]^[y];
    if p = 0 then fillchar( frame[0,p]^,80*16,$ff)
             else fillchar( frame[0,p]^,80*16,0);
  end;
end;

procedure closemenuwindow( var temp : undermenu );
var
  p,y : integer;
begin
  offbutton;
  for p := 0 to maxplane do 
  begin
    if p = 0 then mem[$c000:$ff81] := $1;
    if p = 1 then mem[$c000:$ff81] := $42;
    if p = 2 then mem[$c000:$ff81] := $84;
    if p = 3 then mem[$c000:$ff81] := $c8;
          Frame[0, p] := Ptr(VramSeg[p], 0);
    for y := 0 to 15 do
      frame[0,p]^[y] := temp[p,y]
  end;   
  gridx := oldgridx;
  gridy := oldgridy; 
  mousexyshow := oldmousexyshow;
  clrscr;
end;

procedure putmenu( themenu: menutype; markitem: integer);
var
  p,markstart,markend: integer;
  menustr : menustrtype;
begin
  with themenu do
  begin
    menustr := menustr1 + menustr2;
    gotoxy(1,1);
    write(menustr);
    if markitem in [0..lastitem] then
    begin
      markstart := orgcol + markitem * itemcols;
      markend   := markstart + itemcols -2 ;
      gotoxy(markstart,1);
      textcolor(14);
      for p := markstart to markend do
        write(menustr[p] );
      textcolor(2);
      offbutton;
    end;
  end;
end;

function touchitem(var themenu: menutype; var item: integer): boolean;
var
  x,y,column,i : integer;
  rbutton,lbutton,pointed : boolean;
begin
  showmouse;
  pointed := false;
  repeat
    mousestat(x,y,rbutton,lbutton);
    if lbutton and ( y < 16 ) then
    begin
      column := x div 8 + 1 - themenu.orgcol;
      if column >= 0 then
      begin
        i := column div themenu.itemcols;
        if i in [0..themenu.lastitem] then
        begin
          pointed := true;
          item := i;
        end;
      end;
    end;
  until rbutton or pointed;
  hidemouse;
  offbutton;
  touchitem := pointed;
end;

function getitem(themenu : menutype; var item : integer ): boolean;
var
  temporary : undermenu;
  ok : boolean;
begin
  openmenuwindow(temporary);
  putmenu(themenu,item);
  getitem := touchitem(themenu,item);
  putmenu(themenu,item);
  closemenuwindow(temporary);
end;

function askok( msg : menustrtype ) : boolean;
var
  askmenu : menutype;
  item    : integer;
begin
  with askmenu do
  begin
    orgcol := length(msg) + 1;
    menustr1 := msg;
    menustr2 := '[ yes ][ no  ]';
    itemcols := 7;
    lastitem := 1;
  end;
  askok := false;
  item := pointnothing;
  if getitem(askmenu,item) then
    if item = 0 then
      askok := true;
end;


begin
  mousexyshow := false;
  smx := 0; smy := 0;
  emx := 0; emy := 0;
  tmx := 0; tmy := 0;
  gridx := 1; gridy := 1;
  temp_gridx := 16; temp_gridy := 16;
end.