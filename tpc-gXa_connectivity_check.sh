#!/bin/bash

cd 
rm -fv /opt/VDb/pgsql/dml/test_programs/tradestatus
rm -fv /opt/VDb/pgsql/dml/test_programs/traderesult

for i in  1 2;
do 
    export PGHOST=$(hostname | sed "s/a/b$i/g")
    echo -e "+ Testing for host $PGHOST\n"

    RES=$(psql tpcv -c "select count(*) from sector" | grep 12 | tr -d '[:space:]')
    if [ $RES -ne 12 ]; then
        echo "connectivity check failed for $PGHOST .. RESULT = $RES" >&2
        exit 1
	fi

done


cd /opt/VDb/pgsql/dml/test_programs

make tradestatus

for i in  2 3;
do
    RES=$(./tradestatus PSQL${i} | wc -l)
    if [ $RES -ne 22 ]; then
        echo "Connectivity check usng odbc failed for PSQL${i} .. RESULT = $RES" >&2
        #exit 1
    fi
done


./traderesult 2>&1| grep '^SQL '

