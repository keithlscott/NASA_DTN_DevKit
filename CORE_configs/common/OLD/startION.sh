#!/bin/bash

#                       NOTICE
# This software / technical data was produced for the U.S. 
# Government under Prime Contract No. NNN12AA01C and JPL
# Contract Number 149581, and is subject to the FAR
# 52.227-14 (6/87) Rights in Data General.
#
#

source ./setEnv.sh

echo `which ionstart` >> `hostname`.log 
BASENAME=`hostname`
ionadmin $BASENAME\.ionrc
ltpadmin $BASENAME\.ltprc
acsadmin $BASENAME\.acsrc
if [ -e $BASENAME\.bssprc ]; then
	bsspadmin $BASENAME\.bssprc
fi
ionsecadmin $BASENAME\.ionsecrc
bpadmin $BASENAME\.bprc
ipnadmin $BASENAME\.ipnrc

sleep 10

echo "Starting bpecho on $IPN_NODE_NUMBER\.1" >> `hostname`.log 
bpecho ipn:$IPN_NODE_NUMBER\.1 >> bpecho.log &
echo "Starting bprecvfile on $IPN_NODE_NUMBER\.2" >> `hostname`.log 
bprecvfile ipn:$IPN_NODE_NUMBER\.2 >> bprecvfile.log


