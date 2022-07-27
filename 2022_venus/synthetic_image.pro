
FUNCTION synthetic_image, size=size, no_ar=no_ar, ang_range=ang_range, rcen=rcen

;+
;    Size:  The size of the array. Should be an odd number,
;           e.g., 601. Default is 801.
;    No_Ar: If set, then the image will not contain the active
;           region.
;    Rcen:  Radius corresponding to center of active region.
;           Default is 100 arcsec.
;    Ang_Range:  The angular extent of active region in
;                radians. Default is [0,!pi/2].
;-

int_qs=123.
int_ar=1651.

IF n_elements(size) EQ 0 THEN d=801 ELSE d=size
d2=(d-1)/2

IF n_elements(rcen) EQ 0 THEN rcen=100.

IF n_elements(ang_range) EQ 0 THEN ang_range=[0,!pi/2.]

image=make_array(d,d,value=int_qs)

x=(findgen(d)-d2)*0.6
xx=fltarr(d,d)
FOR i=0,d-1 DO xx[*,i]=x


y=(findgen(d)-d2)*0.6
yy=fltarr(d,d)
FOR i=0,d-1 DO yy[i,*]=y

r=sqrt(xx^2+yy^2)
ang=atan(yy,xx)

k=where(r LT 30.)
image[k]=0.


IF NOT keyword_set(no_ar) THEN BEGIN 
  k=where(ang GE ang_range[0] AND ang LT ang_range[1] AND r GE rcen-25. AND r LE rcen+25.)
  image[k]=int_ar
ENDIF 

return,image


END
