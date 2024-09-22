#!/bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Install flannel                                <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

echo "> Installing flannel on Master ..."
# wget -P /opt/k8s/network/flannel/ https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
download_with_wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml /opt/k8s/network/flannel/
echo "> Backup kube-flannel.yml on Master ..."
cp /opt/k8s/network/flannel/kube-flannel.yml{,.bak}
echo "> Apply kube-flannel.yml on Master ..."
kubectl apply -f /opt/k8s/network/flannel/kube-flannel.yml
