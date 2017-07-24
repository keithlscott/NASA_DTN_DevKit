#!/Library/Frameworks/Python.framework/Versions/3.5/bin/python3
#
# Convert the output of the JPL ION Configurator to work with ion verion 3.6.0
#

import sys
import re
import os
import pexpect
import shutil

ipnrcSections = ['PLAN']
curSection = None
doWrite = True

print('done with imports')

# Return dictionary of IP addresses keyed by node name
def getAddresses():
	theDict = {}
	theString = 'grep "with IP Name" * | grep -v grep | grep -v pexpect | sed -e "s/.*Node://" | sed -e "s/with IP Name://" | sed -e "s/]//" | sed -e "s/[^ ]* //" | tr -s " " | sort | uniq | grep -v localhost | grep -v "is a directory" 2> /dev/null\n'
	p = pexpect.spawn('/bin/bash')
	p.sendline(theString)
	p.sendeof()
	#time.sleep(5)
	a = p.read()
	count = 0
	print('a is ((%s))' % (a))
	for line in a.decode().split('\n'):
		line = line.strip().rstrip()
		print('working line ((%s))' % (line))
		if count>=len(a.decode().split('\n'))-3:
			continue
		else:
			count += 1
		if len(line)<5:
			print('Bailing on line: %s' % (line))
			continue
		b = (line.strip().rstrip()).split()
		if len(b)!=2:
			print('len(b) (%d)!=2' % (len(b)))
			continue
		theDict[b[0]] = b[1]
	print('addressDict is: %s' % (theDict))
	return theDict

#
# For each 'a plan X udp *' line, figure out the target
#
def fixIpnrcFile(fname, addresses):
	target = None
	dests = {}
	output = ''
	shutil.copyfile(fname, fname+'_orig')
	f = open(fname, 'r')
	theFile = f.read()
	lines = theFile.split('\n')
	for l in lines:
		for s in ipnrcSections:
			if l.find(s)>=0:
				curSection = s
				target = None
		#
		# Change 'a plan udp/*' to 'a plan udp/x.y.z.t'
		#
		if l.find('a plan')>=0:
			toks = l.split()
			if target==None or not toks[2] in dests:
				print('Error: no target for plan to %s.' % (toks[2]))
				sys.exit(0)
			elif toks[3][:3]=='tcp':
				pass
			elif toks[3][:3]=='udp':
				l = 'a plan %s udp/%s\n' % (toks[2], dests[toks[2]])
		if l.find('Destination node:')>=0:
			toks = l.split()
			if not toks[3] in dests:
				tmp = toks[-1]
				target = tmp.split(']')[0]
				dests[toks[3]] = target
		output += l
		output += '\n'
	print(output)
	f.close()
	if doWrite:
		of = open(fname, 'w')
		of.write(output)
		of.close()


def fixBprcFile(fname, addresses):
	output = ''
	shutil.copyfile(fname, fname+'_orig')
	f = open(fname, 'r')
	theFile = f.read()
	lines = theFile.split('\n')
	curSection = None
	destIP = None
	bprcSections = ['ENDPOINT', 'PROTOCOL', 'INDUCT', 'OUTDUCT']

	print('Processing .bprc file: %s' % (fname))
	for l in lines:
		print('line: %s' % (l))
		
		#
		# Detect Sections
		#
		for s in bprcSections:
			if l.find(s)>=0:
				curSection = s
				destIP = None
				protocol = None

		#
		# Detect OUTDUCT
		#
		if re.search('Protocol: *udp', l):
			protocol = 'udp'

		#
		# Cause TCP inducts to listen on INADDR_ANY
		#
		if l.find('a induct tcp')>=0:
			print('################')
			print('Found tcp induct.')
			l = 'a induct tcp 0.0.0.0 tcpcli\n'
		#
		# Cause UDP inducts to listen on INADDR_ANY
		#
		if l.find('a induct udp')>=0:
			print('################')
			print('Found udp induct.')
			l = 'a induct udp 0.0.0.0 udpcli\n'
		#
		# Modify 'a outduct udp * udpclo' to 'a outduct udp/x.y.z.t udpclo'
		# Ensure that the dest is an IP address and not localhost, since
		# the outduct code will use localhost and the plan code will use
		# an address.
		#
		if (l.find('Duct name:')>=0) and (l.find('with IP Name: ')>=0):
			toks = l.split()
			nodeName = toks[6]
			destIP = toks[-1][:-1]
			if destIP == 'localhost':
				print('theDict is: %s' % (addresses))
				destIP = addresses[nodeName]
		if l.find('a outduct udp * udpclo')>=0:
			l = 'a outduct udp %s udpclo' % (destIP)

		#
		# ADD 'a outduct udp' lines where the configurator throught they were
		# redundant.
		#
		if l.find('one outduct task per promiscuous protocol')>=0 and curSection=='OUTDUCT' and protocol=='udp':
			l = 'a outduct udp/%s:4556' % (destIP)

		output += l
		output += '\n'
	print(output)
	f.close()
	if doWrite:
		of = open(fname, 'w')
		of.write(output)
		of.close()

def main():
	addresses = getAddresses()

	# bprcFiles = [f for f in os.listdir('.') if (os.path.isfile(f) and f.find('.bprc')>0)]
	# ipnrcFiles = [f for f in os.listdir('.') if (os.path.isfile(f) and f.find('.ipnrc')>0)]
	bprcFiles = [f for f in os.listdir('.') if (os.path.isfile(f) and f[-5:]=='.bprc')]
	ipnrcFiles = [f for f in os.listdir('.') if (os.path.isfile(f) and f[-6:]=='.ipnrc')]

	for theFile in bprcFiles:
		print("working on %s" % (theFile))
		fixBprcFile(theFile, addresses)

	for theFile in ipnrcFiles:
		print("working on %s" % (theFile))
		fixIpnrcFile(theFile, addresses)

if __name__=='__main__':
	main()

