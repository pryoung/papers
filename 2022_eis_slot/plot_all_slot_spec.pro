

FUNCTION plot_all_slot_spec


; This is a multipanel plot that shows the full spectra for all three
; detector segments. It is Figure 1 in the paper.


file=eis_find_file('15-may-2007 05:41',/lev)

wd0=eis_getwindata(file,0)
wd1=eis_getwindata(file,1)
wd2=eis_getwindata(file,2)
wd3=eis_getwindata(file,3)

x0=0.07
x1=0.99
y0=0.02
y1=0.98
dy=(y1-y0)/4.
ddy=0.04

aia_wvl=193

th=2
fs=12
xtl=0.03
ytl=0.005

xscale=32

w=window(dim=[1000,700])

iy=[40,149]
ny=iy[1]-iy[0]+1

lines=0
str={ion: '', wvl: 0., channel: 0 }
openr,lin,'slot_lines.txt',/get_lun
WHILE eof(lin) NE 1 DO BEGIN
   readf,lin,format='(a8,f7,i3)',str
   IF n_tags(lines) EQ 0 THEN lines=str ELSE lines=[lines,str]
ENDWHILE 

;
; SW 1 channel
; ------------
wvl=wd0.wvl
ea=eis_eff_area(wvl)
img=reform(wd0.int[*,0,iy[0]:iy[1],0])
FOR i=0,ny-1 DO img[*,i]=img[*,i]/ea
wvlx=image_fix_axis(wvl)
yax=findgen(ny)

pimg=sqrt(img>100)
pimg=max(pimg)-pimg
p=image(pimg,wvlx,yax,axis_style=2,/current, $
        pos=[x0,y0+3*dy+ddy,x1,y0+4*dy], $
        rgb_table=aia_rgb_table(aia_wvl), $
        xth=th,yth=th,font_size=fs, $
        ymin=1, $
       xticklen=0.03,yticklen=ytl, ytext_orient=-45)
p.scale,xscale,1

k=where(lines.channel EQ 0,nk)
FOR i=0,nk-1 DO BEGIN
   txt=text(/data,lines[k[i]].wvl,95,trim(lines[k[i]].ion),color='blue', $
            font_size=fs,align=0.5)
ENDFOR 

;
; SW 2 channel
; ------------
wvl=wd1.wvl
ea=eis_eff_area(wvl)
img=reform(wd1.int[*,0,iy[0]:iy[1],0])
FOR i=0,ny-1 DO img[*,i]=img[*,i]/ea
wvlx=image_fix_axis(wvl)
yax=findgen(ny)

pimg=sqrt(img>100)
pimg=max(pimg)-pimg
p=image(pimg,wvlx,yax,axis_style=2,/current, $
        pos=[x0,y0+2*dy+ddy,x1,y0+3*dy], $
        rgb_table=aia_rgb_table(aia_wvl), $
        xth=th,yth=th,font_size=fs, $
        ymin=1, $
        xticklen=0.03,yticklen=ytl, ytext_orient=-45)
p.scale,xscale,1

k=where(lines.channel EQ 1,nk)
FOR i=0,nk-1 DO BEGIN
   txt=text(/data,lines[k[i]].wvl,95,trim(lines[k[i]].ion),color='blue', $
            font_size=fs,align=0.5,target=p)
ENDFOR 

iy=iy-18

;
; LW 1 channel
; ------------
wvl=wd2.wvl
ea=eis_eff_area(wvl)
img=reform(wd2.int[*,0,iy[0]:iy[1],0])
FOR i=0,ny-1 DO img[*,i]=img[*,i]/ea
wvlx=image_fix_axis(wvl)
yax=findgen(ny)

pimg=sqrt(img>100)
pimg=max(pimg)-pimg
p=image(pimg,wvlx,yax,axis_style=2,/current, $
        pos=[x0,y0+1*dy+ddy,x1,y0+2*dy], $
        rgb_table=aia_rgb_table(aia_wvl), $
        xth=th,yth=th,font_size=fs, $
        ymin=1, $
       xticklen=0.03,yticklen=ytl, ytext_orient=-45)
p.scale,xscale,1

k=where(lines.channel EQ 2,nk)
FOR i=0,nk-1 DO BEGIN
   txt=text(/data,lines[k[i]].wvl,95,trim(lines[k[i]].ion),color='blue', $
            font_size=fs,align=0.5,target=p)
ENDFOR 


; LW 2 channel
; ------------
wvl=wd3.wvl
ea=eis_eff_area(wvl)
img=reform(wd3.int[*,0,iy[0]:iy[1],0])
FOR i=0,ny-1 DO img[*,i]=img[*,i]/ea
wvlx=image_fix_axis(wvl)
yax=findgen(ny)

pimg=sqrt(img>100<50000.)
pimg=max(pimg)-pimg
p=image(pimg,wvlx,yax,axis_style=2,/current, $
        pos=[x0,y0+0*dy+ddy,x1,y0+1*dy], $
        rgb_table=aia_rgb_table(aia_wvl), $
        xth=th,yth=th,font_size=fs, $
        ymin=1, $
       xticklen=0.03,yticklen=ytl, ytext_orient=-45)
p.scale,xscale,1

k=where(lines.channel EQ 3,nk)
FOR i=0,nk-1 DO BEGIN
   txt=text(/data,lines[k[i]].wvl,95,trim(lines[k[i]].ion),color='blue', $
            font_size=fs,align=0.5,target=p)
ENDFOR 


xt=text(align=0.5,0.5*(x0+x1),0.005,'Wavelength / '+string(197b),font_size=fs+2)
yt=text(orient=270,align=0.5,0.01,y0+ddy+0.5*(4*dy-ddy),'Y-pixel [ 1 pixel = 1 arcsec ]', $
        font_size=fs+2)

w.save,'plot_all_slot_spec.png',resolution=192

return,w

END
