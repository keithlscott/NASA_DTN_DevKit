#!/bin/bash

echo `which ionstart` >> $myHostName.log
ionstart -a node5.acsrc -b node5.bprc -c node5.cfdprc -i node5.ionrc -l node5.ltprc -p node5.ipnrc -s node5.ionsecrc

sleep 10

bpecho ipn:5.1 >& bpecho.log &
bprecvfile ipn:5.2 &

