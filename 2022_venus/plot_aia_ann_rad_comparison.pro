
FUNCTION plot_aia_ann_rad_comparison


;+
; This is a 4-panel plot showing the how the AIA annulus intensity is 
; affect by modifying the inner and out radii.
;
; Requires the following files in the local directory:
;    aia_venus_results.save
;    aia_results_inner_radius.save
;
; PRY, 25-Apr-2022
;-


x0=0.03
x1=0.98
dx=(x1-x0)/2.
ddx=0.07

y0=0.01
y1=0.98
dy=(y1-y0)/2.
ddy=0.06

th=2
fs=12


results_file='aia_venus_results.save'
chck=file_info(results_file)
IF chck.exists EQ 0 THEN BEGIN
  message,'The file aia_venus_results.save was not found. Returning...',/info,/continue
  return,-1
ENDIF 
restore,results_file

xx=d050

;
; Inner radius=10
; ---------------
results_file='aia_results_inner_radius.save'
chck=file_info(results_file)
IF chck.exists EQ 0 THEN BEGIN
  message,'The file '+results_file+' was not found. Returning...',/info,/continue
  return,-1
ENDIF 
restore,results_file

;
; Note the p appended to d010 means that the /previous keyword was set when
; using aia_get_venus.   
;
yy=d010p
yy[0].sub_map_int=d010n[0].sub_map_int
r1=10  &  r2=50


xdim=800
ydim=750
w=window(dim=[xdim,ydim])

extra={ thick: th, $
        xthick: th, $
        ythick: th, $
        xticklen: 0.015, yticklen: 0.015, $
        sym_size: 1, sym_thick: th,$
        font_size: fs}

n=n_elements(xx)
swtch=bytarr(n)
t_tai=anytim2tai(xx.time)
t_min=round((t_tai-t_tai[0])/60.)
chck=t_min MOD 20
k=where(chck NE 0)
swtch[k]=1b

i_in_0=where(xx.r LT 960. AND swtch EQ 0)
i_in_1=where(xx.r LT 960. AND swtch EQ 1)
i_in=where(xx.r LT 960.)
i_out=where(xx.r GE 960.)
i_out_0=where(xx.r GE 960. AND swtch EQ 0)
i_out_1=where(xx.r GE 960. AND swtch EQ 1)

p=plot(/current,xx[i_in].sub_map_int,yy[i_in].sub_map_int,symbol='+', $
       _extra=extra, $
       pos=[x0+ddx,y0+dy+ddy,x0+dx,y0+2*dy],linestyle='none', $
       xmin=1,ymin=1)
xr=p.xrange
yr=p.yrange
maxval=max([xr[1],yr[1]])
p.xrange=[0,maxval]
p.yrange=[0,maxval]
p2=plot(/overplot,xx[i_out].sub_map_int,yy[i_out].sub_map_int,symbol='o', $
        linesty='none',_extra=extra)
p3=plot(/overplot,p.xrange,p.yrange,th=th,linesty='--')

pt=text(30,450,'(a) Annulus radii: '+trim(r1)+' & '+trim(r2),font_size=fs,/data)

ratio1=yy.sub_map_int/xx.sub_map_int


;
; Inner radius=20
; ---------------
yy=d020p
yy[0].sub_map_int=d020n[0].sub_map_int
r1=20  &  r2=50


extra={ thick: th, $
        xthick: th, $
        ythick: th, $
        xticklen: 0.015, yticklen: 0.015, $
        sym_size: 1, sym_thick: th,$
        font_size: fs}

n=n_elements(xx)
swtch=bytarr(n)
t_tai=anytim2tai(xx.time)
t_min=round((t_tai-t_tai[0])/60.)
chck=t_min MOD 20
k=where(chck NE 0)
swtch[k]=1b

i_in_0=where(xx.r LT 960. AND swtch EQ 0)
i_in_1=where(xx.r LT 960. AND swtch EQ 1)
i_in=where(xx.r LT 960.)
i_out=where(xx.r GE 960.)
i_out_0=where(xx.r GE 960. AND swtch EQ 0)
i_out_1=where(xx.r GE 960. AND swtch EQ 1)

q=plot(/current,xx[i_in].sub_map_int,yy[i_in].sub_map_int,symbol='+', $
       _extra=extra, $
       pos=[x0+dx+ddx,y0+dy+ddy,x0+2*dx,y0+2*dy],linestyle='none', $
       xmin=1,ymin=1)
xr=q.xrange
yr=q.yrange
maxval=max([xr[1],yr[1]])
q.xrange=[0,maxval]
q.yrange=[0,maxval]
q2=plot(/overplot,xx[i_out].sub_map_int,yy[i_out].sub_map_int,symbol='o', $
        linesty='none',_extra=extra)
q3=plot(/overplot,q.xrange,q.yrange,th=th,linesty='--')

qt=text(30,450,'(b) Annulus radii: '+trim(r1)+' & '+trim(r2),font_size=fs,/data,target=q)

ratio2=yy.sub_map_int/xx.sub_map_int


;
; Outer radius=70
; ---------------
xx=d050x
yy=d070x
rad1=30  &  rad2=70


extra={ thick: th, $
        xthick: th, $
        ythick: th, $
        xticklen: 0.015, yticklen: 0.015, $
        sym_size: 1, sym_thick: th,$
        font_size: fs}

n=n_elements(xx)
swtch=bytarr(n)
t_tai=anytim2tai(xx.time)
t_min=round((t_tai-t_tai[0])/60.)
chck=t_min MOD 20
k=where(chck NE 0)
swtch[k]=1b

i_in=where(xx.r LT 960. AND swtch EQ 0)
i_in_1=where(xx.r LT 960. AND swtch EQ 1)
i_out=where(xx.r GE 960. AND swtch EQ 0)
i_out_1=where(xx.r GE 960. AND swtch EQ 1)

r=plot(/current,xx[i_in].sub_map_int,yy[i_in].sub_map_int,symbol='+', $
       _extra=extra, $
       pos=[x0+ddx,y0+ddy,x0+dx,y0+dy],linestyle='none', $
       xmin=1,ymin=1)
xr=r.xrange
yr=r.yrange
maxval=max([xr[1],yr[1]])
r.xrange=[0,maxval]
r.yrange=[0,maxval]
r2=plot(/overplot,xx[i_out].sub_map_int,yy[i_out].sub_map_int,symbol='o', $
        linesty='none',_extra=extra)
r3=plot(/overplot,r.xrange,r.yrange,th=th,linesty='--')

rt=text(30,450,'(c) Annulus radii: '+trim(rad1)+' & '+trim(rad2),font_size=fs,/data,target=r)

ratio3=yy.sub_map_int/xx.sub_map_int

;
; Outer radius=90
; ---------------
xx=d050x
yy=d090x
rad1=30  &  rad2=90


extra={ thick: th, $
        xthick: th, $
        ythick: th, $
        xticklen: 0.015, yticklen: 0.015, $
        sym_size: 1, sym_thick: th,$
        font_size: fs}

n=n_elements(xx)
swtch=bytarr(n)
t_tai=anytim2tai(xx.time)
t_min=round((t_tai-t_tai[0])/60.)
chck=t_min MOD 20
k=where(chck NE 0)
swtch[k]=1b

i_in=where(xx.r LT 960. AND swtch EQ 0)
i_in_1=where(xx.r LT 960. AND swtch EQ 1)
i_out=where(xx.r GE 960. AND swtch EQ 0)
i_out_1=where(xx.r GE 960. AND swtch EQ 1)

s=plot(/current,xx[i_in].sub_map_int,yy[i_in].sub_map_int,symbol='+', $
       _extra=extra, $
       pos=[x0+dx+ddx,y0+ddy,x0+2*dx,y0+dy],linestyle='none', $
       xmin=1,ymin=1)
xr=s.xrange
yr=s.yrange
maxval=max([xr[1],yr[1]])
s.xrange=[0,maxval]
s.yrange=[0,maxval]
s2=plot(/overplot,xx[i_out].sub_map_int,yy[i_out].sub_map_int,symbol='o', $
        linesty='none',_extra=extra)
s3=plot(/overplot,s.xrange,s.yrange,th=th,linesty='--')

st=text(30,450,'(d) Annulus radii: '+trim(rad1)+' & '+trim(rad2),font_size=fs,/data,target=s)


xt=text(x0+ddx+(2*dx-ddx)/2.,0.01,align=0.5,'$D_{\rm ann}$ [ DN s!u-1!n pix!u-1!n ]',font_size=fs+2)
yt=text(0.03,y0+ddy+(2*dy-ddy)/2.,align=0.5,'$D*_{\rm ann}$ [ DN s!u-1!n pix!u-1!n ]',font_size=fs+2,orient=90)

ratio4=yy.sub_map_int/xx.sub_map_int


print,format='(" Min-max ratios for plot a: ",2f6.2)',minmax(ratio1)
print,format='(" Min-max ratios for plot b: ",2f6.2)',minmax(ratio2)
print,format='(" Min-max ratios for plot c: ",2f6.2)',minmax(ratio3)
print,format='(" Min-max ratios for plot d: ",2f6.2)',minmax(ratio4)


w.save,'plot_aia_ann_rad_comparison.png',width=2*xdim

return,w

END
