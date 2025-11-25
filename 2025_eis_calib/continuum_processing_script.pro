
PRO continuum_processing_script

;+
; NAME:
;     CONTINUUM_PROCESSING_SCRIPT
;
; PURPOSE:
;     This is an IDL script for executing the series of commands that
;     results in new effective area curves for EIS, as derived from the
;     30-Sep-2024 22:57 flare dataset. The script requires various input
;     files that are provided in the GitHub repository.
;
; CATEGORY:
;     Hinode; EIS; calibration.
;
; CALLING SEQUENCE:
;     CONTINUUM_PROCESSING_SCRIPT
;
; INPUTS:
;     None.
;
; OUTPUTS:
;     Generates a number of files in the working directory. The new
;     effective area files are eis_eff_area_cont_*_v1.txt. The final
;     DEM is in mcmc_dem_calib_v1.sav, and the synthetic spectrum
;     generated from this DEM is in mcmc_dem_calib_v1_synt_spec.sav.
;
; EXAMPLE:
;     IDL> continuum_processing_script
;
; MODIFICATION HISTORY:
;     Ver.1, 24-Nov-2025, Peter Young
;-

;
; This is the location where the default data files are.
;
datadir=file_dirname(file_which('continuum_processing_script.pro'))
datadir=concat_dir(datadir,'data')

;
; Step 1
; ------
; Generate a DEM using the LW emission line intensities from the pre-launch
; calibration ("calib0").
;
ltemp=findgen(22)/10.+5.45
lpress=17.3
abund_file=concat_dir(datadir,'sun_photospheric_fip_bias_0_57.abund')
ioneq_file=concat_dir(datadir,'chianti_p1730.ioneq')
line_list_file=concat_dir(datadir,'line_list.txt')
line_fits_file=concat_dir(datadir,'spec_gauss_fits_calib0.txt')
;
line_data=ch_dem_read_line_ids(line_list_file,spec_gauss=line_fits_file,vshift=30)
ch_dem_write_lookup_tables,line_data,/execute
output=ch_dem_mcmc(line_data,ltemp=ltemp,lpress=lpress,interr_scale=0.15,ioneq_file=ioneq_file,abund_file=abund_file,/fix)
;
wdelete,0,1
;
dem_save_file='mcmc_dem_calib0.sav'
save,file=dem_save_file,output
message,/info,/cont,'The calib0 DEM has been saved to '+dem_save_file+'.'

;
; Step 2
; ------
; After creating the DEM, write it out to the CHIANTI format.
;
dem_file='flare_mcmc_calib0.dem'
write_chianti_dem,output,dem_file,/overwrite
message,/info,/cont,'The calib0 DEM has been written to '+dem_file+'.'

;
; Step 3
; ------
; Now create a synthetic spectrum (with continuum) from the DEM using CHIANTI.
;
dem_file='flare_mcmc_calib0.dem'
lpress=17.3
abund_file=concat_dir(datadir,'sun_photospheric_fip_bias_0_57.abund')
ioneq_file=concat_dir(datadir,'chianti_p1730.ioneq')
sngl_ion=['fe_14','fe_15','fe_16','fe_17','fe_21','fe_22','fe_23','fe_24','si_7','ti_20','si_10']
ch_synthetic,170,292,output=output,pressure=10.^lpress,sngl_ion=sngl_ion,adv=0,ioneq_name=ioneq_file,dem_name=dem_file,/lookup,/photon
junk=temporary(lambda)
make_chianti_spec,output,lambda,spectrum,abund_name=abund_file,/continuum,/lookup,instr_fwhm=0.06,bin_size=0.0223,/photon
;
synt_spec_file='mcmc_dem_calib0_synt_spec.sav'
save,file=synt_spec_file,spectrum
message,/info,/cont,'The calib0 synthetic spectrum has been written to '+synt_spec_file+'.'

;
; Step 4
; ------
; Now write new effective area curves (this has to be done in the
; 2025_fe21 directory).
;
dem_file='flare_mcmc_calib0.dem'
lpress=17.3
abund_file=concat_dir(datadir,'sun_photospheric_fip_bias_0_57.abund')
ioneq_file=concat_dir(datadir,'chianti_p1730.ioneq')
ea_files=write_effective_area(ioneq_file=ioneq_file,abund_file=abund_file,log_press=lpress,dem_file=dem_file,label='v1')

;
; Step 5
; ------
; Begin the next iteration by creating a new line intensity file using the
; new effective area curve. This is referred to as "calib_v1".
; ea_files is defined in Step 4.
;
line_fits_file=concat_dir(datadir,'spec_gauss_fits_calib0.txt')
update_spec_gauss_ints,line_fits_file,'spec_gauss_fits_calib_v1.txt',ea_files=ea_files,/overwrite,/verbose

;
; Step 6
; ------
; Use the new intensity file to calculate the calib_v1 DEM.
;
ltemp=findgen(22)/10.+5.45
lpress=17.3
abund_file=concat_dir(datadir,'sun_photospheric_fip_bias_0_57.abund')
ioneq_file=concat_dir(datadir,'chianti_p1730.ioneq')
line_list_file=concat_dir(datadir,'line_list.txt')
line_fits_file='spec_gauss_fits_calib_v1.txt'
;
line_data=ch_dem_read_line_ids(line_list_file,spec_gauss=line_fits_file,vshift=30)
ch_dem_write_lookup_tables,line_data,/execute
output=ch_dem_mcmc(line_data,ltemp=ltemp,lpress=lpress,interr_scale=0.15,ioneq_file=ioneq_file,abund_file=abund_file,/fix)
;
wdelete,0,1
;
dem_save_file='mcmc_dem_calib_v1.sav'
save,file=dem_save_file,output
message,/info,/cont,'The calib_v1 DEM has been saved to '+dem_save_file+'.'

;
; Step 7
; ------
; Write the DEM out to the CHIANTI format
;
dem_file='flare_mcmc_calib_v1.dem'
write_chianti_dem,output,dem_file,/overwrite
message,/info,/cont,'The calib_v1 DEM has been written to '+dem_file+'.'

;
; Step 8
; ------
; Now create a synthetic spectrum (with continuum) from the DEM
;
dem_file='flare_mcmc_calib_v1.dem'
lpress=17.3
abund_file=concat_dir(datadir,'sun_photospheric_fip_bias_0_57.abund')
ioneq_file=concat_dir(datadir,'chianti_p1730.ioneq')
sngl_ion=['fe_14','fe_15','fe_16','fe_17','fe_21','fe_22','fe_23','fe_24','si_7','ti_20','si_10']
ch_synthetic,170,292,output=output,pressure=10.^lpress,sngl_ion=sngl_ion,adv=0,ioneq_name=ioneq_file,dem_name=dem_file,/lookup,/photon
junk=temporary(lambda)
make_chianti_spec,output,lambda,spectrum,abund_name=abund_file,/continuum,/lookup,instr_fwhm=0.06,bin_size=0.0223,/photon
;
synt_spec_file='mcmc_dem_calib_v1_synt_spec.sav'
save,file=synt_spec_file,spectrum
message,/info,/cont,'The calib_v1 synthetic spectrum has been written to '+synt_spec_file+'.'

;
; Step 9
; ------
; Now write the final effective area curves.
;
;; dem_file='flare_mcmc_calib_v1.dem'
;; lpress=17.3
;; abund_file=concat_dir(datadir,'sun_photospheric_fip_bias_0_57.abund')
;; ioneq_file=concat_dir(datadir,'chianti_p1730.ioneq')
;; write_effective_area,'v1',ioneq_file=ioneq_file,abund_file=abund_file,log_press=lpress,dem_file=dem_file

END
