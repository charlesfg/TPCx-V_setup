#!/bin/bash

for i in `seq 1 4`; do
    for j in 1 2; do
        L=tpc_g${i}b${j}                
        DISK=/var/lib/libvirt/images/${L}-dbstore.img
        # Attach the disk image
        virsh attach-disk tpc0 --source ${DISK} --target vdb

        # Create the partition
        # For simplicity we will emulate the interactive interation with fdisk.
        # Each echo cmd is an option to fdisk, in order we:
        # o -> Create an clear the in memory partition table
        # n -> new partition
        # p -> primary partition
        # 1 -> partition number 1
        #   -> default - start at beginning of disk 
        #   -> default, extend partition to end of disk
        # w -> write the partition table
        # Source http://superuser.com/questions/332252/creating-and-formating-a-partition-using-a-bash-script
        ssh root@10.131.6.20 "(echo o; echo n; echo p; echo 1; echo ; echo; echo w) | fdisk /dev/vdb"

        # Format
        ssh root@10.131.6.20 "mkfs.ext4 -F -v -t ext4 -T largefile4 -m 0 -j -O extent -O dir_index /dev/vdb1"

        # List Information
        ssh root@10.131.6.20 "lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL"

        # Detach disk
        virsh detach-disk tpc0  --target ${DISK}
    done
done