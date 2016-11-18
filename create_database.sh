#!/bin/bash -x

sed -i "s/Scaling\[1-[0-4]\]/Scaling[1-$(hostname | cut -c6)]/" /opt/VDb/pgsql/scripts/linux/env.sh
cd /opt/VDb/pgsql/scripts/linux
./setup.sh
cd -

