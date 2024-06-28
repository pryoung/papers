
function aia_get_venus, quick=quick, data=data, sub_arcsec=sub_arcsec, psf=psf, radius=radius, $
                        show_annulus=show_annulus, next=next, previous=previous, $
                        inner_radius=inner_radius, aia_dir=aia_dir, $
                        ct_number=ct_number, dmax=dmax, circle=circle

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
;     Aia_Dir: By default the routine looks for AIA FITS files in the
;              sub-directory 'aia'. By setting this input you can
;              directly specify the AIA directory. For example,
;              aia_dir='~/aia_335'
;     Dmax:   Specifies the maximum value to display for the images
;             (useful for picking out Venus in dark regions).
;     CT_Number:  IDL color table number to use for plotting.
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
;       .int_stdev  Standard deviation of Venus intensities.
;       .x     The X-position of the Venus center (arcsec).
;       .y     The Y-position of the Venus center (arcsec).
;       .r     The radial position of Venus (arcsec).
;       .dark_left The dark intensity from the top-left corner of the
;               AIA image.
;       .dark_right The dark intensity from the top-right corner of the
;               AIA image.
;       .dark_stdev  Standard deviation of dark region.
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
;     Ver.5, 29-Jun-2022, Peter Young
;       Added calculation of int_stdev and dark_stdev, which have
;       been added to output structure.
;     Ver.6, 25-May-2023, Peter Young
;       Fixed bug whereby data_files wasn't defined if data didn't
;       exist.
;     Ver.7, 17-Oct-2023, Peter Young
;       Adjusted how the initial estimate of the Venus position is
;       made so that it works with any set of images; increased
;       font size of graphic and updated the title.
;     Ver.8, 14-Nov-2023, Peter Young
;       Now adjusts image scaling for AIA channels with a low intensity
;       (e.g., 131) ; also sets a color table (no. 3 for high intensity
;       channels, and no. 5 for low intensity channels).
;     Ver.9, 07-Feb-20224, Peter Young
;       Added optional input aia_dir=.
;     Ver.10, 15-May-2024, Peter Young
;       Added ct_number= and dmax= optional inputs to give greater
;       control over the plotted images.
;     Ver.11, 17-Jun-2024, Peter Young
;       Now uses accurate Venus positions to automatically identify Venus
;       location (no need for manual input; added /circle option so Venus
;       intensity is obtained from a circular region rather than a square
;       (area is same size as square).
;-



IF (keyword_set(previous) OR keyword_set(next)) AND n_tags(data) EQ 0 THEN BEGIN
  print,'% AIA_GET_VENUS: If /previous or /next are set, then DATA must be supplied. Returning...'
  return,-1
ENDIF 

IF n_elements(aia_dir) EQ 0 THEN aia_dir='aia'

IF keyword_set(psf) THEN BEGIN
  list=file_search(concat_dir(aia_dir,'level16'),'AIA*.fits',count=count)
ENDIF ELSE BEGIN 
  list=file_search(aia_dir,'aia*.fits',count=count)
ENDELSE 


IF count EQ 0 THEN BEGIN
  message,'No AIA files were found in the AIA sub-directory. Please download the files from JSOC or VSO. The files needed are listed in the README file.',/CONTINUE,/info
  return,-1
ENDIF


IF n_elements(radius) EQ 0 THEN radius=50.

IF n_elements(inner_radius) EQ 0 THEN inner_radius=30.

IF keyword_set(quick) THEN BEGIN
  list=list[[0,count/2,count-1]]
  count=3
ENDIF

IF n_elements(sub_arcsec) EQ 0 THEN sub_arcsec=120.

;
; These give the coordinates of Venus at a reference time. These are
; used to give an initial guess for the position of Venus.
;
t0='5-jun-2012 21:00:07'
t0_tai=anytim2tai(t0)
x0=-1017
y0=691
;
t1='6-jun-2012 05:40:07'
t1_tai=anytim2tai(t1)
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
;; t0_tai=list_tai[0]
;; t1_tai=list_tai[-1]
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
ENDIF ELSE BEGIN
  data_files=list
ENDELSE 

str={time: '', $
     int: 0., $
     int_stdev: 0., $
     x: 0., $
     y: 0., $
     r: 0., $
     dark_left: 0., $
     dark_right: 0., $
     dark_stdev: 0., $
     full_disk_int: 0., $
     full_disk_npix: 0l, $
     sub_map_int: 0.}
output=replicate(str,count)

IF n_tags(data) NE 0 THEN BEGIN
  output.time=data.time
  output.x=data.x
ENDIF 

;
; The box over which the Venus intensity is averaged has an area
; (2*nb+1)^2 pixels, which corresponds to 20x20 arcsec^2.
;
; For the /circle option, I set the radius of the circle to give
; the same area as for the square option.
;
; Actually I'm increasing circ_pix_radius to 25 to improve
; statistics for low signal channels.
;
nb=16
circ_pix_radius=(2*float(nb)+1)/sqrt(!pi)
;circ_pix_radius=25.0

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
  xy=aia_get_venus_coords(map.time)
  IF n_elements(xy) EQ 2 THEN coord_swtch=1b
 ;
  aia_average_full_disk,map,output=fd_data,radius=1.05,/quiet
  output[i].full_disk_int=fd_data.int
  output[i].full_disk_npix=fd_data.npix
 ;
  output[i].dark_left=median(map.data[0:99,3996:4095])
  output[i].dark_right=median(map.data[3996:4095,3996:4095])
 ;
 ; Below I pick out a box in the bottom-left corner that is the same
 ; size as that used for the Venus intensity. I consider the standard
 ; deviation of the intensities in this box to be an estimate of the
 ; uncertainty in the dark current.
 ;
  dxp=30
  dyp=30
  output[i].dark_stdev=stdev(map.data[dxp-nb:dxp+nb,dyp-nb:dyp+nb])
 ;
  IF coord_swtch THEN BEGIN
    xpos=xy[0]
    ypos=xy[1]
  ENDIF ELSE BEGIN 
    IF n_tags(data) NE 0 THEN BEGIN
      xpos=data[i].x
      ypos=data[i].y
    ENDIF ELSE BEGIN
      t_tai=anytim2tai(map.time)
      xpos=(x1-x0)*(t_tai-t0_tai)/dt_tai + x0
      ypos=(y1-y0)*(t_tai-t0_tai)/dt_tai + y0
    ENDELSE
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
   ; Adjust how image is created depending on how bright the
   ; channel is.
   ;
    dd=sigrange(smap.data,range=r)
    IF r[1] GT 100. THEN BEGIN
      dmin=10
      IF n_elements(dmax) EQ 0 THEN dmax=r[1]
      image=alog10(smap.data>dmin<dmax)
      IF n_elements(ct_number) EQ 0 THEN ct_number=3
    ENDIF ELSE BEGIN
      image=smap.data>r[0]<r[1]*0.5
      IF n_elements(ct_number) EQ 0 THEN ct_number=5
    ENDELSE
    loadct,ct_number
    plot_image,image, $
               title='Image '+trim(i+1)+'/'+trim(count)+', '+ $
               anytim2utc(map.time,/ccsds,/time,/trunc)+' UT', $
               charsize=1.5, $
               xtitle='pixel', $
               ytitle='pixel'
    s=size(image,/dim)
    IF coord_swtch THEN BEGIN
      IF s[0] NE s[1] AND abs(s[1]-s[0]) GT 3 THEN BEGIN
        print,'*** WARNING: Venus is close to edge of field-of-view ***'
        print,format='(10x,2i7)',s[0],s[1]
      ENDIF 
      x=float(s[0])/2.
      y=float(s[1])/2.
    ENDIF ELSE BEGIN 
      cursor,x,y,/data
      x=round(x) & y=round(y)
    ENDELSE
   ;
    oplot,x+[-30,30]/0.6,y*[1,1]
    oplot,x*[1,1],y+[-30,30]/0.6
   ;
    IF keyword_set(circle) THEN BEGIN
      ident_x=fltarr(s[0])+1.
      ident_y=fltarr(s[1])+1.
      x_arr=findgen(s[0])#ident_y
      y_arr=ident_x#findgen(s[1])
      r_arr=sqrt((x_arr-x)^2+(y_arr-y)^2)
      k=where(r_arr LE circ_pix_radius,nk)
     ;
      contour,r_arr,levels=circ_pix_radius,/overplot
      output[i].int=mean(smap.data[k])
      output[i].int_stdev=stdev(smap.data[k])
    ENDIF ELSE BEGIN 
      oplot,[x-nb,x+nb,x+nb,x-nb,x-nb],[y-nb,y-nb,y+nb,y+nb,y-nb]
      output[i].int=mean(smap.data[x-nb:x+nb,y-nb:y+nb])
      output[i].int_stdev=stdev(smap.data[x-nb:x+nb,y-nb:y+nb])
    ENDELSE 
   ;
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
    output[i].int_stdev=stdev(sub_smap.data)
    output[i].time=smap.time
    output[i].x=xpos
    output[i].y=ypos
    output[i].r=data[i].r
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
