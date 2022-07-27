

FUNCTION plot_ar_model, map=map

;+
; This is a 2-panel plot for the Venus scattered light paper (Appendix).
; It shows the 14-Feb-2011 observation on the left, and the AR model on
; the right.
;
; OPTIONAL INPUT/OUTPUT:
;     Map:  The AIA map can be output to this. Giving it as an input then
;     speeds up the routine.
;
; CALLS:
;     SYNTHETIC_IMAGE, SDO2MAP
;
; HISTORY:
;     Ver.1, 26-Jul-2022, Peter Young
;-

img=synthetic_image()
s=size(img,/dim)

c=findgen(101)/100.*2.*!pi
xc=sin(c)
yc=cos(c)


x0=0.02
x1=0.98
dx=(x1-x0)/2.
ddx=0.07
y0=0.10
y1=0.98

th=2
fs=12
xtl=0.015
ytl=0.015

;-----------------------
; LEFT PANEL
;
IF n_tags(map) EQ 0 THEN BEGIN
  file='aia/aia.lev1.193A_2011-02-14T10_55_07.84Z.image_lev1.fits'
  chck=file_info(file)
  IF chck.exists EQ 0 THEN BEGIN
    message,/info,/cont,'The AIA file was not found. It is expected to be in:'
    print,'  ',file
    return,-1
  ENDIF 
  map=sdo2map(file)
ENDIF 
xpos=85.5-76.6
ypos=-228+64.3
sub_map,map,smap,xra=xpos+[-(s[0]-1)/2.*0.6,(s[0]-1)/2.*0.6], $
        yra=ypos+[-(s[0]-1)/2.*0.6,(s[0]-1)/2.*0.6]

xdim=900
ydim=430
w=window(dim=[xdim,ydim])

p=plot_map_obj(smap,rgb_table=aia_rgb_table(193), $
               pos=[x0+ddx,y0,x0+dx,y1],/current,/log,dmin=30, $
               font_size=fs,title='',xth=th,yth=th, $
               xmin=4,ymin=4,xticklen=xtl,yticklen=ytl, $
               xtitle='solar-x [ arcsec ]', $
               ytitle='solar-y [ arcsec ]')

px=plot(/overplot,xpos*[1,1],ypos*[1,1],symbol='+', $
        sym_size=3,color='dodger blue',sym_thick=th)

pc1=plot(/overplot,30.*xc+xpos,30.*yc+ypos,th=th,color='dodger blue')
pc2=plot(/overplot,50.*xc+xpos,50.*yc+ypos,th=th,color='dodger blue')

xr=p.xrange
yr=p.yrange
pt=text(0.95*xr[0]+0.05*xr[1],0.90*yr[1]+0.10*yr[0],'(a)',font_size=fs+2,/data, $
        color='white')

;-----------------------
; RIGHT PANEL
;
x=fltarr(s[0])
x=(findgen(s[0])-(s[0]-1)/2.)*.6
y=fltarr(s[1])
y=(findgen(s[1])-(s[1]-1)/2.)*.6

img=reverse(img,2)
img=(img<200.)
q=image(img,x,y,axis_style=2,  $
        pos=[x0+dx+ddx,y0,x0+2*dx,y1],/current, $
        font_size=fs,title='',xth=th,yth=th, $
        xmin=4,ymin=4,xticklen=xtl,yticklen=ytl, $
        xtitle='solar-x [ arcsec ]')

qc2=plot(/overplot,50.*xc,50.*yc,th=th,color='dodger blue')

xr=q.xrange
yr=q.yrange
qt=text(0.95*xr[0]+0.05*xr[1],0.90*yr[1]+0.10*yr[0],'(b)',font_size=fs+2,/data, $
        color='white',target=q)

w.save,'plot_ar_model.png',width=2*xdim


return,w

END
