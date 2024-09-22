#!/bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> Config YUM for other hosts ...                <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
for hostname in ${!dict_host_others[@]} ; do
    HOSTIP=${dict_host_others[$hostname]}
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "> CONFIGURING YUM for $hostname/$HOSTIP ...     <"
    ssh root@$HOSTIP "cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak"
    ssh root@$HOSTIP "curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo"
    func_line_break
done
