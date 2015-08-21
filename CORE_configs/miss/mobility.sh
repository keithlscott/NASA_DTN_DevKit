# script to set up the date file the communicates to the nodes
time=`date -u +"%Y/%m/%d-%H:%M:%S"`
echo $time > /tmp/ionrcdate
