#!/bin/bash

# NOTICE
# This software / technical data was produced for the U.S.
# Government under Prime Contract No. NNN12AA01C and JPL
# Contract Number 149581, and is subject to the FAR
# 52.227-14 (6/87) Rights in Data General.
#
# Approved for Public Release; Distribution Unlimited.
# MITRE Case Number XX-YYYY

export LD_LIBRARY_PATH=/usr/local/bin:$LD_LIBRARY_PATH

logfile=`hostname`.log
myDir=`dirname $SESSION_FILENAME`/`hostname`

linkFiles()
{
	echo "linking files" >> $logfile
	if [ ! -d $1 ]; then
		echo "No dir to link:" $1
	else
		DIR=$1
		num=`ls $DIR | wc -l`
		if [ $num -eq 0 ]; then
			echo "no files to link in $DIR" >> $logfile
		else
			for file in $DIR/*; do
				justName=`basename $file`
				if [ -e $justName ]; then
					rm $justname
				fi
				echo "linking $file" >> $logfile
				ln -s $file
			done
		fi
	fi
}

copyFiles()
{
	echo "copying files" >> $logfile
	if [ ! -d $1 ]; then
		echo "No dir to copy:" $1
	else
		DIR=$1
		num=`ls $DIR | wc -l`
		if [ $num -eq 0 ]; then
			echo "no files to copy in $DIR" >> $logfile
		else
			for file in $DIR/*; do
				justName=`basename $file`
				if [ -e $justName]; then
					rm $justName
				fi
				echo "copying $file" >> $logfile
				cp $file .
			done
		fi
	fi
}

#
# Common Setup
#
linkFiles `dirname $SESSION_FILENAME`/common/link
copyFiles `dirname $SESSION_FILENAME`/common/copy

#
# Node-Specific Setup
#
echo "Looking for node-specific files in $myDir" >> $logfile
linkFiles $myDir/link
copyFiles $myDir/copy

echo "Looking to run ./nodeSetup.sh" >> $logfile
if [ -e ./nodeSetup.sh ]; then
	echo "About to run nodeSeup.sh"
	./nodeSetup.sh &> nodeSetup.out
	echo "nodeSetup.sh done" >> $logfile
else
	echo "No ./nodeSetup.sh file to run." >> $logfile
fi

echo "Looking to run ./nodeSpecificSetup.sh" >> $logfile
if [ -e ./nodeSpecificSetup.sh ]; then
	echo "About to run nodeSpecificSeup.sh"
	./nodeSpecificSetup.sh &> nodeSpecificSetup.out
	echo "nodeSpecificSetup.sh done" >> $logfile
else
	echo "No ./nodeSpecificSetup.sh file to run." >> $logfile
fi

echo "Done with generalSetup.sh" >> $logfile

