#!/bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Install Calico                                 <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Installing calico on Master ..."
download_with_wget https://docs.projectcalico.org/manifests/calico.yaml /opt/k8s/network/calico/

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Backup calico.yaml on Master ..."
cp /opt/k8s/network/calico/calico.yaml{,.bak}

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Update CIDR in calico.yaml on Master ..."
sed -i '/CALICO_IPV4POOL_CIDR/{s/# //;n;s/# //;s/"[^"]*"/"10.244.0.0\/16"/}' /opt/k8s/network/calico/calico.yaml

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Delete 'docker.io/' in calico.yaml on Master ..."
sed -i 's#docker.io/##g' /opt/k8s/network/calico/calico.yaml

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Pulling dependent images for Calico ..."
image_lines=$(grep image: /opt/k8s/network/calico/calico.yaml | sort | uniq)
for line in $image_lines; do
    local image_name="$line"
    echo "> Pulling image: $image_name ..."
    docker pull "$image_name"
    func_line_break
done
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Apply calico.yaml on Master ..."
kubectl apply -f /opt/k8s/network/calico/calico.yaml
