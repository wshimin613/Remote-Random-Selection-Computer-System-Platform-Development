#!/bin/bash
#exec: sh user_time.sh 192.168.32.36 4070C004

IP=${1}
username=${2}

cd /root/script/min

userstatus1=`./ncuser.sh ${IP} ${username} | grep Active`
status1=$?

userstatus2=`./ncuser.sh ${IP} ${username} | grep Disc`
status2=$?

if [ "${status1}" == "0" ];then
	time1=`./ncuser.sh ${IP} ${username} | grep Active | awk '{print $5}' | grep ':'`
	time_status1=$?
	if [ "${time_status1}" == "0" ];then
		hour=`./ncuser.sh ${IP} ${username} | awk '{print $5}' | cut -d ':' -f 1`
        	minutes=`./ncuser.sh ${IP} ${username} | awk '{print $5}' | cut -d ':' -f 2`
		total=$(( ${hour} * 60 + ${minutes} ))
	else
		total=`./ncuser.sh ${IP} ${username} | awk '{print $5}'`
	fi
elif [ "${status2}" == "0" ];then
	time2=`./ncuser.sh ${IP} ${username} | grep Disc | awk '{print $4}' | grep ':'`
	time_status2=$?
	if [ "${time_status2}" == "0" ];then
		hour=`./ncuser.sh ${IP} ${username} | awk '{print $4}' | cut -d ':' -f 1`
	        minutes=`./ncuser.sh ${IP} ${username} | awk '{print $4}' | cut -d ':' -f 2`
	        total=$(( ${hour} * 60 + ${minutes} ))
	else
		total=`./ncuser.sh ${IP} ${username} | awk '{print $4}'`
	fi
fi
echo "${total}"
