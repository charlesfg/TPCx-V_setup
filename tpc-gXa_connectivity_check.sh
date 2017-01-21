#!/bin/bash

cd 
rm -fv /opt/VDb/pgsql/dml/test_programs/tradestatus

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

# This is needed because the Makefile has a multiline invalid comment
sed  -i.bkp '1,33d' Makefile

# This is needed because there's a bug into the tradestatus program
# In the SQLBindParameter calls, we are passing a SQL_C_UBIGINT into a SQL_INTEGER
# Changing to a BIG_INT
sed  -i.bkp 's/SQL_INTEGER/SQL_BIGINT/' tradestatus.c
make tradestatus

for i in  2 3;
do
    RES=$(./tradestatus PSQL${i} | wc -l)
    if [ $RES -ne 672 ]; then
        echo "Connectivity check usng odbc failed for PSQL${i} .. RESULT = $RES" >&2
        #exit 1
    fi
done
