
Initial setup

Make sure you have Solarsoft installed, including the Hinode/EIS and CHIANTI packages.

Download the ch_dem GitHub repository

Download the GitHub repository:

Add the above two repositories to your IDL path:

Create a new directory where you will run the routines.


Procedure for deriving the EIS effective area curves

The procedure for deriving the new effective area curves is as follows. The author's versions of the files that are referred to available in the data sub-directory in this repository.

Calibrate the flare dataset in photon units (using the /photon keyword), and also in calibrated intensity units. The resulting level-1 files will need to be stored in different directories since they have the same name.

Using pixel_mask_gui and eis_mask_spectrum, select the spatial region for the continuum, and derive a mask spectrum in photon units and also in calibrated units. The photon mask spectrum prepared by the author is available in 20240930_225718_continuum_spec.sav, and the calibrated units spectrum is available in 20240930_225718_continuum_spec_calib0.sav.

Again using pixel_mask_gui and eis_mask_spectrum, select the spatial region for the continuum background, and derive the mask spectrum for the photon data only. The author's spectrum is available in 20240930_225718_continuum_bg.sav.

For the calibrated continuum mask spectrum, fit the LW channel lines that are needed for the DEM analysis. The results of the author's fits are stored in spec_gauss_fits_calib0.txt.
