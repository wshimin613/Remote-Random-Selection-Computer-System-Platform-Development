#!/bin/bash
username=${2}
IP=${1}

i=1
result=0
until [ "${result}" -eq "1" ]
do
	if [ "${i}" -ge "20" ];then
		result=1
	fi
	res1=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Active\"") <(sleep 0.5) |nc -w 0.5 -n ${IP} 3501 | grep rdp`
	if [ "$res1" ];then
		result=1
	fi
	echo $i
	i=$(( $i+1 ))
	sleep 1
done
