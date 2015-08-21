#!/bin/bash

echo `which ionstart` >> $myHostName.log
ionstart -a node3.acsrc -b node3.bprc -c node3.cfdprc -i node3.ionrc -l node3.ltprc -p node3.ipnrc -s node3.ionsecrc

sleep 10

bpecho ipn:3.1 >& bpecho.log &
bprecvfile ipn:3.2 &

