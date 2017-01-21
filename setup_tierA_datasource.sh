#!/bin/bash


for i in \
	/opt/VDb/pgsql/prj/osfiles/odbc.ini \
	/etc/odbcinst.ini \
	/usr/pgsql-9.3/lib/psqlodbcw.so ;
do 
	if [ ! $i ]; then
        echo "Error: file '$i'  does not exist" >&2
		exit 1
	fi
done



cat /opt/VDb/pgsql/prj/osfiles/odbc.ini > /etc/odbc.ini
sed -i "s/w1-tpcv-vm-45/$(hostname | sed "s/a/b1/g")/" /etc/odbc.ini
sed -i "s/w1-tpcv-vm-46/$(hostname | sed "s/a/b2/g")/" /etc/odbc.ini

cp /etc/odbcinst.ini /etc/odbcinst.ini.bkp
sed -i 's/\/usr\/lib64\/psqlodbcw.so/\/usr\/pgsql-9.3\/lib\/psqlodbcw.so/g' /etc/odbcinst.ini

