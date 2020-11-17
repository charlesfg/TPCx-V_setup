for i in $(seq -w 1 35);
do 
    xen-create-image --install-method=tar --install-source=/var/tpcv/xen_images/sprawl.tar \
								 --hostname=sprawl-${i} \
								 --config=/var/tpcv/tpc_repo/vm-utils/sprawl-vm-create.conf \
								 --ip=10.0.0.1${i}
    sleed 2
    xl create /etc/xen/sprawl-${i}.cfg
done

