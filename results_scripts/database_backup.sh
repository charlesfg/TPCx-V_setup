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
	(find tpcv-data tpcv-index tpcv-temp) | cpio -o | lbzip2 -c > /dbstore/tpcv-backup.cpio.bz2
    chown -R postgres:postgres /dbstore
	systemctl start postgresql-9.3.service
} 2>&1 | tee -a $LOG_FILE
log "Finished the backup of  $(hostname)"
