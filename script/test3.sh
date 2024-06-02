#!/bin/bash

#vm_ip=${1}
#cd /root/script/min
#nc=`./nc.sh ${vm_ip}`
#if [ -z "${nc}" ];then
#	ssh -o ConnectTimeout=1 root@192.168.32.52 "date" &> /dev/null; result=$?
#	if [ "${result}" == 0 ];then
#		ssh -o ConnectTimeout=1 root@192.168.32.52 "virsh list | grep 'PC2-2'" &> /dev/null; vm=$?
#		if [ "${vm}" == 0 ];then
#			echo 'userinfo'
#		else
#			echo 'No user and vm no open can do'
#		fi
#	else
#		echo 'No user and host no open can do'
#	fi
#else
#	echo 'No user'
#fi

#user_status=`sh /root/script/min/user_time.sh 192.168.32.1 4070C031`
#if [ "{user_status}" == '' ];then
#
#	echo 'YES'
#fi

test1=`echo "123"`

if [ ${test1} != "" ];then
	echo "YES"
fi
