

FUNCTION plot_aia_venus_ints, data, no_psf=no_psf, quadratic=quadratic, $
                              deconv_data=deconv_data

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
;     Data:  A structure in the form returned by aia_get_venus.pro.
;
; OPTIONAL INPUTS:
;     Deconv_Data:  A structure in the form returned by aia_get_venus.pro
;                   but for deconvolved AIA data.
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
; EXAMPLE:
;     IDL> w=plot_aia_venus_ints(data)
;     IDL> w=plot_aia_venus_ints(data, deconv_data=deconv_data)
;     IDL> w=plot_aia_venus_ints(data,/no_psf)
;     IDL> w=plot_aia_venus_ints(data,/quadratic)
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
;     Ver.6, 07-Feb-2024, Peter Young
;       Added DATA input (to replace save file previously used), and
;       DECONV_DATA= optional input; modified how xrange and yrange are
;       computed.
;-

;
; If DATA has not been input, then check if save file exists (this was
; the old way of running routine).
; 
IF n_tags(data) EQ 0 THEN BEGIN
  chck=file_info('aia_venus_results.save')
  IF chck.exists EQ 0 THEN message,'DATA was not input and the file aia_venus_results.save does not exist. Returning...',/info,/cont
  restore,'aia_venus_results.save'
  data=d050x_err
ENDIF 

IF n_tags(deconv_data) EQ 0 THEN BEGIN
  chck=file_info('aia_venus_results_deconvolved.save')
  IF chck.exists EQ 1 THEN BEGIN
    restore,'aia_venus_results_deconvolved.save'
    deconv_data=dd
  ENDIF 
ENDIF 

;restore,'aia_venus_results.save'
;restore,'aia_venus_results_deconvolved.save'
;dd=ddx

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

n=n_elements(data)
swtch=bytarr(n)
t_tai=anytim2tai(data.time)
t_min=round((t_tai-t_tai[0])/60.)
chck=t_min MOD 20
k=where(chck NE 0)
swtch[k]=1b

yrange=[0,max(data.int)*1.1]

i_in_0=where(data.r LT 960. AND swtch EQ 0)
i_in_1=where(data.r LT 960. AND swtch EQ 1)
i_in=where(data.r LT 960.)
i_out=where(data.r GE 960.)
i_out_0=where(data.r GE 960. AND swtch EQ 0)
i_out_1=where(data.r GE 960. AND swtch EQ 1)

p=plot(/current,data[i_in_0].x,data[i_in_0].int,symbol='+', $
       _extra=extra, $
       xtitle='solar-x [ arcsec ]', $
       ytitle='$D_{\rm V}$ [ DN s!u-1!n pix!u-1!n ]', $
       pos=[x0+ddx,y0,x0+dx,y1],linestyle='none', $
       xrange=[-1300,1300],/xsty, $
       yrange=yrange)
p3=plot(/current,/overplot,data[i_in_1].x,data[i_in_1].int,symbol='x', $
        _extra=extra,linestyle='none')
p1=plot(/current,/overplot,data[i_out_0].x,data[i_out_0].int,symbol='o', $
        _extra=extra,linestyle='none')
p4=plot(/current,/overplot,data[i_out_1].x,data[i_out_1].int,symbol='o', $
        _extra=extra,sym_filled=1,linestyle='none')
p2=plot(/overplot,data.x,data.int,_extra=extra)
tp=text(/data,-1150,54,'(a)',font_size=fs+2)

;
; Overplot deconvolved data.
;
IF NOT keyword_set(no_psf) AND n_tags(deconv_data) NE 0 THEN BEGIN 
  i_in=where(deconv_data.r LT 960.)
  i_out=where(deconv_data.r GE 960.)
 ;
  d=plot(/overplot,deconv_data.x,deconv_data.int,color=color_toi('cyan',/vibrant), $
         _extra=extra)
ENDIF 
  
;-----------------------------
i_in_0=where(data.r LT 960. AND swtch EQ 0)
i_in_1=where(data.r LT 960. AND swtch EQ 1)
i_in=where(data.r LT 960.)
i_out=where(data.r GE 960.)
i_out_0=where(data.r GE 960. AND swtch EQ 0)
i_out_1=where(data.r GE 960. AND swtch EQ 1)

q=errorplot(/current,data[i_in_0].sub_map_int, $
            data[i_in_0].int,data[i_in_0].int_stdev, $
            symbol='+',xsty=1, $
            yrange=yrange, $
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
q2=plot(/current,/overplot,data[i_in_1].sub_map_int,data[i_in_1].int,symbol='x', $
        _extra=extra,linestyle='none')
q1=plot(/current,/overplot,data[i_out_0].sub_map_int,data[i_out_0].int,symbol='o', $
        _extra=extra,linestyle='none')
q4=plot(/current,/overplot,data[i_out_1].sub_map_int,data[i_out_1].int,symbol='o', $
        _extra=extra,linestyle='none',sym_filled=1)
;q2=plot(/overplot,data.sub_map_int,data.int,_extra=extra)
tq=text(/data,30,54,'(b)',font_size=fs+2,target=q)

;c=linfit(data[i_in].sub_map_int,data[i_in].int)
c=linfit(data[i_in].sub_map_int,data[i_in].int,meas=data[i_in].int_stdev, $
         sigma=sigma)
xmax=max(data.sub_map_int)*1.1
x=findgen(11)/10.*xmax
;x=findgen(11)*50.
q3=plot(/overplot,th=th+1,x,c[0]+c[1]*x,color=color_toi('cyan',/vibrant))

print,format='("Slope:   ",f10.4," +/-",f10.4)',c[1],sigma[1]
print,format='("I_ann=0: ",f8.2," +/-",f8.2)',c[0],sigma[0]

;
; This fits a quadratic to all of the data-points
;
IF keyword_set(quadratic) THEN BEGIN 
  c=poly_fit(data.sub_map_int,data.int,2)
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
  getmin=min(abs(v[i]-data.sub_map_int),imin)
  k=where(imin EQ imin_save,nk)
  IF nk EQ 0 THEN BEGIN
    x[i]=data[imin].sub_map_int
    y[i]=data[imin].int
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
