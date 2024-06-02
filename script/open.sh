#!/bin/bash

vm=()
for i in $(seq 1 21)
do
	IP=192.168.32.$(( 50+i ))
	ssh -o ConnectTimeout=1 root@$IP 'date' &> /dev/null; result=$?
	if [ "${result}" != 0 ];then
		mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='0' where vm='PC${i}-1' || vm='PC${i}-2';"
		continue
	fi
	for j in $(seq 1 2)
	do
		ssh -o ConnectTimeout=1 root@$IP virsh list | grep "PC${i}-${j}" &> /dev/null; vm_status=$?
		if [ ${vm_status} == 0 ];then
			# vm 有開機
			vm+=("PC${i}-${j}")
			check=`mysql -u root -p2727175#356 -D DaaS -e "select vmip from userinfo where vm='PC${i}-${j}' and (status='1' or status='2' or status='3')" -B -N`
			# vm 有開機且無使用者選定，則將 vm 狀態變為 0
			if [ -z "${check}" ];then
				mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='0' where vm='PC${i}-${j}'"
			fi
		else
			devm=`mysql -u root -p2727175#356 -D DaaS -e "select vm from pre_open where vm='PC${i}-${j}'"`
			# 因 vm 沒開機，條件未達成則刪除預備機
			if [ ${devm} ];then
				mysql -u root -p2727175#356 -D DaaS -e "delete from pre_open where vm='PC${i}-${j}'"
			fi
			check=`mysql -u root -p2727175#356 -D DaaS -e "select vmip from userinfo where vm='PC${i}-${j}' and (status='1' or status='2' or status='3')" -B -N`
			# vm 沒開機且無使用者選定，則將狀態變為 0
			if [ -z "${check}" ];then
				mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='0' where vm='PC${i}-${j}'"
			fi
		fi
	done
done

#mysql -u root -p2727175#356 -D DaaS -e "truncate table pre_open;"

for vm in ${vm[@]}
do
	check=`mysql -u root -p2727175#356 -D DaaS -e "select vmip from userinfo where vm='${vm}' and (status='1' or status='2' or status='3')" -B -N`
	# 無使用者選定
	if [ -z "${check}" ];then
		vm_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${vm}'" -B -N`
		cd /root/script/min
		vm_status=`./nc.sh ${vm_ip} 2> /dev/null`
		# 確定機器無人使用
		if [ "${vm_status}" ];then
			host_ip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_vm1='${vm}' || host_vm2='${vm}'" -B -N`
			mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='0' where vm='${vm}';"
			# insert pre_open
			invm=`mysql -u root -p2727175#356 -D DaaS -e "select vm from pre_open where vm='${vm}'"`
			# pre_open 內無此台 vm，則新增至 pre_open
			if [ -z "${invm}" ];then
				mysql -u root -p2727175#356 -D DaaS -e "insert into pre_open (vm,hostip,vmip) values('${vm}','${host_ip}','${vm_ip}');"
			fi
		# 機器已被使用
		else
			mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm='${vm}';"
			check_user=`./ncuser.sh ${vm_ip} 2> /dev/null`
			if [ "${check_user}" != "." && "${check_user}" >= "2" ];then
				echo "logoff user"
			fi
		fi
	fi
done
