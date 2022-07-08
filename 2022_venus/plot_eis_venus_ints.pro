
FUNCTION plot_eis_venus_ints, file, wvl, dv_max=dv_max, dann_max=dann_max

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
; INPUTS:
;     File:  The data file containing the results. If not specified,
;            then the file 'eis_venus_new_results.txt' will be used.
;     Wvl:   Wavelength of the line that's being plotted.     
;
; OPTIONAL INPUTS:
;     Dv_Max:  For plot ranges, this sets the maximum value for D_V.
;              Default is 70.
;     Dann_Max:  For plot ranges, this sets the maximum value for D_V.
;                Default is 450.
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
;     Ver.2, 31-May-2022, Peter Young
;        Added file= optional input; modified dimensions of output
;        plot; added dv_max= and dann_max= optional inputs.
;     Ver.3, 12-Jun-2022, Peter Young
;        Added WVL as input and FILE is now required; now plots error
;        bars on panel (b).
;     Ver.4, 15-Jun-2022, Peter Young
;        For wavelengths other than 195, the routine now overplots the
;        195 fit as a blue dashed line.
;     Ver.5, 29-Jun-2022, Peter Young
;        Updated gradient of AIA line.
;     Ver.6, 30-Jun-2022, Peter Young
;        Updated axis labels.
;     Ver.7, 08-Jul-2022, Peter Young
;        Fixed bug when making png file.
;-


IF n_params() LT 2 THEN BEGIN
  print,'Use:  IDL> w=plot_eis_venus_ints( file, wvl [, dv_max=, dann_max= ] )'
  return,-1
ENDIF 


d=read_eis_venus_results(file,wvl)

IF n_tags(d) EQ 0 THEN BEGIN
  message,/cont,/info,'Problem with the data file. Returning...'
  return,-1
ENDIF

wvls=[195.12,274.20]
getmin=min(abs(wvls-wvl),imin)
IF getmin LE 1.0 THEN BEGIN
  CASE imin OF
    1: BEGIN
      dv_max=30.
      dann_max=130.
    END 
    ELSE: BEGIN
      dv_max=70.
      dann_max=450.
    END
  ENDCASE
ENDIF 
      

IF n_elements(dv_max) EQ 0 THEN dv_max=70.
IF n_elements(dann_max) EQ 0 THEN dann_max=450.


r=sqrt(d.x^2 + d.y^2)

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

ann_frac_lim=0.75

i_in=where(r LT 960.)
i_out=where(r GE 960.)

i_cross=where(r LT 960. AND d.ann_frac GE ann_frac_lim)
i_tri=where(r LT 960. AND d.ann_frac LT ann_frac_lim,n_tri)
i_circle=where(r GE 960.,n_circle)

p=plot(/current,d[i_cross].x,d[i_cross].int_venus,symbol='+', $
       _extra=extra, $
       xtitle='solar-X [ arcsec ]', $
       ytitle='$I_{\rm V}$ [ erg cm!u-2!n s!u-1!n sr!u-1!n ]', $
       pos=[x0+ddx,y0,x0+dx,y1],linestyle='none', $
       xrange=[-1300,1300],/xsty, $
       yrange=[0,dv_max])
IF n_circle GT 0 THEN BEGIN 
  p1=plot(/current,/overplot,d[i_circle].x,d[i_circle].int_venus,symbol='o', $
          _extra=extra,linestyle='none')
ENDIF
IF n_tri GT 0 THEN BEGIN 
  p3=plot(/current,/overplot,d[i_tri].x,d[i_tri].int_venus,symbol='triangle', $
          _extra=extra,linestyle='none')
ENDIF 
p2=plot(/overplot,d.x,d.int_venus,_extra=extra)
xr=p.xrange
yr=p.yrange
xp=0.95*xr[0]+0.05*xr[1]
yp=0.10*yr[0]+0.90*yr[1]
tp=text(/data,xp,yp,'(a)',font_size=fs+2)



;-----------------------------------------
;
i_cross=where(r LT 960. AND d.ann_frac GE ann_frac_lim)
i_tri=where(r LT 960. AND d.ann_frac LT ann_frac_lim,n_tri)
i_circle=where(r GE 960.,n_circle)

;; q=plot(/current,pos=[x0+dx+ddx,y0,x0+2*dx,y1], $
;;        d[i_cross].int_ann,d[i_cross].int_venus,symbol='+', $
;;        _extra=extra, $
;;        xtitle='$I_{\rm ann}$ / erg cm!u-2!n s!u-1!n sr!u-1!n', $
;;        ytitle='$I_{\rm V}$ / erg cm!u-2!n s!u-1!n sr!u-1!n', $
;;        linestyle='none', $
;;        xrange=[0,dann_max],yra=[0,dv_max],xmin=4)

q=errorplot(/current,pos=[x0+dx+ddx,y0,x0+2*dx,y1], $
            d[i_cross].int_ann,d[i_cross].int_venus,d[i_cross].int_venus_sig,symbol='+', $
            _extra=extra, $
            xtitle='$I_{\rm ann}$ [ erg cm!u-2!n s!u-1!n sr!u-1!n ]', $
            ytitle='$I_{\rm V}$ [ erg cm!u-2!n s!u-1!n sr!u-1!n ]', $
            linestyle='none', $
            xrange=[0,dann_max],yra=[0,dv_max],xmin=4, $
            errorbar_thick=th)


IF n_tri GT 0 THEN BEGIN 
  q1=plot(/overplot,abs(d[i_tri].int_ann),d[i_tri].int_venus, $
          symbol='triangle',_extra=extra,linestyle='none')
ENDIF

IF n_circle GT 0 THEN BEGIN 
  q3=plot(/overplot,abs(d[i_circle].int_ann),d[i_circle].int_venus, $
          symbol='o',_extra=extra,linestyle='none')
ENDIF 


;c=linfit(abs(d[i_in].int_ann),d[i_in].int_venus)
c=linfit(abs(d[i_cross].int_ann),d[i_cross].int_venus,measure_errors=d[i_cross].int_venus_sig, $
         sigma=sigma,yfit=yfit)
x=findgen(61)*10.
q2=plot(/overplot,_extra=extra,x,c[0]+c[1]*x, $
        color=color_toi(/vibrant,'blue'))

print,'EIS linear fit parameters: '
print,format='("      c[0] = ",f6.2," +/-",f6.2)',c[0],sigma[0]
print,format='("      c[1] = ",f8.4," +/-",f8.4)',c[1],sigma[1]

;
; Check differences between fit and Venus intensities
;
diff=yfit-d[i_cross].int_venus
perc_diff=diff/d[i_cross].int_venus*100.
print,format='("Max difference (fit - Venus_int): ",f4.1,"%")',max(abs(perc_diff))
print,format='("Standard deviation (fit - Venus_int): ",f4.1,"%")',stdev(perc_diff)
;
; I set the c[0] value for the AIA line to be the same as EIS.
; Only overplot this line for 195.
;
IF imin EQ 0 THEN BEGIN 
q3=plot(/overplot,_extra=extra,x,c[0]+0.1063*x, $
        color=color_toi(/vibrant,'magenta'),linestyle='--')
ENDIF 

; If a wavelength other than 195 is plotted, then plot the fit to the 195 line.
;
IF imin NE 0 THEN BEGIN
  q4=plot(/overplot,_extra=extra,x,c[0]+0.1513*x, $
        color=color_toi(/vibrant,'blue'),linestyle='--')
ENDIF 

xr=q.xrange
yr=q.yrange
xp=0.95*xr[0]+0.05*xr[1]
yp=0.10*yr[0]+0.90*yr[1]
tp=text(/data,xp,yp,'(b)',font_size=fs+2,target=q)

lbl=trim(floor(wvl))


outfile='plot_eis_venus_ints_'+lbl+'.png'
w.save,outfile,width=2*xdim
message,/info,/cont,'Plot sent to the file '+outfile+'.'



return,w

END
