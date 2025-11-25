
PRO update_spec_gauss_ints, original_file, new_file, ea_files=ea_files, $
                            verbose=verbose, overwrite=overwrite

;+
; NAME:
;     UPDATE_SPEC_GAUSS_INTS
;
; PURPOSE:
;     Takes a line intensity file produced by spec_gauss_eis, and updates
;     the intensity to the new EIS effective area derived from the
;     30-Sep-2024 flare continuum analysis.
;
; CATEGORY:
;     Hinode; EIS; calibration.
;
; CALLING SEQUENCE:
;     UPDATE_SPEC_GAUSS_INTS, Original_File, New_File
;
; INPUTS:
;     Original_File: A string giving the name of the existing file
;                    containing EIS line intensities. Must be in the
;                    format produced by spec_gauss_eis and read by
;                    read_line_fits. **The intensities must have been
;                    derived with the EIS pre-launch calibration.**
;     New_File: The name of the new file that will contain the updated
;               intensities.
;
; OPTIONAL INPUTS:
;     EA_Files: A structure with the tags 'sw' and 'lw' containing the
;               names of the effective area files. It can be obtained
;               from read_effective_area or write_effective_area (see
;               example below). If not specified, then the routine
;               uses the default EA files from read_effective_area.
;
; KEYWORD PARAMETERS:
;     VERBOSE:  If set, then prints a comparison of the original intensity
;               and new intensity for each line.
;     OVERWRITE:  If NEW_FILE already exists, then it will not be
;                 overwritten unless this keyword is set.
;
; OUTPUTS:
;     Writes NEW_FILE, which is identical to ORIGINAL_FILE, except the
;     intensity and intensity uncertainties have been scaled based on
;     the new effective area curves. Note that the continuum intensities
;     are also scaled.
;
; EXAMPLE:
;     IDL> update_spec_gauss_ints,'spec_gauss_fits_calib0.txt','spec_gauss_fits_calib_v1.txt'
;
;     IDL> ea=read_effective_area(195.12,ea_files=ea_files)
;     IDL> update_spec_gauss_ints,'spec_gauss_fits_calib0.txt','spec_gauss_fits_calib_v1.txt',ea_files=ea_files
;
;     IDL> ea_files=write_effective_area()
;     IDL> update_spec_gauss_ints,'spec_gauss_fits_calib0.txt','spec_gauss_fits_calib_v1.txt',ea_files=ea_files
;
; CALLS:
;     READ_EFFECTIVE_AREA, EIS_EFF_AREA, READ_LINE_FITS
;
; MODIFICATION HISTORY:
;     Ver.1, 31-Oct-2025, Peter Young
;-

chck=file_info(original_file)
IF chck.exists EQ 0 THEN BEGIN
  message,/info,/cont,'The specified original intensity file does not exist! Returning...'
  return
ENDIF

chck=file_info(new_file)
IF chck.exists AND keyword_set(overwrite) EQ 0 THEN BEGIN
  message,/info,/cont,'The specified output file already exists. To overwrite it, set the /OVERWRITE keyword. Returning...'
  return
ENDIF 

;
; Set the LW wavelength array at high resolution.
;
wvl0=245. & wvl1=292.
wvl=findgen((round(wvl1-wvl0)*100.+1.))/100.+wvl0

;
; Get the original lab calibration.
;
ea_old=eis_eff_area(wvl,/quiet)

;
; Get my new effective area
;
ea_new=read_effective_area(wvl,ea_files=ea_files)

nwvl=n_elements(wvl)
ea_ratio=fltarr(nwvl)
k=where(ea_new GT 0.)
ea_ratio[k]=ea_old[k]/ea_new[k]

;
; Read the original line fits, and sort them by wavelength.
;
read_line_fits,original_file,fits
i=sort(fits.wvl)
fits=fits[i]

outfits=fits

IF keyword_set(verbose) THEN BEGIN
  print,'  Wavelength  Old Int.  New Int.'
ENDIF

openw,lout,new_file,/get_lun

n=n_elements(fits)
FOR i=0,n-1 DO BEGIN
  getmin=min(abs(wvl-outfits[i].wvl),imin)
  scl=ea_ratio[imin]
  outfits[i].int=outfits[i].int*scl
  outfits[i].sint=outfits[i].sint*scl
  ;
  IF keyword_set(verbose) THEN BEGIN
    print,format='(f12.3,2f10.1)',outfits[i].wvl,fits[i].int,outfits[i].int
  ENDIF 
  ;
  ; Also change the continuum intensities.
  ;
  getmin=min(abs(wvl-outfits[i].x0),imin)
  scl=ea_ratio[imin]
  outfits[i].y0=outfits[i].y0*scl
  outfits[i].sigy0=outfits[i].sigy0*scl
  ;
  getmin=min(abs(wvl-outfits[i].x1),imin)
  scl=ea_ratio[imin]
  outfits[i].y1=outfits[i].y1*scl
  outfits[i].sigy1=outfits[i].sigy1*scl
  ;
  ; I copied the format from spec_gauss_widget.
  ;
  printf,lout,format='(2f12.4,2e12.3,2f12.4,2e12.4,2f12.4,4e12.4)', $
         outfits[i].wvl,outfits[i].swvl, $
         outfits[i].peak,outfits[i].speak, $
         outfits[i].width,outfits[i].swidth, $
         outfits[i].int,outfits[i].sint, $
         outfits[i].x0, outfits[i].x1, $
         outfits[i].y0, outfits[i].sigy0, $
         outfits[i].y1, outfits[i].sigy1
ENDFOR

free_lun,lout

message,/info,/cont,'The file '+new_file+' has been written. It contains updated intensities and uncertainties for the lines.'

END
