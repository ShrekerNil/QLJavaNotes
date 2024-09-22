#!/bin/bash

function func_line_break() {
    echo -e "\n"
}

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> EDIT /etc/sysctl.conf ..."
cat >> /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> EDIT /etc/sysconfig/network ..."
cat >> /etc/sysconfig/network << EOF
NETWORKING_IPV6=no
EOF
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> EDIT ifcfg-enp0s3 ..."
sed -i '/^IPV6INIT=/c\IPV6INIT=no' /etc/sysconfig/network-scripts/ifcfg-enp0s3
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> DISABLE IPV6 SERVICE ..."
# if systemctl is-enabled ip6tables > /dev/null; then
if systemctl list-unit-files | grep ip6tables.service | grep enabled; then
    echo "> ip6tables is enabled to start on boot."
    systemctl disable ip6tables
    echo "> ip6tables has been disabled to start on boot."
else
    echo "> ip6tables is not enabled to start on boot."
fi
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> APPLY ALL CONFIG ..."
sysctl -p
func_line_break

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> RESTAT NETWORK ..."
systemctl restart network
func_line_break
