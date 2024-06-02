#!/bin/bash

user_total=`mysql -u root -p2727175#356 -D DaaS -e "select username from userinfo where status='1'" -B -N | wc -l`
num=`echo $(( ${user_total} - 1 ))`
for i in $( seq 0 "${num}" )
do
	username=`mysql -u root -p2727175#356 -D DaaS -e "select username from userinfo where status='1' Limit ${i},1" -B -N`
	user_status=`mysql -u root -p2727175#356 -D DaaS -e "select status from userinfo where username='${username}'" -B -N`

	if [ "${user_status}" == '1' ];then
		IP=`mysql -u root -p2727175#356 -D DaaS -e "select IP from userinfo where username='${username}'" -B -N`
		port=`mysql -u root -p2727175#356 -D DaaS -e "select port from userinfo where username='${username}'" -B -N`
		vm=`mysql -u root -p2727175#356 -D DaaS -e "select vm from userinfo where username='${username}'" -B -N`
		vm_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vmip from userinfo where username='${username}'" -B -N`
		host_ip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_vm1='${vm}' || host_vm2='${vm}'" -B -N`
		ssh -o ConnectTimeout=1 root@${host_ip} "virsh list | grep ${vm}" &> /dev/null; vm_status=$?
		if [ "${vm_status}" -eq "0" ];then
			firewall=`iptables-save | grep "PREROUTING" | grep "${IP}" | grep "${port}" | grep "${vm_ip}"`
			if [ -z "${firewall}" ];then
				user_time=`sh /root/script/min/user_time.sh ${vm_ip} ${username} 2> /dev/null`
				login=`mysql -u root -p2727175#356 -D DaaS -e "select login from userinfo where username='${username}'" -B -N`
				#if [ "${user_time}" != '.' ]&&[ "${user_time}" -ge "1" ];then
				if [ "${user_time}" -ge "180" ];then
					/root/script/min/ncuser.sh ${vm_ip} ${username} | grep Active 2> /dev/null
					status1=$?
					/root/script/min/ncuser.sh ${vm_ip} ${username} | grep Disc 2> /dev/null
					status2=$?
					if [ "${status1}" -eq "0" ];then
						user_id=`/root/script/min/ncuser.sh ${vm_ip} ${username} | awk '{print $3}' 2> /dev/null`
					elif [ "${status2}" -eq "0" ];then
						user_id=`/root/script/min/ncuser.sh ${vm_ip} ${username} | awk '{print $2}' 2> /dev/null`
					fi
					/root/script/min/logoff.sh ${vm_ip} ${user_id}
					res=$?
                	                if [ "${res}" -eq "0" ];then
						echo "${username} 閒置登出"
                	                	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set status=0 where username='${username}'"
                	                	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set login=0 where username='${username}'"
                	                fi
				elif [ "${user_time}" == '' ]&&[ "${login}" -eq "1" ];then
					echo "${username} 正常登出"
					mysql -u root -p2727175#356 -D DaaS -e "update userinfo set status=0 where username='${username}'"
                	               	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set login=0 where username='${username}'"
				else 
					echo "${username} used"
				fi
			fi
		else 
			mysql -u root -p2727175#356 -D DaaS -e "update userinfo set status=0 where username='${username}'"
                	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set login=0 where username='${username}'"
		fi
	fi
done
