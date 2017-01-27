#!/usr/bin/python

# NOTICE
# This software / technical data was produced for the U.S.
# Government under Prime Contract No. NNN12AA01C and JPL
# Contract Number 149581, and is subject to the FAR
# 52.227-14 (6/87) Rights in Data General.
#
# Approved for Public Release; Distribution Unlimited.
# MITRE Case Number XX-YYYY

#
# This script uses argparse and pexpect.  You can generally install python
# packages with 'pip install PACKAGE'
#
import sys
import argparse
import pexpect

# Needed to log things to Elasticsearch
import datetime
from elasticsearch import Elasticsearch

#
# On the node to be managed, you need to run 'nm_agent MY_EID MGR_EID'
#

# Somebody (the nm_mgr?) seems to be leaving bp_acq.XX files lying around.
# These look like they might be raw bundles?  Anyway, I don't think it's me...

def startReportGeneration(child, args):
	"""Connect to an agent and request that it start producing
	reports at a given rate."""
	count=0
	for agent in args.agent:
		print "Top of agent setup loop."
		child.write('1\n') # Admin menu
		child.expect('Return to Main Menu')
		child.write('1\n') # Register new agent
		child.expect('Enter EID of new agent')
		print 'Registering agent at EID %s' % (agent)
		child.write('%s\n' % (agent))
		child.expect('Return to Main Menu')
		child.write('z\n')
		child.expect('Exit')
		print 'Building time-based rule...'
		child.write('3\n') # Control menu
		child.expect('Return to Main Menu.')
		print '--- About to build arbitrary control.'
		print child.after
		print '---'
		child.write('9\n') # Build arbitrary control
		if count>0:
			child.expect('to cancel:')
			child.write('%d\n' % (count+1))
		child.expect('Control Timestamp')
		child.write('10\n')
		child.expect('Select One:')
		print "--- about to select MID from list"
		print child.after
		print "---"
		child.write('2\n') # Selecting an existing MID from a list
		child.expect('Select One:')
		child.write('15\n') # Add Ctrl MID
		child.expect('Select One:')
		child.write('1\n') # Provide hex for TRL ID
		child.expect('0x')
		child.write('1501020203\n')
		print 'Provided TRL ID'
		child.expect('Timestamp')
		child.write('10\n')
		child.expect('Period')
		child.write('%d\n' % (args.delay))
		child.expect('Count')
		child.write('%d\n' % (args.count))
		print "--- about to set # of MIDS"
		print child.after
		print "---"
		child.expect('# MIDS')
		child.write('1\n')
		child.expect('Select One:')
		child.write('2\n') # Select existing from list
		child.expect('Select One:')
		child.write('4\n') # Control
		child.expect('Select One:')
		child.write('10\n') # Generate Report
		child.expect('# MIDS:')
		child.write('1\n')
		child.expect('Select One:')
		child.write('2\n') # Select an existing MID from a list.
		child.expect('Select One:')
		child.write('6\n') # Report
		child.expect('Select One:')
		child.write('0\n') # BP_RPT_FULL_MID
		child.expect('# Items:')
		print 'Reports will be sent to: %s' % (args.sendToManager)
		child.write('%s\n' % (args.sendToManager)) # Where to send it.
		print 'Sent request for report.'
		child.expect('Return to Main Menu')
		print 'Exiting to main menu.'
		child.write('z\n')
		child.expect('Exit.')
		count += 1

def processReceivedReports(child, args):
	"""Continually read from the child, looking for new reports."""
	child.write('2\n') # Reporting menu
	first = 1 
	while True:
		timeout=int(2.5*args.delay+first*10)
		print 'Waiting %d for new data report.' % (timeout)
		try:
			# Extra delay first time to account for delay before
			# first report
			child.expect('mgr_rx_thread Received a data report.',
				timeout=timeout)
			first = 0
			print 'Report received.'
			count = 1
			for agent in args.agent:
				print 'working on agent %s' % (agent)
				child.write('4\n') # Print report

				# If more than one agent, have to give agent #
				if len (args.agent)>1:
					print 'I think this needs work...'
					print 'is cancel: the right string here?'
					child.expect('to cancel:')
					child.write('%d\n' % (count))
				print 'reading report output.'
				ret = child.expect('Return to Main Menu.')
				output = child.before
				if output.find('No reports received from this agent.')>0:
					print 'No report from agent %d' % (count)
					continue
				printFormattedOutput(output)
				print 'Clearing reports.'
				child.write('5\n') # Clear reports
				if len (args.agent)>1:
					child.expect('to cancel:')
					child.write('%d\n' % (count))
				print 'Cleared; waiting to return to main menu'
				child.expect('Return to Main Menu.')
				count += 1
		except pexpect.TIMEOUT:
			print 'Read for new report timed out; exiting'
			print 'last text received:\n'
			print child.after
			sys.exit(0)

def doMain(args):
	print 'Starting manager at EID: %s to agent(s): %s' % (args.manager, args.agent)
	child = pexpect.spawn('nm_mgr %s' % (args.manager))
	child.expect('Exit')
	if len(args.manager)>0:
		startReportGeneration(child, args)
	processReceivedReports(child, args)

def printFormattedOutput(output):
	"""Parse the output of a printed report into a dictionary and
	print the output."""
	end = output.find('=======')
	output = output[:end]
	lines = output.split('\n')
	vals = {}
	# print "========="
	# print lines
	# print "========="

	for l in lines:
		start = l.find('(')
		end = l.find(')')
		key = l[start+1:end]
		key = key.replace(' ', '_')
		if l.find('Timestamp')>=0:
			start = l.find(':')
			timestamp = l[start+1:].strip()
			tmp = datetime.datetime.strptime(timestamp, '%a %b %d %H:%M:%S %Y')
			tmp += datetime.timedelta(hours=5)   # Assume EST; I *HATE* timezones and time conversion in general
			vals['sendTimestamp'] = tmp.isoformat()
			continue
		if l.find('Value')>0:
			toks = l[end+1:].strip().split(' ')
			if key == 'ENDPT_NAMES':
				vals[key] = toks
			else:
				vals[key] = toks[0]
	print 'Timestamp: %s' % (datetime.datetime.utcnow().isoformat())
	for v in vals.keys():
		print '%s: %s' % (v, vals[v])

	if True:
		#
		# Build document for ELK
		#
		print "Sending to elasticsearch at 192.168.250.1..."
		es = Elasticsearch(['192.168.250.1'])
		vals['receiveTimestamp'] = datetime.datetime.utcnow().isoformat()
		res = es.index(index='bpnm',
			       doc_type='BP_RPT_FULL_MID',
			       timestamp=datetime.datetime.utcnow().isoformat(),
			       body=vals)
		print "ElasticSearch returned: %s" % (res)



if __name__=='__main__':
	DEF_MGR='ipn:3.5'
	DEF_AGENT='ipn:2.3'
	DEF_DELAY=5
	DEF_COUNT=5
	parser = argparse.ArgumentParser(description="""Connect to a
network management agent and request that it produce full BPA ADM reports
at a given rate for a period of time.""")
	parser.add_argument('--manager', '-m',
		default=DEF_MGR,
		help='EID of manager (%s)' % (DEF_MGR))
	parser.add_argument('--sendToManager', '-s',
		default=None,
		help='EID of manager to send reports to (%s)' % (DEF_MGR))
	parser.add_argument('--agent', '-a',
		default=[],
		action='append',
		help='EID(s) of agent(s) (%s)' % (DEF_AGENT))
	parser.add_argument('--delay', '-d', type=int,
		default=DEF_DELAY,
		help='How long between reports (%d).' % (DEF_DELAY))
	parser.add_argument('--count', '-c', type=int,
		default=DEF_COUNT,
		help='Number of reports (%d)' % (DEF_COUNT))

	args = parser.parse_args()
	if args.sendToManager==None:
		args.sendToManager = args.manager
	print args
	doMain(args)



