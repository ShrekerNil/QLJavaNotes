#!/bin/bash

#LC_ALL=C ifconfig  | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
ip=`ip a show dev eth0|grep -w inet|awk '{print $2}'|awk -F '/' '{print $1}'`
#ip_end=${ip:-1}
ip_end=${ip##*.}

if [ $ip_end -lt 17 ]
then
sh join.sh
else
echo "当前为主节点"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi