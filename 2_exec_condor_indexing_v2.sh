#!/bin/bash
###############################################################################
#
# submit jobs of HTcondor for indexing - v1.1
# This code includes indexmajig parameter modifying prompt.
# It is developed based on the "2_exec_condor_indexing.sh v0.1" by Gisu Park.
#
# (c) 2022 Sang-Ho Na, KISTI
# Contact: shna@kisti.re.kr
#
# Last Modified Data : 2022/11/21
#
###############################################################################

usage() {
	err_msg "CURRENT: indexmajig -g $6 -i $7 -j $8 -f $5 -o $9 -p $10 -e $1 $2 $3 $4"
}

err_msg() { echo "$@" ; } >&2

timedelay() { echo -n "."; for i in {seq 1 $1}; do sleep 1; printf "."; done; printf "\n"; }

create_file_list() {
        timedelay 3
        
		echo -e "\n ** PLEASE SELECT DIRECTORY(DEFAULT: pal)"
		echo "------------------------------------------------"
		echo -e "\n READ TARGET DIRECTORY(pal40)"

        read target
        target=${target,,}

        if [ -z target ]; then 
		target="pal" 
	fi
	
	if [ ! -d file_list ];then
		echo "mkdir file_list"
                mkdir file_list
    fi

    #user define:pal40, default:pal
	echo "READ TARGET DIRECTORY($target)"
	echo "DO CREATE FILE LIST"
	timedelay 3
	ls ../*${target}/*.cxi | while read line
	do
        	name=`echo $line | awk -F'/' '{print $3}' | awk -F '.' '{print $1}'| awk -F '-' '{print $2$3}'`
	        echo $line $name
        	echo $line > ./file_list/$name.lst
	done

	echo "=============================================="
	echo "!!!!!!! FILE LIST CREATION COMPLETE! !!!!!!!!!"
	timedelay
}

indexing() {
	# indexmajig default variables 
	declare -A opt=([g]='pal.geom' [i]='mosflm' [f]='all' [j]='72' [o]='SASE.stream' [p]='mycell.pdb'  [e]='--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000')
    	timedelay 3

	#move directory
	PROCDIR="$( cd "$( dirname "$0" )" && pwd -P )"

	if [ ! -d file_stream ];then 
		echo "mkdir file_stream"; 
		mkdir file_stream; 
	fi

	if [ ! -d log ];then 
		mkdir log; 
	fi

	echo -e "\n\n=============================================="
	echo "INDEXMAJIG DEFAULT PARAMETERS:"   
	usage ${opt[@]}
	echo "=============================================="

	exit_status=1
	while [ $exit_status -eq 1 ]
	do
		echo "SELECT WHAT YOU WANT MODIFY AND EDIT PARAMETER VALUE"
		echo "[g] geometry: -g ${opt['g']}"
		echo "[i] indexing method: -i ${opt['i']}"
		echo "[f] option requires input file list: -f ${opt['f']}"
		echo "[j] cpu number: -j ${opt['j']}"
		echo "[o] stream file: -o ${opt['o']}"
		echo "[p] pdb file: -p ${opt['p']}"
		echo "[e] another params: -e ${opt['e']}"
		echo "----------------------------------------------"
		echo "[x] exit edit & submit job(s)"
		echo "(ex. g sample.geom)"

		read -r optarg value
		case $optarg in
			g)
	        		opt['g']=$value
 		    		;;
        		i)
		                opt['i']=$value
            			;;
		        j)
        			opt['j']=$value
		                ;;
	        	f)
				opt['f']=$value
		                ;;
	        	e)
        			opt['e']=$value
		                ;;
	        	o)
        			opt['o']=$value
   				;;
			p)
	        		opt['p']=$value
		                ;;
			x)
				echo -e "\n=============================================="
				echo    "!!!!!!! INDEXMAJIG OPTIONS EDIT COMPLETE !!!!!!!"
				echo -e "\n=============================================="
				echo -e "JOB(S) WILL BE SUBMITTED"
				timedelay 
				exit_status=0
				;;
			\?)	
				err_msg "Invalid option: -$optarg"
				usage ${opt[@]} 
		esac
	done

	MEM=360


	if [ ${opt['f']} == "all" ]; then

		ls file_list/* | while read line
		do

			runnum_lst=`echo $line | awk -F'/' '{print $2}'`
			runnum=`echo $runnum_lst | awk -F'.' '{print $1}'`
			streamname=`echo $o | awk -F'.' '{print $1}'`
			#echo $runnum_lst $runnum $streamname
			echo "indexamajig" "-g" ${opt['g']} "--indexing="${opt['i']} "-j "${opt['j']} "-f "$runnum_lst "-o "$runnum_${opt['i']}_$streamname_$${opt['o']} ${opt['e']} "-p "${opt['p']}

			condor_submit <<-EOF
			universe = vanilla		
			should_transfer_files = IF_NEEDED
			output = ./log/${i}_${runnum}_${streamname}_condor.out
			error = ./log/${i}_${runnum}_${streamname}_condor.error
			log = ./log/${i}_${runnum}_${streamname}_condor.log
			request_cpus = $j
			request_memory = $MEM GB
			executable = 3_exec_indexing.sh
			arguments = ${PROCDIR} ${opt['g']} ${opt['i']} ${opt['j']} ${runnum_lst} ${runnum} ${opt['o']} ${opt['p']} ${opt['e']}
			queue
			EOF
		done
	else

		runnum=`echo $f | awk -F'.' '{print $1}'`
		streamname=`echo $o | awk -F'.' '{print $1}'`
		#echo $runnum_lst $runnum
		echo "indexamajig" "-g" ${opt['g']} "--indexing="${opt['i']} "-j "${opt['j']} "-f "$f "-o "$runnum_${opt['i']}_$streamname_${opt['o']} ${opt['e']} "-p "${opt['p']}

		condor_submit <<-EOF
		universe = vanilla		
		should_transfer_files = IF_NEEDED
		output = ./log/${i}_${runnum}_${streamname}_condor.out
		error = ./log/${i}_${runnum}_${streamname}_condor.error
		log = ./log/${i}_${runnum}_${streamname}_condor.log
		request_cpus = $j
		request_memory = $MEM GB
		executable = 3_exec_indexing.sh
		arguments = ${PROCDIR} ${opt['g']} ${opt['i']} ${opt['j']} ${opt['f']} ${runnum} ${opt['o']} ${opt['p']} ${opt['e']} 
		queue
		EOF

	fi

        echo "=============================================="
}


echo "=============================================="
echo "          HTConodor-based indexmajig          "
echo "=============================================="
sleep 3

echo "\n\n ** PLEASE SELECT WHAT YOU WANT!!"
echo "=============================================="
echo "          Create file list                      "
echo "=============================================="
sleep 1
echo "** DO YOU WNAT CREATE FILE LIST? (yes or no)"
echo " - CREATE FILE LIST OF CRYSTFEL FOR HTCONDOR"
echo "------------------------------------------------"
read input
input=${input,,}

if [ $input=="yes" ]; then
        create_file_list
fi

echo "=============================================="
echo "     BULK INDEXING PROCESS USING HTCONDOR     "
echo "=============================================="
sleep 1
echo "** DO EXECUTE INDEXMAJIG THORUGH HTCONDOR? (yes or no)"
echo " - SUBMIT HTCONDOR JOBS FOR INDEXMAJIG"
echo "------------------------------------------------"
read input
input=${input,,}

if [ $input=="yes" ]; then
        indexing
fi
