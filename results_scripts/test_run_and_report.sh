#!/bin/bash

TS_START=1492835256
# run the  benchmark
# To get the last ID
# cat /opt/VDriver/results/RUNID
RUN_ID=31

# Folder where resides the results
# /opt/VDriver/results/$(cat /opt/VDriver/results/RUNID)
RUN_RESULTS_FOLDER="/home/charles/Dropbox/Phd Portugal/oxum/31"

TS_END=1492835596


TS_START=$(($TS_END - 3600))

# Create a temporary folder to  store the images
IMG_FOLDER=/tmp/img_tmp_${RUN_ID}
mkdir ${IMG_FOLDER}

cd ../munin_chart_extractor
python MuninChartWrapper.py -p system_run_${RUN_ID} -f ${IMG_FOLDER} -s ${TS_START} -e ${TS_END}
cd -

python chart_run.py -r "${RUN_RESULTS_FOLDER}" -f ${IMG_FOLDER} -s 1500 -e 14500

python report_generator.py -r "${RUN_RESULTS_FOLDER}" -f ${IMG_FOLDER} -s 1500 -e 14500 -a "a as & <languers"
