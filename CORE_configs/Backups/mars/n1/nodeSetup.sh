#!/bin/bash

source ./setPath.sh

mkdir recv
./rcgen.sh 1

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh

