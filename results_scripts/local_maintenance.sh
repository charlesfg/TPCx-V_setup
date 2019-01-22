#/bin/bash

SECONDS=0
F="/tmp/maintenance"
E="/tmp/mtnc.done"

rm 

bash ~/clean_caches.sh &> $F
test -e /dbstore/backup && rm -rf /dbstore/backup/* &>> $F
test -e /dbstore/tpcv-data/pg_log && rm -rf /dbstore/tpcv-data/pg_log/* &>> $F

psql -U tpcv -c VACUUM &>> $F

# do some work
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed." &>> $F
echo "$(($duration / 60)):$(($duration % 60)) $((hostname))" &>> $E
