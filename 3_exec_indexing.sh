#!/bin/bash
###############################################################################
#
# Indexmajin command line of crystfel - v2.0
# This script is developed based on the "3_exec_indexing.sh"
# with 2_condor_submit_indexing.sh".
#
# (c) 2023 Gisu Park(PAL-XFEL)		Sang-Ho Na(KISTI)
# Contact: gspark86@postech.ac.kr	shna@kisti.re.kr
#
# 3_exec_indexing.sh  	   Modified Data 2021/03/09 by Gisu Park
# 		              Last Modified Data 2024/06/05 by Sang-Ho Na
###############################################################################




#source /pal/lib/setup_crystfel-0.9.1_hdf5-1.10.5.sh
source /pal/lib/setup_crystfel-0.10.1_hdf5-1.10.5.sh
#source /pal/data/setup/setup.sh

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/pal/data/setup/lib:/pal/lib/pal-soft/ccp4-7.0/lib
#export PATH=$PATH:/pal/lib/pal-soft/ccp4-7.0/bin/:/pal/data/setup/lib:/pal/data/setup/XDS-INTEL64_Linux_x86_64

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/pal/htcondor/lib

time indexamajig -g ${1} --peaks=cxi --indexing=${2} -j ${3}  -i ${4} -o ${5} -p ${6} ${7}
