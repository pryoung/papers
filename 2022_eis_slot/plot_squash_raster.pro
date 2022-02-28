

FUNCTION plot_squash_raster


; Here I combine the squashed off-limb image with the Fe XVI image in
; a 2-panel plot. See also plot_squashed_slot.pro and
; plot_raster_example.pro. This is Figure 2 in the paper.
;
; The routine 'image_fix_axis' is required. This is available at:
; https://pyoung.org/quick_guides/routines/image_fix_axis.pro


th=2
fs=11

xdim=820
ydim=450
w=window(dim=[xdim,ydim])

x0=0.06
x1=0.44
x2=x1+0.10
x3=0.98
y0=0.11
y1=0.98


;
; Panel (a)
; ---------
file=eis_find_file('31-jan-2008 22:35',/lev)

wd=eis_getwindata(file,195.12)
yws=wd.hdr.yws

iexp=11
img=reform(wd.int[*,iexp,*,0])
wvl=wd.wvl
wvlx=image_fix_axis(wvl)

y=findgen(wd.ny)+yws

exp_num=wd.nx-iexp


p=image(img,wvlx,y,pos=[x0,y0,x1,y1], $
        rgb_table=aia_rgb_table(193), $
        xth=th,yth=th,font_size=fs,/current, $
        axis_style=2, $
        xticklen=0.015,yticklen=0.015, $
        ymin=1, $
        xtitle='Wavelength / '+string(197b), $
        ytit='Y-pixel', $
        xtickdir=1,ytickdir=1, $
        xmin=0)
p.scale,300,1

yr=p.yrange
ypos=0.97*yr[1]+0.03*yr[0]


t=text(/data,194.6,ypos,'(a)!c31-Jan-2008 22:35 UT, Exp '+trim(exp_num)+'!cFe XII !9l!3195.12', $
       font_size=fs,vertical_align=1.0,color='white')





;
; Panel (b)
; ---------
file=eis_find_file('19-may-2007 18:12',/lev)
map=eis_slot_map(file,263,trim=[6,43],/quiet)
sub_map,map,smap,yrange=[-30,230]


q=plot_map_obj(smap,rgb_table=3, $
               xth=th,yth=th,font_size=fs, $
               pos=[x2,y0,x3,y1], $
               /log,dmin=20, /current, $
               xticklen=0.015,yticklen=0.015, $
               xtickdir=1,ytickdir=1, $
               title='')

yr=q.yrange
ypos=0.97*yr[1]+0.03*yr[0]


tq=text(/data,-17,ypos,'(b)!c19-May-2007 18:12 UT!cFe XVI !9l!3262.98',font_size=fs,color='white', $
        vertical_align=1.0,target=q)

xp=187
FOR i=0,5 DO BEGIN
  tx=text(/data,xp-i*38,-25,trim(i+1),font_size=fs,color='white', $
          align=0.5,target=q)
ENDFOR


w.save,'plot_squash_raster.png',width=xdim

return,w

END
