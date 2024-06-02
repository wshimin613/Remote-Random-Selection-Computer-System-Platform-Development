#!/bin/bash
#exec: ./logoff.sh 192.168.32.36 2

IP=${1}
userID=${2}
res=`cat <(echo "cmd.exe /c C:\users\public\logoff.exe ${userID}") <(sleep 0.5) |nc -w 1 -n ${IP} 3501`
#res=`cat <(echo "cmd.exe /c C:\users\public\logoff.exe") <(sleep 0.5) |nc -w 1 -n ${IP} 3501`
if [ "$res" ];then
	echo "$res"
	# if [ "${IP}" == '192.168.31.5' ];then
	# 	res=''
	# 	echo $res
	# elif [ "${IP}" == '192.168.31.6' ];then
    #             res=''
    #             echo $res
	# else
	# 	echo "$res"
	# fi
fi
