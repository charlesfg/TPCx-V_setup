#!/bin/bash 


source common_functions.sh

for i in tpc-g1b1 tpc-g1b2 tpc-g2b1 tpc-g2b2 tpc-g3b1 tpc-g3b2 tpc-g4b1 tpc-g4b2 
do
    runAt ${TARGET} "psql -U tpcv -c \"select * from DataMaintenanceFrame1(43000078181,0,0, 0::smallint,'','ACCOUNT_PERMISSION','',0::smallint)\"" | grep '1 row'
    if test $? -eq 0; 
    then 
        echo ok; 
    else 
        echo "not ok"; 
    fi 
done
