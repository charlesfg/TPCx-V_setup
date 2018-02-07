#!/bin/bash


# Usage :
# $1 ->target filter
# $2 ->directory target
# $3 ->files
function copyTo(){
    TARGET=$1
    shift;
    TARGET_DIR=$1
    shift;
    for i in `cat /etc/hosts | grep $TARGET | awk '{print $2}'`; do  
        echo $i; 
        scp $@ ${i}:${TARGET_DIR} 
    done   
}


alias copytoall="copyTo tpc-g"
alias copytoa="copyTo tpc-g[0-9]a"
alias copytob="copyTo tpc-g[0-9]b"


function runAt(){
    TARGET=$1
    shift;
    for i in `cat /etc/hosts | grep $TARGET | awk '{print $2}'`; do  
        echo $i; 
        ssh $i $@; 
    done
}


alias runatall="runAt tpc-g"
alias runata="runAt tpc-g[0-9]a"
alias runatb="runAt tpc-g[0-9]b"


# clean all caches
runAt tpc-g bash ~/clean_caches.sh


# ensure that the VDriver remote dir is mounted
./ensure_mounted_runs_dir.sh

TS_START=`date +%s`

# Start the load on the tpc-tenant performing a cleaning before
ssh tpc-tenant screen -d -m ./kill_background_work.sh
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

