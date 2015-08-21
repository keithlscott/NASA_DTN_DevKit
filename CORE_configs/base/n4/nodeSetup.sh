#!/bin/bash

source ./setPath.sh

./rcgen.sh 4
ip route add 10.3.3.2/24 dev eth0

sleep 10
echo "Starting ION" >> `hostname`.log
./startION.sh

