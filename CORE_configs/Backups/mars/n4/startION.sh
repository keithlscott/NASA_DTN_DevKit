#!/bin/bash

echo `which ionstart` >> $myHostName.log
ionstart -a node4.acsrc -b node4.bprc -c node4.cfdprc -i node4.ionrc -l node4.ltprc -p node4.ipnrc -s node4.ionsecrc

sleep 10

bpecho ipn:4.1 >& bpecho.log &
bprecvfile ipn:4.2 &


