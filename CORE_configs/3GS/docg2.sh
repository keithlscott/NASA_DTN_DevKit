#!/bin/bash

DIR=/home/kscott/.core/configs/GSFC3/common/link

ssh-keygen -f "/home/kscott/.ssh/known_hosts" -R 192.168.240.5
ssh -X kscott@192.168.240.5 "$DIR/cg2.py"

