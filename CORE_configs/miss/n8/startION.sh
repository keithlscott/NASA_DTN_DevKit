#!/bin/bash

echo `which ionstart` >> $myHostName.log
ionstart -a node8.acsrc -b node8.bprc -c node8.cfdprc -i node8.ionrc -l node8.ltprc -p node8.ipnrc -s node8.ionsecrc

sleep 10

bpecho ipn:8.1 >& bpecho.log &
bprecvfile ipn:8.2 &

