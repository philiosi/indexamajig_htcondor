#!/bin/bash
#################################################################################
#
# submit jobs of HTcondor for indexing - v2.0
# This script is developed based on the "2_condor_indexing.sh".
# It submits condor job(s) with executable "3_exec_indexing.sh".
#
# (c) 2023 Gisu Park(PAL-XFEL)			Sang-Ho Na(KISTI)
# Contact: gspark86@postech.ac.kr		shna@kisti.re.kr
#
# 2_condor_indexing.sh				Last Modified Data : 2021/03/09 by Gisu Pakr
# 2_condor_submit_indexing.sh		Last Modified Data : 2023/09/12 by Sang-Ho Na
# 2_condor_submit_indexing_v2.sh	Last Modified Data : 2023/09/21 by Sang-Ho Na
##################################################################################

# debug print option 
  # ex) if [ $DEBUG -eq 1 ]; then echo "[debug] -f option is directory : mf"; fi
DEBUG=1

# Input
# The directory location is determined based on the input parameter.
geom_dir="" # Do not assign a value. -g option parameter
lst_dir="" # Do not assign a value. -f option parameter

# Output
# 'stream_foler' and 'log' directories are required. Please change directories what you want.
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

# asign memory
MEM=360

if [ ! -d $stream_dir ];then
		mkdir $stream_dir
fi

if [ ! -d $log ];then
		mkdir $log
fi

# define usage
usage() {
		err_msg "Usage: $0 -g abc.geom or geom_dir_name -i mosflm -j 36 -f r0081c00.lst or all -o SASE.stream -p mycell.pdb -e \"--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000\""
}
err_msg() { echo "$@" ; } >&2
err_msg_f() { err_msg "-f option requires lst file or directory, and please check the file exist and readable";}
err_msg_g() { err_msg "-g option requires geometry file or directory, and please check the file exist and readable";}
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
				if [ -d "$g" ]; then # f is direcetory
					# input type
					let "in_type=($in_type|2)"	
					geom_dir=$g
					if [ $DEBUG -eq 1 ]; then echo "[debug] -g option is directory : mg"; fi
				elif [ -f "$g" ]; then
					let "in_type=($in_type|1)"
					if [ $DEBUG -eq 1 ]; then echo "[debug] -g option is regular file : sg"; fi
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
				;;
			f)
				f=$OPTARG
				if [ -d "$f" ]; then # f is direcetory
					# input type
					let "in_type=($in_type|8)"
					lst_dir=$f
					if [ $DEBUG -eq 1 ]; then echo "[debug] -f option is directory : mf"; fi
				elif [ -f "$f" ]; then
					let "in_type=($in_type|4)"
					if [ $DEBUG -eq 1 ]; then echo "[debug] -f option is regular file : sf"; fi
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

if [ $DEBUG -eq 1 ]; then echo "[debug] geom_dir is $geom_dir"; fi
if [ $DEBUG -eq 1 ]; then echo "[debug] g is $g"; fi
if [ $DEBUG -eq 1 ]; then echo "[debug] lst_dir is $lst_dir"; fi
if [ $DEBUG -eq 1 ]; then echo "[debug] f is $f"; fi

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
	output = $log/${geom}_${i}_${runnum}_${streamname}_condor.out
	error = $log/${geom}_${i}_${runnum}_${streamname}_condor.error
	log = $log/${geom}_${i}_${runnum}_${streamname}_condor.log
	request_cpus = ${j}					
	request_memory = $MEM GB
	executable = 3_exec_indexing.sh
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
case $in_type in
	# - 1010 : 10 multi lst, multi geom
	10)	if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: multiful lst files and multiful geom files"; fi
		
		if [ $DEBUG -eq 1 ]; then echo "[debug] start 'while' for reading file list]"; fi 
		ls "$f"/* | while read file_line
		do
			f=$(basename "$file_line")
			
			ls "$geom_dir"/* | while read geom_line
			do
				g=$(basename "$geom_line")
				if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $lst_dir/$f and $geom_dir/$g"; fi 
				set_output_naming
				job_submit
			done
		done
		;;
	# - 1001 : 9  multi lst, single geom
	9)	if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: multiful lst files and single geom file"; fi
		
		ls "$f"/* | while read file_line
		do
			f=$(basename "$file_line")
			if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $lst_dir/$f and $g"; fi 
			set_output_naming
			job_submit
		done
		;;
	# - 0110 : 6  single lst, multi geom
	6)	if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: single lst file and multiful geom files"; fi
		ls "$geom_dir"/* | while read geom_line
		do
			g=$(basename "$geom_line")				
			if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $f and $geom_dir/$g"; fi 
			set_output_naming
			job_submit
		done
		;;
	# - 0101 : 5  single lst, single geom
	5)	if [ $DEBUG -eq 1 ]; then echo "[debug] Input Type $in_type: single lst file and single geom file"; fi
		if [ $DEBUG -eq 1 ]; then echo "[debug] submit condor job : $f and $g"; fi 
		set_output_naming
		job_submit
		;;
esac 
