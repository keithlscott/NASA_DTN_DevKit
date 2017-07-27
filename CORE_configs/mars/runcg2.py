#!/usr/bin/python

import time
import pexpect

pexpect.run('ssh-keygen -f "/home/core/.ssh/known_hosts" -R 192.168.240.1')

child = pexpect.spawn('ssh 192.168.240.1')
child.expect('password:')
child.write('cvm\n')
child.expect('$')

child.write('cd /home/core/.core/configs/NASADTNDevKit/mars\n')
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
