
#
# Writes out the positions of Venus on AIA images as a function
# of time during the 2012 Venus transit. Code adapted from
# example given in SunPy documentation
#
# Requires a set of AIA 193 A images during the transit in the
# current working directory.
#
# Coordinates are sent to the file venus_coords.txt in the
# working directory.
# 
# Peter Young, 28-Jun-2024
#
import matplotlib.pyplot as plt

import astropy.units as u
from astropy.coordinates import SkyCoord, solar_system_ephemeris

import glob

import sunpy.map
from sunpy.coordinates import get_body_heliographic_stonyhurst


pattern='aia.lev1.193A_*.image_lev1.fits'
file_list=glob.glob(pattern)

file_list=sorted(file_list)

solar_system_ephemeris.set('de432s')

with open('venus_coords.txt','w') as outfile:
    for file in file_list:
          aiamap = sunpy.map.Map(file)
          venus = get_body_heliographic_stonyhurst('venus', aiamap.date, observer=aiamap.observer_coordinate)
          venus_hpc = venus.transform_to(aiamap.coordinate_frame)
          tx_format="{:10.1f}".format(venus_hpc.Tx.value)
          ty_format="{:10.1f}".format(venus_hpc.Ty.value)
          date_format=aiamap.date.value[:19]
          outfile.write(date_format+" "+tx_format+ty_format+"\n")

