Topology:	n2 -UDPCL- n1
		n1 -UDPCL- n2
		n1 -TCPCL- n3
		n3 -TCPCL- n1

bpecho		.1 on all nodes
open		.2 on all nodes
nm_agent 	.5 on all nodes
bpstats2 	.10 on all nodes
