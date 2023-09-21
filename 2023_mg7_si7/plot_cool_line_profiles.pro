
FUNCTION plot_cool_line_profiles

;+
; NAME:
;     PLOT_COOL_LINE_PROFILES
;
; PURPOSE:
;     Plots three line profiles and their fits from one of the cool loop
;     spectra.
;
; CATEGORY:
;     Paper; figure.
;
; CALLING SEQUENCE:
;     Result = PLOT_COOL_LINE_PROFILES()
;
; INPUTS:
;     None.
;
; OUTPUTS:
;     Returns an IDL plot object.
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;     Requires a file to be downloaded from the internet.
;
; PROCEDURE:
;
; EXAMPLE:
;     IDL> w=plot_cool_line_profiles()
;
; MODIFICATION HISTORY:
;     Ver.1, 21-Sep-2023, Peter Young
;-


file='20070221_0112/20070221_011216_si7_mask.save'

chck=file_search(file,count=count)
IF count EQ 0 THEN BEGIN
  message,/info,/cont,'Please download the zip file from Zenodo. The DOI is 10.5281/zenodo.8368508. Unpack it in the working directory. Returning...'
  return,''
ENDIF 
restore,file

file='20070221_0112/20070221_011216_si7_mask_fits.txt'

read_line_fits,file,lines

x0=0.025
x1=0.99
dx=(x1-x0)/3.
ddx=0.04
y0=0.13
y1=0.98

th=2
fs=11
xtl=0.015
ytl=0.02

xdim=1000
ydim=350
w=window(dim=[xdim,ydim])

wid=0.4

shift=275.368-275.401

;---------------------------
wvl=272.658
p=plot(lwspec.wvl+shift,lwspec.int/1000.,/stairstep, $
       xra=wvl+[-wid,wid], $
       pos=[x0+ddx,y0,x0+dx,y1], $
       th=th,xth=th,yth=th,font_size=fs, $
       color='blue',/current, $
       yra=[0,2.4],/ysty,/xsty, $
       xmin=1,ymin=1, $
       xticklen=xtl,yticklen=ytl, $
       ytitle='intensity / x10!u3!n erg cm!u-2!n s!u-1!n sr!u-1!n '+string(197b)+'!u-1!n', $
       xtickdir=1)
pt=text(x0+ddx+0.01,y1-0.02,'(a) Si VII 272.66 '+string(197b),font_size=fs+1, $
        target=p,vertical_align=1.0)

getmin=min(abs(lines.wvl-wvl),imin)
x=findgen(101)/100*0.3-0.15 + wvl
g=gauss_sg(x,[lines[imin].peak,lines[imin].wvl+shift,lines[imin].width/2.355])
l=line_sg(x,[lines[imin].y0,lines[imin].y1])

pg=plot(/overplot,x,(g+l)/1000.,th=th,color='red')

;---------------------------
wvl=274.188
q=plot(lwspec.wvl+shift,lwspec.int/1000.,/stairstep, $
       xra=wvl+[-wid,wid], $
       pos=[x0+dx+ddx,y0,x0+2*dx,y1], $
       th=th,xth=th,yth=th,font_size=fs, $
       color='blue',/current, $
       yra=[0,2.1],/ysty,/xsty, $
       xmin=1,ymin=1, $
       xticklen=xtl,yticklen=ytl, $
       ytitle='', $
       xtickdir=1, $
       xtit='wavelength / '+string(197b))
qt=text(x0+dx+ddx+0.01,y1-0.02,'(b) Si VII 274.19 '+string(197b),font_size=fs+1, $
        target=q,vertical_align=1.0)

getmin=min(abs(lines.wvl-wvl),imin)
x=findgen(101)/100*0.3-0.15 + wvl
g=gauss_sg(x,[lines[imin].peak,lines[imin].wvl+shift,lines[imin].width/2.355])
l=line_sg(x,[lines[imin].y0,lines[imin].y1])

qg=plot(/overplot,x,(g+l)/1000.,th=th,color='red')


;---------------------------
wvl=278.394
r=plot(lwspec.wvl+shift,lwspec.int/1000.,/stairstep, $
       xra=wvl+[-wid,wid], $
       pos=[x0+2*dx+ddx,y0,x0+3*dx,y1], $
       th=th,xth=th,yth=th,font_size=fs, $
       color='blue',/current, $
       yra=[0,7.5],/ysty,/xsty, $
       xmin=1,ymin=1, $
       xticklen=xtl,yticklen=ytl, $
       ytitle='', $
       xtickdir=1)
rt=text(x0+2*dx+ddx+0.01,y1-0.02,'(c) Mg VII 278.39 '+string(197b)+'!c      & Si VII 278.46 '+string(197b),font_size=fs+1,target=q,vertical_align=1.0)

getmin=min(abs(lines.wvl-wvl),imin)
x=findgen(101)/100*0.4-0.2 + wvl
g=gauss_sg(x,[lines[imin].peak,lines[imin].wvl+shift,lines[imin].width/2.355])
l=line_sg(x,[lines[imin].y0,lines[imin].y1])
func=g+l
rg1=plot(/overplot,x,func/1000.,th=th,color='red')
;
getmin=min(abs(lines.wvl-278.6),imin)
g=gauss_sg(x,[lines[imin].peak,lines[imin].wvl+shift,lines[imin].width/2.355])
func=l+g

rg2=plot(/overplot,x,func/1000.,th=th,color='red')

w.save,'plot_cool_line_profiles.png',width=2*xdim

return,w

END

