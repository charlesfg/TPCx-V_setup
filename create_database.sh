#!/bin/bash -x

sed -i "s/Scaling\[1-[0-4]\]/Scaling[1-$(hostname | cut -c6)]/" /opt/VDb/pgsql/scripts/linux/env.sh
cat /opt/VDb/pgsql/scripts/linux/env.sh
cd /opt/VDb/pgsql/scripts/linux
chmod +x *.sh
./setup.sh 2>&1 | tee  $(hostname)-setupDB-$(date +"%Y%m%d_%H%M").log &
echo "Setup finished at $(date +"%Y%m%d_%H%M")"
cd -

