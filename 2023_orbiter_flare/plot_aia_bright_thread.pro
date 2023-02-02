

FUNCTION plot_aia_bright_thread

;+
; NAME:
;     PLOT_AIA_BRIGHT_THREAD
;
; PURPOSE:
;     Three-panel plot (stacked vertically) showing AIA 304 images of
;     the north filament leg.
;
; OUTPUTS:
;     Creates the image plot_aia_bright_thread.jpg in the working directory
;     and returns an IDL plot object
;
; RESTRICTIONS:
;     This needs to be run in the Github repository directory.
;
; MODIFICATION HISTORY:
;     Ver.1, 02-Feb-2023, Peter Young
;-

dir=concat_dir('data','aia_bright_thread')
list=file_search(dir,'*.fits',count=count)
IF count EQ 0 THEN BEGIN
  chck=file_info(dir)
  IF chck.exists EQ 0 THEN file_mkdir,dir
 ;
  list=file_search('~/data/flares/20220402/jsoc_cutouts/*.304.image.fits')
  file_copy,list[101],dir,/overwrite
  file_copy,list[111],dir,/overwrite
  file_copy,list[122],dir,/overwrite
  message,/info,/cont,'Image files have been copied. Please run routine again to create plot.'
  return,-1
ENDIF ELSE BEGIN
  amap1=sdo2map(list[0])
  amap2=sdo2map(list[1])
  amap3=sdo2map(list[2])
ENDELSE 


xra=[700,980]
yra=[255,335]

sub_map,amap1,samap1,xra=xra,yra=yra
sub_map,amap2,samap2,xra=xra,yra=yra
sub_map,amap3,samap3,xra=xra,yra=yra

txt1='(a) '+anytim2utc(samap1.time,/ccsds,/time,/trunc)+' UT'
txt2='(b) '+anytim2utc(samap2.time,/ccsds,/time,/trunc)+' UT'
txt3='(c) '+anytim2utc(samap3.time,/ccsds,/time,/trunc)+' UT'

x0=0.13
x1=0.98
y0=0.07
y1=0.98
dy=(y1-y0)/3.

xdim=550
ydim=653
w=window(dim=[xdim,ydim])

fs=12
th=2
xtl=0.020
ytl=0.012

;
; The positions of the EIS slit are obtained from the windata structure
; choosing exposures nearest to the AIA images.
;
p=plot_map_obj(samap1,rgb_table=aia_rgb_table(304), $
               pos=[x0,y0+2*dy,x1,y0+3*dy], $
               xtitle='',ytitle='',title='',/current, $
               /log,dmin=2,dmax=1700, $
               font_size=fs,xth=th,yth=th, $
               xticklen=xtl,yticklen=ytl, $
               xtickdir=1,ytickdir=1,ymin=1, $
               xshowtext=0)
pt=text(/data,795,260,txt1,font_size=fs,color='white')
eis_x=917.6 & eis_y=p.yrange
p_eis=plot(/overplot,eis_x*[1,1],eis_y,th=2,color='dodger blue')
;
q=plot_map_obj(samap2,rgb_table=aia_rgb_table(304), $
               pos=[x0,y0+1*dy,x1,y0+2*dy], $
               xtitle='',ytitle='y / arcsec',title='',/current, $
               /log,dmin=2,dmax=1700, $
               font_size=fs,xth=th,yth=th, $
               xticklen=xtl,yticklen=ytl, $
               xtickdir=1,ytickdir=1,ymin=1)
qt=text(/data,795,260,txt2,font_size=fs,color='white',target=q)
eis_x=917.6 & eis_y=p.yrange
q_eis=plot(/overplot,eis_x*[1,1],eis_y,th=2,color='dodger blue')
;
r=plot_map_obj(samap3,rgb_table=aia_rgb_table(304), $
               pos=[x0,y0,x1,y0+1*dy], $
               xtitle='x / arcsec',ytitle='',title='',/current, $
               /log,dmin=2,dmax=1700, $
               font_size=fs,xth=th,yth=th, $
               xticklen=xtl,yticklen=ytl, $
               xtickdir=1,ytickdir=1,ymin=1)
rt=text(/data,795,260,txt3,font_size=fs,color='white',target=r)
eis_x=917.8 & eis_y=p.yrange
r_eis=plot(/overplot,eis_x*[1,1],eis_y,th=2,color='dodger blue')
r_arr=arrow(/data,[950,943],[316,303],th=th,color='dodger blue',target=r)

w.save,'plot_aia_bright_thread.jpg',wid=2*xdim


return,w

END
