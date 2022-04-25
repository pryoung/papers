
FUNCTION plot_slit_slot_intensities_v2, wvl=wvl, bg_left=bg_left, bg_right=bg_right

;+
;   This produces Figure 6 for the paper.
;
; OPTIONAL INPUTS:
;      Wvl:   Wavelength to process (angstroms). Default is 195.12.
;
; KEYWORD PARAMETERS:
;      Bg_Left:  Only use background on left side of slot. Default is
;                to average left and right sides.
;      Bg_Right: Only use background on right side of slot. Default is
;                to average left and right sides.
;-


IF n_elements(wvl) EQ 0 THEN BEGIN
  wvl=195.12
  outdir='slit_slot_intensities'
  wvl_str=trim(floor(wvl))
ENDIF ELSE BEGIN
  wvl_str=trim(floor(wvl))
  outdir='slit_slot_intensities_'+wvl_str
ENDELSE 

list=file_search(outdir,'*.save')
n=n_elements(list)


;
; Here I get rid of known bad datasets.
;   1 - 20070504_0618 - slot seems to be a dark frame
;  40 - 20070519_1127 - slot inexplicably a factor 2 lower (eclipse?)
;
flag=bytarr(n)
flag[1]=1b
IF n GT 40 THEN flag[40]=1b


all_ratios1=-1.
all_ratios2=-1.
all_ints=-1.

file_count=0


FOR i=0,n-1 DO BEGIN
  restore,list[i]
  IF fmirr_slit EQ fmirr_slot AND yws_slit EQ yws_slot AND flag[i] NE 1 THEN BEGIN 
    int=eis_get_fitdata(fit)
   ;
   ; Get slot background
   ;
    CASE 1 OF
      keyword_set(bg_left): bkgd=bg1
      keyword_set(bg_right): bkgd=bg2
      ELSE: bkgd=bg
    ENDCASE
   ;
    ratio1=(int3-bkgd)/int
    ratio2=int3/int
    k=where(int1 GE 2740 OR int EQ -100,nk)
    IF nk NE 0 THEN BEGIN
      ratio1[k]=-100.
      ratio2[k]=-100.
    ENDIF
    all_ratios1=[all_ratios1,ratio1]
    all_ratios2=[all_ratios2,ratio2]
    all_ints=[all_ints,reform(int)]
    file_count=file_count+1
  ENDIF 
ENDFOR

all_ratios1=all_ratios1[1:*]
all_ratios2=all_ratios2[1:*]
int=all_ints[1:*]

bx=0.02
by=0.02

nx=ceil(alog10(3000)/bx)-floor(alog10(1)/bx)+1
ny=ceil(3/by)

r1=fltarr(nx,ny)
r2=fltarr(nx,ny)

xaxis=findgen(nx)*bx
yaxis=findgen(ny)*by

FOR i=0,nx-1 DO BEGIN
  FOR j=0,ny-1 DO BEGIN
    rx=[i*bx,(i+1)*bx]
    ry=[j*by,(j+1)*by]
    k=where(alog10(int) GE rx[0] AND alog10(int) LT rx[1] AND $
            all_ratios1 GE ry[0] AND all_ratios1 LT ry[1],nk1)
    k=where(alog10(int) GE rx[0] AND alog10(int) LT rx[1] AND $
            all_ratios2 GE ry[0] AND all_ratios2 LT ry[1],nk2)
    r1[i,j]=nk1
    r2[i,j]=nk2
  ENDFOR
ENDFOR


xdim=1000
ydim=420
w=window(dim=[xdim,ydim])

th=2
fs=12

x0=0.01
x1=0.99
dx=(x1-x0)/2.
ddx=0.06
y0=0.10
y1=0.98

xra=[1,3.4]
yra=[0.5,2.5]

;
; Set the intensity limit, below which background subtraction is important.
;
lim=150.

k=where(int GE lim AND all_ratios2 NE -100.,nk)
m2=mean(all_ratios2[k])
s2=stdev(all_ratios2[k])
print,format='("Mean for original data: ",f7.3," +/-",f7.3)',m2,s2

k=where(int GE lim AND all_ratios1 NE -100.,nk)
m1=mean(all_ratios1[k])
s1=stdev(all_ratios1[k])
print,format='("Mean for bg-subtracted data: ",f7.3," +/-",f7.3)',m1,s1

;
; I've added int > 0 as I found an example where int was 0
; (causing an Inf in calculation).
;
k=where(all_ratios1 NE -100. AND int GT 0.,nk)
m1a=mean(all_ratios1[k])
s1a=stdev(all_ratios1[k])
print,format='("Mean for bg-subtracted data (all): ",f7.3," +/-",f7.3)',m1a,s1a


img2=r2^0.7
img2=max(img2)-img2
p=image(img2,xaxis,yaxis,axis_style=2, $
        pos=[x0+ddx,y0,x0+dx,y1],/current, $
        xrange=xra,yrange=yra,/xsty,/ysty, $
        xth=th,yth=th,xticklen=0.015,yticklen=0.015,font_size=fs, $
        ytitle='Slot/slit intensity ratio', $
        xtitle='Log!d10!n ( Slit intensity / erg cm!u-2!n s!u-1!n sr!u-1!n )')
pl=plot(/overplot,p.xrange,[1,1])
pl2=plot(/overplot,color='dodger blue',th=2,[alog10(lim),p.xrange[1]],m2*[1,1])
pt=text(1.1,2.3,/data,'(a)',font_size=fs+2,target=p)

img1=r1^0.7
img1=max(img1)-img1
q=image(img1,xaxis,yaxis,axis_style=2, $
        pos=[x0+dx+ddx,y0,x0+2*dx,y1],/current, $
        xrange=xra,yrange=yra,/xsty,/ysty, $
        xth=th,yth=th,xticklen=0.015,yticklen=0.015,font_size=fs, $
        xtitle='Log!d10!n ( Slit intensity / erg cm!u-2!n s!u-1!n sr!u-1!n )')
ql=plot(/overplot,q.xrange,[1,1])
ql2=plot(/overplot,color='dodger blue',th=2,[q.xrange[0],q.xrange[1]],m1a*[1,1])
qt=text(1.1,2.3,/data,'(b) Background subtracted',font_size=fs+2,target=q)

outfile='plot_slit_slot_intensities_v2_'+wvl_str+'.png'
w.save,outfile,width=xdim


print,'Total number of files used: ',file_count

return,w

END
