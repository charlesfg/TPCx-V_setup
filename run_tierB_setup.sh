#!/bin/bash

set -o errexit


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

bash format_dbstore.sh
bash setup_dbstore_folders.sh
bash setup_postgres.sh
su postgres -c "bash create_database.sh"
su postgres -c "bash -x backup_db.sh"
su postgres -c "bash restore_db.sh"

cat <<EOF
---------------------------------------------------------------
                          !!DONE!!
---------------------------------------------------------------
EOF
