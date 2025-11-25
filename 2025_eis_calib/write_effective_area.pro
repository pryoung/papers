
FUNCTION write_effective_area, abund_file=abund_file, ioneq_file=ioneq_file, $
                               log_press=log_press, dem_file=dem_file, $
                               sw_filename=sw_filename, lw_filename=lw_filename, $
                               label=label

;+
; NAME:
;     WRITE_EFFECTIVE_AREA
;
; PURPOSE:
;     Writes the EIS effective area curves from the analysis of the
;     30-Sep-2024 22:57 flare continuum.
;
; CATEGORY:
;     Hinode; EIS; calibration.
;
; CALLING SEQUENCE:
;     WRITE_EFFECTIVE_AREA
;
; INPUTS:
;     Label:  Text string giving a label that is applied to the output
;             files and determines which DEM input file is used. Call the
;             routine with no inputs to see the options.
;
; OPTIONAL INPUTS:
;     Abund_File: The name of an abundance file used to calculate the
;                 synthetic continuum spectrum. If not set, then the
;                 abundance file from the Github repository is used.
;     Ioneq_File: The name of an ion balance file used to calculate the
;                 synthetic continuum spectrum. If not set, then the
;                 ion balance file from the Github repository is used.
;     Log_Press:  The logarithm of the pressure (units: K cm^-3) used to
;                 calculate the synthetic continuum spectrum. If not
;                 specified, then the value of 17.3 is used.
;     Dem_File:   The name of a DEM file to be used to calculate the
;                 synthetic continuum spectrum. If not specified, then
;                 the user is given an option from a DEM in the GitHub
;                 repository.
;     SW_Filename:  The name to be used for the SW effective area file.
;                   If not specified, then eis_eff_area_cont_sw.txt is
;                   used (although see LABEL= input).
;     LW_Filename:  The name to be used for the LW effective area file.
;                   If not specified, then eis_eff_area_cont_lw.txt is
;                   used (although see LABEL= input).
;     Label:      A string that is used to modify the output filenames
;                 - see example below. Ignored if sw_filename or
;                 lw_filename are set.
;
; OUTPUTS:
;     Writes out the SW and LW effective area files to the working
;     directory. Use the routine read_effective_area.pro to read them.
;     The names of the output files are output to a structure with the
;     tags:
;      .sw  Filename for the EIS SW channel.
;      .lw  Filename for the EIS LW channel.
;
;     The default filenames are:
;       eis_eff_area_cont_sw.txt
;       eis_eff_area_cont_lw.txt
;
;     However, you can specify the names directly with the optional
;     inputs SW_FILENAME and LW_FILENAME. You can also set the input
;     LABEL= to modify the default filenames by inserting a label.
;     For example, label='v1' gives:
;       eis_eff_area_cont_sw_v1.txt
;       eis_eff_area_cont_lw_v1.txt
;
; EXTERNAL CALLS:
;     EIS_EFF_AREA, READ_DEM, READ_IONEQ, READ_ABUND, CH_CONTINUUM,
;     INTERPOL_EIS_EA.
;
; EXAMPLE:
;     IDL> output=write_effective_area()
;
; MODIFICATION HISTORY:
;     Ver.1, 24-Nov-2025, Peter Young
;-

;
; This is the location where the default data files are.
;
datadir=file_dirname(file_which('write_effective_area.pro'))
datadir=concat_dir(datadir,'data')

IF n_elements(dem_file) EQ 0 THEN BEGIN
  list=file_search(datadir,'*.dem',count=n)
  print,'The input DEM_FILE= was not specified. Please choose an option from the repository: '
  options=trim(findgen(n)+1)
  FOR i=0,1 DO BEGIN
    print,format='(6x,i3,".",2x,a30)',i+1,strpad(file_basename(list[i]),30,fill=' ',/after)
  ENDFOR
  read,ans
  k=where(trim(ans) EQ options,nk)
  IF nk EQ 0 THEN BEGIN
    message,/info,/cont,'Input not recognised. Returning...'
    return,-1
  ENDIF ELSE BEGIN
    dem_file=list[k[0]]
  ENDELSE 
ENDIF 

IF n_elements(sw_filename) NE 0 THEN BEGIN
  outfile_sw=sw_filename
ENDIF ELSE BEGIN
  IF n_elements(label) NE 0 THEN lbl_string='_'+label ELSE lbl_string=''
  outfile_sw='eis_eff_area_cont_sw'+lbl_string+'.txt'
ENDELSE 

IF n_elements(lw_filename) NE 0 THEN BEGIN
  outfile_lw=lw_filename
ENDIF ELSE BEGIN
  IF n_elements(label) NE 0 THEN lbl_string='_'+label ELSE lbl_string=''
  outfile_lw='eis_eff_area_cont_lw'+lbl_string+'.txt'
ENDELSE 

;
; Set default ioneq and abund files, and pressure.
;
IF n_elements(ioneq_file) EQ 0 THEN ioneq_file=concat_dir(datadir,'chianti_p1730.ioneq')
IF n_elements(abund_file) EQ 0 THEN abund_file=concat_dir(datadir,'sun_photospheric_fip_bias_0_57.abund')
IF n_elements(log_press) EQ 0 THEN log_press=17.5

;
; Set the files that contain the flare continuum measurements.
;
sw_cont_file=concat_dir(datadir,'sw_cont_fit.sav')
lw_cont_file=concat_dir(datadir,'lw_cont_fit.sav')

;
; These are the wavelengths used for the official EA file.
; 
wvl0=245. & wvl1=292.
wvl_lw=findgen((round(wvl1-wvl0)+1.))+wvl0

wvl0=165. & wvl1=213.
wvl_sw=findgen((round(wvl1-wvl0)+1.))+wvl0

;
; Get the original lab calibration.
;
ea_old_sw=eis_eff_area(wvl_sw,/quiet)
ea_old_lw=eis_eff_area(wvl_lw,/quiet)

;
; Get the spline fit to the continuum intensity.
; This returns the structure ea_cont_fit.
;
restore,sw_cont_file

;
; Get the observed continuum intensity, defined for WVL.
;
y2=spl_init(ea_cont_fit.x_spl,ea_cont_fit.aa)
yi=spl_interp(ea_cont_fit.x_spl,ea_cont_fit.aa,y2,wvl_sw)
c_obs_sw=exp(yi)
k=where(wvl_sw LT floor(ea_cont_fit.x_spl[0]) OR wvl_sw GT ceil(ea_cont_fit.x_spl[-1]),nk)
IF nk GT 0 THEN c_obs_sw[k]=0.

;
; Get the spline fit to the continuum intensity.
; This returns the structure ea_cont_fit.
;
restore,lw_cont_file

;
; Get the observed continuum intensity, defined for WVL.
;
y2=spl_init(ea_cont_fit.x_spl,ea_cont_fit.aa)
yi=spl_interp(ea_cont_fit.x_spl,ea_cont_fit.aa,y2,wvl_lw)
c_obs_lw=exp(yi)
k=where(wvl_lw LT floor(ea_cont_fit.x_spl[0]) OR wvl_lw GT ceil(ea_cont_fit.x_spl[-1]),nk)
IF nk GT 0 THEN c_obs_lw[k]=0.


;
; Get the continuum intensity from the DEM.
;
read_dem,dem_file,logt_dem,log_dem
;
c_dem_sw=ch_continuum(10.^logt_dem,wvl_sw,/photon,press=10.^log_press, $
               abund_file=abund_file,adv=0,ioneq_file=ioneq_file, $
               dem_int=10.^log_dem,/sum)
c_dem_lw=ch_continuum(10.^logt_dem,wvl_lw,/photon,press=10.^log_press, $
               abund_file=abund_file,adv=0,ioneq_file=ioneq_file, $
               dem_int=10.^log_dem,/sum)

;
; Need conversion factor to go from phot/cm2/s/sr/A to phot/s
;
dlambda=c_dem_sw.wvl[1]-c_dem_sw.wvl[0]
t_exp=60.
slit_size=2.0
conv_factor=2.349e-11*dlambda*t_exp*slit_size

ea_new_sw=c_obs_sw/(c_dem_sw.int*conv_factor)
ea_new_lw=c_obs_lw/(c_dem_lw.int*conv_factor)

;
; Get the new EA at 195.12 to be used for normalization.
;
k=where(ea_new_sw GT 0.)
y2=spl_init(wvl_sw[k],alog(ea_new_sw[k]))
yi=spl_interp(wvl_sw[k],alog(ea_new_sw[k]),y2,195.12)
ea_new_195=exp(yi)

;
; Normalize to the Del Zanna et al. (2025) calibration at 195.12 Ang.
;
gdz_ea_195=interpol_eis_ea('30-sep-2024',195.12)
scl=gdz_ea_195[0]/ea_new_195
print,format='("GDZ25 Scale factor: ",f7.2)',scl

;
; Update the new effective areas
;
ea_new_sw=ea_new_sw*scl
ea_new_lw=ea_new_lw*scl

openw,lout,outfile_sw,/get_lun
printf,lout,'# EIS effective area data for SW channel'
printf,lout,'# Filename: '+file_basename(outfile_sw)
printf,lout,'# DEM file used: '+file_basename(dem_file)
printf,lout,'# ioneq file used: '+file_basename(ioneq_file)
printf,lout,'# abund file used: '+file_basename(abund_file)
printf,lout,'# Date written: '+systime()
printf,lout,'# Prepared by Peter R. Young'
nw=n_elements(wvl_sw)
FOR i=0,nw-1 DO BEGIN
  printf,lout,format='(f13.3,f13.7)',wvl_sw[i],ea_new_sw[i]
ENDFOR
free_lun,lout
message,/info,/cont,'The file '+outfile_sw+' has been written.'

openw,lout,outfile_lw,/get_lun
printf,lout,'# EIS effective area data for LW channel'
printf,lout,'# Filename: '+file_basename(outfile_lw)
printf,lout,'# DEM file used: '+file_basename(dem_file)
printf,lout,'# ioneq file used: '+file_basename(ioneq_file)
printf,lout,'# abund file used: '+file_basename(abund_file)
printf,lout,'# Date written: '+systime()
printf,lout,'# Prepared by Peter R. Young'
nw=n_elements(wvl_lw)
FOR i=0,nw-1 DO BEGIN
  printf,lout,format='(f13.3,f13.7)',wvl_lw[i],ea_new_lw[i]
ENDFOR
free_lun,lout
message,/info,/cont,'The file '+outfile_lw+' has been written.'

outfile={ sw: outfile_sw, $
          lw: outfile_lw }

return,outfile

END
