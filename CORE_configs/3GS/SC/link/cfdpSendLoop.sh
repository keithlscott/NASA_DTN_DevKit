#!/bin/bash

function sendOne {
	SIZE_KB=$1
	DEST=$2
	BASENAME=`mktemp XXXXXX`
	rm $BASENAME
	DATAFILENAME="$BASENAME.dat"
	CMDSFILENAME="cfdpCMDS_$BASENAME.txt"
	dd if=/dev/urandom of=$DATAFILENAME bs=1024 count=$SIZE_KB
	echo "d $2" >> $CMDSFILENAME
	echo "f $DATAFILENAME" >> $CMDSFILENAME
	echo "t $DATAFILENAME.recv" >> $CMDSFILENAME
	echo "m 2" >> $CMDSFILENAME
	echo "a 3600" >> $CMDSFILENAME
	echo "&" >> $CMDSFILENAME

	cfdptest $CMDSFILENAME
}

sendOne 500 6

