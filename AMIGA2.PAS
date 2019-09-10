  { AMIGA2.PAS }

{ AMIGA Tool Box V2.0 for FMR-50(FM-TOWNS)}
{ Turbo Pascal V6.0 (Overlay System)              }
{ 0.9  by Syuusei nozi   May. 20, 1996 }
{ 2.0                    Aug. 30, 2018 }

program GTovly;
{$F+}

uses
  overlay,Crt,Dos,agraph2,
  framelib,
  upicop,uemsop,
  uturtle3,
  umapping,
  ufilter,
  utrans,
  utrans2,
  upatgen,
  upatgen2,
  upatgen3,
  uparticl,
  ufractal,
  uiff32,
  uloader,
  upaint;
{$O  uturtle3 }
{$O  umapping }
{$O  ufilter  }
{$O  utrans   }
{$O  utrans2  }
{$O  upatgen  }
{$O  upatgen2 }
{$O  upatgen3 }
{$O  uparticl }
{$O  ufractal }
{$O  uiff32   }
{$O  uloader  }
{$O  upaint   }
var
 command,yesno : char;
 orgtextmode : integer;

  procedure checksystem;
  begin
    writeln;
    writeln(memavail, ' bytes available ');
    writeln('Largest free block is ', maxavail, ' bytes');
    repeat until keypressed
  end;
    
begin
  ovrinit('amiga2.ovr');

  orgtextmode := LastMode;
  systemline(0);
  screeninit;
(*  TextMode(ExtAttr); *)
  TextColor(2);
  clrscr;
  window(41,1,80,24);

  emsinit;
  frameinit;
  
  checksystem;
 
  source := '';
  destination := '';
  asource := '';
  adestination := '';
  bmaskz := '';
  bmaskp := '';
  animno := 0;
  animframe := 16;
  animofset := 68;
  fixscreen;

  repeat
    cscreen;
    writeln(' <<< Amiga Texture System Ver.2 >>> ' );
    writeln;
    writeln('  [1] patternGen       ');
    writeln('  [2] patternGen 2     ');
    writeln('  [3] patternGen 3     ');
    writeln('  [4] filter           ');
    writeln('  [5] translate        ');
    writeln('  [6] translate 2      ');
    writeln('  [7] mapping          ');
    writeln('  [8] turtle           ');
    writeln('  [9] fractal          ');
    writeln('  [A] particle         ');
    writeln;
    writeln('  [X] << Animation Paint system >>');
    writeln('-------------------------------------');
    writeln('  [P] Picture operation');
    writeln('  [Z] EMS     operation');
    writeln('  [@] anim32  operation');
    writeln('  [L] Load other picture');
    writeln('  [!] quit   (Return to OS)');
    writeln;
    write( '>');
    readln( command );
    command := upcase( command );
    case command of
      'X' : paintsystem;
      '!' : begin
              repeat
                write('Quit! Are you sure? (Y/N):');
                readln( yesno );
                yesno := upcase( yesno );
              until yesno in ['Y','N']
            end;
      '1' : patterngen;
      '2' : patterngen2;
      '3' : patterngen3;
      '4' : filter;
      '5' : translate;
      '6' : translate2;
      '7' : mapping;
      '8' : turtle3d;
      '9' : fractal;
      'A' : particle;
      'P' : picop;
      'Z' : emsop;
      '@' : iff32;
      'L' : load_pics;
      '?' : checksystem;
    end;
  until (command = '!') and (yesno = 'Y');
  Efree;
  getrgbpalette;
(*  setRpalette;  *)
  TextMode(orgtextmode);

  g_off;

end.


