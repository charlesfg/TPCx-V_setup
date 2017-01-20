 #!/bin/bash 

pg_restore -j 4 -c --disable-triggers -d tpcv /dbstore/backup 
cd /opt/VDb/pgsql/scripts/linux 
./analyze.sh