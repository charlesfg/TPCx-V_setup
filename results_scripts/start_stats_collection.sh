#!/bin/bash 

[ "$1" ] || { >&2 echo "Id of the run should be provided"; exit 1; }

source ./common_functions.sh

log "Start  stats data collection process"
{
    echo  "Copying files to hosts"
    # copy script to all hosts
    copyTo tpc-g ~ collect_stats.sh
    copyTo tpc-dr ~ collect_stats.sh
    cp collect_stats.sh ~
    
    echo "Start the run remotely"
    runAt tpc-g screen -d -m ~/collect_stats.sh $1
    runAt tpc-dr screen -d -m ~/collect_stats.sh $1
    # start local
    screen -d -m ~/collect_stats.sh $1
} 2>&1  | tee -a $LOG_FILE

log "done"
