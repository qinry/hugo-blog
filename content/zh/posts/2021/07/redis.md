---
title: "Redis 入门"
date: 2021-07-14T16:54:53+08:00
description: "Redis 常用命令；jedis 连接 Redis；缓存雪崩、缓存击穿、缓存穿透问题；分布式锁"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- redis
categories:
- 数据库
---

简单介绍Redis。它是一款键值数据库。它还是非关系型数据库（Nosql）。常常用作内存缓存，应用于频繁的读写场景中。


## 一、基本数据结构

Redi常用的五种数据类型。分别为字符串（strings）、列表（lists）、无序集合（sets）、有序集合（zsets）、哈希（hashs）。

## 二、常用命令

### 2.1.字符串的命令

```
# 一般的字符串
# 设置字符串类型key为value
set key value
# 获取key/value
get key
# 设置多个key
mset key value [key value ...]
# 获取多个key/value
mget key [key ...]
# 删除key
del key
# 字符串数字
# 初始是0，每运行就加1，注意第一次运行后的结果为1
incr key
# 初始是0，每运行减1，注意第一次运行后的结果为-1
decr key
# 定长增减，每次增减number
incrby key number
decrby key number
```

### 2.2.哈希的命令

```
# 设置哈希类型key的field为value
hset key field value 
# 获取key的field
hget key field
# 设置key的多个field
hmset key field value [field value ...]
# 获取key多个field
hmget key field [field ...]
# 获取key所有的field
hgetall key
# 删除key的某个或多个field
hdel key field [field ...]
```

### 2.3.列表的命令 

```
# 向列表key左端加元素value
lpush key value [value ...]
# 从列表key左端弹出元素
lpop key
# 向列表key右端加元素value
rpush key value [value ...]
# 从列表key右端弹出元素
rpop key
# 获取列表key元素的个数
llen key
# 查看列表key下标start到stop（不包括）的元素，下标从0开始，特殊地，下标-1表示最后一个元素
lrange key start stop
```

### 2.4无序集合的命令

```
# 向集合key添加元素member
sadd key member [member ...]
# 从集合key指定删除元素member
srem key member [member ...]
# 获取所有元素
smembers key
# 判断元素是否在集合中
sismember key member
```

### 2.5.有序集合的命令

```
# 设置有序集合key的元素及其分数score
zadd key score member [score member ...]
# 查询集合中start到stop范围内的元素[可带分数]，元素按降序返回
zrevrange key start stop [withscores]
# 获取key中元素的分数
zscore key member
# 删除元素
zrem key member [member ...]
# 给key元素的分数加减分数score
zincrby key score member
```

### 2.6.HyperLogLog的命令

```
# 往HyperLogLog类型的key添加元素element
pfadd key element [element ...]
# 获取key中唯一元素的估计个数
pfcount key [key ...]
pfmerget destkey sourcekey [sourcekey ...]
```

### 2.7.其他常用命令

```
# 查询符合pattern的所有key
keys pattern
# 判断key是否存在
exists key
# 删除key
del key
# 重命名
rename oldkey newkey
# 判断key的数据类型
type key
# 设置key的有效时间
expire key seconds
# 查看key有效时间
ttl key
# 清除key的生存时间
persist key
# 获取服务器信息和统计
info
# 删除当前选择的数据库中所有key，谨慎使用
flushdb
# 删除所有数据库的所有key
flushall
# Redis默认有16个数据库，从0到15，选择下标为index数据库
select index
# key从当前数据库移到下标为index的数据库
move key index
```

### 2.8.事务管理

```
# 开启事务
multi
# 将多个命令入队到事务中
...
# 触发事务
exec
```

### 2.9.发布/订阅

```
# 在某一个客户端上订阅频道channel，等待接受发布者发送的消息
subscribe channel
# 在某一个客户端在channel发布消息message给所有此频道的订阅者
publish channel message
```

## 三、jedis连接Redis

首先，在项目中使用maven引入jedis依赖
```
<dependency> 
    <groupId>redis.clients</groupId> 
    <artifactId>jedis</artifactId> 
    <version>3.6.1</version>
</dependency>
```

其次，确保Redis所在的服务器与本地连通，防火墙允许本地流量发送给服务器，服务器可以发送流量给本地，可以选择关闭它。

最后编写代码，核心代码如下：
```
Jedis jedis = null;
try {
    jedis = new Jedis("192.168.123.181",6379);
//  jedis.auth("password");
    jedis.set("foo", "bar");
    String bar = jedis.get("foo");
    System.out.println("foo:"+bar);
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (jedis != null) {
        jedis.close();
    }
}
```

运行代码，如果有JedisConnectionException，请检查Redis的配置文件，检查bind是否绑定服务器的ip，或者设置成0.0.0.0

使用jedis连接池，核心代码如下：

```
JedisPoolConfig config = new JedisPoolConfig();
config.setMaxIdle(10);
config.setMaxTotal(20);
JedisPool pool = null;
Jedis jedis = null;
try {
    pool = new JedisPool(config, "192.168.123.181",6379);
    jedis = pool.getResource();
//  jedis.auth("password");
    jedis.set("foo", "bar");
    String foo = jedis.get("foo");
    System.out.println("foo="+foo);
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (jedis != null) {
        jedis.close();
    }
    if (pool != null) {
        pool.close();
    }
}
```

## 四、缓存雪崩、缓存击穿、缓存穿透问题

什么是缓存?
广义的缓存就是在第一次加载某些可能会复用数据的时候，在加载数据的同时，将数据放到一个指定的地点做保 存。再下次加载的时候，从这个指定地点去取数据。这里加缓存是有一个前提的，就是从这个地方取数据，比从数 据源取数据要快的多。
java狭义一些的缓存，主要是指三大类
1. 虚拟机缓存(ehcache，JBoss Cache) 
2. 分布式缓存(redis，memcache)
3. 数据库缓存
正常来说，速度由上到下依次减慢

### 4.1.缓存雪崩

缓存雪崩通俗简单的理解就是:由于原有缓存失效(或者数据未加载到缓存中)，新缓存未到期间(缓存正常从 Redis 中获取)所有原本应该访问缓存的请求都去查询数据库了，而对数据库CPU和内存造成巨大压力， 严重的会造成数据库宕机，造成系统的崩溃。

解决方案：

1. 在缓存失效后，通过加锁或者队列来控制读数据库写缓存的线程数量。比如对某个key只允许一个线程查询数据
和写缓存，其他线程等待。虽然能够在一定的程度上缓解了数据库的压力但是与此同时又降低了系统的吞吐量。

代码示例说明：

```
public Users getByUsers(Long id) {
    // 1.先查询redis
    String key = this.getClass().getName() + "-" + Thread.currentThread().getStackTrace() [1].getMethodName()
    + "-id:" + id;
    String userJson = redisService.getString(key);
    if (!StringUtils.isEmpty(userJson)) {
        Users users = JSONObject.parseObject(userJson, Users.class);
        return users;
    }
    Users user = null;
    try {
        lock.lock();
        // 查询db
        user = userMapper.getUser(id);
        redisService.setSet(key, JSONObject.toJSONString(user));
    } catch (Exception e) {
    } finally { 
        lock.unlock(); // 释放锁 
    }
    return user;
}

```

2. 分析用户的行为，不同的key，设置不同的过期时间，让缓存失效的时间点尽量均匀。

### 4.2.缓存击穿

对于一些设置了过期时间的key，如果这些key可能会在某些时间点被超高并发地访问，是一种非常“热点”的数据。 这个时候，需要考虑一个问题:缓存被“击穿”的问题，这个和缓存雪崩的区别在于这里针对某一key缓存，前者则是 很多key。

热点key:某个key访问非常频繁，当key失效的时候有大量线程来构建缓存，导致负载增加，系统崩溃。

解决办法:

1. 使用锁，单机用synchronized,lock等，分布式用分布式锁。 
2. 缓存过期时间不设置，而是设置在key对应的value里。如果检测到存的时间超过过期时间则异步更新缓存。

### 4.3.缓存穿透

缓存穿透是指用户查询数据，在数据库没有，自然在缓存中也不会有。这样就导致用户查询的时候，在缓存中找不到，每次都要去数据库再查询一遍，然后返回空。这样请求就绕过缓存直接查数据库，这也是经常提的缓存命中 率问题。

解决方案: 

1. 如果查询数据库也为空，直接设置一个默认值存放到缓存，这样第二次到缓冲中获取就有值了，而不会继续访问数据库，这种办法最简单粗暴。

2. 把空结果，也给缓存起来，这样下次同样的请求就可以直接返回空了，既可以避免当查询的值为空时引起的缓存穿透。同时也可以单独设置个缓存区域存储空值，对要查询的key进行预先校验，然后再放行给后面的正常缓存处理逻辑。

代码示例说明：
```
public String getByUsers2(Long id) {
    // 1.先查询redis
    String key = this.getClass().getName() + "-" + Thread.currentThread().getStackTrace()[1].getMethodName()+ "-id:" + id;
    String userName = redisService.getString(key);
    if (!StringUtils.isEmpty(userName)) {
        return userName;
    } 
    System.out.println("######开始发送数据库DB请求########"); 
    Users user = userMapper.getUser(id);
    String value = null;
    if (user == null) {
        // 标识为null
        value = ""; // 设置默认值
    } else {
        value = user.getName();
    } 
    redisService.setString(key, value);
    return value;
}
```

## 五、分布式锁

### 5.1.使用分布式锁的条件

1. 系统是一个分布式系统(关键是分布式，单机的可以使用ReentrantLock或者synchronized代码块来实现) 

2. 共享资源(各个系统访问同一个资源，资源的载体可能是传统关系型数据库或者NoSQL)

3. 同步访问(即有很多个进程同时访问同一个共享资源。)

### 5.2.应用场景

分布式锁应该用来解决分布式情况下的多进程并发问题才是最合适的。

有这样一个情境，线程A和线程B都共享某个变量X。 

如果是单机情况下(单JVM)，线程之间共享内存，只要使用线程锁就可以解决并发问题。

如果是分布式情况下(多JVM)，线程A和线程B很可能不是在同一JVM中，这样线程锁就无法起到作用了，这时候 就要用到分布式锁来解决。

分布式锁可以基于很多种方式实现，比如zookeeper、redis...。不管哪种方式，他的基本原理是不变的:用一个状态值表示锁，对锁的占用和释放通过状态值来标识。

### 5.3.使用Redis的分布式锁

setnx和getset命令来获取锁，锁的信息设置成锁有效的截止时间。expire设置有效时间。del来释放锁。
注意：

1. 锁只能有一个进程占有

2. 锁只能有锁的持有者释放

3. 锁必须设置过期时间

#### 5.3.1.setnx命令

Redis为单进程单线程模式，采用队列模式将并发访问变成串行访问，且多客户端对Redis的连接并不存在竞争 关系。Redis的setnx命令可以方便的实现分布式锁。

```
# 当key不存在时，设置为value，否则不做任何动作
setnx key value
# 成功返回Integer 1.
# 失败返回Integer 0.
```

如果setnx返回1，说明客户端已经获得了锁，setnx将键的值设置为锁的超时时间(当前时间 + 锁的有效时间)。 之后客户端可以通过del来释放锁。

如果setnx返回0，说明key已经被其他客户端上锁了。如果锁是非阻塞(non blocking lock)的，我们可以选择返回调用，或者进入一个重试循环，直到成功获得锁或重试超时(timeout)。

#### 5.3.2.getset命令

```
# 将给定key设置为value，返回旧值，旧值不存在返回的是nil
# 如果key存在但不是字符串，则返回错误
getset key value
```

代码示例说明：

```
public static boolean lock(String lockName) {
    Jedis jedis = RedisPool.getJedis(); 
    //lockName可以为共享变量名，也可以为方法名，主要是用于模拟锁信息 
    System.out.println(Thread.currentThread() + "开始尝试加锁!");
    Long result = jedis.setnx(lockName, String.valueOf(System.currentTimeMillis() + 5000)); 
    if (result != null && result.intValue() == 1){
        System.out.println(Thread.currentThread() + "加锁成功!"); 
        jedis.expire(lockName, 5);
        System.out.println(Thread.currentThread() + "执行业务逻辑!");
        jedis.del(lockName);
        return true;
    } else {
        //判断是否死锁
        String lockValueA = jedis.get(lockName); 
        //得到锁的过期时间，判断小于当前时间，说明已超时但是没释放锁，通过下面的操作来尝试获得锁。下面逻辑防止死锁 [已经过期但是没有释放锁的情况]
        if (lockValueA != null && Long.parseLong(lockValueA) < System.currentTimeMillis()){ 
            String lockValueB = jedis.getSet(lockName,
            String.valueOf(System.currentTimeMillis() + 5000)); //这里返回的值是旧值，如果有的话。之前没有值就返回null,设置的是新超时。
            if (lockValueB == null || lockValueB.equals(lockValueA)){ 
                System.out.println(Thread.currentThread() + "加锁成功!"); 
                jedis.expire(lockName, 5); 
                System.out.println(Thread.currentThread() + "执行业务逻辑!"); 
                jedis.del(lockName);
                return true;
            } else {
                return false;
            }
        } else {
            return false;
       } 
    }
}
```
