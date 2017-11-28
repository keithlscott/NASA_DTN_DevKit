#!/bin/bash

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
