if test $(ls /opt/VDriver/ | wc -l) == 0;
then
	echo "Mounting ...."
	sudo sshfs -o allow_other,default_permissions,IdentityFile=~/.ssh/id_rsa  tpc-drive:/opt/VDriver /opt/VDriver
else
	echo "Already mounted"
fi