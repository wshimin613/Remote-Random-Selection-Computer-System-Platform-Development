#!/bin/bash

printf "[\n" > /var/www/html/DaaS/hardware.json
for i in $( seq 1 21 )
do
        ip=192.168.31.$(( i+50 ))
        date=$( ssh -f -o ConnectTimeout=1 root@${ip} "date" 2> /dev/null  ); result=$?
        if [ ${result} != 0 ];then
                printf " {\n" >> /var/www/html/DaaS/hardware.json
                printf "  \"host_status\": \"HOST_${i} is poweroff\"\n" >> /var/www/html/DaaS/hardware.json
                if [ ${i} != '21' ];then
                        printf " },\n" >> /var/www/html/DaaS/hardware.json
                else
                        printf " }\n" >> /var/www/html/DaaS/hardware.json
                fi
        elif [ ${result} == 0 ];then
                show=$( ssh -f -o ConnectTimeout=1 root@${ip} "cat /root/monitor/hardware.json" 2> /dev/null )
                printf "${show}\n" >> /var/www/html/DaaS/hardware.json
        fi
done
printf "]\n" >> /var/www/html/DaaS/hardware.json
