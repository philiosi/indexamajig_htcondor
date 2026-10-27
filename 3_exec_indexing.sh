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
#                          Modified Data 2023/09/12 by Sang-Ho Na
#                          Modified Data 2024/08/23 by Sang-Ho Na
#                     Last Modified Data 2026/10/27 by Sang-Ho Na
###############################################################################

# The CrystFEL version is NOT hard-coded here any more.
#
# 2_submit_condor_indexing.sh submits with "getenv = True", so this job runs
# with the environment of the shell you submitted from: whatever you sourced
# before submitting (e.g. source /pal/lib/setup_crystfel-0.12.0_hdf5-1.10.5.sh)
# is what indexamajig will be.  CRYSTFEL_SETUP below is only a fallback for the
# case where no CrystFEL environment was set up at all; it stays at 0.9.1, the
# version these jobs have always used, so existing workflows are unchanged.

CRYSTFEL_SETUP="${CRYSTFEL_SETUP:-/pal/lib/setup_crystfel-0.9.1_hdf5-1.10.5.sh}"

if ! command -v indexamajig > /dev/null 2>&1; then
    echo "[INFO] no CrystFEL in the job environment, sourcing ${CRYSTFEL_SETUP}"
    source "${CRYSTFEL_SETUP}"
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/pal/htcondor/lib

# Always record which build actually ran.  Without this you cannot tell from
# the job logs whether the job used the version you think it did.
echo "[INFO] host        : $(hostname)"
echo "[INFO] indexamajig : $(command -v indexamajig)"
echo "[INFO] version     : $(indexamajig --version 2>&1 | head -1)"

# "${@:7}" instead of ${7}: condor splits the -e string into separate
# arguments, so passing only ${7} silently dropped every option after the first.
time indexamajig -g "${1}" --peaks=cxi --indexing="${2}" -j "${3}" -i "${4}" -o "${5}" -p "${6}" "${@:7}"
