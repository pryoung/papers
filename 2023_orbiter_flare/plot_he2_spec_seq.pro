

FUNCTION plot_he2_spec_seq, wd=wd

; a multi-panel plot showing time evolution of He II spectra.


IF n_tags(wd) EQ 0 THEN BEGIN 
  file=eis_find_file('2-apr-2022 13:54',/lev,/seq)
  wd=eis_getwindata(file[0],256.32,/refill)
ENDIF


iy0=65
iy1=124

il0=0
il1=30

xy=eis_aia_offsets(wd.hdr.date_obs)

lref=256.358
v=lamb2v(wd.wvl[il0:il1]-lref,lref)
yax=wd.solar_y[iy0:iy1]+15.+xy[1]

iexp=indgen(6)+58

t_tai=anytim2tai(wd.time_ccsds)+wd.exposure_time/2.
t_ccsds=anytim2utc(/ccsds,t_tai[iexp],/time,/trunc)
tstr=t_ccsds+' UT'
eis_tai=t_tai[iexp]

x0=0.06
x1=0.55
dx=(x1-x0)/3.
y0=0.10
y1=0.98
dy=(y1-y0)/2.

fs=12
th=2
xtl=0.015
ytl=0.015

xdim=1200
ydim=700
w=window(dim=[xdim,ydim])

n=n_elements(iexp)

;
; Plot EIS images
; ---------------
dmin=1000
dmax=4e4
FOR i=0,n-1 DO BEGIN
  ix=i MOD 3
  iy=1 - i/3
 ;
  IF iy EQ 0 THEN junk=temporary(xshowtext) ELSE xshowtext=0
  IF ix EQ 0 THEN yshowtext=1 ELSE yshowtext=0
  IF ix EQ 1 AND iy EQ 0 THEN xtitle='v!dLOS!n / km s!u-1!n' ELSE xtitle=''
  IF ix EQ 0 THEN ytitle='y / arcsec' ELSE ytitle=''
  img=reform(wd.int[il0:il1,iexp[i],iy0:iy1])
 ;
 ; Smooth over missing pixels for display purposes
 ;
  med_img=fmedian(img,3,7)
  k=where(img EQ wd.missing,nk)
  IF nk NE 0 THEN img[k]=med_img[k]
 ;
  img=alog10(img>dmin<dmax)
  p=image(img,v,yax,axis_sty=2,rgb_table=3, $
          pos=[x0+ix*dx,y0+iy*dy,x0+(ix+1)*dx,y0+(iy+1)*dy], $
          /current, min_value=alog10(dmin), max_value=alog10(dmax), $
          xshowtext=xshowtext,yshowtext=yshowtext, $
          xth=th,yth=th,font_size=fs, $
          xtickdir=1, xticklen=xtl, $
          xtitle=xtitle, ytitle=ytitle, $
          yticklen=ytl,ytickdir=1,ymin=1)
  p.scale,1,21
  ;; IF iy EQ 0 THEN BEGIN
  ;;   p.axes[0].hide=1
  ;;   xaxis=axis('x',th=th,title='v / km s!u-1!n',ticklen=xtl,target=p, $
  ;;              tickfont_size=fs,tickdir=1)
  ;; ENDIF 
  FOR j=0,1 DO pl=plot(/overplot,p.xrange,(290+j*20)*[1,1],th=th, $
                       linesty=':',color='white')
  pt=text(/data,-470,yax[-8],'(E'+trim(i+1)+') '+tstr[i],font_size=fs,color='white',target=p)
  IF i EQ 3 THEN po=plot(/overplot,-270*[1,1],306*[1,1],symbol='o',sym_thick=2, $
                         color='dodger blue',sym_size=3)
ENDFOR

;
; Now plot AIA images
; -------------------
list=file_search('~/data/flares/20220402/jsoc_cutouts/*.304.image.fits')
list=list[80:149]
read_sdo,list,index,/use_shared

t_obs_tai=anytim2tai(index.t_obs)

x0=0.60
x1=0.99
dx=(x1-x0)/3.
y0=0.10
y1=0.98
dy=(y1-y0)/2.

FOR i=0,n-1 DO BEGIN
  getmin=min(abs(t_obs_tai-eis_tai[i]),imin)
  map=sdo2map(list[imin])
 ;
  eis_x=(wd.solar_x[i]+xy[0]+8.)
  xrange=eis_x+[-15,15]
  yrange=minmax(yax)
  sub_map,map,smap,xra=xrange,yra=yrange
 ;
  ix=i MOD 3
  iy=1 - i/3
 ;
  IF iy EQ 0 THEN junk=temporary(xshowtext) ELSE xshowtext=0
  IF ix EQ 0 THEN yshowtext=1 ELSE yshowtext=0
  IF ix EQ 1 AND iy EQ 0 THEN xtitle='x / arcsec' ELSE xtitle=''
 ;
  q=plot_map_obj(smap,/log,rgb_table=aia_rgb_table(304), $
                 pos=[x0+ix*dx,y0+iy*dy,x0+(ix+1)*dx,y0+(iy+1)*dy], $
                 /current,  $
                 xshowtext=xshowtext,yshowtext=yshowtext, $
                 xth=th,yth=th,font_size=fs, $
                 xtickdir=1,ytickdir=1, $
                 ymin=1,xticklen=xtl,yticklen=ytl, $
                 xmin=0,xtitle=xtitle, ytitle='', $
                 xtickvalues=[910,920,930], $
                 title='')
  FOR j=0,1 DO ql=plot(/overplot,q.xrange,(290+j*20)*[1,1],th=th, $
                       linesty=':',color='white')
  ql1=plot(/overplot,color='dodger blue',th=th, $
           eis_x*[1,1],q.yrange[1]+[0,-3])
  ql2=plot(/overplot,color='dodger blue',th=th, $
           eis_x*[1,1],q.yrange[0]+[0,3])
 ;
  tstr='(A'+trim(i+1)+') '+anytim2utc(/ccsds,t_obs_tai[imin],/time,/trunc)+' UT'
  qt=text(/data,903,yax[-8],tstr,font_size=fs,color='white',target=q)
 ;
  IF i EQ 4 THEN arr=arrow(/data,[918,922.5]+4,[295,301.5]-6,th=th,color='dodger blue',target=q)
  IF i EQ 3 THEN po=plot(/overplot,918.7*[1,1],306*[1,1],symbol='o',sym_thick=2, $
                         color='dodger blue',sym_size=3)
ENDFOR 


w.save,'plot_he2_spec_seq.jpg',width=2*xdim

return,w

END
