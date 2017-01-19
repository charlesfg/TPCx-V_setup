#!/bin/bash 
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

for VM in g1a g2a g3a g4a g1b1 g1b2 g2b1 g2b2 g3b1 g3b2 g4b1 g4b2;
do

    echo "Cloning the tpc-${VM}";
    if [[ ${VM} == g1a || ${VM} == g1b1 ]];
    then 
        echo "Skiping the configured firsts VM"
        continue
    fi

    lvcreate -L8G -n tpc-${VM}-disk oxum-vg
    dd if=/dev/oxum-vg/tpc0-centos7-disk of=/dev/oxum-vg/tpc-${VM}-disk bs=512K

    lvcreate -L4G -n tpc-${VM}-swap oxum-vg
    dd if=/dev/oxum-vg/tpc0-centos7-swap of=/dev/oxum-vg/tpc-${VM}-swap bs=512K

    partprobe
    kpartx -al /dev/oxum-vg/tpc-${VM}-disk
    kpartx -al /dev/oxum-vg/tpc-${VM}-swap

    mount /dev/mapper/oxum--vg-tpc--${VM}--disk1 /mnt/tpc-clone
    cd /mnt/tpc-clone

    sed  -i 's/tpc0/tpc-${VM}/' etc/hostname
    # adding the tpc hosts to the hosts files
    fgrep '10.0.0.' /etc/hosts >> etc/hosts
    sed  -i 's/10.0.0.20/${IP_ADDR[$L]}/'  etc/sysconfig/network-scripts/ifcfg-eth0
    cd -
    umount /mnt/tpc-clone

    cd /var/tpcv/tpc_repo/xen_install/
    cp tpc0-centos7.cfg tpc-${VM}-centos7.cfg
    sed -i 's/tpc0/tpc-${VM}/g' tpc-${VM}-centos7.cfg 
    sed -i 's/-centos7//g' tpc-${VM}-centos7.cfg
    sed -i "s/00:16:3E:29:QQ:QQ/$(bash gen-mac.sh)/" tpc-${VM}-centos7.cfg

    if [[ ${VM} == g[[:digit:]]b* ]];
    then 
        echo "Adding the dbstore space for the database VMs"
        sed "s/xvdc,rw'/xvdc,rw',\n\t'phy:\/dev\/oxum-vg\/tpc_${VM}-dbstore,xvdd,rw'/" tpc-${VM}-centos7.cfg 
    fi
done 
