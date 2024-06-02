#!/bin/bash
username=${2}
IP=${1}
i=0
result=0
until [ "${result}" -eq "1" ]
do
	if [ "${i}" -ge "20" ];then
		mysql -u root -p2727175#356 -D DaaS -e "update userinfo set login='1' where username='${username}'"
		result=1
		break
	fi
	res1=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Active\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3501 | grep rdp`
	if [ "$res1" ];then
		echo "$res1"
		mysql -u root -p2727175#356 -D DaaS -e "update userinfo set login='1' where username='${username}'"
		result=1
	else
		res2=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Active\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3502 | grep rdp`
		if [ "$res2" ];then
			echo "$res2"
			mysql -u root -p2727175#356 -D DaaS -e "update userinfo set login='1' where username='${username}'"
			result=1
		else
			res3=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Active\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3503 | grep rdp`
			if [ "$res3" ];then
				echo "$res3"
				mysql -u root -p2727175#356 -D DaaS -e "update userinfo set login='1' where username='${username}'"
				result=1
			fi
		fi
	fi
	sleep 3
	i=$(( $i+1 ))
done
