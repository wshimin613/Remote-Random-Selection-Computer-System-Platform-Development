#!/bin/bash
#ex: sh autocreate3.sh 4070C004 120.114.140.34 11111

username=${1}
user_IP=${2}
user_port=${3}

. /root/script/min/function.sh --source-only

# 判斷有沒有使用過 | insert 跟 update
check_used=`mysql -u root -p2727175#356 -D DaaS -e "select username from userinfo where username='${username}'" -B -N`
if [ $check_used ];then
    #no vm and vm_ip
    mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=4 where username='${username}'"
else
    mysql -u root -p2727175#356 -D DaaS -e "insert into userinfo (username,IP,port,vm,vmip,status) values('${username}','${user_IP}',${user_port},'${vm}','${vm_ip}',4);"
fi

#vm isn't open but host is open
#auto_scan_vm
use_scan_vm
if [ "${ava_vm[0]}" ];then
	i=0
	result='1'
	until [ "${result}" == 0 ]
	do
		vm=${ava_vm[$i]}
		mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm='${vm}'"
		host_ip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_vm1='${vm}' || host_vm2='${vm}'" -B -N`
		vm_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${vm}'" -B -N`
		ssh -o ConnectTimeout=1 root@$host_ip "virsh create /vm_data/xml/${vm}.xml" &> /dev/null; result=$?
		mysql -u root -p2727175#356 -D DaaS -e "update userinfo set vm='${vm}',vmip='${vm_ip}',status='3' where username='${username}'"
		if [ "${i}" == ${#ava_vm[@]} ];then
                    return 5
                    break
                fi
		i=$(( $i+1 ))
	done

	if [ "${result}" == 0 ];then
		vm_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${vm}'" -B -N`
		i=0
                result='1'
            	until [ "$result" == 0 ]
            	do
                	single_scan $host_ip $vm $vm_ip $username
                	result=$?
                	i=$(echo $(($i+1)))
                	sleep 5
                	if [ "$i" == 17 ];then
                    		return 5
                    		break
                	fi
            	done
		if [ "${result}" == 0 ];then
			firewall ${user_IP} ${user_port} ${vm_ip}
			createRDP ${username} ${user_IP} ${user_port} ${vm} ${vm_ip}
			mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=1 where username='${username}'"
		else
			mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=5 where username='${username}'"
			curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} 使用者開機異常" https://notify-api.line.me/api/notify > /dev/null
		fi
	else
		#mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=5 where username='${username}'"
		auto_scan_host
		if [ "${ava_host[0]}" ];then
			i=0
			result='1'
			until [ "${result}" == 0 ]
			do
				if [ "${ava_host[$i]}" == '' ];then
                                	break
                        	fi
				pcmac=`mysql -u root -p2727175#356 -D GFDO -e "select mac from host where host_num='${ava_host[$i]}'" -B -N`
                        	host_ip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_num='${ava_host[$i]}'" -B -N`
                        	vm="PC${ava_host[$i]}-1"
				vm2="PC${ava_host[$i]}-2"
                        	vm_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${vm}'" -B -N`
                        	vm2_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${vm2}'" -B -N`
                        	mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm='${vm}'"
                        	ether-wake "$pcmac"
                        	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set vm='${vm}',vmip='${vm_ip}',status='2' where username='${username}'"
                        	sleep 50
                        	ssh -o ConnectTimeout=1 root@"${host_ip}" 'date' &> /dev/null;hostres=$?
				if [ "${hostres}" == 0 ];then
					openvm ${pcmac} ${vm} ${host_ip}
					res=$?
					mysql -u root -p2727175#356 -D DaaS -e "update userinfo set status='3' where username='${username}'"
					if [ "${res}" == 0 ];then
						j=0
						until [ "${result}" == 0 ]
						do
							single_scan $host_ip $vm $vm_ip $username
							result=$?
							j=$(echo $(($j+1)))
							sleep 5
							if [ "$j" == 17 ];then
								return 5
								break
							fi
						done
					else
						vm=${vm2}
                                        	vm_ip=${vm2_ip}
                                        	openvm ${pcmac} ${vm} ${host_ip}
                                        	res=$?
                                        	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set status='3' where username='${username}'"
                                        	if [ "${res}" == 0 ];then
                                                	j=0
                                                	until [ "${result}" == 0 ]
                                                	do
                                                        	single_scan $host_ip $vm $vm_ip $username
                                                        	result=$?
                                                        	j=$(echo $(($j+1)))
                                                        	sleep 5
                                                        	if [ "$j" == 17 ];then
                                                                	return 5
                                                                	break
                                                        	fi
                                                	done
                                        	else
                                                	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=5 where username='${username}'"
							curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} 使用者開機異常" https://notify-api.line.me/api/notify > /dev/null
                                        	fi
					fi
				else
                                	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=5 where username='${username}'"
					curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} 使用者開機異常" https://notify-api.line.me/api/notify > /dev/null
				fi
				if [ "${i}" == ${#ava_host[@]} ];then
					return 5
					break
				fi
				i=$(($i+1))
			done
			if [ "${result}" == 0 ];then
				firewall ${user_IP} ${user_port} ${vm_ip}
                                createRDP ${username} ${user_IP} ${user_port} ${vm} ${vm_ip}
                                mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=1 where username='${username}'"
			else
				mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=6 where username='${username}'"
			fi
		else
			mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=6 where username='${username}'"
		fi
	fi
else
	auto_scan_host
	if [ "${ava_host[0]}" ];then
		i=0
		result='1'
		until [ "${result}" == 0 ]
		do
			if [ "${ava_host[$i]}" == '' ];then
				break
			fi
			pcmac=`mysql -u root -p2727175#356 -D GFDO -e "select mac from host where host_num='${ava_host[$i]}'" -B -N`
                    	host_ip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_num='${ava_host[$i]}'" -B -N`
                    	vm="PC${ava_host[$i]}-1"
			vm2="PC${ava_host[$i]}-2"
                    	vm_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${vm}'" -B -N`
                    	vm2_ip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${vm2}'" -B -N`
                    	mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm='${vm}'"
                    	ether-wake "$pcmac"
                    	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set vm='${vm}',vmip='${vm_ip}',status='2' where username='${username}'"
                    	sleep 50
                    	ssh -o ConnectTimeout=1 root@"${host_ip}" 'date' &> /dev/null;hostres=$?
			if [ "${hostres}" == 0 ];then
				openvm ${pcmac} ${vm} ${host_ip}
				res=$?
				mysql -u root -p2727175#356 -D DaaS -e "update userinfo set status='3' where username='${username}'"
				if [ "${res}" == 0 ];then
					j=0
					until [ "${result}" == 0 ]
					do
						single_scan $host_ip $vm $vm_ip $username
						result=$?
						j=$(echo $(($j+1)))
						sleep 5
						if [ "$j" == 17 ];then
							return 5
							break
						fi
					done
				else
					vm=${vm2}
                                    	vm_ip=${vm2_ip}
                                    	openvm ${pcmac} ${vm} ${host_ip}
                                    	res=$?
                                    	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set status='3' where username='${username}'"
                                    	if [ "${res}" == 0 ];then
                                            	j=0
                                            	until [ "${result}" == 0 ]
                                            	do
                                                    	single_scan $host_ip $vm $vm_ip $username
                                                    	result=$?
                                                    	j=$(echo $(($j+1)))
                                                    	sleep 5
                                                    	if [ "$j" == 17 ];then
                                                            	return 5
                                                            	break
                                                    	fi
                                            	done
                                    	else
                                            	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=5 where username='${username}'"
						curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} 使用者開機異常" https://notify-api.line.me/api/notify > /dev/null
                                    	fi
				fi
			else
                            	mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=5 where username='${username}'"
				curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} 使用者開機異常" https://notify-api.line.me/api/notify > /dev/null
			fi
			if [ "${i}" == ${#ava_host[@]} ];then
				return 5
				break
			fi
			i=$(($i+1))
		done
		if [ "${result}" == 0 ];then
			firewall ${user_IP} ${user_port} ${vm_ip}
                        createRDP ${username} ${user_IP} ${user_port} ${vm} ${vm_ip}
                        mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=1 where username='${username}'"
		else
			mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=6 where username='${username}'"
		fi
	else 
		mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=6 where username='${username}'"
	fi
fi
