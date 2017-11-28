#!/bin/bash

# NOTE: Will be overwritten by node-specific setup files
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

HOST=`hostname`
IPN_NODE_NUMBER="0"
MANAGER="None"

if [ -f generalParams.sh ]; then
	source generalParams.sh
fi

if [ -f nodeParams.sh ]; then
	source nodeParams.sh
fi

if [ $IPN_NODE_NUMBER == "0" ]; then
	IPN_NODE_NUMBER=`hostname | tr -d 'a-z'`
fi

echo "IPN_NODE_NUMBER is: $IPN_NODE_NUMBER"

echo "Looking to run ./CORE_IONConfig.sh with node number $IPN_NODE_NUMBER" >> `hostname`.log
if [ -e ./CORE_IONConfig.sh ]; then
        echo "About to run CORE_IONConfig.sh with node number $IPN_NODE_NUMBER"
        ./CORE_IONConfig.sh &> CORE_IONConfig.out
        echo "CORE_IONConfig.sh done"
else
        echo "No ./CORE_IONConfig.sh file to run."
fi
echo "CORE_IONConfig done" >> `hostname`.log


echo "About to start bpecho ipn:$IPN_NODE_NUMBER.1" >> `hostname`.log
bpecho ipn:$IPN_NODE_NUMBER.1 >> `hostname`.log &
echo "Done starting bpecho." >> `hostname`.log


#
# Set up network management agent on .5
#
if [ $MANAGER == "None" ]; then
	echo "No network manager" >& nm_agent.out
else
	echo "a endpoint ipn:$IPN_NODE_NUMBER.5 x" | bpadmin
	nm_agent ipn:$IPN_NODE_NUMBER.5 $MANAGER &> nm_agent.out &
fi

#
echo "a endpoint ipn:$IPN_NODE_NUMBER.10 x" | bpadmin
bpstats2 ipn:$IPN_NODE_NUMBER.10 &> /dev/null &

#
# Add a route to the lo:0 of the host where ELK is running.
# For now everyone has 'control LAN' access to this.
#
ip route add 192.168.250.0/24 via 192.168.240.254

echo "nodeSetup ending" >> `hostname`.log

