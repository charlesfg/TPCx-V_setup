#!/bin/bash
# Attack the system emulating a successful crash in a guest

#
#  Source our common functions 
#

E_BADARGS=85

SECONDS=0
SLEEP_TIME=7

if [ -e ~/common.sh ]; then
    . ~/common.sh
else
    echo "Common functions not present, exiting!"
    exit;
fi

function help(){
    log "Usage: `basename $0` <duration> <domU> [s]"
    log "\t<duration> seconds to wait for reboot "
    log "\t<domU> Domain Name (eg. tpc-g1a)>"
    log "\ts (optional) - skip the reboot after crashing"
    exit $E_BADARGS
}

if [ $# -lt 2 ]
then
    help
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
       log "error: <duration> "$1" is not a number" >&2; 
       help
fi

DURATION=$1
DOMU=$2

REBOOT=1

[ "$3" ] && {
    log "Will not reboot the Guest"
    REBOOT=0
}




function start_vm(){
    local vm_id=$1
    local cnf=$2
    shift

    if xl create ${cnf};
    then
        for i in {1..30}; do
            if vm_is_running $vm_id;
            then
                log "VM $vm_id up and running"
                # sleeping 7 seconds to give DOM0 a break
                sleep $SLEEP_TIME
                return 0
            else
                sleep 1
            fi
        done
    fi

    log "Couldn't start  VM $vm_id"
    return 1
}

function stop_vms(){

    for i in $(xl list | fgrep dsprawl- | awk '{print $1}');
    do
        xl shutdown ${i} 
        xen-delete-image --dir=/var/tpcv/xen_images/disposable/ --hostname=${i}
    done
    sleep 10
    for i in $(xl list | fgrep dsprawl- | awk '{print $1}');
    do
        xl destroy ${i} 
        xen-delete-image --dir=/var/tpcv/xen_images/disposable/ --hostname=${i}
    done
}

{
    set -e 

    ilog "Checking if the $DOMU is up and running"
    if ! vm_is_running $DOMU;
    then
        ilog "VM $DOMU is not running, aborting ..."
        exit 1
    fi

    XEN_VM_CONFIG_HOME=/var/tpcv/tpc_repo/xen_install/curr_cfg
    DOMU_CNF=$(ls ${XEN_VM_CONFIG_HOME}/${DOMU}-*.cfg)

    ilog "Will destroy the $DOMU .. "
    xl destroy $DOMU
    sleep 10

    ilog "Checking that the $DOMU is offline "
    if vm_is_running $DOMU;
    then
        ilog "VM $DOMU is not running, aborting ..."
        exit 1
    fi

    ilog "Wait for input DURATION ( $DURATION seconds )"
    sleep $DURATION
   
    if test $REBOOT -eq 1;
    then 
        ilog "Restart the $DOMU"
        ilog "Will use the configurationg in $DOMU_CNF"
        if ! start_vm $DOMU $DOMU_CNF;
        then
            ilog "FAILED in Restart the system"
            exit 1
        fi
    fi

    ilog "Guest Crash attack on ${DOMU} done!"
    ilog "Done!!! $(($SECONDS/60)) minutes elapsed"
} 2>&1 |tee -a $LOG_FILE  
