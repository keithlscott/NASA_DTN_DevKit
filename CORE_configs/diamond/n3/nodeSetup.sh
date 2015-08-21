#!/bin/bash

source ./setPath.sh

./rcgen.sh 3

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh

