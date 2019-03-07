#!/bin/bash
set -o errexit

rm -rf /dbstore/*
mkdir -p /dbstore/tpcv-data
mkdir /dbstore/tpcv-index
mkdir /dbstore/tpcv-temp
chown -R postgres:postgres /dbstore
