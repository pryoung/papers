
FUNCTION aia_get_venus_coords, input_time, plot=plot


;+
; NAME:
;     AIA_GET_VENUS_COORDS
;
; PURPOSE:
;     Returns accurate coordinates of Venus during the 2012 transit with
;     respect to AIA images.
;
; CATEGORY:
;     Venus; transit; AIA; coordinates.
;
; CALLING SEQUENCE:
;     Result = AIA_GET_VENUS_COORDS( Time )
;
; INPUTS:
;     Input_Time:  String giving the time for which coordinates are
;                  required. Must be a standard SSW format.
;
; OUTPUTS:
;     A 2-element array giving the [x,y] coordinates of Venus.
;
; EXAMPLE:
;     IDL> xy=aia_get_venus_coords('6-jun-2012 02:13')
;
; MODIFICATION HISTORY:
;     Ver.1, 07-Jun-2024, Peter Young
;     Ver.2, 28-Jun-2024, Peter Young
;       Now checks $VENUS_TRANSIT for location of coordinate file.
;-


venus_dir=getenv('VENUS_TRANSIT')
IF venus_dir EQ '' THEN venus_dir='.'

;
; This file was created with the Python routine venus_coords.py and
; must be in the current working directory.
;
coord_file='venus_coords.txt'
coord_file=concat_dir(venus_dir,coord_file)
chck=file_info(coord_file)
IF chck.exists EQ 0 THEN BEGIN
  message,/info,/cont,'The Venus coordinate file was not found. You should point to the location of the file with the environment variable $VENUS_TRANSIT (e.g., in your idl_startup file), or put the coordinate file in your working directory.'
  return,-1
ENDIF ELSE BEGIN 
  openr,lin,coord_file,/get_lun
ENDELSE 

str={time: '', x: 0., y: 0.}

junk=temporary(data)

WHILE eof(lin) NE 1 DO BEGIN
  readf,lin,format='(a20,2f10.0)',str
  IF n_tags(data) EQ 0 THEN data=str ELSE data=[data,str]
ENDWHILE 

free_lun,lin


t_tai=anytim2tai(data.time)
t_min=(t_tai-t_tai[0])/60.

input_t_tai=anytim2tai(input_time)
input_t_min=(input_t_tai-t_tai[0])/60.

y2=spl_init(t_min,data.x)
xi=spl_interp(t_min,data.x,y2,input_t_min)

y2=spl_init(t_min,data.y)
yi=spl_interp(t_min,data.y,y2,input_t_min)


IF keyword_set(plot) THEN BEGIN
  plot,data.x,data.y,xsty=3,ysty=3, $
       xtitle='Solar-x', ytitle='Solar-y', $
       charsiz=2
  plots,xi,yi,psym=1,symsize=3
ENDIF 

return,[xi,yi]

END
