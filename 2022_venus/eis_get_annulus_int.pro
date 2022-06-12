
FUNCTION  eis_get_annulus_int, tt, radius=radius, no_bg=no_bg, pos=pos, map=map, $
                               pix_frac=pix_frac, file=file, int_scale=int_scale, $
                               wvl=wvl, stdev=stdev

;+
; NAME:
;      EIS_GET_ANNULUS_INT
;
; PROJECT:
;      Hinode; EIS; Venus transit.
;
; PURPOSE:
;      Computes an average annulus intensity from EIS slot rasters
;      during the 2012 Venus transit. Does not work with other
;      data-sets!
;
; INPUTS:
;      TT:   A string specifying a time in the format 'HH:MM',
;            corresponding to a time during the Venus transit.
;
; OPTIONAL INPUTS:
;      Radius:  Specifies the outer radius of Venus in arcsec. If not
;               set, then 50 arcsec is used.
;      Pos:  A 2-element array speciying the center of Venus in solar
;            coordinates. If not specified, then the user selects the
;            position manually (by clicking with the mouse).
;      File:  Instead of specifying TT you can directly specify the
;             EIS filename with this keyword.
;      Int_Scale: Array used for scaling the individual exposure
;                 intensities. See eis_slot_map for more details.
;      Wvl:  Specifies the wavelength for which to form the annulus
;            image. If not specified, then 195.12 is assumed.
;
; KEYWORD PARAMETERS:
;      NO_BG:  If set, then no background subtraction is performed
;              with eis_slot_map.pro.
;
; OUTPUTS:
;      Returns the intensity averaged over the annulus.
;
; OPTIONAL OUTPUTS:
;      MAP:  An IDL map containing the annulus image.
;      PIX_FRAC:  A float giving the fraction of pixels in the
;                 returned annulus compared to the maximum possible.
;      STDEV:  Returns the standard deviation of the intensities in
;              the annulus.
;
; MODIFICATION HISTORY:
;      Ver.1, 5-May-2020, Peter Young
;      Ver.2, 18-Feb-2022, Peter Young
;         I've added the /bg48 keyword in call to eis_slot_map,
;         and introduced the /no_bg keyword; also added POS= optional
;         input.
;      Ver.3, 24-Feb-2022, Peter Young
;         Major overhaul; now a function.
;      Ver.4, 28-Feb-2022, Peter Young
;         Added int_scale optional input.
;      Ver.5, 31-May-2022, Peter Young
;         Added wvl= optional input.
;      Ver.6, 12-Jun-2022, Peter Young
;         Added stdev= optional output.
;-

IF n_elements(file) NE 0 THEN BEGIN
  chck=file_search(file,count=count)
  IF count EQ 0 THEN BEGIN
    print,'% EIS_GET_ANNULUS_INT: the specified file was not found. Returning...'
    return,-1
  ENDIF
ENDIF ELSE BEGIN 
  tchck=strmid(tt,0,2)
  IF fix(tchck) GT 12 THEN BEGIN
    tt_full='5-jun-2012 '+tt
  ENDIF ELSE BEGIN
    tt_full='6-jun-2012 '+tt
  ENDELSE 

  file=eis_find_file(tt_full,/lev,count=count,twindow=300.,/backwards)
ENDELSE


IF n_elements(wvl) EQ 0 THEN wvl=195.12

bg48=1b-keyword_set(no_bg)

smap=eis_slot_map(file,wvl,bg48=bg48,int_scale=int_scale,/quiet)

IF n_elements(radius) EQ 0 THEN radius=50.

s=size(smap.data,/dim)
IF n_elements(pos) NE 2 THEN BEGIN 
  plot_image,alog10(smap.data>10)
  cursor,x,y,/data
  x=round(x) & y=round(y)
  xp=float(s[0])/2.*smap.dx
  yp=float(s[1])/2.*smap.dy
  xpos=x*smap.dx + smap.xc-xp
  ypos=y*smap.dy + smap.yc-yp
 ;
  print,format='("Using pixel (",i3,",",i3,") corresponding to position (",f7.1,",",f7.1,")")',x,y,xpos,ypos
ENDIF ELSE BEGIN
  xpos=pos[0]
  ypos=pos[1]
ENDELSE 


v_ix=round( (xpos-smap.xc)/smap.dx ) + round(s[0]/2.)
v_iy=round( (ypos-smap.yc)/smap.dy ) + round(s[1]/2.)
x_arr=findgen(s[0])#(fltarr(s[1])+1.)
y_arr=(fltarr(s[0])+1.)#findgen(s[1])
r_arr=sqrt( (v_ix-x_arr)^2 + (v_iy-y_arr)^2 )
k=where(r_arr GT 30./smap.dx AND r_arr LE radius/smap.dx)

int_ann=average(smap.data[k])
stdev=stdev(smap.data[k])

missing=-100.

k=where(r_arr LE  30./smap.dx OR r_arr GT radius/smap.dx)
smap2=smap
smap2.data[k]=missing

max_pix=round(!pi*(50.^2-30.^2))
k=where(smap2.data NE missing,nk)
pix_frac=float(nk)/float(max_pix) 


map=temporary(smap2)

return,int_ann

END
