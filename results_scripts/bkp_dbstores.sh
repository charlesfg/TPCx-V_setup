LOG_F=bkp_dbstores-$(date +"%F_%T").log
{ time dd if=/dev/oxum-vg/tpc_g1b1-dbstore of=/dev/oxum-vg/tpc_g1b1-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
{ time dd if=/dev/oxum-vg/tpc_g1b2-dbstore of=/dev/oxum-vg/tpc_g1b2-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
{ time dd if=/dev/oxum-vg/tpc_g2b1-dbstore of=/dev/oxum-vg/tpc_g2b1-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
{ time dd if=/dev/oxum-vg/tpc_g2b2-dbstore of=/dev/oxum-vg/tpc_g2b2-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
{ time dd if=/dev/oxum-vg/tpc_g3b1-dbstore of=/dev/oxum-vg/tpc_g3b1-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
{ time dd if=/dev/oxum-vg/tpc_g3b2-dbstore of=/dev/oxum-vg/tpc_g3b2-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
{ time dd if=/dev/oxum-vg/tpc_g4b1-dbstore of=/dev/oxum-vg/tpc_g4b1-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
{ time dd if=/dev/oxum-vg/tpc_g4b2-dbstore of=/dev/oxum-vg/tpc_g4b2-dbstore-bkp bs=256MB ; } 2>&1 | tee -a $LOG_F
