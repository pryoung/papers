

FUNCTION plot_fe12_1g_redshift

;+
; Shows the redshifted component from the 1G fit to Fe XII 195.
;
; This version responds to the referee's comment that the Y-axis should be in heliocentric coordinates
; rather than pixels.
;-


restore,'20110216_1409_fit_fe12_195_1g_v2.save'

fitx=eis_update_fitdata(fit,yra=[0,17],/quiet)
vel=eis_get_fitdata(fitx,/vel)

file=eis_find_file(fit.date_obs,/lev,twind=5,count=count)
IF count NE 0 THEN BEGIN
  wd=eis_getwindata(file,195.12)
  xy=eis_aia_offsets(fit.date_obs)
  solar_y=wd.solar_y+xy[1]
ENDIF ELSE BEGIN
  message,'The level-1 FITS file was not found. Returning...',/cont,/info
  return,-1
ENDELSE 

;
; Need to work out X-axis (time)
;
x=fitx.exp_start_times
x=x+anytim2tai(fit.date_obs)-anytim2tai('16-feb-2011 14:25')
xfix=image_fix_axis(x)
xdx=(xfix[1]-xfix[0])/2.

y=findgen(fit.ny)

i0=10
vel=vel[i0:*,*]
xfix=xfix[i0:*]

plot_vel_rgb_table,vel,image=image,rgb_table=rgb_table, max_value=15


xdim=500
ydim=450
w=window(dim=[xdim,ydim])

fs=11
xtl=0.015
ytl=0.015
th=2

p=image(image,xfix,solar_y,axis_style=2,rgb_table=rgb_table, $
        xtitle='Time relative to 14:25 UT / seconds', $
        ytitle='Solar-Y / arcsec',/current, $
        xth=th,yth=th, xticklen=xtl,yticklen=ytl, $
        font_size=fs, $
        pos=[0.14,0.10,0.98,0.98], $
        xmin=1,ymin=1)
p.scale,1,2.6

x0=900
x1=1200
y0=180
y1=380



l1=plot([900,1200]-920,[180,380]+solar_y[0],th=2,/overplot)

print,format='("Redshift line gradient (km/s): ",f7.1)',float(y1-y0)/float(x1-x0)*725.

;
; The y-positions were obtained by plotting the exposure images and
; using the cursor routine to select the centers of the spray plasma. 
;
xx=xfix[19-i0:22-i0]+xdx
yy=[106.7,135.6,165.6,207.8]+solar_y[0]

cc=linfit(xx,yy)
print,format='("Spray line gradient (km/s): ",f7.1)',cc[1]*725.


l2=plot(/overplot,xx,yy,th=3,color='yellow')

w.save,'plot_fe12_1g_redshift.png',width=xdim*2


return,w

END
