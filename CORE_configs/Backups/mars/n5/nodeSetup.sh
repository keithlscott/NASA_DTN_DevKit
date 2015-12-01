#!/bin/bash

source ./setPath.sh

mkdir recv
./rcgen.sh 5

ip route add 10.0.3.1/24 dev eth1
ip route add 10.0.3.2/24 dev eth1
ip route add 10.0.3.3/24 dev eth1
ip route add 10.0.3.5/24 dev eth1

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh

