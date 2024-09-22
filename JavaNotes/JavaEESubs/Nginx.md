# Nginx Basics

[Nginx完全手册](HeiMaNginx.md)

## Nginx一般充当网关角色

- WAF：Web Application Firewall
- 定向流量分发
- 负载均衡
- Openresty：Nginx+Lua
- Kong：基于Openresty的API Gateway

## Nginx默认配置

### nginx.conf

```nginx
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

### default.conf

```nginx
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
```

### mime.types

```
types {
    text/html                                        html htm shtml;
    text/css                                         css;
    text/xml                                         xml;
    image/gif                                        gif;
    image/jpeg                                       jpeg jpg;
    application/javascript                           js;
    application/atom+xml                             atom;
    application/rss+xml                              rss;

    text/mathml                                      mml;
    text/plain                                       txt;
    text/vnd.sun.j2me.app-descriptor                 jad;
    text/vnd.wap.wml                                 wml;
    text/x-component                                 htc;

    image/png                                        png;
    image/svg+xml                                    svg svgz;
    image/tiff                                       tif tiff;
    image/vnd.wap.wbmp                               wbmp;
    image/webp                                       webp;
    image/x-icon                                     ico;
    image/x-jng                                      jng;
    image/x-ms-bmp                                   bmp;

    application/font-woff                            woff;
    application/java-archive                         jar war ear;
    application/json                                 json;
    application/mac-binhex40                         hqx;
    application/msword                               doc;
    application/pdf                                  pdf;
    application/postscript                           ps eps ai;
    application/rtf                                  rtf;
    application/vnd.apple.mpegurl                    m3u8;
    application/vnd.google-earth.kml+xml             kml;
    application/vnd.google-earth.kmz                 kmz;
    application/vnd.ms-excel                         xls;
    application/vnd.ms-fontobject                    eot;
    application/vnd.ms-powerpoint                    ppt;
    application/vnd.oasis.opendocument.graphics      odg;
    application/vnd.oasis.opendocument.presentation  odp;
    application/vnd.oasis.opendocument.spreadsheet   ods;
    application/vnd.oasis.opendocument.text          odt;
    application/vnd.openxmlformats-officedocument.presentationml.presentation
                                                     pptx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                                                     xlsx;
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                                     docx;
    application/vnd.wap.wmlc                         wmlc;
    application/x-7z-compressed                      7z;
    application/x-cocoa                              cco;
    application/x-java-archive-diff                  jardiff;
    application/x-java-jnlp-file                     jnlp;
    application/x-makeself                           run;
    application/x-perl                               pl pm;
    application/x-pilot                              prc pdb;
    application/x-rar-compressed                     rar;
    application/x-redhat-package-manager             rpm;
    application/x-sea                                sea;
    application/x-shockwave-flash                    swf;
    application/x-stuffit                            sit;
    application/x-tcl                                tcl tk;
    application/x-x509-ca-cert                       der pem crt;
    application/x-xpinstall                          xpi;
    application/xhtml+xml                            xhtml;
    application/xspf+xml                             xspf;
    application/zip                                  zip;

    application/octet-stream                         bin exe dll;
    application/octet-stream                         deb;
    application/octet-stream                         dmg;
    application/octet-stream                         iso img;
    application/octet-stream                         msi msp msm;

    audio/midi                                       mid midi kar;
    audio/mpeg                                       mp3;
    audio/ogg                                        ogg;
    audio/x-m4a                                      m4a;
    audio/x-realaudio                                ra;

    video/3gpp                                       3gpp 3gp;
    video/mp2t                                       ts;
    video/mp4                                        mp4;
    video/mpeg                                       mpeg mpg;
    video/quicktime                                  mov;
    video/webm                                       webm;
    video/x-flv                                      flv;
    video/x-m4v                                      m4v;
    video/x-mng                                      mng;
    video/x-ms-asf                                   asx asf;
    video/x-ms-wmv                                   wmv;
    video/x-msvideo                                  avi;
}
```

## 常用配置及说明

```nginx
###### 全局块 #####

#user administrator administrators; #配置用户或者组，默认为nobody nobody。
worker_processes 1; #nginx进程数，建议设置为等于CPU总核心数 默认为1。
#全局错误日志定义类型，[ debug | info | notice | warn | error | crit ]
error_log /usr/local/nginx/logs/error.log info;
pid /usr/local/nginx/logs/nginx.pid; #进程pid存放路径

###### events块 #####

events {
  #accept_mutex on; #设置网路连接序列化，防止惊群现象发生，默认为on
  #multi_accept on; #设置一个进程是否同时接受多个网络连接，默认为off
  #use epoll; #事件驱动模型，select|poll|kqueue|epoll|resig|/dev/poll|eventport epoll是Linux 2.6以上版本内核中的高性能网络I/O模型，linux建议epoll
  #单个进程最大连接数（最大连接数=连接数*进程数）
  worker_connections  1024;
}


###### http块 #####
http {
  include mime.types; #文件扩展名与文件类型映射表
  default_type application/octet-stream; #用来配置Nginx响应前端请求默认的MIME类型 默认default_type text/plain;
  #charset utf-8; #默认编码

  #access_log off; #取消服务日志
  # 可自定义日志格式
  #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  #                  '$status $body_bytes_sent "$http_referer" '
  #                  '"$http_user_agent" "$http_x_forwarded_for"';

  #access_log  logs/access.log  main;

  client_max_body_size 8m; #设定通过nginx上传文件的大小

  #开启高效文件传输模式，sendfile指令指定nginx是否调用sendfile函数来输出文件，对于普通应用设为 on，如果用来进行下载等应用磁盘IO重负载应用，可设置为off，以平衡磁盘与网络I/O处理速度，降低系统的负载。注意：如果图片显示不正常把这个改成off。
  sendfile on;

  #开启目录列表访问，合适下载服务器，默认关闭。
  autoindex on;

  #keepalive_timeout  0; #长连接超时时间，单位是秒
  keepalive_timeout  65;

  #gzip模块设置
  #gzip on; #开启gzip压缩输出


  #负载均衡配置
  upstream mysvr {

    #upstream的负载均衡，weight是权重，可以根据机器配置定义权重。weigth参数表示权值，权值越高被分配到的几率越大。
    server 192.168.80.121:80 weight=3;
    server 192.168.80.122:80 weight=2;
    server 192.168.80.123:80 backup; #热备
    server 192.168.80.123:80 down;

    #在需要使用负载均衡的server中增加 proxy_pass http://mysvr/;
  }

  #虚拟主机的配置
  server
    {
    listen 80; #监听端口

    #域名可以有多个，用空格隔开
    server_name localhost;

    #access_log  logs/host.access.log  main;
    error_page 404 /404.html; #配置错误页面(当404时展示404.html页面，配置一个location来跳转到具体页面)

    location  / { #请求的url过滤，正则匹配，~为区分大小写，~*为不区分大小写。
      #root path; #根目录
      #index  index.html index.htm; #设置网站的默认首页
      proxy_pass  http://mysvr; #请求转向mysvr 定义的服务器列表
      deny 127.0.0.1; #拒绝的ip
      allow 127.0.0.1; #允许的ip 
    } 

    #配置错误页面转向
    location = /404.html {
      root /home/www/myweb;
      index 404.html;
    }
  }
}
```



# Nginx Advanced

## Server模块

该模块位于: 

# [生产环境之Nginx高可用方案](https://www.cnblogs.com/SimpleWu/p/11004902.html)

## 准备工作：

两台虚拟机。安装好`Nginx`

192.168.16.128

192.168.16.129

## 安装Nginx

更新`yum`源文件：

```shell
Copyrpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```

安装Nginx:

```shell
Copyyum -y install  nginx
```

操作命令：

```shell
Copysystemctl start nginx; #启动Nginx
systemctl stop nginx; #停止Nginx
```

## 什么是高可用？[#](https://www.cnblogs.com/SimpleWu/p/11004902.html#10695496)

高可用HA（High Availability）是分布式系统架构设计中必须考虑的因素之一，它通常是指，通过设计减少系统不能提供服务的时间。如果一个系统能够一直提供服务，那么这个可用性则是百分之百，但是天有不测风云。所以我们只能尽可能的去减少服务的故障。

## 解决的问题？[#](https://www.cnblogs.com/SimpleWu/p/11004902.html#2383204873)

在生产环境上很多时候是以`Nginx`做反向代理对外提供服务，但是一天Nginx难免遇见故障，如：服务器宕机。当`Nginx`宕机那么所有对外提供的接口都将导致无法访问。

虽然我们无法保证服务器百分之百可用，但是也得想办法避免这种悲剧，今天我们使用`keepalived`来实现`Nginx`

的高可用。

## 双机热备方案[#](https://www.cnblogs.com/SimpleWu/p/11004902.html#1868227091)

这种方案是国内企业中最为普遍的一种高可用方案，双机热备其实就是指一台服务器在提供服务，另一台为某服务的备用状态，当一台服务器不可用另外一台就会顶替上去。

**keepalived是什么？**

`Keepalived`软件起初是专为`LVS`负载均衡软件设计的，用来管理并监控LVS集群系统中各个服务节点的状态，后来又加入了可以实现高可用的`VRRP (Virtual Router Redundancy Protocol ,虚拟路由器冗余协议）`功能。因此，`Keepalived`除了能够管理LVS软件外，还可以作为其他服务`（例如：Nginx、Haproxy、MySQL等）`的高可用解决方案软件

**故障转移机制**

`Keepalived`高可用服务之间的故障切换转移，是通过`VRRP` 来实现的。
在 `Keepalived`服务正常工作时，主 `Master`节点会不断地向备节点发送（多播的方式）心跳消息，用以告诉备`Backup`节点自己还活着，当主 `Master`节点发生故障时，就无法发送心跳消息，备节点也就因此无法继续检测到来自主 `Master`节点的心跳了，于是调用自身的接管程序，接管主Master节点的 IP资源及服务。而当主 Master节点恢复时，备Backup节点又会释放主节点故障时自身接管的IP资源及服务，恢复到原来的备用角色。

## 实现过程[#](https://www.cnblogs.com/SimpleWu/p/11004902.html#2616391852)

**安装keepalived**

`yum`方式直接安装即可，该方式会自动安装依赖：

```shell
Copyyum -y install keepalived
```

**修改主机（192.168.16.128）keepalived配置文件**

`yum`方式安装的会生产配置文件在`/etc/keepalived`下：

```shell
Copyvi keepalived.conf
keepalived.conf:
Copy#检测脚本
vrrp_script chk_http_port {
    script "/usr/local/src/check_nginx_pid.sh" #心跳执行的脚本，检测nginx是否启动
    interval 2                          #（检测脚本执行的间隔，单位是秒）
    weight 2                            #权重
}
#vrrp 实例定义部分
vrrp_instance VI_1 {
    state MASTER         # 指定keepalived的角色，MASTER为主，BACKUP为备
    interface ens33      # 当前进行vrrp通讯的网络接口卡(当前centos的网卡) 用ifconfig查看你具体的网卡
    virtual_router_id 66 # 虚拟路由编号，主从要一直
    priority 100         # 优先级，数值越大，获取处理请求的优先级越高
    advert_int 1           # 检查间隔，默认为1s(vrrp组播周期秒数)
    #授权访问
    authentication {
        auth_type PASS #设置验证类型和密码，MASTER和BACKUP必须使用相同的密码才能正常通信
        auth_pass 1111
    }
    track_script {
        chk_http_port            #（调用检测脚本）
    }
    virtual_ipaddress {
        192.168.16.130            # 定义虚拟ip(VIP)，可多设，每行一个
    }
}
```

`virtual_ipaddress` 里面可以配置vip,在线上通过vip来访问服务。

```
interface`需要根据服务器网卡进行设置通常查看方式`ip addr
```

`authentication`配置授权访问后备机也需要相同配置

**修改备机（192.168.16.129）keepalived配置文件**

```
keepalived.conf:
Copy#检测脚本
vrrp_script chk_http_port {
    script "/usr/local/src/check_nginx_pid.sh" #心跳执行的脚本，检测nginx是否启动
    interval 2                          #（检测脚本执行的间隔）
    weight 2                            #权重
}
#vrrp 实例定义部分
vrrp_instance VI_1 {
    state BACKUP                        # 指定keepalived的角色，MASTER为主，BACKUP为备
    interface ens33                      # 当前进行vrrp通讯的网络接口卡(当前centos的网卡) 用ifconfig查看你具体的网卡
    virtual_router_id 66                # 虚拟路由编号，主从要一直
    priority 99                         # 优先级，数值越大，获取处理请求的优先级越高
    advert_int 1                        # 检查间隔，默认为1s(vrrp组播周期秒数)
    #授权访问
    authentication {
        auth_type PASS #设置验证类型和密码，MASTER和BACKUP必须使用相同的密码才能正常通信
        auth_pass 1111
    }
    track_script {
        chk_http_port                   #（调用检测脚本）
    }
    virtual_ipaddress {
        192.168.16.130                   # 定义虚拟ip(VIP)，可多设，每行一个
    }
}
```

**检测脚本：**

```sh
Copy#!/bin/bash
#检测nginx是否启动了
A=`ps -C nginx --no-header |wc -l`        
if [ $A -eq 0 ];then    #如果nginx没有启动就启动nginx                        
      systemctl start nginx                #重启nginx
      if [ `ps -C nginx --no-header |wc -l` -eq 0 ];then    #nginx重启失败，则停掉keepalived服务，进行VIP转移
              killall keepalived                    
      fi
fi
```

脚本授权:`chmod 775 check_nginx_pid.sh`

说明：脚本必须通过授权，不然没权限访问啊，在这里我们两条服务器执行、`VIP(virtual_ipaddress:192.168.16.130)`,我们在生产环境是直接通过vip来访问服务。

模拟`nginx`故障：

修改两个服务器默认访问的`Nginx`的`html`页面作为区别。

首先访问`192.168.16.130`,通过`vip`进行访问，页面显示`192.168.16.128`；说明当前是主服务器提供的服务。

这个时候`192.168.16.128`主服务器执行命令：

```sh
Copysystemctl stop nginx; #停止nginx
```

再次访问`vip(192.168.16.130)`发现这个时候页面显示的还是：`192.168.16.128`，这是脚本里面自动重启。

现在直接将`192.168.16.128`服务器关闭，在此访问`vip(192.168.16.130)`现在发现页面显示`192.168.16.129`这个时候`keepalived`就自动故障转移了，一套企业级生产环境的高可用方案就搭建好了。

`keepalived`中还有许多功能比如：邮箱提醒啊等等，就不操作了，可以去官网看看文档。





# nginx负载均衡的5种策略及原理

## 0、五种轮询方案

nginx的upstream目前支持的5种方式的分配

**1、轮询（默认）**
每个请求按时间顺序逐一分配到不同的后端服务器，如果后端服务器down掉，能自动剔除。 

```ngin
upstream backserver { 
	server 192.168.0.14; 
	server 192.168.0.15; 
}
```

**2、权重轮询**
指定轮询几率，weight和访问比率成正比，用于后端服务器性能不均的情况。 

```
upstream backserver { 
	server 192.168.0.14 weight=8; 
	server 192.168.0.15 weight=10; 
} 
```

**3、源ip_hash**
每个请求按访问ip的hash结果分配，这样每个访客固定访问一个后端服务器，可以解决session的问题。 
upstream backserver { 

```
ip_hash; 
	server 192.168.0.14:88; 
	server 192.168.0.15:80; 
} 
```

**4、fair（第三方）**
按后端服务器的响应时间来分配请求，响应时间短的优先分配。 

```
upstream backserver { 
  server server1; 
  server server2; 
  fair; 
} 
```

**5、url_hash（第三方）**
按访问url的hash结果来分配请求，使每个url定向到同一个后端服务器，后端服务器为缓存时比较有效。 

```
upstream backserver { 
	server squid1:3128; 
	server squid2:3128; 
	hash $request_uri; 
	hash_method crc32; 
}
```

在需要使用负载均衡的server中增加 

```
proxy_pass http://backserver/; 
upstream backserver{ 
ip_hash; 
	server 127.0.0.1:9090 down; (down 表示当前的server暂时不参与负载) 
	server 127.0.0.1:8080 weight=2; (weight 默认为1.weight越大，负载的权重就越大) 
	server 127.0.0.1:6060; 
	server 127.0.0.1:7070 backup; (其它所有的非backup机器down或者忙的时候，请求backup机器) 
}
```

max_fails ：允许请求失败的次数默认为1.当超过最大次数时，返回proxy_next_upstream 模块定义的错误 
fail_timeout:max_fails次失败后，暂停的时间

 

## 1 前言

随着网站负载的不断增加，负载均衡（load balance）已不是陌生话题。负载均衡是将流量负载分摊到不同的服务单元，保证服务器的高可用，保证响应足够快，给用户良好的体验。

nginx第一个公开版发布于2004年。2011年发布了1.0版。它的特点是稳定性高、功能强大、资源消耗低。从服务器市场占有率来看，nginx已有与Apache分庭抗礼势头。其中，不得不提到的特性就是其负载均衡功能，这也成了很多公司选择它的主要原因。

我们将从源码的角度介绍nginx的内置负载均衡策略和扩展负载均衡策略，以实际的工业生产为案例，对比各负载均衡策略，为nginx使用者提供一些参考。


## 2. 源码剖析

nginx的负载均衡策略可以划分为两大类：内置策略和扩展策略。

内置策略包含加权轮询和ip hash，在默认情况下这两种策略会编译进nginx内核，只需在nginx配置中指明参数即可。扩展策略有很多，如fair、通用hash、consistent hash等，默认不编译进nginx内核。

由于在nginx版本升级中负载均衡的代码没有本质性的变化，因此下面将以nginx1.0.15稳定版为例，从源码角度分析各个策略。

**2.1. 加权轮询（weighted round robin）**

轮询的原理很简单，首先我们介绍一下轮询的基本流程。如下是处理一次请求的流程图：

![645365-20170225234214585-347986066](Nginx.assets/645365-20170225234214585-347986066.jpg)

图中有两点需要注意：

第一，如果可以把加权轮询算法分为先深搜索和先广搜索，那么nginx采用的是先深搜索算法，即将首先将请求都分给高权重的机器，直到该机器的权值降到了比其他机器低，才开始将请求分给下一个高权重的机器。

第二，当所有后端机器都down掉时，nginx会立即将所有机器的标志位清成初始状态，以避免造成所有的机器都处在timeout的状态，从而导致整个前端被夯住。

接下来看下源码。nginx的目录结构很清晰，加权轮询所在路径为nginx-1.0.15/src/http/ngx_http_upstream_round_robin.[c|h]，在源码的基础上，针对重要的、不易理解的地方我加了注释。首先看下ngx_http_upstream_round_robin.h中的重要声明：

![645365-20170225234322288-719091410](Nginx.assets/645365-20170225234322288-719091410.jpg)

从变量命名中就可以大致猜出其作用。解释一下current_weight和weight的区别，前者为权重排序的值，随着处理请求会动态的变化，后者则是配置值，用来恢复初始状态。

接下我们来看下轮询的创建过程。代码如下图：

![645365-20170225234344085-380815754](Nginx.assets/645365-20170225234344085-380815754.jpg)


这里有个tried变量需要做些说明：tried中记录了服务器当前是否被尝试连接过。他是一个位图。如果服务器数量小于32，则只需在一个int中即可记录下所有服务器状态。如果服务器数量大于32，则需在内存池中申请内存来存储。

对该位图数组的使用可参考如下代码：

![645365-20170225234406507-469037531](Nginx.assets/645365-20170225234406507-469037531.jpg)

最后是实际的策略代码，逻辑较简单，代码实现也只有30行。来看代码。

![645365-20170225234425226-1659393395](Nginx.assets/645365-20170225234425226-1659393395.jpg)

**2.2. ip hash策略**

ip hash是nginx内置的另一个负载均衡策略，流程和轮询很类似，只是其中的算法和具体的策略有些变化。如下图所示：

![645365-20170225234445413-699356313](Nginx.assets/645365-20170225234445413-699356313.jpg)

ip hash算法的核心实现请看如下代码：

![645365-20170225234504663-2143499219](Nginx.assets/645365-20170225234504663-2143499219.jpg)

可以看到，hash值既与ip有关又与后端机器的数量有关。经测试，上述算法可以连续产生1045个互异的value，这是此算法硬限制。nginx使用了保护机制，当经过20次hash仍然找不到可用的机器时，算法退化成轮询。

因此，从本质上说，ip hash算法是一种变相的轮询算法，如果两个ip的初始hash值恰好相同，那么来自这两个ip的请求将永远落在同一台服务器上，这为均衡性埋下了较深隐患。

**2.3. fair**

fair策略是扩展策略，默认不被编译进nginx内核。它根据后端服务器的响应时间判断负载情况，从中选出负载最轻的机器进行分流。
这种策略具有很强的自适应性，但是实际的网络环境往往不是那么简单，因此须慎用。

**2.4.通用hash、一致性hash**

通用hash和一致性hash也是种扩展策略。通用hash可以以nginx内置的变量为key进行hash，一致性hash采用了nginx内置的一致性hash环，可支持memcache。


## 3 对比测试

了解了以上负载均衡策略，接下来我们来做一些测试。
主要是对比各个策略的均衡性、一致性、容灾性等，从而分析出其中的差异性，根据数据给出各自的适用场景。

为了能够全面、客观的测试nginx的负载均衡策略，我们采用两个测试工具、在不同场景下做测试，以此来降低环境对测试结果造成的影响。

首先给大家介绍测试工具、测试网络拓扑和基本之测试流程。

**3.1 测试工具**

*3.1.1 easyABC*

easyABC是百度内部开发的性能测试工具，培训采用epool模型实现，简单易上手，可以模拟GET/POST请求，极限情况下可以提供上万的压力，在团队内部得到广泛使用。

由于被测试对象为反向代理服务器，因此需要在其后端搭建桩服务器，这里用nginx作为桩Web Server，提供最基本的静态文件服务。

*3.1.2 polygraph*

polygraph是一款免费的性能测试工具，以对缓存服务、代理、交换机等方面的测试见长。它有规范的配置语言PGL（Polygraph Language），为软件提供了强大的灵活性。其工作原理如下图所示：

![645365-20170225234534320-1446984275](Nginx.assets/645365-20170225234534320-1446984275.jpg)

polygraph提供Client端和Server端，将测试目标nginx放在二者之间，三者之间的网络交互均走http协议，只需配置ip+port即可。

Client端可以配置虚拟robot的个数以及每个robot发请求的速率，并向代理服务器发起随机的静态文件请求，Server端将按照请求的url生成随机大小的静态文件做响应。

选用这个测试软件的一个主要原因：可以产生随机的url作为nginx各种hash策略key。
另外polygraph还提供了日志分析工具，功能比较丰富，感兴趣的同学可以参考附录材料。

**3.2. 测试环境**

本次测试运行在5台物理机。其中：被测对象单独搭在一台8核机器上，另外四台4核机器分别搭建了easyABC、webserver桩和polygraph。如下图所示：

![645365-20170225234605788-1877975392](Nginx.assets/645365-20170225234605788-1877975392.jpg)

**3.3. 测试方案**

给各位介绍一下关键的测试指标：

均衡性：是否能够将请求均匀的发送给后端
一致性：同一个key的请求，是否能落到同一台机器
容灾性：当部分后端机器挂掉时，是否能够正常工作

以上述指标为指导，我们针对如下4个测试场景分别用easyABC和polygraph测试：

场景1   server_*均正常提供服务；
场景2   server_4挂掉，其他正常；
场景3   server_3、server_4挂掉，其他正常；
场景4   server_*均恢复正常服务。

上述四个场景将按照时间顺序进行，每个场景将建立在上一个场景基础上，被测试对象无需做任何操作，以最大程度模拟实际情况。

另外，考虑到测试工具自身的特点，在easyabc上的测试压力在17000左右，polygraph上的测试压力在4000左右。以上测试均保证被测试对象可以正常工作，且无任何notice级别以上（alert/error/warn）的日志出现，在每个场景中记录下server_*的qps用于最后的策略分析。

**3.4. 结果**

对比在两种测试工具下的测试结果会发现，结果完全一致，因此可以排除测试工具的影响。表1和图1是轮询策略在两种测试工具下的负载情况。

从图表中可以看出，轮询策略对于均衡性和容灾性都可以做到较好的满足。

![645365-20170225234653116-907128536](Nginx.assets/645365-20170225234653116-907128536.jpg)

![645365-20170225234700304-1028355416](Nginx.assets/645365-20170225234700304-1028355416.jpg)


表2和图2是fair策略在两种测试工具下的负载情况。fair策略受环境影响非常大，在排除了测试工具的干扰之后，结果仍然有非常大的抖动。

从直观上讲，这完全不满足均衡性。但从另一个角度出发，恰恰是由于这种自适应性确保了在复杂的网络环境中能够物尽所用。因此，在应用到工业生产中之前，需要在具体的环境中做好测试工作。

![645365-20170225234724632-1332506884](Nginx.assets/645365-20170225234724632-1332506884.jpg)

![645365-20170225234737710-343142395](Nginx.assets/645365-20170225234737710-343142395.jpg)

以下图表是各种hash策略，所不同的仅仅是hash key或者是具体的算法实现，因此一起做对比。实际测试中发现，通用hash和一致性hash均存在一个问题：当某台后端的机器挂掉时，原有落到这台机器上的流量会丢失，但是在ip hash中就不存在这样的问题。

正如上文中对ip hash源码的分析，当ip hash失效时，会退化为轮询策略，因此不会有丢失流量的情况。从这个层面上说，ip hash也可以看成是轮询的升级版。

![645365-20170225234759945-431914069](Nginx.assets/645365-20170225234759945-431914069.jpg)

图5为ip hash策略，ip hash是nginx内置策略，可以看做是前两种策略的特例：以来源IP为key。

由于测试工具不太擅于模拟海量IP下的请求，因此这里截取线上实际的情况加以分析。如下图所示：

![645365-20170225234821820-56758666](Nginx.assets/645365-20170225234821820-56758666.jpg)

图中前1/3使用轮询策略，中间段使用ip hash策略，后1/3仍然是轮询策略。可以明显的看出，ip hash的均衡性存在着很大的问题。

原因并不难分析，在实际的网络环境中，有大量的高校出口路由器ip、企业出口路由器ip等网络节点，这些节点带来的流量往往是普通用户的成百上千倍，而ip hash策略恰恰是按照ip来划分流量，因此造成上述后果也就自然而然了。


## 4 小结

通过实际的对比测试，我们对nginx各个负载均衡策略进行了验证。下面从均衡性、一致性、容灾性以及适用场景等角度对比各种策略。如下图示：

![645365-20170225234844632-943051456](Nginx.assets/645365-20170225234844632-943051456.jpg)

我们从源码和实际测试数据角度分析说明了nginx负载均衡的策略，给出了各种策略适合的应用场景。通过分析不难发现，无论哪种策略都不是万金油，在具体场景下应该选择哪种策略一定程度上依赖于使用者对策略的熟悉程度。

以上分析和测试数据能够对大家有所帮助，期待有更多越来越好的负载均衡策略涌现，造福更多运维开发同学。
