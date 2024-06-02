#!/bin/bash
# This script is for no used user
# exec: sh autocreate.sh kai 200.200.200.2 20001

. /root/script/min/function.sh --source-only
#. /root/script/RDPclass/test2.sh --source-only

#auto_scan_vm

#echo ${available}
#echo ${ava_vm[@]}

auto_scan_host
if [ "${ava_host[0]}" ];then
	echo 'OK'
else 
	echo 'NO'
fi
