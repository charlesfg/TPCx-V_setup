#!/bin/bash

[ "$1" ] || { >&2 echo "Id of the run should be provided"; exit 1; }


RUN=$1
# interval of collection
SECONDS=10
# default time im minutes to collect
LENGTH=200;

[ "$2" ] && { LENGTH=$2; }

cd ~
FILE_NAME=stats_$(hostname)_$(date +"%Y%m%d-%H%M")_run-${RUN}.bin
COUNT=$(($LENGTH*60/$SECONDS))


/usr/local/bin/sar -A -o $FILE_NAME $SECONDS $COUNT >/dev/null 2>&1
cd -

