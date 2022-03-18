
FUNCTION plot_eis_venus_ints

;+
; NAME:
;     PLOT_EIS_VENUS_INTS
;
; PURPOSE:
;     Create plot for Venus transit paper showing variation of EIS
;     intensities during the transit.
;
; CATEGORY:
;     Hinode/EIS; Venus transit; plot.
;
; CALLING SEQUENCE:
;     Result = PLOT_EIS_VENUS_INTS()
;
; INPUTS:
;     None.
;
; OUTPUTS:
;     Creates an IDL plot object.
;
; MODIFICATION HISTORY:
;     Ver.1, 17-Aug-2021, Peter Young
;-



d=read_eis_venus_results()

r=sqrt(d.x^2 + d.y^2)

w=window(dim=[1100,500],background_color=bgcolor)

th=2
fs=14

x0=0.00
x1=0.98
dx=(x1-x0)/2.
ddx=0.08
y0=0.12
y1=0.98

extra={ thick: th, $
        xthick: th, $
        ythick: th, $
        xticklen: 0.015, yticklen: 0.015, $
        sym_size: 2, sym_thick: th,$
        font_size: fs, $
        yminor: 4}

ann_frac_lim=0.75

i_in=where(r LT 960.)
i_out=where(r GE 960.)

i_cross=where(r LT 960. AND d.ann_frac GE ann_frac_lim)
i_tri=where(r LT 960. AND d.ann_frac LT ann_frac_lim)
i_circle=where(r GE 960.)

p=plot(/current,d[i_cross].x,d[i_cross].int_venus,symbol='+', $
       _extra=extra, $
       xtitle='Solar-X / arcsec', $
       ytitle='$I_{\rm V}$ / erg cm!u-1!n s!u-1!n sr!u-1!n', $
       pos=[x0+ddx,y0,x0+dx,y1],linestyle='none', $
       xrange=[-1300,1300],/xsty, $
       yrange=[0,70])
p1=plot(/current,/overplot,d[i_circle].x,d[i_circle].int_venus,symbol='o', $
        _extra=extra,linestyle='none')
p3=plot(/current,/overplot,d[i_tri].x,d[i_tri].int_venus,symbol='triangle', $
        _extra=extra,linestyle='none')
p2=plot(/overplot,d.x,d.int_venus,_extra=extra)
xr=p.xrange
yr=p.yrange
xp=0.95*xr[0]+0.05*xr[1]
yp=0.10*yr[0]+0.90*yr[1]
tp=text(/data,xp,yp,'(a)',font_size=fs+2)



;-----------------------------------------
;
i_cross=where(r LT 960. AND d.ann_frac GE ann_frac_lim)
i_tri=where(r LT 960. AND d.ann_frac LT ann_frac_lim)
i_circle=where(r GE 960.)

q=plot(/current,pos=[x0+dx+ddx,y0,x0+2*dx,y1], $
       d[i_cross].int_ann,d[i_cross].int_venus,symbol='+', $
       _extra=extra, $
       xtitle='$I_{\rm ann}$ / erg cm!u-1!n s!u-1!n sr!u-1!n', $
       ytitle='$I_{\rm V}$ / erg cm!u-1!n s!u-1!n sr!u-1!n', $
       linestyle='none', $
       xrange=[0,450],yra=[0,70],xmin=4)

q1=plot(/overplot,abs(d[i_tri].int_ann),d[i_tri].int_venus, $
        symbol='triangle',_extra=extra,linestyle='none')

q3=plot(/overplot,abs(d[i_circle].int_ann),d[i_circle].int_venus, $
        symbol='o',_extra=extra,linestyle='none')


;c=linfit(abs(d[i_in].int_ann),d[i_in].int_venus)
c=linfit(abs(d[i_cross].int_ann),d[i_cross].int_venus,yfit=yfit)
x=findgen(61)*10.
q2=plot(/overplot,_extra=extra,x,c[0]+c[1]*x, $
        color=color_toi(/vibrant,'blue'))

print,'EIS linear fit parameters: '
print,format='("      c[0] = ",f6.2)',c[0]
print,format='("      c[1] = ",f8.4)',c[1]

;
; Check differences between fit and Venus intensities
;
diff=yfit-d[i_cross].int_venus
perc_diff=diff/d[i_cross].int_venus*100.
print,format='("Max difference (fit - Venus_int): ",f4.1,"%")',max(abs(perc_diff))
print,format='("Standard deviation (fit - Venus_int): ",f4.1,"%")',stdev(perc_diff)
;
; I set the c[0] value for the AIA line to be the same as EIS.
;
q3=plot(/overplot,_extra=extra,x,c[0]+0.1014*x, $
        color=color_toi(/vibrant,'magenta'),linestyle='--')

xr=q.xrange
yr=q.yrange
xp=0.95*xr[0]+0.05*xr[1]
yp=0.10*yr[0]+0.90*yr[1]
tp=text(/data,xp,yp,'(b)',font_size=fs+2,target=q)


w.save,'plot_eis_venus_ints.png',resolution=192

return,w

END
