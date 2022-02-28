



FUNCTION plot_20sep_fit, data, ypix, _extra=extra

;+
;   This is a two-panel plot showing an image from the X=1080 pointing
;   of the 20-Sep-2021 observation and an intensity slice (with fit)
;   at one y-pixel. It is Figure 3 in the slot paper.
;
;   DATA and YPIX are optional outputs.
;-

restore,'fit_pos_1080.save'

iy=19


img=s2.int

int=s2.int[*,iy]
err=s2.err[*,iy]
wvl=s2.wvl
pix_size=s2.pix_size

ypix=indgen(n_elements(s2.ypix))

y=s2.outfit[*,iy]

aa=s2.aa[*,iy]
sigmaa=s2.sigmaa[*,iy]

bg=aa[6]

th=2
fs=12

xdim=800
ydim=450
w=window(dim=[xdim,ydim])


x0=0.08
x1=0.30
x2=0.39
x3=0.98
y0=0.12
y1=0.98


nx=n_elements(wvl)
xax=findgen(nx)

wvlax=image_fix_axis(wvl)
p=image(img,wvlax,ypix,axis_style=2,rgb_table=aia_rgb_table(193),/current, $
        pos=[x0,y0,x1,y1], $
        th=th,yth=th,xth=th,font_size=fs, $
;        xtext_orientation=40, $
        xmin=0,xtickdir=1,ytickdir=1,ymin=1, $
        xmajor=3, xtickvalues=[194.50,195.00,195.50], $
        xticklen=0.015,yticklen=0.025, $
        xtit='Wavelength / '+string(197b), $
        ytitle='y-pixel')
p.scale,[3/4./s2.pix_size,1]
pl=plot(/overplot,p.xrange,ypix[iy]*[1,1],th=th,color='yellow')
pt=text(/data,194.5,115,'(a)',color='white',target=p,font_size=fs+2)

q=plot(wvl,int,/stairstep,/xsty, $
       th=th,yth=th,xth=th,font_size=fs, $
       xtit='Wavelength / '+string(197b), $
       ytit='Intensity / erg cm!u-2!n s!u-1!n sr!u-1!n',_extra=extra, $
       xticklen=0.015,yticklen=0.015, $
       pos=[x2,y0,x3,y1], $
       dim=[600,400],/current)
qt=text(/data,194.45,180,'(b)',target=q,font_size=fs+2)

yr=q.yrange

qt=text(p.xrange[0]+0.05,0.8*yr[1]+0.2*yr[0],'Ypix='+trim(iy), $
        font_size=fs,/data)

ql=plot(wvl,y,color='blue',th=th,/overplot)

qb=plot(q.xrange,bg*[1,1],th=th,color='red',/overplot)

s1=plot(aa[3]*[1,1],q.yrange,th=th,linestyle='--',/overplot)
s2=plot((aa[4]+aa[3])*[1,1],q.yrange,th=th,linestyle='--',/overplot)

wvl_pix=wvl[1]-wvl[0]

widstr='Slot width: '+string(format='(f6.3)',aa[4]/pix_size)+'$\pm$'+trim(string(format='(f6.3)',sigmaa[4]/pix_size))+' pix'
qt1=text(194.8,60,widstr,font_size=fs,target=q,/data)
;
scl=2.*sqrt(2.*alog(2.))*1000.
fwhmstr='LSF FWHM: '+trim(string(format='(f6.1)',aa[5]*scl))+'$\pm$'+trim(string(format='(f5.1)',sigmaa[5]*scl))+' m'+string(197b)
qt2=text(194.8,45,fwhmstr,font_size=fs,target=q,/data)

print,format='("Quadratic params: ",3e10.2)',aa[0:2]
print,format='("Boundary edge: ",f10.3," +-",f8.3)',aa[3],sigmaa[3]
wid=aa[4]
sigwid=sigmaa[4]
print,format='("Slot width (Ang): ",f10.3," +-",f8.3)',wid,sigwid
print,format='("Pixel width (Ang): ",f10.5)',wvl_pix
print,format='("Slot width (pix): ",f10.3," +-",f8.3)',wid/wvl_pix,sigwid/wvl_pix
print,format='("LSF FWHM (mA): ",f8.2)',aa[5]*2*sqrt(2.)*sqrt(alog(2.))*1000.
print,format='("LSF FWHM (arcsec): ",f6.2)',aa[5]*2*sqrt(2.)*sqrt(alog(2.))/wvl_pix

p.save,'plot_20sep_fit.png',xdim=xdim

return,p


END
