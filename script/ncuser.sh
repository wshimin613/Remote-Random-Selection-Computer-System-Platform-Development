#!/bin/bash
username=${2}
IP=${1}
res1_Ac=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Active\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3501 | grep rdp`
res1_Di=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Disc\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3501 | grep Disc | grep -v find`
if [ "$res1_Ac" ];then
	echo "$res1_Ac"
	# if [ "${IP}" == '192.168.31.5' ];then
	# 	res=''
	# 	echo $res
	# elif [ "${IP}" == '192.168.31.6' ];then
    #             res=''
    #             echo $res
	# else
	# 	echo "$res"
	# fi
elif [ "$res1_Di" ];then
	echo "$res1_Di"
else
	res2_Ac=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Active\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3502 | grep rdp`
	res2_Di=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Disc\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3502 | grep Disc | grep -v find`
	if [ "$res2_Ac" ];then
		echo "$res2_Ac"
	elif [ "$res2_Di" ];then
		echo "$res2_Di"
	else
		res3_Ac=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Active\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3503 | grep rdp`
		res3_Di=`cat <(echo "cmd.exe /c C:\users\public\query.exe user ${username} | find \"Disc\"") <(sleep 0.5) |nc -w 1 -n ${IP} 3503 | grep Disc | grep -v find`
		if [ "$res3_Ac" ];then
			echo "$res3_Ac"
		elif [ "$res3_Di" ];then
			echo "$res3_Di"
		fi
	fi
fi

# 以下是取得的資料
#Active
#./ncuser.sh ${IP} | awk '{print $1}' => username 使用者名稱
#./ncuser.sh ${IP} | awk '{print $2}' => session  使用者登入的機制
#./ncuser.sh ${IP} | awk '{print $3}' => userID   使用者ID (登出時需要)
#./ncuser.sh ${IP} | awk '{print $4}' => status   使用者狀態 (Active)
#./ncuser.sh ${IP} | awk '{print $5}' => idle     使用者閒置時間 (. / time)
