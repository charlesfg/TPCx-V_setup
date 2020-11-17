#!/bin bash

source common_functions.sh

LOG_FILE=$(log_default_name)

log "Starting to restore all databases on the tpc-g*b tier"
copyTo  tpc-g[0-9]b ~ database_restore.sh
AsyncRunAt tpc-g[0-9]b /bin/bash  ~/database_restore.sh
#runAt tpc-g[0-9]b /bin/bash ~/database_backup.sh
wait
log "Backup Restoration finished"

