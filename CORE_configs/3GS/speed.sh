#!/bin/bash

IDENT=c7

# Node 11 is GS1b
# Node 12 is GS2b
# Node 13 is GS3b
GS1=2
GS2=3
GS3=4
GS1b=b
GS2b=c
GS3b=d

SC=1
SC_XMIT=1
SC_RECV=0

speedometer -r veth$SC.$SC_RECV.$IDENT -t veth$SC.$SC_RECV.$IDENT -c \
	-t veth$GS1b.1.$IDENT -r veth$GS1.0.$IDENT \
	-t veth$GS2b.1.$IDENT -r veth$GS2.0.$IDENT \
	-t veth$GS3b.1.$IDENT -r veth$GS3.0.$IDENT

