
PRO write_chianti_dem, data, dem_file, overwrite=overwrite

;+
; NAME:
;     WRITE_CHIANTI_DEM
;
; PURPOSE:
;     Given the DEM output from the ch_dem suite of routines, this routine
;     writes the DEM to CHIANTI format DEM file.
;
; CATEGORY:
;     CHIANTI; DEM.
;
; CALLING SEQUENCE:
;     WRITE_CHIANTI_DEM, Data, Dem_File
;
; INPUTS:
;     Data:  An IDL structure in the format returned by the ch_dem routines
;            (e.g., ch_dem_mcmc).
;     Dem_File: A string giving the name of the DEM output file.
;
; KEYWORD PARAMETERS:
;     OVERWRITE: If the DEM file already exists, then it will not be
;                overwritten unless this keyword is set.
;
; OUTPUTS:
;     The file DEM_FILE is created containing the logarithm (base 10) of
;     the DEM, tabulated as a function of the logarithm of the temperature.
;     The file is suitable as input to CHIANTI 
;
; EXAMPLE:
;     IDL> write_chianti_dem, output, 'flare_20240930.dem'
;
; MODIFICATION HISTORY:
;     Ver.1, 24-Nov-2025, Peter Young
;-


chck=file_info(dem_file)
IF chck.exists EQ 1 AND NOT keyword_set(overwrite) THEN BEGIN
  message,/info,/cont,'The DEM file already exists. Please use /overwrite to overwrite the file. Returning...'
  return
ENDIF 

IF dem_file.endswith('.dem') EQ 0 THEN BEGIN
  message,/info,/cont,'The output DEM filename should end with ".dem". Please modify your input. Returning...'
  return
ENDIF 

openw,lout,dem_file,/get_lun

k=where(data.dem GE 1e15,nk)
ltemp=data.ltemp[k]
ldem=alog10(data.dem[k])

n=n_elements(ltemp)
FOR i=0,n-1 DO BEGIN
  printf,lout,format='(f7.3,f10.3)',ltemp[i],ldem[i]
ENDFOR

printf,lout,' -1'
printf,lout,'%filename: '+file_basename(dem_file)
printf,lout,'%ch_dem method: '+data.method.toupper()
printf,lout,'%data generated on: '+data.time_stamp
printf,lout,'%this file written on: '+systime()
IF data.interr_scale NE -1. THEN printf,lout,'%interr_scale: '+trim(string(format='(f7.2)',data.interr_scale))
IF data.log_press NE -1. THEN printf,lout,'%log_press: '+trim(string(format='(f7.2)',data.log_press))
IF data.log_dens NE -1. THEN printf,lout,'%log_dens: '+trim(string(format='(f7.2)',data.log_dens))
printf,lout,'%comment:'
printf,lout,'  This DEM was generated with the ch_dem suite of DEM routines.'
printf,lout,' -1'

free_lun,lout

message,/info,/cont,'The file '+dem_file+' has been written.'

END
