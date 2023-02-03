

FUNCTION plot_he2_twist, wd=wd


;+
; NAME:
;     PLOT_HE2_TWIST
;
; PURPOSE:
;     Shows the He II 256 line profile as a function of y for an exposure
;     where "twist" is apparent in the Doppler pattern.
;
; OPTIONAL INPUTS:
;     Wd:   The windata structure for He II 256. If this is undefined when
;           calling the routine, then structure is returned and can be
;           used in the following call.
;
; OUTPUTS:
;     Creates the image plot_he2_twist.jpg in the working
;     directory and returns an IDL plot object.
;
; MODIFICATION HISTORY:
;     Ver.1, 03-Feb-2023, Peter Young
;-


IF n_tags(wd) EQ 0 THEN BEGIN 
  file=eis_find_file('2-apr-2022 13:54',/lev,count=count)
  IF count EQ 0 THEN BEGIN
    message,/cont,/info,'Please download the EIS file 20220402_130542 and calibrate it to level-1 before using this routine. Returning...'
    return,-1
  ENDIF 
  wd=eis_getwindata(file,256.32,/refill)
ENDIF


iy0=50
iy1=94

img=reform(wd.int[*,39,iy0:iy1])

xdim=550
ydim=500
w=window(dim=[xdim,ydim])

lref=256.36
v=lamb2v(wd.wvl-lref,lref)

xy=eis_aia_offsets(wd.hdr.date_obs)
y=wd.solar_y[iy0:iy1]+xy[1]+15.


fs=12
th=2
xtl=0.015
ytl=0.015

p=image(axis_sty=2,img,v,y,rgb_table=3,/current, $
        pos=[0.13,0.12,0.98,0.98], $
        font_size=fs,xth=th,yth=th, $
        xticklen=xtl,yticklen=ytl, $
        xtitle='LOS velocity / km s!u-1!n', $
        ytitle='y / arcsec', $
       xtickdir=1,ytickdir=1,ymin=1)
p.scale,1,17


pt=text(/data,-460,294,'EIS, He II 256.32 '+string(197b)+'!c13:16:15 UT', $
        color='white',font_size=fs)

pl=arrow(th=th,color='dodger blue',[-350,-150],[280,266],/overplot, $
         arrow_sty=3,/data)

pltxt=text(-470,270,/data,'blueshifted!cfilament plasma',font_size=fs, $
           color='dodger blue')

w.save,'plot_he2_twist.jpg',width=2*xdim

return,w

END

