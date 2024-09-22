#!/bin/bash

# All nodes
declare -A dict_hosts_all
dict_hosts_all=(["k8s-master"]="192.168.1.50"
                ["k8s-node1"]="192.168.1.51"
                ["k8s-node2"]="192.168.1.52"
                ["k8s-registry"]="192.168.1.60")

# Master
declare -A dict_hosts_master
dict_hosts_master=(["k8s-master"]="192.168.1.50")

# Master & Nodes
declare -A dict_hosts_master_and_nodes
dict_hosts_master_and_nodes=(["k8s-master"]="192.168.1.50"
                         ["k8s-node1"]="192.168.1.51"
                         ["k8s-node2"]="192.168.1.52")

# All non Master nodes
declare -A dict_host_unmaster
dict_host_unmaster=(["k8s-node1"]="192.168.1.51"
                    ["k8s-node2"]="192.168.1.52"
                    ["k8s-registry"]="192.168.1.60")

# All work nodes
declare -A dict_hosts_nodes
dict_hosts_nodes=(["k8s-node1"]="192.168.1.51"
                  ["k8s-node2"]="192.168.1.52")

function func_line_break {
    echo -e "\n"
}

function download_with_wget() {
    # The first argument is the download URL, no default value
    local url="$1"
    echo "> Start downloading file: $url"
    # The second arg of output path is the current script's directory + the file name from the URL
    local output_path=${2:-"$(pwd)"}
    echo "> Output path: $output_path"
    # The third argument is the retry count, default value is 3
    local max_retries=${3:-"3"}
    echo "> Max download retries: $max_retries"
    local retries=0

    # Check if wget is installed
    if ! command -v wget &> /dev/null; then
        echo "> Wget not found, installing wget using yum..."
        # Install wget using yum
        yum install -y wget
        if [ $? -ne 0 ]; then
            echo "> Failed to install wget. Please install it manually."
            return 1
        fi
    fi

    # Start an infinite loop to attempt downloading
    while true; do
        # Download the file using wget
        wget -P "$output_path" "$url"

        # Check the exit status of wget
        if [ $? -eq 0 ]; then
            echo "> Download successful: $url"
            break # Download successful, exit the loop
        else
            echo "> DOWNLOAD FAILED, RETRYING ... (Attempt number: $((retries+1)))"
            retries=$((retries+1))

            # Check if the maximum number of retries has been reached
            if [ $retries -ge $max_retries ]; then
                echo "> MAXIMUM NUMBER OF RETRIES REACHED, DOWNLOAD FAILED: $1"
                return 1 # Maximum number of retries reached, return an error
            fi

            # Wait for a while before retrying
            sleep 5
        fi
    done
}

function exec_ssh() {
    expect -c "set timeout -1;
        spawn ssh root@$1 $2
        expect {
            *password:* { send -- ${PASSWORD}\r; exp_continue; }
            *(yes/no)* { send -- yes\r; exp_continue; }
            eof        { exit 0; }
        }"
}

function exec_whole() {
    expect -c "set timeout -1;
        spawn $1
        expect {
            *password:* { send -- ${PASSWORD}\r; exp_continue; }
            *(yes/no)* { send -- yes\r; exp_continue; }
            eof        { exit 0; }
        }"
}

# 确保脚本以 root 权限运行
if [[ $EUID -ne 0 ]]; then
    echo "THIS SCRIPT MUST BE RUN AS ROOT !"
    exit 1
fi

echo '#########################################################################'
echo '##                      CONFIG LOGIN WITHOUT PASSWD                    ##'
echo '#########################################################################'
source ./cos7-init_login_no_pwd.sh

echo '#########################################################################'
echo '##                           CONFIG ENV BASIC                          ##'
echo '#########################################################################'
source ./cos7-init_env_basic.sh

echo '#########################################################################'
echo '##                       CONFIGURING CONTAINER ENV                     ##'
echo '#########################################################################'
source ./cos7-container.sh

echo '#########################################################################'
echo '##                      CONFIGURING K8S PREPARE ENV                    ##'
echo '#########################################################################'
source ./cos7-kube_cri.sh

echo '#########################################################################'
echo '##                           INSTALL K8S ENV                           ##'
echo '#########################################################################'
source ./cos7-kube.sh

echo '#########################################################################'
echo '##                           INSTALL CNI ENV                           ##'
echo '#########################################################################'
# flannel 的配置目前是有问题的
# source ./cos7-kube_cni_flannel.sh
source ./cos7-kube_cni_calico.sh
