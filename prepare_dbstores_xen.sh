#!/bin/bash

for i in `seq 1 4`; do
    for j in 1 2; do
        L=tpc_g${i}b${j}                
        DISK=phy:/dev/oxum-vg/${L}-dbstore
        # Attach the disk image
        xl block-attach tpc0 ${DISK} xvdd rw

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
        ssh root@10.0.0.20 "(echo o; echo n; echo p; echo 1; echo ; echo; echo w) | fdisk /dev/xvdd"

        # Format
        ssh root@10.0.0.20 "mkfs.ext4 -F -v -t ext4 -T largefile4 -m 0 -j -O extent -O dir_index /dev/xvdd1"

        # List Information
        ssh root@10.0.0.20 "lsblk -f"

        # Detach disk
        xl block-detach tpc0 xvdd
    done
done
