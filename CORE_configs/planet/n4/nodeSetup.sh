#!/bin/bash

source ./setPath.sh

./rcgen.sh 4

ip route add 10.0.5.6/24 dev eth1

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh
