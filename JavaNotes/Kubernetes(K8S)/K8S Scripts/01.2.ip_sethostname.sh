#!/bin/bash

#LC_ALL=C ifconfig | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
ip=`ip a show dev eth0|grep -w inet|awk '{print $2}'|awk -F '/' '{print $1}'`

#根据固定字符串拼接ip最后一位来设置节点主机名
ip_end=${ip##*.}
echo $ip_end
host_code=${ip_end:1:2}
echo $ip_end
if [ $ip_end -lt 17 ]
then
host_name="k8s-node"+$host_code
else
host_name="master"
fi
`hostnamectl set-hostname $host_name`
echo hostname