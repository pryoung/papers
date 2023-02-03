

FUNCTION plot_profiles_132153, wd256=wd256, wd195=wd195


;+
; NAME:
;     PLOT_PROFILES_132153
;
; PURPOSE:
;     Compares eruption line profiles between He II 256 and Fe XII 195,
;     showing that both have a high velocity component.
;
; OPTIONAL INPUTS:
;     Wd195: The windata structure for Fe XII 195. If this is undefined when
;            calling the routine, then structure is returned and can be
;            used in the following call.
;     Wd256: The windata structure for He II 256. If this is undefined when
;            calling the routine, then structure is returned and can be
;            used in the following call.
;
; OUTPUTS:
;     Creates the image plot_profiles_132153.jpg in the working
;     directory and returns an IDL plot object.
;
; MODIFICATION HISTORY:
;     Ver.1, 03-Feb-2023, Peter Young
;-


IF n_tags(wd256) EQ 0 THEN BEGIN 
  file=eis_find_file('2-apr-2022 13:30',/lev,count=count)
  IF count EQ 0 THEN BEGIN
    message,/cont,/info,'Please download the EIS file 20220402_130542 and calibrate it to level-1 before using this routine. Returning...'
    return,-1
  ENDIF 
  wd256=eis_getwindata(file,256.32,/refill)
ENDIF


IF n_tags(wd195) EQ 0 THEN BEGIN 
  file=eis_find_file('2-apr-2022 13:30',/lev,count=count)
  IF count EQ 0 THEN BEGIN
    message,/cont,/info,'Please download the EIS file 20220402_130542 and calibrate it to level-1 before using this routine. Returning...'
    return,-1
  ENDIF 
  wd195=eis_getwindata(file,195.12,/refill)
ENDIF


;
; y-pos for He II 256
;
iy0=102

xy=eis_aia_offsets(wd256.hdr.date_obs)
solar_y=wd256.solar_y[iy0]+xy[0]+15.


y256=average(reform(wd256.int[*,60,iy0-1:iy0+1]),2,missing=wd256.missing)
lref=256.358
v256=lamb2v(wd256.wvl-lref,lref)

o195=eis_ccd_offset(195.12)
iy1=iy0+round(o195)

y195=average(reform(wd195.int[*,60,iy1-1:iy1+1]),2,missing=wd195.missing)
v195=lamb2v(wd195.wvl-195.12,195.12)

xdim=600
ydim=400
w=window(dim=[xdim,ydim])

th=2
fs=12
xtl=0.018
ytl=0.012

p=plot(v256,(y256/1e3)-1.6,/stairstep,color='red',xra=[-650,200], $
       /xsty,/current, $
       xth=th,yth=th,th=th,font_size=fs, $
       yrange=[0,22],/ysty, $
       pos=[0.11,0.12,0.97,0.98], $
       xtitle='v!dLOS!n / km s!u-1!n', $
       ytitle='intensity / x 10!u3!n erg cm!u-2!n s!u-1!n sr!u-1!n pix!u-1!n', $
       xticklen=xtl,yticklen=ytl,name='He II 256')
pl=plot(/overplot,[0,0],p.yrange,th=th,linesty=':')

q=plot(/overplot,v195,(y195/1e3)-1.8,/stairstep,color='blue', $
       xra=p.xrange,th=th,/current,name='Fe XII 195')

pt=text(/data,-620,20,'13:21:53 UT, y='+trim(round(solar_y)),font_size=fs)

l=legend(target=[p,q],/data,pos=[-380,13],linesty=':',font_size=fs)

w.save,'plot_profiles_132153.png',width=2*xdim

return,w

END
