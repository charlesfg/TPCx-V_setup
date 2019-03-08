#!/bin/bash 
set -o errexit


[ "$1" ] || { echo "Should provide which TPCx-V vm should install"; exit 1; }

VM=$1

echo "Setting up the vm $VM ..."

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

echo "Cloning the tpc-${VM}";

test -e /dev/oxum-vg/tpc-${VM}-v2-disk || lvcreate -L10G -n tpc-${VM}-v2-disk oxum-vg
dd if=/dev/oxum-vg/tpc0-centos7-disk of=/dev/oxum-vg/tpc-${VM}-v2-disk bs=512K

set +o errexit
# add the extending disk commands    
(echo d; echo n; echo p; echo 1; echo ; echo; echo w) | fdisk /dev/oxum-vg/tpc-${VM}-v2-disk
set -o errexit

test -e /dev/oxum-vg/tpc-${VM}-v2-swap ||lvcreate -L4G -n tpc-${VM}-v2-swap oxum-vg
dd if=/dev/oxum-vg/tpc0-centos7-swap of=/dev/oxum-vg/tpc-${VM}-v2-swap bs=512K

set +o errexit
partprobe
kpartx -al /dev/oxum-vg/tpc-${VM}-v2-disk
kpartx -al /dev/oxum-vg/tpc-${VM}-v2-swap
set -o errexit

mount /dev/mapper/oxum--vg-tpc--${VM}--v2--disk1 /mnt/tpc-clone
cd /mnt/tpc-clone

sed  -i "s/tpc0/tpc-${VM}/" etc/hostname
# adding the tpc hosts to the hosts files
fgrep '10.0.0.' /etc/hosts >> etc/hosts
sed  -i "s/10.0.0.20/${IP_ADDR[tpc-${VM}]}/"  etc/sysconfig/network-scripts/ifcfg-eth0
if [[ ${VM} == g[[:digit:]]b* ]];
then 
    echo "Adding the dbstore space for the database VMs"
    mkdir dbstore
    echo -e "/dev/xvdd1\t/dbstore\text4\tnofail,noatime,nodiratime,nobarrier\t0\t1\n" >> etc/fstab      
fi
cd -
umount /mnt/tpc-clone

cd /var/tpcv/tpc_repo/xen_install/v2
cp tpc0-centos7.cfg tpc-${VM}-v2-centos7.cfg
sed -i "s/tpc0/tpc-${VM}/g" tpc-${VM}-v2-centos7.cfg 
sed -i "s/-disk/-v2-disk/g" tpc-${VM}-v2-centos7.cfg 
sed -i "s/-swap/-v2-swap/g" tpc-${VM}-v2-centos7.cfg 
sed -i 's/-centos7//g' tpc-${VM}-v2-centos7.cfg
sed -i "s/00:16:3E:29:QQ:QQ/$(bash ../gen-mac.sh)/" tpc-${VM}-v2-centos7.cfg

if [[ ${VM} == g[[:digit:]]b* ]];
then 
    echo "Adding the dbstore space for the database VMs"
    sed -i "s/xvdc,rw'/xvdc,rw',\n\t'phy:\/dev\/oxum-vg\/tpc_${VM}-dbstore,xvdd,rw'/" tpc-${VM}-v2-centos7.cfg 
fi

xl -vvv create tpc-${VM}-v2-centos7.cfg
sleep 25
ssh tpc-${VM} resize2fs /dev/xvda1

