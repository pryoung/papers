

FUNCTION plot_256_192_composite, wd256=wd256, wd192=wd192

;+
; NAME:
;     PLOT_256_192_COMPOSITE
;
; PURPOSE:
;     Creates a figure for the Janvier et al. (2023, A&A) paper about
;     the 2-Apr-2022 filament eruption. The figure shows the evolution
;     of the EIS slit emission and is a composite of he II 256 and
;     Fe XXIV 192.
;
; CATEGORY:
;     Journal figure.
;
; CALLING SEQUENCE:
;     Result = PLOT_256_192_C0MPOSITE( )
;
; INPUTS:
;     None.
;
; OPTIONAL INPUTS:
;     WD256:  To save reloading the data, the previously-generated
;             windata structure for the 256 line can be input.
;     WD192:  To save reloading the data, the previously-generated
;             windata structure for the 192 line can be input.
;	
; KEYWORD PARAMETERS:
;     None.
;
; OUTPUTS:
;     Returns an IDL plot object and also puts a jpeg version of the
;     figure in the user's working directory (name:
;     plot_256_192_composite.jpg).
;
;     If a problem is found, then a value of -1 is returned.
;
; OPTIONAL OUTPUTS:
;     WD256:  The windata structure for the He II 256 line.
;     WD192:  The windata structure for the He II 256 line.
;
; RESTRICTIONS:
;     The user must have the level-1 EIS file with ID 20220402_130542
;     on their computer.
;
; EXAMPLE:
;     IDL> w=plot_256_192_composite()
;
; MODIFICATION HISTORY:
;     Ver.1, 04-May-2023, Peter Young
;-




IF n_tags(wd256) EQ 0 THEN BEGIN
  file=eis_find_file('2-apr-2022 13:30',/lev,count=count)
  IF count EQ 0 THEN BEGIN
    message,/cont,/info,'Please download the EIS file 20220402_130542 and calibrate it to level-1 before using this routine. Returning...'
    return,-1
  ENDIF 
  wd256=eis_getwindata(file,256.32,/refill)
ENDIF 


IF n_tags(wd192) EQ 0 THEN BEGIN
  file=eis_find_file('2-apr-2022 13:30',/lev,count=count)
  IF count EQ 0 THEN BEGIN
    message,/cont,/info,'Please download the EIS file 20220402_130542 and calibrate it to level-1 before using this routine. Returning...'
    return,-1
  ENDIF 
  wd192=eis_getwindata(file,192.08,/refill)
ENDIF 


k1=where(wd256.solar_y GE 180.9 AND wd256.solar_y LE 316.5)
k2=where(wd192.solar_y GE 180.9 AND wd192.solar_y LE 316.5)

xy=eis_aia_offsets(wd256.hdr.date_obs)
yax=wd256.solar_y[k1]+xy[1]+15.


lref=256.32+v2lamb(-100,256.32)
getmin=min(abs(wd256.wvl-lref),imin)

int1=average(wd256.int[imin-3:imin+3,*,k1],1,missing=wd256.missing)
int2=average(wd192.int[15:25,*,k2],1,missing=wd192.missing)

t1_jd=tim2jd(wd256.time_ccsds)
xax=image_fix_axis(t1_jd)


;
; Do interpolation of missing data for display purposes.
;
IF ~ keyword_set(no_interp) THEN BEGIN 
  int1[15,*]=average(int1[[14,16],*],1,missing=wd256.missing)
  int1[72,*]=average(int1[[71,73],*],1,missing=wd256.missing)
ENDIF 
  

;
; Combine the He II and Fe XXIV images. I multiply the Fe XXIV
; image for display purposes.
;
ix=83
int1[ix:*,*]=int2[ix:*,*]*1.5


;
; Take square root and invert image.
;
int1=sqrt(int1>800<40000)


xdim=900
ydim=400
w=window(dim=[xdim,ydim])

xtl=0.016
ytl=0.007
fs=12
th=2

;
; Trim the time range.
;
ix0=5 & ix1=204
int1=int1[ix0:ix1,*]
xax=xax[ix0:ix1]

;
; Plot the image.
;
p=image(int1,xax,yax,rgb_table=aia_rgb_table(304),axis_sty=2, $
        pos=[0.09,0.115,0.97,0.98], $
        title='',/current, $
        xtickunits='time',XTICKFORMAT='(C(CHI2.2,":",CMI2.2))', $
        ytitle='solar-y / arcsec', $
        xtitle='time [ 2-Apr-2022 hh:mm ]', $
        xticklen=xtl,yticklen=ytl, $
        xtickdir=1,ytickdir=1, $
        font_size=fs,xth=th,yth=th, $
        ymin=1,xmin=9)
p.scale,8500,1

;
; Plot the boundary between the images.
;
pl=plot(/overplot,t1_jd[ix]*[1,1],p.yrange,th=th,color='white')

;
; Add text labels.
;
ypos=0.20
pt1=text(0.42,ypos,align=1.0, vertical_align=1.0, $
         'He II !9l!3256.32!c(blue wing)',font_size=fs,color='white',target=p)
pt2=text(0.44,ypos,vertical_align=1.0, $
         'Fe XXIV !9l!3192.08',font_size=fs,color='white',target=p)
;
ypos=0.90
pt3=text(target=p,0.13,ypos,'Filament eruption',font_size=fs+2,color='white')
pt4=text(target=p,0.70,ypos,'Hot post-flare loops',font_size=fs+2,color='white')


;
; Add labels for the three features.
;
acol='light goldenrod'

tt='2-Apr-2022 '+['13:09','13:20']
tt_jd=tim2jd(tt)
a1=arrow(tt_jd,210*[1,1],th=th,color=acol,/data,arrow_sty=3)
pa1_1=plot(/overplot,tt_jd[0]*[1,1],[205,260],color=acol,linesty=':',th=th)
pa1_2=plot(/overplot,tt_jd[1]*[1,1],[205,260],color=acol,linesty=':',th=th)
tt='2-Apr-2022 13:10'
tt_jd=tim2jd(tt)
t1=text(/data,tt_jd,213,'(1)',font_size=fs,color=acol)


tt='2-Apr-2022 '+['13:15','13:21']
tt_jd=tim2jd(tt)
a4=arrow(tt_jd,[283,318],th=th,color=acol,/data,arrow_sty=3)
tt='2-Apr-2022 13:16:40'
tt_jd=tim2jd(tt)
t1=text(/data,tt_jd,303,'(2)',font_size=fs,color=acol)

tt='2-Apr-2022 '+['13:21','13:26']
tt_jd=tim2jd(tt)
a5=arrow(tt_jd,[1,1]*245,th=th,color=acol,/data,arrow_sty=3)
pa5_1=plot(/overplot,tt_jd[0]*[1,1],[240,290],color=acol,linesty=':',th=th)
pa5_2=plot(/overplot,tt_jd[1]*[1,1],[240,290],color=acol,linesty=':',th=th)
t5=text(align=0.5,/data,mean(tt_jd),237,'(3)',font_size=fs,color=acol)




w.save,'plot_256_192_composite.jpg',width=2*xdim

return,w

END
