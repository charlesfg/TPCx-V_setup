#!/usr/bin/env bash

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
runAt tpc-g 'test -e /dbstore/backup && rm -rf /dbstore/backup/*'
runAt tpc-g 'test -e /dbstore/tpcv-data/pg_log && rm -rf /dbstore/tpcv-data/pg_log/*'

ssh tpc-driver 'cd /opt/runs && bash -x kill_run.sh'

# ensure that the VDriver remote dir is mounted
./ensure_mounted_runs_dir.sh


# Start the load on the tpc-tenant performing a cleaning before
#ssh tpc-tenant screen -d -m ./kill_background_work.sh
#ssh tpc-tenant screen -d -m ./run_background_work.sh
