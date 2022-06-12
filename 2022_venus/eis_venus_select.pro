

FUNCTION eis_venus_select, tt, file=file, int_scale=int_scale, wvl=wvl, $
                           outfile=outfile, pos=pos

;+
; NAME:
;     EIS_VENUS_SELECT
;
; PURPOSE:
;     Derives intensities in the Fe XII 195.12 line for the Venus
;     shadow and a surrounding annulus.
;
; CATEGORY:
;     Hinode; EIS; Venus transit.
;
; CALLING SEQUENCE:
;     Result = EIS_VENUS_SELECT( Tt )
;
; INPUTS:
;     Tt:  A string of the form 'HH:MM' specifying a time during the
;          transit period. This is used to identify an EIS
;          file. (Alternatively see the FILE= optional input.)
;
; OPTIONAL INPUTS:
;     File:  A string that directly specifies the EIS file to be used.
;     Wvl:   An EIS wavelength (angstroms) to process. Default is
;            195.12.
;     OutFile: The name of a file to send the results to. If not set,
;              then 'eis_venus_new_results.txt' in the working
;              directory is used.
;     Pos:   Two-element array specifying (x,y) position of Venus.
;            Useful if you've already run the routine on the file and
;            want to use exactly the same position.
;	
; OUTPUTS:
;     Prints the results to a file called 'eis_venus_new_results.txt'
;     in the working directory. If the file already exists, then the
;     results are appended. An alternative filename can be specified
;     with OUTFILE=. 
;
; PROCEDURE:
;     The routine opens an IDL graphics window that will show four
;     plots:
;      1. The slot raster image in Fe XII 195.12. Click with the mouse
;      on the approximate center of the Venus shadow (this is used to
;      select the exposure that contains most of the Venus shadow and
;      the position does not need to be precise).
;      2. A close-up of Venus using the selected exposure. You should
;      carefully select the center of the Venus shadow with the mouse.
;      3. A repeat of panel (1) but now showing the "accurate" center
;      of Venus.
;      4. Another repeat of panel (1) but showing only the annulus
;      around Venus. You should check to make sure that the Venus
;      shadow is not extending into the annulus.
;
; MODIFICATION HISTORY:
;     Ver.2, 31-May-2022, Peter Young
;       Added wvl= and outfile= optional inputs; modified display for
;       panel 1 when signal low.
;     Ver.3, 12-Jun-2022, Peter Young
;       Now computes the standard deviations of the Venus, background
;       and annulus intensities and puts them in the output structure;
;       added POS= optional input.
;-


IF n_elements(file) NE 0 THEN BEGIN
  chck=file_search(file,count=count)
  IF count EQ 0 THEN BEGIN
    print,'% EIS_VENUS_SELECT: the specified file was not found. Returning...'
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

  IF count EQ 0 THEN BEGIN
    print,'** no level-1 file found. Returning... **'
    return,-1
  ENDIF
ENDELSE 


IF n_elements(wvl) EQ 0 THEN wvl=195.12

wd=eis_getwindata(file,wvl)
IF wd.hdr.slit_ind NE 3 THEN BEGIN
  print,'% EIS_VENUS_SELECT:  this routine can only be used for 40" slot data. Returning...'
  return,-1
ENDIF 

!p.multi=[0,4,1]
!p.charsize=2.0

aia_lct,r,g,b,wavel=193,/load

;
; Panel (1)
; ---------
; Create and plot the slot map in 195 line. Note that a background
; level is subtracted from the map (/bg48).
;
map=eis_slot_map(file,wvl,/bg48,/quiet)
s=sigrange(map.data,range=r)
plot_map,map,/log,dmin=max([r[0],5]),dmax=r[1]
map2range,map,xrange=xrange,yrange=yrange

;
; TRIM is a 2-element array that specifies the pixel boundaries used
; to "trim" the wavelength window in order to create the map. For a
; 48-pixel window, for example, one may have trim=[4,43]. 
;
trim=map.trim
dx_pix=trim[1]-trim[0]+1


nexp=wd.hdr.nexp
ny=wd.ny

s=size(map.data,/dim)
nx=s[0]
x_arr=findgen(nx)+xrange[0]

;
; User selects the approximate position of Venus in the first panel. 
;
IF n_elements(pos) EQ 0 THEN BEGIN 
  cursor,x,y,/data,/down
  IF x LT xrange[0] OR x GT xrange[1] OR y LT yrange[0] OR y GT yrange[1] THEN return,-1
ENDIF ELSE BEGIN
  x=pos[0]
  y=pos[1]
ENDELSE 
plots,x,y,psym=1,symsize=3

;
; Work out in which exposure Venus is located [imin].
;
dx=(xrange[1]-xrange[0])/nexp
midx=findgen(nexp)*dx+dx/2.+xrange[0]
getmin=min(abs(midx-x),imin)



;
; Get time of exposure
;
t_venus_tai=anytim2tai(wd.time_ccsds[imin])+wd.exposure_time[imin]/2.
t_venus=anytim2utc(/ccsds,t_venus_tai)

;
; Dotted lines are plotted to indicate which exposure has been
; selected by the user.
;
oplot,(xrange[0]+dx*imin)*[1,1],yrange,line=1
oplot,(xrange[0]+dx*(imin+1))*[1,1],yrange,line=1

;
; Note that the exposures within the windata structure are reversed in
; the X-direction compared to the real solar image.
;
img=reform(wd.int[*,imin,*])
img=reverse(img,1)

;
; Get y-pixel (iy) of center of Venus in WD array, using
; previously-selected Venus location [x,y].
;
y_arr=findgen(ny)+yrange[0]
getmin=min(abs(y_arr-y),iy)


;
; Panel (2)
; ---------
; Plot close-up of Venus in pixel coordinates.
;
img=img[*,iy-40:iy+40]
s_img=size(img,/dim)
iy0=iy-40
plot_image,img

;
; User selects the center of Venus from a close-up of Venus. Note that
; [x,y] are in pixel coordinates.
;
IF n_elements(pos) EQ 0 THEN BEGIN 
  cursor,x,y,/data,/down
  ix=round(x) & iy=round(y)
ENDIF ELSE BEGIN
  getmin=min(abs(pos[0]-x_arr),xpix)
  ix=xpix+(wd.nl-1-trim[1])-imin*dx_pix
  iy=40
ENDELSE


IF ix LT 0 OR ix GE s_img[0] OR iy LT 0 OR iy GE s_img[1] THEN BEGIN
  print,'% EIS_VENUS_SELECT: Clicked outside of image. Exiting...'
  return,-1
ENDIF 

plots,ix,iy,symsize=60,psym=1
x0=ix-10 & x1=ix+10
y0=iy-10 & y1=iy+10
oplot,[x0,x1,x1,x0,x0],[y0,y0,y1,y1,y0]

IF x0 LT 0 OR x1 GE s_img[0] OR y0 LT 0 OR y1 GE s_img[1] THEN BEGIN
  print,'% EIS_VENUS_SELECT: The Venus box lies outside of the image range. Exiting...'
  return,-1
ENDIF 


;
; Now go back to the map coordinates to get the new position of
; Venus. The x-position is a little tricky as you need to account for
; the reversal of the windata window and the trim value.
;
ypos=y_arr[iy+iy0]
;
xpix=ix-(wd.nl-1-trim[1])+imin*dx_pix
xpos=x_arr[xpix]

;
; Panel (3)
; ---------
; Plot the whole map again, with the new (accurate) Venus positionn
; over-plotted. 
;
plot_map,map,/log,dmin=r[0],dmax=r[1]
plots,xpos,ypos,psym=1,symsize=3

;
; To compute the background intensity, I have to go back to the wd.int
; array and select column 0. Note that iy0 needs to be specified.
;
simg=size(img,/dim)
IF x0 LT 0 OR x1 GE simg[0] THEN BEGIN
  print,'% EIS_VENUS_SELECT: the Venus box lies outside the image range. Returning...'
  !p.multi=0
  return,-1
ENDIF 
venus_int=mean(img[x0:x1,y0:y1])
venus_int_stdev=stdev(img[x0:x1,y0:y1])
venus_bg=mean(wd.int[0,imin,iy0+y0:iy0+y1])
venus_bg_stdev=stdev(wd.int[0,imin,iy0+y0:iy0+y1])


;
; Get the annulus intensity
;
int_ann=eis_get_annulus_int(tt,pos=[xpos,ypos],map=ann_map,pix_frac=pix_frac,file=file, $
                           int_scale=int_scale, wvl=wvl,stdev=int_ann_stdev)

;
; Panel (4)
; ---------
; Plot the annulus map.
;
plot_map,ann_map


!p.charsize=1.0
!p.multi=0

;
; Open the results file and check if we need to append.
;
IF n_elements(outfile) EQ 0 THEN outfile='eis_venus_new_results.txt'
chck=file_search(outfile,count=count)
IF count EQ 1 THEN BEGIN
  openu,lun,outfile,/get_lun,/append
ENDIF ELSE BEGIN
  openw,lun,outfile,/get_lun
ENDELSE 

t_venus_short=anytim2utc(t_venus,/ccsds,/time,/trunc)

;out_string=string(format='(a8,2i6,3f7.1,f7.3)',t_venus_short,round(xpos),round(ypos), $
;                  venus_int,venus_bg,int_ann,pix_frac)
out_string=string(format='(a8,2i6,3(f7.1," +/-",f7.1),f7.3)',t_venus_short, $
                  round(xpos),round(ypos), $
                  venus_int,venus_int_stdev, $
                  venus_bg,venus_bg_stdev, $
                  int_ann,int_ann_stdev,pix_frac)

printf,lun,out_string
print,out_string

free_lun,lun

print,'** Results sent to '+outfile+' **'

return,-1

END
