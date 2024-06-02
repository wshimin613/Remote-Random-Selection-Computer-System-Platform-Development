#! /bin/bash
# for RDPclass function of use 
# kai. 2021.06

# auto scan all PC nc status
auto_scan_nc(){
	available=()
	cd /root/script/min/
	for IP in $( seq 1 42 )
	do
		vm_IP="192.168.31.${IP}"
		# check vm status
		vm_status=`./nc.sh ${vm_IP} 2> /dev/null`
		if [ "$vm_status" ];then
			vm_id=`mysql -u root -p2727175#356 -D DaaS -e "select vm from vm where vm_ip='${vm_IP}'" -B -N`
			available+=("${vm_id}")
		fi
	done
}

# auto scan all HOST status
auto_scan_host(){
	ava_host=()
	for IP in $( seq 51 71 )
	do
		host_IP="192.168.31.${IP}"
		# check host status
		ssh -o ConnectTimeout=1 root@$host_IP 'date' &> /dev/null; result=$? 
		if [ "$result" != 0 ];then
			host_num=`mysql -u root -p2727175#356 -D GFDO -e "select host_num from host where host_ip='${host_IP}'" -B -N`
			ava_host+=("${host_num}")
		fi
	done
}

# auto scan all vm status
auto_scan_vm(){
	ava_vm=()
	for IP in $( seq 1 21 )
	do
		host_IP="192.168.31.$((50+${IP}))"
		ssh -o ConnectTimeout=1 root@$host_IP 'date' &> /dev/null; result=$? 
		if [ "${result}" != 0 ];then
			continue
		fi
		for id in $( seq 1 2)
		do
			vmid=PC${IP}-${id}
			ssh -o ConnectTimeout=1 root@${host_IP} virsh list |grep ${vmid} &> /dev/null; vm_status=$? 
			# check vm status			
			if [ $vm_status != 0 ];then
				ava_vm+=("${vmid}")
			fi
		done
	done
}

use_scan_vm(){
        ava_vm=()
        vm_num=`mysql -u root -p2727175#356 -D DaaS -e "select vm_ip from vm where vm_status=0" -B -N | wc -l`
        for i in $( seq 1 $vm_num )
        do
                vm=`mysql -u root -p2727175#356 -D DaaS -e "select vm from vm where vm_status=0" -B -N | sed -n "${i},${i}p"`
                host=`mysql -u root -p2727175#356 -D DaaS -e "select vm from vm where vm_status=0" -B -N | sed -n "${i},${i}p" | cut -d '-' -f 1 | cut -c 3-`
                host_ip="192.168.31.$((50+${host}))"

                # 確認 host 狀態是否開機
                ssh -o ConnectTimeout=1 root@${host_ip} 'date' &> /dev/null; result=$?
                if [ "${result}" != 0 ];then
                        continue
                fi

                # host有開，確認 vm 狀態是否開機
                ssh -o ConnectTimeout=1 root@${host_ip} virsh list | grep ${vm} &> /dev/null; vm_status=$?
                if [ ${vm_status} != 0 ];then
                        ava_vm+=("${vm}")
                fi
        done
}

# scan one PC status 
single_scan(){
	host_ip=${1}
	vm=${2}
	vm_ip=${3}
	username=${4}

	ssh -o ConnectTimeout=1 root@${host_ip} date &> /dev/null; host_status=$?
	ssh -o ConnectTimeout=1 root@${host_ip} virsh list |grep ${vm} &> /dev/null; vm_status=$?
	cd /root/script/min/
	vm_user_list=`./nc.sh ${vm_ip} 2> /dev/null`
	user_used=`mysql -u root -p2727175#356 -D DaaS -e "select * from userinfo where vm='${vm}' and username!='${username}' and (status=1 or status=2 or status=3)"`
	if [ $host_status == 0 ];then
		if [ $vm_status == 0 ];then
			mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_status='1' where vm='${vm}'"
			if [ "${vm_user_list}" ]&&[ -z "${user_used}" ];then
				return 0
			else
				return 3
			fi
		else 
			# openvm
			return 2
		fi
	else
		# openhost
		# openvm
		return 1
	fi
}

#目前沒用到
openhost(){
	pcmac=${1}
	vmid=${2}
	host_ip=${3}

	ether-wake "$pcmac"
	i=0
	result='1'
	until [ "$result" == 0 ]
	do
		ssh -o ConnectTimeout=1 root@"${host_ip}" 'date' &> /dev/null;result=$?
		i=$(echo $(($i+1)))
		sleep 5
		if [ "$i" == 20 ];then
			mysql -u root -p2727175#356 -D GFDO -e "update vm set vm_status=0 where vm='${vmid}'" -B -N
			mysql -u root -p2727175#356 -D GFDO -e "update host set host_status=0,vm_1_status=0 where mac='${pcmac}'" -B -N
			break
		fi
		if [ "$i" == 10 ];then
			ether-wake "$pcmac"
		fi
		mysql -u root -p2727175#356 -D GFDO -e "update host set host_status=1 where mac='${pcmac}'" -B -N
	done
}

##OK，沒開起來就爆了
openvm(){
	pcmac=${1}
	vmid=${2}
	host_ip=${3}
	date=$( date +"%Y/%m/%d %T" )
	if [ $hostres == 0 ];then
		mysql -u root -p2727175#356 -D GFDO -e "update host set host_status=1 where mac='${pcmac}'" -B -N
		ssh -o ConnectTimeout=5 root@$host_ip virsh nodedev-detach pci_0000_00_1c_2 &> /dev/null
		ssh -o ConnectTimeout=5 root@$host_ip virsh nodedev-detach pci_0000_00_1c_4 &> /dev/null
		ssh -o ConnectTimeout=1 root@$host_ip "virsh create /vm_data/xml/${vmid}.xml" &> /dev/null; res=$?
		if [ $res == 0 ];then
			mysql -u root -p2727175#356 -D GFDO -e "update vm set user='guest',vm_status=2,time='${date}' where vm='${vmid}'" -B -N
			mysql -u root -p2727175#356 -D GFDO -e "update host set vm_1_status=2 where mac='${pcmac}'" -B -N
			return 0
			break
		else
			return 5
		fi
	fi
}

##OK
createRDP(){
username=${1}
user_IP=${2}
user_port=${3}
vm=${4}
vm_ip=${5}

servermac='eno1'
#servermac='enp1s0f1'
serverip=`ifconfig "${servermac}" |grep 'inet ' |awk '{print $2}'`
### windows 版本 C 語言
cat << EOF > /var/www/html/DaaS/rdppkg/${username}_win.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int c, char *argv[]) {
	char var[10];
	char value[] = "0";
	char cmd[500] = "start /min cmd.exe /c \"ping 1.1.1.1 -n 1 & del ";
	strcat(cmd,argv[0]);
	strcat(cmd,"\"" );

	FILE *fp = popen("C:\\\\Windows\\\\System32\\\\curl.exe -s http://${serverip}/DaaS/php/get_userconflict.php?seat=${vm}^&seatIP=${vm_ip}^&username=${username}", "r");
	while (fgets(var, 10, fp) != NULL)
	{
		printf("%s\n", "connecting．．．");
	}
	pclose(fp);

	if( value[0] == var[0] ){
		system("start mstsc /admin /v:${serverip}:${user_port}");
	}else{
		printf("%s\n", "Sorry,This PC is currently being used");
		system("pause");
	}
	
	FILE *fw = popen("C:\\\\Windows\\\\System32\\\\curl.exe -s http://${serverip}/DaaS/php/del_firewall.php?userIP=${user_IP}^&userport=${user_port}^&vmip=${vm_ip}^&username=${username}", "r");
	pclose(fw);
	system(cmd);
	return 0;
}
EOF
x86_64-w64-mingw32-gcc -o /var/www/html/DaaS/rdppkg/${username}.exe /var/www/html/DaaS/rdppkg/${username}_win.c
### raspberry pi 版本 C 語言
cat << EOF > /var/www/html/DaaS/rdppkg/${username}_ras.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int c, char *argv[]) {
        char var[10];
        char value[] = "0";
        char cmd[500] = "lxterminal -e bash -c \"ping 1.1.1.1 -n 1 & del ";
        strcat(cmd,argv[0]);
        strcat(cmd,"\"");

        FILE *fp = popen("curl -s \"http://${serverip}/DaaS/php/get_userconflict.php?seat=${vm}&seatIP=${vm_ip}&username=${username}\"", "r");
        while (fgets(var, 10, fp) != NULL)
        {
                //printf("%s\n", "connecting...");
                system("lxterminal -e bash -c \"echo connecting...\"");
        }
        pclose(fp);

        if( value[0] == var[0] ){
                system("remmina -c rdp://${serverip}:${user_port}");
        }else{
                //printf("%s\n", "Sorry,This PC is currently being used");
                system("lxterminal -e bash -c \"echo 'Sorry,This PC is currently being used'\"");
                fgetc(stdin);
        }

        FILE *fw = popen("curl -s \"http://${serverip}/DaaS/php/del_firewall.php?userIP=${user_IP}&userport=${user_port}&vmip=${vm_ip}&username=${username}\"", "r");
        pclose(fw);
        system(cmd);

        return 0;
}
EOF
/usr/local/arm/4.4.3/bin/arm-linux-gcc -o /var/www/html/DaaS/rdppkg/${username} /var/www/html/DaaS/rdppkg/${username}_ras.c
}

##OK
firewall(){
	user_IP=${1}
	user_port=${2}
	vm_ip=${3}
	out='eno1'
	#out='enp1s0f1'
	iptables -t nat -A PREROUTING -i ${out} -s ${user_IP} -p tcp -m tcp --dport ${user_port} -j DNAT --to-destination ${vm_ip}:3389
}

##OK
del_firewall(){
	user_IP=${1}
	user_port=${2}
	vmip=${3}

	out='eno1'
	#out='enp1s0f1'
	sleep 30
	iptables -t nat -D PREROUTING -i ${out} -s ${user_IP} -p tcp -m tcp --dport ${user_port} -j DNAT --to-destination ${vmip}:3389
}

del_userinfo(){
	Username=${1}
	mysql -u root -p2727175#356 -D RDPclass -e "delete from userinfo where username=${Username}"
}

check_repeat(){
	seat=${@}
	for i in $seat
	do
		status=`mysql -u root -p2727175#356 -D DaaS -e "select status from userinfo where vm='${i}'" -B -N`;
		if [ "${status}" != 1 ];then
			available=$i;
			break
		fi
	done
}

