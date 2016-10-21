#!/bin/bash
set -x

cd 
rm -fv /opt/VDb/pgsql/dml/test_programs/traderesult
sed -i 's/DSN=PSQL[1-3]/DSN=PSQL2/g' /opt/VDb/pgsql/dml/test_programs/traderesult.c
for i in  1 2;
do 
    export PGHOST=$(hostname | sed "s/a/b$i/g")

    psql tpcv -c "select count(*) from sector"    
    cd /opt/VDb/pgsql/dml/test_programs
    make traderesult
    ./traderesult 2>&1 | grep Success
    rm -fv traderesult    
    sed -i 's/DSN=PSQL[1-3]/DSN=PSQL3/g' /opt/VDb/pgsql/dml/test_programs/traderesult.c
done