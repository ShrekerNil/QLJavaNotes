# SpringCloudEureka 1 - 总览篇

原文：[Spring Cloud Eureka 全解](https://zhuanlan.zhihu.com/p/34976125)

本文基于[SpringCloud-Dalston.SR5](https://link.zhihu.com/?target=http%3A//cloud.spring.io/spring-cloud-static/Dalston.SR5/)

Eureka作为服务注册中心对整个微服务架构起着最核心的整合作用，因此对Eureka还是有很大的必要进行深入研究。

Eureka 1.x版本是纯基于servlet的应用。为了与spring cloud结合使用，除了本身eureka代码，还有个粘合模块spring-cloud-netflix-eureka-server。在我们启动EurekaServer实例的时候，只用加入对于spring-cloud-starter-eureka-server的依赖即可。之后通过@EnableEurekaServer注解即可启动一个Eureka服务器实例。

## What is Spring Cloud Netflix?

其官方文档中对自己的定义是：

> Spring Cloud Netflix provides Netflix OSS integrations for Spring Boot apps through autoconfiguration and binding to the Spring Environment and other Spring programming model idioms. With a few simple annotations you can quickly enable and configure the common patterns inside your application and build large distributed systems with battle-tested Netflix components. The patterns provided include Service Discovery (Eureka), Circuit Breaker (Hystrix), Intelligent Routing (Zuul) and Client Side Load Balancing (Ribbon)..

Spring Cloud Netflix这个项目对于Spring Boot应用来说，它集成了NetFlix OSS的一些组件，只需通过注解配置和Spring环境的通用简单的使用注解，你可以快速的启用和配置这些久经测试考验的NetFlix的组件于你的应用和用于构建分布式系统中。这些组件包含的功能有服务发现（Eureka），熔断器（Hystrix），智能路由(Zuul)以及客户端的负载均衡器（Ribbon）
简单的来说，Spring Cloud NetFlix这个项目对NetFlix中一些久经考验靠谱的服务发现，熔断，网关，智能路由，以及负载均衡等做了封装，并通过注解的或简单配置的方式提供给Spring Cloud用户用。

## What is Eureka?

> Eureka is a REST (Representational State Transfer) based service that is primarily used in the AWS cloud for locating services for the purpose of load balancing and failover of middle-tier servers. We call this service, the Eureka Server. Eureka also comes with a Java-based client component,the Eureka Client, which makes interactions with the service much easier. The client also has a built-in load balancer that does basic round-robin load balancing. At Netflix, a much more sophisticated load balancer wraps Eureka to provide weighted load balancing based on several factors like traffic, resource usage, error conditions etc to provide superior resiliency.

简单来说Eureka就是Netflix开源的一款提供服务注册和发现的产品，并且提供了相应的Java客户端。

## Spring Cloud Eureka 与 Eureka

其实有点不太一样，Spring Cloud Netflix提供的胶水代码更换了一些初始化配置，并且去掉了一些不合理的例如单实例EurekaServer服务等待时间，还增加了更人性化的界面：



![img](Eureka.assets/v2-8e84c3490da8ccc24bf134dff80b3f64_720w.jpg)



## Eureka VS ZOOKEEPER



![img](Eureka.assets/v2-41a44f3ce4986ae7e49562c54c5f1647_720w.jpg)



从设计思路上看，Eureka是AP型设计，ZOOKEEPER是CP型设计：

1. Eureka不持久化，缓存，Zookeeper持久化，对于注册中心没必要持久化，我们只关心当前瞬时的服务状态
2. Eureka通过增量更新注册信息，Zookeeper通过Watch事件监控变化，对于服务注册变化的过程，我们不关心，只关心瞬时状态
3. Eureka提供客户端缓存，Zookeeper无客户端缓存，在网络隔离注册中心访问不了的情况下，宁可返回某服务5分钟之前在哪几个服务器上可用的信息，也不能因为暂时的网络故障而找不到可用的服务器

综上所述，Eureka适合作为服务注册发现中心，Zookeeper适合更广泛的分布式协调服务

## Eureka架构



![img](Eureka.assets/v2-a26112df5bd821215c9cc2a75d4d92f1_720w.jpg)



比较细节的架构图如下所示，之后的文章我们会详细解释：

![img](Eureka.assets/v2-2c52a01af9c1fd76b12023d85e110930_720w.jpg)



## EurekaServer 关键API与用途解释

**注意，这个和官网的不一样，在SpringCloud环境下，context-path就是eureka**

![img](Eureka.assets/v2-1a32f095ec777f118374e5758f687fce_720w.jpg)

# SpringCloudEureka 2 - 整体流程篇

之前我们看过这个整体流程图：

![img](Eureka.assets/v2-2c52a01af9c1fd76b12023d85e110930_720w.jpg)

接下来我们来仔细分析下这个流程，**先不涉及源代码，只说流程**

## 服务提供者EurekaClient -> EurekaServer

每个服务会生成自己的InstanceInfo：

![img](Eureka.assets/v2-0cdd9bb6bf14ebe3ab47545a53da6f2a_720w.jpg)



除了这些，还有两个比较重要的配置

> 服务过期时间配置：eureka.instance.lease-expiration-duration-in-seconds
> 服务刷新时间配置：eureka.instance.lease-renewal-interval-in-seconds

EurekaServer会根据**服务过期时间**清理过期实例，同时会定时调用renew接口维持心跳，这个心跳周期由**服务刷新时间**配置决定。

同时，在实例初始化之后，服务提供者通过register接口注册实例。每隔**服务信息更新时间**检查本地信息是否过期，如果过期通过register接口更新InstanceInfo

> 服务信息更新时间配置（一般不配置，因为实例信息基本不会更新）：eureka.client.instance-info-replication-interval-seconds

## EurekaServer内部缓存

服务实例注册，会放入registry这个ConcurrentHashMap中：

```text
private final ConcurrentHashMap<String, Map<String, Lease<InstanceInfo>>> registry
            = new ConcurrentHashMap<String, Map<String, Lease<InstanceInfo>>>();
```

其实就是把客户端生成的InstanceInfo放入这个registry的Map中。但是在服务消费者EurekaClient端获取所有服务与实例列表，并不是直接读取这个registry，而是从ResponseCache中获取。

ResponseCache包括两部分：ReadWriteMap和ReadOnlyMap；ReadWriteMap
就是一个Guava的LoadingCache。
在EurekaServer端，所有的读取请求都是读的ReadOnlyMap（这个可以配置），如果不存在则读取ReadWriteMap，如果不存在就从Registry拉取（LoadingCache的机制），实例信息更新会主动失效ReadWriteMap触发从Registry拉取。 ReadWriteMap比Registry多了两个key（ALL*APP还有ALL*APP_DELTA）

有定时任务会定时从ReadWriteMap同步到ReadOnlyMap这个时间配置是：**eureka server刷新readCacheMap的时间**，注意，client读取的是readCacheMap，这个时间决定了多久会把readWriteCacheMap的缓存更新到readCacheMap上

> eureka server刷新readCacheMap的时间配置：eureka.server.responseCacheUpdateInvervalMs

ReadWriteMap是一个LoadingCache，将Registry中的服务实例信息封装成要返回的http响应（分别是经过gzip压缩和非压缩的），同时还有两个特殊key，ALL*APPS和ALL*APPS*DELTA
ALL*APPS就是所有服务实例信息
ALL*APPS*DELTA就是所有服务实例增量信息

这里面其中的内容，我们先不考虑；

EurekaServer内部有定时任务，每隔**检查过期实例时间**，扫描Registry里面过期的实例并删除，并且使对应的ReadWriteMap缓存失效：

> 检查过期实例时间配置：eureka.server.eviction-interval-timer-in-ms

## EurekaServer -> 服务消费者EurekaClient

每隔**增量获取服务列表时间**配置向EurekaServer请求一次增量服务实例列表集合

> 增量获取服务列表时间配置：eureka.client.registryFetchIntervalSeconds

同时，SpringCloud环境下服务消费者调用一般用Ribbon做负载均衡，从Eureka所有服务所有实例缓存到Ribbon某个服务所有实例缓存，也是有定时任务，每隔**Ribbon服务实例列表刷新时间**同步

> Ribbon服务实例列表刷新时间配置：ribbon.ServerListRefreshInterval

# SpringCloudEureka 3 - 服务注册与取消

## 关于服务注册

> 开启/关闭服务注册配置：eureka.client.register-with-eureka = true （默认）

## 什么时候注册？



1. 应用第一次启动时，初始化EurekaClient时，应用状态改变：从STARTING变为UP会触发这个Listener，调用instanceInfoReplicator.onDemandUpdate();
   可以推测出，实例状态改变时，也会通过注册接口更新实例状态信息

```java
statusChangeListener = new ApplicationInfoManager.StatusChangeListener() {
  @Override
  public String getId() {
    return "statusChangeListener";
  }

  @Override
  public void notify(StatusChangeEvent statusChangeEvent) {
    if (InstanceStatus.DOWN == statusChangeEvent.getStatus() ||
        InstanceStatus.DOWN == statusChangeEvent.getPreviousStatus()) {
      // log at warn level if DOWN was involved
      logger.warn("Saw local status change event {}", statusChangeEvent);
    } else {
      logger.info("Saw local status change event {}", statusChangeEvent);
    }
    instanceInfoReplicator.onDemandUpdate();
  }
};
```



1. 定时任务，如果InstanceInfo发生改变，也会通过注册接口更新信息

```java
public void run() {
  try {
    discoveryClient.refreshInstanceInfo();
    //如果实例信息发生改变，则需要调用register更新InstanceInfo
    Long dirtyTimestamp = instanceInfo.isDirtyWithTime();
    if (dirtyTimestamp != null) {
      discoveryClient.register();
      instanceInfo.unsetIsDirty(dirtyTimestamp);
    }
  } catch (Throwable t) {
    logger.warn("There was a problem with the instance info replicator", t);
  } finally {
    Future next = scheduler.schedule(this, replicationIntervalSeconds, TimeUnit.SECONDS);
    scheduledPeriodicRef.set(next);
  }
}
```



1. 在定时renew时，如果renew接口返回404（代表这个实例在EurekaServer上面找不到），可能是之前注册失败或者注册过期导致的。这时需要调用register重新注册

```java
boolean renew() {
  EurekaHttpResponse<InstanceInfo> httpResponse;
  try {
    httpResponse = eurekaTransport.registrationClient.sendHeartBeat(
      instanceInfo.getAppName(), instanceInfo.getId(), instanceInfo, null);
    logger.debug("{} - Heartbeat status: {}", PREFIX + appPathIdentifier,
                 httpResponse.getStatusCode());
    //如果renew接口返回404（代表这个实例在EurekaServer上面找不到），可能是之前注册失败或者注册过期导致的
    if (httpResponse.getStatusCode() == 404) {
      REREGISTER_COUNTER.increment();
      logger.info("{} - Re-registering apps/{}", PREFIX + appPathIdentifier, 
                  instanceInfo.getAppName());
      long timestamp = instanceInfo.setIsDirtyWithTime();
      boolean success = register();
      if (success) {
        instanceInfo.unsetIsDirty(timestamp);
      }
      return success;
    }
    return httpResponse.getStatusCode() == 200;
  } catch (Throwable e) {
    logger.error("{} - was unable to send heartbeat!", PREFIX + appPathIdentifier, e);
    return false;
  }
}
```

## 向Eureka发送注册请求EurekaServer发生了什么？

主要有两个存储，一个是之前提到过的registry，还有一个最近变化队列，后面我们会知道，这个最近变化队列里面就是客户端获取增量实例信息的内容：

```java
// 整体注册信息缓存
private final ConcurrentHashMap<String, Map<String, Lease<InstanceInfo>>> registry = 
  new ConcurrentHashMap<String, Map<String, Lease<InstanceInfo>>>();
// 最近变化队列
private ConcurrentLinkedQueue<RecentlyChangedItem> recentlyChangedQueue = 
  new ConcurrentLinkedQueue<RecentlyChangedItem>();
```

EurekaServer收到实例注册主要分两步：



- 调用父类方法注册
- 同步到其他EurekaServer实例

```java
public void register(InstanceInfo info, boolean isReplication) {
  int leaseDuration = 90;
  if (info.getLeaseInfo() != null && info.getLeaseInfo().getDurationInSecs() > 0) {
    leaseDuration = info.getLeaseInfo().getDurationInSecs();
  }
  //调用父类方法注册
  super.register(info, leaseDuration, isReplication);
  //同步到其他EurekaServer实例
  this.replicateToPeers(PeerAwareInstanceRegistryImpl.Action.Register, 
                        info.getAppName(),
                        info.getId(), info, (InstanceStatus)null, isReplication);
}
```

我们先看**同步到其他EurekaServer实例**

其实就是，注册到的EurekaServer再依次调用其他集群内的EurekaServer的Register方法将实例信息同步过去

```java
private void replicateToPeers(Action action, String appName, String id,
                              InstanceInfo info /* optional */,
                              InstanceStatus newStatus /* optional */, boolean isReplication) {
  Stopwatch tracer = action.getTimer().start();
  try {
    if (isReplication) {
      numberOfReplicationsLastMin.increment();
    }
    // If it is a replication already, do not replicate again as this will create a poison replication
    if (peerEurekaNodes == Collections.EMPTY_LIST || isReplication) {
      return;
    }

    for (final PeerEurekaNode node : peerEurekaNodes.getPeerEurekaNodes()) {
      // If the url represents this host, do not replicate to yourself.
      if (peerEurekaNodes.isThisMyUrl(node.getServiceUrl())) {
        continue;
      }
      replicateInstanceActionsToPeers(action, appName, id, info, newStatus, node);
    }
  } finally {
    tracer.stop();
  }
}

private void replicateInstanceActionsToPeers(Action action, String appName,
             String id, InstanceInfo info, InstanceStatus newStatus,
             PeerEurekaNode node) {
  try {
    InstanceInfo infoFromRegistry = null;
    CurrentRequestVersion.set(Version.V2);
    switch (action) {
      case Cancel:
        node.cancel(appName, id);
        break;
      case Heartbeat:
        InstanceStatus overriddenStatus = overriddenInstanceStatusMap.get(id);
        infoFromRegistry = getInstanceByAppAndId(appName, id, false);
        node.heartbeat(appName, id, infoFromRegistry, overriddenStatus, false);
        break;
      case Register:
        node.register(info);
        break;
      case StatusUpdate:
        infoFromRegistry = getInstanceByAppAndId(appName, id, false);
        node.statusUpdate(appName, id, newStatus, infoFromRegistry);
        break;
      case DeleteStatusOverride:
        infoFromRegistry = getInstanceByAppAndId(appName, id, false);
        node.deleteStatusOverride(appName, id, infoFromRegistry);
        break;
    }
  } catch (Throwable t) {
    logger.error("Cannot replicate information to {} for action {}", 
                 node.getServiceUrl(), action.name(), t);
  }
}
```

然后看看调用父类方法注册：

```java
public void register(InstanceInfo registrant, int leaseDuration, boolean isReplication) {
  try {
    //register虽然看上去好像是修改，但是这里用的是读锁，后面会解释
    read.lock();
    //从registry中查看这个app是否存在
    Map<String, Lease<InstanceInfo>> gMap = registry.get(registrant.getAppName());
    //不存在就创建
    if (gMap == null) {
      final ConcurrentHashMap<String, Lease<InstanceInfo>> gNewMap = 
        new ConcurrentHashMap<String, Lease<InstanceInfo>>();
      gMap = registry.putIfAbsent(registrant.getAppName(), gNewMap);
      if (gMap == null) {
        gMap = gNewMap;
      }
    }
    //查看这个app的这个实例是否已存在
    Lease<InstanceInfo> existingLease = gMap.get(registrant.getId());

    if (existingLease != null && (existingLease.getHolder() != null)) {
      //如果已存在，对比时间戳，保留比较新的实例信息......
    } else {
      // 如果不存在，证明是一个新的实例
      //更新自我保护监控变量的值的代码.....

    }
    Lease<InstanceInfo> lease = new Lease<InstanceInfo>(registrant, leaseDuration);
    if (existingLease != null) {
      lease.setServiceUpTimestamp(existingLease.getServiceUpTimestamp());
    }
    //放入registry
    gMap.put(registrant.getId(), lease);

    //加入最近修改的记录队列
    recentlyChangedQueue.add(new RecentlyChangedItem(lease));
    //初始化状态，记录时间等相关代码......

    //主动让Response缓存失效
    invalidateCache(registrant.getAppName(), 
                    registrant.getVIPAddress(), 
                    registrant.getSecureVipAddress());
  } finally {
    read.unlock();
  }
}
```

总结起来，就是主要三件事：

1.将实例注册信息放入或者更新registry

2.将实例注册信息加入最近修改的记录队列

3.主动让Response缓存失效

我们来类比下服务取消

## 服务取消CANCEL

```java
protected boolean internalCancel(String appName, String id, boolean isReplication) {
  try {
    //cancel虽然看上去好像是修改，但是这里用的是读锁，后面会解释
    read.lock();

    //从registry中剔除这个实例
    Map<String, Lease<InstanceInfo>> gMap = registry.get(appName);
    Lease<InstanceInfo> leaseToCancel = null;
    if (gMap != null) {
      leaseToCancel = gMap.remove(id);
    }
    if (leaseToCancel == null) {
      logger.warn("DS: Registry: cancel failed because Lease is not registered for: {}/{}", appName, id);
      return false;
    } else {
      //改变状态，记录状态修改时间等相关代码......
      if (instanceInfo != null) {
        instanceInfo.setActionType(ActionType.DELETED);
        //加入最近修改的记录队列
        recentlyChangedQueue.add(new RecentlyChangedItem(leaseToCancel));
      }
      //主动让Response缓存失效
      invalidateCache(appName, vip, svip);
      logger.info("Cancelled instance {}/{} (replication={})", appName, id, isReplication);
      return true;
    }
  } finally {
    read.unlock();
  }
}
```

总结起来，也是主要三件事：

1.从registry中剔除这个实例

2.将实例注册信息加入最近修改的记录队列

3.主动让Response缓存失效

这里我们注意到了这个最近修改队列，我们来详细看看

## 最近修改队列

这个最近修改队列和消费者定时获取服务实例列表有着密切的关系

```java
private TimerTask getDeltaRetentionTask() {
  return new TimerTask() {

    @Override
    public void run() {
      Iterator<RecentlyChangedItem> it = recentlyChangedQueue.iterator();
      while (it.hasNext()) {
        if (it.next().getLastUpdateTime() <
            System.currentTimeMillis() - serverConfig.getRetentionTimeInMSInDeltaQueue()) {
          it.remove();
        } else {
          break;
        }
      }
    }
  };
}
```

这个RetentionTimeInMSInDeltaQueue默认是180s（配置是eureka.server.retention-time-in-m-s-in-delta-queue,默认是180s，**官网写错了**），可以看出这个队列是一个长度为180s的滑动窗口，保存最近180s以内的应用实例信息修改，后面我们会看到，客户端调用获取增量信息，实际上就是从这个queue中读取，所以可能一段时间内读取到的信息都是一样的。

# SpringCloudEureka 4 - 服务与实例列表获取

## EurekaClient端

我们从Ribbon说起：EurekaClient也存在缓存，应用服务实例列表信息在每个EurekaClient服务消费端都有缓存。一般的，Ribbon的LoadBalancer会读取这个缓存，来知道当前有哪些实例可以调用，从而进行负载均衡。这个loadbalancer同样也有缓存。

首先看这个LoadBalancer的缓存更新机制，相关类是PollingServerListUpdater：

```java
final Runnable wrapperRunnable = new Runnable() {
  @Override
  public void run() {
    if (!isActive.get()) {
      if (scheduledFuture != null) {
        scheduledFuture.cancel(true);
      }
      return;
    }
    try {
      //从EurekaClient缓存中获取服务实例列表，保存在本地缓存
      updateAction.doUpdate();
      lastUpdated = System.currentTimeMillis();
    } catch (Exception e) {
      logger.warn("Failed one update cycle", e);
    }
  }
};

//定时调度
scheduledFuture = getRefreshExecutor().scheduleWithFixedDelay(
  wrapperRunnable,
  initialDelayMs,
  refreshIntervalMs,
  TimeUnit.MILLISECONDS
);
```

这个updateAction.doUpdate();就是从EurekaClient缓存中获取服务实例列表，保存在BaseLoadBalancer的本地缓存：

```java
protected volatile List<Server> allServerList = Collections.synchronizedList(new ArrayList<Server>());

public void setServersList(List lsrv) {
  //写入allServerList的代码，这里略
}

@Override
public List<Server> getAllServers() {
  return Collections.unmodifiableList(allServerList);
}
```

这里的getAllServers会在每个负载均衡规则中被调用，例如RoundRobinRule：

```java
public Server choose(ILoadBalancer lb, Object key) {
  if (lb == null) {
    log.warn("no load balancer");
    return null;
  }

  Server server = null;
  int count = 0;
  while (server == null && count++ < 10) {
    List<Server> reachableServers = lb.getReachableServers();
    //获取服务实例列表，调用的就是刚刚提到的getAllServers
    List<Server> allServers = lb.getAllServers();
    int upCount = reachableServers.size();
    int serverCount = allServers.size();

    if ((upCount == 0) || (serverCount == 0)) {
      log.warn("No up servers available from load balancer: " + lb);
      return null;
    }

    int nextServerIndex = incrementAndGetModulo(serverCount);
    server = allServers.get(nextServerIndex);

    if (server == null) {
      /* Transient. */
      Thread.yield();
      continue;
    }

    if (server.isAlive() && (server.isReadyToServe())) {
      return (server);
    }

    // Next.
    server = null;
  }

  if (count >= 10) {
    log.warn("No available alive servers after 10 tries from load balancer: "
             + lb);
  }
  return server;
}
```

这个缓存需要注意下，有时候我们只修改了EurekaClient缓存的更新时间，但是没有修改这个LoadBalancer的刷新本地缓存时间，就是`ribbon.ServerListRefreshInterval`,这个参数可以设置的很小，因为没有从网络读取，就是从一个本地缓存刷到另一个本地缓存（如何配置缓存配置来实现服务实例快速下线快速感知快速刷新，[可以参考我的另一篇文章](https://link.zhihu.com/?target=http%3A//blog.csdn.net/zhxdick/article/details/78560993)）。

然后我们来看一下EurekaClient本身的缓存，直接看关键类DiscoveryClient的相关源码，我们这里只关心本地Region的，多Region配置我们先忽略：

```java
//本地缓存，可以理解为是一个软链接
private final AtomicReference<Applications> localRegionApps = new AtomicReference<Applications>();

private void initScheduledTasks() {
  //如果配置为需要拉取服务列表，则设置定时拉取任务，这个配置默认是需要拉取服务列表
  if (clientConfig.shouldFetchRegistry()) {
    // registry cache refresh timer
    int registryFetchIntervalSeconds = clientConfig.getRegistryFetchIntervalSeconds();
    int expBackOffBound = clientConfig.getCacheRefreshExecutorExponentialBackOffBound();
    scheduler.schedule(
      new TimedSupervisorTask(
        "cacheRefresh",
        scheduler,
        cacheRefreshExecutor,
        registryFetchIntervalSeconds,
        TimeUnit.SECONDS,
        expBackOffBound,
        new CacheRefreshThread()
      ),
      registryFetchIntervalSeconds, TimeUnit.SECONDS);
  }
  //其他定时任务初始化的代码，忽略
}

//定时从EurekaServer拉取服务列表的任务
class CacheRefreshThread implements Runnable {
  public void run() {
    refreshRegistry();
  }
}

void refreshRegistry() {
  try {
    //多Region配置处理代码，忽略

    boolean success = fetchRegistry(remoteRegionsModified);
    if (success) {
      registrySize = localRegionApps.get().size();
      lastSuccessfulRegistryFetchTimestamp = System.currentTimeMillis();
    }

    //日志代码，忽略
  } catch (Throwable e) {
    logger.error("Cannot fetch registry from server", e);
  }        
}

//定时从EurekaServer拉取服务列表的核心方法
private boolean fetchRegistry(boolean forceFullRegistryFetch) {
  Stopwatch tracer = FETCH_REGISTRY_TIMER.start();

  try {
    Applications applications = getApplications();

    //判断，如果是第一次拉取，或者app列表为空，就进行全量拉取，否则就会进行增量拉取
    if (clientConfig.shouldDisableDelta()
        || (!Strings.isNullOrEmpty(clientConfig.getRegistryRefreshSingleVipAddress()))
        || forceFullRegistryFetch
        || (applications == null)
        || (applications.getRegisteredApplications().size() == 0)
        || (applications.getVersion() == -1)) //Client application does not have latest library supporting delta
    {
      getAndStoreFullRegistry();
    } else {
      getAndUpdateDelta(applications);
    }
    applications.setAppsHashCode(applications.getReconcileHashCode());
    logTotalInstances();
  } catch (Throwable e) {
    logger.error(PREFIX + appPathIdentifier + " - was unable to refresh its cache! status = " + e.getMessage(), e);
    return false;
  } finally {
    if (tracer != null) {
      tracer.stop();
    }
  }

  //缓存更新完成，发送个event给观察者，目前没啥用 
  onCacheRefreshed();

  // 检查下远端的服务实例列表里面包括自己，并且状态是否对，这里我们不关心
  updateInstanceRemoteStatus();

  // registry was fetched successfully, so return true
  return true;
}

//全量拉取代码
private void getAndStoreFullRegistry() throws Throwable {
  long currentUpdateGeneration = fetchRegistryGeneration.get();

  Applications apps = null;
  //访问/eureka/apps接口，拉取所有服务实例信息
  EurekaHttpResponse<Applications> httpResponse = clientConfig.getRegistryRefreshSingleVipAddress() == null
    ? eurekaTransport.queryClient.getApplications(remoteRegionsRef.get())
    : eurekaTransport.queryClient.getVip(clientConfig.getRegistryRefreshSingleVipAddress(), remoteRegionsRef.get());
  if (httpResponse.getStatusCode() == Status.OK.getStatusCode()) {
    apps = httpResponse.getEntity();
  }
  logger.info("The response status is {}", httpResponse.getStatusCode());

  if (apps == null) {
    logger.error("The application is null for some reason. Not storing this information");
  } else if (fetchRegistryGeneration.compareAndSet(currentUpdateGeneration, currentUpdateGeneration + 1)) {
    localRegionApps.set(this.filterAndShuffle(apps));
    logger.debug("Got full registry with apps hashcode {}", apps.getAppsHashCode());
  } else {
    logger.warn("Not updating applications as another thread is updating it already");
  }
}

//增量拉取代码

private void getAndUpdateDelta(Applications applications) throws Throwable {
  long currentUpdateGeneration = fetchRegistryGeneration.get();

  Applications delta = null;
  //访问/eureka/delta接口，拉取所有服务实例增量信息
  EurekaHttpResponse<Applications> httpResponse = eurekaTransport.queryClient.getDelta(remoteRegionsRef.get());
  if (httpResponse.getStatusCode() == Status.OK.getStatusCode()) {
    delta = httpResponse.getEntity();
  }

  if (delta == null) {
    //如果delta为空，拉取增量失败，就全量拉取
    logger.warn("The server does not allow the delta revision to be applied because it is not safe. "
                + "Hence got the full registry.");
    getAndStoreFullRegistry();
  } else if (fetchRegistryGeneration.compareAndSet(currentUpdateGeneration, currentUpdateGeneration + 1)) {
    //这里设置原子锁的原因是怕某次调度网络请求时间过长，导致同一时间有多线程拉取到增量信息并发修改
    //拉取增量成功，检查hashcode是否一样，不一样的话也会全量拉取
    logger.debug("Got delta update with apps hashcode {}", delta.getAppsHashCode());
    String reconcileHashCode = "";
    if (fetchRegistryUpdateLock.tryLock()) {
      try {
        updateDelta(delta);
        reconcileHashCode = getReconcileHashCode(applications);
      } finally {
        fetchRegistryUpdateLock.unlock();
      }
    } else {
      logger.warn("Cannot acquire update lock, aborting getAndUpdateDelta");
    }
    // There is a diff in number of instances for some reason
    if (!reconcileHashCode.equals(delta.getAppsHashCode()) || clientConfig.shouldLogDeltaDiff()) {
      reconcileAndLogDifference(delta, reconcileHashCode);  // this makes a remoteCall
    }
  } else {
    logger.warn("Not updating application delta as another thread is updating it already");
    logger.debug("Ignoring delta update with apps hashcode {}, as another thread is updating it already", delta.getAppsHashCode());
  }
}
```

以上就是对于EurekaClient拉取服务实例信息的源代码分析，总结EurekaClient 重要缓存如下：



1. EurekaClient第一次全量拉取，定时增量拉取应用服务实例信息，保存在缓存中。
2. EurekaClient增量拉取失败，或者增量拉取之后对比hashcode发现不一致，就会执行全量拉取，这样避免了网络某时段分片带来的问题。
3. 同时对于服务调用，如果涉及到ribbon负载均衡，那么ribbon对于这个实例列表也有自己的缓存，这个缓存定时从EurekaClient的缓存更新

## EurekaServer端

在EurekaServer端，所有的读取请求都是读的ReadOnlyMap（这个可以配置）
有定时任务会定时从ReadWriteMap同步到ReadOnlyMap这个时间配置是：

```properties
#eureka server刷新readCacheMap的时间，注意，client读取的是readCacheMap，这个时间决定了多久会把readWriteCacheMap的缓存更新到readCacheMap上
#默认30s
eureka.server.responseCacheUpdateInvervalMs=3000
```

相关代码：

```java
if (shouldUseReadOnlyResponseCache) {
  timer.schedule(getCacheUpdateTask(),
                 new Date(((System.currentTimeMillis() / responseCacheUpdateIntervalMs) * responseCacheUpdateIntervalMs) + responseCacheUpdateIntervalMs), responseCacheUpdateIntervalMs);
}
private TimerTask getCacheUpdateTask() {
  return new TimerTask() {
    @Override
    public void run() {
      logger.debug("Updating the client cache from response cache");
      for (Key key : readOnlyCacheMap.keySet()) {
        if (logger.isDebugEnabled()) {
          Object[] args = {key.getEntityType(), key.getName(), key.getVersion(), key.getType()};
          logger.debug("Updating the client cache from response cache for key : {} {} {} {}", args);
        }
        try {
          CurrentRequestVersion.set(key.getVersion());
          Value cacheValue = readWriteCacheMap.get(key);
          Value currentCacheValue = readOnlyCacheMap.get(key);
          if (cacheValue != currentCacheValue) {
            readOnlyCacheMap.put(key, cacheValue);
          }
        } catch (Throwable th) {
          logger.error("Error while updating the client cache from response cache", th);
        }
      }
    }
  };
}
```

ReadWriteMap是一个LoadingCache，将Registry中的服务实例信息封装成要返回的http响应（分别是经过gzip压缩和非压缩的），同时还有两个特殊key，ALLAPPS和ALLAPPSDELTA
ALLAPPS就是所有服务实例信息
ALLAPPSDELTA就是之前讲注册说的RecentlyChangedQueue里面的实例列表封装的http响应信息

# SpringCloudEureka 5 - 自我保护机制

## 自我保护机制

> 关闭自我保护机制（默认是打开的）：eureka.server.enable-self-preservation=false

自我保护机制：默认情况下，如果Eureka Server在一定时间内没有接收到某个微服务实例的心跳，Eureka Server将会注销该实例（默认90秒）。但是当网络分区故障发生时，微服务与Eureka Server之间无法正常通信，以上行为可能变得非常危险了——因为微服务本身其实是健康的，此时本不应该注销这个微服务。

Eureka通过“自我保护模式”来解决这个问题——当Eureka Server节点在短时间内丢失过多客户端时（可能发生了网络分区故障），那么这个节点就会进入自我保护模式。一旦进入该模式，Eureka Server就会保护服务注册表中的信息，不再删除服务注册表中的数据（也就是不会注销任何微服务）。当网络故障恢复后，该Eureka Server节点会自动退出自我保护模式。

综上，自我保护模式是一种应对网络异常的安全保护措施。它的架构哲学是宁可同时保留所有微服务（健康的微服务和不健康的微服务都会保留），也不盲目注销任何健康的微服务。使用自我保护模式，可以让Eureka集群更加的健壮、稳定。

**但是，在我们实际生产中，我们云环境同一个Region下不会发生大规模网络分区状况，所以没有启用自我保护。**

> 相关参数：eureka.server.renewalPercentThreshold = 0.85

## 整体逻辑



![img](Eureka.assets/v2-deaedc55faa4720d21ed07304c52df07_720w.jpg)



在每一个服务实例注册时：

```text
expectedNumberOfRenewsPerMin += 2
numberOfRenewsPerMinThreshold = RenewalPercentThreshold*numberOfRenewsPerMinThreshold
```

无论你设置心跳时间是多少，expectedNumberOfRenewsPerMin都是+2（默认心跳时间是30s，每分钟有60s，所以+2，但是没有根据真正的心跳时间修改，**应该算是个缺陷**）

在收到心跳时：

```text
renewsLastMin.increment()
```

当`renewsLastMin<numberOfRenewsPerMinThreshold`，就会触发自我保护，不会失效过期服务

# SpringCloudEureka 6 - 一些热门QA

## Eureka服务实例启动时，是否会立刻向EurekaServer注册?

是的，立刻注册。

EurekaClient在每次实例状态发生改变时，有一个Listener：

```java
statusChangeListener = new ApplicationInfoManager.StatusChangeListener() {
  @Override
  public String getId() {
    return "statusChangeListener";
  }

  @Override
  public void notify(StatusChangeEvent statusChangeEvent) {
    if (InstanceStatus.DOWN == statusChangeEvent.getStatus() ||
        InstanceStatus.DOWN == statusChangeEvent.getPreviousStatus()) {
      // log at warn level if DOWN was involved
      logger.warn("Saw local status change event {}", statusChangeEvent);
    } else {
      logger.info("Saw local status change event {}", statusChangeEvent);
    }
    //这个会触发调用register接口将实例信息注册上去
    instanceInfoReplicator.onDemandUpdate();
  }
};
```

实例初始化完毕时，会发送一个状态为UP的事件，触发这个Listener（状态从STARTING变成UP ）：

```java
@Override
public void register(EurekaRegistration reg) {
  maybeInitializeClient(reg);

  if (log.isInfoEnabled()) {
    log.info("Registering application " + reg.getInstanceConfig().getAppname()
             + " with eureka with status "
             + reg.getInstanceConfig().getInitialStatus());
  }

  reg.getApplicationInfoManager()
    .setInstanceStatus(reg.getInstanceConfig().getInitialStatus());

  if (reg.getHealthCheckHandler() != null) {
    reg.getEurekaClient().registerHealthCheck(reg.getHealthCheckHandler());
  }
}
```

那么，官网这两个配置有啥用：

![img](Eureka.assets/v2-618fca803fbdbcb0c412039648a02134_720w.jpg)

其实这个Initially是另外一个逻辑，就是在应用启动40s后，检查实例信息是否老旧，或者第一次注册是否失败，如果失败，就再次注册。之后每隔30s执行一次这个任务

## EurekaServer集群内部信息如何同步？

首先，EurekaClient会选择eureka.client.service-url.defaultZone配置的第一个EurekaServer，之后如果和这个EurekaServer没有网络问题，就会一直用这个。
在EurekaClient向EurekaServer发送注册，下线，心跳，状态改变等一切事件时，这些会在EurekaServer上面同步到集群（EurekaServer集群配置就是eureka.client.service-url.defaultZone，集群内每个EurekaServer）的所有Server上



![img](Eureka.assets/v2-a26112df5bd821215c9cc2a75d4d92f1_720w.jpg)



这样的机制有没有问题？
\1. 这个同步到其他EurekaServer与本次EurekaClient请求是否是同步的？
不是同步的，例如注册到EurekaServerA，EurekaServerA将注册请求同步到EurekaServerB与当前注册请求是异步的
\2. 某次异步同步请求失败如何补偿？
例如服务实例A注册到EurekaServerA，但是同步到EurekaServerB失败。这时EurekaServerB就没有这个实例，在下次A心跳时，EurekaServerA同步心跳请求到EurekaServerB时，会返回404，触发重新注册
**推论：**
为了减少和均匀EurekaServer压力和访问便利，我们对于每个微服务的不同实例，配置Eureka集群都要写的顺序不一样，和自己网段一样的写的靠前

网络抖动时，导致访问到另一个Eureka，重启才能恢复。。。

## 服务实例怎么过期？

通过EurekaServer内部定时检查过期实例任务，扫描Registry里面过期的实例并删除，并且使对应的ReadWriteMap缓存失效
注意，ReadOnlyMap里面的并不会立刻失效，而是通过下一个只读缓存刷新从ReadWriteMap刷到ReadOnlyMap感知变化。因为EurekaClient获取实例信息只从ReadOnlyMap读取，所以EurekaClient感知变化也会有这个延迟



![img](Eureka.assets/v2-a683b5b95a305a4f18db0736a611bf43_720w.jpg)



## 为何EurekaServer挂了，客户端依然可以调通？

SpringCloud环境下，EurekaClient有缓存，Ribbon对于调用的服务列表也有缓存，所以可以继续调用，但不会更新服务与实例列表了。
根据Eureka的self-preservation的设计思路，可以理解这种设计也是符合Eureka初衷的（CAP中的A）



![img](Eureka.assets/v2-809b2d35ed8dd956869e96cf1a664417_720w.jpg)

# SpringCloudEureka 7 - 生产配置最佳实践

**可以实现比较快的服务上下线：**

## EurekaServer配置：

```properties
#eureka server刷新readCacheMap的时间，注意，client读取的是readCacheMap，这个时间决定了多久会把readWriteCacheMap的缓存更新到readCacheMap上
#默认30s
eureka.server.responseCacheUpdateInvervalMs=3000
#eureka server缓存readWriteCacheMap失效时间，这个只有在这个时间过去后缓存才会失效，失效前不会更新，过期后从registry重新读取注册服务信息，registry是一个ConcurrentHashMap。
#由于启用了evict其实就用不太上改这个配置了
#默认180s
eureka.server.responseCacheAutoExpirationInSeconds=180

#启用主动失效，并且每次主动失效检测间隔为3s
#默认60s
eureka.server.eviction-interval-timer-in-ms=3000

#服务过期时间配置,超过这个时间没有接收到心跳EurekaServer就会将这个实例剔除
#注意，EurekaServer一定要设置eureka.server.eviction-interval-timer-in-ms否则这个配置无效，这个配置一般为服务刷新时间配置的三倍
#默认90s
eureka.instance.lease-expiration-duration-in-seconds=15
#服务刷新时间配置，每隔这个时间会主动心跳一次
#默认30s
eureka.instance.lease-renewal-interval-in-seconds=5
#eureka client刷新本地缓存时间
#默认30s
eureka.client.registryFetchIntervalSeconds=5
#eureka客户端ribbon刷新时间
#默认30s
ribbon.ServerListRefreshInterval=1000
eureka.instance.preferIpAddress=true
#关闭自我保护
eureka.server.enable-self-preservation=false
eureka.client.serviceUrl.defaultZone=http://10.120.242.153:8211/eureka/,http://10.120.242.154:8211/eureka/
```

## EurekaClient配置:

```properties
#服务过期时间配置,超过这个时间没有接收到心跳EurekaServer就会将这个实例剔除
#注意，EurekaServer一定要设置eureka.server.eviction-interval-timer-in-ms否则这个配置无效，这个配置一般为服务刷新时间配置的三倍
#默认90s
eureka.instance.lease-expiration-duration-in-seconds=15
#服务刷新时间配置，每隔这个时间会主动心跳一次
#默认30s
eureka.instance.lease-renewal-interval-in-seconds=5
#eureka client刷新本地缓存时间
#默认30s
eureka.client.registryFetchIntervalSeconds=5
#eureka客户端ribbon刷新时间
#默认30s
ribbon.ServerListRefreshInterval=1000
eureka.instance.preferIpAddress=true
#关闭自我保护
eureka.server.enable-self-preservation=false
eureka.client.serviceUrl.defaultZone=http://10.120.242.153:8211/eureka/,http://10.120.242.154:8211/eureka/
```

# SpringCloudEureka 8 - 安全配置

一般的，Eureka在内网服务，我们不会对于外网暴露Eureka端口，所以一般Eureka不做任何验证。假设我们想进一步增强Eureka的安全性，可以结合`spring security`来简单配置一些安全设置

首先在Spring Cloud Eureka Server所在的项目中添加对于`spring security`的依赖：

```xml
<dependency>  
    <groupId>org.springframework.boot</groupId>  
    <artifactId>spring-boot-starter-security</artifactId>  
</dependency>
```

然后在项目配置文件`application.properties`中加入安全认证，注意三点配置，用户名，密码，还有Eureka服务地址：

```properties
#打开security
security.basic.enabled=true  
security.user.name=username  
security.user.password=password  

#这里的用户名密码就是上面配置的
eureka.client.service-url.defaultZone=http://username:password@localhost:8761/eureka  # 安全的注册地址
```



==发布于 2018-03-27==



# Eureka Questions

## [说说Eureka的高可用方案](https://www.cnblogs.com/xiaoyangjia/p/11639997.html)

1. 说说Eureka的高可用方案
   至少3个Eureka实例才能满足高可用，配置方法如下：
   1. 准备三个节点node1，node2，node3。
   2. 在每个实例的application.xml文件里加入
      `eureka.client.service-url.defaultZone: {address}`，address是其他节点的地址。如果是node1，address就是`http://node2/eureka,http://node3/eureka`，其他节点依次类推。
   3. 启动三个实例，注册信息会在他们之间互相同步。
2. Eureka的高可用满足CAP的哪两项
   Eureka放弃了一致性，保证的是AP。Spring Cloud的开发者认为注册服务更重要的是可用性，可以接受短期内达不到一致性的状况。
3. 如果其中一台Eureka宕机，会出现什么情况
   客户端在向某个Eureka注册发现连接失败，则会自动切换至其它节点，只要有一台Eureka还在，就能保证注册服务可用，只不过查到的信息可能不是最新的。
4. 如果客户端与Eureka失去连接，Eureka会怎么处理
   如果在15分钟内超过85%的节点都没有正常的心跳，那么Eureka就认为客户端与注册中心出现了网络故障，此时会出现以下几种情况：
   1. Eureka不再从注册列表中移除因为长时间没收到心跳而应该过期的服务。
   2. Eureka仍然能够接受新服务的注册和查询请求，但是不会被同步到其它节点上(即保证当前节点依然可用)。
   3. 当网络稳定时，当前实例新的注册信息会被同步到其它节点中。
