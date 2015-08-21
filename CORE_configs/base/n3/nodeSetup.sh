#!/bin/bash

source ./setPath.sh

./rcgen.sh 3
ip route add 10.3.3.1/24 dev eth2

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh

