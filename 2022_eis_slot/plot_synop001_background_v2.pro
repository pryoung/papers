
FUNCTION plot_synop001_background_v2


;
; Here I use the 9-May 18:05 SYNOP001 dataset to investigate the
; effect of choosing the background from different pixels.
;
; Using eis_fit_slot_exposure, I get a centroid at Ypix=215 is
; 195.1521. 
;
; ** This version uses a modified background subtraction, as described
; ** in Sect. 4.4 of the paper. I've also switched to a
; different dataset due to a background anomaly for the 00:02
; dataset. 




;---------
file=eis_find_file('16-may-2007 10:46',/lev)
wd=eis_getwindata(file,195.12)


;
; Get 48-pixel window.
;
i0=1326-50-1024
wvl48=wd.wvl[i0:i0+47]
int48=reform(wd.int[i0:i0+47,0,*,0])

bg48=reform(int48[0,*])

;
; Get 64-pixel window
;
i0=1326-50-1024-8
wvl64=wd.wvl[i0:i0+63]
int64=reform(wd.int[i0:i0+63,0,*,0])


ypix=findgen(256)
cen=ypix*(-0.1127e-3)
cen_ref=195.20-0.0223
cen=cen_ref+cen-cen[0]

bgpix=intarr(256)
bg64=fltarr(256)
int_avg=fltarr(256)
int_edge=fltarr(256)
FOR i=0,255 DO BEGIN
   getmin=min(abs(wvl64-cen[i]),imin)
   bgpix[i]=imin-30
   bg64[i]=average(int64[bgpix[i]-2:bgpix[i]+2,i])
  ;
   int_avg[i]=average(int64[imin-20:imin+20,i])
   int_edge[i]=average(int64[imin-20:imin-17,i])
 ENDFOR

restore,'slit_slot_intensities/20070516_1046_data.save'
bg64=bg
scl=eis_slot_calib_factor(wavel=195.12,exptime=30.)
bg64=bg64/scl


diff=(bg48-bg64)/bg64*100.

print,format='(" Standard deviation of differences (16-May): ",f6.2,"%")',stdev(diff)



chck=strpos(wd.hdr.calstat,'ABS')
IF chck LT 0 THEN BEGIN
  print,'** The level-1 file is still in DN units - applying calibration factor **'
  calib_factor=eis_slot_calib_factor(wavelength=195.12,exptime=30.0)
  bg48=bg48*calib_factor
  bg64=bg64*calib_factor
  int_avg=int_avg*calib_factor
  int_edge=int_edge*calib_factor
ENDIF


ypix=wd.hdr.yws+findgen(256)


th=2
fs=12

;--------
; Right panel
;
p=plot(ypix,bg48,symbol='o',color='red', $
       sym_thick=th,xth=th,yth=th,/xsty, $
       dim=[850,400],pos=[0.37,0.12,0.99,0.98],linesty='none', $
       xticklen=0.018,yticklen=0.012, $
       ytit='Intensity / erg cm!u-2!n s!u-1!n sr!u-1!n', $
       xtit='y-pixel',font_size=fs, $
      ymin=1)
q=plot(/overplot,ypix,bg64,symbol='x',color='blue',sym_thick=th, $
      linesty='none')
pt=text(/data,415,73,'(b)',font_size=fs+2,target=p)

r=plot(/overplot,ypix,int_avg/10.,th=th)
r2=plot(/overplot,ypix,(int_avg-bg64)/10.,th=th,linestyle='--')

;--------
; Left panel
;
x=findgen(64)
s=image(sqrt(int64),x,ypix,axis_style=2,pos=[0.08,0.12,0.29,0.98], $
        xth=th,yth=th,rgb_table=aia_rgb_table(193),/current, $
        font_size=fs, $
        xmin=0,xticklen=0.015,yticklen=0.03,xtickdir=1,ytickdir=1, $
        xtitle='x-pixel', $
        ytitle='y-pixel')
s.scale,2,1
s1=plot(8*[1,1],s.yrange,color='red',th=th,/overplot)
st=text(/data,3,640,'(a)',font_size=fs+2,target=s,color='white')


p.save,'plot_synop001_background.png',resolution=192


return,p

END

