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

SECONDS=0

ssh tpc-driver reboot

# clean all caches
copyTo tpc-g ~ clean_caches.sh
copyTo tpc-g ~ clean_space_centos.sh

ssh tpc-driver uptime
# ensure that the VDriver remote dir is mounted
./ensure_mounted_runs_dir.sh

ssh tpc-tenant 'find ~ -name tc_tester\*.log -exec rm  {} \; '

runAt tpc-g 'bash ~/clean_caches.sh'
runAt tpc-g 'bash ~/clean_space_centos.sh'
#runAt tpc-g 'test -e /dbstore/backup && rm -rf /dbstore/backup/*'
runAt tpc-g 'test -e /dbstore/tpcv-data/pg_log && rm -rf /dbstore/tpcv-data/pg_log/*'
#runAt tpc-g 'psql -U tpcv -c VACUUM'
# Restore the database database
#copyTo tpc-g.b ~ restore_db.sh
#runAt tpc-g.b 'bash restore_db.sh'
./check_dbs_connectivity.sh

ssh tpc-driver 'cd /opt/runs && bash -x kill_run.sh'


# Start the load on the tpc-tenant performing a cleaning before
# for i in tpc-tenant tpc-tenant2 tpc-tenant3;
# do
#     ssh $i screen -d -m su wl_user -c /home/wl_user/kill_background_work.sh
# done
# 
# for i in tpc-tenant tpc-tenant2 tpc-tenant3;
# do
#     ssh $i screen -d -m su wl_user -c /home/wl_user/run_background_work.sh
# done


# Start Network Monitor
./start_iperf.sh

# To get the last ID
RUN_ID_F=/opt/VDriver/results/RUNID

if test -f ${RUN_ID_F}; then
    RUN_ID=`cat  ${RUN_ID_F}`
else
    RUN_ID=0
fi
RUN_ID=`expr $RUN_ID + 1`

scp start_iperf_collection.sh tpc-driver:~
ssh tpc-driver screen -d -m ./start_iperf_collection.sh $RUN_ID

#ssh tpc-tenant2 screen -d -m ./kill_background_work.sh
#ssh tpc-tenant3 screen -d -m ./kill_background_work.sh
# 
# echo $(date +%Y-%m-%d_%H%M%S) >> /root/perftest
# CNT=$(wc -l /root/perftest | awk '{print $1}' )
# LABEL="NONE"
# case $CNT  in
#     1)
#         LABEL="CPU tenant[1]"
#         echo $LABEL
#         ssh tpc-tenant screen -d -m ./run_background_work_tests.sh 2
#         ;;
#     2)
#         LABEL="IO tenant[1]"
#         echo $LABEL
#         ssh tpc-tenant screen -d -m ./run_background_work_tests.sh 1
#         ;;
#     3)
#         LABEL="CPU tenant[1,2]"
#         echo $LABEL
#         ssh tpc-tenant screen -d -m ./run_background_work_tests.sh 2
#         ssh tpc-tenant2 screen -d -m ./run_background_work_tests.sh 2
#         ;;
#     4)
#         LABEL="CPU tenant[1,2,3]"
#         echo $LABEL
#         ssh tpc-tenant screen -d -m ./run_background_work_tests.sh 2
#         ssh tpc-tenant2 screen -d -m ./run_background_work_tests.sh 2
#         ssh tpc-tenant3 screen -d -m ./run_background_work_tests.sh 2
#         ;;
#     5)
#         LABEL="IO em tenants[1,2]"
#         echo $LABEL
#         ssh tpc-tenant screen -d -m ./run_background_work_tests.sh 1
#         ssh tpc-tenant2 screen -d -m ./run_background_work_tests.sh 1
#         ;;
#     *)
#         echo "Cabo ... "
# esac
# echo $LABEL > /tmp/run_alias
# do some work
duration=$SECONDS
echo "$(($duration / 60)):$(($duration % 60)) $((hostname))" 
