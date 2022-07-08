
FUNCTION plot_aia_venus, reverse=reverse

;+
;   Plots an AIA 193 image from during the transit, and overplots the
;   track of Venus.
;
; MODIFICATION HISTORY:
;     Ver.2, 30-Jun-2022, Peter Young
;       Increased font size; updated axis labels; fixed Angstrom
;       problem.
;     Ver.3, 08-Jul-2022, Peter Young
;       Now produces a jpeg instead of png (much smaller in size).
;-


if n_tags(map) eq 0 then begin 
   aiadir='aia'
   aiafile='aia.lev1.193A_2012-06-06T01_00_55.84Z.image_lev1.fits'
   aiafile=concat_dir(aiadir,aiafile)
   map=sdo2map(aiafile)
endif

IF keyword_set(reverse) THEN BEGIN
   bgcolor='black'
   color='white'
ENDIF ELSE BEGIN
   color='black'
   bgcolor='white'
ENDELSE 

xdim=1000
ydim=400
w=window(dim=[xdim,ydim],background_color=bgcolor)




sub_map,map,smap,yrange=[100,800],xrange=[-948.9,948.9]
s=size(smap.data,/dim)
smap2=rebin_map(smap,s[0]/2,s[1]/2)

th=2
fs=12

day=anytim2utc(/ccsds,map.time,/date)
tt=anytim2utc(/ccsds,map.time,/time,/trunc)

title='AIA 193 '+string(197b)+', '+day+' '+tt+' UT'

p=plot_map_obj(smap2,/log,dmin=20,rgb_table=aia_rgb_table(193), /current, $
               font_size=fs,xthick=th,ythick=th, $
               title='', $
               pos=[0.07,0.10,0.99,0.98], $
               yminor=1, $
               xticklen=0.018,yticklen=0.008, $
               xcolor=color,ycolor=color, $
               xtitle='solar-$x$ [ arcsec ]', $
               ytitle='solar-$y$ [ arcsec ]')

t=text(/data,-890,730,title,font_size=fs,color='white')


;
; Plot track of Venus
;
restore,'aia_venus_results.save'
x=d050.x
y=d050.y
n=n_elements(x)
for i=0,n-2 do begin
   if i eq 6 or i eq 17 then begin
      q=arrow(/overplot,x[i:i+1],y[i:i+1],color='yellow',/data, $
             head_indent=0.9)
   endif else begin
      q=plot(/overplot,x[i:i+1],y[i:i+1],color='yellow',thick=1, $
             xrange=p.xrange,yrange=p.yrange)
   endelse 
endfor 


d=read_eis_venus_results('results_195.txt',195.12)
x=d.x
y=d.y
n=n_elements(x)
FOR i=0,n-1 DO BEGIN
  r=plot(/overplot,x[i]*[1,1],y[i]*[1,1],color='dodger blue',symbol='+', $
         sym_thick=1, sym_size=2, $
         xrange=p.xrange,yrange=p.yrange)
;  r=plot(/overplot,x[i:i+1],y[i:i+1],color='dodger blue',thick=1, $
;             xrange=p.xrange,yrange=p.yrange)
ENDFOR


IF NOT keyword_set(reverse) THEN w.save,'plot_aia_venus.jpg',width=2*xdim

return,w

end

