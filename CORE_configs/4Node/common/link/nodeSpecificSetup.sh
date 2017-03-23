#!/bin/bash

# NOTE: Will be overwritten by node-specific setup files
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

echo "Looking to run ./CORE_IONConfig.sh" >> `hostname`.log
if [ -e ./CORE_IONConfig.sh ]; then
        echo "About to run CORE_IONConfig.sh"
        ./CORE_IONConfig.sh &> CORE_IONConfig.out
        # ./CORE_IONConfig.sh 
        echo "CORE_IONConfig.sh done"
else
        echo "No ./CORE_IONConfig.sh file to run."
fi
echo "CORE_IONConfig done" >> `hostname`.log


HOST=`hostname`
if [ $HOST == "n1" ]; then
	IPN_NODE_NUMBER=1
elif [ $HOST == "n2" ]; then
	IPN_NODE_NUMBER=2
elif [ $HOST == "n3" ]; then
	IPN_NODE_NUMBER=3
fi


#IPN_NODE_NUMBER=`echo $HOST | sed -e "s/n//"`
sleep 10

echo "About to start bpecho ipn:$IPN_NODE_NUMBER.1" >> `hostname`.log
bpecho ipn:$IPN_NODE_NUMBER.1 >> `hostname`.log &
echo "Done starting bpecho." >> `hostname`.log




