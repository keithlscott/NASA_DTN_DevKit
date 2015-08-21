#!/bin/bash

NODE=9

echo `which ionstart` >> $myHostName.log
ionstart -a node.acsrc -b node.bprc -c node.cfdprc -i node.ionrc -l node.ltprc -p node.ipnrc -s node.ionsecrc

sleep 10

bpecho ipn:$NODE.1 >& bpecho.log &
bprecvfile ipn:$NODE.2 &


