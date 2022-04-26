

FUNCTION plot_20161123_regions

;+
;  Creates the file plot_20161123_regions.png that was used in the Venus
;  transit paper.
;
; PRY, 26-Apr-2022
;-

fitfile='20161123_0308_fit_fe12_195.save'
chck=file_info(fitfile)
IF chck.exists EQ 0 THEN BEGIN
  message,'This routine requires the '+fitfile+' to be in the current working directory. Returning...',/cont,/info
  return,-1
ENDIF 
restore,fitfile

int=eis_get_fitdata(fitx,/map)


th=2
fs=12

xdim=460
ydim=450
w=window(dim=[xdim,ydim])

p=plot_map_obj(int,rgb_table=aia_rgb_table(193),/log,dmin=10, $
               xth=th,yth=th,font_size=fs, $
               pos=[0.13,0.10,0.98,0.98], $
               xmin=1,ymin=1, $
               xticklen=0.015,yticklen=0.018,/current)

x0=163
y0=532

th=findgen(101)/100.*2.*!pi
x1=x0+30.*cos(th)
y1=y0+30.*sin(th)

x2=x0+50.*cos(th)
y2=y0+50.*sin(th)

;
; Plot CH annulus regions
;
q=plot(/overplot,x1,y1,th=2,col='dodger blue')
r=plot(/overplot,x2,y2,th=2,col='dodger blue')
s=plot(/overplot,[1,1]*x0,[1,1]*y0,symbol='+',color='dodger blue', $
       sym_size=2,sym_thick=2)


;
; Plot quiet Sun box.
;
x=-185+[-30,30,30,-30,-30]
y=415+[-30,-30,30,30,-30]
b=plot(/overplot,x,y,th=2,color='white')

p.save,'plot_20161123_regions.png',resolution=2.*xdim

return,p

END
