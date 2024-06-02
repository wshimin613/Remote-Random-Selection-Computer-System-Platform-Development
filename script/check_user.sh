#!/bin/bash

cd /root/script/min

vmip=${1}

username=`./ncuser.sh ${vmip} | awk '{print $1}'`
userID=`./ncuser.sh ${vmip} | awk '{print $3}'`
idle=`./ncuser.sh ${vmip} | awk '{print $5}'`

echo "$username,$userID,$idle"
