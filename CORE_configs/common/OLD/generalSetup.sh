#!/bin/bash

#                       NOTICE
# This software / technical data was produced for the U.S. 
# Government under Prime Contract No. NNN12AA01C and JPL
# Contract Number 149581, and is subject to the FAR
# 52.227-14 (6/87) Rights in Data General.
#
#

sleep 2
export myHostName=`hostname`

if [ -z "$SESSION_FILENAME" ]; then
	# The new way -- allows setPath to be run from inside CORE
	# OR a host shell.  
	DIR=$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )
	sessionDir=`dirname $DIR`
	echo "Using HOST method to set sessionDir to $sessionDir" >> $myHostName.log
else
	# For virtual nodes running inside CORE
	sessionDir=`dirname $SESSION_FILENAME`
	echo "Using CORE method to set sessionDir to $sessionDir" >> $myHostName.log
fi

# Link to all files in $sessionDir/common
echo "Linking files from $sessionDir/../common:" >> $myHostName.log
for file in $sessionDir/../common/*; do
	echo "    Linking to " $file >> $myHostName.log
	ln -s $file
done

# Link to things common to this scenario
echo "Linking files from $sessionDir/$myHostName/common:" >> $myHostName.log
for file in $sessionDir/common/*; do
	echo "    Linking to " $file >> $myHostName.log
	ln -s $file
done

# Link to the node-specific files for my host
echo "Linking files from $sessionDir/$myHostName:" >> $myHostName.log
for file in $sessionDir/$myHostName/*; do
	echo "    Linking to " $file >> $myHostName.log
	ln -s $file
done

# Scripts with these names WILL have been linked in from the above.
sh ./setEnv.sh
echo "Running ./nodeSetup.sh" >> $myHostName.log
./nodeSetup.sh

echo "PATH is: " $PATH >> $myHostName.log

