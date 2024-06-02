#!/bin/bash
# auto create PC for prevention
# exec: sh openconnect.sh kai 120.114.140.28 20001 PC1-2 192.168.31.2

Username=${1}
user_IP=${2}
user_port=${3}
seat=${4}
vmip=${5}
# hostip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_vm1='${seat}' || host_vm2='${seat}'" -B -N`

. /root/script/RDPclass/function.sh --source-only

# single_scan $hostip	$seat $vmip
# res=$?
mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=2 where username='${Username}'"
openhost ${pcmac} ${seat} ${hostip}
mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=3 where username='${Username}'"
openvm ${pcmac} ${seat} ${hostip}

# firewall ${user_IP} ${user_port} ${vmip}
# createRDP ${Username} ${user_IP} ${user_port}

res=$?
if [ "${res}" == 0 ];then
    firewall ${user_IP} ${user_port} ${vmip}
    # echo 'firewall'
    createRDP ${Username} ${user_IP} ${user_port}
    # echo "createRDP"
    mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=1 where username='${Username}'"
else
    # echo 'vm open faild'
    mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=5 where username='${Username}'"
fi

# check_used=`mysql -u root -p2727175#356 -D RDPclass -e "select username from userinfo where username='${Username}'" -B -N`
# if [ $check_used ];then
#     mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=1 where username='${Username}'"
# else
#     mysql -u root -p2727175#356 -D RDPclass -e "insert into userinfo (username,IP,port,seat,seatIP,usestatus) values('${Username}','${user_IP}',${user_port},'${seat}','${vmip}',1);"
# fi