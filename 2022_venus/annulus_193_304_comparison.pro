

FUNCTION annulus_193_304_comparison

;+
; Here I take an annulus and convolve it with the 193 PSF to see what
; the scattered light is inside the annulus.
;
; Returns an IDL structure with the results.
;
; Ver.1, 08-Jul-2022, Peter Young
;-


arr=fltarr(4096,4096)
x_arr=fltarr(4096,4096)
FOR i=0,4095 DO x_arr[*,i]=findgen(4096)-2048
y_arr=fltarr(4096,4096)
FOR i=0,4095 DO y_arr[i,*]=findgen(4096)-2048

r_arr=sqrt(x_arr^2 + y_arr^2)
sub_r_arr=r_arr[2048-300:2048+300,2048-300:2048+300]

file193='psf_193.save'
chck=file_info(file193)
IF chck.exists EQ 0 THEN BEGIN
  psf=aia_calc_psf(193)
  save,file='psf_193.save',psf
ENDIF ELSE BEGIN 
  restore,file193
ENDELSE 

kernel=psf[2048-100:2048+100,2048-100:2048+100]
kernel=kernel/total(kernel)

k=where(r_arr GE 30/0.6 AND r_arr LE 50./0.6)
arr[k]=1.0

sub_arr=arr[2048-300:2048+300,2048-300:2048+300]
d193=convol(sub_arr,kernel)
k=where(sub_r_arr LE 5./0.6)
av_193_int=average(d193[k])
print,format='(" Average 193 int within 5 arcsec: ",f8.4)',av_193_int

;------
file304='psf_304.save'
chck=file_info(file304)
IF chck.exists EQ 0 THEN BEGIN
  psf=aia_calc_psf(304)
  save,file='psf_304.save',psf
ENDIF ELSE BEGIN 
  restore,file304
ENDELSE 


kernel=psf[2048-100:2048+100,2048-100:2048+100]
kernel=kernel/total(kernel)

k=where(r_arr GE 30/0.6 AND r_arr LE 50./0.6)
arr[k]=1.0

sub_arr=arr[2048-300:2048+300,2048-300:2048+300]
d304=convol(sub_arr,kernel)
k=where(sub_r_arr LE 5./0.6)
av_304_int=average(d304[k])
print,format='(" Average 304 int within 5 arcsec: ",f8.4)',av_304_int

print,format='(" 304/193 ratio: ",f7.2)',av_304_int/av_193_int

output={radius: r_arr[2048-300:2048+300,2048-300:2048+300], $
        d193: d193, $
        d304: d304 }

return,output

END
