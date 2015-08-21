#!/bin/bash

source ./setPath.sh

./rcgen.sh 4

sleep 10
echo "Starting ION" >> `hostname`.log
./startION.sh

