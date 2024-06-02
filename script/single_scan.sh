#! /bin/bash
# check one status
# exec: sh single_scan.sh PC1-2 192.168.31.2
vm=${1}
vm_ip=${2}
username=${3}
host_ip=`mysql -u root -p2727175#356 -D GFDO -e "select host_ip from host where host_vm1='${vm}' || host_vm2='${vm}'" -B -N`

. /root/script/min/function.sh --source-only
single_scan $host_ip $vm $vm_ip $username

echo $?
