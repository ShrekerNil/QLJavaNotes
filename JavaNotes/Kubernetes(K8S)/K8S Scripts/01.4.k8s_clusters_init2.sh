#!/bin/bash

# 该脚本需输入y确认

#LC_ALL=C ifconfig | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
ip=`ip a show dev eth0|grep -w inet|awk '{print $2}'|awk -F '/' '{print $1}'`
#ip_end=${ip:-1}
ip_end=${ip##*.}
if [ $ip_end -lt 17 ]
then
echo "跳过当前步骤"
else
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
fi