#!/bin/bash

# Wait for ion to be started

started=0

while [ $started -eq 0 ]; do
	count=`grep "ipnfw is running" ion.log | wc -l`
	if [ $count -gt 0 ]; then
		sleep 5
		break
	fi
	sleep 1
done


echo "a endpoint ipn:5.6 x" | bpadmin

