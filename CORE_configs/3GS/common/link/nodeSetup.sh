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
if [ $HOST == "SC" ]; then
	IPN_NODE_NUMBER=1
elif [ $HOST == "GS1" ]; then
	IPN_NODE_NUMBER=2
elif [ $HOST == "GS2" ]; then
	IPN_NODE_NUMBER=3
elif [ $HOST == "GS3" ]; then
	IPN_NODE_NUMBER=4
elif [ $HOST == "MO" ]; then
	IPN_NODE_NUMBER=5
elif [ $HOST == "ScienceOps" ]; then
	IPN_NODE_NUMBER=6
elif [ $HOST == "GS1b" ]; then
	IPN_NODE_NUMBER=22
elif [ $HOST == "GS2b" ]; then
	IPN_NODE_NUMBER=33
elif [ $HOST == "GS3b" ]; then
	IPN_NODE_NUMBER=44
fi


#IPN_NODE_NUMBER=`echo $HOST | sed -e "s/n//"`
sleep 10

echo "About to start bpecho ipn:$IPN_NODE_NUMBER.1" >> `hostname`.log
bpecho ipn:$IPN_NODE_NUMBER.1 >> `hostname`.log &
echo "Done starting bpecho." >> `hostname`.log


#
# Set up network management agent on .5
#
MANAGER=ipn:5.6
echo "a endpoint ipn:$IPN_NODE_NUMBER.5 x" | bpadmin
nm_agent ipn:$IPN_NODE_NUMBER.5 $MANAGER &> nm_agent.out &

#
echo "a endpoint ipn:$IPN_NODE_NUMBER.10 x" | bpadmin
bpstats2 ipn:$IPN_NODE_NUMBER.10 &> /dev/null &

#
# Add a route to the lo:0 of the host where ELK is running.
# For now everyone has 'control LAN' access to this.
#
ip route add 192.168.250.0/24 via 192.168.240.254

echo "nodeSetup ending" >> `hostname`.log

