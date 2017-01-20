#!/bin/bash

if [ -e /dev/xvdd1 ]; then
	echo "format the dbstorage partition"
	mkfs.ext4 -F -v -t ext4 -T largefile4 -m 0 -j -O extent -O dir_index /dev/xvdd1
else
	echo "ERROR: dbstorage partition not found (/dev/xvdd1)"
	exit 1
fi

mkdir /dbstore

if ! mount -o nofail,noatime,nodiratime,nobarrier /dev/xvdd1 /dbstore  
then
	echo "ERROR: Could not mount /dbstore partition (/dev/xvdd1)"
	exit 1
fi

echo "/dev/xvdd1\t/dbstore\text4\tnofail,noatime,nodiratime,nobarrier\t0\t1\n" >> /etc/fstab
