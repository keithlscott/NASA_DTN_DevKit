#!/bin/bash

source ./setPath.sh

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh
