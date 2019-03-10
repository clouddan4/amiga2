unit uemsop;
{$O-}

Interface
uses crt,DOS,agraph2,framelib;
procedure emsop;

Implementation

{$I col_op_z.pas}
{$I wipe.pas}

procedure compress( ratio : integer );
var
  x,y,xx,yy,mx,my,
  xt,yt,t,d,c,scope  : integer;
begin
  mx := ( maxhor + 1 ) div ratio;
  my := ( maxver + 1 ) div ratio;
  scope := ratio - 1;
  d := ratio * ratio;
  for x := 0 to mx do
    for y := 0 to my do
    begin
      t := 0;
      for xx := 0 to scope do
        for yy := 0 to scope do
         begin
           xt := x * ratio + xx;
           yt := y * ratio + yy;
           c := point( xt,yt );
           if c = out_of_frame then c := 0;
           t := t + c;
           pset( xt,yt,0 )
         end;
     c := t div d;
     pset( x,y,c )
    end
end;


procedure emsop;
var
  command,yesno,mmm : char;
  mask,dummymask: flnam;
  dmask : dirstr;
  nmask : namestr;
  emask : extstr;
  kai,zzz : string[3] ;
  sno,i,m,mm,x,y,dx,dy,c,c1,c2,ccc,xx,yy,cx,cy,
    cl1,cl2,ratio : integer;
  xc : array[ 0..maxcol ] of integer;
  dumyp : array[0..7,0..2] of integer;
  
label start1;


begin
  ratio := 2;
  repeat
start1:    
    screenad(0,0);
    cscreen;
    writeln( '>> EMS OPERATION <<' );
    writeln;
    writeln( '  [N] anim No.   0 -  2 : ',animno);
    writeln( '  [A] Anim frame 1 - 64 : ',animframe);
    writeln( '  [F] anim oFset(>frame): ',animofset);
    writeln( '  [D] Dir     : ',bmaskz);
    writeln( '  [I] source  : ',asource);
    writeln( '  [O] dest [=]: ',adestination);
    writeln( '  [L] Load IFFs   [S] Save IFFs' );
    writeln('-------------------------------------');
    writeln( '  [P] Play        [-] play ',animno,' & 1');
    writeln( '  [<] play rev    [V] copy to reVerse ');
    writeln( '  [>] play pinpon [T] copy to pinpon');
    writeln( '  [M] copy&effect [C] Clear  ');
    writeln( '  [1] copy anim   [E] Exchang anim');
    writeln( '  [2] append anim [3] copy to rotate');
    writeln( '  [4] pic->frames [5] pic->all_frames');
    writeln( '  [6] motion blur [7] fadeout');
    writeln( '  [X] eX color OP [W] Wipe OP');
    writeln( '  [Y] ex 1color   [R] Reverse color');
    writeln( '  [Z] sort color  [/] compress 1/n');
    write( 'p>');
    readln( command );
    command := upcase( command );
    case command of
      'Q' :;
      'N' : begin write('Anim No. : '); readln(animno) end;
      'A' : begin write('Anim Frame : '); readln(animframe); end;
      'F' : begin write('Anim ofset : '); readln(animofset); end;
      'D' : begin
              str(animframe,kai);
              if animframe < 10 then zzz := '00'+ kai
                                else if animframe < 100 then zzz := '0'+ kai
                                                        else zzz := kai;
              if bmaskz = '' then
              begin
                write('Directory ( return : ' ); writeln( 'ANIM\*.',zzz,') ' );
                write(' = ')
              end else
              begin
                write('Directory ( return : ' ); writeln( bmaskz,') ' );
                write(' = ')
              end;
              readln( mask ); dummymask := mask;
              if dummymask <> '' then bmaskz := dummymask;
              if (dummymask = '') and (bmaskz = '') then
              begin
                mask := 'ANIM\*.'+zzz;
                bmaskz := mask
              end;
              if (dummymask = '') and (bmaskz <> '') then
              begin
                fsplit(bmaskz,dmask,nmask,emask);
                mask := dmask+nmask+'.'+zzz;
                bmaskz := mask
              end;
              file_select( mask,asource );
              if asource <> '' then
              begin
                fsplit(asource,dmask,nmask,emask);
                asource := dmask+nmask
              end;
            end;
      'I' : begin write('Source File  : '); readln(asource) end;
      'O' : begin write('Destination File : '); readln(adestination) end;
      '=' : adestination := asource;
      'L' : begin
              gscreen;
              readfileok := false;
              for i := 1 to animframe do
              begin
                str(i,kai);
                if i < 10 then zzz := '00'+ kai
                          else if i <100 then zzz := '0'+ kai
                                         else zzz := kai;
                mask := asource + '.' + zzz;
                writeln('execute No = ',mask);
                if (asource <> '') and (exist(mask)) then
                begin
                  iffload(mask);
                  scrntoems(i+animno*animofset);
                end else writeln( 'Picture not found !' );
              end;
              if readfileok = true then
               begin
                 write(' Use Palette OK ? (Y/N) ');
                 readln( yesno ); yesno := upcase( yesno );
                 if yesno = 'Y' then useiffcolor
               end;
            end;
      'S' : begin
              gscreen;
              getrgbpalette;
              for i := 1 to animframe do
              begin
                str(i,kai);
                if i < 10 then zzz := '00'+ kai
                          else if i <100 then zzz := '0'+ kai
                                         else zzz := kai;
                mask := adestination + '.' + zzz;
                writeln('execute No = ',mask);
                emstoscrn(i+animno*animofset);
                if adestination <> '' then
                begin
                  if exist(mask) then
                  begin
                    writeln('Picture already exists!');
                    write('Save ',mask); write(' Ok? (Y/N) ');
                   readln(yesno);
                   if upcase(yesno) = 'Y' then
                    begin
                      diskreset;
                      iffsave( mask, 0 )
                    end
                  end else
                  begin
                    diskreset;
                    gscreen;
                    iffsave( mask, 0 )
                  end
                end;
              end;
            end;
      'P' : begin
              screenad(1,0); fixscreen;
              screenad(0,0);
              scrn0to1;
              repeat
                for i := 1 to (animframe) do 
                begin
                  delay(30);
              (*  writeln(i); *)
                  if odd(i+2) then screenad(1,0)
                              else screenad(0,1);
                  emstoscrn(i+animno*animofset)
                end;
              until keypressed;
              screenad(1,0); undo;
              screenad(0,0);
              emstoscrn(1+animno*animofset);
            end;
      '-' : begin
              screenad(1,0); fixscreen;
              screenad(0,0);
              scrn0to1;
              repeat
                for i := 1 to (animframe) do
                begin
                  delay(30);
           (*     writeln(i); *)
                  if odd(i+2) then screenad(1,0)
                              else screenad(0,1);
                  emstoscrn(i+animno*animofset);
                  emstoscrn1(i+1*animofset)
                end;
              until keypressed;
              screenad(1,0); undo;
              screenad(0,0);
              emstoscrn(1+animno*animofset);
              emstoscrn1(1+1*animofset);
            end;
      '<' : begin
              screenad(1,0); fixscreen;
              screenad(0,0);
              scrn0to1;
              repeat
                for i := (animframe) downto 1 do
                begin
                  delay(30);
          (*      writeln(i);  *)
                  if odd(i+2) then screenad(1,0)
                              else screenad(0,1);
                  emstoscrn(i+animno*animofset)
                end;
              until keypressed;
              screenad(1,0); undo;
              screenad(0,0);
              emstoscrn(1+animno*animofset);
            end;
      '>' : begin
              screenad(1,0); fixscreen;
              screenad(0,0);
              scrn0to1;
              repeat
                for i := 1 to (animframe) do
                begin
                  delay(30);
           (*     writeln(i);   *)
                  if odd(i+2) then screenad(1,0)
                              else screenad(0,1);
                  emstoscrn(i+animno*animofset)
                end;
                for i := (animframe) downto 1 do
                begin
                  delay(30);
           (*     writeln(i);   *)
                  if odd(i+2) then screenad(1,0)
                              else screenad(0,1);
                  emstoscrn(i+animno*animofset)
                end;
              until keypressed;
              screenad(1,0); undo;
              screenad(0,0);
              emstoscrn(1+animno*animofset);
            end;
      'V' : begin
              write(' Copy   Posicion(1.2) = '); readln(m);
              screenad(0,0);
              for i := 1 to (animframe) do
              begin
                writeln(i);
                emstoscrn(i);
                scrntoems((animframe-i+1)+m*animofset)
              end;
            end;
      'T' : begin
              screenad(0,0);
              for i := 1 to (animframe) do
              begin
                writeln(i);
                emstoscrn(i);
                scrntoems(2*animframe-i+1)
              end;
              animframe := animframe*2;
            end;
      'C' : begin
              gclear(0);
              for i := 1 to animframe do
              begin
                scrntoems(i+0*animofset);
                gotoxy(47,1); write(i:2,' / ',animframe:2)
              end
            end;
      '1' : begin
              write(' Source AnimNo.(0.1.2) = '); readln(mm);
              write(' Target AnimNo.(0.1.2) = '); readln(m);
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(i+mm*animofset);
                scrntoems(i+m*animofset)
              end;
            end;
      'E' : begin
              write(' Exchange Posicion = '); readln(m);
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(i); hscopy(1);
                emstoscrn(i+m*animofset); scrntoems(i);
                for x :=0 to maxhor do
                  for y := 0 to maxver do
                  begin
                    c := point(x,y+200);
                    pset(x,y+200,point(x,y));
                    pset(x,y,c)
                  end;
                  scrntoems(i+m*animofset)
              end;
            end;
      'M' : begin
              write('** Source AnimNo.(0.1.2) = '); readln(mm);
              write('** Target AnimNo.(0.1.2) = '); readln(m);
              writeln('(Q: cancel) --------------------------');
              writeln(' 1: 通常    2: 平均    E: 組織的ディザ');
              writeln(' +: 加算    -: 減算    *: 乗算');
              writeln(' /: xor     &: and     |: or');
              writeln(' 3: 差の絶対値     4: screen');
              writeln(' L: 比較明         K: 比較暗');
              writeln(' A: Alpha blend    W: WR blend');
              writeln('--------------------------------------');
              writeln(' O: Overlay        U: Underlay');
              writeln(' =: overlay+平均   \: over/under+平均');
              writeln(' 0: 0 で切り取り   M: Mask作成');
              writeln(' H: O/U 水平change V: O/U 垂直change');
              writeln(' B: O/U 裏画面mask ');
              writeln('--------------- (not0 to ) -----------');
              writeln(' ]: not0 to mask0  [: not0 to mask15');
              writeln(' I: inc not0       D: dec not0');
              writeln(' 5: slit x         6: slit y');
              writeln(' 7: slit x + y     8: slit x - y');
              writeln('--------------------------------------');
              writeln(' X: X-flip  Y: Y-flip   9: 90°(trim)');
              writeln(' S: Srol    %: srol(%)  T: srol(Trim)');
              write  ('** Move method = '); readln(mmm); mmm := upcase(mmm);
              if mmm = 'Q' then goto start1;
              xx := 0; yy := 0;
              cx := 0; cy := 0;
              case mmm of
                'E' : begin
                        writeln( '        0: Bayer 配列 パターン');
                        writeln( '        1: 網点  配列 パターン');
                        writeln( '        2: 渦巻き配列 パターン');
                        write('ditherパターンの種類 = '); readln(cl1);
                        write('転送元濃度 (0～15)   = '); readln(cl2)
                      end;
        'S','%','T' : begin
                        write('X offset = '); readln(xx);
                        write('Y offset = '); readln(yy)
                      end;
                'M' : begin
                        write('域値color   = '); readln(cl1);
                        writeln( '    ボケ足: 1-15');
                        writeln( '    2値   : 0');
                        write('ボケ足 = '); readln(cl2);
                        c := cl1 - cl2;
                        if c < 0 then c := 0;
                      end;
                '9' : begin
                        gscreen;
                        for i := 1 to animframe do
                        begin
                          writeln(i);
                          emstoscrn(i+mm*animofset); hscopy(1);
                          gclear(0);
                          for x := 60 to 259 do
                            for y := 0 to 199 do
                            begin
                              c1 := point(x,y+200);
                              pset(60+y,199-(x-60),c1)
                            end;
                          scrntoems(i+m*animofset);
                        end;
                        goto start1;
                      end;
              end;
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(i+m*animofset); hscopy(1);
                emstoscrn(i+mm*animofset);
                if (mmm='S') or (mmm='%') or (mmm='T') or (mmm='X') or (mmm='Y')
                  then hscopy(1);
                for x :=0 to maxhor do
                  for y := 0 to maxver do
                  begin
                    c1 := point(x,y);
                    c2 := point(x,y+200);
                    case mmm of
                      'E' : begin
                              case cl1 of
                                0 : c :=  Dither[x mod 4 + 1][y mod 4 + 1];
                                1 : c := Dither2[x mod 4 + 1][y mod 4 + 1];
                                2 : c := Dither3[x mod 4 + 1][y mod 4 + 1];
                              end;
                              if cl2 > c then ccc := c1 else ccc := c2;
                            end;
                      '1' : ccc := c1;
                      '2' : ccc := round((c1+c2)/2);
                      '+' : begin
                              ccc := c1 + c2;
                              if ccc > 15 then ccc := 15
                            end;
                      '-' : begin
                              ccc := c2 - c1;
                              if ccc < 0 then ccc := 0
                            end;
                      '*' : ccc := round((c1*c2)/15);
                      '/' : ccc := c1 xor c2;
                      '&' : ccc := c1 and c2;
                      '|' : ccc := c1 or c2;
                      '3' : ccc := abs(c1-c2);
{                     '4' : ccc := round( (15-c1)*(15-c2)/15 ); }
                      '4' : ccc := round(15- (15-c1)*(15-c2)/15 ); 
                      'L' : if c1 > c2 then ccc := c1
                                       else ccc := c2;
                      'K' : if c1 > c2 then ccc := c2
                                       else ccc := c1;
                      'A' : ccc := round((c1*c1+(15-c1)*c2)/15);
                      'W' : begin
                              ccc := c1 - 7;
                              ccc := ccc + c2;
                              if ccc > 15 then ccc := 15;
                              if ccc <  0 then ccc :=  0
                            end;
                      'O' : if c1 = 0 then ccc := c2
                                      else ccc := c1;
                      'U' : if c2 = 0 then ccc := c1
                                      else ccc := c2;
                      'H' : if y < 100 then 
                            begin
                              if c1 = 0 then ccc := c2
                                        else ccc := c1
                            end else
                            begin
                              if c2 = 0 then ccc := c1
                                        else ccc := c2;
                            end;
                      'V' : if x < 160 then 
                            begin
                              if c1 = 0 then ccc := c2
                                        else ccc := c1
                            end else
                            begin
                              if c2 = 0 then ccc := c1
                                        else ccc := c2;
                            end;
                      'B' : begin
                              screenad(1,0);
                              c := point(x,y);
                              screenad(0,0);
                              if c = 0 then
                              begin
                                if c1 = 0 then ccc := c2
                                          else ccc := c1
                              end else
                              begin
                                if c2 = 0 then ccc := c1
                                          else ccc := c2;
                              end;
                            end;
                      'M' : if c1 >= cl1 then ccc := maxcolor
                                         else if c1 < c then ccc := 0 
                                                        else ccc := c1;
                      '=' : if c1 = 0 then ccc := c2
                                      else ccc := round((c1+c2)/2);
                      '\' : if c1 = 0 then ccc := c2
                              else if c2 = 0 then ccc := c1
                                             else ccc := round((c1+c2)/2);
                      '0' : if c1 = 0 then ccc := 0
                                      else ccc := c2;  
                      ']' : begin
                              if c1 <> 0 then c2 := 0;
                              ccc := c2
                            end;
                      '[' : begin
                              if c1 <> 0 then c2 := maxcolor;
                              ccc := c2
                            end;
                      'I' : begin
                              if c1 <> 0 then c2 := c2+1;
                              if c2 > maxcolor then c2 := maxcolor;
                              ccc := c2
                            end;
                      'D' : begin
                              if c1 <> 0 then c2 := c2-1;
                              if c2 < 0  then c2 := 0;
                              ccc := c2
                            end;
                      '5' : if c1 = 0 then ccc := c2
                                      else if odd(x+1) then ccc := c1
                                                       else ccc := c2;
                      '6' : if c1 = 0 then ccc := c2
                                      else if odd(y+1) then ccc := c1
                                                       else ccc := c2;
                      '7' : if c1 = 0 then ccc := c2
                                      else if odd(x+y+1) then ccc := c1
                                                         else ccc := c2;
                      '8' : if c1 = 0 then ccc := c2
                                      else if odd(x-y+200) then ccc := c1
                                                           else ccc := c2;
                      'S' : ccc := point(((-xx+x+640) mod 320),
                                         ((-yy+y+400) mod 200)+200);
                      '%' : ccc := point(((-round(xx*i/animframe)+x+640) mod 320),
                                         ((-round(yy*i/animframe)+y+400) mod 200)+200);
                      'T' : begin
                              ccc := point(-xx+x,-yy+y+200);
                              if ((-xx+x) < 0) or ((-xx+x) > maxhor)
                              or ((-yy+y) < 0) or ((-yy+y) > maxver) then ccc := 0
                            end;
                      'X' : begin
                              ccc := point(x,y+200);
                              cx := maxhor -x -x
                            end;
                      'Y' : begin
                              ccc := point(x,y+200);
                              cy := maxver -y -y
                            end;
                    end;
                    pset(x+cx,y+cy,ccc);
                  end;
                  scrntoems(i+m*animofset);
              end;
            end;
      '2' : begin
              write(' Source AnimNo.(0.1.2) = '); readln(mm);
              write(' Target AnimNo.(0.1.2) = '); readln(m);
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(i+mm*animofset);
                scrntoems(i+animframe+m*animofset)
              end;
              animframe := animframe*2;
            end;
      '3' : begin
              write(' Source AnimNo.(0.1.2) = '); readln(mm);
              write(' Target AnimNo.(0.1.2) = '); readln(m);
              write(' Rotate frame = '); readln(x);
              gscreen;
              x := x mod animframe;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(x+mm*animofset);
                scrntoems(i+m*animofset);
                x := x+1;
                if x > animframe then x := 1
              end;
            end;
      '4' : begin
              write(' Target AnimNo.(0.1.2) = '); readln(mm);
              write(' first frame = '); readln(x);
              write(' last frame = '); readln(y);
              gscreen;
              for i := x to y do
              begin
                writeln(i);
                scrntoems(i+mm*animofset)
              end;
            end;
      '5' : begin
              write(' Target AnimNo.(0.1.2) = '); readln(mm);
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                scrntoems(i+mm*animofset)
              end;
            end;
      '6' : begin
              write(' Source AnimNo.(0.1.2) = '); readln(mm);
              write(' Target AnimNo.(0.1.2) = '); readln(m);
              write(' frame offset = '); readln(sno);
              write('減衰率 = '); readln(dx);
              gscreen;
              for i := 1 to (animframe) do 
              begin
                emstoscrn(i+mm*animofset);
                fixscreen;
                dy := i - sno*2;
                if i <= sno*2 then dy := animframe - sno*2 +i;
                emstoscrn(dy+mm*animofset);
                hscopy(1);
                dy := i - sno;
                if i <= sno then dy := animframe - sno + i;
                emstoscrn(dy+mm*animofset);
                for x := 0 to maxhor do
                  for y := 0 to maxver do
                  begin
                    c := framepoint(1,x,y);
                    c1 := point(x,y)-dx;
                    if c1 < 0 then c1 := 0;
                    c2 := point(x,y+200)-2*dx;
                    if c2 < 0 then c2 := 0;
                    if c2 >= c1 then ccc := c2 else ccc := c1;
                    if c >= ccc then ccc := c  else ccc := ccc;
                    pset(x,y,ccc) 
                  end;  
                scrntoems(i+m*animofset);
              end;
            end;
      '7' : begin
              write(' Source AnimNo.(0.1.2) = '); readln(mm);
              write(' Target AnimNo.(0.1.2) = '); readln(m);
              gscreen;
              for i := 1 to animframe do
              begin
                emstoscrn(i+mm*animofset);
                hscopy(1);
                for x := 0 to maxhor do
                  for y := 0 to maxver do
                  begin
                    c1 := point(x,y+200);
                    ccc:= round(c1-c1*(i-1)/animframe);
                    pset(x,y,ccc)
                  end;
                scrntoems(i+m*animofset);
              end;
            end;
      'X' : color_op_ems;
      'W' : slitwipe;
      'Y' : begin
              writeln(' Chenge Color ');
              write('   from = '); readln(mm);
              write('   to   = '); readln(m);
              gscreen;
              for i := 1 to (animframe) do
              begin
                emstoscrn(i+animno*animofset);
                for x := 0 to maxhor do
                  for y := 0 to maxver do
                    if point(x,y)=mm then pset(x,y,m);
                scrntoems(i+animno*animofset);
              end;
            end;
      'R' : begin
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(i+animno*animofset);
                for x := 0 to maxhor do
                  for y := 0 to maxver do
                    pset(x,y,(15 - point(x,y)));
                scrntoems(i+animno*animofset);
              end;
            end;
      'Z' : begin
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(i);
                exiffcolor(0);
                scrntoems(i);
              end;
            end;
      '/' : begin
              write('ratio(1/n)  n = '); inputI(ratio);
              write(' Source AnimNo.(0.1.2) = '); readln(mm);
              write(' Target AnimNo.(0.1.2) = '); readln(m);
              gscreen;
              for i := 1 to animframe do
              begin
                writeln(i);
                emstoscrn(i+mm*animofset);
                compress(ratio);
                scrntoems(i+m*animofset)
              end;
            end;
    end;
  until command = 'Q';
end;

begin
end.
