#!/bin/bash

echo `which ionstart` >> $myHostName.log
ionstart -a node6.acsrc -b node6.bprc -c node6.cfdprc -i node6.ionrc -l node6.ltprc -p node6.ipnrc -s node6.ionsecrc

sleep 10

bpecho ipn:6.1 >& bpecho.log &
bprecvfile ipn:6.2 &

