#!/usr/bin/python

import time
import pexpect
import os
import sys

print 'cwd is %s' % (os.getcwd())
sys.path.insert(0, os.getcwd())
from cg2Prefs import *

# THENODE='192.168.5.1'
# THEDIR='/home/core/.core/configs/NASADTNDevKit/square/common/link'

print 'sshing to %s' % (THENODE)
pexpect.run('ssh-keygen -f "/home/core/.ssh/known_hosts" -R %s' % (THENODE))

child = pexpect.spawn('ssh %s' % (THENODE))
child.expect('password:')
child.write('cvm\n')
child.expect('$')

child.write('cd %s\n' % (THEDIR))
child.expect('$')

print 'starting cg2.py'
time.sleep(1)
child.write('../common/cg2.py &\n')
child.expect('$')
print 'done'

print 'waiting'
time.sleep(300)

# print 'closing'
# child.close()
