
FUNCTION sg_read_avg_int, filename

;+
; NAME:
;     SG_READ_AVG_INT
;
; PURPOSE:
;     Reads the "average intensity" file produced by spec_gauss_widget.
;     This file can be created when giving the /continuum option to
;     spec_gauss_widget.
;
; CATEGORY:
;     Spectrum; intensity measurement.
;
; CALLING SEQUENCE:
;     Result = SG_READ_AVG_INT( Filename )
;
; INPUTS:
;     Filename:  The name of a file containing the average intensities
;                produced by spec_gauss_widget.
;
; OUTPUTS:
;     An IDL structure with the following tags:
;      .wvl  Wavelength.
;      .int  Intensity.
;      .err  Intensity error.
;      .stdev  Standard deviation of intensity values in region.
;      .npix Number of wavelength pixels averaged to give the int value.
;      .time_stamp  Time at which structure was created.
;
; EXAMPLE:
;     IDL> spec_gauss_widget,xx,yy,ee,/continuum
;     IDL> output=sg_read_avg_int('average_intensity.txt')
;
; MODIFICATION HISTORY:
;     Ver.1, 25-Nov-2025, Peter Young
;-

chck=file_info(filename)
IF chck.exists EQ 0 THEN BEGIN
  message,/info,/cont,'The specified file does not exist. Returning...'
  return,-1
ENDIF

str={wvl: 0., $
     int: 0., $
     err: 0., $
     stdev: 0., $
     npix: 0, $
     time_stamp: '' }
junk=temporary(output)

openr,lin,filename,/get_lun

WHILE eof(lin) NE 1 DO BEGIN 
  readf,lin,format='(f12.0,3e12.0,i7,a21)',str
  IF n_tags(output) EQ 0 THEN output=str ELSE output=[output,str]
ENDWHILE 

free_lun,lin

;
; Put entries in ascending wavelength order.
;
k=sort(output.wvl)
output=output[k]

return,output

END

