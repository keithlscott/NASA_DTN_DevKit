#!/usr/bin/python

# NOTICE
# This software / technical data was produced for the U.S.
# Government under Prime Contract No. NNN12AA01C and JPL
# Contract Number 149581, and is subject to the FAR
# 52.227-14 (6/87) Rights in Data General.
#
# Approved for Public Release; Distribution Unlimited.
# MITRE Case Number XX-YYYY

import pexpect
import argparse
import datetime
import time
from elasticsearch import Elasticsearch

def requestStats(myEID, fromEID):
	child = pexpect.spawn('bpchat %s %s' % (myEID, fromEID))
	child.write('\n')
	return child

def nodeNumberFromIPNEID(ipnEID):
	if ipnEID=='none':
		return 0
	a = ipnEID.find(':')
	a += 1
	b = ipnEID.find('.')
	return int(ipnEID[a:b])

def parseResults(child, fromEID):
	try:
		doc = {}
		ret = child.expect('xxx', timeout=5)
	except:
		print "request for stats returned:"
		print child.before
		lines = child.before.split('\n')
		print "got %d lines" % (len(lines))
		if len(lines)<5:
			return
		
		doc = {'nodeNumber': nodeNumberFromIPNEID(fromEID)}
		for l in lines:
			if l.find("[x]")>=0:
				toks = l.split()
				doc['sendTimestamp'] = datetime.datetime.utcfromtimestamp(int(toks[5][:-1])).isoformat()
				key = toks[1]
				indices = [7, 10, 13]
				for index in range(len(indices)):
					doc[key+'_%d_bundles' % (index)] = int(toks[indices[index]])
					doc[key+'_%d_bytes' % (index)]   = int(toks[indices[index]])
				doc[key+'_total_bundles'] = int(toks[16])
				doc[key+'_total_bytes'] = int(toks[17])
			else:
				pass
		print doc

		if not 'sendTimestamp' in doc.keys():
			return

                #
                # Build document for ELK
                #
                es = Elasticsearch(['192.168.250.1'])
		doc['receiveTimestamp'] = datetime.datetime.utcnow().isoformat()
                res = es.index(index='bpnm',
                               doc_type='BPStats',
                               timestamp=doc['sendTimestamp'],
                               body=doc)
		print res


def doMain():
	child = requestStats('ipn:5.10', 'ipn:2.10')
	parseResults(child, 'ipn:2.10')

if __name__=='__main__':
	doMain()

