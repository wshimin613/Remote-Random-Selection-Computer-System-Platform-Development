#!/bin/bash
username=${2}
IP=${1}
res1=`cat <(echo "cmd.exe /c C:\users\public\query.exe user") <(sleep 0.5) |nc -w 1 -n ${IP} 3501`
if [ "$res1" ];then
	echo "$res1"
	# if [ "${IP}" == '192.168.31.5' ];then
	# 	res=''
	# 	echo $res
	# elif [ "${IP}" == '192.168.31.6' ];then
    #             res=''
    #             echo $res
	# else
	# 	echo "$res"
	# fi
else
	res2=`cat <(echo "cmd.exe /c C:\users\public\query.exe user") <(sleep 0.5) |nc -w 1 -n ${IP} 3502`
	if [ "$res2" ];then
		echo "$res2"
	else
		res3=`cat <(echo "cmd.exe /c C:\users\public\query.exe user") <(sleep 0.5) |nc -w 1 -n ${IP} 3503`
		if [ "$res3" ];then
			echo "$res3"
		fi
	fi
fi
