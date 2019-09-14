# amiga2
 (Deluxe Paint III like) animation paint system for UNZ(FM-TOWNS emulator)  

![スイカの行進](https://github.com/clouddan4/amiga2/blob/master/SUIKA.gif)
![スイカの行進](https://github.com/clouddan4/amiga2/blob/master/SUIKA.png)

20 years ago, I used Amiga500,Amiga4000,X68000 and FM-Towns(This program).  
Original source skelton is 'Turbo Graphics (PC-9801) by Anzai Tosihiro' and  
 'Computer Graphics (SMC-777) by Anzai Tosihiro' .  

recently, UNZ(FM-TOWNS emulator) was upgrated, and can running 'EMM386.EXE'.  
so, I can update (& bugfix) this program.  

in the future, I want to run this program on DOSBOX(& TP7).  
and, use 256color(or, mix multiple 16color-anims to 256color-GIFAnim).  
but I don't have VGA know-how....(T_T).  
(once at a time, I bought Delphi3 for windows. and, I was discouraged.)  

---

### How to RUN this Program
requirements
- 'Fujitsu FMR-50' or 'FMR-60 with 16dotcard' or 'FM-TOWNS' or 'UNZ(FM-TOWNS emulator)'
- DOS6.2 and setting mouse driver & EMM386.exe
- run setup2.exe(dos command) and keep max EMS-frame

install
- copy AMIGA2.EXE, AMIGA2.OVR, PAINTSYS.HLP to any directory(e.g. D:\ATS)
- make sub directory 'PST' and copy *.ptn(brush&tone pattern file) to 'PST'
- make sub directory 'P'(parameter files)
- make sub directory 'PIC'(default picture files)
- make sub directory 'ANIM'(default anim-frame files)

run
- execute amiga2.exe (run 'total system')
	- type p (run picture operation)
	- type z (run anim operation)
- type x (run 'Anime Paint system')
	- mouse click 'HELP' or '?'

---

### Basic feature
Edit Picture:   640X400 16color  
Edit Animation: 320X200 16color (on EMS frames)  
Mix 2 Animation: to 320X200 32color IFF(ILBM) pictures (send to Amiga) 

![16color](https://github.com/clouddan4/amiga2/blob/master/16color.png)
![32color](https://github.com/clouddan4/amiga2/blob/master/32COLOR.gif)

![TREE4](https://github.com/clouddan4/amiga2/blob/master/TREE4.gif)
![TREE4](https://github.com/clouddan4/amiga2/blob/master/DP3_TREE.png)

Add feature from 'Deluxe Paint III'
- Load & Save Amiga IFF(ILBM) format pictures
- ToolBox
	- line, circle, box, curve, splay, polygon, fill, ...
- 6 Gradient fill types
- Symmetry draw
- Cut Brush (max size 320X200)
- Anim Brush (use Animaton track No.3 on EMS)
- Animation
	- light_table(Onion skin)
	- (tool) step Animation
- Grid
- Magnify (and edit animframe)
- and more....

![16color](https://github.com/clouddan4/amiga2/blob/master/submenu.png)

### New feature (except 'DPaint3')
- Load minor(worldwide) graphic format picture
	- MAG&FRM(by NEC PC-9801), SMC(by Sony SMC-777C)
- 3 Animation tracks
	- copy, overlay, underlay, masking_mat, ...
- (PhotoShop like) Mix mode (brush to screen)
- more Gradient style (bevel in, out)
	- auto convert 16 color gradient style to 2,3,8 color dither pattern
- Tone & Tile paint
- (2value or shade) mask (use spare screen)
- Tool morphing Animation (between 2 setting same tool)
	- (Perhaps same tool in PhotonPaint & SpectraColor)
- change Brush Over/Under (by keybord or Auto setting)
- and more....

built-in external Anim_geneator module
- Pattern_GEN (jumble of good and bad)
- Filter
- Deformation
- Mapping
	- Mask-synthesis, Displace-Map, Ripple-Map
- Particle (poor)
- Fractal (jumble of good and bad)

---

#### near future plans
- convert 16color sprite-map-set picture(e.g. TIC-80) <--> Anim Brush
	- or, add to brush-mode: (sprite)map-Brush
- Brush-angle auto align along to TOOL-path
- add spare page to light table
- Pattern_GEN: thunder-bolt anim-effect
- Mapping: TimeDisplace-Map

#### far future plans
- built-in script engine (tiny-FORTH?)
- Bitmap-stroke-Brush along to TOOL-path (Creature House: Expression?)


