#!/bin/bash -x



declare -A IP_ADDR  # Create an associative array

IP_ADDR[tpc-g1a]=10.131.6.31
IP_ADDR[tpc-g1b1]=10.131.6.32
IP_ADDR[tpc-g1b2]=10.131.6.33
IP_ADDR[tpc-g2a]=10.131.6.34
IP_ADDR[tpc-g2b1]=10.131.6.35
IP_ADDR[tpc-g2b2]=10.131.6.36
IP_ADDR[tpc-g3a]=10.131.6.37
IP_ADDR[tpc-g3b1]=10.131.6.38
IP_ADDR[tpc-g3b2]=10.131.6.39
IP_ADDR[tpc-g4a]=10.131.6.40
IP_ADDR[tpc-g4b1]=10.131.6.41
IP_ADDR[tpc-g4b2]=10.131.6.42

for i in `seq 1 4`; do
	for j in 1 2; do
		if [[ $i -eq 1 && $j -eq 1 ]]; then
			continue;
		fi
		L=tpc-g${i}b${j}		
		echo ":: Cloning the $L VM .... "
		echo virt-clone --original tpc-g1b1 --name $L --auto-clone
		echo ":: Attach the storage for flat files and the dbstore"
		echo virsh attach-disk $L --source /var/lib/libvirt/images/tpc-flatfiles.img \
			--target vdb --persistent
		echo virsh attach-disk $L --source /var/lib/libvirt/images/${L}-dbstore.img \
			--target vdc --persistent

		echo /opt/tpc/libguestfs-1.34.2/run virt-customize \
				--domain $L \
				--hostname $L \
				--edit /etc/sysconfig/network-scripts/ifcfg-eth0:"s/10.131.6.20/${IP_ADDR[$L]}/g" \
				--edit /etc/fstab:'eof && do{print "$_"; print "/dev/vdb1\t/vgenstore\text4\tdefaults\t0\t1\n"}' \
				--edit /etc/fstab:'eof && do{print "$_"; print "/dev/vdc1\t/dbstore\text4\tnofail,noatime,nodiratime,nobarrier\t0\t1\n"}'

		echo ":: Start the vm"
		echo virsh start $L
		echo ":: Wait until it boot"
		echo sleep 20 
		echo ":: Setup the DB folders"
		echo ssh root@${IP_ADDR[$L]} "bash -x setup_dbstore_folders.sh"
		echo ":: Setup Postgres"
		echo ssh root@${IP_ADDR[$L]} "bash -x setup_postgres.sh"		
		echo ":: Create all databases"
		echo ssh postgres@${IP_ADDR[$L]} "bash -x create_database.sh"
		exit;

		
	done
done

