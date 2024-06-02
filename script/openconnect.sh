#!/bin/bash

username=${1}
user_IP=${2}
user_port=${3}
vm=${4}
vm_ip=${5}

. /root/script/min/function.sh --source-only

firewall ${user_IP} ${user_port} ${vm_ip}
createRDP ${username} ${user_IP} ${user_port} ${vm} ${vm_ip}
mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=1 where username='${username}'"

#check_used=`mysql -u root -p2727175#356 -D DaaS -e "select username from userinfo where username='${username}'" -B -N`
#if [ $check_used ];then
#    mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${vm}',vmip='${vm_ip}',status=1 where username='${username}'"
#    mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm_ip='${vm_ip}'"
#else
#    mysql -u root -p2727175#356 -D DaaS -e "insert into userinfo (username,IP,port,vm,vmip,status) values('${username}','${user_IP}',${user_port},'${vm}','${vm_ip}',1);"
#    mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm_ip='${vm_ip}'"
#fi
