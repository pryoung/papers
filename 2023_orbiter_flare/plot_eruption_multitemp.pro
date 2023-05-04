
FUNCTION plot_eruption_multitemp


;+
; NAME:
;     PLOT_ERUPTION_MULTITEMP
;
; PURPOSE:
;     Creates a figure for the Janvier et al. (2023, A&A) paper about
;     the 2-Apr-2022 filament eruption. The figure shows the EIS emission
;     from the eruption in four different emission lines.
;
; CATEGORY:
;     Journal figure.
;
; CALLING SEQUENCE:
;     Result = PLOT_ERUPTION_MULTITEMP( )
;
; INPUTS:
;     None.
;
; OUTPUTS:
;     Returns an IDL plot object containing the figure, and also creates
;     the file plot_eruption_multitemp.jpg in the working directory.
;
; RESTRICTIONS:
;     The level-1 EIS file with the ID 20220402_130542 needs to on the
;     user's computer.
;
; EXAMPLE:
;     IDL> w=plot_eruption_multitemp()
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
  wd284=eis_getwindata(file,284.16,/refill)
  wd195=eis_getwindata(file,195.12,/refill)
ENDIF 


;
; Specify the x-range for the plot.
;
ix0=45
ix1=74


yr=[250.1,297.6]+2

k1=where(wd256.solar_y GE yr[0] AND wd256.solar_y LE yr[1])
k2=where(wd195.solar_y GE yr[0] AND wd195.solar_y LE yr[1])
k3=where(wd284.solar_y GE yr[0] AND wd284.solar_y LE yr[1])

;
; Get y-axis for plots.
; 
xy=eis_aia_offsets(wd256.hdr.date_obs)
yax=wd256.solar_y[k1]+xy[1]+15.

vel=-200
;
lref=256.32+v2lamb(vel,256.32)
getmin=min(abs(wd256.wvl-lref),imin)
int1=average(wd256.int[imin-3:imin+3,ix0:ix1,k1],1,missing=wd256.missing)
;
lref=194.661
lref=lref+v2lamb(vel,lref)
getmin=min(abs(wd195.wvl-lref),imin)
int2=average(wd195.int[imin-3:imin+3,ix0:ix1,k2],1,missing=wd195.missing)
;
lref=195.119
lref=lref+v2lamb(vel,lref)
getmin=min(abs(wd195.wvl-lref),imin)
int3=average(wd195.int[imin-3:imin+3,ix0:ix1,k2],1,missing=wd195.missing)
;
lref=284.163
lref=lref+v2lamb(vel,lref)
getmin=min(abs(wd284.wvl-lref),imin)
int4=average(wd284.int[imin-3:imin+3,ix0:ix1,k3],1,missing=wd284.missing)



t1_jd=tim2jd(wd256.time_ccsds[ix0:ix1])
xax=image_fix_axis(t1_jd)


;
; Do interpolation for missing data
;
IF ~ keyword_set(no_interp) THEN BEGIN 
  int1[72-ix0,*]=average(int1[[71-ix0,73-ix0],*],1,missing=wd256.missing)
  int2[72-ix0,*]=average(int2[[71-ix0,73-ix0],*],1,missing=wd195.missing)
  int3[72-ix0,*]=average(int3[[71-ix0,73-ix0],*],1,missing=wd195.missing)
  int4[72-ix0,*]=average(int4[[71-ix0,73-ix0],*],1,missing=wd284.missing)
ENDIF 


xdim=1100
ydim=400
w=window(dim=[xdim,ydim])

x0=0.07
x1=0.99
dx=(x1-x0)/4.
ddx=0.00
y0=0.12
y1=0.98

xtl=0.02
ytl=0.015
fs=12
th=2


int1=sqrt(int1>1000<50000)


xscl=6270

;
; He II 256
; 
p=image(int1,xax,yax,axis_sty=2, rgb_table=3,  $
        pos=[x0+ddx,y0,x0+dx,y1],/current, $
        xtickunits='time',XTICKFORMAT='(C(CHI2.2,":",CMI2.2))', $
        ytitle='y / arcsec', $
        xticklen=xtl,yticklen=ytl, $
        xtickdir=1,ytickdir=1, $
        font_size=fs,xth=th,yth=th, $
        ymin=1)
p.scale,xscl,1
pt=text(/data,xax[1],yax[-3],'(a) He II 256.32 '+string(197b)+' (0.08 MK)', $
        font_size=fs,color='white',target=p)

;
; Fe VIII 194
;
int2=sqrt(int2>200<5000)
q=image(int2,xax,yax,axis_sty=2, rgb_table=3,  $
        pos=[x0+dx+ddx,y0,x0+2*dx,y1],/current, $
        xtickunits='time',XTICKFORMAT='(C(CHI2.2,":",CMI2.2))', $
        xticklen=xtl,yticklen=ytl, $
        xtickdir=1,ytickdir=1, $
        font_size=fs,xth=th,yth=th, $
        yshowtext=0, $
        ymin=1)
ax=q.axes
ax[1].color='white'
ax[1].ticklen=0
q.scale,xscl,1
qt=text(/data,xax[1],yax[-3],'(b) Fe VIII 194.66 '+string(197b)+' (0.45 MK)', $
        font_size=fs,color='white',target=q)

;
; Fe XII 195
;
int3=sqrt(int3>1800<20000)
r=image(int3,xax,yax,axis_sty=2, rgb_table=3,  $
        pos=[x0+2*dx+ddx,y0,x0+3*dx,y1],/current, $
        xtickunits='time',XTICKFORMAT='(C(CHI2.2,":",CMI2.2))', $
        xticklen=xtl,yticklen=ytl, $
        xtickdir=1,ytickdir=1, $
        font_size=fs,xth=th,yth=th, $
        yshowtext=0, $
        ymin=1)
ax=r.axes
ax[1].color='white'
ax[1].ticklen=0
r.scale,xscl,1
rt=text(/data,xax[1],yax[-3],'(c) Fe XII 195.12 '+string(197b)+' (1.6 MK)', $
        font_size=fs,color='white',target=r)


;
; Fe XV 284
;
int4=sqrt(int4>1000<15000)
s=image(int4,xax,yax,axis_sty=2, rgb_table=3,  $
        pos=[x0+3*dx+ddx,y0,x0+4*dx,y1],/current, $
        xtickunits='time',XTICKFORMAT='(C(CHI2.2,":",CMI2.2))', $
        xticklen=xtl,yticklen=ytl, $
        xtickdir=1,ytickdir=1, $
        font_size=fs,xth=th,yth=th, $
        yshowtext=0, $
        ymin=1)
ax=s.axes
ax[1].color='white'
ax[1].ticklen=0
s.scale,xscl,1
st=text(/data,xax[1],yax[-3],'(d) Fe XV 284.16 '+string(197b)+' (2.2 MK)', $
        font_size=fs,color='white',target=s)

xtxt=text(x0+2*dx,0.01,'time [ 2-Apr-2022 hh:mm ]',font_size=fs,align=0.5)


w.save,'plot_eruption_multitemp.jpg',width=2*xdim


return,w

END
