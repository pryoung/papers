
FUNCTION plot_cool_loops

;+
; NAME:
;     PLOT_COOL_LOOPS
;
; PURPOSE:
;     Creates an IDL plot object showing an example of cool loop
;     footpoints. 
;
; CATEGORY:
;     Paper; figure.
;
; CALLING SEQUENCE:
;     Result = PLOT_COOL_LOOPS()
;
; INPUTS:
;     None.
;
; OUTPUTS:
;     An IDL plot object.
;
; RESTRICTIONS:
;     The routine requires two files that need to be downloaded from
;     the internet.
;
; EXAMPLE:
;     IDL> w=plot_cool_loops()
;
; MODIFICATION HISTORY:
;     Ver.1, 21-Sep-2023, Peter Young
;-


aia_file='aia.lev1.171A_2010-09-22T11_50_00.34Z.image_lev1.fits'
chck=file_search(aia_file,count=count)
IF count EQ 0 THEN BEGIN
  message,/info,/cont,'Please download the AIA file aia.lev1.171A_2010-09-22T11_50_00.34Z.image_lev1.fits from the VSO and put it in the working directory. Returning...'
  return,''
ENDIF 

IF n_tags(smap) EQ 0 THEN BEGIN 
  map=sdo2map(aia_file)
  p=[-50,-600]
  sub_map,map,smap,xrange=p[0]+[-250,250],yrange=p[1]+[-200,200]
ENDIF 


xdim=850
ydim=420
w=window(dim=[xdim,ydim])

y0=0.10
y1=0.98

th=2
fs=12

p=plot_map_obj(smap,rgb_table=aia_rgb_table(171),/log,dmin=100, $
               pos=[0.10,y0,0.605,y1], $
               title='',/current, $
               xth=th,yth=th,font_size=fs, $
               xticklen=0.015,yticklen=0.015, $
               xtickdir=1,ytickdir=1, $
               xmin=1,ymin=1)
pt=text(/data,-280,-435,'(a) AIA 171 '+string(197b)+', 11:50 UT',color='white', $
        font_size=fs)


eis_file='20100922/20100922_112633_si7_mask.save'
chck=file_search(eis_file,count=count)
IF count EQ 0 THEN BEGIN
  message,/info,/cont,'Please download the zip file from Zenodo. The DOI is 10.5281/zenodo.8368508. Unpack it in the working directory. Returning...'
  return,''
ENDIF 
restore,eis_file

map2range,map,xrange=xra,yrange=yra
dx=10
dy=-10
xra=xra+dx
yra=yra+dy

map.xc=map.xc+dx
map.yc=map.yc+dy

p2=plot(/overplot, $
        [xra[0],xra[1],xra[1],xra[0],xra[0]], $
        [yra[0],yra[0],yra[1],yra[1],yra[0]], $
        th=th,color='dodger blue')

;--
q=plot_map_obj(map,rgb_table=aia_rgb_table(193), $
               pos=[0.675,y0,0.98,y1],/current, $
               title='', $
               xth=th,yth=th,font_size=fs, $
               xticklen=0.015,yticklen=0.015, $
               xtickdir=1,ytickdir=1, $
               xmin=1,ymin=1,ytitle='')
qt=text(/data,-50+dx,-500+dy,'(b) EIS, Si VII 275.37 '+string(197b)+'!c      11:26 UT',color='white', $
        font_size=fs,target=q,vertical_align=1.0)


map2=map
map2.data=mask.image

r=plot_map_obj(map2,/contour,color='dodger blue',levels=[1],c_thick=th)

w.save,'plot_cool_loops.png',width=2*xdim

return,w

END
