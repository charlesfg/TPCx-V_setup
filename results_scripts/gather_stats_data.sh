#!/bin/bash
[ "$1" ] || { >&2 echo "Id of the run should be provided"; exit 1; }

source ./common_functions.sh
log "Start gathering stats data"
{
echo "kill stats process"
runAt tpc-g 'pkill -f collect_stats.sh'
runAt tpc-dr 'pkill -f collect_stats.sh'
pkill -f collect_stats.sh

echo " sync stats data"
cd /var/tpcv/sar_logs

copyFrom tpc-g '~/stats*.bin' .
copyFrom tpc-dr '~/stats*.bin' .

mv -v ~/stats*.bin .
mkdir $1
mv stats*.bin $1

echo " Removing remote data"
runAt tpc-g rm -v '~/stats*.bin'
runAt tpc-dr rm -v '~/stats*.bin'

cd -
} 2>&1  | tee -a $LOG_FILE

log "done" 
