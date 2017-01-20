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

bash -x format_dbstore.sh 2>&1 | tee format_dbstore_$(hostname)_$(date +%Y-%m-%d_%H%M).log
bash -x setup_dbstore_folders.sh 2>&1 | tee setup_dbstore_folders_$(hostname)_$(date +%Y-%m-%d_%H%M).log
bash -x setup_postgres.sh 2>&1 | tee setup_postgres_$(hostname)_$(date +%Y-%m-%d_%H%M).log

su postgres -c "bash -x create_database.sh" 2>&1 | tee create_database_$(hostname)_$(date +%Y-%m-%d_%H%M).log

su postgres -c "bash -x backup_db.sh" 2>&1 | tee backup_db_$(hostname)_$(date +%Y-%m-%d_%H%M).log

su postgres -c "bash -x restore_db.sh" 2>&1 | tee restore__$(hostname)_$(date +%Y-%m-%d_%H%M).log


cat <<EOF
---------------------------------------------------------------
                          !!DONE!!
---------------------------------------------------------------
EOF
