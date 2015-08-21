#!/bin/bash

echo `which ionstart` >> $myHostName.log
ionstart -a node1.acsrc -b node1.bprc -c node1.cfdprc -i node1.ionrc -l node1.ltprc -p node1.ipnrc -s node1.ionsecrc

sleep 10

bpecho ipn:1.1 >& bpecho.log &
bprecvfile ipn:1.2 &


