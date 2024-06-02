#!/bin/bash

auto_scan_vm() {
  available=()
  cd /root/script/RDPclass/
  #PCnum=`mysql -u root -p2727175#356 -D GFDO -e "select vm_num from vm where usestatus=0" -B -N`
  for IP in $( seq 1 42 )
  do
           #vm_IP="192.168.31.${IP}"
           vm_IP="192.168.32.${IP}"
           # if [ "$IP" == 5 ];then
           #       continue
           # fi
           # check vm status
          vm_status=`./nc.sh ${vm_IP} 2> /dev/null`
          if [ "$vm_status" ];then
                  #vm_id=`mysql -u root -p2727175#356 -D GFDO -e "select vm from vm where vm_ip='${vm_IP}'" -B -N`
                  vm_id=`mysql -u root -p2727175#356 -D DaaS -e "select vm from vm where vm_ip='${vm_IP}'" -B -N`
                  available+=("${vm_id}")
          fi
  done
#  for i in $( seq 0 20 )
#  do
#  	echo ${available[$i]}
#  done
}
