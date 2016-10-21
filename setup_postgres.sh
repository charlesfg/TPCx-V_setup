#!/bin/bash -x

PGDATA=/dbstore/tpcv-data
GUEST_IP=`ifconfig | grep 10.131.6 | awk '{print $2}'`

cat <<EOF  >>/etc/systemd/system/postgresql-9.3.service
.include /lib/systemd/system/postgresql-9.3.service
Environment=PGDATA=/dbstore/tpcv-data
EOF

mkdir /etc/systemd/system/postgresql-9.3.service.d

cat <<EOF  >> /etc/systemd/system/postgresql-9.3.service.d/restart.conf
[Service]
Environment=PGDATA=/dbstore/tpcv-data
EOF

systemctl enable postgresql-9.3.service
/usr/pgsql-9.3/bin/postgresql93-setup initdb
systemctl start postgresql-9.3.service

su postgres <<EOF
sed -i 's/peer\|ident/trust/g' /dbstore/tpcv-data/pg_hba.conf

sed -i 's/127.0.0.1\/32/0.0.0.0\/0/g' /dbstore/tpcv-data/pg_hba.conf

sed -i "s/^#listen.*/listen_addresses = '*'/g" /dbstore/tpcv-data/postgresql.conf

sed -i 's/^shared_buffers.*/shared_buffers = 1024MB/g' /dbstore/tpcv-data/postgresql.conf

sed -i 's/^#wal_sync.*/wal_sync_method = open_datasync/g' /dbstore/tpcv-data/postgresql.conf

sed -i 's/^#wal_wri.*/wal_writer_delay = 10ms/g' /dbstore/tpcv-data/postgresql.conf

sed -i 's/^#checkpoint_seg.*/checkpoint_segments = 30/g' /dbstore/tpcv-data/postgresql.conf

sed -i 's/^#checkpoint_comple.*/checkpoint_completion_target = 0.9/g' /dbstore/tpcv-data/postgresql.conf
EOF

systemctl restart postgresql-9.3.service
