#!/bin/bash

cd /root/script/min/
echo "[" > /var/www/html/DaaS/vm_hardware.json
for IP in $( seq 1 42 )
do
	vm_IP="192.168.31.${IP}"
	vm=`mysql -u root -p2727175#356 -D DaaS -e "select vm from vm where vm_ip='${vm_IP}'" -B -N`
	host_IP=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_vm1='${vm}' or host_vm2='${vm}'" -B -N`
	ssh -o ConnectTimeout=1 root@$host_IP "virsh list | grep ${vm}" &> /dev/null; result=$?
	if [ "$result" == 0 ];then
		nc_check=`./nc_all.sh ${vm_IP} 2> /dev/null`
		if [ "${nc_check}" ];then
			disk_C_total=`./nctest.sh ${vm_IP} C: 2> /dev/null | grep -a "GB" | sed -n "2,2p" | cut -d '(' -f 2 | awk '{print $1}'`
        		disk_C_free=`./nctest.sh ${vm_IP} C: 2> /dev/null | grep -a "GB" | sed -n "1,1p" | cut -d '(' -f 2 | awk '{print $1}'`
        		disk_D_total=`./nctest.sh ${vm_IP} D: 2> /dev/null | grep -a "GB" | sed -n "2,2p" | cut -d '(' -f 2 | awk '{print $1}'`
        		disk_D_free=`./nctest.sh ${vm_IP} D: 2> /dev/null | grep -a "GB" | sed -n "1,1p" | cut -d '(' -f 2 | awk '{print $1}'`
        		disk_L_total=`./nctest.sh ${vm_IP} L: 2> /dev/null | grep -a "GB" | sed -n "2,2p" | cut -d '(' -f 2 | awk '{print $1}'`
        		disk_L_free=`./nctest.sh ${vm_IP} L: 2> /dev/null | grep -a "GB" | sed -n "1,1p" | cut -d '(' -f 2 | awk '{print $1}'`
			disk_C_usage=`echo "${disk_C_total}-${disk_C_free}" | bc`
                        disk_D_usage=`echo "${disk_D_total}-${disk_D_free}" | bc`
                        disk_L_usage=`echo "${disk_L_total}-${disk_L_free}" | bc`

			disk_C_warning=`echo "100*${disk_C_usage}/${disk_C_total}" | bc`
                        disk_D_warning=`echo "100*${disk_D_usage}/${disk_D_total}" | bc`
                        disk_L_warning=`echo "100*${disk_L_usage}/${disk_L_total}" | bc`

			if [ `expr ${disk_C_warning} \< 85` -eq 0 ];then
                                curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} C槽容量即將不足" https://notify-api.line.me/api/notify > /dev/null
                        fi

                        if [ `expr ${disk_D_warning} \< 85` -eq 0 ];then
                                curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} D槽容量即將不足" https://notify-api.line.me/api/notify > /dev/null
                        fi

                        if [ `expr ${disk_L_warning} \< 85` -eq 0 ];then
                                curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} L槽容量即將不足" https://notify-api.line.me/api/notify > /dev/null
                        fi

			echo " {" >> /var/www/html/DaaS/vm_hardware.json
			echo "  \"vm_name\": \"${vm}\"," >> /var/www/html/DaaS/vm_hardware.json
			echo "  \"disk_C_total\": \"${disk_C_total}\"," >> /var/www/html/DaaS/vm_hardware.json
        		echo "  \"disk_C_free\": \"${disk_C_free}\"," >> /var/www/html/DaaS/vm_hardware.json
        		echo "  \"disk_D_total\": \"${disk_D_total}\"," >> /var/www/html/DaaS/vm_hardware.json
        		echo "  \"disk_D_free\": \"${disk_D_free}\"," >> /var/www/html/DaaS/vm_hardware.json
        		echo "  \"disk_L_total\": \"${disk_L_total}\"," >> /var/www/html/DaaS/vm_hardware.json
        		echo "  \"disk_L_free\": \"${disk_L_free}\"" >> /var/www/html/DaaS/vm_hardware.json
			if [ $IP -eq 42 ];then
				echo " }" >> /var/www/html/DaaS/vm_hardware.json
			else
				echo " }," >> /var/www/html/DaaS/vm_hardware.json
			fi
		else
			echo " {" >> /var/www/html/DaaS/vm_hardware.json
			echo "  \"vm_status\": \"${vm} nc disconnected\"" >> /var/www/html/DaaS/vm_hardware.json
			curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${vm} NC 服務異常" https://notify-api.line.me/api/notify > /dev/null
			if [ $IP -eq 42 ];then
				echo " }" >> /var/www/html/DaaS/vm_hardware.json
			else
				echo " }," >> /var/www/html/DaaS/vm_hardware.json
			fi
		fi
	else
		echo " {" >> /var/www/html/DaaS/vm_hardware.json
		echo "  \"vm_status\": \"${vm} is poweroff\"" >> /var/www/html/DaaS/vm_hardware.json
		if [ $IP -eq 42 ];then
			echo " }" >> /var/www/html/DaaS/vm_hardware.json
		else
			echo " }," >> /var/www/html/DaaS/vm_hardware.json
		fi
	fi
done
echo "]" >> /var/www/html/DaaS/vm_hardware.json
