#!/bin/bash
###############################################################################
#
# submit jobs of HTcondor for indexing - v2.0
# This script is developed based on the "2_condor_indexing.sh".
# It submits condor job(s) with executable "3_exec_indexing.sh".
#
# (c) 2023 Gisu Park(PAL-XFEL)          Sang-Ho Na(KISTI)
# Contact: gspark86@postech.ac.kr       shna@kisti.re.kr
#
# 2_condor_indexing.sh          Last Modified Data : 2021/03/09 by Gisu Pakr
# 2_condor_submit_indexing.sh   Last Modified Data : 2023/09/12 by Sang-Ho Na
###############################################################################

# create folder for output and log
PROCDIR="$( cd "$( dirname "$0" )" && pwd -P )"

# asign memory
MEM=360

# The directory location is determined based on the input parameter.
geom_folder="" # Do not assign a value.
file_folder="" # Do not assign a value.

# 'stream_foler' and 'log' directories are required. Please change directories what you want.
# Default directory are 'file_stream' and 'log'
stream_folder="file_stream"
log="log"

if [ ! -d $stream_folder ];then
        mkdir $stream_folder
fi

if [ ! -d $log ];then
        mkdir $log
fi

# define usage
usage() {
        err_msg "Usage: $0 -g abc.geom or geom_folder_name -i mosflm -j 36 -f r0081c00.lst or all -o SASE.stream -p mycell.pdb -e \"--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000\""
}
err_msg() { echo "$@" ; } >&2
err_msg_f() { err_msg "-f option requires input file list";}
err_msg_g() { err_msg "-g option requires geometry file or folder (ex: abc.geom or geom_files)";}
err_msg_i() { err_msg "-i option requires indexing method ex)mosflm, xds. asdf, dirax, xgandalf";}
err_msg_j() { err_msg "-j option requires number of cpu";}
err_msg_o() { err_msg "-o option requires stream file name";}
err_msg_p() { err_msg "-o option requires *.pdb file";}
err_msg_e() { err_msg "-e option another parameter such as -p, --int-radius, --threshold, --min-srn, --min-fradient ";}


if [ "$#" -lt 10 ]; then
        usage
        exit
fi

# get indexmajig options
while getopts ":g:i:j:f:e:o:p:" opt; do
        case $opt in
                g)
                        g=$OPTARG
			;;
                i)
                        i=$OPTARG
                        ;;
                j)
                        j=$OPTARG
                        ;;
                f)
	                f=$OPTARG
                        ;;
                e)
                        e=$OPTARG
                        ;;
                o)
                        o=$OPTARG
                        ;;
                p)
                        p=$OPTARG
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
                        err_msg "Invalid option: -$OPTAGR"
                        usage
                        ;;
        esac
done

# job submit function
job_submit() { 
	geom=`echo $g | awk -F'.' '{print $1}'`
	got=$(realpath -m "${PROCDIR}/${geom_folder}/${g}")
	fot=$(realpath -m "${PROCDIR}/${file_folder}/${f}")
	oot=${PROCDIR}/${stream_folder}/${geom}_${i}_${runnum}_${o}
	pot=${PROCDIR}/${p}

	condor_submit <<-EOF
	universe = vanilla
	should_transfer_files = IF_NEEDED
	output = $log/${geom}_${i}_${runnum}_${streamname}_condor.out
	error = $log/${geom}_${i}_${runnum}_${streamname}_condor.error
	log = $log/${geom}_${i}_${runnum}_${streamname}_condor.log
	request_cpus = ${j}			        
	request_memory = $MEM GB
	executable = 3_exec_indexing_v2.sh
	arguments = ${got} ${i} ${j} ${fot} ${oot} ${p} ${e}
	queue
	EOF

	echo "indexamajig -g $got --peaks=cxi --inexing=$i -j $j -i $fot -o $oot $e -p $pot"
}

set_output_naming() {
	runnum=`echo $f | awk -F'.' '{print $1}'`
	streamname=`echo $o | awk -F'.' '{print $1}'`
}

# Analyzing all files in the specific folder.
if [ -d "$f" ]; then
	echo "[f option is directory $f]"
	ls "$f"/* | while read file_line
	do
		echo "[while for reading file list]"
		file_folder=$(dirname "$file_line")
		f=$(basename "$file_line")
		echo "[file is $file_folder/$f]"

		if [ -d "$g" ]; then
			echo "[g is directory $g]"
			#for geom_file in "$g" folder
			geom_folder=$g
			ls "$g"/* | while read geom_line
			do
				g=`echo $geom_line | awk -F'/' '{print $2}'`					
				set_output_naming
				job_submit
			done
		elif [ -f "$g" ]; then
			echo "[g includes path: $g]"
			geom_folder=$(dirname "$g")
	                g=$(basename "$g")
			echo "[geom path: $geom_folder]"
			echo "[g is $g]"
			set_output_naming
                        job_submit
		else
			echo "[g is specific geom file $g]"
			set_output_naming
			job_submit
		fi

	done
elif [ -f "$f" ]; then
	echo "[f option is path]"
	file_folder=$(dirname "$f")
        f=$(basename "$f")
	echo "[file is $file_folder/$f]"

	if [ -d "$g" ]; then
		echo "[g is directory $g]"
		#for geom_file in "$g" folder
		geom_folder=$g
		ls "$g"/* | while read geom_line
		do
			g=$(basename "$geom_line")
			set_output_naming
			job_submit
		done
	elif [ -f "$g" ]; then
                echo "[g includes path: $g]"
                geom_folder=$(dirname "$g")
                g=$(basename "$g")
                set_output_naming
                job_submit
	else
		set_output_naming
		job_submit
	fi
fi        

