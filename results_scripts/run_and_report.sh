#!/bin/bash

EXTRA_PARAM=""
if [ -z "$1" ]
then
    echo "No alias provided"
else
    echo "Using $1 as alias"
    EXTRA_PARAM="$EXTRA_PARAM -a $1"
fi

sleep 1

source ./common_functions.sh

# clean all caches
runAt tpc-g bash ~/clean_caches.sh


# ensure that the VDriver remote dir is mounted
./ensure_mounted_runs_dir.sh


# To get the last ID
RUN_ID_F=/opt/VDriver/results/RUNID

if test -f ${RUN_ID_F}; then
    RUN_ID=`cat  ${RUN_ID_F}`
else
    RUN_ID=0
fi
RUN_ID=`expr $RUN_ID + 1`

TS_START=`date +%s`

# Start the load on the tpc-tenant performing a cleaning before
ssh tpc-tenant screen -d -m ./kill_background_work.sh
ssh tpc-tenant screen -d -m ./run_background_work.sh

bash start_stats_collection.sh $RUN_ID

# run the  benchmark
ssh postgres@tpc-driver "cd /opt/runs && bash run.sh"
#echo "Sleep for 30 seconds"
#sleep 30


# Folder where resides the results

RUN_RESULTS_FOLDER="/opt/VDriver/results/$(cat /opt/VDriver/results/RUNID)"

TS_END=`date +%s`

bash gather_stats_data.sh $RUN_ID

# Create a temporary folder to  store the images
IMG_FOLDER=/tmp/img_tmp_${RUN_ID}
mkdir ${IMG_FOLDER}

cd ../munin_chart_extractor
python MuninChartWrapper.py -p system_run_${RUN_ID} -f ${IMG_FOLDER} -s ${TS_START} -e ${TS_END}
cd -

python chart_run.py -r "${RUN_RESULTS_FOLDER}" -f ${IMG_FOLDER}

if [ -z "$EXTRA_PARAM" ]; then
   python report_generator.py -r "${RUN_RESULTS_FOLDER}" -f ${IMG_FOLDER}
else
   python report_generator.py -r "${RUN_RESULTS_FOLDER}" -f ${IMG_FOLDER} "$EXTRA_PARAM"
fi

echo  "done...."

