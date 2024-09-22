#!/bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Config Host CRI Environments ...               <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
# echo "*********************************************"
# echo "> Preparing /var/run/cri-dockerd ..."
# mkdir -p /var/run/cri-dockerd
# chown root:docker /var/run/cri-dockerd
# chmod 0770 /var/run/cri-dockerd

echo "*********************************************"
echo "> Downloading cri-dockerd.tgz ..."
# https://gitee.com/QLOthers/TempFiles/raw/master/cri-dockerd-0.3.2.amd64.tgz
# wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.2/cri-dockerd-0.3.2.amd64.tgz
download_with_wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.2/cri-dockerd-0.3.2.amd64.tgz /opt/k8s/cri-dockerd/
tar -xf /opt/k8s/cri-dockerd/cri-dockerd-0.3.2.amd64.tgz -C /opt/k8s/cri-dockerd/
func_line_break

echo "*********************************************"
echo "> Upload cri-dockerd to master & nodes ..."
for hostname in ${!dict_hosts_master_and_nodes[@]} ; do
    hostip=${dict_hosts_master_and_nodes[$hostname]}
    echo "Upload cri-dockerd to $hostname/$hostip ..."
    scp /opt/k8s/cri-dockerd/cri-dockerd/cri-dockerd root@$hostip:/usr/local/bin/
    func_line_break
done

echo "*********************************************"
echo "> Test cri-dockerd to master & nodes ..."
for hostname in ${!dict_hosts_master_and_nodes[@]} ; do
    hostip=${dict_hosts_master_and_nodes[$hostname]}
    echo "Test cri-dockerd on $hostname/$hostip ..."
    ssh root@$hostip "cri-dockerd --version"
    func_line_break
done

echo "*********************************************"
echo "> Create cri-dockerd.service ..."
cat > /etc/systemd/system/cri-dockerd.service << EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/local/bin/cri-dockerd --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9 --network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin --container-runtime-endpoint=unix:///var/run/cri-dockerd.sock --cri-dockerd-root-directory=/var/lib/dockershim --docker-endpoint=unix:///var/run/docker.sock --cri-dockerd-root-directory=/var/lib/docker
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
[Install]
WantedBy=multi-user.target
EOF

echo "*********************************************"
echo "> Create cri-dockerd.socket ..."
cat > /etc/systemd/system/cri-dockerd.socket << EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=/var/run/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

echo "*********************************************"
echo "> Upload cri-dockerd.service/socket ..."
for hostname in ${!dict_hosts_nodes[@]} ; do
    hostip=${dict_hosts_nodes[$hostname]}
    echo "Upload cri-dockerd.service/socket to $hostname/$hostip ..."
    scp /etc/systemd/system/cri-dockerd.service root@$hostip:/etc/systemd/system/cri-dockerd.service
    scp /etc/systemd/system/cri-dockerd.socket root@$hostip:/etc/systemd/system/cri-dockerd.socket
    func_line_break
done

echo "*********************************************"
echo "> Enable cri-dockerd.service ..."
for hostname in ${!dict_hosts_master_and_nodes[@]} ; do
    hostip=${dict_hosts_master_and_nodes[$hostname]}
    echo "Upload cri-dockerd.service/socket to $hostname/$hostip ..."
    ssh root@$hostip "systemctl daemon-reload; systemctl enable cri-dockerd.service; systemctl restart cri-dockerd.service"
    func_line_break
done

echo "*********************************************"
echo "> Test cri-dockerd.service ..."
for hostname in ${!dict_hosts_master_and_nodes[@]} ; do
    hostip=${dict_hosts_master_and_nodes[$hostname]}
    echo "Upload cri-dockerd on $hostname/$hostip ..."
    ssh root@$hostip "systemctl is-active cri-dockerd"
    func_line_break
done
