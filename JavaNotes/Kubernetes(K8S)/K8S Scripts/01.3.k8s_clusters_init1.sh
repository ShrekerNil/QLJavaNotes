#!/bin/bash
#LC_ALL=C ifconfig | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
ip=`ip a show dev eth0|grep -w inet|awk '{print $2}'|awk -F '/' '{print $1}'`

#ip_end=${ip:-1}
ip_end=${ip##*.}

#如果是主节点，则初始化后，执行固定配置命令
if [ $ip_end -lt 17 ]
then
  echo "当前节点非master"
else
  kubeadm init \
  --apiserver-advertise-address=10.0.0.17 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.17.0 \
  --service-cidr=10.1.0.0/16 \
  --pod-network-cidr=10.244.0.0/16
fi