
PRO get_slit_slot_intensities, output

;
; This goes through all the slit-slot pairs, fits the narrow slit 195
; line, and extracts the intensity for the slot line.
;

outdir='slit_slot_intensities'
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

restore,'synop001_slit_template_195.save'

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
  wd=eis_getwindata(file2,195.12,/refill)
 ;
 ; The 2007-05-04T06:25:19 dataset has an error array of all-zeros for
 ; some reason.
 ;
  IF max(wd.err[*,0,*,0]) EQ 0. THEN continue
  wdx=eis_trim_windata(wd,[194.62,195.62])
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
  wd=eis_getwindata(file1,195.12)
  getmin=min(abs(wd.wvl-wvl_fit),imin)

  ny=wd.ny
  ypix=indgen(ny)+wd.hdr.yws
  d_ang=eis_slit_slot_offset(ypix,date=output[i].slot_dobs)
  d_pix=round(d_ang/(wd.wvl[imin+1]-wd.wvl[imin]))
  
  scl=eis_slot_calib_factor(wavel=195.12,exptime=wd.exposure_time[0])
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
