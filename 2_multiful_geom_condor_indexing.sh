#!/bin/bash
###############################################################################
#
# submit jobs of HTcondor for indexing - v0.1
#
# (c) 2021 Gisu Park, PAL-XFEL
# Contact: gspark86@postech.ac.kr
#
# Last Modified Data : 2021/03/09
#
###############################################################################


PROCDIR="$( cd "$( dirname "$0" )" && pwd -P )"

if [ ! -d file_stream ];then
        mkdir file_stream
fi

if [ ! -d log ];then
        mkdir log
fi

##indexamajig -g pal.geom --indexing=mosflm -j 72 -i r0081c00.lst -o SASE.stream --int-radius=3,4,5 -p mycell.pdb --threshold=600 --min-srn=4 --min-gradient=100000

usage() {
        err_msg "Usage: $0 -g geom_folder_name -i mosflm -j 36 -f r0081c00.lst or all -o SASE.stream -p mycell.pdb -e "--int-radius=3,4,5 --threshold=600 --min-srn=4 --min-gradient=100000" "
}
err_msg() { echo "$@" ; } >&2
err_msg_f() { err_msg "-f option requires input file list";}
err_msg_g() { err_msg "-g option requires geometry file folder (ex: geom_files)";}
err_msg_i() { err_msg "-i option requires indexing method ex)mosflm, xds. asdf, dirax, xgandalf";}
err_msg_j() { err_msg "-j option requires number of cpu";}
err_msg_o() { err_msg "-o option requires stream file name";}
err_msg_p() { err_msg "-o option requires *.pdb file";}
err_msg_e() { err_msg "-e option another parameter such as -p, --int-radius, --threshold, --min-srn, --min-fradient ";}


if [ "$#" -lt 10 ]; then
        usage
        exit
fi

geom_folder=""

while getopts ":g:i:j:f:e:o:p:" opt; do
        case $opt in
                g)
			geom_folder=$OPTARG
			#echo $geom_folder
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


MEM=360

if [ -n "$geom_folder" ]; then
	for geom_file in ./"$geom_folder"/*.geom
	do
        	if [ -f "$geom_file" ]; then
    			if [ $f == "all" ]; then

	        		ls file_list/* | while read line
		        	do
	
        		        	runnum_lst=`echo $line | awk -F'/' '{print $2}'`
	        		        runnum=`echo $runnum_lst | awk -F'.' '{print $1}'`
	                		streamname=`echo $o | awk -F'.' '{print $1}'`
	        	        	#echo $runnum_lst $runnum $streamname
			                echo "indexamajig" "-g" $geom_file "--indexing="$i "-j "$j "-f "$runnum_lst "-o "$runnum_$i_$streamname_$o $e "-p "$p
	
		        	        condor_submit <<-EOF
			                universe = vanilla
	        		        should_transfer_files = IF_NEEDED
	                		output = log/${i}_${runnum}_${streamname}_condor.out
		                	error = log/${i}_${runnum}_${streamname}_condor.error
		        	        log = log/${i}_${runnum}_${streamname}_condor.log
		                	request_cpus = ${j}
			                request_memory = $MEM GB
			                executable = 3_exec_indexing.sh
			                arguments = ${PROCDIR} ${geom_file} ${i} ${j} ${runnum_lst} ${runnum} ${o} ${p} ${e}
			                queue
					EOF

			        done
			else
			        runnum=`echo $f | awk -F'.' '{print $1}'`
	        		streamname=`echo $o | awk -F'.' '{print $1}'`
			        #echo $runnum_lst $runnum
			        echo "indexamajig" "-g" $geom_file "--indexing="$i "-j "$j "-f "$f "-o "$runnum_$i_$streamname_$o $e "-p "$p
	
			        condor_submit <<-EOF
			        universe = vanilla
			        should_transfer_files = IF_NEEDED
			        output = log/${i}_${runnum}_${streamname}_condor.out
			        error = log/${i}_${runnum}_${streamname}_condor.error
			        log = log/${i}_${runnum}_${streamname}_condor.log
			        request_cpus = $j
			        request_memory = $MEM GB
			        executable = 3_exec_indexing.sh
			        arguments = ${PROCDIR} ${geom_file} ${i} ${j} ${f} ${runnum} ${o} ${p} ${e}
			        queue
				EOF

			fi        
	        fi
	done
else
    echo "Error: -g option with folder path for geom files is required."
    usage
fi

