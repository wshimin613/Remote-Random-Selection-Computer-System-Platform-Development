#!/bin/bash
# sh raspberry.sh 4070C004 120.114.140.34 29997 PC4-1 192.168.31.7

username=${1}
user_IP=${2}
user_port=${3}
vm=${4}
vm_ip=${5}

servermac='eno1'
serverip=`ifconfig "${servermac}" | grep 'inet ' | awk '{print $2}'`

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
arm-linux-gcc -o /var/www/html/DaaS/rdppkg/${username} /var/www/html/DaaS/rdppkg/${username}_ras.c
