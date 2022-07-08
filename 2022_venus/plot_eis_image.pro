

FUNCTION plot_eis_image

;+
;   Creates a 2-panel plot showing a slot raster image of Venus from EIS
;   (left) and a single exposure close-up showing Venus. This plot was used
;   in the Venus transit paper.
;
; PRY, 26-Apr-2022
;
; MODIFICATION HISTORY:
;     Ver.2, 30-Jun-2022, Peter Young
;       Updated axis labels.
;-


level1=1
eis_time='6-jun-2012 00:40'
file=eis_find_file(eis_time,level1=level1,count=count)

IF count EQ 0 THEN BEGIN
  message,'The level-1 EIS file was not found. Please download the level-0 file nearest the time '+eis_time+', calibrate it and put it in your $HINODE directory.',/cont,/info
  return,-1
ENDIF 

map=eis_slot_map(file,195.12)

th=2
fs=12

x0=0.00
x1=0.98
dx=(x1-x0)/2.
ddx=0.12
y0=0.12
y1=0.98

extra={ thick: th, $
        xthick: th, $
        ythick: th, $
        xticklen: 0.015, yticklen: 0.03, $
        font_size: fs, $
        yminor: 4}

xdim=500
ydim=500
w=window(dim=[xdim,ydim])

IF keyword_set(level1) THEN BEGIN
  p_dmin=100
ENDIF ELSE BEGIN
  p_dmin=200
ENDELSE 
p=plot_map_obj(map,/current,/log,rgb_table=aia_rgb_table(193), $
               dim=[300,500],_extra=extra, $
               title='',dmin=p_dmin, $
               xtickdir=1,ytickdir=1, $
               pos=[x0+ddx,y0,x0+dx,y1],xminor=0, $
               xtitle='solar-x [ arcsec ]', $
               ytitle='solar-y [ arcsec ]')
;               pos=[0.2,0.09,0.95,0.98])

t=text(/data,-275,750,font_size=fs,'(a)!cEIS!cFe XII !9l!3195.12!c00:39-00:41 UT',color='white')

wd=eis_getwindata(file,195.12)
img=reform(wd.int[*,3,*])
img=img[*,150:279]

q=image(/current,img, $
        axis_style=2,rgb_table=aia_rgb_table(193), $
        pos=[x0+ddx+dx,y0,x0+2*dx,y1], $
        _extra=extra, $
        xmin=1,xtickdir=1,ytickdir=1, $
       xtitle='x-pixel',ytitle='y-pixel')

xp=8 & yp=48
qb=plot(/overplot,xp+[0,20,20,0,0],yp+[0,0,20,20,0],th=th,color='white')

qe=plot(/overplot,[0.5,0.5],yp+[0,20],th=th+2,color='dodger blue')

w.save,'plot_eis_image.png',width=2*xdim

return,w

END
