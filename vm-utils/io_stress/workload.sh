#!/bin/bash

# vlines_phases = [840, 1560, 2280, 3000, 3720, 4440, 5160, 5880, 6600, 7320, 8040]

[ "$1" ] || {
    log "Duration Parameter needed"
    log "Usage $0 [number of run in seconds] "
    exit
}
TEST_TIME=$1
SECONDS=0

LOG_FILE="${HOME}/io_stress_workload_$(date +%Y%m%d_%H%M%S).log"

function log
{
  echo "$SECONDS  $(date +%c)  -- $@" | tee -a $LOG_FILE
}


log "Starting the test ..."
# kill any  stress-ng process
cd ~
ps uax | grep stress-ng | awk '{print $2}' | xargs -n1 kill -9
ps aux | grep stress-ng

cd stress-ng-0.*

# phase 1
log "Test --class io --all 2 --timeout $TEST_TIME"
( ./stress-ng --class io --all 2 --timeout $TEST_TIME 2>&1 ) >> $LOG_FILE

log "End of the fucking process!"
