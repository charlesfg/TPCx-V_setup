#!/bin/bash

declare -A STORE_SIZE  # Create an associative array

# Size of the dbstore in Gb (based on db + backup )
STORE_SIZE[tpc_g1]=43
STORE_SIZE[tpc_g2]=81
STORE_SIZE[tpc_g3]=121
STORE_SIZE[tpc_g4]=159



for i in `seq 1 4`; do
	for j in 1 2; do
		L=tpc_g${i}b${j}
		S=${STORE_SIZE[tpc_g${i}]}  
		echo  "Creating disk for the vm $L with $S GB"
		qemu-img create -f raw /var/lib/libvirt/images/${L}-dbstore.img ${S}G
	done
done