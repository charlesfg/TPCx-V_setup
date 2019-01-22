SECONDS=0
echo "Droping the database"
su postgres -c "cd ~ && dropdb tpcv"
su postgres -c "cd ~ && createdb tpcv"
echo "Trying to restore de database ... "
su postgres -c "cd ~ && pg_restore -j 4 -c --disable-triggers -d tpcv /dbstore/backup"
cd /opt/VDb/pgsql/scripts/linux 
echo "Will analyze the restoration!"
./analyze.sh
echo "Done!!! $(($SECONDS/60)) minutes elapsed"
