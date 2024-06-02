#!/bin/bash
# kai. 202106. auto create PC for prevention
# exec: sh del_firewall.sh 120.114.140.28 20001 192.168.31.2

user_IP=${1}
user_port=${2}
vm_ip=${3}

. /root/script/min/function.sh --source-only

del_firewall ${user_IP} ${user_port} ${vm_ip}
