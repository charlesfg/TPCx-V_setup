set -o errexit


declare -A IP_ADDR  # Create an associative array


IP_ADDR[tpc-drive]=10.0.0.30

for VM in drive;
do

    echo "Cloning the tpc-${VM}";
    if [[ ${VM} == g1a || ${VM} == g1b1 ]];
    then 
        echo "Skiping the configured firsts VM"
        continue
    fi

    test -e /dev/oxum-vg/tpc-${VM}-disk || lvcreate -L8G -n tpc-${VM}-disk oxum-vg
    dd if=/dev/oxum-vg/tpc0-centos7-disk of=/dev/oxum-vg/tpc-${VM}-disk bs=512K

    test -e /dev/oxum-vg/tpc-${VM}-swap ||lvcreate -L4G -n tpc-${VM}-swap oxum-vg
    dd if=/dev/oxum-vg/tpc0-centos7-swap of=/dev/oxum-vg/tpc-${VM}-swap bs=512K

    partprobe
    kpartx -al /dev/oxum-vg/tpc-${VM}-disk
    kpartx -al /dev/oxum-vg/tpc-${VM}-swap

    mount /dev/mapper/oxum--vg-tpc--${VM}--disk1 /mnt/tpc-clone
    cd /mnt/tpc-clone

    sed  -i "s/tpc0/tpc-${VM}/" etc/hostname
    # adding the tpc hosts to the hosts files
    fgrep '10.0.0.' /etc/hosts >> etc/hosts
    sed  -i "s/10.0.0.20/${IP_ADDR[tpc-${VM}]}/"  etc/sysconfig/network-scripts/ifcfg-eth0
    cd -
    umount /mnt/tpc-clone

    cd /var/tpcv/tpc_repo/xen_install/
    cp tpc0-centos7.cfg tpc-${VM}-centos7.cfg
    sed -i "s/tpc0/tpc-${VM}/g" tpc-${VM}-centos7.cfg 
    sed -i 's/-centos7//g' tpc-${VM}-centos7.cfg
    sed -i "s/00:16:3E:29:QQ:QQ/$(bash gen-mac.sh)/" tpc-${VM}-centos7.cfg

    if [[ ${VM} == g[[:digit:]]b* ]];
    then 
        echo "Adding the dbstore space for the database VMs"
        sed -i "s/xvdc,rw'/xvdc,rw',\n\t'phy:\/dev\/oxum-vg\/tpc_${VM}-dbstore,xvdd,rw'/" tpc-${VM}-centos7.cfg 
    fi
    
    xl -vvv create tpc-${VM}-centos7.cfg
done 

