#!/bin/bash

result=1
i=0

until [ "${result}" -eq 0 ]
do
	echo ${i}
	if [ "${i}" -ge 3 ];then
		echo "over"
		break
	fi
	sleep 5
	i=$(( $i+1 ))
done
