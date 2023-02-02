
;
; Feature (1) of the EIS evolution shows some dark threads passing
; through the EIS slit. These cause absorption on the blue side of
; the line profile. This figure shows this absorption as a function
; of time.
; 

IF n_tags(wd) EQ 0 THEN BEGIN 
  file=eis_find_file('2-apr-2022 13:54',/lev,/seq)
  wd=eis_getwindata(file[0],256.32,/refill)
ENDIF

wd.int[*,15,*]=average(wd.int[*,[14,16],*],2,missing=wd.missing)

ix0=10
ix1=62
il0=5
il1=30

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
        pos=[0.16,0.11,0.97,0.98], $
        xtickdir=1,ytickdir=1, $
        xmin=1,xticklen=xtl,yticklen=ytl, $
        xtitle='wavelength / '+string(197b), $
        ytitle='Time [ HH:MM ]')
p.scale,1,42

tt='2-apr-2022 '+['13:11:30','13:19:00']
tt_jd=tim2jd(tt)
l0=256.20-0.03
l1=256.25-0.03

q=plot(/overplot,[l1,l0,l0,l1],[tt_jd[0],tt_jd[0],tt_jd[1],tt_jd[1]], $
       th=th,color='dodger blue')

;pa=arrow(/data,[256.2,256.28],t_jd[32]*[1,1],th=2,color='dodger blue')
;pa2=arrow(/data,[256.19,256.27],t_jd[25]*[1,1],th=2,color='dodger blue')

w.save,'plot_he2_threads_profiles.jpg',wid=xdim

END
