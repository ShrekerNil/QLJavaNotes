#!/bin/bash
scp -r /tmp/k8s_install 10.0.0.11:/tmp
scp -r /tmp/k8s_install 10.0.0.12:/tmp
scp -r /tmp/k8s_install 10.0.0.13:/tmp
scp -r /tmp/k8s_install 10.0.0.14:/tmp
scp -r /tmp/k8s_install 10.0.0.15:/tmp
scp -r /tmp/k8s_install 10.0.0.16:/tmp
scp -r /etc/kubernetes 10.0.0.11:/etc
scp -r /etc/kubernetes 10.0.0.12:/etc
scp -r /etc/kubernetes 10.0.0.13:/etc
scp -r /etc/kubernetes 10.0.0.14:/etc
scp -r /etc/kubernetes 10.0.0.15:/etc
scp -r /etc/kubernetes 10.0.0.16:/etc

# 主节点安装成功后复制join指令到join.sh中后，，执行scp.sh将脚本发送到其他各个node 执行
# node节点如果报错The connection to the server localhost:8080 was refused - did you specif，则执行kubeadmq8080.sh即可。
# 执行脚本后依旧报错，则直接在命令行手动执行脚本中命令