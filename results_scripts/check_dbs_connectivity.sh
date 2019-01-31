#!/bin/bash 

for i in tpc-g1b1 tpc-g1b2 tpc-g2b1 tpc-g2b2 tpc-g3b1 tpc-g3b2 tpc-g4b1 tpc-g4b2 
do
    ssh $i "psql -U tpcv -c \"select * from DataMaintenanceFrame1(43000078181,0,0, 0::smallint,'','ACCOUNT_PERMISSION','',0::smallint)\"" | grep '1 row'
    if test $? -eq 0; 
    then 
        echo "DB in $i is ok"; 
    else 
        echo "Restart DB in $i .."; 
        ssh $i "systemctl stop postgresql-9.3.service"
        sleep 5
        ssh $i "systemctl start postgresql-9.3.service"
        sleep 5
        ssh $i "psql -U tpcv -c \"select * from DataMaintenanceFrame1(43000078181,0,0, 0::smallint,'','ACCOUNT_PERMISSION','',0::smallint)\"" | grep '1 row'
        if test $? -eq 0; 
        then 
            echo "DB in $i is NOW ok"; 
        else
            echo "It was not possible to recover the  DB in $i .."; 
        fi

    fi 
done
