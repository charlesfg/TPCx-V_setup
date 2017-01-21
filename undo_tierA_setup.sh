#!/bin/bash -x

rm /etc/odbc.ini
cp /etc/odbcinst.ini.bkp /etc/odbcinst.ini 

cd /opt/VDb/pgsql/dml/test_programs
cp tradestatus.c.bkp tradestatus.c
cp Makefile.bkp Makefile
cd -