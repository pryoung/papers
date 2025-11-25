
PRO make_bg_subtracted_continuum_spectrum, swspec=swspec, lwspec=lwspec, calib=calib

;+
; NAME:
;     MAKE_BG_SUBTRACTED_CONTINUUM_SPECTRUM
;
; PURPOSE:
;     Creates the background-subtracted flare spectrum in photon units.
;
; CATEGORY:
;     Flare; continuum.
;
; CALLING SEQUENCE:
;     MAKE_BG_SUBTRACTED_CONTINUUM_SPECTRUM
;
; INPUTS:
;     None.
;
; KEYWORD PARAMETERS:
;     CALIB:  If set, then the calibrated spectra are used instead of the
;             photon spectra.
;
; OUTPUTS:
;     See optional outputs.
;
; OPTIONAL OUTPUTS:
;     SWSPEC:  A structure in the format returned by eis_mask_spectrum,
;              but with the int and err tags modified to contain the
;              background-subtracted spectrum. This is for the SW channel.
;     LWSPEC:  A structure in the format returned by eis_mask_spectrum,
;              but with the int and err tags modified to contain the
;              background-subtracted spectrum. This is for the LW channel.
;
; EXAMPLE:
;     IDL> make_bg_subtracted_continuum_spectrum, swspec=swspec, lwspec=lwspec
;
; MODIFICATION HISTORY:
;     Ver.1, 23-Oct-2025, Peter Young
;     Ver.2, 25-Nov-2025, Peter Young
;       Tidied up for moving to GitHub repository.
;-

IF keyword_set(calib) THEN add_text='_calib0' ELSE add_text=''

datadir=file_dirname(file_which('make_bg_subtracted_continuum_spectrum.pro'))
datadir=concat_dir(datadir,'data')

bgfile=concat_dir(datadir,'20240930_225718_continuum_bg'+add_text+'.sav')
restore,bgfile
swbg=swspec
lwbg=lwspec
file=concat_dir(datadir,'20240930_225718_continuum_spec'+add_text+'.sav')
restore,file

swspec.int=swspec.int-swbg.int
k=where(swspec.err NE swspec.missing AND swbg.err NE swbg.missing,nk)
n=n_elements(swspec.err)
print,format='("No. of of missing pixels in SW spectrum: ",i5)',n-nk
swspec.err[k]=sqrt(swspec.err[k]^2 + swbg.err[k]^2)

lwspec.int=lwspec.int-lwbg.int
k=where(lwspec.err NE lwspec.missing AND lwbg.err NE lwbg.missing,nk)
n=n_elements(lwspec.err)
print,format='("No. of of missing pixels in LW spectrum: ",i5)',n-nk
lwspec.err[k]=sqrt(lwspec.err[k]^2 + lwbg.err[k]^2)

END

