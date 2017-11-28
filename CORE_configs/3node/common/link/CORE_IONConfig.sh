#!/bin/bash
pushd .
THEDIR=`dirname $SESSION_FILENAME`
LOG=`hostname`.log
HOSTNAME=`hostname`

# 
# Wait until we can ping a location...
#
function waitForConnectivity {
	GOT=0
	DEST=$1

	while [ $GOT -lt 1 ]; do
		GOT=`ping $DEST -c 1 -W 5 | grep "1 received" | wc -l`
		if [ $GOT -lt 1 ]; then
			echo "  still no connectivity to $DEST" >> $LOG
			sleep 5
		fi
	done
}

echo "Starting nodeSetup" >> $LOG

# Link to config files
for file in $THEDIR/config/$NODE_NAME\.*; do
	ln -s $file
done
ln -s $THEDIR/config/contacts.ionrc


# Fix the max ltp spans in the initialization commands of
# .ltprc files  ION doesn't seem to like '0' as a max
# spans (it refuses to initialize ltp)
THELTPRC=`hostname`.ltprc
echo "Looking for ltprc file $THELTPRC" >> $LOG
if [ -e $THELTPRC ]; then
	echo "Munging ltprc file $THELTPRC" >> $LOG
	sed -e "s/^1 0/1 50/" $THELTPRC > temp.ltprc
	mv temp.ltprc $THELTPRC
else
	echo "No ltprc file ($THELTPRC) found." >> $LOG
fi

# Wait for OSPF to distribute routes.
echo "Waiting for connectivity..." >> $LOG
waitForConnectivity 10.0.0.2
waitForConnectivity 10.0.2.2
echo "IP connectivity established: " `date` >> $LOG

# Wait for everyone else to hopefully be ready.
sleep 5

# Start ION
echo "Starting ION" >> $LOG
ionadmin $NODE_NAME\.ionrc
ionadmin contacts.ionrc
sleep 1

if [ -f $NODE_NAME\.ltprc ]; then
	ltpadmin $NODE_NAME\.ltprc
else
	echo "No ltprc file for $NODE_NAME" >> $LOG
fi
sleep 1
echo "Running bpadmin on $NODE_NAME\.bprc" >> $LOG
bpadmin $NODE_NAME\.bprc
# bprc will run ipnadmin

sleep 1

if [ -f $NODE_NAME\.cfdprc ]; then
	echo "Running cfdpadmin on $NODE_NAME\.cfdprc" >> $LOG
	cfdpadmin $NODE_NAME\.cfdprc
else
	echo "No cfdprc file for $NODE_NAME" >> $LOG
fi
