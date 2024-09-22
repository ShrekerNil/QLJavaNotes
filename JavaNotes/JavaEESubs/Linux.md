# Linux笔记

> 本篇中提到的命令默认基于CentOS，如遇意外会提示
>
> [LinuxSummary.md](LinuxSummary.md)

## 重要的名词

- **文件描述符**：内核为每个进程打开的文件维护的描述原信息，可以理解为代表一个文件，即文件的句柄

## Linux根目录

在Linux系统中，根目录（/）下包含多个子目录，每个目录都有其特定的用途。以下是一些常见的子目录及其用途：

1. **/bin**：binary，这个目录存放**系统预装的命令和应用程序**，如`/bin`、`/boot`等。
2. **/dev**：device，这个目录包含了**Linux系统中使用的所有外部设备的文件**。
3. **/etc**：et cetera(等等)，这个目录是**Linux系统中最常用的配置文件目录**，几乎所有的软件配置文件都放在这个目录下。
4. **/lib**：library，这个目录是**根文件系统上的程序所需的共享库**，用于避免每个程序都包含相同的子程序副本。
5. **/opt**：options，这个目录用于**存放第三方软件**。
6. **/tmp**：temporary，这个目录用于**临时文件**存放，一般用户或正在执行的程序临时存放文件的目录。
7. **/usr**：user，这个目录用于**存放用户安装的应用程序相关文件**。
8. **/var**：variable，这个目录用于**存放经常被访问的数据**，如日志、缓存等。

## 常见命令

### 目录操作

- ls
- cd
- pwd
- mkdir
- rmdir

### 文件操作

- touch
- cat
- cp
- rm
- mv
- chmod

- grep
  - 从文件中查找关键词所在行并打印列表：`grep <keyword>: <file>`

- head
- tail
- wc
- find
- which
- whereis
- locate
- echo
- more`more` 命令是一个用于分页显示文本文件内容的命令行工具。它允许用户逐页查看文件内容，而不是一次性显示整个文件。`more` 命令通常用于查看较长的文本文件，如日志文件、配置文件等。在使用 `more` 命令时，您可以使用以下按键来控制显示：
  - **空格键**：向下翻一页。
  - **回车键**：向下滚动一行。
  - **b 键**：向上翻一页。
  - **/ 键**：搜索文本。输入 `/` 后跟要搜索的字符串，然后按回车键。`more` 会高亮显示匹配的文本，并允许您继续搜索或按 `n` 键跳转到下一个匹配项。
  - **q 键**：退出 `more` 命令，返回到命令行。

- less：`less` 是一个比 `more` 更加强大和灵活的文本查看器，它允许用户在查看文件时进行更多的交互操作。`less` 命令在Unix和类Unix系统中广泛使用，它提供了许多有用的特性，包括但不限于
  - **分页查看**：`less` 会逐页显示文件内容，允许用户在查看过程中暂停。
  - **搜索功能**：用户可以使用 `/` 来搜索文本，输入搜索字符串后按回车键开始搜索。按 `n` 键可以跳转到下一个匹配项，按 `N` 键可以跳转到上一个匹配项。
  - **向前和向后滚动**：使用 `j` 键向下滚动一行，使用 `k` 键向上滚动一行。使用 `d` 键向下滚动半页，使用 `u` 键向上滚动半页。
  - **跳转到特定行**：输入 `:n` 来跳转到第n行，其中 `n` 是您想要跳转到的行号。
  - **退出**：按 `q` 键退出 `less`。
  - **高亮显示**：`less` 可以高亮显示搜索结果。
  - **文件导航**：`less` 可以同时打开多个文件，并允许用户在它们之间切换。
  - **文件比较**：`less` 可以用来比较两个文件的内容。


```sh
basename example.tar.gz .tar.gz
# => example

FILE="example.tar.gz"

echo "${FILE%%.*}"
# => example

echo "${FILE%.*}"
# => example.tar

echo "${FILE#*.}"
# => tar.gz

echo "${FILE##*.}"
# => gz

# 在bash中可以这么写
filename=$(basename "$fullfile")
extension="${filename##*.}"
filename="${filename%.*}"

# 查看某个程序的依赖
ldd <exec>

# 切换程序的root目录
chroot <path>

# 生成文件
dd

# 查看挂载的文件系统
df

# 某个进程的文件描述符
cd /proc/<pid>/fd
# 当前bash打开的文件描述符
cd /proc/$$/fd

# 详细查看某个进程文件描述符细节
lsof -op <pid>
```

### 压缩操作

- bzip2
- bunzip2
- gzip
- unzip
- tar

### 进程操作

- top

![top view](Linux.assets/image-20210812232027334.png)

- ps
- kill

### 磁盘操作

- mount
- unmount

### 网络操作

1. 查看本机路由信息：`route -n`

2. nmcli：network manager command-line interface

   - 显示网络接口：nmcli

   - 获得网络接口的简单摘要：`nmcli device status` / `nmcli dev status`

   - 列出系统上的所有活动接口：`nmcli connection show` / `nmcli con show` / `nmcli connection show --active`

   - 指定输出字段：`nmcli -f DEVICE, TYPE device`

   - 易于阅读的格式显示：`nmcli -p device`

   - 配置NAT网络的静态IP：

     ```bash
     nmcli con modify enp0s3 \
     ipv4.method manual \
     ipv4.address 192.168.88.10/24 \
     ipv4.gateway 192.168.88.1 \
     ipv4.dns 223.5.5.5
     autoconnect yes
     ```


### 开关机命令

- shutdown
- halt
- poweroff
- reboot

### 系统命令

- init：用于切换系统的运行级别。这些运行级别通过符号链接在`/etc/rcX.d/`目录中来控制相应的服务启动或停止，其中`X`代表当前的运行级别。可以通过修改`/etc/inittab`文件来设置默认的运行级别：
  1. `init 0`：关机。这会导致系统完全关闭。
  2. `init 1`：单用户模式。在这个模式下，只有root用户可以登录，适用于系统维护和故障排除。
  3. `init 2`：多用户模式，但不启用NFS（网络文件系统）。这个级别通常用于系统启动时的基本服务配置。
  4. `init 3`：多用户-命令行模式。这是默认的运行级别之一，适用于大多数服务器环境。
  5. `init 4`：用户定义的运行级别。这个级别可以根据需要进行自定义设置。
  6. `init 5`：图形界面模式。这个级别通常用于桌面环境，如GNOME或KDE。
  7. `init 6`：重启系统。这会导致系统重新启动。

### 其他操作

- help
- man
- history

```sh
echo $HISTSIZE
echo $HISTFILE
```

## 常用操作

### 查看用户名密码

```sh
$ cat /etc/passwd
```

### 查看网卡

```sh
$ ip a s
$ ip link
$ nmcli
$ ifconfig
```

### 查看端口占用

```sh
# 方法1
$ yum install -y net-tools
$ netstat -nltpu | grep 80

# 方法2
$ yum install -y lsof
$ lsof -i:80
```

### 查看系统资源

```sh
# 查看系统CPU信息
$ lscpu
```

### 查看进程

```sh
$ ps -aux
```

### 查看应用的资源占用

```sh
# 根据端口找pid
$ ps -aux | grep sshd
# 根据进程号&top命令查看内存占用
$ top -p <pid>
# 查看磁盘占用情况
$ df -h
```

![image-20210812232812998](Linux.assets/image-20210812232812998.png)

### 防火墙规则保存与恢复

iptables：

```sh
$ iptables-save > <file>
$ iptables-restore > <file>
```

### 监控文件夹变化

每隔1秒刷新当前文件的变化：

```sh
$ watch -n 1 -d find ./
```

### 定时任务

```sh
$ cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed

================================================================

# 查看已有的任务
crontab -l

# 编辑任务
crontab -e

#每周五隔一个小时执行一次
* */1 * * 5 <command | script>
```

## 实践案例

### AccessLog中找出访问量最高的IP

```sh
# Nginx日志位置： /var/log/nginx/access.log
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr -kl | head -n 10
```

#### 配置默认为空格

配置文件位置:

```
vi: /etc/virc
vim: /etc/vimrc
```

配置文件最后添加

```sh
" add tab space
set ts=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
```

- ts 是tabstop的缩写，设TAB宽度为4个空格。
- softtabstop 表示在编辑模式的时候按退格键的时候退回缩进的长度，当使用 expandtab 时特别有用。
- shiftwidth 表示每一级缩进的长度，一般设置成跟 softtabstop 一样。
- expandtab表示缩进用空格来表示，noexpandtab 则是用制表符表示一个缩进。
- autoindent自动缩进

#### 已存在的文件

TAB替换为空格

```
:set ts=4
:set expandtab
:%retab!
```

空格替换为TAB

```
	:set ts=4
:set noexpandtab
:%retab!
```

## VIM编辑器

### 常见操作

#### 多行复制

复制操作：`:.,$-1y`；粘贴操作：`p`

`.`带表光标所在的行，`,`分隔，`$`表示最后一行，`$-1`表示倒数第二行，`y`表示复制，`p`表示粘贴

#### 多列编辑

`:.,$/#//`：利用替换删除配置文件注释，释义见[复制](### 复制)

删除字符

删除一行：`dd`

删除及光标后的n行：`<n>dd`

#### 不退出执行命令

`:! <your-cmd>`

#### 不变格式粘贴

利用vim的粘贴模式即可实现

1. 复制要粘贴的内容
2. 输入命令：`:set paste`
3. 粘贴即可

#### 保存退出快捷键

1. 命令模式：`:wq`
2. 命令模式：`Shift + Z + Z`

### 相关配置

在 Vim 或 Vi 编辑器中，配置文件（通常是 `.vimrc` 或 `.virc`）用于存储用户自定义的设置和映射。

#### 设置tab空格数量

一般设置tab空格数量会涉及到4个选项：

1. `tabstop`：这个设置定义了 Vim 中一个制表符（Tab）所占用的空格数。默认值通常是 8。
2. `softtabstop`：这个设置定义了 Vim 在插入模式下，当你按下 Tab 键时，应该插入多少个空格。
3. `shiftwidth`：这个设置定义了 Vim 在自动缩进时使用的空格数。
   - 当你使用 `>>` 或 `<<` 命令来缩进或取消缩进代码块时，Vim 会根据 `shiftwidth` 的值来决定应该插入或删除多少个空格。
4. `expandtab`：这个设置决定了 Vim 在插入模式下，当你按下 Tab 键时，是否应该插入空格而不是制表符。
   - 如果 `expandtab` 设置为 `true`，那么 Vim 会插入空格而不是制表符。这有助于保持代码的可移植性，因为不同编辑器和环境对制表符的解释可能不同。

下面是一个用于快速修改编辑器tab空格数量的函数脚本：

```sh
#!/bin/bash

# Define a function to configure the tabstop setting for vi
function configure_vi_tab() {
    local space_count=$1
    local editor=${2:-"vi"}
    local valid_editors=("vi" "vim")

    # Check if the second argument is valid
    if [[ ! " ${valid_editors[@]} " =~ " ${editor} " ]]; then
        echo "Error: Invalid editor name. Please use 'vi' or 'vim'."
        exit 1
    fi

    local vi_config_file="${HOME}/.${editor}rc"
    local config_content=$(cat "$vi_config_file")

    # Check and modify configuration items
    if ! grep -q "tabstop" <<< "$config_content"; then
        echo "Adding tabstop configuration: tabstop=$space_count"
        echo "tabstop=$space_count" >> "$vi_config_file"
    else
        sed -i "s/^tabstop=[0-9]\+/tabstop=$space_count/g" "$vi_config_file"
    fi

    if ! grep -q "softtabstop" <<< "$config_content"; then
        echo "Adding softtabstop configuration: softtabstop=$space_count"
        echo "softtabstop=$space_count" >> "$vi_config_file"
    else
        sed -i "s/^softtabstop=[0-9]\+/softtabstop=$space_count/g" "$vi_config_file"
    fi

    if ! grep -q "shiftwidth" <<< "$config_content"; then
        echo "Adding shiftwidth configuration: shiftwidth=$space_count"
        echo "shiftwidth=$space_count" >> "$vi_config_file"
    else
        sed -i "s/^shiftwidth=[0-9]\+/shiftwidth=$space_count/g" "$vi_config_file"
    fi

    if ! grep -q "expandtab" <<< "$config_content"; then
        echo "Adding expandtab configuration: expandtab=true"
        echo "expandtab=true" >> "$vi_config_file"
    else
        sed -i "s/^expandtab=false|0/expandtab=true/g" "$vi_config_file"
    fi
}

# Example usage:
configure_vi_tab 4 "vi"
configure_vi_tab 4 "vim"

# 或者直接添加到该文件，因为新系统默认没有这个配置：
cat >> ${HOME}/.${editor}rc << EOF
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab=true
EOF
```

### 常见快捷键

#### 命令模式~快捷键

1. 缩进：`>>` 或 `<<` 

#### 命令模式~命令

- set nu　　//显示行号
- set nonu　　//不显示行号
- set expandtab　　//把tab 显示成空格
- set shiftwidth=4　　//自动缩进4格
- set ignorecase　　//忽略大小写

## 软链接和硬链接

软链接和硬链接都是链接，都可以通过链接访问到文件

软链接

- 只是一个链接，源文件删除就不可能访问到了，可以理解为连接到原始文件句柄，而不是链接到磁盘文件
- 磁盘文件引用奇数不+1

硬链接

- 和原始文件链接同等级别，链接到磁盘文件，原始链接删除照样能访问到磁盘文件
- 磁盘文件引用计数+1

## Linux内核映射

标准输入输出

0：标准输入

1：标准输出

2：标准错误输出

`/proc`：内核映射目录

- 映射内核的一些变量属性等
- 目录本身不存放任何内容，开机之后，内核的一些属性等都会在这个目录挂载
- 目录下每一个数字代表一个进程的PID 

```sh
$ ls /proc
1      1174   19     22075  26568  274  3488  45   552  8     9883       cgroups    driver       irq         loadavg  net           softirqs       tty
10     13     19703  23     268    283  350   46   558  825   9885       cmdline    execdomains  kallsyms    locks    pagetypeinfo  stat           uptime
1041   14     2      24     26842  284  372   491  565  826   9887       consoles   fb           kcore       mdstat   partitions    swaps          version
11     15     20     241    27080  3    3749  5    566  828   9895       cpuinfo    filesystems  keys        meminfo  sched_debug   sys            vmallocinfo
11024  16     21     259    27091  30   3786  512  579  9     9900       crypto     fs           key-users   misc     schedstat     sysrq-trigger  vmstat
11027  16005  22     260    27102  31   41    515  59   90    acpi       devices    interrupts   kmsg        modules  scsi          sysvipc        zoneinfo
11042  17     22000  262    27120  32   43    516  7    9790  buddyinfo  diskstats  iomem        kpagecount  mounts   self          timer_list
11081  18     22016  263    27187  33   44    540  761  9881  bus        dma        ioports      kpageflags  mtrr     slabinfo      timer_stats
```

## 防火墙Firewall

### firewalld

```sh
# 查看firewall是否运行,下面两个命令都可以
systemctl status firewalld.service
firewall-cmd --state

# 添加端口
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent

# 添加端口并重新加载配置
firewall-cmd --zone=public --add-port=80/tcp --permanent && firewall-cmd --reload
firewall-cmd --zone=public --add-port=443/tcp --permanent && firewall-cmd --reload
firewall-cmd --zone=public --add-port=3306/tcp --permanent && firewall-cmd --reload

# 删除端口
firewall-cmd --zone=public --remove-port=5672/tcp --permanent

# 重新加载配置
firewall-cmd --reload

# 查看所有打开的端口
firewall-cmd --zone=public --list-ports

# 没有做任何配置，default zone和active zone都应该是public
firewall-cmd --get-default-zone
firewall-cmd --get-active-zones

# 启动防火墙
systemctl start firewalld

# 停止防火墙
systemctl stop firewalld

# 开机关闭或开启防火墙
systemctl disable firewalld
systemctl enable firewalld
```

### iptables

#### 系统命令

```sh
# 1.查看iptables状态
service iptables status

# 2.开启/关闭iptables
service iptables start
service iptables stop

# 3.查看iptables是否开机启动
chkconfig iptables --list

# 4.设置iptables开机启动/不启动
chkconfig iptables on
chkconfig iptables off
```

#### iptables命令

1. 查看当前iptables状态

   ```sh
   # 默认查看filter表的状态，如果需要查看其他表的状态加上 -t 表名
   iptables -nL 
   # 可以列出序列号，在插入或者删除的时候就不用自己去数了
   iptables -nL --line-numbers 
   # 可以查看到包过滤的流量统计，访问次数等
   iptables -nL --line-numbers --verbose 
   
   iptables --list
   ```

2. 插入一条记录

   ```sh
   # 在第一条的位置插入一条记录，接受所有来自lo网口的访问
   iptables -I INPUT 1 -i lo -j ACCPET 
   # 如果在INPUT中不指明在第几条插入，默认就是在第一条插入
   iptables -I INPUT 2 -s 192.168.1.0/24 -j ACCPET 
   ```

3. 追加一条记录

   ```sh
   # 在INPUT最后追加一条记录。
   iptables -A INPUT -s 192.168.2.0/24 -j ACCEPT 
   ```

4. 删除一条记录

   ```sh
   iptables -D INPUT 7 # 删除第7条记录
   ```

5. 针对协议开放

   ```sh
   iptables -I INPUT -p imcp -j ACCEPT
   ```

6. 针对端口开放（需要指明协议）

   ```sh
   iptables -I INPUT -p tcp --dport 22 -j ACCEPT
   ```

7. 限制ip端口访问

   ```sh
   iptables -I INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCPET
   ```

8. 拒绝所有访问

   ```
   # 这个一般放到最后，不然会对前面的规则造成影响。
   iptables -A INPUT -j DROP 
   ```

9. 根据时段限制访问

   ```
   # 这里的时间是指UTC时间记得换算
   iptables -A INPUT -p tcp -m time --timestart 00:00 --timestop 02:00 -j DROP 
   ```

10. 限制单个IP一分钟内建立的连接数

    ```
    iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 25 -j REJECT
    ```

11. 保存iptables规则的保存和恢复

    ```
    iptables-save > /etc/sysconfig/iptables
    iptables-restore < /etc/sysconfig/iptables
    ```

12. 对外建立的连接经过INPUT不拦截

    ```
    iptables -I INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ```

13. 端口转发（本机8080转发到远程192.168.1.22:80）

    ```
    iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 8080 -j DNAT --to 192.168.1.22:80
    iptables -t nat -A POSTROUTING -j MASQUERADE
    # 需要打开网转发
    echo 1 > /proc/sys/net/ipv4/ip_forward 
    iptables -t filter FORWARD -d 192.168.1.22/32 -j ACCEPT # 转发的FROWARD要允许双方的数据传输
    iptables -t filter FORWARD -s 192.168.1.22/32 -j ACCEPT
    ```

    

### firewalld换成iptables

```sh
#查看firewalld是否启用
systemctl status firewalld

#停止firewalld
systemctl stop firewalld

#禁用firewalld（否则重启系统后会再次启动）
systemctl disable firewalld

#查看是否安装iptables
yum list installed | grep iptables-services

#如果没安装则安装下
yum install iptables-services -y

#重启iptables
systemctl restart iptables

#设置开机自启
systemctl enable iptables

#重启docker
systemctl restart docker
```

### ufw

[Ubuntu20.04防火墙设置(简易教程)](https://blog.csdn.net/weixin_42171170/article/details/106957543)

Ubuntu一款轻量化的工具，主要用于对输入输出的流量进行监控

```sh
# 安装
sudo apt install ufw

# 查看状态
sudo ufw status verbose

# 开启/关闭防火墙
sudo ufw enable | disable

# 设置默认访问策略
sudo ufw default deny

# 开放 | 关闭 服务
sudo ufw allow | deny [service]

# 允许外部访问 80 端口(tcp/udp)
sudo ufw allow 80

# 允许外部访问 80 端口(svn)
sudo ufw allow 3690

# 允许此IP访问本机所有端口
sudo ufw allow from 192.168.1.111

# 允许指定的IP段访问特定端口
sudo ufw allow proto tcp from 192.168.0.0/24 to any port 22

# 删除存在的某条规则，比如删除svn端口就是
sudo ufw delete allow/deny 3690
```

## Ctrl 键组合

> [linux下的ctrl快捷键使用](https://blog.csdn.net/qq_36663951/article/details/79928439)

1. 调整光标位置

- Ctrl + a # 光标跳到行首
- Ctrl + e # 光标移到行尾

2. 历史记录

- Ctrl + r # 搜索之前打过的历史记录中的命令。重复这个快捷键就会继续向前找，直到找不到
- Ctrl + p # 是 recall 上一条历史记录中的命令，即重复上一次命令，同“↑”键
- Ctrl + n # 是 recall 下一条历史记录中的命令，同“↓”键

3. 操作字符

- Ctrl + d # 删除提示符后一个字符或 exit 或 logout
- Ctrl + k # 清除**光标至行尾**的所有内容
- Ctrl + u # 清除**光标至行首**的所有内容
- Ctrl + w # 删除**光标前**的一个单词
- Ctrl + t # 交换光标位置前的两个字符
- Ctrl + y # 粘贴或者恢复上次的删除

4. 操作进程

- Ctrl + c # 杀死当前进程
- Ctrl + z # 把当前进程转到后台运行，使用`fg`命令恢复。比如top-d1 然后`Ctrl + z`，到后台，然后`fg`,重新恢复

5. 其他

- Ctrl + l # 清屏，相当于clear
- Ctrl + x # 重新回到原位置

## SELinux

SELinux（Security-Enhanced Linux）是一种安全增强型的Linux内核安全模块，主要由美国国家安全局开发。它通过严格的访问控制机制来增强系统的安全性。SELinux实现了强制访问控制（Mandatory Access Control, MAC），每个进程和系统资源都有一个特殊的安全标签称为SELinux上下文，这些上下文抽象化了系统级别的细节，专注于实体的安全属性。

然而，尽管SELinux提供了额外的安全性，但在实际应用中，它可能会带来一些问题。首先，SELinux的配置和管理相对复杂，有些用户可能会发现它导致他们访问某些文件或应用程序时遇到了麻烦。此外，SELinux可能会与某些应用程序不兼容，或者在调试过程中造成困扰。例如，在搭建Kubernetes集群时，SELinux的安全机制可能会与K8S本身的流量机制冲突，因为K8S会在netfilter里设置流量规则，这可能会干扰正常运行。

因此，很多人在搭建集群时选择禁用SELinux，以确保系统能够正常运行并避免潜在的兼容性问题。禁用SELinux可以通过修改/etc/selinux/config文件，将SELINUX=enforcing更改为SELINUX=disabled来实现。

## Linux网络

### 子网掩码以及网段

#### 172.17.0.0/16和172.17.0.0/24有什么区别

172.17.0.0/16和172.17.0.0/24的区别主要体现在**子网掩码和可用IP地址范围**上。

1. **子网掩码**：
   - 172.17.0.0/16的子网掩码是255.255.240（即11111111.11111111.11110000.00000000）。
   - 172.17.0.0/24的子网掩码是255.255.255.0（即11111111.11111111.11111111.00000000）。
2. **网络前缀位数**：
   - /16表示网络前缀占用了16位，剩下的16位用于主机号。
   - /24表示网络前缀占用了24位，剩下的8位用于主机号。
3. **可用IP地址范围**：
   - 172.17.0.0/16可以使用的IP地址范围是从172.17.0.0到172.17.255.255，共有65536个IP地址。
   - 172.17.0.0/24可以使用的IP地址范围是从172.17.0.0到172.17.255.255，共有256个IP地址。
4. **子网划分能力**：
   - /16的网络可以划分成多个子网，每个子网的大小取决于具体的子网掩码。例如，可以将其划分为32个/24的子网。
   - /24的网络本身就是一个较小的子网，不需要进一步划分。

172.17.0.0/16和172.17.0.0/24的主要区别在于子网掩码、网络前缀位数以及可用IP地址范围。/16提供了更大的地址空间和更灵活的子网划分能力，而/24则是一个较小且简单的网络。

# SSH终端

## 常用操作

[Linux 创建新的用户并设置密钥SSH远程登录](https://blog.csdn.net/qq_15504597/article/details/82839414)

[docker安装jenkins，使用pipleline流水线部署项目](https://blog.csdn.net/qq_36783142/article/details/103727334)

### SSH链接保活

在学习使用Linux的过程中，避免不了长时间使用SSH，而连接长时间不用就会断开，解决办法如下

#### Win10命令行连接

Win10本地编辑用户目录下的目录`~/.ssh/config`，在其中添加如下两个配置：

```sh
ServerAliveInterval 60
ServerAliveCountMax 1440
```

#### MobaXTerm

在设置中进行调整：Setting → Configuration → SSH → SSH Setting

勾选：SSH keepalive

### 命令提示符

> 将 `[root@k8s-master ~]#`修改成`[root@k8s-master ~]$`

在 CentOS 7.9 中，命令提示符的默认设置是 `#` 表示 root 用户，而 `$` 表示普通用户。如果你想要永久性地修改 root 用户的命令提示符，你需要修改 Bash 的配置文件。

对于 root 用户，你可以修改 `/root/.bashrc` 文件。对于普通用户，你则需要修改 `/home/username/.bashrc` 文件，其中 `username` 是你的用户名。

以下是修改 root 用户命令提示符的步骤：

1. 打开 `/root/.bashrc` 文件进行编辑。你可以使用文本编辑器，如 `vi` 或 `nano`：

   ```sh
   vi /root/.bashrc
   ```

2. 找到 `PS1` 变量的定义行。通常它看起来像这样：

   ```sh
   #!/bin/bash
   
   # Script file path
   script_path=$(readlink -f "$0")
   script_dir=$(dirname "$script_path")
   
   # Function to set the prompt
   set_prompt() {
       # Check if PS1 is already defined
       if grep -q 'PS1=' /root/.bashrc; then
           # If PS1 is already defined, modify its value
           sed -i '/PS1=/c\PS1="[\\u@\\h \\W]\\$ "' /root/.bashrc
       else
           # If PS1 does not exist, add a new PS1 definition
           echo 'export PS1="[\\u@\\h \\W]\\$ "' >> /root/.bashrc
       fi
   }
   
   # Call the function to set the prompt
   set_prompt
   
   # Make the changes take effect immediately
   source /root/.bashrc
   ```

## 相关命令

1. ssh：交互式连接主机

   - 连接远程主机：`ssh root@47.120.43.14`
   - 连接成功之后执行命令：`ssh root@47.120.43.14 ip a`

2. sshpass：非交互式连接主机：连接前指定密码，避免交互式输入密码

   - 连接远程主机：`sshpass -p "123" ssh root@47.120.43.14`

   - 连接成功之后执行命令：

     `````sh
     $ sshpass -p "123" ssh root@47.120.43.14 touch /root/new
     $ sshpass -p "123" scp expect.sh root@47.120.43.14:/root
     $ sshpass -p "123" ssh root@47.120.43.14 sh /root/expect.sh
     `````

     

## 常见SSH终端

### Electerm

完全开源免费

### MobaXTerm

MobaXterm确实有收费版本，但同时也提供免费版本供个人和非商业用途使用

功能比较强大

### WindTerm

> 官网地址：https://kingtoolbox.github.io/
>
> 开源地址：https://github.com/kingToolbox/WindTerm

## 报错汇总

ssh指纹变了就会产生警告：WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!

解决：删除该主机的指纹信息即可：

vi /root/.ssh/known hosts

# Linux的NameSpace

> Linux中的NameSpace就是对应领域的一个独立的隔离的空间
>
> 比如Network NameSpace，就是网络的隔离独立的空间

<img src="Linux.assets/image-20240516221558788.png" alt="image-20240516221558788" style="zoom:50%;" />

## Network NameSpace

> 每个容器的网络命名空间给这个容器提供了独立的网络

```bash
# 查看本机的网络命名空间列表
$ ip netns list

# 删除
$ ip netns delete <ns-name>

# 新建
$ ip netns add <ns-name>

# 查看新建网络命名空间的网络信息
$ ip netns exec <ns-name> ip a

# 启动默认关闭的网络空间网卡
$ ip netns exec <ns-name> ip link set dev lo up
```

### 实战

> 创建两个NS，实现两个NS的网络互联互通
>
> <img src="Linux.assets/image-20240516132836063.png" alt="image-20240516132836063" style="zoom:50%;" />

```sh
# 创建两个命名空间
$ ip netns add ns-test1
$ ip netns add ns-test2

# host创建两个成对的veth
$ ip link add veth-peer1 type veth peer name veth-peer2

# 测试创建。多了往两个：veth-peer1 和 veth-peer2
$ ip link

# 检查ns-test1的网卡，目前只有一个lo
$ ip netns exec ns-test1 ip link

# 将veth-peer1添加到 ns-test1
$ ip link set veth-peer1 netns ns-test1

# 再次检查ns-test1的网卡，目前有lo和veth-peer1
$ ip netns exec ns-test1 ip link

# 同样的操作，将veth-peer2添加到 ns-test2
$ ip link set veth-peer2 netns ns-test2

# 分别给veth-peer1和veth-peer2分配IP
$ ip netns exec ns-test1 ip addr add 192.168.1.1/24 dev veth-peer1
$ ip netns exec ns-test2 ip addr add 192.168.1.2/24 dev veth-peer2

# 启动两个端口
$ ip netns exec ns-test1 ip link set dev veth-peer1 up
$ ip netns exec ns-test2 ip link set dev veth-peer2 up

# 检查两个端口的状态
$ ip netns exec ns-test1 ip link
$ ip netns exec ns-test2 ip link

# 查看两个端口的IP，IP都已经分配
$ ip netns exec ns-test1 ip a
$ ip netns exec ns-test2 ip a

# 两个IP互ping
$ ip netns exec ns-test1 ping 192.168.1.2
$ ip netns exec ns-test2 ping 192.168.1.1
```



# Shell编程

## echo

1. 启用转义符，请使用：`echo -e "<content>"`

   ```sh
   func_line_break() {
   	echo -e "\n"
   }
   ```

2. 不输出换行符，请使用：`echo -n "<content>"`

## 变量

[linux中()、\[\]、{}、(())、\[\[\\]\]等各种括号的使用](https://www.cnblogs.com/my-first-blog-lgz/p/13390430.html)

### 变量的定义

```sh
let sum=2+3
echo $sum
```

### $变量的引用符号

1. \${a} 变量a的值, 在不引起歧义的情况下可以省略大括号。
2. \$(cmd) 命令替换，和`cmd`效果相同，结果为shell命令cmd的输，不过某些Shell版本不支持$()形式的命令替换, 如tcsh。
3. \$((expression)) 和`exprexpression`效果相同, **计算数学表达式exp的数值**。 其中exp只要符合C语言的运算规则即可, 甚至三目运算符和逻辑表达式都可以计算。

### 变量的引用

在Shell脚本中，变量的作用域和生命周期是由它们被定义的位置决定的。在Shell中，有几种类型的变量：

1. 局部变量：在函数内部定义的变量，只在该函数内部有效。
2. 环境变量：使用`export`命令导出的变量，可以在子Shell中访问。
3. 位置参数：在Shell脚本中，`$1`, `$2`, `$3`等是位置参数，它们代表传递给脚本的参数。

下面我将提供几个脚本示例来演示这些变量在Shell、子Shell以及子Shell的子Shell中的行为。

#### 示例1：局部变量

```bash
#!/bin/bash

# 定义一个局部变量
local_var="local value"

# 定义一个函数，该函数打印局部变量的值
print_local_var() {
    echo "Local variable inside function: $local_var"
}

# 调用函数
print_local_var

# 尝试在子Shell中访问局部变量
(
    echo "Local variable in subshell: $local_var"
)

# 再次尝试在子Shell的子Shell中访问局部变量
(
    (
    		echo "Local variable in sub-subshell: $local_var"
    )
)
```

输出：
```
[root@localhost ~]# ./test.sh
Local variable inside function: local value
Local variable in subshell: local value
Local variable in sub-subshell: local value
```

在这个脚本中，`local_var`是一个局部变量，它只在定义它的函数`print_local_var`内部有效。尝试在子Shell和子Shell的子Shell中访问`local_var`将不会成功，因为它们不在该变量的作用域内。

#### 示例2：环境变量

```bash
#!/bin/bash

# 定义一个环境变量
export env_var="environment value"

# 定义一个函数，该函数打印环境变量的值
print_env_var() {
    echo "Environment variable inside function: $env_var"
}

# 调用函数
print_env_var

# 尝试在子Shell中访问环境变量
(
    echo "Environment variable in subshell: $env_var"
)

# 再次尝试在子Shell的子Shell中访问环境变量
(
    (
        echo "Environment variable in sub-subshell: $env_var"
    )
)
```

输出：

```
[root@localhost ~]# ./test.sh
Environment variable inside function: environment value
Environment variable in subshell: environment value
Environment variable in sub-subshell: environment value
```

在这个脚本中，`env_var`是一个环境变量，它通过`export`命令导出，因此可以在子Shell和子Shell的子Shell中访问。

#### 示例3：位置变量参数

```bash
#!/bin/bash

# 打印脚本的第一个位置参数
echo "First positional parameter: $1"

# 尝试在子Shell中访问位置参数
(
    echo "First positional parameter in subshell: $1"
)

# 再次尝试在子Shell的子Shell中访问位置参数
(
    echo "First positional parameter in sub-subshell: $1"
)
```

在这个脚本中，`$1`是脚本的第一个位置参数。它在脚本、子Shell以及子Shell的子Shell中都是有效的。

**注意事项**

- 在子Shell中，环境变量是可见的，因为它们是从父Shell继承的。
- 局部变量只在定义它们的函数或脚本中可见。
- 位置参数在脚本和所有子Shell中都是可见的，因为它们是传递给脚本的参数。

要运行这些脚本，你需要将它们保存到文件中，给予执行权限（使用`chmod +x scriptname.sh`），然后通过Shell执行它们。例如：

```bash
./scriptname.sh arg1 arg2
```

这将运行脚本，并将`arg1`和`arg2`作为位置参数传递给脚本。

#### 查看服务器运行状态

```sh
#!/bin/bash

ip=192.168.1.100

ping -c1 $ip &> /dev/null && echo "$ip is Up." || echo "$ip is Down."
```

### 交互式变量

> read函数从键盘读入变量值，使用方法如下，执行完成后，用户输入的字符串就会存放在变量`<variable>`中
>
> `read -p "<string to print>" <variable>`

```sh
#!/bin/bash

read -p "请输入您要测试的IP：" ip

ping -c1 $ip &> /dev/null && echo "$ip is Up." || echo "$ip is Down."
```

### 环境变量

```sh
export key=value
key1=value
export key1
```

变量的作用域：当前shell以及子shell

想要使某个变量在当前用户登录后一直生效，可放在`~/.bash_profile`中

想要使某个变量在所有用户登录后一直生效，可放在`/etc/profile`中

### 环境变量的可见性

[父子进程中变量可见性](https://ke.qq.com/webcourse/index.html#cid=398381&term_id=100475149&taid=3385546626176045&type=1024&vid=5285890793680196340)

在Linux中，父进程和子进程变量的修改对方是看不到的，基于内核级别的copy-on-write

```sh
$ name=sange
$ echo $name
sange
$ /bin/bash
$ echo $name
#此处无输出
$ exit
exit
$ export name # 之后开启的进程就能读取到这变量
$ /bin/bash
$ echo $name
sange
$ { echo "sange"; echo "maozi"; } # 代码块，同一个代码块的指令在同一个进程中执行
sange
maozi
```

### Linux预定义变量

```sh
$$ #父进程ID
$BASHPID #当前进程ID
$# #是传给脚本的参数个数
$@ #是传给脚本的所有参数的列表
$* #是以一个单字符串显示所有向脚本传递的参数，与位置变量不同，参数可超过9个
$$ #是脚本运行的当前PID
$? #是显示最后命令的退出状态，0表示没有错误，其他表示有错误

$0 #是脚本本身的名字
$1 #是传递给该shell脚本的第一个参数
$2 #是传递给该shell脚本的第二个参数

$"
表示多行文本
"
```

```sh
echo $$ | more #显示父进程的PID，因为$$的优先级大于管道的优先级
echo $BASHPID | more #显示子进程的PID，因为$BASHPID的优先级小于管道的优先级
```

```sh
#!/bin/bash
echo -n "平均成绩是:
echo "($1 + $2)/2" | bc
```

```sh
#!/bin/bash

echo "程序的名字是: $0"
echo "用户输入的第1参数是: $1"
echo "用户输入的第2参数是: $2"
echo "该程序携带的所有参数是: $*"
echo "该程序携带的参数个数是: $#"
echo "该程序的进程号是: $$"
sleep 999
```



## 变量的运算

### 整数的运算

1. expr

   ```sh
   #!/bin/bash
   read -p "请输入您的第一门成绩:" number1
   read -p "请输入您的第二门成绩:" number2
   echo -n "总成绩是:
   echo $number1 + $number2
   ```

2. $(())

   ```sh
   echo $((2**3)) # 输出2的三次方
   ```

3. $[]

   ```sh
   echo $[2**3] # 输出2的三次方
   ```

### 小数的运算

使用工具bc解决

```sh
#!/bin/bash
read -p "请输入您的第一门成绩:" number1
read -p "请输入您的第二门成绩:" number2
echo -n "平均成绩是:
echo "($number1 + $number2)/2" | bc
```

## 字符串

> [shell中字符串的处理_kerongw的博客-shell字符串处理](https://blog.csdn.net/qq_43469158/article/details/117756634)

### 字符串类型

| 字符串类型                                                 | 区别                                                         |
| ---------------------------------------------------------- | ------------------------------------------------------------ |
| 单引号 `'string'`                                          | 强引用，任何字符都会原样输出，其中的变量无效                 |
| <span style="white-space:nowrap;">双引号 `"string"`</span> | 弱引用，如果字符串中包含变量，该变量会被解析(得到变量的值)，而不是原样输出 |
| 点引号 `` `string` ``                                      | 内容会被当做Shell命令执行                                    |
| 无引号 `string`                                            | 不被引号包围的字符串中出现变量也会被解析，这一点和双引号包围的字符串一样，字符串中不能出现空格，否则空格后面的字符串会被其他命令或解析 |

### 长度

`${#string_name}`

### 拼接

```shell
str1=www
str2=bilibili

string1=$str1$str2              #中间不加别的，直接放一起
string2="$str1 $str2"           #双引号括住，中间可加任意字串
string3=$str1"..."$str2         #整体不加引号，若中间要出现别的字串需前后紧挨，且字串双引号括住
string4="${str1}.${str2}.com"   #也可以使用${}方式引用变量

echo $string1
echo $string2
echo $string3
echo $string4
————————————————————————————————————————————————————————————————
运行结果：
wwwbilibili
www bilibili
www...bilibili
www.bilibili.com
```

### 截取

1. 指定位置开始你截取：**不管从那边计数，截取方向都是从左到右**

   | 方式               | 格式                       | 说明                                                         | 备注 |
   | ------------------ | -------------------------- | ------------------------------------------------------------ | ---- |
   | 字符串左边开始计数 | `${string:start:length}`   | string：要截取的字符串。<br/>start：截取的起始位置(计数从0开始)<br/>length：要截取的长度，省略截取到末尾 |      |
   | 字符串右边开始计数 | `${string:0-start:length}` | string：要截取的字符串。<br/>start：截取的位置(计数起始数字是1)。length：要截取的长度，省略截取到末尾 |      |

   ```sh
   url="www.bilibili.com"
   echo ${url:0:4}		#输出：www.
   string=${url:4:8}	#string=bilibili
   string=${url:4}		#从左边第4个字符截取到末尾string="bilibili.com"
   
   
   url="https://www.bilibili.com/"
   echo ${url:0-4:3}	#从右边第4个开始，截取3个。输出：com
   echo ${url:0-13}	#从右边第13个开始，截取到末尾。输出：bilibili.com/
   ```

   

2. 指定字符开始截取

   | 方式                | 格式                | 说明                                                         | 备注                              |
   | ------------------- | ------------------- | ------------------------------------------------------------ | --------------------------------- |
   | `#`号截取右边字符串 | `${string#*chars}`  | string要截取的字符串。<br/>chars指定的字符(字串)。<br/>`*`通配符，表示任意长度的字符串。<br/>`*chars`连起来表示忽略左边的所有字符，直到遇到第一个chars | 删掉第一个chars及其左边的字符串   |
   |                     | `${string##*chars}` | string要截取的字符串。<br/>chars指定的字符(字串)。<br/>`*`通配符，表示任意长度的字符串。<br/>`*chars`连起来表示忽略左边的所有字符，直到遇到最后一个chars | 删掉最后一个chars及其左边的字符串 |
   | `%`号截取左边字符串 | `${string%chars*}`  | string要截取的字符串。<br/>chars指定的字符(字串)。<br/>`*`通配符，表示任意长度的字符串。<br/>`chars*`表示忽略最后一个chars右边的所有字符。 | 删掉最后一个chars及其右边的字符串 |
   |                     | `${string%%*chars}` | string要截取的字符串。<br/>chars指定的字符(字串)。<br/>`*`通配符，表示任意长度的字符串。<br/>`*chars`表示忽略第一个chars右边的所有字符 | 删掉第一个chars及其右边的字符串   |

   ```sh
   string="https://www.bilibili.com/mainline/hehe.xml"
   str1=${string#*/}		#删掉第一个/及其左边的字串
   str2=${string#*www.}	#删掉第一个www.及其坐标的字串
   str3=${string##*/}		#删掉最后一个/及其左边的字字串
   ___________________________________________________
   结果：
   /www.bilibili.com/mainline/hehe.xml
   bilibili.com/mainline/hehe.xml
   hehe.xml
   
   
   string="https://www.bilibili.com/www//w/x"
   str1=${string%%/*}	#删掉第一个/及其右边的字串
   str2=${string%i*}	#删掉最后一个i及其右边的字串
   ___________________________________________
   结果：
   https:
   https://www.bilibil
   ```

## cat/tee追加文本

cat追加文本有两种形式：

1. 忽略追加文本每行的空格和制表符缩进，请使用以下这种形式

   ```sh
   cat >> ./test << EOF
       Hello, World!
   EOF
   ```

   输出是：

   ```
   Hello, World!
   ```

2. 保留追加文本每行的空格和制表符缩进，请使用以下这种形式

   ```sh
   cat >> ./test <<- EOF
       Hello, World!
   EOF
   ```

   输出是：

   ```
       Hello, World!
   ```

## if 参数

| 参数                                                         | 描述                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [ -a \<file\> ]                                              | 如果 \<file\> 存在则为真。                                   |
| [ -b \<file\> ]                                              | 如果 \<file\> 存在且是一个**块**特殊文件则为真。             |
| [ -c \<file\> ]                                              | 如果 \<file\> 存在且是一个**字**特殊文件则为真。             |
| [ -d \<file\> ]                                              | 如果 \<file\> 存在且是一个**目录**则为真。                   |
| [ -e \<file\> ]                                              | 如果 \<file\> 存在则为真。                                   |
| [ -f \<file\> ]                                              | 如果 \<file\> 存在且是一个普通文件则为真。                   |
| [ -g \<file\> ]                                              | 如果 \<file\> 存在且已经设置了SGID则为真。                   |
| [ -h \<file\> ]                                              | 如果 \<file\> 存在且是一个符号连接则为真。                   |
| [ -k \<file\> ]                                              | 如果 \<file\> 存在且已经设置了粘制位则为真。                 |
| [ -p \<file\> ]                                              | 如果 \<file\> 存在且是一个名字管道(F如果O)则为真。           |
| [ -r \<file\> ]                                              | 如果 \<file\> 存在且是可读的则为真。                         |
| [ -s \<file\> ]                                              | 如果 \<file\> 存在且大小不为0则为真。                        |
| [ -t FD ]                                                    | 如果文件描述符 FD 打开且指向一个终端则为真。                 |
| [ -u \<file\> ]                                              | 如果 \<file\> 存在且设置了SUID (set user ID)则为真。         |
| [ -w \<file\> ]                                              | 如果 \<file\> 如果 \<file\> 存在且是可写的则为真。           |
| [ -x \<file\> ]                                              | 如果 \<file\> 存在且是可执行的则为真。                       |
| [ -O \<file\> ]                                              | 如果 \<file\> 存在且属有效用户ID则为真。                     |
| [ -G \<file\> ]                                              | 如果 \<file\> 存在且属有效用户组则为真。                     |
| [ -L \<file\> ]                                              | 如果 \<file\> 存在且是一个符号连接则为真。                   |
| [ -N \<file\> ]                                              | 如果 \<file\> 存在 and has been mod如果ied since it was last read则为真。 |
| [ -S \<file\> ]                                              | 如果 \<file\> 存在且是一个套接字则为真。                     |
| <span style="white-space:nowrap;">[ -o OPTIONNAME ]</span>   | 如果 shell选项 “OPTIONNAME” 开启则为真。                     |
| [ -z STRING ]                                                | 用来判断字符串长度是否为零。常见的场景：判断脚本是否**不带参数** |
| [ -n STRING ]                                                | 用来判断字符串长度是否**非零**，常见的场景：判断脚本是否**带有参数** |
| <span style="white-space:nowrap;">[ CONDITION1 -o CONDITION2 ]</span> | CONDITION1成立或者CONDITION2成立                             |
| [ CONDITION1 -a CONDITION2 ]                                 | CONDITION1成立并且CONDITION2成立                             |
| [ \<file\>1 -nt \<file\>2 ]                                  | 如果 \<file\>1 has been changed more recently than \<file\>2, or 如果 \<file\>1 exists and \<file\>2 does not则为真。 |
| [ \<file\>1 -ot \<file\>2 ]                                  | 如果 \<file\>1 比 \<file\>2 要老, 或者 \<file\>2 存在且 \<file\>1 不存在则为真。 |
| [ \<file\>1 -ef \<file\>2 ]                                  | 如果 \<file\>1 和 \<file\>2 指向相同的设备和节点号则为真。   |
| <span style="white-space:nowrap;">[ STRING1 == STRING2 ]</span> | 如果2个字符串相同。 “=” may be used instead of “==” for strict POSIX compliance则为真。 |
| [ STRING1 != STRING2 ]                                       | 如果字符串不相等则为真。                                     |
| [ STRING1 < STRING2 ]                                        | 如果 “STRING1” sorts before “STRING2” lexicographically in the current locale则为真。 |
| [ STRING1 > STRING2 ]                                        | 如果 “STRING1” sorts after “STRING2” lexicographically in the current locale则为真。 |
| [ ARG1 OP ARG2 ]                                             | “**OP**” is one of `-eq`, `-ne`, `-lt`, `-le`, `-gt` or `-ge`.<br/>These arithmetic binary operators return true if “ARG1” is equal to, not equal to, less than, less than or equal to, greater than, or greater than or equal to “ARG2”, respectively. “ARG1” and “ARG2” are integers. |

## Shell中的数组和字典

### 数组

```sh
# 声明数组：这部可以省略
declare -a list

# 初始化数组：使用空格分隔
list=(v1 v2 v3)

# 获取数组长度，计算元素数量
echo ${#list[*]}
echo ${#list[@]}
# 计算非空元素的数量
echo ${#list}

# 添加元素
list+=("v4")
list=( "${list[@]}" "v5" )

# 删除元素
unset list[0]
list=( "${list[@]:1}" )

# 数组切片：返回从第二个元素开始到第四个元素的子集
list=( "${list[@]:1:2}" )


# 按照索引名获取对应的值
echo ${list[0]}

# 获取所有元素
echo ${list[*]}
echo ${list[@]}

# 遍历
for value in ${list[*]}; do
	echo $value
done
```

### 字典

```sh
# 定义关联数组，即字典
declare -A dict

# 初始化键值对
dict=([key1]="value1" [key2]="value2")
dict=(key1=value1 key2=value2)

# 添加键值/修改键值对
dict[key3]=value3

# 访问键值
echo ${dict["key1"]}

# 获取所有键
echo ${!dict[*]}
echo ${!dict[@]}

# 获取所有值
echo ${dict[*]}
echo ${dict[@]}

# 遍历
for key in ${!dict[@]} ; do
    echo "Key: $key, Value: ${dict[$key]}"
done
```

## 代码块

`{}`在当前进程执行的代码块，遇到管道就在子进程执行

`()`在子进程执行的代码块

## 父子进程

```sh
# 请高亮2079查看进程关系
$ echo $$
2079
$ /bin/bash # 开启子进程
$ echo $$
2124
$ pstree # 打印获取进程树
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─...
        ├─sshd───sshd─┬─bash───bash───pstree
        │             └─sftp-server
        ├─...
        └─vmtoolsd───{vmtoolsd}
$ ps -ef | grep 2079
root       2079   2075  0 Aug22 pts/0    00:00:00 -bash
root       2124   2079  0 00:00 pts/0    00:00:00 /bin/bash
root       2172   2124  0 00:05 pts/0    00:00:00 grep --color=auto 2079
```

## 管道 pipline

管道符：`|`

管道：管道前命令的输出作为管道后命令的输入

管道机制：

- 解释执行
- 读入一行指令，如果指令中包含管道符`|`，就分别给管道前后的指令开启两个进程，并把前面进程的结果输出作为后面进程的输入
- [Linux 管道文件](https://blog.csdn.net/shenwansangz/article/details/44116681)

```sh
# 打印文件前3行，默认10行
head -3 test.txt

# 打印文件后3行，默认10行
tail -3 test.txt

# 打印文件第5行
head -5 test.txt | tail -1
```

管道和代码块结合：

```sh
$ echo $$
2079
$ num=1
$ echo $num
1
$ { a=9; echo "sange"; } | cat
sange
$ echo $num
1
$ { echo $BASHPID; read x; } | { cat; echo $BASHPID; read y; }
2288
# 程序阻塞在这里
########################### 新开连接到这台机器 #######################
$ ps -ef | grep 2079 # 2079这个进程派生出两个子进程：2288和2289
root       2079   2075  0 Aug22 pts/0    00:00:00 -bash
root       2288   2079  0 00:42 pts/0    00:00:00 -bash
root       2289   2079  0 00:42 pts/0    00:00:00 -bash
root       2292   2255  0 00:43 pts/1    00:00:00 grep --color=auto 2079
$ ll /proc/2288/fd
total 0
lrwx------. 1 root root 64 Aug 23 00:44 0 -> /dev/pts/0
l-wx------. 1 root root 64 Aug 23 00:44 1 -> pipe:[35860] # 2288的 输出 指向一个管道
lrwx------. 1 root root 64 Aug 23 00:43 2 -> /dev/pts/0
lrwx------. 1 root root 64 Aug 23 00:44 255 -> /dev/pts/0
$ ll /proc/2289/fd
total 0
lr-x------. 1 root root 64 Aug 23 00:45 0 -> pipe:[35860] # 2289的 输入 指向一个管道
lrwx------. 1 root root 64 Aug 23 00:45 1 -> /dev/pts/0
lrwx------. 1 root root 64 Aug 23 00:43 2 -> /dev/pts/0
lrwx------. 1 root root 64 Aug 23 00:45 255 -> /dev/pts/0
$ lsof -op 2288
COMMAND  PID USER   FD   TYPE DEVICE OFFSET     NODE NAME
...
bash    2288 root    1w  FIFO    0,9    0t0    35860 pipe # 2288的 管道 是一个 FIFO 的写管道
...
$ lsof -op 2289
COMMAND  PID USER   FD   TYPE DEVICE OFFSET     NODE NAME
...
bash    2289 root    0r  FIFO    0,9    0t0    35860 pipe # 2289的 管道 是一个 FIFO 的读管道
...
```

注意事项

- 管道会触发当前的进程创建一个子进程

## 重定向机制

**基本重定向符**

- 基本输入重定向：`<`

- 基本输出重定向：`>`

**组合重定向符**

- 标准输入重定向符：`0<`
- 标准输出重定向符：`1>`
- 标准错误输出重定向符：`2>`

**通用案例**

- 修改一个程序`<exec>`的标准输入为`<file>`：`<exec> 0< <file>`

- 修改一个程序`<exec>`的标准输出为`<file>`：`<exec> 1> <file>`

- 同时修改一个程序`<exec>`的标准输入为`<file1>`，标准输出为`<file2>`：`<exec> 0< <file1> 1> <file2>`

- 修改标准错误输出`2>`同理

**注意事项**

1. `0<`和`1>`中间不能有空白符

2. 如果重定向描述符右边不是一个`<file>`，而是一个fd，请在`重定向符`右边添加一个`&`，同样不能有空格，如：

   ```sh
   # 注意：前后的顺序不能修改
   ls ./ 1> ls.out 2>& 1
   ```

## 多行写入文件

### 覆盖写入

```sh
#!/bin/bash

echo "Mutil-line write to file in shell"
cat>test.txt<<EOF
这是一个由shell创建的文件
this is a file created by shell.
we want to make a good world.
EOF
```

1. `<<EOF` 表示当遇到EOF时结束输入，`cat>test.txt<<EOF` 这中间没有空格
2. 生成文件名和`EOF`中的内容，均支持变量
3. 追加写入`test.txt`文件，可使用`cat>>test<<EOF`

## 当前时间

1. 原格式输出：`2018年 09月 30日 星期日 15:55:15 CST`

   ```sh
   time1=$(date)
   echo $time1
   ```

2. 时间串输出：`2018-09-30 15:55:15`

   ```sh
   #!bin/bash
   time3=$(date "+%Y-%m-%d %H:%M:%S")
   echo $time3
   ```

## 脚本的相互调用

脚本之间的调用常有三种方式：

1. **直接调用/使用sh调用**，默认使用Shell执行：`./test.sh` / `sh ./test.sh`
   - 在一个shell脚本中直接执行另一个shell脚本
   - **优点**：简单易行，不需要额外的命令或工具。
   - **缺点**：被调用脚本会作为一个新的进程运行，可能会影响性能和资源使用。
2. **source调用**：`source ./test.sh`
   - 通过source命令将另一个脚本中的内容加载到当前shell环境中
   - **优点**：可以修改被调用的脚本并立即看到效果，适用于调试和快速修改。
   - **缺点**：如果被调用脚本较大，可能会导致当前shell环境变量过多，影响性能。
3. **exec调用**：
   - 通过exec命令替换当前进程，执行另一个脚本
   - **优点**：可以完全替换当前进程，释放原有的内存和文件描述符等资源。
   - **缺点**：如果被调用脚本有错误，整个脚本会因为错误而中断。
4. **expect自动交互**：
   - 使用expect工具实现脚本之间的自动交互。首先启动指定脚本或命令，然后匹配结果关键词，最后进行相应的操作
   - **优点**：适用于需要与系统进行交互的场景，如登录远程服务器、输入密码等。
   - **缺点**：实现复杂，需要编写额外的expect脚本来控制交互流程。
5. **IPC进程间通信**：
   - 通过管道、套接字等方式实现进程间的通信
   - **优点**：可以在不同进程之间传递数据，适用于复杂的系统架构。
   - **缺点**：实现复杂度较高，受网络性能等因素的影响。

**直接调用和利用sh都会创建新的进程**，从而使得脚本中的变量不影响当前shell；而利用**source则不会创建新的进程**，脚本中的变量会直接影响到当前shell。

## 命令行自动化：expect

> 具体的使用案例，请参考：QLNotes\Config\Scripts\Linux\Shell\AutoDeploy

### 安装

```sh
$ yum install -y expect
```

### 命令要素

#### 定义脚本执行的 shell

```sh
#!/usr/bin/expect
```

这里定义的是expect可执行文件的链接路径(或真实路
各径)，功能类似于bash 等shell 功能

#### 设置超时时间

```sh
set timeout 30
```

设置超时时间，单位是秒，如果设为timeout -1意为永不超时，默认10秒

#### spawn

spawn 是进入expect环境后才能执行的内部命令，不能直接在默认的 shell环境中进行执行
主要功能:传递交互指令

#### expect

这里的expect同样是expect的内部命令
主要功能:判断输出结果是否包含某项字符串，没有则立即返回，否则就等待一段时间后返回，等待时间通过 timeout 进行设置

#### send

执行交互动作，将交互要执行的动作进行输入给交互指令
命令字符串结尾要加上"r"，如果出现异常等待的状态可以进行核查，

#### interact

执行完后保持交互状态，把控制权交给控制台
如果不加这一项，交互完成会自动退出

#### exp_continue

继续执行接下来的交互操作

#### \$argv

expect 脚本可以接受从 bash传递过来的参数，可以使用[ lindex $argv n ]获得，n从0开始，分别表示第一个，第二个，第三个....参数

### 案例

#### SSH免密登录

```sh
#!/usr/bin/expect
# login_ssh.exp
set ipaddr "192.168.1.61"
set passwd "123456"
set timeout 30
spawn ssh root@$ipaddr
expect {
	"yes/no" { send "yes\r";exp_contine }
	"password:" { send "$passwd\r" }
}
interact
```

```sh
#!/usr/bin/expect
# login_ssh.exp
set ipaddr [ lindex $argv 0 ]
set user [ lindex $argv 1 ]
set passwd [ lindex $argv 2 ]
set timeout 30
spawn ssh $user@$ipaddr
expect {
	"yes/no" { send "yes\r";exp_contine }
	"password:" { send "$passwd\r" }
}
interact
```

```sh
#!/usr/bin/expect -f
set timeout 30
set pswd "123456"
spawn ssh -l root 192.168.1.61 -p cos7
expect "*password*"
send "$pswd\r"
interact
```

#### 批量传输文件

```sh
#!/usr/bin/expect
# 脚本的第一个位置参数
set ip [lindex $argv 0]
set user root
set password centos
set timeout 5
#把本地的目录及目录下的文件以$user这个用户批量复制到对方$ip主机上的/tmp目录下
spawn scp -r /etc/hosts $user@$ip:/tmp
expect {
	"yes/no" { send "yes\r"; exp_continue }
	"password:" { send "$password\r" }
}
#当看到eof时，事情做完后结束expect，脚本退出
expect eof
```

#### 批量传输公钥

```sh
#!/usr/bin/expect -d
set ip [ lindex $argv 0 ]
set pw [ lindex $argv 1 ]
set timeout 60
spawn ssh-copy-id $ip
expect {
  "*yes/no" { send "yes\r", exp_continue}
  #上面这行这行如果注释了，我们需要在/etc/ssh/ssh_config 将# `StrictHostKeyChecking ask`修改为`StrictHostKeyChecking no`
  "password:" { send "$pw\r" }
}
expect eof
```

#### ssh与expect融合

1. 单个示例

   ```sh
   #!/bin/bash
   user="root"
   host="47.120.43.14"
   password="123456"
   local_file="/root/expect.sh"
   remote_path="/root"
   
   /usr/bin/expect<< EOF
   # 使用scp命令将本地文件拷贝到远程机器上
   spawn scp $local_file $user@$host:$remote_path
   expect {
     "*yes/no" { send "yes\r"; exp_continue }
     "*password:" { send "$password\r" }
   }
   # 连接远程服务器并执行脚本
   spawn ssh $user@$host
   expect {
     "*yes/no" { send "yes\r"; exp_continue }
     "*password:" { send "$password\r" }
   }
   
   # 发送执行脚本命令
   expect "*#"
   send "sh $remote_path/expect.sh\r"
   
   # 发送退出命令
   expect "*#"
   send "exit\r"
   
   expect eof
   EOF
   ```

2. 批量操作

   ```sh
   #!/bin/bash
   user="root"
   password="Wm910312!@#"
   local_file="/root/expect.sh"
   remote_path="/root"
   hosts=("47.120.43.14""159.75.92.61") #主机地址列表
   
   for host in "${hosts[@]}"; do
     /usr/bin/expect << EOF
     # 使用 scp命令将本地文件拷贝到远程机器上
     spawn scp $local_file $user@$host:$remote_path
     expect {
       "*yes/no" { send "yes\r"; exp_continue }
       "*password:" { send "$password\r" }
     }
     # 连接远程服务器并执行脚本
     spawn ssh $user@$host
     expect {
       "*yes/no" { send "yes\r"; exp_continue }
       "*password:" { send "$password\r" }
     }
     # 发送执行脚本命令
     expect "*#"
     send "sh $remote_path/expect.sh\r"
     # 发送退出命令
     expect "*#"
     send "exit\r"
     expect eof
   EOF
   done
   ```

   

#### 其他

```sh
#!/bin/bash

#检查是否安装了expect 软件
rpm -q expect &>/dev/null
if [ $? -ne 0 ];then
  yum -y install expect
  if [ $? -eq 0 ];then
    echo "install success!"
  else
    echo "install fail !"
    exit 2
  fi
fi

#检查客户端是否生成了公钥和私钥
if[ ! -f ~/.ssh/id_rsa ];then
  ssh-keygen -P "" -f ~/.ssh/id_rsa
  if [ $? -eq 0 ];then
    echo "success!"
  else
    echo "fail !"
    exit 2
  fi
fi
```



## Shell颜色控制

```sh
# col.sh
# 颜色代码标识 \003 可以替换为 \E
# 多个 ANSI 控制码可同时使用,用分号(;)作为分隔符, 红底绿字闪烁:echo -e "\E[32;41;05mtest\E[0m"
echo "默认:黑色背景色(40),白色前景色(37),即:黑底白字"
echo
background_color=$"
字体背景颜色范围:40-49\n40:黑色
41:红色
42:绿色
43:黄色
44:蓝色
45:紫色
46:天蓝
47:白色\n示例代码如下:"
echo -e $background_color
echo -e "\033[40;37m_黑底　白字 \033[0m"
echo -e "\033[41;37m_红底　白字 \033[0m" 
echo -e "\033[42;37m_绿底　白字 \033[0m" 
echo -e "\033[43;37m_黄底　白字 \033[0m" 
echo -e "\033[44;37m_蓝底　白字 \033[0m" 
echo -e "\033[45;37m_紫底　白字 \033[0m" 
echo -e "\033[46;37m_天蓝底白字 \033[0m" 
echo -e "\033[47;30m_白底　黑字 \033[0m"

echo
foreground_color=$"
字体前景颜色范围:30-39\n30:黑色
31:红色
32:绿色
33:黄色
34:蓝色
35:紫色
36:天蓝
37:白色\n示例代码如下:"
echo -e $foreground_color
echo -e "\033[47;30m_白底黑字 \033[0m"
echo -e "\033[31m_红色字 \033[0m"
echo -e "\033[32m_绿色字 \033[0m" 
echo -e "\033[33m_黄色字 \033[0m" 
echo -e "\033[34m_蓝色字 \033[0m" 
echo -e "\033[35m_紫色字 \033[0m" 
echo -e "\033[36m_天蓝字 \033[0m" 
echo -e "\033[37m_白色字 \033[0m"
```

## Shell脚本调试

1. **使用`-n`选项**：
   `-n`选项允许你检查脚本中的语法错误而不实际执行脚本。这可以通过在命令行中使用`sh -n script.sh`来实现，或者在脚本的开头添加`#!/bin/sh -n`。

2. **使用`-v`选项**：
   `-v`选项会在执行脚本时将执行过的脚本命令打印到标准错误输出。这有助于查看脚本的执行过程，但不会显示变量的值。可以在命令行中使用`sh -v script.sh`，或者在脚本开头添加`#!/bin/sh -v`。

3. **使用`-x`选项**：
   `-x`选项提供跟踪执行信息，将执行的每一条命令和结果依次打印出来。这有助于查看脚本的执行过程和变量的值。可以在命令行中使用`sh -x script.sh`，或者在脚本开头添加`#!/bin/sh -x`。

4. **使用`set`命令**：
   在脚本中使用`set -x`和`set +x`可以分别启用和禁用`-x`选项，这样可以只对脚本中的某一段进行跟踪调试。例如：
   
   ```sh
   #!/bin/sh
   if [ -z "$1" ]; then
     set -x
     echo "ERROR: Insufficient Args."
     exit 1
   set +x
   ```
   
5. **使用`trap`命令**：
`trap`命令可以捕获和处理信号。在脚本中添加`trap`命令可以在接收到特定信号时执行一些操作，比如输出一些调试信息。例如：
   
   ```sh
trap 'echo "Received SIGINT signal"' SIGINT
   ```

6. **使用日志记录**：
   在脚本中添加日志记录代码，可以帮助开发者更好地理解脚本的执行过程和问题所在。通过输出变量、中间结果以及关键步骤的日志信息，可以帮助开发者定位问题所在。

7. **使用`tee`命令**：
当使用了多重管道，而需要判断前面的管道输出是否是正确的，可以使用`tee`命令。例如：
   
   ```sh
ipaddr=`/sbin/ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | tee temp.txt | cut -d : -f3 | awk '{print $1}'`
   ```

8. **使用`bash -x`命令**：
   `bash -x`命令可以执行脚本并显示所有变量的值，这有助于调试脚本中的问题。例如：
   
   ```sh
   bash -x script.sh
   ```

以上就是Shell脚本的一些常见调试方法。在实际使用中，你可以根据需要选择合适的方法进行调试。

## 案例

### 遍历文件中的IP

```sh
#!/bin/bash
#v1.0 by tianyun2020-9-20
read -p "Please enter a New Password:"pass
for ip in $(cat ip.txt);do
  {
    ping -c1 -W1 $ip &>/dev/null
    if [ $? -eq 0 ];then
      ssh $ip "echo $pass |passwd --stdin root"
      if [ $? -eq 0 ];then
        echo "$ip" >>ok_`date +%F`.txt # 时间文本，可以清楚地看出哪个时间修改成功了，哪个时间修改失败了
      else
        echo "$ip" >>fail_`date +%F`.txt
      fi
    else
      echo "$ip" >>fail.txt
    fi
  }&
done
wait
echo "finish..."
```

### 确保脚本以root权限运行

```sh
# 确保脚本以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
```

### 禁用交换分区

```sh
#!/bin/bash

# 确保脚本以 root 权限运行
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# 注释掉包含 swap 的行的函数
comment_swap() {
    # 读取 /etc/fstab 文件
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 如果行包含 swap，则在行前添加注释符号 #
        if [[ $line == *swap* ]]; then
            echo "#$line"
        else
            echo "$line"
        fi
    done < /etc/fstab > /etc/fstab.tmp
    # 替换 /etc/fstab 文件
    mv /etc/fstab.tmp /etc/fstab
    echo "Swap entries in /etc/fstab have been commented out."
}

# 调用函数
comment_swap
```

### 恢复与备份

```sh
#!/bin/bash

show_new_line() {
    echo -e "\n"
}

# Program Name
program_operate="Typora"

# Arrays for file backups and recoveries
file_recoveries=("/c/Users/Shreker/AppData/Roaming/Typora/themes/purple-squence-light.css" "/c/Users/Shreker/AppData/Roaming/Typora/profile.data")
file_backups=("./Settings/purple-squence-light.css" "./Settings/profile.data")

# Function to check if file exists
file_exists() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Function to copy files
copy_files() {
    local source_file=$1
    local target_file=$2

    if file_exists "$source_file"; then
        cp "$source_file" "$target_file"
        echo "File copied successfully: $source_file -> $target_file"
    else
        echo "Error: Source file does not exist - $source_file"
    fi
}

# Main script logic
while true; do
    echo "=============================================="
    echo "Please choose an option for ${program_operate}:"
    echo "1) Backup files"
    echo "2) Recover files"
    read -p "Enter your choice (1/2): " choice

    case $choice in
        1)
            echo "Starting backup process..."
            for i in "${!file_backups[@]}"; do
                copy_files "${file_recoveries[$i]}" "${file_backups[$i]}"
            done
            ;;
        2)
            echo "Starting recovery process..."
            for i in "${!file_recoveries[@]}"; do
                copy_files "${file_backups[$i]}" "${file_recoveries[$i]}"
            done
            ;;
        *)
            echo "Invalid option selected."
            ;;
    esac

    show_new_line
    # read -p "Do you want to continue? (yes/no): " cont
    # if [[ "$cont" != "yes" ]]; then
    #     break
    # fi
    read -p "Press ENTER to continue or Any other key to exit: " cont
    if [[ -z "$cont" ]]; then
        continue
    else
        break
    fi
    show_new_line
done

echo "Exiting the script."
```

`for` 循环用于遍历数组 `file_backups` 中的所有索引。让我们逐步分析这行代码：

- `for`：这是开始一个循环的关键词。
- `i`：这是循环变量，在每次迭代中，它将被赋予数组 `file_backups` 中的一个索引值。
- `in`：这是 `for` 循环语法的一部分，用于分隔循环变量和要迭代的集合。
- `"${!file_backups[@]}"`：这部分是关键，它使用了间接引用的语法来获取数组 `file_backups` 的所有索引。

让我们详细解释间接引用的部分：

- `${array[@]}`：这是获取数组 `array` 所有元素的标准方式。
- `${!array[@]}`：通过在变量名前加 `!`，我们使用间接引用。这意味着不是获取数组元素的值，而是获取数组元素的键（索引）。

# 部署问题总结

## SpringBoot打包太大怎么办

[SpringBoot打包后Jar包很大怎么办？](https://mp.weixin.qq.com/s/xPRNlIT9Ac4STKzMRyUhqQ)

### 包大的原因

为什么包比较大呢，原因在于包中`xxx.jar/BOOT-INFO/lib`目录下保存了项目用到的所有jar

### 解决方案

把该目录下的jar导出来，异步上传到服务器，利用对应的命令启动即可

#### 导jar包

```sh
$ mvn dependency:copy-dependencies -DoutputDirectory=<your-lib-path> -DincludeScope=runtime
```

#### 上传`<your-lib-path>`中的jar到服务器

#### 单独打包业务代码

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <mainClass>${your-main-class}</mainClass>
        <layout>ZIP</layout>
        <includes>
            <include>
                <groupId>nothing</groupId>
                <artifactId>nothing</artifactId>
            </include>
        </includes>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>repackage</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

#### 加载jar运行

```sh
$ java -Dloader.path=d:\temp\lib -jar target/blog.jar
```

## [蓝绿发布、灰度发布和滚动发布](https://www.cnblogs.com/nulige/articles/10929182.html)

应用程序升级面临最大挑战是新旧业务切换，将软件从测试的最后阶段带到生产环境，同时要保证系统不间断提供服务。

长期以来，业务升级渐渐形成了几个发布策略：蓝绿发布、灰度发布和滚动发布，目的是尽可能避免因发布导致的流量丢失或服务不可用问题。

### 蓝绿发布

#### 部署过程

项目逻辑上分为AB组，在项目上线时，首先把A组从负载均衡中摘除，进行新版本的部署。B组仍然继续提供服务。当A组升级完毕，负载均衡重新接入A组，再把B组从负载列表中摘除，进行新版本的部署。A组重新提供服务。最后，B组也升级完成，负载均衡重新接入B组，此时，AB组版本都已经升级完成，并且都对外提供服务。

#### 优点

- 发布策略简单；
- 用户无感知，平滑过渡；
- 升级/回滚速度快。

#### 缺点

- 需要准备正常业务使用资源的两倍以上服务器，防止升级期间单组无法承载业务突发；
- 短时间内浪费一定资源成本；
- 基础设施无改动，增大升级稳定性。

### 灰度发布

灰度发布是通过切换线上并存版本之间的路由权重，逐步从一个版本切换为另一个版本的过程。

#### 部署过程

灰度发布只升级部分服务，即让一部分用户继续用老版本，一部分用户开始用新版本，如果用户对新版本没什么问题，那么逐步扩大范围，把所有用户都迁移到新版本上面来。

#### 优点

- 保证整体系统稳定性，在初始灰度的时候就可以发现、调整问题，影响范围可控；
- 新功能逐步评估性能，稳定性和健康状况，如果出问题影响范围很小，相对用户体验也少；
- 用户无感知，平滑过渡。

#### 缺点

- 自动化要求高

### 滚动发布

滚动发布是指每次只升级一个或多个服务，升级完成后加入生产环境，不断执行这个过程，直到集群中的全部旧版本升级新版本。 

![img](Linux.assets/1053682-20190527095443475-675603692.png)

- 红色：正在更新的实例
- 蓝色：更新完成并加入集群的实例
- 绿色：正在运行的实例

#### 部署过程

- 先升级1个副本，主要做部署验证；
- 每次升级副本，自动从LB上摘掉，升级成功后自动加入集群；
- 事先需要有自动更新策略，分为若干次，每次数量/百分比可配置；
- 回滚是发布的逆过程，先从LB摘掉新版本，再回滚到老版本，这个过程一般时间比较长；

#### 优点

- 用户无感知，平滑过渡；
- 节约资源。

#### 缺点

- 部署时间慢，取决于每阶段更新时间；
- 发布策略较复杂；
- 无法确定OK的环境，不易回滚。
- 自动化要求高。

## Docker监控

### 非容器云管理平台

1、Docker自带命令

```sh
$ docker container top id
$ docker container status
```

2、Zabbix/Prometheus + Grafana

3、Weave Scope

### 容器云管理平台

1. Rancher
2. Docker Swarm
3. Kubernetes
4. Apache Mesos

|                      | Swarm                    | Kubernetes                                             | Mesos                  | ECS                            |
| -------------------- | ------------------------ | ------------------------------------------------------ | ---------------------- | ------------------------------ |
| 基本功能             | Docker原生的集群管理工具 | 开源的容器集群工具，提供应用级别的部署，维护和扩张功能 | 基于数据中心的操作系统 | 基于云的高可用，高扩展容器集群 |
| 高层次抽象           | 无                       | Pod Job Service                                        | 无                     | Task Service                   |
| 应用扩展性           | 无                       | 支持                                                   | Framework 支持         | 支持                           |
| 应用高可用性         | 无                       | 支持                                                   | Framework 支持         | 支持                           |
| 集群协调和服务发现   | ETCD ZooKeeper Consul    | ETCD                                                   | ZooKeeper              | ／                             |
| 调度策略（Schedule） | 内置，可扩展             | 内置                                                   | 两级别，可扩展         | 可扩展                         |
| 监控                 | Logging Driver           | Heapter，ELK Addon                                     | 内置                   | CloudWatch                     |
| 用户界面             | CLI API UCP UI           | CLI API UI                                             | API UI                 | CLI API AWS Console            |
| 开发语言             | Go                       | Go                                                     | Java                   | NA                             |
| 开源                 | 是                       | 是                                                     | 是                     | 否                             |
| 最大支持管理节点数   | 官方1000 非官方5000      | 官方1000 非官方2000                                    | 10000                  | ／                             |

## 免费SSL证书

### 阿里云申请免费SSL证书的途径

#### 单域名SSL证书页面

域名地址：https://yundun.console.aliyun.com/

<img src="Linux.assets/image-20220122000919319.png" alt="image-20220122000919319" style="zoom:50%;" />



Linux相关工具
=======
## 进程管理工具：supervisor

### 安装启动

```
 yum install -y supervisor
 systemctl enable supervisord
 systemctl start supervisord
 ps -ef | grep supervisor
```

### supervisor使用

- supervisor配置文件：`/etc/supervisord.conf`

  > 注：supervisor的配置文件默认是不全的，不过在大部分默认的情况下，上面说的基本功能已经满足。

- 子进程配置文件路径：`/etc/supervisord.d/`

  > 注：默认子进程配置文件为ini格式，可在supervisor主配置文件中修改。

### 配置文件说明

#### supervisor.conf 配置文件说明

```properties
[unix_http_server]
file=/tmp/supervisor.sock   ;UNIX socket 文件，supervisorctl 会使用
;chmod=0700                 ;socket文件的mode，默认是0700
;chown=nobody:nogroup       ;socket文件的owner，格式：uid:gid
 
;[inet_http_server]         ;HTTP服务器，提供web管理界面
;port=127.0.0.1:9001        ;Web管理后台运行的IP和端口，如果开放到公网，需要注意安全性
;username=user              ;登录管理后台的用户名
;password=123               ;登录管理后台的密码
 
[supervisord]
logfile=/tmp/supervisord.log ;日志文件，默认是 $CWD/supervisord.log
logfile_maxbytes=50MB        ;日志文件大小，超出会rotate，默认 50MB，如果设成0，表示不限制大小
logfile_backups=10           ;日志文件保留备份数量默认10，设为0表示不备份
loglevel=info                ;日志级别，默认info，其它: debug,warn,trace
pidfile=/tmp/supervisord.pid ;pid 文件
nodaemon=false               ;是否在前台启动，默认是false，即以 daemon 的方式启动
minfds=1024                  ;可以打开的文件描述符的最小值，默认 1024
minprocs=200                 ;可以打开的进程数的最小值，默认 200
 
[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ;通过UNIX socket连接supervisord，路径与unix_http_server部分的file一致
;serverurl=http://127.0.0.1:9001 ; 通过HTTP的方式连接supervisord
 
; [program:xx]是被管理的进程配置参数，xx是进程的名称
[program:xx]
command=/opt/apache-tomcat-8.0.35/bin/catalina.sh run  ; 程序启动命令
autostart=true       ; 在supervisord启动的时候也自动启动
startsecs=10         ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
autorestart=true     ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
startretries=3       ; 启动失败自动重试次数，默认是3
user=tomcat          ; 用哪个用户启动进程，默认是root
priority=999         ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true ; 把stderr重定向到stdout，默认false
stdout_logfile_maxbytes=20MB  ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20   ; stdout 日志文件备份数，默认是10
; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
stdout_logfile=/opt/apache-tomcat-8.0.35/logs/catalina.out
stopasgroup=false     ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=false     ;默认为false，向进程组发送kill信号，包括子进程
 
;包含其它配置文件
[include]
files = relative/directory/*.ini    ;可以指定一个或多个以.ini结束的配置文件
```

#### 子进程配置文件说明

给需要管理的子进程(程序)编写一个配置文件，放在`/etc/supervisor.d/`目录下，以`.ini`作为扩展名（每个进程的配置文件都可以单独分拆也可以把相关的脚本放一起）。如任意定义一个和脚本相关的项目名称的选项组：`/etc/supervisord.d/test.conf`

```ruby
#项目名
[program:blog]
#脚本目录
directory=/opt/bin
#脚本执行命令
command=/usr/bin/python /opt/bin/test.py

#supervisor启动的时候是否随着同时启动，默认True
autostart=true
#当程序exit的时候，这个program不会自动重启,默认unexpected，设置子进程挂掉后自动重启的情况，有三个选项，false,unexpected和true。如果为false的时候，无论什么情况下，都不会被重新启动，如果为unexpected，只有当进程的退出码不在下面的exitcodes里面定义的
autorestart=false
#这个选项是子进程启动多少秒之后，此时状态如果是running，则我们认为启动成功了。默认值为1
startsecs=1

#脚本运行的用户身份 
user = test

#日志输出 
stderr_logfile=/tmp/blog_stderr.log 
stdout_logfile=/tmp/blog_stdout.log 
#把stderr重定向到stdout，默认 false
redirect_stderr = true
#stdout日志文件大小，默认 50MB
stdout_logfile_maxbytes = 20MB
#stdout日志文件备份数
stdout_logfile_backups = 20
```

##### 子进程配置示例：

```bash
#说明同上
[program:test] 
directory=/opt/bin 
command=/opt/bin/test
autostart=true 
autorestart=false 
stderr_logfile=/tmp/test_stderr.log 
stdout_logfile=/tmp/test_stdout.log 
#user = test  
```

### supervisor命令说明

#### 常用命令

```sh
supervisorctl status        //查看所有进程的状态
supervisorctl stop es       //停止es
supervisorctl start es      //启动es
supervisorctl restart       //重启es
supervisorctl update        //配置文件修改后使用该命令加载新的配置
supervisorctl reload        //重新启动配置中的所有程序
```

注：把`es`换成`all`可以管理配置中的所有进程。直接输入`supervisorctl`进入supervisorctl的shell交互界面，此时上面的命令不带supervisorctl可直接使用。

#### 注意事项

- 使用supervisor进程管理命令之前先启动supervisord，否则程序报错。

- 使用命令`supervisord -c /etc/supervisord.conf`启动。

- 若是centos7：

  ```sh
  systemctl start supervisord.service     //启动supervisor并加载默认配置文件
  systemctl enable supervisord.service    //将supervisor加入开机启动项
  ```

#### 常见问题

1. unix:///var/run/supervisor.sock no such file
   问题描述：安装好supervisor没有开启服务直接使用supervisorctl报的错
   解决办法：`supervisord -c /etc/supervisord.conf`
2. command中指定的进程已经起来，但supervisor还不断重启
   问题描述：command中启动方式为后台启动，导致识别不到pid，然后不断重启，这里使用的是elasticsearch，command指定的是`$path/bin/elasticsearch -d`                    
   解决办法：supervisor无法检测后台启动进程的pid，而supervisor本身就是后台启动守护进程，因此不用担心这个
3. 启动了多个supervisord服务，导致无法正常关闭服务
   问题描述：在运行`supervisord -c /etc/supervisord.conf`之前，直接运行过`supervisord -c /etc/supervisord.d/xx.conf`导致有些进程被多个superviord管理，无法正常关闭进程。
   解决办法：使用`ps -fe | grep supervisord`查看所有启动过的supervisord服务，kill相关的进程。

#### Supervisor官网

[http://supervisord.org](https://links.jianshu.com/go?to=http%3A%2F%2Fsupervisord.org)

>ddb24446e1dcac1e155bacd319a96004f7985247

## 测试工具：busybox

> 参考：Docker.md/其他工具/测试工具：busybox

# 新系统操作

## CentOS7更新yum源

```sh
# 安装工具
yum install -y wget

# 备份
cd /etc/yum.repos.d/
mkdir repo_bak
mv *.repo repo_bak/

# 下载库文件
wget http://mirrors.aliyun.com/repo/Centos-7.repo

# 重新生成缓存
yum clean all
yum makecache

# 安装EPEL（Extra Packages for Enterprise Linux ）源
yum install -y epel-release

# 重新生成缓存
yum clean all
yum makecache

# 查看启用的yum源和所有的yum源
yum repolist enabled
yum repolist all

# 更新yum
yum -y update
```

# 虚拟机Linux

> 所有Linux虚拟机的密码：cos7

## Commons

### 修改网络

> 安装虚拟机的时候使用默认的NAT网络

1. BOOTPROTO修改为static
2. 添加
   - IPADDR=
   - PREFIX=24
   - GATEWAY=
   - DNS1=223.6.6.6
   - DNS2=223.5.5.5
   - DNS3=\<GATEWAY\>
3.  `:x`保存配置
4. 重启网卡: `ifdown <net-card-name>; ifup <net-card-name>`
5. 查看网络信息: `ip a`
6. 查看系统版本: `cat /etc/redhat-release`
7. 查看内核版本: `uname -r`
8. 查看内存占用: `free -h`
9. 查看磁盘占用: `df -hT`
10. 查看selinux状态: `sestatus`
    - 关闭selinux: `vi /etc/selinux/config`, 把SELINUX的`enforcing`修改成`disabled`
11. 查看防火墙状态: `systemctl status firewalld`



### 修改vi编辑器配置

1. tab设置成4个空格



### 关闭SELINUX

```sh
vi /etc/sysconfig/selinux
# SELINUX=enforcing修改为disabled
```

## VBox

### Rocky 

- 问题: 新建Rocky后,能ping通baidu, 但是XShell连接不上
  - 参考: [解决Xshell连不上virtualBox虚拟机的解决方法](https://www.jb51.net/article/229502.htm)


## 命令行颜色总结

> 表格形式; `\E` 标识符在 `PS1` 环境变量中不生效，只能用`\033`

| 前景(3开头) | 背景(4开头) | 颜色  | ANSI控制码(结束标识\E[0m) |
| ----------- | ----------- | ----- | ------------------------- |
| 30          | 40          | 0黑色 | \E[30m\E[0m，\E[40m\E[0m  |
| 31          | 41          | 1红色 | \E[31m\E[0m，\E[41m\E[0m  |
| 32          | 42          | 2绿色 | \E[32m\E[0m，\E[42m\E[0m  |
| 33          | 43          | 3黄色 | \E[33m\E[0m，\E[43m\E[0m  |
| 34          | 44          | 4蓝色 | \E[34m\E[0m，\E[44m\E[0m  |
| 35          | 45          | 5紫色 | \E[35m\E[0m，\E[45m\E[0m  |
| 36          | 46          | 6天蓝 | \E[36m\E[0m，\E[46m\E[0m  |
| 37          | 47          | 7白色 | \E[37m\E[0m，\E[47m\E[0m  |

## 命令行控制码

| 控制码    | 说明                                 |
| --------- | ------------------------------------ |
| \033[0m   | 关闭所有属性，即属性结束标识         |
| \033[01m  | **设置高亮度，即字体加粗、文体强调** |
| \033[03m  | *设置倾斜*                           |
| \033[04m  | 下划线                               |
| \033[05m  | 闪烁                                 |
| \033[07m  | 反显                                 |
| \033[08m  | 消隐                                 |
| \033[09m  | 文字中划线                           |
| \033[3nm  | 设置前景色(0 ≤ n ≤ 7)                |
| \033[4nm  | 设置背景色(0 ≤ n ≤ 7)                |
| \033[nA   | 光标上移n行                          |
| \033[nB   | 光标下移n行                          |
| \033[nC   | 光标右移n行                          |
| \033[nD   | 光标左移n行                          |
| \033[y;xH | 设置光标位置                         |
| \033[2J   | 清屏                                 |
| \033[K    | 清除从光标到行尾的内容               |
| \033[s    | 保存光标位置                         |
| \033[u    | 恢复光标位置                         |
| \033[?25l | 隐藏光标                             |
| \033[?25h | 显示光标                             |

# 虚拟机网络模式

## 各种模式的互通性

![image-20240513111632954](Linux.assets/image-20240513111632954.png)

## 地址转换NAT

在NAT网络模式下，虚拟机可以通过路由器为设备分配私有地址，并将其转换为公网地址以实现外部网络访问。

![image-20240513112120553](Linux.assets/image-20240513112120553.png)

## 桥接Bridged

桥接模式就是让虚拟机和宿主机都连接宿主机的路由器，用共同路由器管理网络，即宿主机遇这些虚拟机平级存在

桥接模式可以让虚拟机之间直接通信并访问主机和网络，但需要确保虚拟机的MAC地址不相同。

![image-20240513112455525](Linux.assets/image-20240513112455525.png)

## 内部网络Internal

内部网络模式则是一种隔离的网络环境，虚拟机可以相互通信，但无法与宿主和网络连接。

且VBox默认不提供DHCP服务，即需要手动配置静态IP

![image-20240513111102271](Linux.assets/image-20240513111102271.png)

## 仅主机HostOnly

仅主机模式则是完全隔离的网络环境，虚拟机无法与主机、网络或其他虚拟机通信。？

虚拟机和主机可以PING通？



# Win10系统

## 安装VMWare报错

1. [VMware Workstation 与 Device/Credential Guard 不兼容。在禁用 Device/Credential Guard 后，可以运行 VMware Workstation](https://blog.csdn.net/m0_48096446/article/details/131062336)。
   - 组策略解决
     - 打开“运行”对话框，键入 “gpedit.msc”
     - 导航到 “计算机配置” > “管理模板” > “系统” > “Device Guard”。
     - 右侧窗格中选择 “启用或禁用 Device Guard”，将其设置为 “未配置” 或 “已禁用”。
     - 重启
   - 命令行解决
     - 管理员运行命令：`bcdedit /set hypervisorlaunchtype off`
     - 重启
2. VMWare首次安装设置完开启Linux后出现蓝屏：SYSTEM_SERVICE_EXCEPTION
   - 解决方案：
     - 控制面板中开启Win10的：虚拟机平台/Virtual Machine Platform
     - 然后重启

# 域名解析记录

## 常见的域名解析类型

| 类型        | 含义                                                         |
| ----------- | ------------------------------------------------------------ |
| A           | 将域名指向一个IPv4地址（例如：100.100.100.100）              |
| AAAA        | 将主机名（或域名）指向一个IPv6地址（例如：ff03:0:0:0:0:0:0:c1） |
| CNAME       | 将一个域名指向另一个域名，实现与被指向域名相同的访问效果     |
| MX          | 指向邮件服务器地址                                           |
| NS          | 将子域名指定某个域名服务器来解析                             |
| TXT         | 一般做一些验证记录时会使用此项，如：做SPF（反垃圾邮件）记录  |
| SRV         | 添加服务记录，SRV记录了哪台计算机提供了哪个服务              |
| SOA         | 用于在众多NS记录中那一台是主服务器                           |
| PTR         | PTR记录是A记录的逆向记录，又称IP反查记录或指针记录，负责将IP反向解析为域名 |
| 显性URL转发 | 将域名指向一个http(s)协议地址，访问域名时，自动跳转至目标地址。例如：将www.liuht.cn显性转发到www.itbilu.com后，访问www.liuht.cn时，地址栏显示的地址为：www.itbilu.com，即显示原始地址 |
| 隐性URL转发 | 将域名指向一个http(s)协议地址，访问域名时，自动跳转至目标地址，隐性转发会隐藏真实的目标地址。例如：将www.liuht.cn显性转发到www.itbilu.com后，访问www.liuht.cn时，地址栏显示的地址仍然：www.liuht.cn，即显示键入地址 |

# 代理配置

## CentOS代理

我看别人配置好像就在网卡配置中添加了 HTTP_PROXY、PROXY_USER、PROXY_PASS，这个完整的配置是什么样的

在CentOS 7.9中，如果您想要在网卡配置文件中设置代理服务器，通常需要使用环境变量来指定代理服务器的地址和端口。这些环境变量包括`HTTP_PROXY`、`HTTPS_PROXY`、`FTP_PROXY`等，用于指定不同协议的代理服务器。然而，这些变量通常是在系统的全局配置文件中设置的，而不是在网卡配置文件中。

如果您确实看到有人在网卡配置文件中设置了代理相关的环境变量，这可能是一个误解或者是一个特定的配置需求。通常情况下，代理服务器的配置是在系统的环境变量中设置的，而不是在网卡配置文件中。

以下是一个在全局配置文件中设置代理服务器的示例：

1. 打开全局配置文件：

    ```bash
    sudo vi /etc/profile
    ```

2. 在文件的末尾添加以下内容：

    ```bash
    export http_proxy="http://username:password@proxy-server:port"
    export https_proxy="http://username:password@proxy-server:port"
    export ftp_proxy="http://username:password@proxy-server:port"
    ```

    其中`username`和`password`是您的代理服务器的用户名和密码，`proxy-server`是代理服务器的地址，`port`是代理服务器的端口号。

3. 保存并关闭文件。

4. 使配置生效：

    ```bash
    source /etc/profile
    ```

5. 验证代理设置：

    ```bash
    echo $http_proxy
    ```

    应该会显示您设置的代理服务器地址。

请注意，上述步骤是在全局范围内设置代理服务器，这意味着所有使用这些环境变量的程序都会使用这个代理服务器。如果您只想为特定的用户或程序设置代理，您可以在该用户的`.bashrc`或`.bash_profile`文件中设置这些变量。

如果您的确需要在网卡配置文件中设置代理，这可能涉及到更高级的配置，例如使用`nmcli`命令来设置网络连接的代理设置，或者在网卡配置文件中添加特定的代理设置。但是，这通常不是标准做法，且可能需要特定的网络管理工具支持。

如果您需要进一步的帮助来设置代理服务器，请提供更多的上下文信息，例如您希望代理哪些类型的流量（HTTP、HTTPS、FTP等），以及您是否希望为所有用户或特定用户设置代理。这样我可以提供更精确的指导。

# Linux附表

## 网卡配置

### 静态默认配置：

```properties
NAME="enp0s3"
DEVICE="enp0s3"
TYPE="Ethernet"
BOOTPROTO="none
DEFROUTE="yes"
IPV4_FAILURE_FATAL="yes"
ONBO0T="yes"
IPADDR="10.10.10.10"
PREFIX="24"
GATEWAY="10.10.10.2"
DNS1="8.8.8.8"
DNS2="8.8.4.4"
DNS3="114.114.114.114"
DNS4="10.10.10.2"
```

### 动态默认配置

```properties
<key>=<value>
```



# Linux线上纪实

## 磁盘打满

排查过程：

1. 排查是哪个盘满了：`df -h`
   - `df` 是 Disk Free 的缩写，用于报告文件系统的总空间、已用空间、剩余空间以及挂载点等信息。
   - `-h` 参数表示以人类可读的格式（如 KB、MB、GB）显示大小，而不是以字节为单位。
2. 查看是哪些文件造成的：`du -sh ./*`
   - `du` 是 Disk Usage 的缩写，用于估计文件系统的空间使用情况。
   - `-s` 参数表示对每个参数只列出总计（summarize），即只显示每个参数的总大小，而不是列出每个子目录和文件的大小。
   - `-h` 参数表示以人类可读的格式（如 KB、MB、GB）显示大小，而不是以字节为单位。
   - `./` 表示当前目录。
   - `*` 是一个通配符，代表当前目录下的所有文件和文件夹。
3. 查看文件产生的进程：`lsof <file-path>`
   - `lsof` 是 List Open Files 的缩写，用于列出当前系统打开的所有文件的信息。
   - `<file-path>` 是你想要查询的文件的路径。
4. 根据得到的PID即可得到些文件的进程：`ps -ef | grep <PID>`

## 文件夹rm失败

> 线上有一个文件夹中存在非常多的小文件
>
> 使用`rm -rf ./*`失败：`-bash: /usr/bin/rm: 参数列表过长`

使用这个命令删除：`find ./ -type f -name "*.txt" -delete`

用来查找并删除当前目录及其子目录下所有扩展名为 `.txt` 的文件的命令。

- `find` 是一个强大的命令，用于在指定目录下查找文件。
- `./` 表示当前目录。
- `-type f` 参数指定只查找文件（file），不包括目录。
- `-name "*.txt"` 参数指定查找所有文件名以 `.txt` 结尾的文件。这里的 `*` 是一个通配符，代表任意数量的任意字符。
- `-delete` 参数指示 `find` 命令删除找到的文件。

## 删除数据恢复

1. 删除后先卸载分区：`umount /data`
2. 恢复数据：`ext4magic /dev/sd1 -R -d /mnt`

`ext4magic /dev/sd1 -R -d /mnt` 是一个用于修复或恢复 ext4 文件系统的命令，但需要注意的是，`ext4magic` 并不是一个标准的Linux工具。

通常，Linux系统中用于修复ext4文件系统的工具是 `e2fsck`。

让我们分析一下这个命令的各个部分：

- `/dev/sd1`：这通常指的是系统中的一个磁盘分区。`sd1` 表示第一个SCSI或SATA磁盘上的第二个分区（分区编号从1开始）。
- `-R`：这个选项在 `e2fsck` 中表示重新挂载文件系统为只读模式，然后进行检查和修复。如果 `ext4magic` 是一个特定工具的命令，这个选项可能有类似的含义。
- `-d /mnt`：这个选项在 `e2fsck` 中表示在修复过程中，如果需要，将文件系统临时挂载到 `/mnt` 目录下。如果 `ext4magic` 是一个特定工具的命令，这个选项可能有类似的含义。

由于 `ext4magic` 不是一个标准工具，如果你需要修复ext4文件系统，建议使用 `e2fsck`。例如，使用 `e2fsck` 的命令可能如下：

```bash
sudo e2fsck -f /dev/sd1
```

这个命令会强制检查 `/dev/sd1` 分区上的ext4文件系统，并尝试修复任何错误。如果需要在修复过程中挂载文件系统，可能需要额外的步骤。

在执行任何文件系统修复操作之前，请确保你已经备份了所有重要数据，因为这些操作可能会导致数据丢失。如果你不确定如何操作，建议寻求专业帮助。



# 其他

## VMShell提供CentOS7的Yum源

> https://linuxword.com/?p=38887

VmShell 开源 CentOS 7 配置内部YUM源，本YUM源每晚凌晨1点自动获取最新的组件依赖提供自动更新，方便企业内网使用该模板

同时VmShell的YUM源服务器在日本，方便国际网络更新，具体方式如下：

1. 备份：`mkdir /etc/yum.repos.d/backup && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/`
2. 下载新的 CentOS-Base.repo 到 /etc/yum.repos.d/：`curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.vmshell.com/repo/CentOS-Base.repo`
3. 运行 `yum clean all && yum makecache && yum -y update && yum -y upgrade` 生成缓存并更新依赖
4. 运行 `yum repolist` 查看已经生成缓存

重要提醒：当然VmShell也将该YUM源模板提供出来用于大家下载给公司企业内网作为yum源使用（解决企业内网服务器更新YUM源的问题，仅仅只需要更换IP即可）：

1. **服务器配置：**4C-4GB-50GB (SSD) ，实际模板文件为35GB大小；
2. **服务器系统**：Centos7.9 64bit
3. **服务器用户名**：root
4. **服务器端口**：22
5. **服务器密码**：000000

发布完整版库模板下载地址（完整无错版）： 

https://linuxword.com/wp-content/uploads/PVE/CentOS7-YUM.zip
如果想自己生成具体模板制作文档请见教程：[VmShell国际CentOS源服务器[解决阿里源速度慢问题\]](https://linuxword.com/?p=38887)

1、由于CentoS7源停止了更新，阿里源在线更新速度太慢，也缺少第三方yum源，因此基于VmShell国际线路搭建一台yum源服务器满足这一需求，同时网络层面策略只允许此yum源服务器每周日晚限时联网同步阿里云的yum源保持最新。
2、准备亚洲服务器用作yum源服务器。
3、系统版本：CentOS 7.9
