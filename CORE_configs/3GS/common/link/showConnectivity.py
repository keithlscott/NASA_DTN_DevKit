#!/usr/bin/python

import pexpect


def getContacts():

	ret = pexpect.run('/bin/bash -c "echo \'l contact\' | ionadmin"')
	print ret


def doMain():
	getContacts()

if __name__=='__main__':
	doMain()

