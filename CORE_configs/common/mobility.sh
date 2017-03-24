# script to set up the date file the communicates to the nodes
time=`date -u +"%Y/%m/%d-%H:%M:%S"`
echo "Mobility script sets date / time to $time" >> `hostname`.log
echo "Mobility script sets date / time to $time" >> tmp/mobility.log
echo $time > /tmp/ionrcdate
