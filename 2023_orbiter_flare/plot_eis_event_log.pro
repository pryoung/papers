

FUNCTION plot_eis_event_log, goes=goes, wd=wd, no_interp=no_interp

;+
; NAME:
;     PLOT_EIS_EVENT_LOG
;
; PURPOSE:
;     An image showing the time-y intensity variation of the He II 256
;     line (blue wing).
;
; OPTIONAL INPUTS:
;     Wd:   The windata structure for He II 256. If this is undefined when
;           calling the routine, then structure is returned and can be
;           used in the following call.
;
; KEYWORD PARAMETERS:
;     GOES: If set, then a GOES curve is over-plotted. (Not used in
;           final paper.)
;     NO_INTERP: Two of the data columns are missing in the data and they
;                are interpolated to make the displayed image look prettier.
;                Setting this keyword restores the missing columns.
;
; OUTPUTS:
;     Creates the image plot_eis_event_log.jpg in the working directory
;     and returns an IDL plot object
;
; MODIFICATION HISTORY:
;     Ver.1, 02-Feb-2023, Peter Young
;-



IF n_tags(wd) EQ 0 THEN BEGIN
  file=eis_find_file('2-apr-2022 13:30',/lev,count=count)
  IF count EQ 0 THEN BEGIN
    message,/cont,/info,'Please download the EIS file 20220402_130542 and calibrate it to level-1 before using this routine. Returning...'
    return,-1
  ENDIF 
  wd=eis_getwindata(file,256.32,/refill)
ENDIF 

xy=eis_aia_offsets('2-apr-2022 13:30')




lref=256.32+v2lamb(-100,256.32)

getmin=min(abs(wd.wvl-lref),imin)

int1=average(wd.int[imin-3:imin+3,*,*],1,missing=wd.missing)

t1_jd=tim2jd(wd.time_ccsds)
xax=image_fix_axis(t1_jd)

;
; Includes offset derived from coaligning with AIA.
;
yax=wd.solar_y+xy[1]+15.0

;
; Do interpolation for missing data
;
IF ~ keyword_set(no_interp) THEN BEGIN 
  int1[15,*]=average(int1[[14,16],*],1,missing=wd.missing)
  int1[72,*]=average(int1[[71,73],*],1,missing=wd.missing)
ENDIF 
  
;
; Take square root and invert image.
;
print,minmax(int1)
int1=sqrt(int1>1000<50000)
int1=max(int1)-int1

th=2
fs=12
xtl=0.018
ytl=0.012

ix0=5
ix1=109
iy0=0
iy1=139
int1=int1[ix0:ix1,iy0:iy1]
xax=xax[ix0:ix1]
yax=yax[iy0:iy1]

xdim=580
ydim=400
w=window(dim=[xdim,ydim])


p=image(int1,xax,yax,rgb_table=aia_rgb_table(304),axis_style=2, $
        pos=[0.12,0.12,0.98,0.98], $
        xtickunits='time',XTICKFORMAT='(C(CHI2.2,":",CMI2.2))', $
        ytitle='solar-y / arcsec', $
        xtitle='time [ 2-Apr-2022 hh:mm ]', $
        xticklen=xtl,yticklen=ytl, $
        font_size=fs,xth=th,yth=th,/current, $
        ymin=1)
p.scale,10000,1

pt=text(0.15,0.90,'EIS: He II !9l!3256.32 (blue wing)',font_size=fs,color='black',target=p)

IF keyword_set(goes) THEN BEGIN 
;
; get GOES data
;
  IF n_tags(gdata) EQ 0 THEN BEGIN 
    g=ogoes()
    g->set,tstart='2-apr-2022 13:00',tend='2-apr-2022 14:00',mode=1
    gdata=g->getdata(/struct)
    low=g->getdata(/low)
    high=g->getdata(/high)
    times=g->getdata(/times)
    deri=deriv(times,high)
    obj_destroy,g
  ENDIF 

  yr=p.yrange
  y1=0.8*yr[1]+0.2*yr[0]
  y0=0.8*yr[0]+0.2*yr[1]
  y=alog10(low)
  y=y-min(y)
  y=y/max(y)*(y1-y0) + y0

  t_goes_tai=anytim2tai(gdata.utbase)+gdata.tarray
  t_goes_ccsds=anytim2utc(t_goes_tai,/ccsds)
  print,t_goes_ccsds[0]
  t_goes_jd=tim2jd(t_goes_ccsds)

  q=plot(/overplot,t_goes_jd,y,th=2,color='dodger blue',xrange=p.xrange, $
         xtickunits='time')
  q2=plot(/overplot,p.xrange,[y1,y1],color='dodger blue',linesty=':',th=th)
  q3=plot(/overplot,p.xrange,[y0,y0],color='dodger blue',linesty=':',th=th)
ENDIF


acol='green'

tt='2-Apr-2022 '+['13:09','13:20']
tt_jd=tim2jd(tt)
a1=arrow(tt_jd,210*[1,1],th=th,color=acol,/data,arrow_sty=3)
pa1_1=plot(/overplot,tt_jd[0]*[1,1],[205,260],color=acol,linesty=':',th=th)
pa1_2=plot(/overplot,tt_jd[1]*[1,1],[205,260],color=acol,linesty=':',th=th)
tt='2-Apr-2022 13:10'
tt_jd=tim2jd(tt)
t1=text(/data,tt_jd,213,'(1)',font_size=fs,color=acol)


tt='2-Apr-2022 '+['13:29','13:32:30']
tt_jd=tim2jd(tt)
a2=arrow(tt_jd,218*[1,1],th=th,color=acol,/data,arrow_sty=3)
t2=text(align=0.5,/data,mean(tt_jd),210,'(5)',font_size=fs,color=acol)
pa2_1=plot(/overplot,tt_jd[0]*[1,1],[213,300],color=acol,linesty=':',th=th)
pa2_2=plot(/overplot,tt_jd[1]*[1,1],[213,300],color=acol,linesty=':',th=th)

tt='2-Apr-2022 '+['13:25','13:27']
tt_jd=tim2jd(tt)
a3=arrow(tt_jd,[308,330],th=th,color=acol,/data,arrow_sty=2)
t3=text(align=0,/data,tt_jd[1],330,'(4)',font_size=fs,color=acol)

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



w.save,'plot_eis_event_log.jpg',width=2*xdim

return,w

END

