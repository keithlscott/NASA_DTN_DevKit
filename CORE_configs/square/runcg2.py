#!/usr/bin/python

import time
import pexpect

source cg2Prefs.py

THENODE='192.168.5.1'
THEDIR='/home/core/.core/configs/NASADTNDevKit/square/common/link'

pexpect.run('ssh-keygen -f "/home/core/.ssh/known_hosts" -R %s' % (THENODE))

child = pexpect.spawn('ssh %s' % (THENODE))
child.expect('password:')
child.write('cvm\n')
child.expect('$')

child.write('cd %s\n' % (THEDIR))
child.expect('$')

print 'starting cg2.py'
time.sleep(1)
child.write('./cg2.py &\n')
child.expect('$')
print 'done'

print 'waiting'
time.sleep(300)

# print 'closing'
# child.close()
