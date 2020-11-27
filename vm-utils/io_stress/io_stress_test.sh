#!/bin/bash


# Attack the system triggering a 3vm IO intensive background workload

#
#  Source our common functions 
#
SECONDS=0

if [ -e ~/common.sh ]; then
    . ~/common.sh
else
    echo "Common functions not present, exiting!"
    exit;
fi

function stop_vms(){
    local vm_id=$1

    for i in $(xl list | fgrep $vm_id | awk '{print $1}');
    do
        xl shutdown ${i} 
        sleep 5
    done
    sleep 10
    for i in $(xl list | fgrep  $vm_id | awk '{print $1}');
    do
        xl destroy ${i} 
    done
}

function vm_is_running(){
    VM_ID=$1
    if test $(xl list $VM_ID | grep -v State | awk '{print $5}' | grep '[rb]' | wc -l ) -eq 1;
    then
        if test "$(ssh $VM_ID hostname)" = "$VM_ID"
        then
            return 0
        fi
    fi
    return 1
}

[ "$1" ] || {
    log "Duration Parameter needed"
    log "Usage $0 [number of run in seconds] "
    exit
}

function start_vm(){
   local vm_id=$1
   shift

   if xl create /var/tpcv/tpc_repo/xen_install/v2/${vm_id}-centos7.cfg
   then
       for i in {1..30}; do
           if vm_is_running $vm_id;
           then
               log "VM $vm_id up and running"
               return 0
           else
               sleep 3
           fi
       done
   fi

   log "Couldn't start  VM $vm_id"

   return 1
}

RET_COND=1
END=$1

log "Ensuring that all test vms are dowm"
stop_vms "tpc-tenant"

set -e
log "Starting the VMs"
start_vm tpc-tenant
start_vm tpc-tenant2
start_vm tpc-tenant3

if vm_is_running tpc-tenant && vm_is_running tpc-tenant2 && vm_is_running tpc-tenant3
then
    log "all vms are up"
else
    log "error on launching the vms"
    return 1
fi


{
    echo "copying the workload into the vms "
    scp workload.sh tpc-tenant:~
    scp workload.sh tpc-tenant2:~
    scp workload.sh tpc-tenant3:~

    echo "spawning the workload"
    ssh tpc-tenant screen -d -m bash workload.sh ${END}
    ssh tpc-tenant2 screen -d -m bash workload.sh ${END}
    ssh tpc-tenant3 screen -d -m bash workload.sh ${END}
    
    log "Sleeping wainting the test time"
    sleep ${END}


} 2>&1 |tee -a $LOG_FILE 

RET_COND=0
set +e
log "Force vms ending"
stop_vms "tpc-tenant"
log "Test finished after ${SECONDS} seconds"
log "Exiting with ${RET_COND}"
exit ${RET_COND}
