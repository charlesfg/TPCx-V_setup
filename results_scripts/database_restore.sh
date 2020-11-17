function log_default_name
{
    local F=$(basename -- "$0")
    echo ${F%.*}_$(date +"%Y%m%d_%H%M%S").log
}
# Sinple function to the $LOG_FILE defined variable
function log
{
  echo "$(date +%c)  -- $@" | tee -a $LOG_FILE  
}

LOG_FILE=$(log_default_name)

log  "Starting backup at $(hostname)"
{ 
    systemctl stop postgresql-9.3.service
    cd /dbstore
    rm -rf tpcv-data tpcv-index tpcv-temp
    lbzip2 -d /dbstore/tpcv-backup.cpio.bz2 -c | cpio -idm
    chown -R postgres:postgres /dbstore
    systemctl start postgresql-9.3.service
} 2>&1 | tee -a $LOG_FILE
log "Finished the backup of  $(hostname)"
