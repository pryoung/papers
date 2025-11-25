
FUNCTION read_effective_area, wvl, version=version, ea_files=ea_files

;+
; NAME:
;     READ_EFFECTIVE_AREA
;
; PURPOSE:
;     Derives the EIS effective area for the specified wavelengths. The
;     curves were generated from an analysis of the flare continuum from
;     the 30-Sep-2024 22:57 UT dataset.
;
; CATEGORY:
;     Hinode; EIS; calibration.
;
; CALLING SEQUENCE:
;     Result = READ_EFFECTIVE_AREA( Wvl )
;
; INPUTS:
;     Wvl:  A scalar of vector giving wavelengths in Angstroms. If not
;           defined, then it will be returned as the wavelength array in
;           the effective area curve file.
;
; OPTIONAL INPUTS:
;     Version:  A string containing the label (as defined in
;               write_effective_area) that differentiates different EA
;               files. For example, 'v1', 'v2', etc. The default will
;               always be the best file. Currently this is 'v1'.
;     EA_Files:  An IDL structure with tags 'sw' and 'lw' containing the
;                names of the two effective area files that are read by
;                this routine.
;	
; OUTPUTS:
;     An array of same size as WVL, giving the EIS effective area at the
;     specified wavelengths. 
;
; OPTIONAL OUTPUTS:
;     EA_Files:  An IDL structure with tags 'sw' and 'lw' containing the
;                names of the two effective area files that are read by
;                this routine.
;
; EXAMPLE:
;     IDL> wvl=findgen(43)+170
;     IDL> ea=read_effective_area(wvl)
;
;     IDL> ea_files={sw: 'my_ea_file_sw.txt', lw: 'my_ea_file_lw.txt'}
;     IDL> ea=read_effective_area(wvl, ea_files=ea_files)
;
; RESTRICTIONS:
;     If you use the routine in the GitHub repository
;     pryoung/papers/2025_calib then it should automatically find the
;     effective area files in the same repository.
;
; MODIFICATION HISTORY:
;     Ver.1, 31-Oct-2025, Peter Young
;     Ver.2, 24-Nov-2025, Peter Young
;      Modified for inclusion in a GitHub repository.
;-

IF n_tags(ea_files) EQ 0 THEN BEGIN 
  IF n_elements(version) EQ 0 THEN version='v1'
;
; This tells the routine to look for the EA data in the sub-directory 'data'
; under the directory where read_effective_area resides.
;
  ea_dir=file_dirname(file_which('read_effective_area.pro'))
  ea_dir=concat_dir(ea_dir,'data')

  ea_file_sw='eis_eff_area_cont_sw_'+version+'.txt'
  ea_file_sw=concat_dir(ea_dir,ea_file_sw)

  ea_file_lw='eis_eff_area_cont_lw_'+version+'.txt'
  ea_file_lw=concat_dir(ea_dir,ea_file_lw)

  ea_files={sw: ea_file_sw, lw: ea_file_lw}
ENDIF ELSE BEGIN
  ea_file_sw=ea_files.sw
  ea_file_lw=ea_files.lw
ENDELSE 

IF n_elements(wvl) EQ 0 THEN swtch=1b ELSE swtch=0b

;
; Get SW effective area.
; ----------------------
chck=file_info(ea_file_sw)
IF chck.exists EQ 0 THEN BEGIN
  message,/info,/cont,'The effective area file for the SW file was not found. Returning...'
  return,-1.
ENDIF
;
openr,lin,ea_file_sw,/get_lun
s1=''
w=0.
ea=0.
WHILE eof(lin) NE 1 DO BEGIN
  readf,lin,s1
  IF s1.substring(0,0) NE '#' THEN BEGIN
    reads,s1,format='(2f13.0)',a,b
    w=[w,a]
    ea=[ea,b]
  ENDIF 
ENDWHILE 
free_lun,lin

k=where(ea NE 0.)
w=w[k]
ea=ea[k]

nwvl=n_elements(wvl)
ea_out=fltarr(nwvl)

IF swtch EQ 0b THEN BEGIN
  k=where(wvl GE w[0] AND wvl LE w[-1],nk)
  IF nk NE 0 THEN BEGIN
    y2=spl_init(w,alog10(ea))
    yi=spl_interp(w,alog10(ea),y2,wvl[k])
    ea_out[k]=10.^yi
  ENDIF
ENDIF ELSE BEGIN
  wvl=w
  ea_out=ea
ENDELSE

;
; Get LW effective area.
; ----------------------
chck=file_info(ea_file_lw)
IF chck.exists EQ 0 THEN BEGIN
  message,/info,/cont,'The effective area file for the LW file was not found. Returning...'
  return,-1.
ENDIF
;
openr,lin,ea_file_lw,/get_lun
s1=''
w=0.
ea=0.
WHILE eof(lin) NE 1 DO BEGIN
  readf,lin,s1
  IF s1.substring(0,0) NE '#' THEN BEGIN
    reads,s1,format='(2f13.0)',a,b
    w=[w,a]
    ea=[ea,b]
  ENDIF 
ENDWHILE 
free_lun,lin

k=where(ea NE 0.)
w=w[k]
ea=ea[k]

IF swtch EQ 0b THEN BEGIN
  k=where(wvl GE w[0] AND wvl LE w[-1],nk)
  IF nk NE 0 THEN BEGIN
    y2=spl_init(w,alog10(ea))
    yi=spl_interp(w,alog10(ea),y2,wvl[k])
    ea_out[k]=10.^yi
  ENDIF
ENDIF ELSE BEGIN
  wvl=[wvl,w]
  ea_out=[ea_out,ea]
ENDELSE

return,ea_out

END
