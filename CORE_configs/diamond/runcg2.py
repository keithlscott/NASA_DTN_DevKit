#!/usr/bin/python

import time
import pexpect

pexpect.run('ssh-keygen -f "/home/core/.ssh/known_hosts" -R 192.168.5.2')

child = pexpect.spawn('ssh 192.168.5.2')
child.expect('password:')
child.write('cvm\n')
child.expect('$')

child.write('cd /home/core/.core/configs/NASADTNDevKit/diamond/common/link\n')
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
