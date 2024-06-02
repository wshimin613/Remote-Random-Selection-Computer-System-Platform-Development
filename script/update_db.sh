#!/bin/bash

for i in $(seq 1 42)
do
	mysql -u root -p2727175#356 -D DaaS -e "update vm set vm_ip='192.168.31.${i}' where vmid='${i}';"
done
