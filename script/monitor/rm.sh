#!/bin/bash

for i in $( seq 1 21 )
do
	ip=192.168.31.$(( i+50 ))
	#ssh -f -o ConnectTimeout=1 root@${ip} "rm -rf /root/monitor.sh"
	ssh -f -o ConnectTimeout=1 root@${ip} "rm -rf /root/hardware.json"
	#ssh -f -o ConnectTimeout=1 root@${ip} "reboot"
done
