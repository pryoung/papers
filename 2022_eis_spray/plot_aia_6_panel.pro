

FUNCTION plot_aia_6_panel


;+
;  Generates a six-panel plot showing the AIA 193 images corresponding
;  to the EIS exposures.
;-



eis_times=['14:25:08','14:25:55','14:26:42','14:27:29','14:28:16','14:29:03']

eis_tai=anytim2tai('16-feb-2011 '+eis_times)

aiadir='aia_dir'
aia_files=file_search(aiadir,'*.193.*.fits')


;
; The EIS X-location is 440.3 after the EIS-AIA correction.
;
eis_xcen=440.3+5

map=sdo2map(aia_files)
mapx=sdo_align_map(map,xra=eis_xcen+[-40,40],yra=[-286.3,-47.3])


x0=0.07
x1=0.99
dx=(x1-x0)/6.
ddx=0.0
y0=0.08
y1=0.98

th=2
fs=9
xtl=0.015
ytl=0.030

xdim=800
ydim=405
w=window(dim=[xdim,ydim])

FOR i=0,5 DO BEGIN
  pos=[x0+ddx+i*dx,y0,x0+(i+1)*dx,y1]

  IF i EQ 0 THEN yshowtext=1 ELSE yshowtext=0
  p=plot_map_obj(mapx[i],rgb_table=aia_rgb_table(193), $
                 /log, dmin=100, $
                 pos=pos,/current, $
                 title='', $
                 xticklen=xtl,yticklen=ytl, $
                 yshowtext=yshowtext, $
                 xth=th,yth=th,font_size=fs, $
                 xtitle='', $
                 xmajor=2,xtickval=[420,460],xmin=3)
  tstr='('+string(byte(i)+97b)+') '+anytim2utc(mapx[i].time,/time,/trunc,/ccsds)+' UT'
  pt=text(eis_xcen-37,-280,tstr,font_size=fs-1,color='black',/data,target=p)
  ax=p.axes
  ax[3].showtext=0

  l1=plot(/overplot,(eis_xcen-2)*[1,1],p.yrange,th=th,linesty=':',color='dodger blue')
  l2=plot(/overplot,(eis_xcen+2)*[1,1],p.yrange,th=th,linesty=':',color='dodger blue')
ENDFOR

xx=[0,0.025]
yy=[0,0.05]
a1=arrow(xx+0.25,yy+0.43,color='dodger blue',thick=th)
a2=arrow(xx+0.40,yy+0.56,color='dodger blue',thick=th)
a3=arrow(xx+0.56,yy+0.71,color='dodger blue',thick=th)
a4=arrow(xx+0.74,yy+0.81,color='dodger blue',thick=th)

xt=text(x0+3*dx,0.005,'Solar-X (arcsec)',font_size=fs,align=0.5)

w.save,'plot_aia_6_panel.png',width=2*xdim

return,w

END 
