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


alias runatall="runAt tpc-"
alias runata="runAt tpc-g[0-9]a"
alias runatb="runAt tpc-g[0-9]b"

