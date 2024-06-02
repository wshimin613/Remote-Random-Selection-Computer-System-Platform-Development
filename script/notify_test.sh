#!/bin/bash

vm=()

for num in 1 1 2 3 4 1 2
do
	[[ " ${vm[@]} " =~ " ${num} " ]] && echo "It is in array" || vm+=(${num})
done
rm -f /root/script/min/vm_notify.sh
for i in ${vm[@]}
do
	echo -e $i >> vm_notify.sh
done

#curl -s -X POST -H 'Authorization: Bearer qo2uwdwErAwuyd7yhhSLZ8FENrIU9JvLKnXgdjw7nKt' -F 'message=腳本發送訊息測試' https://notify-api.line.me/api/notify
