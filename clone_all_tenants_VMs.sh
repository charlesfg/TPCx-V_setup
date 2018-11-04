#!/bin/bash 
set -o errexit


declare -A IP_ADDR  # Create an associative array

IP_ADDR[tpc-tenant2]=10.0.0.51
IP_ADDR[tpc-tenant3]=10.0.0.52

for VM in tpc-tenant2 tpc-tenant3;
do

    echo "Cloning the tpc-${VM}";

    test -e /dev/oxum-vg/${VM}-disk || lvcreate -L30G -n ${VM}-disk oxum-vg
    dd if=/dev/oxum-vg/tpc-tenant_extended-disk of=/dev/oxum-vg/${VM}-disk bs=512K

    test -e /dev/oxum-vg/${VM}-swap ||lvcreate -L4G -n ${VM}-swap oxum-vg
    dd if=/dev/oxum-vg/tpc-tenant-swap of=/dev/oxum-vg/${VM}-swap bs=512K

    partprobe
    kpartx -al /dev/oxum-vg/${VM}-disk
    kpartx -al /dev/oxum-vg/${VM}-swap

    mount /dev/mapper/oxum--vg-tpc--${VM}--disk1 /mnt/tpc-clone
    cd /mnt/tpc-clone

    sed  -i "s/tpc-tenant/tpc-${VM}/" etc/hostname
    # adding the tpc hosts to the hosts files
    fgrep '10.0.0.' /etc/hosts >> etc/hosts
    sed  -i "s/10.0.0.50/${IP_ADDR[tpc-${VM}]}/"  etc/sysconfig/network-scripts/ifcfg-eth0
    cd -
    umount /mnt/tpc-clone

    cd /var/tpcv/tpc_repo/xen_install/
    cp tpc-tenant-centos7.cfg tpc-${VM}-centos7.cfg
    sed -i "s/tpc-tenant/tpc-${VM}/g" tpc-${VM}-centos7.cfg 
    sed -i "s/02:73:22:41:35:77/$(bash gen-mac.sh)/" tpc-${VM}-centos7.cfg
    
    #xl -vvv create tpc-${VM}-centos7.cfg
done 
