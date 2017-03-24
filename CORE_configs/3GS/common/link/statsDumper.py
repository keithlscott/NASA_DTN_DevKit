#!/usr/bin/python

import pexpect

def getStats():
	res = pexpect.run('bpstats')

def parseIONLog():
	res = pexpect.run('tail -40 ion.log')
	print 'Raw results:'
	print res
	lines = res.split('\n')
	count = len(lines)
	print 'Found %d lines' % (count)
	for l in lines[::-1]:	# Process in reverse order
		print 'Examining line: %s' % (l)
		if l.find('end of statistics snapshot...')>=0:
			lastLine = count
			print 'Found lastLine: %d' % (count)
		if l.find('Start of statistics snapshot...')>=0:
			return(lines[count:])
		count -= 1
	return []


if __name__=='__main__':
	getStats()
	res = parseIONLog()
	if len(res)>0:
		print "Found a statistics block"
		for l in res:
			print l
	else:
		print 'Couldnt find stats.'

