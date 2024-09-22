#  Basical Notes

>  [3 本手册《高并发手册》、《JVM 核心手册》、《Java 并发编程手册》，工作面试两不误。链接：https://pan.baidu.com/s/1m6468_1Zy0JQHRlBFGcAHQ?pwd=8888 
>
>  [Java 实战演练 35 讲] 链接：https://pan.baidu.com/s/14BXAn_8fh-dem4MM5Kvkbw?pwd=8888
>
>  [10 本校招/社招必刷八股文] 链接：https://pan.baidu.com/s/1cbu4_p7QAdA4fPtIUBRsqw?pwd=8888
>
>  高并发链接：https://pan.baidu.com/s/15YnGEj0OsIJJsuOeNl9Eiw?pwd=4nb8
>
>  Java岗面试核心MCA版链接：https://pan.baidu.com/s/1jffPBQDbpkpZy2pHVHihYw?pwd=kuly 
>
>  2023面试大全链接：https://pan.baidu.com/s/1Y854A_pSmLiIJmRgmLpDUQ?pwd=8888
>
>  2023面试大全-2链接：https://pan.baidu.com/s/1CYRFlC1dELG-YcmChD6prw?pwd=8888
>
>  [一线互联网Java面试核心点(80万字)](https://www.yuque.com/tulingzhouyu/db22bv/td5a84ty4vel22ge)：https://www.yuque.com/tulingzhouyu/db22bv/td5a84ty4vel22ge
>
>  1. [徐庶老师主页](https://space.bilibili.com/1461699434)
>     - Spring全家桶：https://space.bilibili.com/1461699434/channel/seriesdetail?sid=377669
>  2. [徐庶讲Java主页](https://space.bilibili.com/3493297123232325)

## [Algorithm](JavaEESubs/Algorithm.md)

## [DesignPattern](JavaEESubs/DesignPattern.md)

## [JVM](JavaEESubs/JVM.md)

## [LinuxIO](JavaEESubs/LinuxIO.md)

## [NetworkProtocal](JavaEESubs/NetworkProtocal.md)

# Java Notes

## [JavaSE](JavaEESubs/JavaSE.md)

## [Thread](JavaEESubs/Thread.md)

## [JavaSPI](JavaEESubs/JavaSPI.md)

## [JavaWeb](JavaEESubs/JavaWeb.md)

## [MyBatis](JavaEESubs/MyBatis.md)

## [MySQL](JavaEESubs/MySQL.md)

## [Spring](JavaEESubs/Spring.md)

## [SpringMVC](JavaEESubs/SpringMVC.md)

## [SpringBoot](JavaEESubs/SpringBoot.md)

## [WeChat](JavaEESubs/WeChat.md)

# Architucture Notes

## [DistributedSystem](JavaEESubs/DistributedSystem.md)

## [DistributedAlgorithm](JavaEESubs/DistributedAlgorithm.md)

## [MicroService](JavaEESubs/MicroService.md)

## [Nginx](JavaEESubs/Nginx.md)

## [LVS](JavaEESubs/LVS.md)

## [Redis](JavaEESubs/Redis.md)

## [Dubbo](JavaEESubs/Dubbo.md)

## [SpringCloud](JavaEESubs/SpringCloud.md)

## [ShardingSphere](JavaEESubs/ShardingSphere.md)

## [ElasticStack](JavaEESubs/ElasticStack.md)

## [MessageQueue](JavaEESubs/MessageQueue.md)

### [RocketMQ](JavaEESubs/RocketMQ.md)

### [RabbitMQ](JavaEESubs/RabbitMQ.md)

### [Kafka](JavaEESubs/Kafka.md)

## [Register](JavaEESubs/Register.md)

### [ZooKeeper](JavaEESubs/ZooKeeper.md)

### [Eureka](JavaEESubs/Eureka.md)

# Security Notes

## [NetworkSecurity](JavaEESubs/NetworkSecurity.md)

## [SpringSecurity](JavaEESubs/SpringSecurity.md)

# Deploy Notes

## [Linux](JavaEESubs/Linux.md)

## [Docker](JavaEESubs/Docker.md)

## [Kubernetes](JavaEESubs/Kubernetes.md)

## [Apollo](JavaEESubs/Apollo.md)

## [CICD](JavaEESubs/CICD.md)

# Design Notes

## [SystemDesign](JavaEESubs/SystemDesign.md)

# Management Notes

## [ProjectManagement](JavaEESubs/ProjectManagement.md)

## [Business](JavaEESubs/Business.md)

# Auxiliary Notes

## [Swagger](JavaEESubs/Swagger.md)

## [Tests](JavaEESubs/Tests.md)

# Tools

## [Git](JavaEESubs/Git.md)

## [常见内网穿透工具及使用教程](https://mp.weixin.qq.com/s/CG_j6RMtdnPzj5evIyqfYw)

# Others

## [线上事故](JavaEESubs/RealAccident.md)

## 异步编程框架

1. RxJava2
2. Reactor
3. AKKA

## 一些名词

- BOSS：**B**ussiness **O**peration **S**upport **S**ystem：业务操作支持系统
- JWT：**J**son **W**eb **T**oken：基于JSON的WebToken
- Spin Lock：自旋锁
- RTT：Round trip time：往返时间

## 知识体系

```
从项目业务维护的规范性上：
1. 所有的mapper和service层必须使用MyBatisPlus的Generator生成，没有特殊原因不得手动创建Mapper和Service
  1. 这个主要为了简化单表数据查询的效率，因为目前项目使用了MyBatisPlus，那就利用MyBatisPlus特性把代码做到最简
  2. 一张数据表对应一个Mapper，对应一个Service，Mapper只有其对应的Service具有访问权限
2. 需要别的服务模块的数据，需要注入别的模块的service，没有特殊原因禁止直接注入需要的模块的Mapper，模块数据的访问入口只有 Service
  1. 这个主要是出于将来项目结构拆分方便，以及业务维护单一性方面的考虑
  2. 举例，假如我的销售商品管理需要店铺模块的数据，那就 @Autowired BaseShopService, 禁止在销售商品模块中直接 @Autowired BaseShopMapper，如果要调用的服务中没有对应的接口，应该找负责的人员添加接口，而不是自己直接添加
```


## 其他

- Lua
  - [OpenResty](https://openresty.org/cn/) is a dynamic web platform based on NGINX and LuaJIT.
    - LuaJIT：Lua语言的解析引擎
  
- Tengine
  - [Tengine](http://tengine.taobao.org/)是由淘宝网发起的Web服务器项目。它在[Nginx](http://nginx.org/) 的基础上，针对大访问量网站的需求，添加了很多高级功能和特性。Tengine的性能和稳定性已经在大型的网站如[淘宝网](http://www.taobao.com/) ，[天猫商城](http://www.tmall.com/) 等得到了很好的检验。它的最终目标是打造一个高效、稳定、安全、易用的Web平台。
  
- Cassandra

  - 暂时理解为：列式数据库

- XXL-JOB

  - 一个轻量级分布式任务调度平台，其核心设计目标是开发迅速、学习简单、轻量级、易扩展。 现已开放源代码并接入多家公司线上产品线，开箱即用。

- Tomcat Pipline

## 常见的组件端口

在微服务架构中，不同的服务可能会使用不同的端口来提供服务。端口的选择通常取决于服务的类型、所使用的协议以及是否遵循特定的行业标准。以下是一些常见的服务及其默认端口：

| 服务类型       | 服务名称              | 默认端口                                                     |
| -------------- | --------------------- | ------------------------------------------------------------ |
| 数据库服务     | MySQL                 | 3306                                                         |
| 数据库服务     | PostgreSQL            | 5432                                                         |
| 数据库服务     | MongoDB               | 27017                                                        |
| 搜索引擎       | Elasticsearch         | 9200 (HTTP API) / 9300 (内部通信)                            |
| 缓存服务       | Redis                 | 6379                                                         |
| 消息队列       | Kafka                 | 9092                                                         |
| 消息队列       | RabbitMQ              | 5672 (AMQP) / 15672 (管理界面)                               |
| 服务发现与配置 | Consul                | 8500 (HTTP API)<br/>8300 (RPC)<br/>8301 (Serf LAN)<br/>8302 (Serf WAN) |
| 服务发现与配置 | ZooKeeper             | 2181 (客户端通信)                                            |
| 反向代理服务器 | Nginx                 | 80 (HTTP) / 443 (HTTPS)                                      |
| 分布式追踪系统 | Zipkin                | 9411                                                         |
| 分布式追踪系统 | Jaeger                | 14268 (HTTP API) / 16686 (UI)                                |
| 监控系统       | Prometheus            | 9090                                                         |
| 容器管理       | Docker                | 2375 (未加密的远程 API) / 2376 (加密的远程 API)              |
| 集群管理       | Kubernetes API Server | 6443                                                         |
| 监控仪表板     | Grafana               | 3000                                                         |
| 数据可视化     | Kibana                | 5601                                                         |

请注意，实际部署时，端口可能会根据具体需求和安全策略进行调整。此外，某些服务可能支持通过环境变量或配置文件来指定端口，以便在不同的部署环境中使用不同的端口。
