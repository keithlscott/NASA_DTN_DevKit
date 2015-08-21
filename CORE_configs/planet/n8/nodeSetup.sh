#!/bin/bash

source ./setPath.sh

./rcgen.sh 8

ip route add 10.0.5.1/32 dev eth0
ip route add 10.0.5.2/32 dev eth0
ip route add 10.0.5.3/32 dev eth0
ip route add 10.0.5.4/32 dev eth0
ip route add 10.0.5.5/32 dev eth0

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh

