

IF n_tags(wd) EQ 0 THEN BEGIN 
  file=eis_find_file('2-apr-2022 13:30',/lev)
  wd=eis_getwindata(file,256.32,/refill)
ENDIF

iy0=50
iy1=94

img=reform(wd.int[*,39,iy0:iy1])

xdim=550
ydim=500
w=window(dim=[xdim,ydim])

lref=256.36
v=lamb2v(wd.wvl-lref,lref)

xy=eis_aia_offsets(wd.hdr.date_obs)
y=wd.solar_y[iy0:iy1]+xy[1]+15.


fs=12
th=2
xtl=0.015
ytl=0.015

p=image(axis_sty=2,img,v,y,rgb_table=3,/current, $
        pos=[0.13,0.12,0.98,0.98], $
        font_size=fs,xth=th,yth=th, $
        xticklen=xtl,yticklen=ytl, $
        xtitle='LOS velocity / km s!u-1!n', $
        ytitle='y / arcsec', $
       xtickdir=1,ytickdir=1,ymin=1)
p.scale,1,17


pt=text(/data,-460,294,'EIS, He II 256.32 '+string(197b)+'!c13:16:15 UT', $
        color='white',font_size=fs)

pl=arrow(th=th,color='dodger blue',[-350,-150],[280,266],/overplot, $
         arrow_sty=3,/data)

pltxt=text(-470,270,/data,'blueshifted!cfilament plasma',font_size=fs, $
           color='dodger blue')

w.save,'plot_he2_twist.jpg',width=2*xdim

END

