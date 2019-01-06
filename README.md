# amiga2
 (Deluxe Paint III like) animation paint system for UNZ(FM-TOWNS emulator) 

![スイカの行進](https://github.com/clouddan4/amiga2/blob/master/SUIKA.gif)

20 years ago, I used Amiga500,Amiga4000,X68000 and FM-Towns(This program).  
Original source skelton is 'Turbo Graphics (PC-9801) by Anzai Tosihiro' and  
 'Computer Graphics (SMC-777) by Anzai Tosihiro' .  

recently, UNZ(FM-TOWNS emulator) was upgrated, and can running EMM386.EXE .  
so, I can update (& bugfix) this program.   

in the future, I want to run this program on DOSBOX(& TP7).  
 and, use 256color(or, mix multiple 16color-anims to 256color-GIFAnim)  
 but I don't have VGA know-how....(T_T)  
(once at a time, I bought Delphi3 for windows. and, I was discouraged.)

---

### Basic feature
Edit Picture:   640X400 16color  
Edit Animation: 320X200 16color (on EMS frames)  
Mix 2Animation: to 320X200 32color IFF(ILBM) pictures  
![16color](https://github.com/clouddan4/amiga2/blob/master/16color.png)
![32color](https://github.com/clouddan4/amiga2/blob/master/32COLOR.gif)

Add feature from 'Deluxe Paint III'
- Load & Save Amiga IFF(ILBM) format pictures
- ToolBox
	- line, circle, box, curve, airbrush, polygon, fill, ...
- 6 Gradient fill types
- Symmetry draw
- Cut Brush
- Anim Brush
- Animation
	- light table
	- (tool) step Animation
- and more....

### New feature
- 3 Animation tracks
	- copy, overlay, underlay, masking_mat, ...
- (PhotoShop like) Mix mode (brush & screen)
- screen_toon, color_tiling
- masking
- tool between Animation
- change Brush Over/Under by keybord
- and more....

built-in external Anim_geneator module
- Pattern_GEN (jumble of good and bad)
- Filter
- Deformation
- Mapping
	- Mask-synthesis, Displace-Map, Ripple-Map
- Particle (poor)
- Fractal (jumble of good and bad)

![スイカの行進](https://github.com/clouddan4/amiga2/blob/master/SUIKA.png)
---

#### near future plans
- convert 16color sprite-map-set picture(e.g. TIC-80) <--> Anim Brush
	- or, add to brush-mode: (sprite)map-Brush
- Brush-angle auto align along to TOOL-path
- Pattern_GEN: thunder-bolt anim-effect
- Mapping: TimeDisplace-Map

#### far future plans
- built-in script engine (tiny-FORTH?)
- Bitmap-stroke-Brush along to TOOL-path (Creature House: Expression?)


