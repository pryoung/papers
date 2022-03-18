

FUNCTION plot_spray_6_panel_v2, reverse=reverse, blackwhite=blackwhite

;+
; This creates a 6-panel plot showing the development of the flare
; spray in the EIS exposures.
;
;   REVERSE:  Reverses the color table, giving a black background
;             instead of white.
;   BLACKWHITE: If set, then a black-white color table is used instead
;               of AIA 193.
;-


file=eis_find_file('16-feb-2011 14:09:55',/lev)

IF file[0] EQ '' THEN BEGIN
  print,' ** Please download the EIS file at 16-Feb-2011 14:09:55 and calibrate it with eis_prep. **'
  return,-1
ENDIF 

xy=eis_aia_offsets('16-feb-2011 14:09:55')

IF n_tags(wd1) EQ 0 THEN BEGIN 
  wd1=eis_getwindata(file,195.12)
  wd1.solar_y=wd1.solar_y+xy[1]
  wd2=eis_getwindata(file,192.8)
  wd2.solar_y=wd2.solar_y+xy[1]
ENDIF

t_tai=anytim2tai(wd1.time_ccsds)
t_tai=t_tai+45.0/2.0
t_ccsds=anytim2utc(/ccsds,t_tai,/time,/trunc)

;
; Wavelengths from CHIANTI.
;
lref1=195.119
lref2=193.509

v1=lamb2v(wd1.wvl-lref1,lref1)
v2=lamb2v(wd2.wvl-lref2,lref2)

;
; This forces the x-axis to be evenly spaced.
;
v1=image_fix_axis(v1)
v2=image_fix_axis(v2)

iy0=10
iy1=249

fs=9
th=2
xtl=0.020
ytl=0.015

IF keyword_set(reverse) THEN BEGIN 
  bgcolor='black'
  color='white'
ENDIF ELSE BEGIN
  bgcolor='white'
  color='black'
ENDELSE 


x0=0.08
x1=0.98
dx=(x1-x0)/3.
ddx=0.0
y0=0.08
y1=0.98
dy=(y1-y0)/2.
ddy=0.00

xdim=800
ydim=500
w=window(dim=[xdim,ydim],background_color=bgcolor)

IF keyword_set(blackwhite) THEN rgb_table=0 ELSE rgb_table=aia_rgb_table(193)

ix0=19
ix1=ix0+6
FOR ix=ix0,ix1-1 DO BEGIN 

  img1=reform(wd1.int[*,ix,iy0:iy1])
  img2=reform(wd2.int[*,ix,iy0:iy1])

  k=where(img2 NE wd2.missing)
  img2[k]=img2[k]/0.675

  img1=alog10(img1>100)
  img2=alog10(img2>100)

  IF NOT keyword_set(reverse) THEN BEGIN 
    img1=max(img1)-img1
    img2=max(img2)-img2
  ENDIF 
    
  y=wd1.solar_y[iy0:iy1]

  ia=(ix-ix0) MOD 3
  ib=1-(ix-ix0)/3
  pos=[x0+ddx+ia*dx,y0+ddy+ib*dy,x0+(ia+1)*dx,y0+(ib+1)*dy]

  IF ib EQ 0 THEN xshowtext=1 ELSE xshowtext=0
  IF ia EQ 0 THEN yshowtext=1 ELSE yshowtext=0
  
  i1=image(img1,v1,y,axis_style=2,/current, $
           font_size=fs,xthick=th,ythick=th, $
           xticklen=xtl,yticklen=ytl, $
           pos=pos,rgb_table=rgb_table, $
           xcolor=color,ycolor=color, $
           xshowtext=xshowtext,yshowtext=yshowtext)
  i1.scale,1,7.37
  i2=image(img2,v2,y,/overplot,rgb_table=rgb_table)
  axes=i1.axes
  axes[2].showtext=0
  axes[3].showtext=0

  IF ia EQ 2 AND ib EQ 1 THEN l1=plot(/overplot,[-720,-250],[-145,-200],th=th,color='blue')
  IF ia EQ 0 AND ib EQ 0 THEN l2=plot(/overplot,[-720,-250],[-100,-180],th=th,color='blue')
  IF ia EQ 1 AND ib EQ 0 THEN l3=plot(/overplot,[-650,-200],[-80,-180],th=th,color='blue')

  lbl='('+string(78b+byte(ix))+')'
  t=text(-1400,-277,lbl+'!c'+t_ccsds[ix]+' UT',color='white',/data,font_size=fs, $
         font_style='bold',target=i1)

ENDFOR

;
; Add annotation to the plots
;
ax=[0,0.04]
ay=[0,0.04]
arrcol='dark olive green'
a1=arrow(0.42+ax,0.69+ay,th=th,color=arrcol)
a2=arrow(0.73+ax,0.75+ay,th=th,color=arrcol)
a3=arrow(0.13+ax,0.39+ay,th=th,color=arrcol)
a4=arrow(0.45+ax,0.43+ay,th=th,color=arrcol)


xt=text(x0+ddx+(3*dx-ddx)/2.,0.01,'LOS velocity / km s!u-1!n',font_size=fs+1, $
        align=0.5,color=color)
yt=text(0.02,y0+ddy+(2*dy-ddy)/2.,'Solar-Y / arcsec',font_size=fs+1,align=0.5, $
        orient=90,color=color)

w.save,'plot_spray_6_panel_v2.png',width=2*xdim

return,w

END
