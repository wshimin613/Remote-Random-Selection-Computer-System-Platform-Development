#!/bin/bash

disk_num=$( lsblk | grep disk | awk '{print $1}' | wc -l )
hostname=$( hostname 2> /dev/null )
j=0

printf " {\n  \"hostname\": \"${hostname}\",\n" > /root/monitor/hardware.json
for i in $( seq 1 ${disk_num} )
do
	disk=$( lsblk | grep disk | awk '{print $1}' | sed -n "${i}p" )
	disk_type=$( smartctl -a /dev/${disk} | grep 'Rotation Rate' | awk '{print $3}' 2> /dev/null )
	disk_total=$( fdisk -l | grep "Disk /dev/${disk}" | awk '{print $3}' 2> /dev/null )
	disk_usage=$( df -h --total /dev/${disk}* | grep 'total' | awk '{print $3}' | sed 's/G//g' 2> /dev/null )
	disk_health=$( smartctl -a /dev/${disk} | grep Power_On_Hours | awk '{print $10}' 2> /dev/null )
	if [ "${disk_type}" == 'Solid' ];then
		j=$(( ${j}+1 ))
		if [ "${j}" -gt 1 ];then
			ssd_warning=`echo "100*${disk_usage}/${disk_total}" | bc`

			if [ `expr ${ssd_warning} \< 85` -eq 0 ];then
				curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${hostname} SSD${j}容量即將不足" https://notify-api.line.me/api/notify > /dev/null
			fi

			printf "  \"ssd${j}_total\": \"${disk_total}\",\n" >> /root/monitor/hardware.json
			printf "  \"ssd${j}_usage\": \"${disk_usage}\",\n" >> /root/monitor/hardware.json
			printf "  \"ssd${j}_health\": \"${disk_health}\",\n" >> /root/monitor/hardware.json
		else
			ssd_warning=`echo "100*${disk_usage}/${disk_total}" | bc`

			if [ `expr ${ssd_warning} \< 85` -eq 0 ];then
                                curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${hostname} SSD${j}容量即將不足" https://notify-api.line.me/api/notify > /dev/null
                        fi

			printf "  \"ssd_total\": \"${disk_total}\",\n" >> /root/monitor/hardware.json
			printf "  \"ssd_usage\": \"${disk_usage}\",\n" >> /root/monitor/hardware.json
			printf "  \"ssd_health\": \"${disk_health}\",\n" >> /root/monitor/hardware.json
		fi
	else 
		hdd_warning=`echo "100*${disk_usage}/${disk_total}" | bc`

		if [ `expr ${hdd_warning} \< 85` -eq 0 ];then
			curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3501 ${hostname} HDD容量即將不足" https://notify-api.line.me/api/notify > /dev/null
		fi
		hdd_total=${disk_total}
		hdd_usage=${disk_usage}
		hdd_health=${disk_health}
	fi
done
	printf "  \"hdd_total\": \"${hdd_total}\",\n" >> /root/monitor/hardware.json
	printf "  \"hdd_usage\": \"${hdd_usage}\",\n" >> /root/monitor/hardware.json
	printf "  \"hdd_health\": \"${hdd_health}\"\n" >> /root/monitor/hardware.json
printf " },\n" >> /root/monitor/hardware.json


#	disk_ssd_warning=`echo "100*${disk_usage_a}/${disk_total_a}" | bc`
#	disk_hdd_warning=`echo "100*${disk_usage_b}/${disk_total_b}" | bc`
#	if [ `expr ${disk_ssd_warning} \< 85` -eq 0 ];then
#        	curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3502 ${hostname} SSD容量即將不足" https://notify-api.line.me/api/notify > /dev/null
#	fi
#	if [ `expr ${disk_hdd_warning} \< 85` -eq 0 ];then
#	        curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F "message=I3502 ${hostname} HDD容量即將不足" https://notify-api.line.me/api/notify > /dev/null
#	fi
