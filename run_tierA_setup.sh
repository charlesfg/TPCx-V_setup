#!/bin/bash

#set -o errexit


git config --global user.email "charles.fg@gmail.com"
git config --global user.name  "Charles Goncalves"

git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
git config --global alias.type 'cat-file -t'
git config --global alias.dump 'cat-file -p'

git clone https://github.com/charlesfg/TPCx-V_setup.git
cd TPCx-V_setup

bash -xe setup_tierA_datasource.sh 2>&1 | tee setup_tierA_datasource_$(hostname)_$(date +%Y-%m-%d_%H%M).log
su postgres -c "bash -xe tpc-gXa_connectivity_check.sh" 2>&1 | tee tpc-gXa_connectivity_check$(hostname)_$(date +%Y-%m-%d_%H%M).log

cat <<EOF
---------------------------------------------------------------
                          !!DONE!!
---------------------------------------------------------------
EOF
