
FUNCTION plot_slit_tilts_v3

;+
; PRY, 16-Feb-2022
;
; This creates the figure plot_slit_tilts_v3.png for the EIS slot
; paper. It uses data that are created by the routine
; fit_9may07_dataset.pro. 
;-

;
; Get the May 9 fit data (both slot and slit).
;
restore,'fit_9may07_dataset.save'


;
; dw is the difference in wavelength between the slot centroid and the
; slit centroid for pixel 10. Note that I have to re-apply the
; wavelength offset to the eis_auto_fit centroid (for the slit), which
; recovers the original detector wavelength.
;
; Pixel 10 corresponds to y-pixels 205-224 in the original, unbinned
; dataset. 
;
dw=data.slot_cen[10] - ( reform(fit.aa[1,0,10]) + reform(fit.offset[0,10]) )
dw=dw[0]

;
; Set the reference pixel in the detector frame by adding the yip
; value. 
;
iy=data.yip+215



;
; Now get the narrow slit tilt parameters, and make dw_slit be zero at
; the reference location [iy].
; 
dw_slit=eis_slit_tilt(0,1024,/short,locations=y,info=info,date='9-may-2007')
dw_slit=dw_slit-dw_slit[iy]


;
; Here I set the slot tilt, which is linear in this case. I then set
; dw_slot[iy] to be dw, the different in slot and slit centroids at
; the reference point. 
;
dw_slot=-0.1127e-3*y 
dw_slot=dw_slot-dw_slot[iy]+dw


th=2
fs=12

xdim=1000
ydim=500
w=window(dim=[xdim,ydim])


x0=0.02
x1=0.98
dx=(x1-x0)/2.
ddx=0.06
y0=0.10
y1=0.89

p=plot(dw_slit,y,/xsty,/ysty,th=th,xra=[-0.03,0.09], $
       xtitle='Wavelength / '+string(197b), $
       font_size=fs,xticklen=1,yticklen=1, $
       xgridstyle=':',ygridstyle=':', $
       xminor=0,yminor=0, $
       xth=th,yth=th, $
       dim=[500,420], $
       pos=[x0+ddx,y0,x0+dx,y1], $
       ytit='Detector y-pixel',/current)

p2=plot(/overplot,dw_slot,y,color='blue',th=th)

getmin=min(abs(dw_slit-dw_slot),imin)
print,format='("The curves cross at Y-pixel =",i4)',y[imin]


p1=plot(/overplot,p.xrange,336*[1,1],color='red',th=2)
p2=plot(/overplot,p.xrange,847*[1,1],color='red',th=2)


ax=p.axes
ax[2].hide=1


scale_factor=1./data.pix_size

b=axis(0,location='top',coord_transform=[0,scale_factor], tickdir=0, $
       ticklen=0.015, th=th, $
       title='Detector x-pixel',tickfont_size=fs)

pt=text(/data,0.085,930,'(a) before 24-Aug-2008',align=1.0,font_size=fs)


;=================================================
;
; The Gauss fit to the slit data is in fit_195_20210920_1314.save (x4 binning
; has been applied). The WVL array in this file is the wavelength
; array from windata.
; I consider y-pixels 48 to 52
;
restore,'fit_195_20210920_1314.save'
cen=reform(fitx.aa[1,4,48:52])+reform(fitx.offset[4,48:52])

;
; This is measured centroid at Ypix=50
;
cen50=mean(cen)


;
; Now get mean pixel centroid for slot data
;
restore,'fit_pos_1080.save'
cen=s2.slot_cen[48:52]
cen50_slot=mean(cen)

;
; Have difference in wavelength at reference pixel [dw]
;
dw=cen50_slot-cen50

;
; Set the reference pixel on the detector
;
iy=50*4+s2.yip

;
; Get slit tilt and set to zero at reference pixel.
;
dw_slit=eis_slit_tilt(0,1024,/short,locations=y,info=info,date='20-sep-2021')
dw_slit=dw_slit-dw_slit[iy]

;
; Get slot tilt and set to dw at reference pixel.
;
dw_slot=y*(-7.260e-5)+y^2*(-2.316e-8)
dw_slot=dw_slot-dw_slot[iy]+dw



th=2
fs=12

q=plot(dw_slit,y,/xsty,/ysty,th=th,xra=[-0.04,0.07], $
       xtitle='Wavelength / '+string(197b), $
       font_size=fs,xticklen=1,yticklen=1, $
       xgridstyle=':',ygridstyle=':', $
       xminor=0,yminor=0, $
       xth=th,yth=th, $
       dim=[500,420], $
       pos=[x0+dx+ddx,y0,x0+2*dx,y1], $
       /current)

q2=plot(/overplot,dw_slot,y,color='blue',th=th)

getmin=min(abs(dw_slit-dw_slot),imin)
print,format='("The curves cross at Y-pixel =",i4)',y[imin]


r1=plot(/overplot,q.xrange,336*[1,1],color='red',th=2)
r2=plot(/overplot,q.xrange,847*[1,1],color='red',th=2)

ax=q.axes
ax[2].hide=1


scale_factor=1./s2.pix_size

c=axis(0,location='top',coord_transform=[0,scale_factor], tickdir=0, $
       ticklen=0.015, th=th, $
       title='Detector x-pixel',tickfont_size=fs,target=q)

qt=text(/data,0.064,930,'(b) after 24-Aug-2008',align=1.0,font_size=fs, $
       target=q)


w.save,'plot_slit_tilts_v3.png',width=xdim


return,w


END
