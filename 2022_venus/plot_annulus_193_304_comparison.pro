



FUNCTION plot_annulus_193_304_comparison, data


;+
; NAME:
;     PLOT_ANNULUS_193_304_COMPARISON
;
; PURPOSE:
;     Creates a plot showing a radial slice through synthetic AIA 193 and
;     304 images. The images are created by taking an annulus and convolving
;     with the Grigis et al. PSF.
;
; CATEGORY:
;     SDO; AIA; synthetic data.
;
; CALLING SEQUENCE:
;     Result = PLOT_ANNULUS_193_304_COMPARISON( )
;
; INPUTS:
;     None.
;
; OPTIONAL INPUTS:
;     Data:  Structure returned by the routine annulus_193_304_comparison.
;
; OUTPUTS:
;     Creates an IDL plot object showing cross-sections through the
;     synthetic 193 and 304 images. The plot is also saved to file
;     plot_annulus_193_304_comparison.png.
;
; EXAMPLE:
;     IDL> data=annulus_193_304_comparison()
;     IDL> w=plot_annulus_193_304_comparison(data)
;
; MODIFICATION HISTORY:
;     Ver.1, 08-Jul-2022, Peter Young
;-



IF n_tags(data) EQ 0 THEN data=annulus_193_304_comparison()

r=data.radius[300:*,300]*0.6
d193=data.d193[300:*,300]
d304=data.d304[300:*,300]

th=2
fs=12

xdim=500 & ydim=350
w=window(dim=[xdim,ydim])

p=plot(r,d193,/stairstep,xra=[0,65],/xsty, $
       xtitle='radius [ arcsec ]', $
       ytitle='intensity [ no units ]', $
       xth=th,yth=th,th=th,font_size=fs, $
       pos=[0.13,0.12,0.98,0.98], $
       xticklen=0.015,yticklen=0.015, $
       yrange=[0,1.1],/ysty, $
       name='193',xmin=1,ymin=1,/current)
q=plot(r,d304,/stairstep,color='blue',/overplot,th=th,name='304')


l=legend(target=[p,q],font_size=fs,/data,pos=[18,1.03],thick=th)

p.save,'plot_annulus_193_304_comparison.png',width=2*xdim
return,w

END
