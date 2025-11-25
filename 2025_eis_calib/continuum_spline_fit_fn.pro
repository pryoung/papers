
FUNCTION continuum_spline_fit_fn, x, p, _extra=e

;+
;  This is the spline fit function used by continuum_spline_fit.pro.
;-

x_spl=e.x_spl

y2=spl_init(x_spl,p)
return,exp(spl_interp(x_spl,p,y2,x))

END
