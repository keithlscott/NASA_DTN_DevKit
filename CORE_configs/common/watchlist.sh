#!/bin/bash

#                       NOTICE
# This software / technical data was produced for the U.S. 
# Government under Prime Contract No. NNN12AA01C and JPL
# Contract Number 149581, and is subject to the FAR
# 52.227-14 (6/87) Rights in Data General.
#
#

#check if ion startup is done and print
if [ -f ion.log ]
then
	#print how many bundles are in the bp queue
	echo BP queue: `bplist | grep Destination | wc -l`
	#print how many bundles this node has sourced
	bpstats && tail ion.log | awk '/src/ { print "Sourced:", $18 }'
	echo "---------"
	echo ION: RUNNING
else
	echo "---------"
	echo ION: STARTING UP
fi


