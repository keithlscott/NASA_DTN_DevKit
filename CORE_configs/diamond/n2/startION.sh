#!/bin/bash

echo `which ionstart` >> $myHostName.log
ionstart -a node2.acsrc -b node2.bprc -c node2.cfdprc -i node2.ionrc -l node2.ltprc -p node2.ipnrc -s node2.ionsecrc

sleep 10

bpecho ipn:2.1 >& bpecho.log &
bprecvfile ipn:2.2 &

