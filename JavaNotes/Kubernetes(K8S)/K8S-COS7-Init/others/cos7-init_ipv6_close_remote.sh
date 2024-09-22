#!/bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "> CLOSE IPV6 ON ALL HOSTS ...                   <"
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
for hostname in ${!dict_host_others[@]} ; do
    HOSTIP=${dict_host_others[$hostname]}
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Closing IPV6 on $hostname/$HOSTIP ..."
    scp ./cos7-cos7-init_ipv6_close_host.sh root@$HOSTIP:/root/cos7-cos7-init_ipv6_close_host.sh
    ssh root@$HOSTIP "chmod +x /root/cos7-cos7-init_ipv6_close_host.sh"
    ssh root@$HOSTIP "sh /root/cos7-cos7-init_ipv6_close_host.sh"
    func_line_break
done
