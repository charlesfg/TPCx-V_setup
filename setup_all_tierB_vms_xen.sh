#!/bin/bash -x
set -o errexit


declare -A IP_ADDR  # Create an associative array

IP_ADDR[tpc-g1a]=10.0.0.31
IP_ADDR[tpc-g1b1]=10.0.0.32
IP_ADDR[tpc-g1b2]=10.0.0.33
IP_ADDR[tpc-g2a]=10.0.0.34
IP_ADDR[tpc-g2b1]=10.0.0.35
IP_ADDR[tpc-g2b2]=10.0.0.36
IP_ADDR[tpc-g3a]=10.0.0.37
IP_ADDR[tpc-g3b1]=10.0.0.38
IP_ADDR[tpc-g3b2]=10.0.0.39
IP_ADDR[tpc-g4a]=10.0.0.40
IP_ADDR[tpc-g4b1]=10.0.0.41
IP_ADDR[tpc-g4b2]=10.0.0.42

for i in `seq 1 4`; do
	for j in 1 2; do
		# if [[ $i -eq 1 && $j -eq 1 ]]; then
		# 	continue;
		# fi
		# if [[ $i -eq 1 && $j -eq 2 ]]; then
		# 	continue;
		# fi
		L=tpc-g${i}b${j}		
		echo ":: Setup the $L VM .... "
		scp  run_tierB_setup.sh ${L}:~
		ssh ${L} bash run_tierB_setup.sh		
	done
done

