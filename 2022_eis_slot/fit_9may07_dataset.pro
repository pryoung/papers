

PRO fit_9may07_dataset

;+
; PRY, 16-Feb-2022
;
; This routine is used to generate data that is used in the figure
; plot_slit_tilts_v3.png for the EIS slot paper.
;
; It takes the SYNOP001 dataset from 18:05 on 9-May-2007 and fits the
; narrow slit data with a Gaussian (using eis_auto_fit.pro), and fits
; the slot data using eis_fit_slot_exposure.
;
; The slot fit targets the y-pixel region 205:219 as the emission is
; uniform in this region. The data are binned (ybin=20) and I set the
; start pixel for the fit to be y=5 (ystart=5). This same binning is
; applied to the slit data.
;
; Since the slot data covers the entire CCD, I restrict the slot
; window to 64 pixels (npix=64).
;
; I have a pre-saved template for the narrow slit fit.
;-


;---
; Load slot data and perform fit.
;
file=eis_find_file('9-may-2007 18:05',/lev)
wd=eis_getwindata(file,195.12)

data=eis_fit_slot_exposure(wd,iexp_prp=0,npix=64,/quiet, $
                          ybin=20,ystart=5)


;---
; Now fit the narrow slit data.
;
file=eis_find_file('9-may-2007 18:08',/lev)
wd=eis_getwindata(file,195.12,/refill)
wdx=eis_bin_windata(wd,ybin=20,ystart=5)

restore,'synop001_slit_template_195.save'
eis_auto_fit,wdx,fit,template=template,wvl_select=wvl_select,/quiet,iexp=0


outfile='fit_9may07_dataset.save'
save,file=outfile,data,fit

print,'% FIT_9MAY07_DATASET: the structures DATA and FIT have been written to the file '+outfile


END
