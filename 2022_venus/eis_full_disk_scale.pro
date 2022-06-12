
;+
;   This routine uses three of the large slot rasters during the
;   transit to obtain quiet-Sun scaling formulae that allow the Fe XII
;   195.12 full-disk intensity to be estimated from AIA 193 images.
;
;   Note that not all of the AIA images are full-disk. If the nearest
;   AIA image was not full-disk then I adjusted aia_time until I found
;   a full-disk image.
;-


;
; This is the scaling factor for slot intensities suggested by Young &
; Ugarte-Urra (2022).
;
eis_scale=0.86

file=eis_find_file('5-jun-2012 23:16',/lev)

map=eis_slot_map(file,195.12,/bg48,/quiet,calib=3)

junk=temporary(amap)

bdim=150
aia_offset=[0,-9]
aia_time='5-jun-2012 23:12'
pos=[-537,665]
eis_aia_int_compare,map,amap,bdim=bdim,aia_time=aia_time, $
                    aia_offset=aia_offset,output=output1, pos=pos,/quiet, $
                    eis_scale=eis_scale

;----
file=eis_find_file('6-jun-2012 00:30',/lev)

map=eis_slot_map(file,195.12,/bg48,/quiet,calib=3)

junk=temporary(amap)

;
; There are a couple of small bright points in the images, so I used
; these to check the coalignment.
;
bdim=150
aia_offset=[-5,-5]
aia_time='6-jun-2012 00:32'
pos=[-197,689]
eis_aia_int_compare,map,amap,bdim=bdim,aia_time=aia_time, $
                    aia_offset=aia_offset,output=output2,pos=pos,/quiet, $
                    eis_scale=eis_scale


;----
file=eis_find_file('6-jun-2012 02:05',/lev)

map=eis_slot_map(file,195.12,/bg48,/quiet,calib=3)

junk=temporary(amap)


;
; There are a couple of small bright points in the images, so I used
; these to check the coalignment.
;
bdim=150
aia_offset=[-3,-2]
aia_time='6-jun-2012 02:08'
pos=[200,687]
eis_aia_int_compare,map,amap,bdim=bdim,aia_time=aia_time, $
                    aia_offset=aia_offset,output=output3,pos=pos,/quiet, $
                    eis_scale=eis_scale


;---
;
; int_v_0 is the extrapolated Venus intensity for a zero annulus
; intensity. See Sect. 5 and Fig. 5 from the paper.
;
int_v_0=12.2

beta1=output1.int_eis/output1.int_aia*output1.int_aia_fd/int_v_0
beta2=output2.int_eis/output2.int_aia*output2.int_aia_fd/int_v_0
beta3=output3.int_eis/output3.int_aia*output3.int_aia_fd/int_v_0

print,'--------------------------------------'
print,'Beta values for the three data-sets: '
print,format='("  23:16 dataset: ",f6.2)',beta1
print,format='("  00:30 dataset: ",f6.2)',beta2
print,format='("  02:08 dataset: ",f6.2)',beta3
print,'--------------------------------------'
print,format='("Note: results assume Venus int of: ",f6.1)',int_v_0

int_eis_fd1=output1.int_eis/output1.int_aia*output1.int_aia_fd
int_eis_fd2=output2.int_eis/output2.int_aia*output2.int_aia_fd
int_eis_fd3=output3.int_eis/output3.int_aia*output3.int_aia_fd


print,''
print,'Data for latex table in paper'
print,format='(a5," & ",4(i3," & "),f5.1," \\")', $
      '23:16',round(output1.int_aia),round(output1.int_aia_fd), $
      round(output1.int_eis),round(output1.int_eis_fd),beta1
print,format='(a5," & ",4(i3," & "),f5.1," \\")', $
      '00;31',round(output2.int_aia),round(output2.int_aia_fd), $
      round(output2.int_eis),round(output2.int_eis_fd),beta2
print,format='(a5," & ",4(i3," & "),f5.1," \\")', $
      '02:06',round(output3.int_aia),round(output3.int_aia_fd), $
      round(output3.int_eis),round(output3.int_eis_fd),beta3

END
