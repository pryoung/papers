

PRO make_eis_movie_256_304, wd256=wd256

;+
; NAME:
;     MAKE_EIS_MOVIE_256_304
;
; PURPOSE:
;     Creates the image frames for a movie that was published in Janvier et
;     al. (2023, A&A) about the 2-Apr-2022 filament eruption.
;
; CATEGORY:
;     Journal movie.
;
; CALLING SEQUENCE:
;     MAKE_EIS_MOVIE_256_304
;
; INPUTS:
;     None.
;
; OPTIONAL INPUTS:
;     AIA_DIR:  The directory containing the AIA cutouts.
;     Wd256:   The windata structure for the EIS He II 256 line, created
;              on a previous call to the routine. 
;
; OUTPUTS:
;     Writes out jpeg images to the directory 'eis_frames_256_304'.
;
; OPTIONAL OUTPUTS:
;     Wd256:  The windata structure for the EIS He II 256 line.
;
; EXAMPLE:
;     IDL> make_eis_movie_256_304
;
; MODIFICATION HISTORY:
;     Ver.1, 04-May-2023, Peter Young
;     Ver.2, 05-May-2023, Peter Young
;       Added labels (a) and (b) to images.
;-


;
; Be default I look for the AIA cutouts in my own directory.
;
IF n_elements(aia_dir) EQ 0 THEN aia_dir='~/data/flares/20220402/jsoc_cutouts'

search_str=concat_dir(aia_dir,'*.304.image.fits')
list=file_search(search_str,count=count)
IF count EQ 0 THEN BEGIN
  print,'Please download the AIA 304 cutout images from:'
  print,'   https://doi.org/10.5281/zenodo.7897655'
  print,'After downloading, use the input AIA_DIR= to specify the directory'
  print,'in which the cutout images are stored.'
  return
ENDIF 
amap=sdo2map(list[0:249])
aia_tai=anytim2tai(amap.time)


IF n_tags(wd256) EQ 0 THEN BEGIN 
  file=eis_find_file('2-apr-2022 13:54',/lev,/seq)
  wd256=eis_getwindata(file[0],256.32,/refill)
ENDIF

;
; I have to create a fake time for a missing exposure
;
wd256.time_ccsds[15]='2022-04-02T13:09:43.433'

eis_tai=anytim2tai(wd256.time_ccsds)+wd256.exposure_time/2.


iexp0=5
iexp1=80

iy0=0
iy1=129

d256=wd256.int[*,iexp0:iexp1,iy0:iy1]



outdir='eis_frames_256_304'
chck=file_info(outdir)
IF chck.exists EQ 0 THEN file_mkdir,outdir
chck=file_search(outdir,'*.jpg',count=count)
IF count NE 0 THEN file_delete,chck

n=iexp1-iexp0+1
xdim=800
ydim=500

dx_aia=round(41.5)


x0=0.09
x1=0.41
x2=0.41
x3=0.98
y0=0.12
y1=0.98



;
; offset values come from coalign_he2.pro.
;
xy=eis_aia_offsets(wd256.hdr.date_obs)
eis_offset=[xy[0]+8.0,xy[1]+15]

solar_y=wd256.solar_y[iy0:iy1]+eis_offset[1]

lref=256.36
v=lamb2v(wd256.wvl-lref,lref)
vax=image_fix_axis(v)

fs=12
th=2
xtl=0.015
ytl=0.015

IF n_tags(samap) EQ 0 THEN BEGIN
  xcen=wd256.solar_x[iexp0]+eis_offset[0]
  sub_map,amap,samap,xrange=xcen+[-80,60], $
          yrange=[solar_y[0],solar_y[-1]]
ENDIF 

count=0
FOR i=0,n-1 DO BEGIN
  IF iexp0+i EQ 15 OR iexp0+i EQ 72 THEN continue
  w=window(dim=[xdim,ydim],/buffer)
  eis_img=reform(d256[*,i,*])
  k=where(eis_img EQ wd256.missing,nk)
 ;
 ; replace missing data with median
 ;
  IF nk GT 0 THEN BEGIN
    med_img=fmedian(eis_img,3,7,missing=wd256.missing)
    eis_img[k]=med_img[k]
  ENDIF
  
  p=image(sqrt(eis_img>1.), $
          min_value=sqrt(50.), max_value=sqrt(50000.), $
          axis_style=2, $
          vax,solar_y, $
          xtickdir=1,xticklen=xtl,yticklen=ytl, $
          pos=[x0,y0,x1,y1], $
          rgb_table=aia_rgb_table(304),/current, $
          ytickdir=1,font_size=fs,xth=th,yth=th,  $
          ytitle='y / arcsec', $
          xtitle='LOS velocity / km s!u-1!n')
  p.scale,1,10.55
  eis_txt=anytim2utc(eis_tai[iexp0+i],/ccsds,/time,/trunc)+' UT'
  pt=text(target=p,-500,p.yrange[0]+3,/data,eis_txt,font_size=fs,color='white')
  pt2=text(target=p,-500,p.yrange[1]-3,vertical_align=1.0, $
           /data,'(a) EIS, He II 256 '+string(197b),font_size=fs,color='white')

  getmin=min(abs(eis_tai[iexp0+i]-aia_tai),imin)
  s=plot_map_obj(samap[imin],dmin=5,dmax=1000,/log, $
                 pos=[x2,y0,x3,y1], $
                 rgb_table=aia_rgb_table(304),/current,title='',font_size=fs, $
                 xticklen=xtl,yticklen=ytl,xtickdir=1,ytickdir=1, $
                 yshowtext=0,xth=th,yth=th, xmin=1, $
                 xtitle='x / arcsec')
  sl1=plot(/overplot,(xcen-2)*[1,1],s.yrange,th=th,color='dodger blue')
  sl2=plot(/overplot,(xcen+2)*[1,1],s.yrange,th=th,color='dodger blue')
  aia_txt=anytim2utc(samap[imin].time,/ccsds,/time,/trunc)+' UT'
  st=text(target=s,/data,s.xrange[1]-5,align=1,s.yrange[0]+3,aia_txt,font_size=fs,color='white')
  st2=text(target=s,/data,s.xrange[1]-5,align=1,s.yrange[1]-3,vertical_align=1.0, $
           '(b) AIA 304 '+string(197b)+' (He II)',font_size=fs,color='white')
  
  
  outfile='image'+strpad(trim(count),4,fill='0')+'.jpg'
  outfile=concat_dir(outdir,outfile)
  w.save,outfile,width=xdim
  count=count+1
  w.close
ENDFOR

message,/info,/cont,'Image frames written to the directory '+outdir+'.'
message,/info,/cont,'To create the movie I recommend using ffmpeg. See the website:'
message,/info,/cont,'  https://pyoung.org/quick_guides/mpeg_movies.html'


END
