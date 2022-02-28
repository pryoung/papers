FUNCTION read_eis_venus_results, quiet=quiet

;+
; NAME:
;     READ_EIS_VENUS_RESULTS
;
; PURPOSE:
;     Reads the text file containing the EIS Venus intensity results. 
;
; CATEGORY:
;     Hinode/EIS; Venus transit; file i/o.
;
; CALLING SEQUENCE:
;     Result = READ_EIS_VENUS_RESULTS( )
;
; INPUTS:
;     None.
;
; OUTPUTS:
;     Returns an IDL structure with the following tags:
;      .time  Observation time.
;      .x     Solar-X position (arcsec).
;      .y     Solar-X position (arcsec).
;      .int_all  The average intensity in center of Venus.
;      .int_dark The dark current intensity.
;      .int   Venus intensity minus dark current. Adjusted for
;             Warren et al. (2014) radiometric calibration.
;      .ann_int  The average intensity in an annulus around
;                Venus. Corrected for dark current. Adjusted for
;                Warren et al. (2014) radiometric calibration.
;
; EXAMPLE:
;     IDL> data=read_eis_venus_results()
;
; MODIFICATION HISTORY:
;     Ver.1, 07-Oct-2020, Peter Young
;     Ver.2, 17-Aug-2021, Peter Young
;        Now removes dark current from annulus intensity; Warren et
;        al. (2014) is applied to the intensities.
;     Ver.3, 28-Feb-2022, Peter Young
;        I switched to using eis_venus_select to get the Venus
;        intensities, and so this routine reads these results.
;-


openr,lin,'eis_venus_new_results.txt',/get_lun

str={time: '', x: 0., y: 0., int_all: 0., int_dark: 0., ann_int: 0., ann_frac: 0. }
junk=temporary(data)


calib_factor=eis_recalibrate_intensity('5-Jun-2012 23:00',195.12,1)

WHILE eof(lin) NE 1 DO BEGIN
   readf,lin,format='(a8,2f6.0,4f7.0)',str
  ;
   IF n_tags(data) EQ 0 THEN data=str ELSE data=[data,str]
ENDWHILE 

free_lun,lin


;IF NOT keyword_set(quiet) THEN print,'% READ_EIS_VENUS_RESULTS: removed dark current from annulus intensity.'
;IF NOT keyword_set(quiet) THEN print,'% READ_EIS_VENUS_RESULTS: corrected intensites with Warren et al. (2014) calibration.'


n=n_elements(data)
FOR i=0,n-1 DO BEGIN
  chck=fix(strmid(data[i].time,0,2))
  IF chck GE 12 THEN data[i].time='5-jun-2012 '+data[i].time ELSE data[i].time='6-jun-2012 '+data[i].time
ENDFOR 


str2={time: '', x: 0., y: 0., int_venus: 0., int_ann: 0., ann_frac: 0. }
output=replicate(str2,n)
output.time=data.time
output.x=data.x
output.y=data.y
output.ann_frac=data.ann_frac
output.int_venus=(data.int_all-data.int_dark)*calib_factor
output.int_ann=data.ann_int*calib_factor


return,output

END
