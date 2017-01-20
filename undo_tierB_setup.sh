#!/bin/bash -x

set -o errexit

systemctl stop postgresql-9.3.service
systemctl disable postgresql-9.3.service
rm -rf /etc/systemd/system/postgresql-9.3.service.d
rm -rf /etc/systemd/system/postgresql-9.3.service
rm -rf /dbstore/*
umount /dbstore
sed -i '/\/dev\/xvdd1/d' /etc/fstab
rmdir /dbstore
