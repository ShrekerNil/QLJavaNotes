#!/bin/bash

# 一：创建目录：/tmp/k8s_install,编写脚本，为了降低耦合性及提高维护性，共创建以下几个脚本
# 01.1.k8s_cluster_install.sh
# 01.2.ip_sethostname.sh
# 01.3.k8s_clusters_init1.sh
# 01.4.k8s_clusters_init2.sh
# 01.5.k8s_clusters_init3.sh


# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭selinux
sed -i 's/enforcing/disabled/' /etc/selinux/config
setenforce 0

# 关闭swapoff
swapoff -a

# 脚本动态根据服务器IP设置主机名
cd /tmp/k8s_install
sh ip_sethostname.sh

#绑定IP和主机名
cat >> /etc/hosts << EOF
192.168.1.50 k8s-master.napsoul.com k8s-master
192.168.1.51 k8s-node1.napsoul.com k8s-node1
192.168.1.52 k8s-node2.napsoul.com k8s-node2
192.168.1.60 k8s-registry.napsoul.com k8s-registry
EOF

#设置流量转发
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#执行生效
sysctl --system

#配置阿里源并安装docker，docker版本一定要是18以上
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
yum -y install docker-ce-18.06.1.ce-3.el7
systemctl enable docker && systemctl start docker
docker --version

#安装必要依赖
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget vim net-tools git

#同步服务器时间，可能会报错，不过问题不大，可以忽略
ntpdate time.windows.com

#配置阿里镜像加速器
mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://vkayqpp3.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker

#添加阿里云yum源
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum clean all
yum -y makecache

#安装k8s相关组件，最新的稳定版为1.19.0，此次先安装1.17.0，验证脚本无误后，后期尝试1.19.0
yum install -y kubelet-1.17.0 kubeadm-1.17.0 kubectl-1.17.0

#设置开机启动
systemctl enable kubelet

#初始化k8s
#master节点输出的加入命令需要手动复制
cd /tmp/k8s_install
sh k8s_clusters_init1.sh
sh k8s_clusters_init2.sh
sh k8s_clusters_init3.sh

#脚本在主节点执行完成之后，将join命令贴到join.sh脚本中，再将脚本发送到各个node节点

#查看节点状态
kubectl get nodes -n kube-system
