#!/bin/bash

# disable system swap
function disable_swap() {
    # 读取 /etc/fstab 文件
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 如果行包含 swap，则在行前添加注释符号 #
        if [[ $line == *swap* ]]; then
            echo "#$line"
        else
            echo "$line"
        fi
    done < /etc/fstab > /etc/fstab.tmp
    # 替换 /etc/fstab 文件
    mv /etc/fstab.tmp /etc/fstab
    echo "Swap entries in /etc/fstab have been commented out."
}

# set the prompt sign
function set_prompt_dollar() {
    # Check if PS1 is already defined
    if grep -q 'PS1=' /root/.bashrc; then
        # If PS1 is already defined, modify its value
        sed -i '/PS1=/c\PS1="[\\u@\\h \\W]\\$ "' /root/.bashrc
    else
        # If PS1 does not exist, add a new PS1 definition
        echo 'export PS1="[\\u@\\h \\W]\\$ "' >> /root/.bashrc
    fi
}

set_prompt_dollar

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Config hostname for non master node ...        <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo "******************************************"
echo "> Setting hostname ...                   <"
for hostname in ${!dict_hosts_all[@]} ; do
    hostip=${dict_hosts_all[$hostname]}
    echo "Setting hostname for $hostname/$hostip ..."
    ssh root@$hostip "hostnamectl set-hostname $hostname"
    func_line_break
done

echo "******************************************"
echo "> Testing hostname ...                   <"
for hostname in ${!dict_hosts_all[@]} ; do
    hostip=${dict_hosts_all[$hostname]}
    echo "> Testing hostname for $hostname/$hostip ..."
    ssh root@$hostip "hostname"
    func_line_break
done

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Open Ports Needed ...                          <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
# 要么关闭防火墙，要么放开端口
# echo "> Open port: 80"
# firewall-cmd --zone=public --add-port=80/tcp --permanent
# func_line_break
# echo "> Open port: 8080"
# firewall-cmd --zone=public --add-port=8080/tcp --permanent
# func_line_break
# echo "> Open port: 443"
# firewall-cmd --zone=public --add-port=443/tcp --permanent
# func_line_break
# echo "> Open port: 6443"
# firewall-cmd --zone=public --add-port=6443/tcp --permanent
# func_line_break
# echo "> Open port: 10250"
# firewall-cmd --zone=public --add-port=10250/tcp --permanent
# func_line_break
# echo "> Reload firewall service ..."
# firewall-cmd --reload
systemctl stop firewalld
systemctl disable firewalld
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Config basic env on none Master nodes ...      <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
for hostname in ${!dict_host_unmaster[@]} ; do
    hostip=${dict_host_unmaster[$hostname]}
    echo "Disable firewall to $hostname/$hostip ..."
    ssh root@$hostip "systemctl stop firewalld"
    ssh root@$hostip "systemctl disable firewalld"
    func_line_break
    echo "Disable selinux to $hostname/$hostip ..."
    ssh root@$hostip "setenforce 0"
    ssh root@$hostip "sed -i '/SELINUX/s/enforcing/disabled/g' /etc/selinux/config"
    func_line_break
    echo "Disable NetworkManager to $hostname/$hostip ..."
    ssh root@$hostip "systemctl stop NetworkManager"
    ssh root@$hostip "systemctl disable NetworkManager"
    func_line_break
    echo "Confiug ssh env to $hostname/$hostip ..."
    ssh root@$hostip "sed -i -e "/GSSAPIAuthentication/s/yes/no/g" -e "/GSSAPICleanupCredentials/s/yes/no/g" -e "s/^#UseDNS\ no/UseDNS\ no/" -e "s/^#UseDNS\ yes/UseDNS\ no/" /etc/ssh/sshd_config"
    ssh root@$hostip "echo -ne 'ClientAliveInterval 60\nClientAliveCountMax 10' >> /etc/ssh/sshd_config"
    ssh root@$hostip "systemctl restart sshd"
    func_line_break
done

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Configuring Master hosts ...                   <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

echo "******************************************"
echo "> Adding hosts config to /etc/hosts ...  <"
cat > /etc/hosts << EOF
192.168.1.50 k8s-master.napsoul.com k8s-master
192.168.1.51 k8s-node1.napsoul.com k8s-node1
192.168.1.52 k8s-node2.napsoul.com k8s-node2
192.168.1.60 k8s-registry.napsoul.com k8s-registry
EOF
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Syncing hosts to none Master nodes ...       <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
for hostname in ${!dict_host_unmaster[@]} ; do
    hostip=${dict_host_unmaster[$hostname]}
    echo "Uploading k8s-master:/etc/hosts to $hostname/$hostip ..."
    scp /etc/hosts root@$hostip:/etc/hosts
    ssh root@$hostip "cat /etc/hosts"
    func_line_break
done

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Disable Master Swap ...                        <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
disable_swap
swapoff -a
cat >> /etc/sysctl.d/k8s.conf << EOF
vm.swappiness=0
EOF
sysctl -p /etc/sysctl.d/k8s.conf
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Configuring forward traffic ...                <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
cat >> /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
modprobe overlay
sysctl -p /etc/sysctl.d/k8s.conf
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Uploading k8s.conf to remote hosts ...      <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
for hostname in ${!dict_hosts_nodes[@]} ; do
    hostip=${dict_hosts_nodes[$hostname]}
    echo "Uploading k8s-master:/etc/sysctl.d/k8s.conf to $hostname@$hostip ..."
    scp /etc/sysctl.d/k8s.conf root@$hostip:/etc/sysctl.d/k8s.conf
    ssh root@$hostip "modprobe br_netfilter"
    ssh root@$hostip "modprobe overlay"
    ssh root@$hostip "sysctl -p /etc/sysctl.d/k8s.conf"
    ssh root@$hostip "swapoff -a"
    func_line_break
done
