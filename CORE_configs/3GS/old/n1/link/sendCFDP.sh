#!/bin/bash

NONCE=`date +"%s"`
echo "d 4
f nodeSetup.out
t cfdpRecv.$NONCE
a 10
&
" > cfdpCmds

cfdptest < cfdpCmds
