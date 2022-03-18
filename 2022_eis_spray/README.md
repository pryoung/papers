
## A Spectroscopic Measurement of High Velocity Spray Plasma from an M-class Flare

## Journal: Advances in Space Research

## Author: Peter R. Young

This directory contains files for the paper "A Spectroscopic Measurement of High Velocity Spray Plasma from an M-class Flare" that has been submitted to Advances in Space Research.

### Figures

The figures for the paper were generated with the following IDL routines.

#### Figure 1 (plot_aia_6_panel.png)

The AIA images are provided in the GitHub repository.

```
IDL> w=plot_aia_6_panel()
```

#### Figure 2 (plot_spray_6_panel)

You will need to download the EIS file and calibrate it with eis_prep. 

```
IDL> w=plot_spray_6_panel()
```

#### Figure 3 (plot_fe12_1g_redshift.png)

```
IDL> w=plot_fe12_1g_redshift()
```

#### Figure 4 (filaments.png)

This was created with Powerpoint and exported to a png.

### Tables

The table contains Gaussian fit parameters. The spectra are stored in the save files:

```
20110216_1409_mask_exp21.save
20110216_1409_mask_exp22.save
```

The 'swspec' spectra were fit using `spec_gauss_eis`, and the fit parameters are contained in:

```
spec_gauss_fits_20110216_1409_mask_exp21.txt
spec_gauss_fits_20110216_1409_mask_exp22.txt
```

### Movies

Two movies are provided:

```
aia_193_movie.mp4
eis_movie.mp4
```

The first shows full-cadence AIA 193 images with a log scaling. The approximate location of the EIS slit is indicated by blue lines. The second shows an EIS move of the eruption in the format used for Figure 2 of the paper.

