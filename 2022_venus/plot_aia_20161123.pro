
FUNCTION plot_aia_20161123

;+
;  This routine creates the file plot_aia_20161123.png for the Venus
;  transit paper.
;
;  The displayed map is in a save file. If you don't have it, then you
;  need to download the full AIA image from the JSOC.
;
; PRY, 26-Apr-2022
;-



aia_save_file='aia_map_data.save'
chck=file_info(aia_save_file)
IF chck.exists EQ 0 THEN BEGIN
  file='aia.lev1_euv_12s.2016-11-23T040007Z.193.image_lev1.fits'
  map=sdo2map(file)
  dd=200
  sub_map,map,smap,xra=[-dd,dd]+68,yra=[-dd,dd]+620
  save,file=aia_save_file,smap
ENDIF ELSE BEGIN
  restore,aia_save_file
ENDELSE 


th=2
fs=12

xdim=480
ydim=450
w=window(dim=[xdim,ydim])

p=plot_map_obj(smap,rgb_table=aia_rgb_table(193),/log,dmin=12, $
               xth=th,yth=th,font_size=fs, $
               pos=[0.14,0.11,0.98,0.98], $
               title='', $
               xticklen=0.015,yticklen=0.015,xmin=4,ymin=4, $
               xtickdir=1,ytickdir=1,/current)


x0=68.
y0=620.

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

p.save,'plot_aia_20161123.png',width=2*xdim


return,w

END
