#!/bin/bash

#                       NOTICE
# This software / technical data was produced for the U.S. 
# Government under Prime Contract No. NNN12AA01C and JPL
# Contract Number 149581, and is subject to the FAR
# 52.227-14 (6/87) Rights in Data General.
#
#

source ./setEnv.sh

./rcgen.sh $IPN_NODE_NUMBER

sleep 10

echo "Starting ION" >> `hostname`.log
./startION.sh

