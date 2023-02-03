
FUNCTION plot_he2_threads_profiles, wd=wd


;+
; NAME:
;     PLOT_HE2_THREADS_PROFILES
;
; PURPOSE:
;     Shows a time period for the He II 256 profile whereby there is some
;     absorption on the blue side.
;
; OPTIONAL INPUTS:
;     Wd:   The windata structure for He II 256. If this is undefined when
;           calling the routine, then structure is returned and can be
;           used in the following call.
;
; OUTPUTS:
;     Creates the image plot_he2_threads_profiles.jpg in the working
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

;
; exposure 15 is missing so replace with average of neighboring exposures.
;
wd.int[*,15,*]=average(wd.int[*,[14,16],*],2,missing=wd.missing)

ix0=10
ix1=62
il0=5
il1=30

;
; Average over 5 pixels in y-direction.
;
img=average(wd.int[il0:il1,ix0:ix1,48:52],3,missing=wd.missing)

x=wd.wvl[il0:il1]
t_tai=anytim2tai(wd.time_ccsds[ix0:ix1])+wd.exposure_time[ix0:ix1]/2.
t_tai=image_fix_axis(t_tai)
t_utc=anytim2utc(t_tai,/ccsds)
t_jd=tim2jd(t_utc)

xdim=550
ydim=380

th=2
fs=12
xtl=0.015
ytl=0.015

w=window(dim=[xdim,ydim])
p=image(sigrange(img),x,t_jd,axis_sty=2, rgb_table=3, /current, $
        font_size=fs,xth=th,yth=th, $
        ytickunits='time',yTICKFORMAT='(C(CHI2.2,":",CMI2.2))', $
        pos=[0.16,0.12,0.97,0.98], $
        xtickdir=1,ytickdir=1, $
        xmin=1,xticklen=xtl,yticklen=ytl, $
        xtitle='wavelength / '+string(197b), $
        ytitle='time [ hh:mm ]')
p.scale,1,42

tt='2-apr-2022 '+['13:11:30','13:19:00']
tt_jd=tim2jd(tt)
l0=256.20-0.03
l1=256.25-0.03

q=plot(/overplot,[l1,l0,l0,l1],[tt_jd[0],tt_jd[0],tt_jd[1],tt_jd[1]], $
       th=th,color='dodger blue')

w.save,'plot_he2_threads_profiles.jpg',wid=2*xdim

return,w

END
