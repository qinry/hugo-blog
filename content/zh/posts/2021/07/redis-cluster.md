---
title: "Redis集群"
date: 2021-07-14T17:02:54+08:00
description: "搭建Redis集群，jedis访问Redis集群"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- redis
categories:
- 数据库
---


## 一、集群架构

(1)所有的 Redis 节点彼此互联（PING-PONG 机制），内部使用二进制协议优化传输速度和带宽. 

(2)节点的 fail 是通过集群中超过半数的节点检测有效时整个集群才生效. 

(3)客户端与 Redis 节点直连,不需要中间 proxy 层.客户端不需要连接集群所有节点,连接集群中任何一个可用节点即可 

(4)redis-cluster把所有的物理节点映射到 [0-16383]slot 上，cluster 负责维护 node<->slot<->value

Redis 集群中内置了 16384 个哈希槽，当需要在 Redis 集群中放置一个 key-value 时，Redis 先对 key 使用 CRC16 算法算出一个结果，然后把结果对 16384 求余数，这样每个 key 都会对应一个编号在 0-16383 之间的哈希槽， Redis 会根据节点数量大致均等的将哈希槽映射到不同的节点

## 二、心跳机制

(1)集群中所有 master 参与投票,如果半数以上 master 节点与其中一个 master 节点通信超过 (cluster-node-timeout)，认为该 master 节点挂掉。

(2)什么时候整个集群不可用(cluster_state:fail)？
Ø 如果集群任意 master 挂掉,且当前 master 没有 slave ，则集群进入 fail 状态。也可以理解成集群的[0-16383]slot映射不完全时进入fail状态。
Ø 如果集群超过半数以上 master 挂掉，无论是否有 slave ，集群进入 fail 状态。

## 三、搭建集群

前提有多个虚拟机，并装好了 Redis。搭建集群最少要 3 台主机，一台主机再配置从机的话，最少需要 6 台机器或虚拟机。不过可以一台机子有 6 个 Redis 实例。使用端口 7001~7006。

首先，编写配置文件 redis.conf：`cluster-enabled yes`。还有按情况配置 `port <端口号>` 和 `bind 0.0.0.0`。

接着，删除数据存放目录下持久化文件，重要持久化文件自行备份。启动 7001～7002 这六个 Redis 实例。如果防火墙未放行 Redis 服务的流量话，配置放行或者关闭防火墙。

然后，创建集群 

```
redis-cli --cluster create <ip>:<port> [<ip>:<port> ...] --cluster-replicas 1
```

最后，连接集群 

```
redis-cli -h <ip> -p <port> -c
``` 

查看集群信息，在运行的客户端内部执行命令 `cluster info`。
查看集群节点信息，`cluster nodes`。

## 四、jedis连接集群

maven引入相关依赖

```
<dependency> 
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId> 
    <version>3.6.1</version>
  </dependency>
```

示例代码：

```
public static void main(String[] args) throws IOException { 
    // 创建一连接，JedisCluster对象,在系统中是单例存在 
    Set<HostAndPort> nodes = new HashSet<HostAndPort>(); 
    nodes.add(new HostAndPort("192.168.123.181", 7001)); 
    nodes.add(new HostAndPort("192.168.123.181", 7002)); 
    nodes.add(new HostAndPort("192.168.123.181", 7003)); 
    nodes.add(new HostAndPort("192.168.123.181", 7004)); 
    nodes.add(new HostAndPort("192.168.123.181", 7005)); 
    nodes.add(new HostAndPort("192.168.123.181", 7006)); 
    JedisCluster cluster = new JedisCluster(nodes);
    // 执行JedisCluster对象中的方法，方法和redis指令一一对应。
    cluster.set("test1", "test111");
    String result = cluster.get("test1"); 
    System.out.println(result);
    //存储List数据到列表中
    cluster.lpush("site-list", "java"); 
    cluster.lpush("site-list", "c"); 
    cluster.lpush("site-list", "mysql");
    // 获取存储的数据并输出
    List<String> list = cluster.lrange("site-list", 0 ,2); 
    for(int i=0; i<list.size(); i++) {
        System.out.println("列表项为: "+list.get(i)); 
    }
    // 程序结束时需要关闭JedisCluster对象 
    cluster.close();
    System.out.println("集群测试成功!"); 
    
}
```