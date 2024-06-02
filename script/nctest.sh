#!/bin/bash
IP=${1}
disk=${2}
res1=`cat <(echo "cmd.exe /c fsutil volume diskfree ${disk}") <(sleep 0.5) |nc -w 1 -n ${IP} 3501`
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
	res2=`cat <(echo "cmd.exe /c fsutil volume diskfree ${disk}") <(sleep 0.5) |nc -w 1 -n ${IP} 3502`
	if [ "$res2" ];then
		echo "$res2"
	else
		res3=`cat <(echo "cmd.exe /c fsutil volume diskfree ${disk}") <(sleep 0.5) |nc -w 1 -n ${IP} 3503`
		if [ "$res3" ];then
			echo "$res3"
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
