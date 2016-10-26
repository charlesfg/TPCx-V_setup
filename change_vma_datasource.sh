#!/bin/bash

set -o verbose
set -o errexit

for i in  1 2; do 
        H=$(hostname | sed "s/a/b$i/g") ; 
        sed  -i "s/tpc-g1b$i/$H/g" /etc/odbc.ini
done
