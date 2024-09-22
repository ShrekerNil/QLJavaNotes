#!/bin/bash

# Update containerRuntimeEndpoint in /var/lib/kubelet/config.yaml
function update_container_runtime_endpoint() {
     # Check if the file exists
     if [ ! -f "/var/lib/kubelet/config.yaml" ]; then
         echo "Configuration file /var/lib/kubelet/config.yaml does not exist."
         return 1
     fi

     # Use sed to replace the specified line
     sed -i '/^containerRuntimeEndpoint:/c\containerRuntimeEndpoint: "unix:///var/run/cri-dockerd.sock"' /var/lib/kubelet/config.yaml

     # Check if sed command was successful
     if [ $? -eq 0 ]; then
         echo "containerRuntimeEndpoint has been updated to 'unix:///var/run/cri-dockerd.sock'."
     else
         echo "Update failed."
         return 1
     fi
}

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Install K8S                                    <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

echo "******************************************"
echo "> Adding kubernetes.repo @k8s-master ... <"
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum makecache fast

echo "******************************************"
echo "> Uploading kubernetes.repo ..."
for hostname in ${!dict_hosts_nodes[@]} ; do
    hostip=${dict_hosts_nodes[$hostname]}
    echo "Uploading kubernetes.repo to $hostname/$hostip ..."
    scp /etc/yum.repos.d/kubernetes.repo root@$hostip:/etc/yum.repos.d/kubernetes.repo
    ssh root@$hostip "yum makecache fast"
    func_line_break
done

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Installing K8S Components ..."
for hostname in ${!dict_hosts_master_and_nodes[@]} ; do
    hostip=${dict_hosts_master_and_nodes[$hostname]}
    echo "Installing K8S Components to $hostname/$hostip ..."
    ssh root@$hostip "yum install -y kubeadm kubectl kubelet"
    ssh root@$hostip "systemctl enable kubelet.service"
    func_line_break
done

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Pulling dependent images for K8S ..."
kubeadm_version=$(kubeadm version | sed -n 's/.*GitVersion:"\([^"]*\).*/\1/p' | sed 's/^v//')
image_lines=$(kubeadm config images list --kubernetes-version=$kubeadm_version | awk -F "/" '{print $NF}')
for i in ${image_lines}; do
    echo "> Pulling dependent image: $i"
    docker pull registry.aliyuncs.com/google_containers/$i
    func_line_break
done
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ">              Master initialization             <"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
master_ip=$(hostname -I | awk '{print $1}')
cmd_join=$(kubeadm init \
    --kubernetes-version=$kubeadm_version \
    --apiserver-advertise-address=$master_ip \
    --image-repository registry.aliyuncs.com/google_containers \
    --service-cidr=10.96.0.0/12 \
    --pod-network-cidr=10.244.0.0/16 \
    --cri-socket=unix:///var/run/cri-dockerd.sock \
    --ignore-preflight-errors=Swap \
    --ignore-preflight-errors=NumCPU \
    --ignore-preflight-errors=Mem \
    2>&1 | tee /dev/tty | grep -A 1 'kubeadm join' | head -n 2)
func_line_break

# cmd_join=$(echo "$cmd_join" | sed 's/ \\//g')
cmd_join="${cmd_join} --cri-socket=unix:///var/run/cri-dockerd.sock"
echo "cmd_join: $cmd_join"
# cmd_join=$(echo "$cmd_join" | sed 's/\\ //g; s/$/ --cri-socket=unix:\/\/\/var\/run\/cri-dockerd.sock/')
sleep 3
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo ">               Node initialization              <"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
for hostname in ${!dict_hosts_nodes[@]} ; do
    hostip=${dict_hosts_nodes[$hostname]}
    echo "> Work node initialization to $hostname/$hostip ..."
    ssh root@$hostip "$cmd_join"
    func_line_break
done

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Test kubectl on Master ..."
kubectl get nodes
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Update containerRuntimeEndpoint ..."
# 安装完成后发现/var/lib/kubelet/config.yaml中的containerRuntimeEndpoint是空的
# 所以编写函数更新这个错误，可能是之前的某些配置有问题导致containerRuntimeEndpoint为空
update_container_runtime_endpoint
systemctl restart kubelet
for hostname in ${!dict_hosts_nodes[@]} ; do
    hostip=${dict_hosts_nodes[$hostname]}
    echo "> Update containerRuntimeEndpoint to $hostname/$hostip ..."
    scp /var/lib/kubelet/config.yaml root@$hostip:/var/lib/kubelet/config.yaml
    ssh root@$hostip "systemctl restart kubelet"
    func_line_break
done

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> cmd completion ..."
func_line_break

echo "> Handle .bashrc ..."
cat >> ~/.bashrc << EOF

# cmd completion for kubectl & kubeadm
source <(kubectl completion bash)
source <(kubeadm completion bash)
EOF
func_line_break

# 如果要在终端上实现补全功能，在下面的脚本执行正常的情况下
# 1、重启即可实现补全命令
# 2、使用命令重新加载补全命令：source /usr/share/bash-completion/bash_completion
echo "> Installing bash-completion on Master ..."
yum -y install bash-completion
source ~/.bashrc
func_line_break

echo "> Upload .bashrc to nodes ..."
for hostname in ${!dict_hosts_nodes[@]} ; do
    hostip=${dict_hosts_nodes[$hostname]}
    echo "> Config cmd completion for kubectl & kubeadm to $hostname/$hostip ..."
    scp /root/.bashrc root@$hostip:/root/.bashrc
    ssh root@$hostip "yum -y install bash-completion"
    ssh root@$hostip "source ~/.bashrc"
    func_line_break
done
