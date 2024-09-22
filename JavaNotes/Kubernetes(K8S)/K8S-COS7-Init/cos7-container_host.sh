#!/bin/bash

function func_line_break {
    echo -e "\n"
}

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> CONFIG HOST CONTAINER ENVIRONMENTS ...                      <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

echo "********************************************************"
echo "> Installing docker dependencies ..."
yum install -y yum-utils device-mapper-persistent-data lvm2
func_line_break

echo "********************************************************"
echo "> Adding docker-ce.repo to YUM ..."
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
func_line_break

echo "********************************************************"
echo "> Installing docker-ce ..."
yum install -y docker-ce
func_line_break

echo "********************************************************"
echo "> Enable docker service ..."
systemctl enable docker
func_line_break

echo "********************************************************"
echo "> Start docker service ..."
systemctl start docker
func_line_break

echo "********************************************************"
echo "> Config image acceleration & cgroupfs ..."
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://7eyfz1ob.mirror.aliyuncs.com",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ], 
  "insecure-registries": ["k8s-register.napsoul.com"], 
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
func_line_break

echo "********************************************************"
echo "> Restart docker service ..."
systemctl daemon-reload
systemctl restart docker
func_line_break
