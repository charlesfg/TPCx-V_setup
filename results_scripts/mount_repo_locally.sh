#!/usr/bin/env bash

if test $(ls /home/charles/src/tpc_repo_oxum | wc -l) == 0;
then
	echo "Mounting ...."
	sshfs -o allow_other,default_permissions,IdentityFile=/home/charles/.ssh/id_rsa  root@200.131.6.113:/var/tpcv/tpc_repo /home/charles/src/tpc_repo_oxum
else
	echo "Already mounted"
fi
