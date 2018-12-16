unit upaint;
{$F+}
{$O+}
Interface
uses crt,DOS,agraph2,framelib,upicop,uemsop,
     fmmouse,pglobal,submenu,loupe,paledit,screenop,usr1,usr2;
procedure paintsystem;

Implementation



{$v-}

{$i sysbrush.inc }

procedure mainmenu;
var
  dch1,dch2  : string[4];
  item : integer;
  atwork : boolean;
  themenu: menutype;
begin
  with themenu do
  begin
    menustr1 :='ï`âÊ|    |    |ägëÂ|ì¡ïM|é¿å±|    |    |Anim|';
    menustr2 :='|âÊñ |êF  |ê›íË|Help|èIóπ';
    orgcol   := 1;
    itemcols := 5;
    lastitem := 15
  end;
(*  item := pointnothing; *)
  item := 0;
  repeat
    atwork := true;
    themenu.menustr2 := '|âÊñ |êF  |ê›íË|Help|èIóπ';
    str(currentframe:3,dch1);
    str(animframe:3,dch2);
    themenu.menustr2 := dch1+' /'+dch2+' '+themenu.menustr2;
    cursoroff;
    if getitem( themenu , item ) then
      case item of
         0: with systemparam do
             systembrush(currentbrush,
                        currentcolor,currentbgcolor,currentmaskcolor);
        11: screenmenu;
        12: paletteeditor;
         9: begin
              putsystempalette;
              hidemouse;
              window(41,1,80,24);
              cursoron;
              picop;
              clrscr;
              window(1,1,80,24);
              cursoroff;
              getsystempalette
            end;
        10: begin;
              putsystempalette;
              hidemouse;
              window(41,1,80,24);
              cursoron;
              emsop;
              clrscr;
              window(1,1,80,24);
              cursoroff;
              screenad(0,0);
              emstoscrn(currentframe+0*animofset);
              if autoanimscreen1 = true then
                emstoscrn1(currentframe+1*animofset);
              fixscreen;
              getsystempalette
            end;
         3: loupedot;
         4: with systemparam do
              userproc1(currentbrush,currentcolor);
         5: with systemparam do
              userproc2(currentbrush,currentcolor);
         6: ;
         7: ;
         8: animset;
        13: systemset;
        14: help('SYSTEM');
        15: if askok('èIóπÇµÇƒÇ¢Ç¢Ç≈Ç∑Ç©') then
              atwork := false;
      end
      else
        waitrbutton;
  until not atwork;
end;


procedure paintsystem;

begin
  window(1,1,80,24);
  setupsystem;
  setupbrushbox;
  setuptonebox;
  mainmenu;
  closesystem;
  cursoron;
  window(41,1,80,24);

end;
end.