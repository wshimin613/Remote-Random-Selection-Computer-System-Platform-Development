#!/bin/bash

#use_scan_vm(){
	ava_vm=()
	vm_num=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm_status=0" -B -N | wc -l`
	for i in $( seq 1 $vm_num )
	do
		vm=`mysql -u root -p2727175#356 -D DaaS -e "select vm from vm where vm_status=0" -B -N | sed -n "${i},${i}p"`
		host=`mysql -u root -p2727175#356 -D DaaS -e "select vm from vm where vm_status=0" -B -N | sed -n "${i},${i}p" | cut -d '-' -f 1 | cut -c 3-`
		host_ip="192.168.32.$((50+${host}))"

		# 確認 host 狀態是否開機
		ssh -o ConnectTimeout=1 root@${host_ip} 'date' &> /dev/null; result=$?
		if [ "${result}" != 0 ];then
			continue
		fi
		
		# host有開，確認 vm 狀態是否開機
		ssh -o ConnectTimeout=1 root@${host_ip} virsh list | grep ${vm} &> /dev/null; vm_status=$?
		if [ ${vm_status} != 0 ];then
			ava_vm+=("${vm}")
		fi
	done
	echo ${ava_vm[@]}
#}
