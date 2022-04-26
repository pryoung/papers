
function aia_get_venus, quick=quick, data=data, sub_arcsec=sub_arcsec, psf=psf, radius=radius, $
                        show_annulus=show_annulus, next=next, previous=previous, $
                        inner_radius=inner_radius

;+
; NAME:
;     AIA_GET_VENUS
;
; PURPOSE:
;     Goes through the list of AIA 193 images and allows the user to
;     choose the center of Venus. The routine returns the average
;     intensity at the center of Venus.
;
; CATEGORY:
;     SDO/AIA; Venus transit.
;
; CALLING SEQUENCE:
;     Result = AIA_GET_VENUS()
;
; INPUTS:
;     None.
;
; OPTIONAL INPUTS:
;     Data:   This is the structure from a previous call to
;             AIA_GET_VENUS. It is used to set the position of Venus
;             without the user having to manually select it
;             again. This is useful in conjunction with the /psf
;             keyword so that the routine uses exactly the same
;             positions. 
;     Sub_Arcsec: By default, the sub-map is set to +/- 200 arcsec
;             around the center of Venus. This keyword allows the size
;             to be modified.
;     Radius: Sets the outer radius of the annulus. Default is 50
;             arcsec.
;     Inner_Radius: This sets the inner radius. The default is 30
;                   arcsec (corresponding to radius of Venus).
;	
; KEYWORD PARAMETERS:
;     QUICK:  Only processes three frames. Used for testing.
;     PSF:    Use the deconvolved images in the aia/level16
;             directory.
;     SHOW_ANNULUS: If set, then after the Venus position is selected
;                   an image showing only the annulus region will be
;                   displayed briefly.
;     NEXT:   (Only applies if DATA has been input.) The routine uses
;             the Venus position from DATA, but applies it to the next
;             AIA image frame. This is used for testing the
;             inner_radius input.
;     PREVIOUS: (Only applies if DATA has been input.) The routine uses
;             the Venus position from DATA, but applies it to the previous
;             AIA image frame. This is used for testing the
;             inner_radius input.
;
; OUTPUTS:
;     Creates a structure array containing information about the
;     transit. The tags are: 
;       .time  Time of image.
;       .int   The Venus intensity.
;       .x     The X-position of the Venus center (arcsec).
;       .y     The Y-position of the Venus center (arcsec).
;       .r     The radial position of Venus (arcsec).
;       .dark_left The dark intensity from the top-left corner of the
;               AIA image.
;       .dark_right The dark intensity from the top-right corner of the
;               AIA image.
;       .full_disk_int The full disk average intensity.
;       .full_disk_npix No. of pixel used to compute the average full
;               disk intensity.
;       .sub_map_int  The average intensity of the annulus region
;               around Venus.
;
; RESTRICTIONS:
;     Takes images from the sub-directory 'aia'.
;
; EXAMPLES:
;     IDL> d050=aia_get_venus()
;     IDL> d100=aia_get_venus(radius=100.)
;     IDL> d050psf=aia_get_venus(/psf,data=d050)
;
;     IDL> d010=aia_get_venus(data=d050,/previous,inner_radius=10)
;
; MODIFICATION HISTORY:
;     Ver.1, 27-Feb-2020, Peter Young
;     Ver.2, 04-Mar-2020, Peter Young
;       Now computes sub map intensity from an annulus around Venus.
;     Ver.3, 06-Aug-2021, Peter Young
;       Added /silent in call to read_sdo; small updates to header.
;     Ver.4, 07-Mar-2022, Peter Young
;       Introduced /previous, /next and inner_radius= (used to
;       investigate effect of reducing the inner radius of the
;       annulus). 
;-



IF (keyword_set(previous) OR keyword_set(next)) AND n_tags(data) EQ 0 THEN BEGIN
  print,'% AIA_GET_VENUS: If /previous or /next are set, then DATA must be supplied. Returning...'
  return,-1
ENDIF 

IF keyword_set(psf) THEN BEGIN
  list=file_search('aia/level16','AIA*.fits',count=count)
ENDIF ELSE BEGIN 
  list=file_search('aia','aia.*.fits',count=count)
ENDELSE 


IF count EQ 0 THEN BEGIN
  message,'No AIA files were found in the /aia sub-directory. Please download the files from JSOC or VSO. The files needed are listed in the README file.',/CONTINUE,/info
  return,-1
ENDIF


IF n_elements(radius) EQ 0 THEN radius=50.

IF n_elements(inner_radius) EQ 0 THEN inner_radius=30.

IF keyword_set(quick) THEN BEGIN
  list=list[[0,count/2,count-1]]
  count=3
ENDIF

IF n_elements(sub_arcsec) EQ 0 THEN sub_arcsec=200.

x0=-1017
y0=691
x1=1082
y1=442

;
; For some reason, reading list in one call to read_sdo does not work,
; so I have to use a for loop.
;
list_tai=dblarr(count)
FOR i=0,count-1 DO BEGIN 
  read_sdo,list[i],index,/use_shared_lib,/silent
  list_tai[i]=anytim2tai(index.t_obs)
ENDFOR 
t0_tai=list_tai[0]
t1_tai=list_tai[-1]
dt_tai=t1_tai-t0_tai

;
; If DATA exists then set the output to be DATA. The only tag that
; will end up different will be sub_map_int.
; 
IF n_tags(data) NE 0 THEN BEGIN
  n=n_elements(data)
  data_files=strarr(n)

  data_tai=anytim2tai(data.time)
  FOR i=0,n-1 DO BEGIN
    getmin=min(abs(data_tai[i]-list_tai),imin)
    IF getmin GT 20 THEN BEGIN
      print,'% AIA_GET_VENUS: Problem - one of the entries in DATA does not match to an AIA image. Please check your inputs. Returning...'
      print,data[i].time,getmin
      return,-1
    ENDIF ELSE BEGIN
      data_files[i]=list[imin]
    ENDELSE
    count=n
  ENDFOR 
  
  output=data
ENDIF ELSE BEGIN 
  str={time: '', $
       int: 0., $
       x: 0., $
       y: 0., $
       r: 0., $
       dark_left: 0., $
       dark_right: 0., $
       full_disk_int: 0., $
       full_disk_npix: 0l, $
       sub_map_int: 0.}
  output=replicate(str,count)
  data_files=list
ENDELSE 

nb=16

i0=0
i1=count-1
IF keyword_set(previous) THEN BEGIN
  data_files=['',data_files[0:-2]]
  output[0].sub_map_int=0.
  i0=1
ENDIF
IF keyword_set(next) THEN BEGIN
  data_files=[data_files[1:*],'']
  output[-1].sub_map_int=0.
  i1=i1-1
ENDIF 

FOR i=i0,i1 DO BEGIN
  map=sdo2map(data_files[i])
 ;
  aia_average_full_disk,map,output=fd_data,radius=1.05,/quiet
  output[i].full_disk_int=fd_data.int
  output[i].full_disk_npix=fd_data.npix
 ;
  output[i].dark_left=median(map.data[0:99,3996:4095])
  output[i].dark_right=median(map.data[3996:4095,3996:4095])
 ;
  IF n_tags(data) NE 0 THEN BEGIN
    xpos=data[i].x
    ypos=data[i].y
  ENDIF ELSE BEGIN
    t_tai=anytim2tai(map.time)
    xpos=(x1-x0)*(t_tai-t0_tai)/dt_tai + x0
    ypos=(y1-y0)*(t_tai-t0_tai)/dt_tai + y0
  ENDELSE 
 ;
 ; Get sub-map (smap) that is approximately centered on Venus.
 ;
  sub_map,map,smap,xrange=xpos+[-sub_arcsec,sub_arcsec],yrange=ypos+[-sub_arcsec,sub_arcsec]
 ;
  IF n_tags(data) EQ 0 THEN BEGIN
   ;
   ; The center of Venus is manually selected by the user.
   ;
    plot_image,alog10(smap.data>10), $
               title=trim(i+1)+'/'+trim(count)+', '+ $
               anytim2utc(map.time,/ccsds,/time,/trunc)
    cursor,x,y,/data
    x=round(x) & y=round(y)
    oplot,[x-nb,x+nb,x+nb,x-nb,x-nb],[y-nb,y-nb,y+nb,y+nb,y-nb]
    oplot,x+[-30,30]/0.6,y*[1,1]
    oplot,x*[1,1],y+[-30,30]/0.6
    output[i].int=mean(smap.data[x-nb:x+nb,y-nb:y+nb])
    output[i].time=map.time
    s=size(smap.data,/dim)
    xp=float(s[0])/2.*smap.dx
    yp=float(s[1])/2.*smap.dy
    output[i].x=x*smap.dx + smap.xc-xp
    output[i].y=y*smap.dy + smap.yc-yp
    output[i].r=sqrt(output[i].x^2 + output[i].y^2)
    xpos=output[i].x
    ypos=output[i].y
 ENDIF ELSE BEGIN
   ;
   ; If DATA specified, then create a sub-map (sub_smap) to extract
   ; Venus intensity.
   ;
    plot_map,smap,/log,dmin=10
    oplot,xpos+[-nb,nb,nb,-nb,-nb]*0.6,ypos+[-nb,-nb,nb,nb,-nb]*0.6
    oplot,xpos+[-30,30],ypos*[1,1]
    oplot,xpos*[1,1],ypos+[-30,30]
    sub_map,smap,sub_smap,xrange=xpos+[-nb,nb]*0.6,yrange=ypos+[-nb,nb]*0.6
    output[i].int=mean(sub_smap.data)
  ENDELSE
 ;
  output[i].sub_map_int=average(smap.data)
 ;
  s=size(smap.data,/dim)
  v_ix=round( (xpos-smap.xc)/smap.dx ) + round(s[0]/2.)
  v_iy=round( (ypos-smap.yc)/smap.dy ) + round(s[1]/2.)
  x_arr=findgen(s[0])#(fltarr(s[1])+1.)
  y_arr=(fltarr(s[0])+1.)#findgen(s[1])
  r_arr=sqrt( (v_ix-x_arr)^2 + (v_iy-y_arr)^2 )
  k=where(r_arr GT inner_radius/0.6 AND r_arr LE radius/0.6)
  output[i].sub_map_int=average(smap.data[k])
 ;
  IF keyword_set(show_annulus) THEN BEGIN 
    k=where(r_arr LE  inner_radius/0.6 OR r_arr GT radius/0.6)
    smap2=smap
    smap2.data[k]=0.
    plot_map,smap2,title='Annulus map'
  ENDIF 
ENDFOR

return,output

END
