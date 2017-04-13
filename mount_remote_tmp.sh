test -e /tmp/oxum_tmp && test -d /tmp/oxum_tmp/  || mkdirt /tmp/oxum_tmp 
sudo sshfs -o allow_other,default_permissions,IdentityFile=/home/charles/.ssh/id_rsa  ubuntu@200.131.6.113:/tmp /tmp/oxum_tmp
