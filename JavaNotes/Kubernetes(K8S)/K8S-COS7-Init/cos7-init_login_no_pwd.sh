#!/bin/bash

PASSWORD=cos7

function config_ssh_auto_login() {
    expect -c "set timeout -1;
        spawn ssh-copy-id $1;
        expect {
            *(yes/no)* { send -- yes\r; exp_continue; }
            *password:* { send -- $2\r; exp_continue; }
            eof {exit 0;}
        }"
}

function config_ssh_auto_login_batch() {
    echo "********************************************************"
    echo "> STARTING SSH-COPY-ID ...                            <"
    for hostip in ${dict_hosts_all[@]}; do
        echo "***********************************************"
        echo "> Copying public rsa id for ${hostip} ..."
        config_ssh_auto_login ${hostip} ${PASSWORD}
        func_line_break
    done
}

function config_env_local() {
    echo "********************************************************"
    echo "> Closing ipv6 locally ..."
    source ./cos7-init_ipv6_close_host.sh
    func_line_break

    echo "********************************************************"
    echo "> Handling CentOS-Base.repo ..."
    cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
    curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
    yum makecache fast
    func_line_break

    echo "********************************************************"
    echo "> Installing openssh-clients & expect LOCAL ..."
    yum install -y openssh-clients
    yum install -y expect
    func_line_break

    echo "********************************************************"
    echo "> Configuring local yum ..."
    sed -i '/\[main\]/a gpgcheck=0' /etc/yum.conf
    func_line_break
}

function config_env_remote() {
    for hostip in ${dict_host_unmaster[@]}; do
        echo "********************************************************"
        echo "> Copying cos7-init_ipv6_close_host.sh for ${hostip} ..."
        exec_whole "scp ./cos7-init_ipv6_close_host.sh root@${hostip}:/root/cos7-init_ipv6_close_host.sh"
        func_line_break

        echo "> CHMOD cos7-init_ipv6_close_host.sh for ${hostip} ..."
        exec_ssh ${hostip} "chmod +x /root/cos7-init_ipv6_close_host.sh"
        func_line_break

        echo "> Executing cos7-init_ipv6_close_host.sh for ${hostip} ..."
        exec_ssh ${hostip} "source /root/cos7-init_ipv6_close_host.sh"
        func_line_break

        echo "> BACKUP CentOS-Base.repo for ${hostip} ..."
        exec_ssh ${hostip} "cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak"
        func_line_break

        echo "> HANDLING CentOS-Base.repo for ${hostip} ..."
        exec_ssh ${hostip} "curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo"
        func_line_break

        echo "> HANDLING CentOS-Base.repo for ${hostip} ..."
        exec_ssh ${hostip} "sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo"
        func_line_break

        echo "> REBUILD YUM CACHE for ${hostip} ..."
        exec_ssh ${hostip} "yum makecache fast"
        func_line_break

        echo "> Installing openssh-clients for ${hostip} ..."
        exec_ssh ${hostip} "yum install -y openssh-clients"
        func_line_break
    done
}

function make_rsa_key() {
    echo "********************************************************"
    echo "> MAKING RSA ID ..."
    expect -c "set timeout -1;
        spawn ssh-keygen -t rsa;
        expect {
            */.ssh/id_rsa* { send -- \r; exp_continue; }
            *empty* { send -- \r; exp_continue; }
            *again* { send -- \r; exp_continue; }
            eof        {exit 0;}
        }"
}

function main() {
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "> CONFIG LOCAL ENVIRONMENTS ...                              <"
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    func_line_break
    config_env_local
    func_line_break

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "> CONFIG REMOTE ENVIRONMENTS ...                            <"
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    func_line_break
    config_env_remote
    func_line_break

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "> MAKE RSA KEY ...                                          <"
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    func_line_break
    make_rsa_key
    func_line_break

    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "> CONFIG SSH AUTO LOGIN ...                                 <"
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    func_line_break
    config_ssh_auto_login_batch
    func_line_break
}

main
