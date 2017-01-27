#!/bin/bash

MANAGER=ipn:5.5

echo 'a endpoint ipn:2.5 x' | bpadmin
nm_agent ipn:2.5 $MANAGER &> nm_agent.out &

