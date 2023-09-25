#!/bin/bash

###############################################################################
#
# Create file list of crystfel for HTcondor - v0.1
#
# (c) 2021 Gisu Park, PAL-XFEL
# Contact: gspark86@postech.ac.kr
#
# Last Modified Data : 2021/03/09
#
###############################################################################


usage() {
	err_msg "Usage: $0 -d pal40 (default:pal)"
}
err_msg() { echo "$@" ; } >&2
err_msg_d() { err_msg "-d option requires directory name of *.cxi";}


if [ "$#" -lt 1 ]; then
	usage
	exit
fi

while getopts ":d:" opt; do
	case $opt in
		d)
			d=$OPTARG
			;;
		:)
			case $OPTARG in
				f) err_msg_f ;;
			esac
			usage
			;;
		\?)
			err_msg "Invalid option: -$OPTAGR"
			usage
			;;
	esac
done

if [ ! -d file_list ];then
	mkdir file_list
fi

#user define:pal40, default:pal
ls ../*${d}/*.cxi | while read line
do
	
	name=`echo $line | awk -F'/' '{print $3}' | awk -F '.' '{print $1}'| awk -F '-' '{print $2$3}'`
	echo $line $name
	echo $line > ./file_list/$name.lst
done

