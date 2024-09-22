# Timestamp

1. 时间戳本身在硬盘上存储的是 UTC 0时区 从1970/01/01T00:00:00到当前时间的秒数
2. MySQL本身默认的时间格式采用CST `show variables like '%time_zone%';`
3. JDBC在连接MySQL的时候，会读取MySQL的环境变量，JDBC会把时间数据按照时间标准进行转换然后存入MySQL
   - JDBC有个假设：数据源的时区和JDBC的时区是同一个时区
     - JDBC会根据所在系统的时区设置计算相应的0区时间
   - MySQL有个假设：数据源的时区和MySQL的时区是同一个时区
     - MySQL会根据系统环境变量的时区设置计算相应的0区时间
   - 我们的数据源一般都是UTC+8，那么存到MySQL之后就会出现**少13个小时**的现象(冬令时还会相差 14 个小时)，原因如下：https://www.jianshu.com/p/3dbccdef6031
     - JDBC把我们的时间减去5小时形成CST+0的时间，因为JDBC在连接的时候会读取数据库的时区信息，MySQL默认设置的是CST，即CST-5
     - MySQL把我们的时间再减去8小时形成他认为的CST+0的时间，因为MySQL认为：数据源和MySQL系统在同一个时区，即CST+8
     - 当 MySQL 的 `time_zone` 值为 `SYSTEM` 时，会取 `system_time_zone` 值作为协调时区。
   - 对于`TIMESTAMP`类型，MySQL会正确的根据connection时区（对于JDBC来说就是JVM时区）/服务端时区做转换。
     - JDBC程序不需要特别注意什么事情。只要保证JVM时区和用户所在时区保持一致即可。
   - 不要在服务器端做日期时间的字符串格式化（`DATE_FORMAT()`），因为返回的结果是服务端的时区，而不是connection的时区（对于JDBC来说就是JVM时区）。
   - `CURRENT_TIMESTAMP()`, `CURRENT_TIME()`, `CURRENT_DATE()`可以安全的使用，返回的结果会转换成connection时区（对于JDBC来说就是JVM时区）。
4. 服务器修改时区：
   - 修改 `my.cnf` 文件，在 `[mysqld]` 节下增加 `default-time-zone = '+08:00'`
   - 修改时区操作影响深远，需要重启 MySQL 服务器，建议在维护时间进行
5. system_time_zone和time_zone
   - system_time_zone：操作系统时区，在MySQL启动时会检查当前系统的时区并根据系统时区设置全局参数system_time_zone的值。
   - time_zone：用来设置每个连接会话的时区，默认为system时，使用全局参数system_time_zone的值。

