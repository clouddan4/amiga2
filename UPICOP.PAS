unit upicop;
{$O-}
Interface
uses crt,DOS,agraph2,framelib;
procedure picop;

Implementation

{$I palop.pas}
{$I color_op.pas}
{$I picopcmp.pas}



procedure picop;
var
  command,yesno,m,mm : char;
  mask,dummymask : flnam;
  dmask : dirstr;
  nmask : namestr;
  emask : extstr;
  x,y,c,i,dx,dy,xx,yy,ccc,c1,c2,cx,cy,
  cl1,cl2 : integer;

label start1;
begin
  repeat
start1:
    cscreen;
    writeln( '>> PICTURE OPERATION <<' );
    writeln;
    writeln( '  [D] Dir     : ',bmaskp);
    writeln( '  [I] source  : ',source);
    writeln( '  [O] dest    : ',destination);
    writeln( '  [L] Load IFF    [S] Save IFF 320' );
    writeln( '  [A] load MAG    [4] save IFF 640' );
    writeln('-------------------------------------');
    writeln( '  [G] Graphic     [H] Hide graphic ' );
    writeln( '  [T] mono Toon   [P] Palette OP' );
    writeln( '  [C] gClear      [0] all clear' );
    writeln( '  [1..3] copy to  [E] Exchange' );
    writeln( '  [M] copy&effect    ' );
    writeln( '  [>] to page1    [<] from page1');
    writeln( '  [F] Fixscreen   [U] Undofix');
    writeln( '  [6] > temp file [7] < temp file');
    writeln( '  [8] push 0      [9] pop 0');
    writeln( '  [^] push brush  [B] Brush OP');
    writeln( '  [X] eX color OP ' );
    writeln( '  [Y] ex 1 color  [R] Reverse color' );
    writeln( '  [Z] sort color  [/] compress 1/n');
    writeln( '  [Q] Quit' );
    write( 'p>');
    readln( command );
    command := upcase( command );
    case command of
      'Q' :;
      'D' : begin
              if bmaskp = '' then
              begin
                write('Dir mask ( return : ' );
                writeln( 'PIC\*.IFF) ' );
                write(' = ')
              end else
              begin
                write('Dir mask ( return : ' );
                writeln( bmaskp,') ' );
                write(' = ')
              end;
              readln( mask );
              dummymask := mask;
              if dummymask <> '' then bmaskp := mask;
              if (dummymask = '') and (bmaskp = '') then
              begin
                mask := 'PIC\*.IFF';
                bmaskp := mask
              end;
              if (dummymask = '') and (bmaskp <> '') then mask := bmaskp;
              file_select( mask ,source);
            end;
      'I' : begin write('Source File  : '); readln(source) end;
      'O' : begin write('Destination File : '); readln(destination) end;
      'L' : begin
              readfileok := false;
              if (source <> '') and (exist(source)) then
              begin
                gscreen;
                iffload(source);
                if readfileok = true then
                begin
                  write(' Use Palette OK ? (Y/N) '); readln( yesno );
                  yesno := upcase( yesno );
                  if yesno = 'Y' then useiffcolor
                end;
              end else writeln( 'Picture not found !' );
              wait
            end;
      'A' : begin
              readfileok := false;
              if (source <> '') and (exist(source)) then
              begin
                gscreen;
                MagDecode(source);
              end else writeln( 'Picture not found !' );
              wait
            end;
  'S','4' : begin
              if destination <> '' then
              begin
                if exist(destination) then writeln('Picture already exists!');
                write('Save ',destination ); write(' Ok? (Y/N) ');
                readln(yesno);
                if upcase(yesno) = 'Y' then
                begin
                  diskreset;
                  gscreen;
                  getrgbpalette;
                  if command = 'S' then iffsave( destination, 0 )
                                   else iffsave( destination, 1 );
                end
              end
            end;
      'G' : begin
              cursoroff;
              gscreen;
              repeat until keypressed;
              cursoron;
            end;
      'H' : G_off;
      'T' : b_and_w;
      'P' : palop;
      'C' : begin
              write( 'Gclear color = ' );
              readln( c );
              if c in [ 0..maxcol ] then
                begin
                  gscreen;
                  gclear( c )
                end
            end;
      '0' : fillscreen(0);
      '1' : hscopy(1);
      '2' : hscopy(2);
      '3' : hscopy(3);
      'E' : begin
              write('Exchenge Posicion = ');
              readln(m);
              case m of
                '1' : begin dx := 0;   dy := 200; end;
                '2' : begin dx := 320; dy := 0;   end;
                '3' : begin dx := 320; dy := 200; end;
              end;
              gscreen;
              for x :=0 to maxhor do
                for y := 0 to maxver do
                begin
                  c := point(x+dx,y+dy);
                  pset(x+dx,y+dy,point(x,y));
                  pset(x,y,c);
                end;
            end;
      'M' : begin
              write('** Move Posicion = ');
              readln(m);
              writeln(' Q: cancel');
              writeln('--------------------------------------');
              writeln(' 1: í èÌ     2: ïΩãœ');
              writeln(' +: â¡éZ     -: å∏éZ     *: èÊéZ');
              writeln(' /: xor      &: and      |: or');
              writeln(' 3: ç∑ÇÃê‚ëŒíl     4: screen');
              writeln(' L: î‰ärñæ         K: î‰ärà√');
              writeln(' A: alpha blend    W: WR blend');
              writeln('--------------------------------------');
              writeln(' O: Overlay        U: Underlay');
              writeln(' =: overlay+ïΩãœ   0: 0 to êÿÇËéÊÇË');
              writeln(' H: O/U êÖïΩchange V: O/U êÇíºchange');
              writeln(' B: O/U ó†âÊñ mask M: MaskçÏê¨');
              writeln('--------------- not0 to---------------');
              writeln(' ]: not0 to mask0  [: not0 to mask15');
              writeln(' I: inc not0       D: dec not0');
              writeln(' 5: slit x         6: slit y');
              writeln(' 7: slit x + y     8: slit x - y');
              writeln('--------------------------------------');
              writeln(' S: Scroll   T: Sc_Trim   9: -90Åãtrim');
              writeln(' X: X-Flip   Y: Y-Flip     ');
              write  ('** Move method = ');
              readln(mm);
              mm := upcase(mm);
              if mm = 'Q' then goto start1;
              case m of
                '1' : begin dx := 0;   dy := 200; end;
                '2' : begin dx := 320; dy := 0;   end;
                '3' : begin dx := 320; dy := 200; end;
              end;
              xx := 0; yy := 0;
              cx := 0; cy := 0;
              case mm of
            'S','T' : begin
                        write('X offset = '); readln(xx);
                        write('Y offset = '); readln(yy)
                      end;
                'M' : begin
                        write('àÊíl   = '); readln(cl1);
                        writeln( '    É{ÉPë´: 1-15');
                        writeln( '    2íl   : 0');
                        write('É{ÉPë´ = '); readln(cl2);
                        c := cl1 - cl2;
                        if c < 0 then c := 0;
                      end;
                '9' : begin
                        for x := 60 to 259 do
                          for y := 0 to 199 do
                          begin
                            c1 := point(x,y);
                            pset(60+y+dx,199-(x-60)+dy,c1)
                          end;
                        goto start1;
                      end;
              end;
              gscreen;
              for x :=0 to maxhor do
                for y := 0 to maxver do
                 begin
                   c1 := point(x,y);
                   c2 := point(x+dx,y+dy);
                   case mm of
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
                                        ((-yy+y+400) mod 200));
                     'T' : begin
                             ccc := point(-xx+x,-yy+y);
                             if ((-xx+x) < 0) or ((-xx+x) > maxhor)
                             or ((-yy+y) < 0) or ((-yy+y) > maxver) then ccc := 0
                           end;
                     'X' : begin
                             ccc := c1;
                             cx := maxhor -x -x
                           end;
                     'Y' : begin
                             ccc := c1;
                             cy := maxver -y -y
                           end;
                   end;
                   pset(x+dx+cx,y+dy+cy,ccc)
                 end;
            end;
      '>' : begin gscreen; scrn0to1 end;
      '<' : begin gscreen; scrn1to0 end;
      'F' : fixscreen;
      'U' : undofix;
      '6' : begin
              getrgbpalette;
              iffsave('PIC\TMP.IFF',1);
            end;
      '7' : iffload('PIC\TMP.IFF');
      '8' : scrntoems((2+1)*animofset+1);
      '9' : emstoscrn((2+1)*animofset+1);
      '^' : scrntoems((2+1)*animofset+3);
      'B' : emstoscrn((2+1)*animofset+3);
      'X' : color_op;
      'Y' : begin
              writeln(' Chenge Color ');
              write('   from = '); readln(c1);
              write('   to   = '); readln(c2);
              gscreen;
              for x := 0 to maxhor do
                for y := 0 to maxver do
                  if point(x,y)=c1 then pset( x,y,c2 );
            end;
      'R' : begin
              gscreen;
              for x := 0 to maxhor do
                for y := 0 to maxver do
                  pset( x,y,( 15 - point(x,y) ) )
            end;
      'Z' : begin exiffcolor(0); wait end;
      '/' : picopcmp;
    end;
  until command = 'Q';
end;
begin
end.
