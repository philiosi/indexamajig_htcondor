#!/bin/bash
#################################################################################################
#                 !!THIS IS TEST CODE.. PLEASE DO NOT USE!
# submit jobs of HTcondor for indexing - v2.0
# This script is developed based on the "2_condor_indexing.sh".
# It submits condor job(s) with executable "3_exec_indexing.sh".
#
# (c) 2023 Gisu Park(PAL-XFEL)         Sang-Ho Na(KISTI)
# Contact: gspark86@postech.ac.kr      shna@kisti.re.kr
#
# File history
# 2_condor_indexing.sh                 		Last Modified Data : 2021/03/09 by Gisu Pakr
# 2_condor_submit_indexing.sh          		Last Modified Data : 2023/09/12 by Sang-Ho Na
# 2_condor_submit_indexing_v2.sh       		Last Modified Data : 2023/09/21 by Sang-Ho Na
# 2_submit_condor_indexing.sh     			Last Modified Data : 2024/06/04 by Sang-Ho Na
# test_2_submit_condor_indexing_v2.sh		Last Modified Data : 2024/06/11 by Sang-Ho Na
#################################################################################################

# debug print option 
  # ex) if [ $DEBUG -eq 1 ]; then echo "[debug] -f option is directory : mf"; fi
DEBUG=1

# Input
# The directory location is determined based on the input parameter.
geom_dir="" # Do not assign a value. -g option parameter
lst_dir="" # Do not assign a value. -f option parameter

# Output
# 'stream_dir' and 'log' directories are required. Please change directories what you want.
# Default directory are 'file_stream' and 'log'
stream_dir="file_stream"
log="log"

# create folder for output and log
PROCDIR="$( cd "$( dirname "$0" )" && pwd -P )"

# fourc input type
# - 1010 : 10 multi lst, multi geom
# - 1001 : 9  multi lst, single geom
# - 0110 : 6  single lst, multi geom
# - 0101 : 5  single lst, single geom
in_type=0

# assign memory
MEM=360

if [ ! -d $stream_dir ]; then
    mkdir $stream_dir
fi

if [ ! -d $log ]; then
    mkdir $log
fi

# define usage
usage() {
    err_msg "Usage: $0 -g abc.geom or geom_dir_name -i mosflm -j 36 -f r0081c00.lst or all -o SASE.stream -p mycell.pdb -e \"--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000\""
}
err_msg() { echo "$@" ; } >&2
err_msg_f() { err_msg "-f option requires lst file or directory, and please check the file exist and readable"; }
err_msg_g() { err_msg "-g option requires geometry file or directory, and please check the file exist and readable"; }
err_msg_i() { err_msg "-i option requires indexing method ex)mosflm, xds, asdf, dirax, xgandalf"; }
err_msg_j() { err_msg "-j option requires number of cpu(max 72cores)"; }
err_msg_o() { err_msg "-o option requires stream file"; }
err_msg_p() { err_msg "-p option requires *.pdb file"; }
err_msg_e() { err_msg "-e option another parameter such as -p, --int-radius, --threshold, --min-srn, --min-fradient "; }

if [ "$#" -lt 10 ]; then
    usage
    exit
fi

# get indexmajig options
while getopts ":g:i:j:f:e:o:p:" opt; do
    case $opt in
        g)
            g=$OPTARG
            if [ -d "$g" ]; then # g is directory
                # input type
                let "in_type=($in_type|2)"    
                geom_dir=$g
                if [ $DEBUG -eq 1 ]; then echo "[debug] -g option is directory : $geom_dir"; fi
            elif [ -f "$g" ]; then
                let "in_type=($in_type|1)"
                if [ $DEBUG -eq 1 ]; then echo "[debug] -g option is regular file : $g"; fi
                if [[ "$g" == */* ]]; then
                    geom_dir=$(dirname "$g")
                    g=$(basename "$g")
                fi
            else
                err_msg_g
            fi
            ;;
        i)
            i=$OPTARG
            ;;
        j)
            j=$OPTARG
            if [ "$j" -gt 72 ]; then
                if [ $DEBUG -eq 1 ]; then echo "[error] Number of CPU cores specified ($j) is greater than 72"; fi
                exit 1
            fi
            ;;
        f)
            f=$OPTARG
            if [ -d "$f" ]; then # f is directory
                # input type
                let "in_type=($in_type|8)"
                lst_dir=$f
                if [ $DEBUG -eq 1 ]; then echo "[debug] -f option is directory : $lst_dir"; fi
            elif [ -f "$f" ]; then
                let "in_type=($in_type|4)"
                if [ $DEBUG -eq 1 ]; then echo "[debug] -f option is regular file : $f"; fi
                if [[ "$f" == */* ]]; then
                    lst_dir=$(dirname "$f")
                    f=$(basename "$f")
                fi
            else
                err_msg_f
            fi
            ;;
        e)
            e=$OPTARG
            ;;
        o)
            o=$OPTARG
            if [ ! -f "$o" ]; then
                if [ $DEBUG -eq 1 ]; then echo "[error] File $o does not exist. '-o' option requires stream file name"; fi
                exit 1
            fi
            ;;
        p)
            p=$OPTARG
            if [ ! -f "$p" ]; then
                if [ $DEBUG -eq 1 ]; then echo "[error] File $p does not exist. '-p' option requires *.pdb file"; fi
                exit 1
            fi
            ;;
        :)
            case $OPTARG in
                g) err_msg_g ;;
                i) err_msg_i ;;
                j) err_msg_j ;;
                f) err_msg_f ;;
                e) err_msg_e ;;
                o) err_msg_o ;;
                p) err_msg_p ;;
            esac
            usage
            ;;
        \?)
            err_msg "Invalid option: -$OPTARG"
            usage
            ;;
    esac
done

# job submit function
job_submit() { 
    geom=`echo $g | awk -F'.' '{print $1}'`
    got=$(realpath -m "${PROCDIR}/${geom_dir}/${g}")
    fot=$(realpath -m "${PROCDIR}/${lst_dir}/${f}")
    oot=${PROCDIR}/${stream_dir}/${geom}_${i}_${runnum}_${o}
    pot=${PROCDIR}/${p}

    condor_submit <<-EOF
universe = vanilla
should_transfer_files = IF_NEEDED
output = $log/${geom}_${i}_${runnum}_condor.out
error = $log/${geom}_${i}_${runnum}_condor.error
log = $log/${geom}_${i}_${runnum}_condor.log
request_cpus = ${j}                    
request_memory = $MEM GB
executable = 3_exec_indexing.sh
arguments = ${got} ${i} ${j} ${fot} ${oot} ${p} ${e}
queue
EOF

    echo "indexamajig -g $got --peaks=cxi --indexing=$i -j $j -i $fot -o $oot $e -p $pot"
}

set_output_naming() {
    cxi_basename=`basename "$f" .cxi`
    runnum=`echo $cxi_basename | awk -F'_' '{print $2}'`
    streamname=`echo $o | awk -F'.' '{print $1}'`
}


# Analyzing all files in the specific folder.
case $in_type in
    # - 1010 : 10 multi lst, multi geom
    10)
        if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: multiple lst files and multiple geom files"; fi
        
        if [ $DEBUG -eq 1 ]; then echo "[debug] start 'while' for reading file list"; fi 
        ls "$lst_dir"/* | while read file_line
        do
            f=$(basename "$file_line")
            
            while IFS= read -r cxi_file; do
                ls "$geom_dir"/* | while read geom_line
                do
                    g=$(basename "$geom_line")
                    if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $cxi_file and $geom_dir/$g"; fi 
                    f=$cxi_file  # Store the cxi file path in variable f
                    set_output_naming
                    job_submit
                done
            done < "$lst_dir/$f"  # Read from the lst file
        done
        ;;
    # - 1001 : 9  multi lst, single geom
    9)
        if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: multiple lst files and single geom file"; fi
        
        ls "$lst_dir"/* | while read file_line
        do
            f=$(basename "$file_line")
            
            # Read each line in the lst file and process each cxi file
            while IFS= read -r cxi_file; do
                if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $cxi_file and $g"; fi 
                f=$cxi_file  # Store the cxi file path in variable f
                set_output_naming
                job_submit
            done < "$lst_dir/$f"  # Read from the lst file
        done
        ;;
    # - 0110 : 6  single lst, multi geom
    6)
        if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: single lst file and multiple geom files"; fi
        
        while IFS= read -r cxi_file; do
            ls "$geom_dir"/* | while read geom_line
            do
                g=$(basename "$geom_line")
                if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $cxi_file and $geom_dir/$g"; fi 
                f=$cxi_file  # Store the cxi file path in variable f
                set_output_naming
                job_submit
            done
        done < "$f"  # Read from the lst file
        ;;
    # - 0101 : 5  single lst, single geom
    5)
        if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: single lst file and single geom file"; fi
        
        # Read each line in the lst file and process each cxi file
        while IFS= read -r cxi_file; do
            if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $cxi_file and $g"; fi 
            f=$cxi_file  # Store the cxi file path in variable f
            set_output_naming
            job_submit
        done < "$f"  # Read from the lst file
        ;;
esac

