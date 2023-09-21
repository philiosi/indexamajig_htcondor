#!/bin/bash
###############################################################################
#
# Indexmajin command line of crystfel - v0.1
#
# (c) 2021 Gisu Park, PAL-XFEL
# Contact: gspark86@postech.ac.kr
#
# Last Modified Data : 2021/03/09
#
###############################################################################




source /pal/lib/setup_crystfel-0.9.1_hdf5-1.10.5.sh
#source /pal/data/setup/setup.sh

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/pal/data/setup/lib:/pal/lib/pal-soft/ccp4-7.0/lib
#export PATH=$PATH:/pal/lib/pal-soft/ccp4-7.0/bin/:/pal/data/setup/lib:/pal/data/setup/XDS-INTEL64_Linux_x86_64

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/pal/data/staff/ue_191027_SFX/proc/cheetah/hdf5/test/lib

#echo "time indexamajig -g "${1}"/"${2} "--peaks=cxi --indexing="${3} "-j "${4}  "-i "${1}"/file_list/"${5} "-o "${1}"/file_stream/"${3}_${6}_${7} "-p "${1}"/"${8} ${9}

time indexamajig -g ${1}/${2} --peaks=cxi --indexing=${3} -j ${4}  -i ${1}/file_list/${5}  -o ${1}/file_stream/${3}_${6}_${7} -p ${1}/${8}  ${9} 


