#!/bin/bash
# kai. 2021.06
# exec :sh auto_scan_nc.sh

. /root/script/min/function.sh --source-only

auto_scan_host
echo ${ava_host[@]}
