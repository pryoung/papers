

FUNCTION aia_venus_linfit, data, all=all, sigma=sigma

;+
; NAME:
;     AIA_VENUS_LINFIT
;
; PURPOSE:
;     Performs a linear fit to the Venus intensity as a function of the
;     Venus annulus intensity.
;
; CATEGORY:
;     AIA; Venus; fitting.
;
; CALLING SEQUENCE:
;     Result = AIA_VENUS_LINFIT( Data )
;
; INPUTS:
;     Data:  The structure returned by aia_get_venus.pro.
;
; KEYWORD PARAMETERS:
;     ALL:    By default, the routine only fits the points inside the solar
;             disk. Setting this keyword allows the above-limb points to be
;             included too.
;     NO_PLOT: If set, then the plot is not created.
;
; OUTPUTS:
;     A 2-element array giving the linear fit coefficients. That is,
;     c[0]+c[1]*x. A direct-graphics plot is created showing the data and the
;     fit.
;
; OPTIONAL OUTPUTS:
;     Sigma:  A 2-element array giving the uncertainties on the linear fit
;             coefficients.
;
; EXAMPLE:
;     IDL> d=aia_get_venus()
;     IDL> c=aia_venus_linfit(d)
;
; MODIFICATION HISTORY:
;     Ver.1, 10-Jan-2023, Peter Young
;-


IF tag_exist(data,'int_stdev') EQ 0 THEN BEGIN
  message,/info,/cont,'The input data structure does not have the int_stdev tag, which means it was created with an old version of aia_get_venus. Try running aia_get_venus again or updating your repository. Returning...'
  return,-1
ENDIF 

IF keyword_set(all) THEN BEGIN
  d=data
ENDIF ELSE BEGIN 
  i_in=where(data.r LT 960.)
  d=data[i_in]
ENDELSE 



c=linfit(d.sub_map_int,d.int,meas=d.int_stdev, $
         sigma=sigma)

IF NOT keyword_set(no_plot) THEN BEGIN
  plot,d.sub_map_int,d.int,psym=6,symsize=3, $
       charsiz=2.0, $
       xtitle='Annulus intensity', $
       ytitle='Venus intensity'
  x0=0
  x1=max(d.sub_map_int)
  oplot,[x0,x1],[c[0]+c[1]*x0,c[0]+c[1]*x1],th=2
ENDIF 

return,c

END
