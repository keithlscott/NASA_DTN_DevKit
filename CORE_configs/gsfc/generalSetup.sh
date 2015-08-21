#!/bin/bash

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

# Link to all files in $sessionDir/links
for theFile in $sessionDir/*; do
	ln -s $theFile
done

for file in $sessionDir/$myHostName/*; do
	echo "Linking to " $file >> $myHostName.log
	ln -s $file
done

# Scripts with these names WILL have been linked in from the above.
./setPath.sh
./nodeSetup.sh

echo "PATH is: " $PATH >> $myHostName.log

