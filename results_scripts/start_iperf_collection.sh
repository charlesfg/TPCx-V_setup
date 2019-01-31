#!/bin/bash
# workstation
#IPERF_DIR=/home/charles/Downloads/iperf-master/src
# oxum
#IPERF_DIR=/var/tpcv/iperf-master/src
# tpc-driver
IPERF_DIR=/root/iperf-master/src

# workstation
#RESULTS_DIR=/tmp
# tpc-driver
RESULTS_DIR=/root/iperf_logs

[ "$1" ] || { >&2 echo "Id of the run should be provided"; exit 1; }


SERVER=150.164.203.68
#SERVER=localhost

RUN=$1
# default time im minutes to collect
LENGTH=125;

[ "$2" ] && { LENGTH=$2;}

# create if directory does  not exist
test -d ${RESULTS_DIR}/${RUN} || mkdir ${RESULTS_DIR}/${RUN}

cd ${IPERF_DIR}

for i in $(seq 1 ${LENGTH});
do
    ./iperf3 -c $SERVER -J > ${RESULTS_DIR}/${RUN}/RUN_${RUN}_$(date +"%F_%T").json
    sleep 50
done