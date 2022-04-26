
# Paper: Young & Viall, Scattered light in EIS and AIA datasets

This repository contains files used for data analysis and generating figures. All software are written in IDL. The EIS and AIA Solarsoft libraries are required.

## AIA data analysis

The key routine is `aia_get_venus.pro`. This takes the set of full-disk AIA images (see below for the full list of files used in the paper). For each one, a sub-image around Venus is displayed in a graphics window. The user clicks on the approximate center of Venus in the image. The next image is then shown, and the user again clicks on the center. This is repeated for the full set of images and an IDL structure is output.

````
r=aia_get_venus()
````

The file `aia_venus_results.save` contains several structures created with `aia_get_venus`. For example, `d050` contains the results for using an outer annulus radius of 50 arcsec and for the set of 26 images at 20 min cadence. `d050x` is the same, but for the extended series of 32 images (see paper for more details). `d100` uses an outer radius of 100 arcsec.

If you have already created a structure and you want to modify the outer radius (for example), then you can send the previous structure as an input to avoid manually selecting the Venus positions.

````
r=aia_get_venus(radius=100,data=d050)
````

## EIS data analysis

The routine `eis_venus_select.pro` was written to derive the Fe XII 195.12 intensity at the center of the Venus shadow. The procedure for running this routine is indicated in the example below:

```
file=eis_find_file('5-jun-2012 23:00',/lev,/seq)
d=eis_venus_select(file=file[0])
```

There are 20 files for this particular pointing, and eis_venus_select is called separately for each of the files. A graphics window is opened and an image will appear. If it's too small, just click outside the plot window, resize the window, then start again. The steps for running the routine are:

1. In the first image click at the approximate center of the Venus shadow. Based on this, the routine identifies the particular exposure that contains most of the Venus shadow.
2. The second image shows a close-up of Venus from the selected exposure. Carefully select the center of the shadow with the mouse. If the center of Venus is too close to the edge of the window, then click somewhere outside the plot window to exit.
3. If you select the center, but see that the displayed box (used to compute the average intensity at the center of the shadow) extends outside of the slot image, then you'll have to manually open the results file and delete the entry.
4. The third panel will show the image from panel 1 again, but with the new Venus position displayed. Make sure that tit's centered in the shadow, as expected.
5. The fourth panel shows the image of the Venus annulus. Make sure that this looks OK. In particular, that you do not see part of the Venus shadow in the annulus.
6. The results get appended into the text file 'eis_venus_new_results.txt'.

## Reading and plotting the EIS results

The results can be read into a structure with

```
d=read_eis_venus_results()
```

The plot used for the paper was generated with:

```
p=plot_eis_venus_ints()
```



## Orbital twilight corrections

The slot sequences beginning at 06/03:23 and 06/05:01 began during orbital twilight and so the intensities are suppressed. This was corrected by using a uniform intensity area of the slot raster maps and then comparing the intensity in the early rasters with those of the later rasters. Correction factors were obtained with the routine eis_eclipse_raster. The corrections only apply to the first two files in the sequence.

### 06/03:23
```
file=eis_find_file('6-jun-2012 03:30',/lev,/seq)
eis_eclipse_scale,file,yrange=[300,370]
File:  0   Ratios:      0.812     0.272
File:  1   Ratios:      0.983     0.965
```

### 06/05:01
```
file=eis_find_file('6-jun-2012 05:10',/lev,/seq)
eis_eclipse_scale,file,yrange=[270,320]
File:  0   Ratios:      0.704     0.139
File:  1   Ratios:      0.975     0.929
```

## Figures

### Figure 1 - plot_aia_venus.png

Shows track of Venus on AIA 193 image.

````
w=plot_aia_venus()
````

### Figure 2 - plot_aia_venus_ints.png

Two-panel plot showing variation of AIA Venus intensity during transit and relation to annulus intensity.

````
w=plot_aia_venus_ints()
````

### Figure 3 - plot_aia_20161123.png

Shows AIA sub-image for a coronal hole.

````
w=plot_aia_20161123()
````

### Figure 4 - plot_eis_image.png

Two panel plot showing slot raster image of Venus (left) and close-up of the Venus exposure (right).

````
w=plot_eis_image()
````

### Figure 5 - plot_eis_venus_ints.png

Two panel plot similar to Figure 2, but for EIS.

````
w=plot_eis_venus_ints()
````

### Figure 6 - plot_20161123_regions.png

Shows an EIS raster with locations used for coronal hole and quiet Sun.

````
w=plot_20161123_regions()
````

### Figure 7 - plot_aia_ann_rad_comparison.png

This is a 2x2 panel plot showing the effect of varying the annulus radius.

```
w=plot_aia_ann_rad_comparison()
```

## AIA files

The following is the list of 32 AIA 193 files that were used for the AIA analysis. They can be downloaded from the JSOC of VSO. In order to use the routine `aia_get_venus` you should put these files in the sub-directory `/aia`.

```
aia.lev1.193A_2012-06-05T21_00_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T21_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T21_40_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T21_50_31.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T22_00_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T22_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T22_40_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T23_00_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T23_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-05T23_40_01.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T00_00_01.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T00_20_01.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T00_40_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T01_00_55.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T01_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T01_40_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T02_00_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T02_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T02_40_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T03_00_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T03_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T03_40_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T03_50_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T04_00_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T04_10_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T04_15_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T04_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T04_40_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T04_50_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T05_00_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T05_20_07.84Z.image_lev1.fits
aia.lev1.193A_2012-06-06T05_40_07.84Z.image_lev1.fits
```
