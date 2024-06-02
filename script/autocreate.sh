#!/bin/bash
# This script is for no used user
# exec: sh autocreate.sh kai 200.200.200.2 20001

username=${1}
user_IP=${2}
user_port=${3}

. /root/script/min/function.sh --source-only

# 判斷有沒有使用過 | insert 跟 update
check_used=`mysql -u root -p2727175#356 -D DaaS -e "select username from userinfo where username='${username}'" -B -N`
if [ $check_used ];then
    #no vm and vmip
    mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=4 where username='${username}'"
else
    mysql -u root -p2727175#356 -D DaaS -e "insert into userinfo (username,IP,port,vm,vmip,status) values('${username}','${user_IP}',${user_port},'${seat}','${vmip}',1);"
fi

auto_scan_nc
check_repeat ${available[@]}
seat=${available}
if [ "${seat}" ];then
    # echo "############## auto_scan_nc ##############"
    #vmip=`mysql -u root -p2727175#356 -D GFDO -e "select vm_ip from vm where vm='${seat}'" -B -N`
    # add vm list to control the machine's usestaus
    mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm='${seat}'"
    vmip=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm='${seat}'" -B -N`
    firewall ${user_IP} ${user_port} ${vmip}
    createRDP ${username} ${user_IP} ${user_port} ${seat} ${vmip}

    #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=1 where username='${username}'"
    mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=1 where username='${username}'"

elif [ -z "${seat}" ];then
    # 若沒有電腦使用，則重新判斷每台電腦是否開機，若有未開機狀態的電腦，則將電腦開機
    # will return ava_host array
    # echo "auto_scan_host"
    auto_scan_host
    if [ "${ava_host[0]}" ];then
        echo "will open ${ava_host[0]}"
        pcmac=`mysql -u root -p2727175#356 -D GFDO -e "select mac from host where host_num='${ava_host[0]}'" -B -N`
        hostip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_num='${ava_host[0]}'" -B -N`
        seat="PC${ava_host[0]}-1"

	# add vm list to control the machine's usestaus
	mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm='${seat}'"
        vmip=`mysql -u root -p2727175#356 -D GFDO -e "select vm_ip from vm where vm='${seat}'" -B -N`

        #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=2 where username='${username}'"
        mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=2 where username='${username}'"
        ether-wake "$pcmac"
        openhost ${pcmac} ${seat} ${hostip}

        #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=3 where username='${username}'"
        mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=3 where username='${username}'"
        openvm ${pcmac} ${seat} ${hostip}
        res=$?
        if [ "${res}" == 0 ];then
            firewall ${user_IP} ${user_port} ${vmip}
            # echo 'firewall'
    	    createRDP ${username} ${user_IP} ${user_port} ${seat} ${vmip}
            # echo "createRDP"
	        #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=1 where username='${username}'"
	        mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=1 where username='${username}'"
        else
            # echo 'vm open faild'
            #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=5 where username='${username}'"
            mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=5 where username='${username}'"
        fi
    else
        auto_scan_vm
        echo "will check vm state : ${ava_vm[0]}"
        if [ ${ava_vm[0]} ];then
            seat="${ava_vm[0]}"
            pcmac=`mysql -u root -p2727175#356 -D GFDO -e "select mac from host where host_vm1='${seat}' || host_vm2='${seat}'" -B -N`
            hostip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_vm1='${seat}' || host_vm2='${seat}'" -B -N`
            vmip=`mysql -u root -p2727175#356 -D GFDO -e "select vm_ip from vm where vm='${seat}'" -B -N`

            #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=3 where username='${username}'"
            mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=3 where username='${username}'"
            openvm ${pcmac} ${seat} ${hostip}

            i=0
	        result='1'
            until [ "$result" == 0 ]
            do
                single_scan $hostip $seat $vmip
                result=$?
                i=$(echo $(($i+1)))
                sleep 5
                if [ "$i" == 20 ];then
                    return 5
                    break
                fi
            done
            if [ "${result}" == 0 ];then
                firewall ${user_IP} ${user_port} ${vmip}
                # echo 'firewall'
                createRDP ${username} ${user_IP} ${user_port} ${seat} ${vmip}
                # echo "createRDP"
                #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=1 where username='${username}'"
                mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=1 where username='${username}'"
            else
                # echo 'vm open faild'
                #mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=5 where username='${username}'"
                mysql -u root -p2727175#356 -D DaaS -e "update userinfo set IP='${user_IP}',port='${user_port}',vm='${seat}',vmip='${vmip}',status=5 where username='${username}'"
            fi

            # mysql -u root -p2727175#356 -D RDPclass -e "update userinfo set IP='${user_IP}',port='${user_port}',seat='${seat}',seatIP='${vmip}',usestatus=1 where username='${username}'"
            # firewall ${user_IP} ${user_port} ${vmip}
	        # createRDP ${username} ${user_IP} ${user_port}
        fi
    fi
fi
