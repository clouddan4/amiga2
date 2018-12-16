(*=============================================================================
	FMR-50 Graphic common unit for TURBO PASCAL 5.0
	By nozi 96/05/19 , 97/02/05
=============================================================================*)
unit agraph2;
{$O-}

Interface
uses crt,DOS;

(*-- system -------------------------------*)
type
	byteptr		= ^byte;
	wordptr		= ^word;
	pointerUnion= record case pointer of
		0:(ofs,seg	: word );
		1:(p		: pointer );
		2:(bp		: byteptr );
		3:(wp		: wordptr );
	end;

(*-- graphics -----------------------------*)
const
	BPLANE = $C000;		{ VRAM seg }
	RPLANE = $C000;
	GPLANE = $C000;
	IPLANE = $C000;
	maxhor = 319;
	maxver = 199;
	Rmaxhor = 639;
	Rmaxver = 399;
	maxcol = 15;
	MAXCOLOR = 15;
	out_of_frame = 255;
	aspect_ratio = 1;
        HorBytes = 79;
        MaxPlane = 3;
	VramSeg: array[0..MAXPLANE] of word = (BPLANE, RPLANE, GPLANE, IPLANE);

type
	LusterT		= array[0..HorBytes] of byte;
	VramT		= array[0..Rmaxver] of LusterT;
	picflnam = string[80];
        SmoothType = ( Lgr, Smr, Avg);
        dithtype = array[1..4] of integer;

const   Dither: array[1..4] of dithtype = (
        (10,  4, 14,  0),
        (14,  5,  1,  8),
        ( 2,  9, 13,  7),
        ( 6, 11,  3, 12));
var
	YPOSTBL		: array [0..408] of word;
	XPOSTBL		: array [0..639] of byte;
	XBITTBL		: array [0..639] of byte;

	vram0	: VramT absolute BPLANE:0;
	vram1	: VramT absolute RPLANE:0;
	vram2	: VramT absolute GPLANE:0;
	vram3	: VramT absolute IPLANE:0;

	vram    : array[0..MaxPlane] of ^VramT;
        vramb   : ^vramT;
        Stype   : smoothtype;

(*-- child communicate ------------------------*)
const
	MPS_ID='MPS.EXE ver1.00'+#$1a;

type
	PenPatternT	= array[0..15] of word;
	TilePatternT= array[0..3,0..15] of word;
	TonePatternT= array[0..15] of word;

	SystemWorkT	= record
		ID			: Array[0..15]of char;
		PenPattern	: array[0..15]of PenPatternT;
		TonePattern	: array[0..15]of TonePatternT;
		TilePattern	: array[0..15]of TilePatternT;
		Mask		: array[0..15]of Boolean;
		Pen			: Byte;
		Tone		: Byte;
		Tile		: Byte;
		IsMask		: boolean;
		IsUnder		: boolean;
	end;

(*-- palette -----------------------------*)
type
	mcbT		= record
		id		: char;
		owner	: word;
		parasize: word;
		padding	: array[0..10]of byte;
	end;

	RGBT		= (RED,GREEN,BLUE);
	PaletteAtom	= array[RGBT] of byte;
	PaletteT	= array[0..15] of PaletteAtom;

	StayPalID_T	= array [0..9] of char;
	StayPalT	= record
		id		: StayPalID_T;
		tone	: byte;
		extflag	: byte;
		MpsWork	: ^SystemWorkT;
		palette	: PaletteT;
	end;
var
	RpalP		: ^StayPalT;
	palet           : array[0..15,0..2] of byte;
        underpalette,palettedata : PaletteT;
const
	Spal_ID		: StayPalID_T = 'pal98 grb'+char(0);
	SystemPalette	: PaletteT = (
		( 0, 0, 0),( 0, 0,12),( 0,12, 0),( 0,12,12),
		(12, 0, 0),(12, 0,12),(12,12, 0),( 7, 7, 7),
		(12,12,12),( 0, 0,15),( 0,15, 0),( 0,15,15),
		(15, 0, 0),(15, 0,15),(15,15, 0),(15,15,15)
	);
(*--EMS-----------------------------------*)
const	EMSvector = $67;			{ＥＭＭ割り込みベクトル}
	EMSerr = $ff;				{ＥＭＳユニット内エラー番号}

var	Emessage,				{メッセージ出力フラグ}
	EMSterr : boolean;			{エラー番号出力フラグ}
	EMSerror : byte;			{エラー番号格納用}
	EMSaddr  : pointer;			{ページアドレスデータ格納位置}
	EMSppage,				{物理ページ数}
	EMSlpage,				{論理ページ数}
	EMShandle : word;			{使用中のハンドル番号}


(*-- Disk    -----------------------------*)
const
  SystemDrive = 'A';
  UserDrive = 'D';
  maxdrive = 'M';

type
  flnam  =  string[80];
   text80 = flnam;
   filename = string[12];
   filelist = array[1..255] of filename;
   regtypefl = registers;

var
  source,
  destination,
  asource,
  adestination,bmaskz,bmaskp : flnam;
  animno,animframe,animofset : integer;

  readfileok : boolean;

(*-- Turtle3    -----------------------------*)
const
  homex = 160; { maxhor / 2 }
  homey = 100; { maxver / 2 }

type
  xyz   = ( x,y,z );
  pos3d = array[ xyz ] of real;
  mat3d = array[ xyz,xyz ] of real;
  turtle = record
             position : pos3d;
             heading  : mat3d;
             pencolor : integer;
             pen      : boolean;
             phase    : integer;
           end;
var
  mama         : turtle;
  distance     : real;
  scrunch      : boolean;
  smooth_trace : boolean;

(*-- forward -----------------------------*)

procedure pset(x,y:integer;color:byte);
function  point(x,y:integer):byte;
procedure Line(x1,y1,x2,y2:integer;color:byte);
procedure DITHPLOT (X, Y, Ishade, Color1, Color2: integer);
procedure SmoothPlot(x,y:real; c:integer;
                           PType:SmoothType);
procedure SmoothLine(x1,y1,x2,y2:real;
                     color      :integer;
                     PType      :SmoothType );
procedure rline(x1,y1,x2,y2:real;color:integer);
procedure Screen_Set;
procedure G_On;
procedure G_Off;
procedure T_On;
procedure T_Off;
procedure cscreen;
procedure gscreen;
procedure gclear( color : integer );
procedure AnalogOn;
procedure AnalogOff;
procedure screenad(access,disp:byte);
procedure screeninit;

function  Search_StayPal:pointer;
procedure PaletteSet(palette:PaletteT);
procedure setRGBpalette(color,r,g,b:integer);
procedure getRGBpalette;
procedure getRpalette;
procedure setRpalette;
procedure graypalette;
procedure palette(color : byte; RGB : RGBT; value: byte );
procedure defpalette(color,r,g,b : byte);
procedure defpaletteset(paletteset : palettet);

function  HexStr(num:word):string;
function  pitago(x,y:real):real;

procedure EMScall(var R : registers);		{ＥＭＭファンクションコール}
function  Eexist : boolean;			{ＥＭＳの存在を調べる}
function  EstatOK : boolean;			{ＥＭＳのステータスを調べる}
function  Ever : byte;				{ＥＭＳバージョンの取得}
function  Etpage : word;			{総ページ数取得}
function  Eupage : word;			{未使用ページ数取得}
procedure Egetppagedata;			{物理ページデータの格納}
function  Eppageseg(page : word) : word;	{物理ページのセグメント取得}
procedure Egetlpage(page : word);		{論理ページの取得}
procedure Eregetlpage(page : word);		{論理ページの割り付け変更}
procedure Emapping(phys, logi : word);		{マッピング}
procedure Efree;				{ＥＭＳの解放}
function  Eread(page, offset : word) : byte;	{データ読み込み}
procedure Ewrite(page, offset : word; data : byte);{データ書き込み}
procedure emsinit;

procedure select_drive( drv : char );
function current_drive : char;
procedure diskreset;
function exist(filename : flnam) : boolean;

procedure wait;
function inkey : char;
procedure inputI( var i: integer );
procedure inputR( var i: real );
procedure beep;
function existsys : boolean;

procedure cursoron ;
procedure cursoroff;
procedure SystemLine(sw:byte);

function fileready( var name : flnam ) : boolean;

procedure SORTFILES (var Fnames: filelist; Nfiles: integer);
procedure DISP_NAME (var Fnames: filelist; Fnum, Dispfrst, Fcolor,
  Bcolor: integer);
procedure REFRESH_FILES (var Fnames: filelist; Select, Dispfrst,
  Displast: integer);
procedure FILE_SELECT (Fmask: text80; var Flnm: text80);

procedure scrntoems( i : integer);
procedure scrn1toems( i : integer);
procedure emstoscrn(i:integer);
procedure emstoscrn1(i:integer);
procedure hscopy(n:integer);
procedure scrn0to1;
procedure scrn1to0;

procedure iffsave(fl : picflnam; sw : integer);
procedure iffload( fl : picflnam);
procedure useiffcolor;
procedure useiffcolor0;
procedure exiffcolor(i:integer);  (* i=0 320*200   i=1 640*400 *)
procedure MagDecode(filename : picflnam);

procedure textscreen;
procedure fullscreen;
procedure clear;
procedure penup;
procedure pendown;
procedure setpc( color : integer );
procedure fat;
procedure thin;
procedure turtle_line(x1,y1,x2,y2: real; c: integer);
procedure setdistance( d : real );
procedure draw3d( p1,p2 : pos3d );
procedure fd( st : real );
procedure jp( st : real );
procedure lt( a : real );
procedure rt( a : real );
procedure ut( a : real );
procedure dt( a : real );
procedure spin( a : real );
procedure mirror;
procedure setpos( px,py,pz : real );
procedure setheading( a : real );
procedure home;
procedure clearscreen;

Implementation
(*===========================================================================*)
(* Pset and Pget *)

procedure pset( x,y:integer;color:byte );
var
  xpos,daddr,onpattern,offpattern: byte;
begin
  if (x >639) or (x < 0) or (y > 399) or (y < 0 ) then exit;
  xpos := x shr 3;
  daddr := x and 7;
  onpattern := $80 shr daddr;
  offpattern := not onpattern;
  mem[$c000:$ff81] := $1;
  if (color and 1)=0
    then vram0[ y,xpos ] := vram0[ y,xpos] and offpattern
    else vram0[ y,xpos ] := vram0[ y,xpos] or onpattern;
  mem[$c000:$ff81] := $42;
  if (color and 2)=0
    then vram0[ y,xpos ] := vram0[ y,xpos] and offpattern
    else vram0[ y,xpos ] := vram0[ y,xpos] or onpattern;
  mem[$c000:$ff81] := $84;
  if (color and 4)=0
    then vram0[ y,xpos ] := vram0[ y,xpos] and offpattern
    else vram0[ y,xpos ] := vram0[ y,xpos] or onpattern;
  mem[$c000:$ff81] := $c8;
  if (color and 8)=0
    then vram0[ y,xpos ] := vram0[ y,xpos] and offpattern
    else vram0[ y,xpos ] := vram0[ y,xpos] or onpattern;
end;


function point( x,y : integer ) : byte;
var
  color : byte;
  xpos,xaddr,onpattern : byte;
begin
  if (x > 639) or (x < 0) or (y > 399) or (y < 0) then
    begin
      point := 0;
      exit;
    end;
  xpos := x shr 3;
  xaddr := x and 7;
  onpattern := $80 shr xaddr;
  color := 0;
  mem[$c000:$ff81] := $1;
  if onpattern and vram0[y,xpos] <> 0 then color := color or 1;
  mem[$c000:$ff81] := $42;
  if onpattern and vram0[y,xpos] <> 0 then color := color or 2;
  mem[$c000:$ff81] := $84;
  if onpattern and vram0[y,xpos] <> 0 then color := color or 4;
  mem[$c000:$ff81] := $c8;
  if onpattern and vram0[y,xpos] <> 0 then color := color or 8;
  point := color;
end;


procedure InitTbl;
var	i	: word;
begin
	for i:=0 to 408 do YPOSTBL[i]:=i*80;
	for i:=0 to 639 do begin
		XPOSTBL[i]:=i shr 3;
		XBITTBL[i]:=$80 shr (i and 7);
	end;
end;

procedure DITHPLOT (X, Y, Ishade, Color1, Color2: integer);
{ dithered pixel plot command }
var Xmod, Ymod: integer;    { X & Y coords modulo 4. This is the place in }
                            { the dither matrix }
begin
  Xmod := X mod 4 + 1;
  Ymod := Y mod 4 + 1;
  if (Ishade > Dither[Xmod][Ymod]) then
    pset(X, Y, Color1)
  else
    pset(X, Y, Color2);
end; { procedure DITHPLOT }

procedure Line(x1,y1,x2,y2:integer;color:byte);
var sx,sy,dx,dy,i,s,x,y:integer;
begin
  if x2 > x1 then sx := 1
             else sx := -1;
  if y2 > y1 then sy := 1
             else sy := -1;
  dx := abs( x2 - x1 );
  dy := abs( y2 - y1 );
  if dx > dy then
    begin
      s := dx shr 1;
      for i :=0 to dx do
        begin
          pset(x1,y1,color);
          s := s + dy;
          if s > dx then
            begin
              s := s - dx;
              y1 := y1 + sy
            end;
          x1 := x1 + sx
        end
      end
    else
      begin
        s := dy shr 1;
        for i := 0 to dy do
          begin
            pset(x1,y1,color);
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
procedure SmoothPlot(x,y:real; c:integer;PType:SmoothType);
var
  xm,ym : real;
  xo,yo : integer;

  function ftoc( f : real; Color:integer ) : integer;
  begin
    if f > 0 then
      ftoc := round( sqrt( f ) * Color )
    else
      ftoc := 0
  end;

  procedure LSPlot( x,y : integer; ratio : real);
  var
    OldC,NewC : integer;
    r         : real;
  begin
    OldC := point(x,y);
    case PType of
      lgr:begin
            NewC := ftoc(ratio,c);
            if NewC > OldC then Pset(x,y,NewC);
          end;
      smr:begin
            NewC := ftoc(ratio,Maxcol - c );
            if NewC > ( Maxcol - OldC ) then
              pset(x,y,maxcol - NewC);
          end;
      avg:pset(x,y,round(c*ratio+OldC*(1-ratio)));
    end;
  end;

begin
  xo := trunc( x );
  yo := trunc( y );
  xm := x - xo;
  ym := y - yo;
  LSPlot(xo  ,yo,  (1-xm)*(1-ym));
  LSPlot(xo+1,yo,  xm*(1-ym));
  LSPlot(xo,  yo+1,(1-xm)*ym);
  LSPlot(xo+1,yo+1,xm*ym);
end;


procedure SmoothLine(x1,y1,x2,y2:real;
                     color      :integer;
                     PType      :SmoothType );
var
  dx,dy,ix,iy,x,y,sqr1 : real;
  points,i : integer;

begin
  dx := x2 - x1;
  dy := y2 - y1;
  if abs( dx ) > abs( dy ) then
    points := trunc( abs( dx ) ) + 1
  else
    points := trunc( abs( dy ) ) + 1;
  ix := dx / points;
  iy := dy / points;
  x := x1;
  y := y1;
  for i := 0 to points do
    begin
      smoothplot( x,y,color,PType );
      x := x + ix;
      y := y + iy
    end
end;
procedure RLine( x1,y1,x2,y2: real; color: integer );
begin
  line(round(x1),round(y1),round(x2),round(y2),color)
end;


(*===========================================================================*)
(* Graphic Init *)

procedure Screen_Set;
begin
  mem[$c000:$ffa0] := $00;
  mem[$c000:$ff82] := $67;
  mem[$c000:$ff81] := $0f;
end;

procedure G_On;
begin
  port[$fda0]:=$0f;
(*  Mem[$c000:$ff82]:=$67; *)
end;

procedure G_Off;
begin
  port[$fda0]:=$03;
(*  Mem[$c000:$ff82]:=$40; *)
end;

procedure T_On;
begin
end;

procedure T_Off;
begin
  clrscr;
end;

procedure gclear( color : integer );
var x,y : integer;
begin
  for y :=0 to maxver do
    for x :=0 to maxhor do
      pset(x,y,color)
end;
procedure AnalogOn;
begin
end;

procedure AnalogOff;
begin
end;

procedure screenad(access,disp:byte);
begin
  if access = 0
    then Mem[$c000:$ff83] := $00
    else Mem[$c000:$ff83] := $18;
  if Disp = 0
    then Mem[$c000:$ff82] := $67
    else Mem[$c000:$ff82] := $7f;
end;

procedure cscreen;
begin
  T_on;
  clrscr;
end;
procedure gscreen;
begin
  G_on;
  clrscr;
end;


procedure screeninit;
begin
	Screen_Set;
	AnalogOn;
	screenad(0,0);
	G_On;
end;
(*===========================================================================*)
(* Palette Set *)

function Search_StayPal:pointer;
begin
	Search_StayPal:=nil;
end;

procedure PaletteSet(palette:PaletteT);
var	i:integer;
       rr,gg,bb,cc:byte;
begin
	for i:=0 to 15 do
        begin
	  gg:=palette[i,GREEN] shl 4;
	  rr:=palette[i,  RED] shl 4;
	  bb:=palette[i, BLUE] shl 4;
	  cc := i;
	  port[$fd90] := cc;
     	  port[$fd92] := bb;
  	  port[$fd94] := rr;
  	  port[$fd96] := gg
	end;
end;

procedure setRGBpalette( color,r,g,b : integer );
var rr,gg,bb,cc : byte;
begin

  cc :=color;
  rr :=r;
  gg :=g;
  bb :=b;
  rr :=rr shl 4;
  gg :=gg shl 4;
  bb :=bb shl 4;

  port[$fd90] := cc;
  port[$fd92] := bb;
  port[$fd94] := rr;
  port[$fd96] := gg;

end;


procedure setRpalette;
begin
end;

procedure getRpalette;
begin
end;

procedure getRGBpalette;
var r,g,b,i : byte;
begin
  for i := 0 to 15 do
    begin
      port[$fd90] := i;
      b := port[$fd92];
      r := port[$fd94];
      g := port[$fd96];
      r := r shr 4;
      g := g shr 4;
      b := b shr 4;
      palet[i,0] := r;
      palet[i,1] := g;
      palet[i,2] := b
   end;
end;

procedure graypalette;
var
  c : integer;
begin
  for c := 0 to 15 do
    setRGBpalette( c,c,c,c )
end;

procedure palette(color : byte;RGB : RGBT; value: byte );
begin
  port[$fd90] := color;
  case rgb of
    RED   : begin
              port[$fd94] := value shl 4;
              palettedata[color,red] := value;
            end;
    GREEN : begin
              port[$fd96] := value shl 4;
              palettedata[color,green] := value;
            end;
    BLUE  : begin
              port[$fd92] := value shl 4;
              palettedata[color,blue] := value;
            end;
  end;
end;



procedure defpalette(color,r,g,b : byte);
begin
  palette(color,red,r);
  palette(color,green,g);
  palette(color,blue,b);
end;

procedure defpaletteset(paletteset : palettet);
var
  c : integer;
  rgb : rgbt;
begin
  for c := 0 to maxcolor do
    for rgb := red to blue do
      palette(c,rgb,paletteset[c,rgb]);
end;

(*===========================================================================*)
(* etc *)
const
  hexcode : array[0..15] of char = (
	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
	);
function HexStr(num:word):string;
begin
  hexstr:='$'+
  hexcode[hi(num) shr 4 ]+
  hexcode[hi(num) and $f]+
  hexcode[lo(num) shr 4 ]+
  hexcode[lo(num) and $f] ;
end;

function  pitago(x,y:real):real;
begin
  x := x*x;
  y := y*y;
  pitago := sqrt(x+y);
end;  

(*===========================================================================*)
(* EMS *)

procedure EMScall(var R : registers);
begin
    intr(EMSvector,R);
    if (R.ah <> 0) and EMSterr then writeln('EMS error ; no.',R.ah);
    EMSerror := R.ah
end;

function Eexist : boolean;
var	R : registers;
	EMSstr : string[8];
	i : byte;
begin
    EMSstr := 'EMMXXXX0';
    R.ah := $35;
    R.al := EMSvector;
    intr($21,R);
    for i := 1 to 8 do
	if mem[R.es : $0009+i] <> ord(EMSstr[i]) then begin
	    Eexist := false;
	    if Emessage then writeln('EMMが存在しません.');
	    exit
	end;
    Eexist := true
end;

function EstatOK : boolean;
var	R : registers;
begin
    R.ah := $40;
    EMScall(R);
    if (R.ah <> $00) and Emessage then writeln('EMSが異常です.');
    EstatOK := (R.ah = $00)
end;

function Ever : byte;
var	R : registers;
begin
    R.ah := $46;
    EMScall(R);
    Ever := R.al
end;

function Etpage : word;
var	R : registers;
begin
    R.ah := $42;
    EMScall(R);
    Etpage := R.dx
end;

function Eupage : word;
var	R : registers;
begin
    R.ah := $42;
    EMScall(R);
    Eupage := R.bx
end;

procedure Egetppagedata;
var	R : registers;
	i : byte;
begin
    if Ever = $32 then begin	{EMS ver 3.2 の場合}
	R.ah := $41;
	EMScall(R);
	EMSppage := 4;
	if memavail < 16 then begin
	    if Emessage then writeln('EMSデータ用メモリが足りません.');
	    EMSerror := EMSerr;
	    exit
	end;
	getmem(EMSaddr,16);
	for i := 0 to 3 do begin
	    memw[seg(EMSaddr^):ofs(EMSaddr^)+i*4] := R.bx + i*$400;
	    memw[seg(EMSaddr^):ofs(EMSaddr^)+i*4+2] := i
	end
    end
    else begin			{EMS ver 4.0 の場合}
	R.ax := $5801;
	EMScall(R);
	EMSppage := R.cx;
	if memavail < EMSppage*4 then begin
	    if Emessage then writeln('EMSデータ用メモリが足りません.');
	    EMSerror := EMSerr;
	    exit
	end;
	getmem(EMSaddr,EMSppage*4);
	R.ax := $5800;
	R.es := seg(EMSaddr^);
	R.di := ofs(EMSaddr^);
	EMScall(R)
    end
end;

function Eppageseg(page : word) : word;
begin
    Eppageseg := memw[seg(EMSaddr^):ofs(EMSaddr^)+(page-1)*4]
end;

procedure Egetlpage(page : word);
var	R : registers;
begin
    if Ever = $32 then begin	{EMS ver 3.2 の場合}
	R.ah := $43;
	R.bx := page;
	EMScall(R)
    end
    else begin			{EMS ver 4.0 の場合}
	R.ax := $5a00;
	R.bx := page;
	EMScall(R)
    end;
    if R.ah = 0 then begin
	EMSlpage := page;
	EMShandle := R.dx;
	if Emessage then writeln('ＥＭＳを',page,'ページ使用します.')
    end
    else begin
	if Emessage then writeln('EMSが不足しました.');
	exit
    end
end;

procedure Eregetlpage(page : word);
var	R : registers;
begin
    if Ever = $32 then begin
	if Emessage then writeln('EMS 3.2では割り当て変更はできません.');
	EMSerror := EMSerr;
	exit
    end;
    R.ah := $51;
    R.dx := EMShandle;
    R.bx := page;
    EMScall(R);
    if R.ah = 0 then begin
	EMSlpage := page;
	if Emessage then writeln('ＥＭＳを',page,'ページに変更します.')
    end
    else if Emessage and (R.ah <> $83) then writeln('EMSが不足しました,')
end;

procedure Emapping(phys, logi : word);
var	R : registers;
begin
    R.ah := $44;
    R.al := (phys-1) mod $100;
    R.bx := logi-1;
    R.dx := EMShandle;
    EMScall(R)
end;

procedure Efree;
var	R : registers;
begin
    freemem(EMSaddr,EMSppage*4);
    if EMShandle <> 0 then begin
	R.ah := $45;
	R.dx := EMShandle;
	EMScall(R);
	if EMSerror = 0 then begin
	    EMSppage := 0;
	    EMSlpage := 0;
	    EMShandle := 0;
	    if Emessage then writeln('ＥＭＳを解放しました.')
	end
    end
end;

function Eread(page, offset : word) : byte;
begin
    Eread := mem[Eppageseg(page):offset]
end;

procedure Ewrite(page, offset : word; data : byte);
begin
    if (page > EMSppage) or (page = 0) or (offset >= $4000) then begin
	EMSerror := EMSerr;
	exit
    end;
    mem[Eppageseg(page):offset] := data;
    EMSerror := 0
end;

procedure emsinit;

type	str4 = string[4];
var	i,j : word;
	l : byte;

function hexchar(num : word) : str4;
var	i, j : byte;
	tmp : str4;
begin
    tmp := '';
    for i := 1 to 4 do begin
	j := num mod $10;
	if j <= 9 then tmp := chr(ord('0')+j) + tmp
		  else tmp := chr(ord('A')+j-9) + tmp;
	num := num div $10
    end;
    hexchar := tmp
end;


begin
    if not Eexist then halt;
    if not EstatOK then halt;
    writeln('ＥＭＳの総ページ    数は ',Etpage,' ページです.');
    writeln('ＥＭＳの未使用ページ数は ',Eupage,' ページです.');
    writeln;
    writeln('物理ページデータは、以下のとおりです.');
    Egetppagedata;
    if EMSerror <> 0 then halt;
    for i := 1 to EMSppage do
	writeln('page ',i,' : Segment ',hexchar(Eppageseg(i)));
    Egetlpage(Eupage-20);

end;

(* ====================================================================== *)
(* Disk *)
procedure select_drive( drv : char );
 var
  i : integer;
begin
  if drv in[ 'A'..maxdrive ] then
    begin
      i := ord( drv ) - ord( 'A' );
      chdir(drv);
    end
end;

function current_drive : char;
var
  i : integer;
begin
(*  i := bdos( 25 );
  current_drive := chr( ord('A') + i )
*)
  current_drive := 'd';

end;

procedure diskreset;
var
  drive : char;
begin
  drive := current_drive;
{  bdos( 13 ); }
  select_drive( drive );

end;

function exist(filename : flnam) : boolean;
var
  fil : file;
begin
  {$I-}
  assign(fil,filename);
  reset(fil);
  close(fil);
  {$I+}
  exist :=( ioresult = 0 );
end;



procedure wait;
begin
  write( 'Hit any key.' );
  repeat until keypressed;
end;


{ console library }

function inkey : char;
begin
{  inkey := char( bios(2) );  }
  inkey := readkey;
end;

procedure inputI( var i: integer );
var
  error : boolean;
begin
  error := false;
  repeat
    {$I-}
      readln( i );
    {$I+}
    error := not ( ioresult = 0 );
    if error then
      write( 'Redo ! ' );
  until not ( error );
end;

procedure inputR( var i: real );
var
  error : boolean;
begin
  error := false;
  repeat
    {$I-}
      readln( i );
    {$I+}
    error := not ( ioresult = 0 );
    if error then
      write( 'Redo ! ' );
  until not ( error );
end;

procedure beep;
begin
  write(^G);
end;
function existsys : boolean;
begin
(*  if exist( systemdrive+':toolbox.com' )
    then existsys := true
    else existsys := false;
*)
    existsys := true;
end;

procedure SystemLine( sw : byte);
CONST
	ONSTR  : string[7] = ^['[>1l$';
	OFFSTR : string[7] = ^['[>1h$';
var	reg : registers;
begin
end;

procedure cursoron ;
begin
  textcursor(dispcursor)
end;

procedure cursoroff;
begin
  textcursor(nodispcursor)
end;


{ FILESEL.INC: Routines for an interactive file selector }

procedure SORTFILES (var Fnames: filelist; Nfiles: integer);

{ Shell sort a list of file names.
  Procedure as published in Tanenbaum, "Structured Computer Organization",
  Prentice-Hall, Englewood Cliffs, NJ, 1976.
}
var Dist: integer;              { sorting distance }
    K, I: integer;              { genl sorting indexes }
    Tmp:  filename;

begin

{ Determine the initial value of Dist by finding the largest power
  of 2 less than Nfiles, and subtracting 1 from it. The final step in
  this calculation is performed inside the main sorting loop.
}
  Dist := 4;
  while (Dist < Nfiles) do
    Dist := Dist + Dist;
  Dist := Dist - 1;

{ Main sorting loop. The outer loop is executed once per pass. }
  while (Dist > 1) do begin
    Dist := Dist div 2;
    for K := 1 to (Nfiles - Dist) do begin
      I := K;
      while (I > 0) do begin
        { This stmt. is the comparison. It also controls moving values
          upward after an exchange.
        }
        if (Fnames[I] > Fnames[I+Dist]) then begin
          { This is the swap }
          tmp := Fnames[I];
          Fnames[I] := Fnames[I+Dist];
          Fnames[I+Dist] := tmp;
        end else
          I := 0;      { stop the while loop! }
        I := I - Dist;
      end; { while }
    end; { for K }
  end; { while Dist }

end; { procedure SORTFILES }

{ DISP_NAME: Display a single filename in the file selector window with
  the specified foreground and background colors.
}
procedure DISP_NAME (var Fnames: filelist; Fnum, Dispfrst, Fcolor,
  Bcolor: integer);
var Row: integer;
    i: integer;

begin
  Row := Fnum - Dispfrst + 1;
  textcolor(Bcolor);
  textcolor(Fcolor);
  gotoxy (1, Row);
  write(Fnames[Fnum]);
  { Fill out rest of line with blanks }
  for i := 1 to (12 - length(Fnames[Fnum])) do
    write (' ');
  { Position cursor at start of this filename }
  gotoxy (1, Row);

end; { procedure DISP_NAME }




{ REFRESH_FILES: Refresh the list of files in the file selector window }
procedure REFRESH_FILES (var Fnames: filelist; Select, Dispfrst,
  Displast: integer);
var i: integer;
    bg: integer;    { temp for BGcol }
    txt: integer;   { temp for Textcol }

begin
  bg := 6;
  txt := 2;
  window(42, 3, 57, Displast - Dispfrst + 4);
  for i := Dispfrst to Displast do begin
    if (i <> Select) then
      disp_name (Fnames, i, Dispfrst, txt, bg);      { normal }
  end;

  { We draw the selected filename last, so the cursor is on that row: }
  disp_name (Fnames, Select, Dispfrst, bg, txt)      { highlighted }
end; { procedure REFRESH_FILES }

procedure FILE_SELECT (Fmask: text80; var Flnm: text80);
const MAXFWIN = 20;       { Max # files to display in window }

var Srch: SearchRec;
    Fnames: filelist;
    Nfiles: integer;
    Select: integer;
    Dispfrst: integer;
    Displast: integer;
    msg: text80;
    ch: char;
    Selected: boolean;
    Dir: dirstr;
    Name: namestr;
    Ext: extstr;
    txt: integer;
    bg: integer;

label DONE;

begin
  clrscr;
  writeln('<< File Mask = ',fmask,' >>');
  Nfiles := 0;
  Flnm := '';
  bg := 6;
  txt := 2;

  repeat
    { Read all the file names that match the wildcard spec }
    findfirst (Fmask, 0, Srch);
    while (Doserror = 0) and (Nfiles < 255) do begin
      Nfiles := Nfiles + 1;
      with Srch do
        Fnames[Nfiles] := Name;
      findnext (Srch);
    end;

    if (Nfiles < 1) then begin
      clrscr;
      writeln('No files found for file mask: ', Fmask);
      write('Enter new file mask, or Enter to abort: ');
      readln(Fmask);
      clrscr;
      writeln('<< File Mask = ',fmask,' >>');
      if (Fmask = '') then
        goto DONE;
    end;
  until (Nfiles > 0);

  sortfiles (Fnames, Nfiles);

  Select := 1;
  Dispfrst := 1;
  if (Nfiles > MAXFWIN) then
    Displast := MAXFWIN
  else
    Displast := Nfiles;
  refresh_files (Fnames, Select, Dispfrst, Displast);
  Flnm := Fnames[Select];
  Selected := FALSE;
  kanji := false;

  repeat
    ch := readkey;
    if (ch = #0) then begin
      { Function or arrow key pressed, get 2nd code }
      ch := readkey;

      case ch of

        #$6E: if (Select > 1) then begin         { Page up }
            Select := 1;
            Dispfrst := 1;
            if (Nfiles > MAXFWIN) then
              Displast := MAXFWIN
            else
              Displast := Nfiles;
            refresh_files (Fnames, Select, Dispfrst, Displast);
          end; { if Select > 1 }

        #$70: if (Select < Nfiles) then begin    { page down }
            Select := Nfiles;
            Displast := Nfiles;
            if (Nfiles > MAXFWIN) then
              Dispfrst := Displast - MAXFWIN + 1
            else
              Dispfrst := Displast - Nfiles + 1;
            refresh_files (Fnames, Select, Dispfrst, Displast);
          end; { if Select < Nfiles }

        else          { Invalid keypress }
          write (^G);
      end; { case ch of }
    end else begin    { if ch = 0 }
      case ch of

       #$1D: if (Select > 1) then begin         { Left arrow }
            Select := Select - MAXFWIN + 1;
            if (Select < 1) then
              Select := 1;
            Dispfrst := Dispfrst - MAXFWIN + 1;
            if (Dispfrst < 1) then
              Dispfrst := 1;
            if (Nfiles > MAXFWIN) then
              Displast := Dispfrst + MAXFWIN - 1
            else
              Displast := Dispfrst + Nfiles - 1;
            refresh_files (Fnames, Select, Dispfrst, Displast);
          end; { if Select > 1 }

       #$1C: if (Select < Nfiles) then begin    { Right arrow }
            Select := Select + MAXFWIN - 1;
            if (Select > Nfiles) then
              Select := Nfiles;
            Displast := Displast + MAXFWIN - 1;
            if (Displast > Nfiles) then
              Displast := Nfiles;
            if (Nfiles > MAXFWIN) then
              Dispfrst := Displast - MAXFWIN + 1
            else
              Dispfrst := Displast - Nfiles + 1;
            refresh_files (Fnames, Select, Dispfrst, Displast);
          end; { if Select < Nfiles }

        #$1E: if (Select > 1) then begin     { Up Arrow }
            Select := Select - 1;
            if (Select < Dispfrst) then begin
              Dispfrst := Dispfrst - 1;
              Displast := Displast - 1;
              refresh_files (Fnames, Select, Dispfrst, Displast);
            end else begin
              { Don't need to refresh entire list - just move highlight }
              { First set old name to normal: }
              disp_name (Fnames, Select+1, Dispfrst, txt, bg);
              { Then set new name to highlight: }
              disp_name (Fnames, Select, Dispfrst, bg, txt);
            end;
          end; { if Select > 1 }

        #$1F: if (Select < Nfiles) then begin    { Down Arrow }
            Select := Select + 1;
            if ( Select > Displast) then begin
              Dispfrst := Dispfrst + 1;
              Displast := Displast + 1;
              refresh_files (Fnames, Select, Dispfrst, Displast);
            end else begin
              { Don't need to refresh entire list - just move highlight }
              { First set old name to normal: }
              disp_name (Fnames, Select-1, Dispfrst, txt, bg);
              { Then set new name to highlight: }
              disp_name (Fnames, Select, Dispfrst, bg, txt);
            end;
          end; { if Select < Nfiles }


        #$0D: begin      { Enter key }
          Flnm := Fnames[Select];
          Selected := TRUE;
        end;

        #$1B: begin      { Escape key }
          Flnm := '';
          Selected := TRUE;
        end;

        else
          write (^G);
      end; { case ch of }
    end; { if ch = 0 }
  until Selected;
  kanji := true;
  if (Flnm <> '') then begin
    { Prepend the path }
    fsplit (Fmask, Dir, Name, Ext);
    Flnm := Dir + Flnm;
  end;

DONE:
  { This is the old window size from the parameters menu: }
  Window(41,1,80,24);
  textcolor(2);

end; { procedure FILE_SELECT }



function fileready( var name : flnam ) : boolean;
var
  drive : CHAR;
  ext : string[4];
  p : integer;
  inpname,mask : flnam;
begin
  drive := 'p';
  p := pos('.',name);
  if p > 0
    then ext := copy( name,p,4 )
    else ext := '';
  if ext = ''
    then mask := drive + '\*.*'
    else mask := drive + '\*' + ext ;
  file_select( mask,inpname );
  if inpname <> '' then
    begin
{      if pos( ':',inpname ) = 0 then
        inpname := drive + '\' + inpname; }
      if pos( '.',inpname ) = 0 then
        inpname := inpname + ext;
      if exist( inpname ) then
        begin
          fileready := true;
          name := inpname;
        end
      else
        begin
          writeln( inpname,' is not exist.' );
          fileready := false;
          wait
        end
    end
  else
    fileready := false;
end;

(*=====================================================================*)
(* EMS op *)

procedure scrntoems( i : integer);

var
  j,xp, yp : integer;

begin
  xp := 0;
  yp := 0;
  j  := 0;

  Emapping(1,2*i-1);
  Emapping(2,2*i);
    mem[$c000:$ff81] := $1;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            Ewrite(1,j,vram0[yp,xp]);
            inc(j)
      end;
    mem[$c000:$ff81] := $42;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            Ewrite(1,j,vram0[yp,xp]);
            inc(j)
      end;
    j := 0;
    mem[$c000:$ff81] := $84;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            Ewrite(2,j,vram0[yp,xp]);
            inc(j)
      end;
    mem[$c000:$ff81] := $c8;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            Ewrite(2,j,vram0[yp,xp]);
            inc(j)
      end;
end;

procedure scrn1toems( i : integer);

var
  j,xp, yp : integer;

begin
  xp := 0;
  yp := 0;
  j  := 0;

  Emapping(1,2*i-1);
  Emapping(2,2*i);
    mem[$c000:$ff81] := $1;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            Ewrite(1,j,vram0[yp,xp]);
            inc(j)
      end;
    mem[$c000:$ff81] := $42;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            Ewrite(1,j,vram0[yp,xp]);
            inc(j)
      end;
    j := 0;
    mem[$c000:$ff81] := $84;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            Ewrite(2,j,vram0[yp,xp]);
            inc(j)
      end;
    mem[$c000:$ff81] := $c8;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            Ewrite(2,j,vram0[yp,xp]);
            inc(j)
      end;
end;

procedure emstoscrn(i:integer);

var
  xp,yp,j,xxp:integer;
  test1,test2 : word;
begin
  xp := 0;
  yp := 0;
  j  := 0;
  Emapping(1,2*i-1);
  Emapping(2,2*i);
    test1 := memw[seg(EMSaddr^):ofs(EMSaddr^)];
    test2 := memw[seg(EMSaddr^):ofs(EMSaddr^)+4];
    mem[$c000:$ff81] := $1;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test1:j];
            inc(j)
      end;
    mem[$c000:$ff81] := $42;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test1:j];
            inc(j)
      end;
      j := 0;
    mem[$c000:$ff81] := $84;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test2:j];
            inc(j)
      end;
    mem[$c000:$ff81] := $c8;
    for yp := 0 to 199 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test2:j];
            inc(j)
      end;
 end;

procedure emstoscrn1(i:integer);

var
  xp,yp,j,xxp:integer;
  test1,test2 : word;
begin
  xp := 0;
  yp := 0;
  j  := 0;
  Emapping(1,2*i-1);
  Emapping(2,2*i);
    test1 := memw[seg(EMSaddr^):ofs(EMSaddr^)];
    test2 := memw[seg(EMSaddr^):ofs(EMSaddr^)+4];
    mem[$c000:$ff81] := $1;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test1:j];
            inc(j)
      end;
    mem[$c000:$ff81] := $42;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test1:j];
            inc(j)
      end;
      j := 0;
    mem[$c000:$ff81] := $84;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test2:j];
            inc(j)
      end;
    mem[$c000:$ff81] := $c8;
    for yp := 200 to 399 do
      for xp := 0 to 39 do
        begin
            vram0[yp,xp] := mem[test2:j];
            inc(j)
      end;
 end;

procedure hscopy(n:integer);

var
  xp,yp,xxp,dxb,dyb:integer;
begin
  xp := 0;
  yp := 0;
  case n of
    1 : begin
          dxb := 0;
          dyb := 200;
        end;
    2 : begin
          dxb := 40;
          dyb := 0;
        end;
    3 : begin
          dxb := 40;
          dyb := 200;
        end
  end;

  for xxp := 0 to 3 do begin
    case xxp of
      0 :  begin
             mem[$c000:$ff81] := $1;
           end;
      1 :  begin
             mem[$c000:$ff81] := $42;
           end;
      2 :  begin
             mem[$c000:$ff81] := $84;
           end;
      3 :  begin
             mem[$c000:$ff81] := $c8;
           end;
    end;
    for yp := 0 to 199 do

      for xp := 0 to 39 do
        begin
          vram0[yp+dyb,xp+dxb] := vram0[yp,xp];
        end;
      end;
 end;


procedure scrn0to1;
begin

  new(vramb);
  screenad(0,0);

              mem[$c000:$ff81] := $1;
              vramb^ := vram0;
              screenad(1,1);
              mem[$c000:$ff81] := $1;
              vram0 := vramb^;
              screenad(0,0);
              mem[$c000:$ff81] := $42;
              vramb^ := vram0;
              screenad(1,1);
              mem[$c000:$ff81] := $42;
              vram0 := vramb^;
              screenad(0,0);
              mem[$c000:$ff81] := $84;
              vramb^ := vram0;
              screenad(1,1);
              mem[$c000:$ff81] := $84;
              vram0 := vramb^;
              screenad(0,0);
              mem[$c000:$ff81] := $c8;
              vramb^ := vram0;
              screenad(1,1);
              mem[$c000:$ff81] := $c8;
              vram0 := vramb^;

  dispose(vramb);
  screenad(0,0)
end;

procedure scrn1to0;
begin
  new(vramb);
  screenad(1,1);
  
              mem[$c000:$ff81] := $1;
              vramb^ := vram0;
              screenad(0,0);
              mem[$c000:$ff81] := $1;
              vram0 := vramb^;
              screenad(1,1);
              mem[$c000:$ff81] := $42;
              vramb^ := vram0;
              screenad(0,0);
              mem[$c000:$ff81] := $42;
              vram0 := vramb^;
              screenad(1,1);
              mem[$c000:$ff81] := $84;
              vramb^ := vram0;
              screenad(0,0);
              mem[$c000:$ff81] := $84;
              vram0 := vramb^;
              screenad(1,1);
              mem[$c000:$ff81] := $c8;
              vramb^ := vram0;
              screenad(0,0);
              mem[$c000:$ff81] := $c8;
              vram0 := vramb^;

  dispose(vramb);
  screenad(0,0)
end;


(* ====================================================================== *)
(* IFF support *)

procedure iffsave(fl : picflnam; sw : integer);
var
  filename : picflnam;
  picfile  : file;
  fbuf     : array[1..128] of byte;
  maxv, hor_byte,
  xp,yp,xxp,i,J,JJ : integer;
  fptr,dots,data,nextdata,cc     : byte;

procedure putdata( d : byte );
  begin
    if fptr = 129 then
      begin
        {$I-}
        blockwrite( picfile,fbuf,1 );
        {$I+}
        fptr := 1
      end;
    fbuf[fptr] := d;
    fptr := fptr + 1;
  end;

begin
  filename := fl ;
  assign(picfile,filename);
  rewrite(picfile);
  fptr :=1;
  putdata($46); { F }
  putdata($4F); { O }
  putdata($52); { R }
  putdata($4D); { M }

  putdata(0);   {  ブロック本体のSIZE 4 byte }
  putdata(0);
  putdata($7D);
  putdata($90);

  putdata($49); { I }
  putdata($4C); { L }
  putdata($42); { B }
  putdata($4D); { M }
  putdata($42); { B }
  putdata($4D); { M }
  putdata($48); { H }
  putdata($44); { D }

  putdata(0); { size 4 byte }
  putdata(0);
  putdata(0);
  putdata($14);

  if sw = 0 then
  begin { 320X200 }
    putdata($01); { Width 2 byte }
    putdata($40);
    putdata($00); { Height 2 byte }
    putdata($C8);
  end else
  begin { 640X400 }
    putdata($02); { Width 2 byte }
    putdata($80);
    putdata($01); { Height 2 byte }
    putdata($90);
  end;

  putdata(0); { X position 2 byte }
  putdata(0);
  putdata(0); { Y position 2 byte }
  putdata(0);

  putdata($04); { BitPlane }
  putdata(0); { MASK }
  putdata(0); { Compression }
  putdata(0); { padbyte }
  putdata(0); { trans color 2 byte }
  putdata(0);
  putdata($0A); { X aspect }
  putdata($0B); { Y aspect }
  putdata($01); { page width 2 byte }
  putdata($40);
  putdata($00); { page height 2 byte }
  putdata($C8);

  putdata($43); { C }
  putdata($4D); { M }
  putdata($41); { A }
  putdata($50); { P }

  putdata(0); { size 4 byte }
  putdata(0);
  putdata(0);
  putdata($60);

  for j :=0 to 15 do
    for jj :=0 to 2 do
    begin
      cc := palet[j,jj];
      cc := cc shl 4;
      putdata(cc);
    end;
  for j := 0 to 15 do
  begin
    putdata(0);
    putdata(0);
    putdata(0);
  end;

  putdata($42); { B }
  putdata($4F); { O }
  putdata($44); { D }
  putdata($59); { Y }

  if sw = 0 then
  begin
    putdata(0); { size 4 byte 320X200 }
    putdata(0);
    putdata($7D);
    putdata(0);
  end else
  begin
    putdata(0); { size 4 byte 640X400 }
    putdata($01);
    putdata($F4);
    putdata(0);
  end;

  if sw = 0 then
  begin
    maxv := maxver;
    hor_byte := 39;
  end else
  begin
    maxv := Rmaxver;
    hor_byte := 79;
  end;
  
   for yp := 0 to maxv do
    for xxp := 0 to 3 do
      begin

        for xp := 0 to hor_byte do
          begin
            case xxp of
            0:begin
                mem[$c000:$ff81] := $1;
                dots := vram0[yp,xp];
                putdata(dots)
              end;
            1:begin
                mem[$c000:$ff81] := $42;
                dots := vram0[yp,xp];
                putdata(dots)
              end;
            2:begin
                mem[$c000:$ff81] := $84;
                dots := vram0[yp,xp];
                putdata(dots)
              end;
            3:begin
                mem[$c000:$ff81] := $c8;
                dots := vram0[yp,xp];
                putdata(dots)
              end;
            end;
          end;
          end;
          {$I-}
          blockwrite( picfile,fbuf,1 );
          {$I+}

          close(picfile);
        end;


procedure iffload( fl : picflnam);
var
  picfile : file;
  fbuf : array[1..128] of byte;
  axu,axl,ayu,ayl,bitp,mask,comp,flag,dumy:byte;
  xwidth,yheight,cp,iii:integer;
  fptr,dots,data,b1,b2,r,g,b:byte;
  c1,c2,xp,yp,xxp,i,ii,j,jj,m,n : integer;
  empty : boolean;
  cbuf : array[1..4] of byte;
  yesno : char;
  numread : word;

  function getdata : byte ;
  begin
    if fptr = 1 then
      if not eof(picfile) then
        {$I-}
        blockread(picfile,fbuf,1,numread)
        {$I+}
      else empty := true;
      getdata := fbuf[fptr];
      fptr := fptr + 1;
      if fptr = 129 then fptr := 1
  end;

begin
  readfileok := false;
  empty := false;
  assign(picfile,fl);
  reset(picfile);
  fptr := 1;
  for jj := 1 to 8 do
    dumy := getdata;
  dumy := getdata;
  if dumy <> $49 then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  dumy := getdata;
  if dumy <> $4C then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  dumy := getdata;
  if dumy <> $42 then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  dumy := getdata;
  if dumy <> $4D then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  dumy := getdata;
  if dumy <> $42 then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  dumy := getdata;
  if dumy <> $4D then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  dumy := getdata;
  if dumy <> $48 then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  dumy := getdata;
  if dumy <> $44 then begin
    writeln(' Not IFF Bitmap ! ');
    exit end;
  for jj := 1 to 4 do
    dumy := getdata;
   
  xwidth := getdata;
  xwidth := xwidth shl 8;
  xwidth := xwidth + getdata;
  yheight := getdata;
  yheight := yheight shl 8;
  yheight := yheight + getdata;
  dumy := getdata;
  dumy := getdata;
  dumy := getdata;
  dumy := getdata;
  bitp := getdata;
  if bitp > 4 then begin
    writeln('This Machine is not supported ! ');
    exit end;     
  mask := getdata;
  comp := getdata;
  writeln(' IFF-ILBM format');
  writeln;
  writeln('  Width    = ',xwidth);
  writeln('  Height   = ',yheight);
  writeln('  Bitplane = ',bitp);
  writeln('  Mask     = ',mask);
  writeln('  Compress = ',comp);

  dumy := getdata; { padbyte }
  dumy := getdata; { transcolor 2 byte }
  dumy := getdata;
  dumy := getdata; { X aspect }
  dumy := getdata; { Y aspect }
  dumy := getdata; { page width 2 byte }
  dumy := getdata;
  dumy := getdata; { page height 2 byte }
  dumy := getdata;

  cbuf[1] := $43; { C }
  cbuf[2] := $4D; { M }
  cbuf[3] := $41; { A }
  cbuf[4] := $50; { P }
  cp := 1;
  while cp <= 4 do
  begin
    dumy := getdata;
    if cbuf[cp] = dumy then
      cp := cp + 1
    else
      cp := 1;
  end;
  dumy := getdata; { palette block size 4 byte }
  dumy := getdata;
  dumy := getdata;
  dumy := getdata;
  for iii := 0 to 15 do
  begin
    dumy := getdata;
    palet[iii,0] := dumy shr 4;
    dumy := getdata;
    palet[iii,1] := dumy shr 4;
    dumy := getdata;
    palet[iii,2] := dumy shr 4
  end;

  cbuf[1] := $42; { B }
  cbuf[2] := $4F; { O }
  cbuf[3] := $44; { D }
  cbuf[4] := $59; { Y }
  cp := 1;
  while cp <= 4 do
  begin
    dumy := getdata;
    if cbuf[cp] = dumy then
      cp := cp + 1
    else
      cp := 1;
  end;
  dumy := getdata; { body block size 4 byte }
  dumy := getdata;
  dumy := getdata;
  dumy := getdata;
  if comp <> 0 then
  begin
    xp := 0;
    yp := 0;
    xxp := 0;
    while yp < yheight do
    begin
      dumy := getdata;
      if dumy > $7F then
      begin
        flag := (dumy xor $FF) + 2;
        dumy := getdata;
        while flag > 0 do
        begin
          case xxp of
            0 :  mem[$c000:$ff81] := $1;
            1 :  mem[$c000:$ff81] := $42;
            2 :  mem[$c000:$ff81] := $84;
            3 :  mem[$c000:$ff81] := $c8
          end;
          vram0[yp,xp] := dumy;
          xp := xp + 1;
          flag := flag - 1;
        end;
      end else
      begin
        flag := dumy + 1;
        while flag > 0 do
        begin
          dumy := getdata;
          case xxp of
            0 :  mem[$c000:$ff81] := $1;
            1 :  mem[$c000:$ff81] := $42;
            2 :  mem[$c000:$ff81] := $84;
            3 :  mem[$c000:$ff81] := $c8
          end;
          vram0[yp,xp] := dumy;
          xp := xp + 1;
          flag := flag - 1;
        end;
      end;
      if xp >= (xwidth div 8) then
      begin
        xxp := xxp + 1;
        if xxp = 4 then
        begin
          yp := yp + 1;
          xxp :=  0;
        end;
        xp := 0;
      end;
    end;


  end else
  begin
    xp := 0;
    yp := 0;
    xxp := 0;
    while yp < yheight do
    begin
      dumy := getdata;
      case xxp of
        0 :  mem[$c000:$ff81] := $1;
        1 :  mem[$c000:$ff81] := $42;
        2 :  mem[$c000:$ff81] := $84;
        3 :  mem[$c000:$ff81] := $c8
      end;
      vram0[yp,xp] := dumy;
      xp := xp + 1;
      if xp >= (xwidth div 8) then
      begin
        xxp := xxp + 1;
        if xxp = 4 then
        begin
          yp := yp + 1;
          xxp :=  0;
        end;
        xp := 0;
      end;
    end;

  end;
  close(picfile);
  readfileok := true;
end;

procedure useiffcolor;
var i : integer;
  r,g,b : byte;
      begin
        for i := 0 to 15 do
          begin
            r := palet[i,0];
            g := palet[i,1];
            b := palet[i,2];
            setrgbpalette(i,r,g,b)
          end;
       end;
procedure useiffcolor0;
  begin
    useiffcolor;
    setrgbpalette(0,0,0,0)
  end;

procedure exiffcolor(i:integer);
  var c,ii,ccc,x,y : integer;
      dumy : array[0..15] of real;
      dumyp : array[0..15,0..2] of integer;
      xc : array[0..15] of integer;
   begin
     gscreen;
     for c := 0 to 15 do
{      dumy[c] := 0.3*palet[c,0]+0.59*palet[c,1]+0.11*palet[c,2]+(c/1000);  }
       dumy[c] := 0.53*palet[c,0]+0.59*palet[c,1]+0.51*palet[c,2]+(c/1000);
     for c := 0 to 15 do
     begin
       ccc := 0;
       for ii := 0 to maxcol do
         if dumy[ii] < dumy[c] then ccc := ccc+1;
         xc[c] := ccc    ;
         writeln(palet[c,0],' ',palet[c,1],' ',palet[c,2]);
     end;
     for c := 0 to 15 do
     begin
       dumyp[c,0] := palet[c,0];
       dumyp[c,1] := palet[c,1];
       dumyp[c,2] := palet[c,2]
     end;
     for c := 0 to 15 do
     begin
       palet[xc[c],0] := dumyp[c,0];
       palet[xc[c],1] := dumyp[c,1];
       palet[xc[c],2] := dumyp[c,2];
       writeln(palet[c,0],' ',palet[c,1],' ',palet[c,2]);
     end;
     useiffcolor;
     for x := 0 to (319+320*i) do
       for y := 0 to (199+200*i) do
         pset( x,y,xc[point(x,y)] );
   end;


procedure PSet4Dot(x,y:integer; color:word);
begin
	Pset(x  ,y,lo(color) shr 4);
	Pset(x+1,y,lo(color) and $f);
	Pset(x+2,y,hi(color) shr 4);
	Pset(x+3,y,hi(color) and $f);
end;

function PGet4Dot(x,y:integer):word;
begin
	PGet4Dot :=
		point(x  ,y) shl  4 +
		point(x+1,y)        +
		point(x+2,y) shl 12 +
		point(x+3,y) shl  8   ;
end;

procedure MagDecode(filename : picflnam);
type
	MagHeader	= record
		header		: byte;
		machine		: byte;
		exflag		: byte;
		scrnmode	: byte;
		x1			: integer;
		y1			: integer;
		x2			: integer;
		y2			: integer;
		FlagAofs	: longint;
		FlagBofs	: longint;
		FlagBsize	: longint;
		Pixelofs	: longint;
		Pixelsize   : longint;
		Palette	   	: paletteT;
	end;
const
	MagID	: string[8] = 'MAKI02  ';
	BufSize	= 65520;
	FbufSize= 80;
var
	Header	: MagHeader;
	Buffer	: pointerUnion;
	FlagA	: pointerUnion;
	FlagB	: pointerUnion;
	Pixel	: pointerUnion;
	fp		: file;

	procedure PixelDecode;
	const
		PostblX : array[0..15] of integer =
			( 0,4,8,16,0,4,0,4,8,0,4,8,0,4,8,0 );
		PostblY : array[0..15] of integer =
			( 0,0,0,0,1,1,2,2,2,4,4,4,8,8,8,16 );
	var	flagbuf	: array[0..FbufSize-1] of byte;
		flag	: byte;
		a_bit	: byte;
		x,y		: integer;
	begin
		fillchar(flagbuf,sizeof(flagbuf),0);
		a_bit:=$80;
		for y:=Header.y1 to Header.y2 do begin
			for x:=Header.x1 div 8 to Header.x2 div 8 do
			begin
				if (FlagA.bp^ and a_bit)<>0 then begin
					flagbuf[x]:=flagbuf[x] xor FlagB.bp^;
					inc(FlagB.ofs);
				end;
				a_bit:=a_bit shr 1;
				if a_bit=0 then	begin
					a_bit:=$80;
					inc(FlagA.ofs);
				end;
				flag:=flagbuf[x] shr 4;
				if flag=0 then begin
					PSet4Dot(x*8,y,pixel.wp^);
					inc(pixel.ofs,2);
				end else begin
					PSet4Dot(x*8,y,
						PGet4Dot(x*8-PosTblX[flag],y-PosTblY[flag])
					);
				end;
				flag:=flagbuf[x] and $0f;
				if flag=0 then begin
					PSet4Dot(x*8+4,y,pixel.wp^);
					inc(pixel.ofs,2);
				end else begin
					PSet4Dot(x*8+4,y,
						PGet4Dot(x*8+4-PosTblX[flag],y-PosTblY[flag])
					);
				end;
			end;
		end;
	end;
	procedure error(msg:string);
	begin
		writeln(msg);
		{$i-}close(fp);{$i+}
		FreeMem(Buffer.p,BufSize);
		exit;
	end;

var	c		: char;
	i		: integer;
	result	: word;
begin
	assign(fp,filename); FileMode:=0;
	{$i-}reset(fp,1);{$i+}
	if IOresult<>0 then error('File not found.');
	for i:=1 to 8 do begin;
		blockread(fp,c,1);
		if c<>MagID[i] then error('This is not mag data.');
	end;
	repeat
		blockread(fp,c,1);
	until c=#$1a;
	blockread(fp,Header,sizeof(Header));
	with header do begin
		if MaxAvail<BufSize then
			error('Not enough core.');
		if scrnmode and $80 <> 0 then
			error('256color MAG data not supported.');
		if x2>=FbufSize*8 then
			error('Over width. Can not decode data.');
		if y2>399 then y2:=399;
		for i:=0 to 15 do begin
		  Palette[i,GREEN] := palette[i,GREEN] shr 4; palet[i,0]:=Palette[i,GREEN];
		  Palette[i,RED  ] := palette[i,RED  ] shr 4; palet[i,1]:=Palette[i,RED  ];
		  Palette[i,BLUE ] := palette[i,BLUE ] shr 4; palet[i,2]:=Palette[i,BLUE ];
                  setrgbpalette(i,palet[i,0],palet[i,1],palet[i,2]);
		end;
	end;

	GetMem(Buffer.p,BufSize);
	blockread(fp,Buffer.p^,BufSize,result);
	if result>=BufSize then
		error('Buffer full. Can not decode data.');
	FlagA:=Buffer;
	FlagB:=Buffer;
	Pixel:=Buffer;
	inc(FlagA.ofs,Header.FlagAofs-sizeof(Header));
	inc(FlagB.ofs,Header.FlagBofs-sizeof(Header));
	inc(Pixel.ofs,Header.Pixelofs-sizeof(Header));

{	PaletteSet(Header.Palette); }
	PixelDecode;

	FreeMem(Buffer.p,BufSize);
	close(fp);
end;


(* ====================================================================== *)
(* Turtle3 *)
procedure textscreen;
begin
  cscreen
end;

procedure fullscreen;
begin
  gscreen
end;

procedure clear;
begin
  gclear(0)
end;

procedure penup;
begin
  mama.pen := false;
end;

procedure pendown;
begin
  mama.pen := true;
end;

procedure setpc( color : integer );
begin
  mama.pencolor := color;
end;

procedure fat;
begin
  smooth_trace := true
end;

procedure thin;
begin
  smooth_trace := false
end;

procedure turtle_line(x1,y1,x2,y2: real; c: integer);
var
  xx1,yy1,xx2,yy2 : real;
begin
  if mama.pen then
    begin
      if scrunch then
        begin
          yy1 := -y1 * aspect_ratio + homey;
          yy2 := -y2 * aspect_ratio + homey
        end
      else
        begin
          yy1 := -y1 + homey;
          yy2 := -y2 + homey
        end;
      xx1 := x1 + homex;
      xx2 := x2 + homex;
      if smooth_trace
        then smoothline( xx1,yy1,xx2,yy2,c ,stype)
        else      rline( xx1,yy1,xx2,yy2,c );
    end
end;

procedure setdistance( d : real );
begin
  distance := d;
end;

procedure draw3d( p1,p2 : pos3d );
var
  x1,y1,x2,y2 : real;
begin
  if distance = 0 then
    turtle_line( p1[x],p1[y],p2[x],p2[y],mama.pencolor )
  else
    begin
      x1 := distance*p1[ x ] / ( distance-p1[ z ] );
      y1 := distance*p1[ y ] / ( distance-p1[ z ] );
      x2 := distance*p2[ x ] / ( distance-p2[ z ] );
      y2 := distance*p2[ y ] / ( distance-p2[ z ] );
      turtle_line( x1,y1,x2,y2,mama.pencolor );
    end
end;

procedure fd( st : real );
var
  image : pos3d;
begin
  with mama do
    begin
      image[ x ] := position[ x ] + st * heading[ x,x ];
      image[ y ] := position[ y ] + st * heading[ x,y ];
      image[ z ] := position[ z ] + st * heading[ x,z ];
      draw3d( position,image );
      position := image
    end
end;

procedure jp( st : real );
var
  pentmp : boolean;
begin
  pentmp := mama.pen;
  penup;
  fd( st );
  mama.pen := pentmp
end;

procedure lt( a : real );
var
  tmp : mat3d;
  i   : xyz;
  sinA,cosA : real;
begin
  with mama do
    begin
      sinA := sin( phase * a * pi / 180 );
      cosA := cos( phase * a * pi / 180 );
      for i := x to z do
        begin
          tmp[ x,i ] :=  heading[ x,i ] * cosA + heading[ y,i ] * sinA;
          tmp[ y,i ] := -heading[ x,i ] * sinA + heading[ y,i ] * cosA;
          tmp[ z,i ] :=  heading[ z,i ]
        end;
      heading := tmp
    end
end;

procedure rt( a : real );
begin
  lt( -a )
end;

procedure ut( a : real );
var
  tmp : mat3d;
  i   : xyz;
  sinA,cosA : real;
begin
  with mama do
    begin
      sinA := sin( a * pi / 180 );
      cosA := cos( a * pi / 180 );
      for i := x to z do
        begin
          tmp[ x,i ] :=  heading[ x,i ] * cosA + heading[ z,i ] * sinA;
          tmp[ y,i ] :=  heading[ y,i ];
          tmp[ z,i ] := -heading[ x,i ] * sinA + heading[ z,i ] * cosA;
        end;
      heading := tmp
    end
end;

procedure dt( a : real );
begin
  ut( -a )
end;

procedure spin( a : real );
var
  tmp : mat3d;
  i   : xyz;
  sinA,cosA : real;
begin
  with mama do
    begin
      sinA := sin( phase * a * pi / 180 );
      cosA := cos( phase * a * pi / 180 );
      for i := x to z do
        begin
          tmp[ x,i ] :=  heading[ x,i ];
          tmp[ y,i ] :=  heading[ y,i ] * cosA + heading[ z,i ] * sinA;
          tmp[ z,i ] := -heading[ y,i ] * sinA + heading[ z,i ] * cosA;
        end;
      heading := tmp
    end
end;

procedure mirror;
begin
  mama.phase := - mama.phase;
end;

procedure setpos( px,py,pz : real );
begin
  mama.position[ x ] := px;
  mama.position[ y ] := py;
  mama.position[ z ] := pz;
end;

procedure setheading( a : real );
var
  i,j : xyz;
begin
  for i := x to z do
    for j := x to z do
      if i = j
        then mama.heading[ i,j ] := 1
        else mama.heading[ i,j ] := 0;
  rt( a - 90 );
end;

procedure home;
begin
  mama.phase := 1;
  setpos( 0,0,0 );
  setheading( 0 );
end;

procedure clearscreen;
begin
  (* wipe;
  screeninit;
  *)
  home;
  distance := 300;
  setpc( maxcol );
  pendown;
  scrunch := true;
  thin
end;



(* ====================================================================== *)
(* Start Up *)

begin
	InitTbl;
	
        Emessage := true;
        EMSterr  := false;
        EMSppage := 0;
        EMSlpage := 0;
        EMShandle := 0;
	vram[0] := @vram0;
	vram[1] := @vram1;
	vram[2] := @vram2;
	vram[3] := @vram3;
end.
