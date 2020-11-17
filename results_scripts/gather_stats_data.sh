#!/bin/bash
[ "$1" ] || { >&2 echo "Id of the run should be provided"; exit 1; }

source ./common_functions.sh

#kill stats
runAt tpc-g 'pkill -f collect_stats.sh'
pkill -f collect_stats.sh

# sync stats
cd /var/tpcv/sar_logs

copyFrom tpc-g '~/stats*.bin' .
mv -v ~/stats*.bin .
mkdir $1
mv stats*.bin $1

runAt tpc-g rm -v '~/stats*.bin'

cd -

