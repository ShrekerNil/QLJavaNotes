#!/bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Configuring Container Env for all hosts       <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
for hostip in ${dict_hosts_all[@]}; do
    echo "**************************************************"
    echo "> Copying cos7-container_host.sh for ${hostip} ..."
    exec_whole "scp ./cos7-container_host.sh root@${hostip}:/root/cos7-container_host.sh"

    echo "> CHMOD cos7-container_host.sh for ${hostip} ..."
    exec_ssh ${hostip} "chmod +x /root/cos7-container_host.sh"

    echo "> Executing cos7-container_host.sh for ${hostip} ..."
    exec_ssh ${hostip} "source /root/cos7-container_host.sh"
done
func_line_break
