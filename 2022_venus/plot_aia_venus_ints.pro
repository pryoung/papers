

FUNCTION plot_aia_venus_ints, no_psf=no_psf, quadratic=quadratic

;+
; NAME:
;     PLOT_AIA_VENUS_INTS
;
; PURPOSE:
;     Creates an IDL plot object showing the variation of the AIA 193
;     Venus intensity during the transit (left panel), and a plot of
;     the Venus intensity vs. the annulus intensity (right
;     panel). Also outputs an eps version of the figure to the working
;     directory. 
;
; CATEGORY:
;     AIA; Venus transit; graphics.
;
; CALLING SEQUENCE:
;     Result = PLOT_AIA_VENUS_INTS( )
;
; INPUTS:
;     None.
;
; KEYWORD PARAMETERS:
;     NO_PSF:  If set, then the PSF-deconvolved intensity is not
;              plotted in the left panel.
;     QUADRATIC: If set, then a quadratic fit is performed for the
;                right panel, and the curve is over-plotted.
;
; OUTPUTS:
;     Creates an IDL plot object and also makes a copy of the object
;     to an eps file called 'plot_aia_venus_ints.eps'.
;
; RESTRICTIONS:
;     Requires the files 'aia_venus_results.save' and
;     'aia_venus_results_deconvolved.save' to be present in the
;     working directory.
;
; EXAMPLE:
;     IDL> w=plot_aia_venus_ints()
;     IDL> w=plot_aia_venus_ints(/no_psf)
;     IDL> w=plot_aia_venus_ints(/quadratic)
;
; MODIFICATION HISTORY:
;     Ver.1, 05-Oct-2020, Peter Young
;     Ver.2, 26-Apr-2022, Peter Young
;       Updated dimensions of output plot.
;     Ver.3, 29-Jun-2022, Peter Young
;       Added intensity uncertainties from d050x_err structure.
;     Ver.4 30-Jun-2022, Peter Young
;       Updated axis labels.
;     Ver.5, 27-Jul-2022, Peter Young
;       Another slight change to axis label.
;-


restore,'aia_venus_results.save'
restore,'aia_venus_results_deconvolved.save'
dd=ddx

xdim=1100
ydim=500
w=window(dim=[xdim,ydim],background_color=bgcolor)

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

n=n_elements(d050x)
swtch=bytarr(n)
t_tai=anytim2tai(d050x.time)
t_min=round((t_tai-t_tai[0])/60.)
chck=t_min MOD 20
k=where(chck NE 0)
swtch[k]=1b

i_in_0=where(d050x.r LT 960. AND swtch EQ 0)
i_in_1=where(d050x.r LT 960. AND swtch EQ 1)
i_in=where(d050x.r LT 960.)
i_out=where(d050x.r GE 960.)
i_out_0=where(d050x.r GE 960. AND swtch EQ 0)
i_out_1=where(d050x.r GE 960. AND swtch EQ 1)

p=plot(/current,d050x[i_in_0].x,d050x[i_in_0].int,symbol='+', $
       _extra=extra, $
       xtitle='solar-x [ arcsec ]', $
       ytitle='$D_{\rm V}$ [ DN s!u-1!n pix!u-1!n ]', $
       pos=[x0+ddx,y0,x0+dx,y1],linestyle='none', $
       xrange=[-1300,1300],/xsty, $
       yrange=[0,60])
p3=plot(/current,/overplot,d050x[i_in_1].x,d050x[i_in_1].int,symbol='x', $
        _extra=extra,linestyle='none')
p1=plot(/current,/overplot,d050x[i_out_0].x,d050x[i_out_0].int,symbol='o', $
        _extra=extra,linestyle='none')
p4=plot(/current,/overplot,d050x[i_out_1].x,d050x[i_out_1].int,symbol='o', $
        _extra=extra,sym_filled=1,linestyle='none')
p2=plot(/overplot,d050x.x,d050x.int,_extra=extra)
tp=text(/data,-1150,54,'(a)',font_size=fs+2)

;
; Overplot deconvolved data.
;
IF NOT keyword_set(no_psf) THEN BEGIN 
  i_in=where(dd.r LT 960.)
  i_out=where(dd.r GE 960.)
 ;
  d=plot(/overplot,dd.x,dd.int,color=color_toi('cyan',/vibrant), $
         _extra=extra)
ENDIF 
  
;-----------------------------
i_in_0=where(d050x.r LT 960. AND swtch EQ 0)
i_in_1=where(d050x.r LT 960. AND swtch EQ 1)
i_in=where(d050x.r LT 960.)
i_out=where(d050x.r GE 960.)
i_out_0=where(d050x.r GE 960. AND swtch EQ 0)
i_out_1=where(d050x.r GE 960. AND swtch EQ 1)

q=errorplot(/current,d050x[i_in_0].sub_map_int, $
            d050x[i_in_0].int,d050x_err[i_in_0].int_stdev, $
            symbol='+', $
            yrange=[0,60], $
            _extra=extra,linestyle='none', $
            pos=[x0+dx+ddx,y0,x0+2*dx,y1] , $
            xtitle='$D_{\rm ann}$ [ DN s!u-1!n pix!u-1!n ]', $
            ytitle='$D_{\rm V}$ [ DN s!u-1!n pix!u-1!n ]' , $
            xminor=4, errorbar_th=th)
;; q=plot(/current,d050x[i_in_0].sub_map_int,d050x[i_in_0].int,symbol='+', $
;;        yrange=[0,60], $
;;        _extra=extra,linestyle='none', $
;;        pos=[x0+dx+ddx,y0,x0+2*dx,y1] , $
;;        xtitle='$D_{\rm ann}$ / DN s!u-1!n pix!u-1!n', $
;;        ytitle='$D_{\rm V}$ / DN s!u-1!n pix!u-1!n' , $
;;        xminor=4)
q2=plot(/current,/overplot,d050x[i_in_1].sub_map_int,d050x[i_in_1].int,symbol='x', $
        _extra=extra,linestyle='none')
q1=plot(/current,/overplot,d050x[i_out_0].sub_map_int,d050x[i_out_0].int,symbol='o', $
        _extra=extra,linestyle='none')
q4=plot(/current,/overplot,d050x[i_out_1].sub_map_int,d050x[i_out_1].int,symbol='o', $
        _extra=extra,linestyle='none',sym_filled=1)
;q2=plot(/overplot,d050x.sub_map_int,d050x.int,_extra=extra)
tq=text(/data,30,54,'(b)',font_size=fs+2,target=q)

;c=linfit(d050x[i_in].sub_map_int,d050x[i_in].int)
c=linfit(d050x[i_in].sub_map_int,d050x[i_in].int,meas=d050x_err[i_in].int_stdev, $
         sigma=sigma)
x=findgen(11)*50.
q3=plot(/overplot,th=th+1,x,c[0]+c[1]*x,color=color_toi('cyan',/vibrant))

print,format='("Slope:   ",f10.4," +/-",f10.4)',c[1],sigma[1]
print,format='("I_ann=0: ",f8.2," +/-",f8.2)',c[0],sigma[0]

;
; This fits a quadratic to all of the data-points
;
IF keyword_set(quadratic) THEN BEGIN 
  c=poly_fit(d050x.sub_map_int,d050x.int,2)
  q4=plot(/overplot,th=th,x,c[0]+c[1]*x+c[2]*x^2,color=color_toi('magenta',/vibrant))
ENDIF 


p.save,'plot_aia_venus_ints.png',width=2.*xdim

;
; I've added the following because there is a cluster of points
; that are quite tightly spaced together. Below I choose a
; sample that's more evenly spaced (about every 25 in the
; X-direction) and then fit a line through it. The straight line fit
; is very similar to the above. I've commented out the plot part.
;
v=findgen(20)*25.+25.
x=fltarr(20)-100.
y=fltarr(20)-100.

imin_save=500
FOR i=0,19 DO BEGIN
  getmin=min(abs(v[i]-d050x.sub_map_int),imin)
  k=where(imin EQ imin_save,nk)
  IF nk EQ 0 THEN BEGIN
    x[i]=d050x[imin].sub_map_int
    y[i]=d050x[imin].int
  ENDIF 
  imin_save=[imin_save,imin]
END
k=where(y NE -100.)
x=x[k]
y=y[k]

;a=plot(x,y,symbol='+',_extra=extra)
c=linfit(x,y)
xx=findgen(11)*50.
;b=plot(/overplot,xx,c[0]+c[1]*xx,th=th,color=color_toi('cyan',/vibrant))
print,'Alternative linear fit:'
print,format='("  Slope:   ",f10.4)',c[1]
print,format='("  I_ann=0: ",f8.2)',c[0]

return,w

END
