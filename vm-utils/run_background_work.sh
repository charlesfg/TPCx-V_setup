#!/bin/bash
# kill any  stress-ng process 
cd ~
ps uax | grep stress-ng | awk '{print $2}' | xargs -n1 kill -9
ps aux | grep stress-ng
sleep 2
while true; do 
	# run at 10 < x < 60 
	EXEC_TIME=$[  ( $RANDOM % 50 )   + 10 ]
	# run at 5 < x < 15 
	SLEEP_TIME=$[ ( $RANDOM % 10 )  + 5 ]
	# memory usage  in MB 25 < x < 75
	MEM_LOAD=$[ ( $RANDOM % 50 ) + 25 ]
	# cpu load  5 < x < 25
	CPU_LOAD=$[ ( $RANDOM % 20 ) + 5 ]
	# switch from io and cpu
	if test $(($EXEC_TIME%2)) = 0;
	then
		stress-ng --udp 3 --timeout 1 &
		stress-ng --cpu 1 --cpu-load ${CPU_LOAD} --timeout ${EXEC_TIME} &
	else
		stress-ng --sock 3 --timeout 1 &
		stress-ng --cpu 1 --cpu-load ${CPU_LOAD} --timeout ${EXEC_TIME} &
	fi
    stress-ng --vm 1 --vm-bytes ${MEM_LOAD}M --vm-method all --verify --timeout ${EXEC_TIME} &
	sleep ${SLEEP_TIME}
done

