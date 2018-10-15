#!/bin/bash 

[ "$1" ] || { >&2 echo "Id of the run should be provided"; exit 1; }

source ./common_functions.sh

# copy script to all hosts
copyTo tpc- ~ collect_stats.sh
cp collect_stats.sh ~

# start remotely
runAt tpc- screen -d -m ~/collect_stats.sh $1
# start local
screen -d -m ~/collect_stats.sh $1
