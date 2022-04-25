
PRO get_slit_slot_intensities, output, wvl=wvl, n_limit=n_limit


;+
; NAME:
;     GET_SLIT_SLOT_INTENSITIES
;
; PURPOSE:
;     This goes through all the SYNOP001 slit-slot pairs, fits the
;     narrow slit 195 line, and extracts the intensity for the slot
;     line. 
;
; CATEGORY:
;     Hinode; EIS; slit; slot.
;
; CALLING SEQUENCE:
;     GET_SLIT_SLOT_INTENSITIES, Output
;
; INPUTS:
;     None.
;
; OPTIONAL INPUTS:
;     Wvl:   By default the routine processes Fe XII 195.12. Use WVL
;            to specify a different wavelength (make sure to give a
;            precise wavelength).
;     N_Limit: 
;	
; OUTPUTS:
;     The routine writes the intensity data for each file to the
;     directory 'slit_slot_intensities'. (If a different wavelength is
;     specified, then '_WVL' is added to the directory.)
;
;
; OPTIONAL OUTPUTS:
;     A structure with the following tags:
;      .slit_dobs  DATE_OBS of slit raster.
;      .slot_dobs  DATE_OBS of slot raster.

; MODIFICATION HISTORY:
;     Ver.2, 31-Mar-2022, Peter Young
;       Added WVL= optional input.
;-



IF n_elements(wvl) EQ 0 THEN BEGIN
  wvl=195.12
  outdir='slit_slot_intensities'
  wvl_str=trim(floor(wvl))
ENDIF ELSE BEGIN
  wvl_str=trim(floor(wvl))
  outdir='slit_slot_intensities_'+wvl_str
ENDELSE 
 
chck=file_info(outdir)
IF chck.directory EQ 0 THEN file_mkdir,outdir
chck=file_search(outdir,'*.save',count=count)
IF count NE 0 THEN file_delete,chck

s=eis_obs_structure('1-may-2007','1-jun-2007',study_acr='synop001',count=n)

str={slit_dobs: '', slot_dobs: ''}
output=0

FOR i=0,n-1 DO BEGIN
  IF s[i].slit_index EQ 3 THEN BEGIN 
    d1_tai=anytim2tai(s[i].date_obs)
    d2_tai=anytim2tai(s[i+1].date_obs)
    IF d2_tai-d1_tai LE 300. THEN BEGIN
      str.slot_dobs=s[i].date_obs
      str.slit_dobs=s[i+1].date_obs
      IF n_tags(output) EQ 0 THEN output=str ELSE output=[output,str]
    ENDIF
  ENDIF 
ENDFOR


n=n_elements(output)

template_file='synop001_slit_template_'+wvl_str+'.save'
chck=file_info(template_file)
IF chck.exists EQ 0 THEN BEGIN
  print,'% GET_SLIT_SLOT_INTENSITIES: The fit template file does not exist. Returning...'
  return
ENDIF 
restore,template_file


IF n_elements(n_limit) NE 0 THEN n=n_limit

FOR i=0,n-1 DO BEGIN
  file2=eis_find_file(output[i].slit_dobs,twindow=5.,count=count,/lev)
  IF count EQ 0 THEN BEGIN
    print,'** The file '+output[i].slit_dobs+' is missing!  **'
    return
  ENDIF
  d=obj_new('eis_data',file2)
  fmirr=*(d->getaux_data()).fmirr
  fmirr_slit=fmirr[0]
  obj_destroy,d
 ;
  wd=eis_getwindata(file2,wvl,/refill)
 ;
 ; The 2007-05-04T06:25:19 dataset has an error array of all-zeros for
 ; some reason.
 ;
  IF max(wd.err[*,0,*,0]) EQ 0. THEN continue
  wdx=eis_trim_windata(wd,wvl+[-0.5,0.5])
  yws_slit=wd.hdr.yws
  eis_auto_fit,wdx,fit,template=template,wvl_select=wvl_select,/quiet,iexp=0
 ;
  wvl_fit=median(reform(fit.aa[1,0,*])+reform(fit.offset))
  file1=eis_find_file(output[i].slot_dobs,twindow=5.,count=count,/lev)
  IF count EQ 0 THEN BEGIN
    print,'** The file '+output[i].slot_dobs+' is missing!  **'
    return
  ENDIF
  d=obj_new('eis_data',file1)
  fmirr=*(d->getaux_data()).fmirr
  fmirr_slot=fmirr[0]
  obj_destroy,d
 ;
  wd=eis_getwindata(file1,wvl)
  getmin=min(abs(wd.wvl-wvl_fit),imin)

  ny=wd.ny
  ypix=indgen(ny)+wd.hdr.yws
  d_ang=eis_slit_slot_offset(ypix,date=output[i].slot_dobs)
  d_pix=round(d_ang/(wd.wvl[imin+1]-wd.wvl[imin]))
  
  scl=eis_slot_calib_factor(wavel=wvl,exptime=wd.exposure_time[0])
  int1=reform(wd.int[imin,0,*,0])*scl
  int3=average(reform(wd.int[imin-1:imin+1,0,*,0]),1,missing=wd.missing)*scl
  int5=average(reform(wd.int[imin-2:imin+2,0,*,0]),1,missing=wd.missing)*scl
 ;
  bg1=fltarr(ny)
  bg2=fltarr(ny)
  FOR j=0,ny-1 DO BEGIN 
    bg1[j]=average(reform(wd.int[imin+d_pix[j]-30:imin+d_pix[j]-26,0,j,0]),missing=wd.missing)*scl
    bg2[j]=average(reform(wd.int[imin+d_pix[j]+26:imin+d_pix[j]+30,0,j,0]),missing=wd.missing)*scl
  ENDFOR
  bg=average([[bg1],[bg2]],2)
  yws_slot=wd.hdr.yws
 ;
  outfile=time2fid(output[i].slot_dobs,/full_year,/time)+'_data.save'
  outfile=concat_dir(outdir,outfile)
  save,file=outfile,fit,fmirr_slit,yws_slit, $
       int1,int3,int5,bg,bg1,bg2,yws_slot,fmirr_slot
ENDFOR 


END
