 #!/bin/bash 

cd /dbstore
rm -rf /dbstore/backup
mkdir /dbstore/backup
pg_dump -j 4 -Fd tpcv -f /dbstore/backup -Z 9

