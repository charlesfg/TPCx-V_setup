#!/bin/bash -x

set -o errexit


declare -A IP_ADDR  # Create an associative array

IP_ADDR[tpc-g1a]=10.0.0.31
IP_ADDR[tpc-g1b1]=10.0.0.32
IP_ADDR[tpc-g1b2]=10.0.0.33
IP_ADDR[tpc-g2a]=10.0.0.34
IP_ADDR[tpc-g2b1]=10.0.0.35
IP_ADDR[tpc-g2b2]=10.0.0.36
IP_ADDR[tpc-g3a]=10.0.0.37
IP_ADDR[tpc-g3b1]=10.0.0.38
IP_ADDR[tpc-g3b2]=10.0.0.39
IP_ADDR[tpc-g4a]=10.0.0.40
IP_ADDR[tpc-g4b1]=10.0.0.41
IP_ADDR[tpc-g4b2]=10.0.0.42

for i in `seq 1 4`; do	
	if [[ $i -eq 1 ]]; then
		continue;
	fi
	L=tpc-g${i}a
	echo ":: Cloning the $L VM .... "
	virt-clone --original tpc-g1a --name $L --auto-clone		
	
	/opt/tpc/libguestfs-1.34.2/run virt-customize \
			--domain $L \
			--hostname $L \
			--edit /etc/sysconfig/network-scripts/ifcfg-eth0:"s/10.0.0.31/${IP_ADDR[$L]}/g" 
	echo ":: Start the vm"
	virsh start $L
	echo ":: Wait until it boot"
	sleep 30
	# Here we need to run as the user that have ssh passwordless permission on the base Tier B vm
	echo ":: Update the Data Sources"
	su charles -c "ssh -o 'StrictHostKeyChecking no' root@${IP_ADDR[$L]} 'bash -x change_vma_datasource.sh'"
	echo ":: Setup Postgres"
	su charles -c "ssh -o 'StrictHostKeyChecking no'  root@${IP_ADDR[$L]} 'bash -x tpc-gXa_connectivity_check.sh'"		
	echo -e "\n++++++++++++++++++++++++++++++\n\n\n"
done

