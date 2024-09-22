#!/bin/bash

# 主节点安装成功后，执行scp.sh将脚本发送到其他各个node执行
# 注：
#   node节点如果报错The connection to the server localhost:8080 was refused - did you specif，则执行kubeadmq8080.sh即可
#   执行脚本后依旧报错，则直接在命令行手动执行脚本中命令。

#LC_ALL=C ifconfig | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
ip=`ip a show dev eth0|grep -w inet|awk '{print $2}'|awk -F '/' '{print $1}'`
#ip_end=${ip:-1}
ip_end=${ip##*.}
echo $ip_end
host_code=${ip_end:1:2}
echo $ip_end
if [ $ip_end -lt 17 ]
then
kubeadm join 10.0.0.17:6443 --token upd9ll.n2695flanykqy3rk \
--discovery-token-ca-cert-hash sha256:fda6328b*************380e10d92789d73c39b0640652f7f99
else
echo "当前为主节点“
fi
echo hostname
