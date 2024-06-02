#!/bin/bash

for i in $( seq 1 21 )
do
	ip=192.168.31.$(( 50+i ))
	ssh root@${ip} "hostnamectl set-hostname host${i}"; result=$?
	if [ ${result} == 0 ];then
		echo "HOST${i} is OK"
	fi
done
