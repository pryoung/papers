
FUNCTION continuum_spline_fit, intensity_file, n_spl=n_spl, quiet=quiet

;+
; NAME:
;     CONTINUUM_SPLINE_FIT
;
; PURPOSE:
;     Derives an EA curve for the LW channel that is a spline curve with
;     n_spl nodes.
;
; CATEGORY:
;     Flare; continuum; fit.
;
; CALLING SEQUENCE:
;     Result = CONTINUUM_SPLINE_FIT( Intensity_File )
;
; INPUTS:
;     Intensity_File: The name of a text file containing the continuum
;          intensities. This is the file automatically produced by
;          spec_gauss_eis.pro called 'average_intensity.txt'.
;
; OPTIONAL INPUTS:
;     N_Spl:  The number of node points. If not specified, then 16 is used
;             for the SW channel and 8 is used for the LW channel.
;	
; KEYWORD PARAMETERS:
;     QUIET:  If set, then do not print informational messages to the IDL
;             window.
;
; OUTPUTS:
;     An IDL structure with the following tags:
;      .x_spl  Wavelengths of spline nodes.
;      .xx     The input wavelengths from intensity_file.
;      .yy     The input intensities from intensity_file.
;      .ee     The input intensity errors from intensity_file.
;      .yfit   The fit to the YY values.
;      .chisq  Reduced chi-square value for fit.
;      .y_spl  The spline node values.
;      .sigmaa The uncertainties on the spline node values.
;
; EXAMPLE:
;     IDL> output=continuum_spline_fit('sw_continuum_ints.txt')
;
; MODIFICATION HISTORY:
;     Ver.1, 25-Nov-2025, Peter Young
;-

chck=file_info(intensity_file)
IF chck.exists EQ 0 THEN BEGIN
  message,/info,/cont,'The intensity file does not exist! Returning...'
  return,-1
ENDIF 

s=sg_read_avg_int(intensity_file)

;
; Get rid of any intensity points below 0.
;
k=where(s.int GT 0.,nk)
IF nk NE 0 THEN s=s[k]

;
; This is only used to get the end points of the wavelength range.
;
make_bg_subtracted_continuum_spectrum, swspec=swspec, lwspec=lwspec

;
; The SW effective area is effectively zero below 171, so I set
; this as the minimum wavelength.
;
IF mean(s.wvl) LT 230. THEN BEGIN
  spec=swspec
  min_wvl=171.0
  max_wvl=max(swspec.wvl)
  IF n_elements(n_spl) EQ 0 THEN n_spl=16
ENDIF ELSE BEGIN
  spec=lwspec
  min_wvl=min(lwspec.wvl)
  max_wvl=max(lwspec.wvl)
  IF n_elements(n_spl) EQ 0 THEN n_spl=8
ENDELSE 
  
IF NOT keyword_set(quiet) THEN message,/info,/cont,'No. of spline points: '+trim(n_spl)

x_spl=findgen(n_spl)/float(n_spl-1)*(max_wvl-min_wvl)+min_wvl

;
; Define data to be fit. Note that we're fitting to the log of the intensity.
;
xx=s.wvl
yy=s.int
ee=s.err

;
; Set the initial values for the spline points.
;
init=make_array(n_spl,value=alog10(mean(yy)))

junk=temporary(other)
other={ x_spl: x_spl }

aa=mpfitfun('continuum_spline_fit_fn', xx, yy, ee, init, $
            perror=sigmaa, /quiet, bestnorm=bestnorm,yfit=yfit, $
            parinfo=parinfo,status=status, functargs= other)

chisq=bestnorm/(float(n_elements(xx))-float(n_spl))
print,format='("Reduced chi^2 value: ",f7.2)',chisq

output={x_spl: x_spl, xx: xx, yy: yy, ee: ee, $
        yfit: yfit, chisq: chisq, $
        aa: aa, sigmaa: sigmaa}

IF NOT keyword_set(quiet) THEN BEGIN
  wvl=rebin(spec.wvl,1024)
  int=rebin(spec.int,1024)
  yrange=[0,max(yy)*1.5]
  plot,wvl,int,psym=10,/xsty,yrange=yrange,/ysty, $
       charsiz=2,xtit='Wavelength (A)', $
       ytit='Intensity (photon s!u-1!n)'
  y2=spl_init(output.x_spl,output.aa)
  yi=spl_interp(output.x_spl,output.aa,y2,wvl)
  oplot,wvl,exp(yi),th=2
  xyouts,/data,average(wvl),yrange[1]*0.20,'n_spl='+trim(n_spl),charsiz=2, $
         align=0.5
ENDIF 

return,output

END

