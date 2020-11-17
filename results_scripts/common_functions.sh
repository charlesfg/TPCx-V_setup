function log_default_name
{
    local F=$(basename -- "$0")
    echo ${F%.*}_$(date +"%Y%m%d_%H%M%S").log
}
# Sinple function to the $LOG_FILE defined variable
function log
{
  echo "$(date +%c)  -- $@" | tee -a $LOG_FILE  
}

#!/bin/bash
# Usage :
# $1 ->target filter
# $2 ->files pttrn
function copyFrom(){
    TARGET=$1
    shift;
    FILES_PTTRN=$1
    shift;
    for i in `cat /etc/hosts | grep $TARGET | awk '{print $2}'`; do  
        echo $i; 
        scp ${i}:${FILES_PTTRN} $@
    done   
}

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


alias copytoall="copyTo tpc-"
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


function AsyncRunAt(){
    TARGET=$1
    shift;
    for i in `cat /etc/hosts | grep $TARGET | awk '{print $2}'`; do  
        echo $i; 
        ssh $i "$@" &
    done
}

function vm_is_running(){
    VM_ID=$1
    if test $(xl list $VM_ID | grep -v State | awk '{print $5}' | grep '[rb]' | wc -l ) -eq 1;
    then
        return 0
    else
        return 1
    fi
}
LOG_FILE=$(log_default_name)
