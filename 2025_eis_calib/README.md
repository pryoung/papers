# Deriving updated EIS effective area curves using the 30-Sep-2024 flare continuum

This repository contains IDL routines and data for deriving EIS effective area curves using the flare continuum measured from the 30-Sep-2024 22:57 flare dataset.

Make sure to do the initial setup. The author's analysis can be repeated exactly by simply calling the routine `continuum_process_script` which will derive new effective area curves using the author's data files in the repository.

Below I also describe how the data files are created so that the reader can repeat the analysis from scratch.

## Initial setup

All software are written in IDL.

Make sure you have Solarsoft installed, including the Hinode/EIS and CHIANTI packages.

* Download the ch_dem GitHub repository (`git clone https://github.com/pryoung/ch_dem`).
* Download this GitHub repository (`git clone https://github.com/pryoung/papers/`).
* Add the above two repositories to your IDL path.
* Create a new directory where you will run the routines.

## Deriving the effective area curves

After performing the above steps, go to your new directory and do:

`IDL> continuum_process_script`

This takes about 5 minutes to run. It will produce some graphical plots during the execution that come from the DEM code. A number of files are created by the routine. The new effective area files are stored in `eis_eff_area_cont_sw_v1.txt` and `eis_eff_area_cont_sw_v1.txt`, which can be read with read_effective_area.

## Procedure for deriving the EIS effective area curves

The above script uses ready-made data files created by the author. Below I describe how the data files are created.

* Calibrate the flare dataset in photon units (using the /photon keyword), and also in calibrated intensity units. The resulting level-1 files will need to be stored in different directories since they have the same name.
* Using `pixel_mask_gui` and `eis_mask_spectrum`, select the spatial region for the continuum, and derive a mask spectrum in photon units and also in calibrated units. The photon mask spectrum prepared by the author is available in `20240930_225718_continuum_spec.sav`, and the calibrated units spectrum is available in `20240930_225718_continuum_spec_calib0.sav`.
* Again using `pixel_mask_gui` and `eis_mask_spectrum`, select the spatial region for the continuum background, and derive the mask spectrum for the photon data only. The author's spectrum is available in `20240930_225718_continuum_bg.sav`.
* For the calibrated continuum mask spectrum, fit the LW channel lines that are needed for the DEM analysis. The results of the author's fits are stored in `spec_gauss_fits_calib0.txt`.
* Create the background-subtracted continuum photon spectrum by running `make_bg_subtracted_continuum_spectrum`.
* Use `spec_gauss_eis` with the `/continuum` option to make continuum measurements across the SW and LW channels.
* Perform fits to the continuum intensities with `continuum_spline_fit` and save results in `sw_cont_fit.sav` and `lw_cont_fit.sav`.

