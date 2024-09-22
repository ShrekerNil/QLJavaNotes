#!/bin/bash

# 使用shell脚本搭建k8s集群
# 作者：wujianqinjian https://www.bilibili.com/read/cv8352789/?spm_id_from=333.999.0.0 出处：bilibili

# 前置免密登录脚本，执行脚本时需连续输入3次回车后，再根据提示输入yes及对应服务器密码

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
