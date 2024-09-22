#!/bin/bash

# 定义要传输的文件所在的本地目录
LOCAL_DIR="/d/QLRepo/QLCoder/JavaNotes/Kubernetes(K8S)/COS7-Init/"

# 定义远程服务器的IP地址
REMOTE_SERVER="192.168.1.50"

# 定义远程服务器的用户名
REMOTE_USER="root"

# 定义远程服务器的密码（不建议在脚本中明文存储密码）
REMOTE_PASS="cos7"

# 定义要传输的文件后缀
FILE_SUFFIX="sh"

echo "================================================================="
echo ==============="      UPLOAD INITIAL SCRIPTS       ==============="
echo "================================================================="
# 传输文件到远程服务器的/root/目录
scp ${LOCAL_DIR}*.${FILE_SUFFIX} ${REMOTE_USER}@${REMOTE_SERVER}:/root/

# 检查scp命令是否成功执行
if [ $? -eq 0 ]; then
      echo "> Files transferred successfully."
else
      echo "> Failed to transfer files."
      exit 1
fi

## 使用sshpass自动输入密码执行远程服务器上的命令
#ssh ${REMOTE_USER}@${REMOTE_SERVER} "chmod +x /root/cos7-init.sh"
#ssh ${REMOTE_USER}@${REMOTE_SERVER} "/root/cos7-init.sh"
#
## 检查脚本执行是否成功
#if [ $? -eq 0 ]; then
#      echo "> cos7-init.sh executed successfully."
#else
#      echo "> Failed to execute cos7-init.sh."
#      exit 1
#fi
