SECONDS=0
echo "Cleaning everything ...."
systemctl stop postgresql-9.3.service
cp -v /dbstore/tpcv-data/pg_hba.conf /tmp
cp -v /dbstore/tpcv-data/postgresql.conf /tmp
rm -rf /dbstore/*
mkdir -p /dbstore/tpcv-data
mkdir /dbstore/tpcv-index
mkdir /dbstore/tpcv-temp
chown -R postgres:postgres /dbstore
/usr/pgsql-9.3/bin/postgresql93-setup initdb    
cp -v /tmp/pg_hba.conf /dbstore/tpcv-data
cp -v /tmp/postgresql.conf /dbstore/tpcv-data
systemctl start postgresql-9.3.service

echo "Trying to setup de database ... "
cd /opt/VDb/pgsql/scripts/linux
su postgres -c "./setup.sh"
psql -U tpcv -c VACUUM
rm -rf /dbstore/tpcv-data/pg_log/*
rm -rf /dbstore/backup

echo "Done!!! $(($SECONDS/60)) minutes elapsed"
