BASENAME=`hostname`
if [ -e IPN_NODE_NUMBER.txt ]; then
	IPN_NODE_NUMBER=`cat IPN_NODE_NUMBER.txt`
else
	IPN_NODE_NUMBER=`echo $BASENAME | tr -d [:alpha:]`
fi

echo "BASENAME is: $BASENAME"
echo "IPN_NODE is: $IPN_NODE_NUMBER"
