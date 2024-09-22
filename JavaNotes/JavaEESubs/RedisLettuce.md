# redis的java客户端lettuce的使用

从官方文档翻译并整理的，有地方可能表述不准确

建议查看官方文档：https://github.com/lettuce-io/lettuce-core/wiki/About-lettuce

## lettuce的介绍

lettuce是一个线程安全的redis客户端。提供同步，异步和reactive的APIs。

如果可以避开阻塞和事务型的操作比如BLPOP和MULTI/EXEC，多个线程可以分享同一个连接。多个连接被NIO框架netty有效的管理。

并且支持哨兵模式，集群模式和数据模式。

他的大部分方法对正好对应redis的命令。

## RedisURI

### 创建

RedisURI是redis连接的一些标准信息，比如需要提供数据库名称，密码，url，超时时间等。有三种方式可以创建：

```java
RedisURI.create("redis://localhost/");
RedisURI.Builder.redis("localhost", 6379).auth("password").database(1).build();
new RedisURI("localhost", 6379, 60, TimeUnit.SECONDS);
```

### [URI的语法](https://github.com/lettuce-io/lettuce-core/wiki/Redis-URI-and-connection-details)

**Redis Standalone**：
`redis://[[username:]password@]host[:port][/database][?[timeout=timeout[d|h|m|s|ms|us|ns]]`

**Redis Standalone (SSL)**：
`rediss://[[username:]password@]host[:port][/database][?[timeout=timeout[d|h|m|s|ms|us|ns]]`

**Redis Standalone (Unix Domain Sockets)**
`redis-socket://[[username:]password@]path[?[timeout=timeout[d|h|m|s|ms|us|ns]][&database=database]]`

**Redis Sentinel**

`redis-sentinel://[[username:]password@]host1[:port1][,host2[:port2]][,hostN[:portN]][/database][?[timeout=timeout[d|h|m|s|ms|us|ns]][&sentinelMasterId=sentinelMasterId]`

### 时间单位

d 天
h小时
m分钟
s秒
ms 毫秒
us 微秒
ns 纳秒

4. 示例

```java
//url和port
RedisClient client = RedisClient.create(RedisURI.create("localhost", 6379));
client.setDefaultTimeout(20, TimeUnit.SECONDS);

// …

client.shutdown();
 builder
RedisURI redisUri = RedisURI.Builder.redis("localhost")
                                .withPassword("authentication")
                                .withDatabase(2)
                                .build();
RedisClient client = RedisClient.create(redisUri);
ssl builder
RedisURI redisUri = RedisURI.Builder.redis("localhost")
                                .withSsl(true)
                                .withPassword("authentication")
                                .withDatabase(2)
                                .build();
RedisClient client = RedisClient.create(redisUri);
 String RedisURI
RedisURI redisUri = RedisURI.create("redis://authentication@localhost/2");
RedisClient client = RedisClient.create(redisUri);

// …

client.shutdown();
```

3. 基本使用

```xml
<dependency>
  <groupId>biz.paluch.redis</groupId>
  <artifactId>lettuce</artifactId>
  <version>5.0.0.Beta1</version>
</dependency>
```

建立连接

```java
RedisClient client = RedisClient.create("redis://localhost");
StatefulRedisConnection<String, String> connect = client.connect();
```

同步方式

```JAVA
RedisCommands<String, String> commands = connect.sync(); 
String value = commands.get("foo");
```

异步方式

```JAVA
RedisAsyncCommands<String, String> redisAsync = connect.async();
RedisFuture<String> redisFuture = redisAsync.get("a");
try {
  String a = redisFuture.get();
  System.out.println(a);
} catch (InterruptedException e) {
  e.printStackTrace();
} catch (ExecutionException e) {
  e.printStackTrace();
}
```

RedisFuture的get方法是阻塞方法，会一直阻塞到返回结果，可以添加超时时间 

关闭连接
```java
connection.close(); 
client.shutdown(); 
```

4. Reactive API
懵逼ing...

5. Pub Sub
发布订阅的使用

6. Transactions
事务的使用

7. dynamic Redis Command Interfaces
自定义命令

8. Master Slave
主从模式的使用

9. Redis Sentinel
哨兵模式的使用

10. Redis Cluster
集群模式的使用

11. 连接池的使用
lettuce是线程安全的，可以被多个线程同时使用，所以线程池不是必须的。lettuce提供了一般的连接池支持。

lettuce的连接池依赖common-pool2

```xml
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
    <version>2.4.3</version>
</dependency>
```

1. 连接池的归还两种方式

```java
StatefulConnection.close()
GenericObjectPool.returnObject(…)
```

1. 基本使用

```java
RedisClient client = RedisClient.create(RedisURI.create(host, port));

GenericObjectPool<StatefulRedisConnection<String, String>> pool = 
  ConnectionPoolSupport.createGenericObjectPool(() -> client.connect(), new GenericObjectPoolConfig());

// executing work
try (StatefulRedisConnection<String, String> connection = pool.borrowObject()) {

  RedisCommands<String, String> commands = connection.sync();

  commands.multi();
  commands.set("key", "value");
  commands.set("key2", "value2");
  commands.exec();

}

// terminating
pool.close();
client.shutdown();
```

3. 集群使用

```java
RedisClusterClient clusterClient = RedisClusterClient.create(RedisURI.create(host, port));

GenericObjectPool<StatefulRedisClusterConnection<String, String>> pool = ConnectionPoolSupport
               .createGenericObjectPool(() -> clusterClient.connect(), new GenericObjectPoolConfig());

// execute work
try (StatefulRedisClusterConnection<String, String> connection = pool.borrowObject()) {
    connection.sync().set("key", "value");
    connection.sync().blpop(10, "list");
}

// terminating
pool.close();
clusterClient.shutdown();
```

