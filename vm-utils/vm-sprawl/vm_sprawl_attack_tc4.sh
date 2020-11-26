#!/bin/bash


# Attack the system emulating a vm-sprawl attack
# v1 - Just Running the VMs

#
#  Source our common functions 
#
SECONDS=0
SLEEP_TIME=7

if [ -e ~/common.sh ]; then
    . ~/common.sh
else
    echo "Common functions not present, exiting!"
    exit;
fi

[ "$1" ] || {
    log "Duration Parameter needed"
    log "Usage $0 [number of run in seconds] "
    exit
}


END=$1

function test_finished(){
    if [ $SECONDS -ge $END ];
    then
        log "Test timeout $SECONDS > $END .."
        return 0
    fi
    return 1
}

function start_vm(){
   local vm_id=$1
   shift

   if xen-create-image --install-method=tar --install-source=/var/tpcv/xen_images/sprawl.tar \
       --hostname=dsprawl-${i} \
       --config=/var/tpcv/tpc_repo/vm-utils/sprawl-vm-create.conf \
       --ip=10.0.0.1${i};
   then

       if xl create /etc/xen/${vm_id}.cfg;
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
   fi

   log "Couldn't start  VM $vm_id"
   xen-delete-image --dir=/var/tpcv/xen_images/disposable/ --hostname=dsprawl-${i}

   return 1
}

function stop_vms(){

    for i in $(xl list | fgrep dsprawl- | awk '{print $1}');
    do
        xl destroy ${i} 
        xen-delete-image --dir=/var/tpcv/xen_images/disposable/ --hostname=${i}
    done
}

log "Starting VM-Sprawl attack that will took ${END} seconds (after setup)"
{

    declare -a f
    err_cnt=0
    
    f=($(seq -w 1 50))
    
    while [ ${#f[@]} -gt 0 ];
    do
        if test_finished;
        then 
            break
        fi
        i=${f[0]}
        f=(${f[@]:1})
        if ! start_vm dsprawl-${i};
        then
            f+=(${i})
            err_cnt=$(($err_cnt+1))
            log "Error on creating VM-Sprawl $i, $err_cnt error"
            sleep $SLEEP_TIME
        fi
        log "Remaining VMs to create ${f[@]}"
    done

} 2>&1 |tee -a $LOG_FILE 

log "Checking if every vm is up"

if test $(xl list  | grep dsprawl- | awk '{print $1}' | wc -l) -eq 35;
then
    log "Setup done!"
    TO_END=$(($END - $SECONDS))
    if ! test_finished;
    then
        log "Waiting ${END} Seconds"
        sleep $END
    fi
    stop_vms
    log "VM-Sprawl attack done"
    log "Done!!! $(($SECONDS/60)) minutes elapsed"
    exit 0
else
    log "Not every VM it's up:"
    log $(xl list  | grep dsprawl- | awk '{print $1}' | sort)
    while ! test_finished;
    do
        sleep 3
    done
    stop_vms
    log "VM-Sprawl attack FAILED"
    log "Done!!! $(($SECONDS/60)) minutes elapsed"
    exit 0
fi

