#!/bin/bash

# ensure that the VDriver remote dir is mounted
./ensure_mounted_runs_dir.sh

TS_START=`date +%s`

# Start the load on the tpc-tenant
ssh tpc-tenant screen -d -m ./run_background_work.sh

# run the  benchmark
ssh postgres@tpc-drive "cd /opt/runs && bash run.sh"

# To get the last ID
RUN_ID=$(cat /opt/VDriver/results/RUNID)

# Folder where resides the results

RUN_RESULTS_FOLDER="/opt/VDriver/results/$(cat /opt/VDriver/results/RUNID)"

TS_END=`date +%s`

# Create a temporary folder to  store the images
IMG_FOLDER=/tmp/img_tmp_${RUN_ID}
mkdir ${IMG_FOLDER}

cd ../munin_chart_extractor
python MuninChartWrapper.py -p system_run_${RUN_ID} -f ${IMG_FOLDER} -s ${TS_START} -e ${TS_END}
cd -

python chart_run.py -r "${RUN_RESULTS_FOLDER}" -f ${IMG_FOLDER}

python report_generator.py -r "${RUN_RESULTS_FOLDER}" -f ${IMG_FOLDER}


echo  "done...."

