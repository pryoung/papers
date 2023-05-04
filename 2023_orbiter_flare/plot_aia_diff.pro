
FUNCTION plot_aia_diff

;+
; NAME:
;     PLOT_AIA_DIFF
;
; PURPOSE:
;     A 2-panel plot showing an AIA 304 image during the early rise phase (a)
;     and then a difference image obtained from 36s later (b).
;
; CATEGORY:
;     Journal figure.
;
; CALLING SEQUENCE:
;     Result = PLOT_AIA_DIFF( )
;
; INPUTS:
;     None.
;
; OUTPUTS:
;     Creates the image plot_aia_diff.jpg in the working directory
;     and returns an IDL plot object.
;
; RESTRICTIONS:
;     This needs to be run in the Github repository directory.
;
; EXAMPLE:
;     IDL> w=plot_aia_diff()
;
; MODIFICATION HISTORY:
;     Ver.1, 02-Feb-2023, Peter Young
;     Ver.2, 04-May-2023, Peter Young
;       Tidied up for release in GitHub repository.
;-



;
; The following checks if the AIA files are available. If the routine is
; run from the GitHub repository, then they will be found in the
; data/aia_diff sub-directory.
;
dir=concat_dir('data','aia_diff')
list=file_search(dir,'*.fits',count=count)
IF count EQ 0 THEN BEGIN
  chck=file_info(dir)
  IF chck.exists EQ 0 THEN file_mkdir,dir
 ;
  list=file_search('~/data/flares/20220402/jsoc_cutouts/respike/*_0304.fits')
  file_copy,list[68:75],dir,/overwrite
  message,/info,/cont,'Image files have been copied. Please run routine again to create plot.'
  return,-1
ENDIF ELSE BEGIN
  amap=sdo2map(list,/clean)
ENDELSE 


sub_map,amap,samap,xra=[750,970],yra=[170,370]

map1=samap[2]
map2=samap[5]

;
; Convert map2 to the difference image.
;
map2.data=map2.data-map1.data

x0=0.02
x1=0.98
dx=(x1-x0)/2.
ddx=0.05
y0=0.10
y1=0.98

xdim=820
ydim=400

fs=12
th=2
xtl=0.02
ytl=0.02

w=window(dim=[xdim,ydim])


;
; Plot panel (a)
;
p=plot_map_obj(map1,rgb_table=aia_rgb_table(304),/log,dmin=2, $
               /current,pos=[x0+ddx,y0,x0+dx,y1], $
               xth=th,yth=th,font_size=fs, $
               xticklen=xtl,yticklen=ytl, $
               xtitle='x / arcsec', $
               ytitle='y / arcsec', $
               title='')
tstr=anytim2utc(map1.time,/ccsds,/time,/trunc)+' UT'
pt=text(/data,800,345,font_size=fs, $
        '(a) AIA 304 '+string(197b)+', '+tstr,color='white')

pa=arrow(/data,[911,930],[284,310],color='white',target=p, $
         th=th,arrow_sty=2)
pat=text(/data,930,310,'(2)',font_size=fs,target=p,color='white')
;
pa2=arrow(/data,[850,880],[310,295],color='white',target=p, $
         th=th)
pat2=text(/data,850,310,'(1)',align=1.0,font_size=fs,target=p,color='white')
;
pa3=arrow(/data,[885,868],[325,317],color='white',target=p, $
         th=th)
pat3=text(/data,897,327,'(3)',align=1.0,font_size=fs,target=p,color='white')


;
; Plot panel (b)
;
q=plot_map_obj(map2,dmin=-10,dmax=10, $
               /current,pos=[x0+dx+ddx,y0,x0+2*dx,y1], $
               xth=th,yth=th,font_size=fs, $
               xticklen=xtl,yticklen=ytl, $
               xtitle='x / arcsec', $
               ytitle='', $
               title='')
qt=text(/data,800,345,'(b) Difference image (+36 s)',font_size=fs,target=q, $
        color='white')

bx0=890 & bx1=940
by0=q.yrange[0]+1 & by1=270
b=plot(/overplot,[bx0,bx1,bx1,bx0,bx0],[by0,by0,by1,by1,by0], $
       th=th,linesty='--',color='yellow',yrange=q.yrange)

xy=eis_aia_offsets(map1.time)
eis_x=889.6+xy[0]+8.
eis_y=181.4+xy[1]+15.
q2=plot(eis_x*[1,1],eis_y+[0,152],th=2,color='blue',/overplot)

w.save,'plot_aia_diff.jpg',width=2*xdim

return,w

END
