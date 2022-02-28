

FUNCTION plot_1050_data, xpos, output=output

;+
;   Produces the 4-panel Figure 4 for the EIS slot paper.
;-


IF n_elements(xpos) EQ 0 THEN xpos=1080

IF xpos EQ 1080 THEN outfile='plot_1080_fits.png'

xstr=trim(xpos)

file='fit_pos_'+xstr+'.save'
chck=file_search(file,count=count)
IF count EQ 0 THEN BEGIN
  print,'The file '+file+' was not found. Returning...'
  return,-1
ENDIF
print,'** Using file '+file+' **'
restore,file

ypix=[s1.ypix,s2.ypix]

wid=[s1.slot_wid,s2.slot_wid]/s1.pix_size
widerr=[s1.slot_wid_err,s2.slot_wid_err]/s1.pix_size

gwid=[s1.slot_gwid,s2.slot_gwid]
gwiderr=[s1.slot_gwid_err,s2.slot_gwid_err]

cen=[s1.slot_cen,s2.slot_cen]-195.0
cenerr=[s1.slot_cen_err,s2.slot_cen_err]

int=[s1.int_avg,s2.int_avg]


x0=-0.01
x1=0.98
dx=(x1-x0)/2.
ddx=0.09
;
y0=0.02
y1=0.98
dy=(y1-y0)/2.
ddy=0.05

th=2
fs=12
xtl=0.020
ytl=0.020
symth=1.0
symsz=0.7

xdim=1000
ydim=800
w=window(dim=[xdim,ydim])

;----------
; Intensity
;
p=plot(ypix,int>0,/xsty,symbol='+', $
       pos=[x0+ddx,y0+dy+ddy,x0+dx,y1],/current,linesty='none', $
       xth=th,yth=th,font_size=fs, $
       sym_size=symsz,sym_thick=symth,xticklen=xtl,yticklen=ytl, $
       ytitle='Intensity  [ erg cm!u-2!n s!u-1!n sr!u-1!n ]')
pl=text(x0+ddx+0.02,y0+dy+ddy+0.03,'(a)',font_size=fs+2)

;----------
; Centroid
;
q=plot(ypix,cen,/ysty,/xsty,symbol='+', $
       pos=[x0+dx+ddx,y0+dy+ddy,x0+2*dx,y1],/current,linesty='none', $
       xth=th,yth=th,font_size=fs, $
       sym_size=symsz,sym_thick=symth,xticklen=xtl,yticklen=ytl, $
       ytitle='(Slot centroid - 195)  [ '+string(197b)+' ]')
ql=text(x0+dx+ddx+0.02,y0+dy+ddy+0.03,'(b)',font_size=fs+2)
;
k=where(cen NE s1.missing)
x=ypix[k]
y=cen[k]
e=cenerr[k]
rcen=poly_fit(x,y,2,measure_errors=e,yfit=yfit,sigma=rcen_err)
yra=[floor(min(yfit)*100.)/100.,ceil(max(yfit)*100.)/100.]
q.yrange=yra
;
q2=plot(/overplot,x,yfit,th=th,color='blue')

;----------
; Slot width
;
r=plot(ypix,wid,yra=[40,42],/ysty,/xsty,symbol='+', $
       pos=[x0+ddx,y0+ddy,x0+dx,y0+dy],/current,linesty='none', $
       xth=th,yth=th,font_size=fs, $
       sym_size=symsz,sym_thick=symth,xticklen=xtl,yticklen=ytl, $
       ytitle='Slot width  [ pixels ]')
rl=text(x0+ddx+0.02,y0+ddy+0.03,'(c)',font_size=fs+2)
;
k=where(wid NE s1.missing)
x=ypix[k]
y=wid[k]
e=widerr[k]
rwid=poly_fit(x,y,1,measure_errors=e,yfit=yfit,sigma=rwid_err)
r2=plot(/overplot,x,yfit,th=2,color='blue')


;-----------
; LSF FWHM
;  - note I'm scaling from Gauss-width to FWHM
;
scl=2.*sqrt(2.*alog(2.))/s2.pix_size
s=plot(ypix,gwid*scl,yra=[2,4.5],/ysty,/xsty,symbol='+', $
       pos=[x0+dx+ddx,y0+ddy,x0+2*dx,y0+dy],/current,linesty='none', $
       xth=th,yth=th,font_size=fs, $
       sym_size=symsz,sym_thick=symth,xticklen=xtl,yticklen=ytl, $
       ymin=1, $
       ytitle='LSF FWHM  [ arcsec ]')
sl=text(x0+dx+ddx+0.02,y0+ddy+0.03,'(d)',font_size=fs+2)
;
k=where(gwid NE s1.missing)
x=ypix[k]
y=gwid[k]*scl
e=gwiderr[k]*scl
rgwid=poly_fit(x,y,2,measure_errors=e,yfit=yfit,sigma=rgwid_err)
s2=plot(/overplot,x,yfit,th=2,color='blue')


getmin=min(yfit,imin)
print,format='("Best spatial res ",f5.2," at pixel ",i3)',getmin,imin*s1.ybin
print,format='("Worst spatial res ",f5.2)',max(yfit)
print,format='("Spatial res at ypix=592 ",f5.2)',rgwid[0]+rgwid[1]*592.+rgwid[2]*592.^2

xt=text(x0+ddx+(2*dx-ddx)/2.,0.01,'y-pixel',font_size=fs+1,align=0.5)

;
; For some reason wid, cen, etc are returned as arrays (1,4), so I
; have to use a reform.
;
output={ wid_params: reform(rwid), $
         wid_sigma: rwid_err, $
         gwid_params: reform(rgwid), $
         gwid_sigma: rgwid_err, $
         cen_params: reform(rcen), $
         cen_sigma: rcen_err, $
         pix_size: s1.pix_size}


;
; This writes the png file to the slot paper directory.
;
IF n_elements(outfile) NE 0 THEN BEGIN
  w.save,outfile,xdim=xdim
  print,'Written graphic to '+outfile
ENDIF 

return,w

END
