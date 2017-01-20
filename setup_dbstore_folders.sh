#!/bin/bash
set -o errexit


mkdir -p /dbstore/tpcv-data
mkdir /dbstore/tpcv-index
mkdir /dbstore/tpcv-temp
chown -R postgres:postgres /dbstore
