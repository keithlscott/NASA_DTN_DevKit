#!/usr/bin/python
import pexpect
import time

theDict = {}
theString = 'grep "with IP Name" * | grep -v grep | grep -v pexpect | sed -e "s/.*Node://" | sed -e "s/with IP Name://" | sed -e "s/]//" | tr -s " " | sort | uniq | grep -v localhost\n'
p = pexpect.spawn('/bin/bash')
p.sendline(theString)
p.sendeof()
#time.sleep(5)
a = p.read()
print a
count = 0
for line in a.split('\n'):
	if count>=len(a.split('\n'))-3:
		continue
	else:
		count += 1
	if len(line)<5:
		continue
	print 'line is', line
	b = (line.strip().rstrip()).split()
	if len(b)!=2:
		continue
	print b
	print b[0], b[1]
	theDict[b[0]] = b[1]
#a = p.read_nonblocking(timeout=1)
# a = pexpect.run('bash -c "%s"' % (theString))
#a = pexpect.run('bash -c "grep \"with IP Name\" *"')
print theDict

