---
title: "Redis 持久化"
date: 2021-07-14T17:01:46+08:00
description: "Redis 两种持久化方式，主从复制和哨兵模式"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- redis
categories:
- 数据库
---

## 一、Redis 持久化存储方式

由于 Redis 的值放在内存中，为防止突然断电等特殊情况的发生，需要对数据进行持久化备份。即将内存数据保存 到硬盘。

### 1.1.RDB 持久化

RDB 是以二进制文件，是在某个时间点将数据写入一个临时文件，持久化结束后，用这个临时文件替换上次持久化的文件，达到数据恢复。

Redis 默认启用 RDB 存储，redis.conf 中的具体配置参数如下：

```
#dbfilename:持久化数据存储在本地的文件
dbfilename "dump.rdb"
#dir:持久化数据存储在本地的路径，如果是在/usr/local/redis/redis-5.0.5/src下启动的redis-cli，则数据会存储在当前src目录下
dir "/var/lib/redis/6379"
##snapshot触发的时机，save
##如下为900秒后，至少有一个变更操作，才会snapshot
##对于此值的设置，需要谨慎，评估系统的变更操作密集程度
##可以通过“save”来关闭snapshot功能 
#save时间，以下分别表示更改了1个key时间隔900s进行持久化存储;更改了10个key300s进行存储;更改10000个 key60s进行存储。
save 900 1
save 300 10
save 60 10000 
##当snapshot时出现错误无法继续时，是否阻塞客户端「变更操作」，「错误」可能因为磁盘已满/磁盘故障/OS级别异常等 
stop-writes-on-bgsave-error yes 
##是否启用rdb文件压缩，默认为“yes”，压缩往往意味着「额外的cpu消耗」，同时也意味这较小的文件尺寸以及较短的网 络传输时间
rdbcompression yes
```

### 1.2.AOF 持久化

Append-Only File，将「操作 + 数据」以格式化指令的方式追加到操作日志文件的尾部，在 append 操作返回后(已经写入到文件或者将要写入)，才进行实际的数据变更，“日志文件”保存了历史所有的操作过程;

当 server 需要数据恢复时，可以直接 replay 此日志文件，即可还原所有的操作过程。AOF 相对可靠，AOF 文件内容是字符串，非常容易阅读和解析。

AOF 的特性决定了它相对比较安全，如果你期望数据更少的丢失，那么可以采用 AOF 模式。

如果 AOF 文件正在被写入时突然 server 失效，有可能导致文件的最后一次记录是不完整，你可以通过手工或者程序的方式去检测并修正不完整的记录。

如果你的 redis 持久化手段中有 aof，那么在 server 故障失效后再次启动前，需要检测 aof 文件的完整性。

AOF 默认关闭，开启需要修改配置文件 redis.conf : appendonly yes

```
##此选项为aof功能的开关，默认为“no”，可以通过“yes”来开启aof功能 
##只有在“yes”下，aof重写/文件同步等特性才会生效
appendonly yes

##指定aof文件名称 
appendfilename "appendonly.aof"

##指定aof操作中文件同步策略，有三个合法值:always everysec no,默认为everysec
appendfsync everysec 

##在aof-rewrite期间，appendfsync是否暂缓文件同步，"no"表示「不暂缓」，“yes”表示「暂缓」，默认为“no” 
no-appendfsync-on-rewrite no
##aof文件rewrite触发的最小文件尺寸(mb,gb),只有aof文件大于此尺寸是才会触发rewrite，默认“64mb”，建议“512mb”
auto-aof-rewrite-min-size 64mb

##相对于「上一次」rewrite，本次rewrite触发时aof文件应该增长的百分比。 
##每一次rewrite之后，Redis都会记录下此时“新aof”文件的大小(例如A)，那么当aof文件增长到A*(1 + p)之后 
##触发下一次rewrite，每一次aof记录的添加，都会检测当前aof文件的尺寸。
auto-aof-rewrite-percentage 100
```

### 1.3.AOF 与 RDB 区别

RDB 的优缺点

优点：使用单独子进程来进行持久化，主进程不会进行任何IO操作，保证了Redis的高性能

缺点：RDB是间隔一段时间进行持久化，如果持久化之间Redis发生故障，会发生数据丢失。所以这种方式更适合数据要求不严谨的时候

AOF 的优缺点

优点：可以保持更高的数据完整性，如果设置追加 file 的时间是 1s，如果 Redis 发生故障，最多会丢失1s的数据;且如果日志写入不完整支持 redis-check-aof 来进行日志修复;AOF文件没被 rewrite 之前(文件过大时会对命令进行 合并重写)，可以删除其中的某些命令(比如误操作的 flushall)。

缺点：AOF 文件比 RDB 文件大，且恢复速度慢。

---

## 二、主从复制

### 2.1.特点

1. 持久化保证了即使Redis服务重启也不会丢失数据，但是当 Redis 服务器的硬盘损坏了可能会导致数据丢失，通过Redis的主从复制机制就可以避免这种单点故障(单台服务器的故障)。

2. 主Redis中的数据和从上的数据保持实时同步,当主 Redis 写入数据时通过主从复制机制复制到两个从服务上。

3. 主从复制不会阻塞 master，在同步数据时，master 可以继续处理 client 请求.

4. 主机 master 配置:无需配置


### 2.2.搭建主从复制

搭建主从复制，主机是不用配置，只配置从机即可。

前提有多台虚拟机，或者在一台搭建多个 Redis 虚拟主机，这个要多个 Redis 副本

首先，从机修改配置文件 redis.conf: `replicaof <主机ip> <主机端口号>`
如有需要，则修改 bind 和 port 等信息。

接着，清除从机的持久化文件

最后启动从机

查看主从关系信息，客户单内部运行命令 `info replication`。

注意：

1. 主机一旦发生增删改操作，那么从机会自动将数据同步到从机中
2. 从机不能执行写操作,只能读

### 2.3.复制过程原理

1. 当从库和主库建立 MS (master slaver)关系后，会向主数据库发送SYNC命令;
2. 主库接收到 SYNC 命令后会开始在后台保存快照(RDB 持久化过程)，并将期间接收到的写命令缓存起来; 快照完成后,主 Redis 会将快照文件和所有缓存的写命令发送给从 Redis;
3. 从 Redis 接收到后，会载入快照文件并且执行收到的缓存命令;
4. 主 Redis 每当接收到写命令时就会将命令发送从 Redis，保证数据的一致;

### 2.4.问题解决

主从复制过程中出现宕机的解决办法：

* 从机宕机：直接重启

* 主机宕机：从机执行 `slaveof no one` 命令，断开主从关系并提升为主库；当原先主机修好后，重启后，执行 `slaveof` 命令，原先主机设置为从机。


## 三、哨兵模式


### 3.1.特点

哨兵的作用就是对 Redis 系统的运行情况监控，它是一个独立进程,它的功能:

1. 监控主数据库和从数据库是否运行正常;
2. 主数据出现故障后自动将从数据库转化为主数据库;

### 3.2.搭建

前提有多台主机，最开始只需在配置从机，在从机启动哨兵进程监控主机。

首先，配置哨兵配置文件，可以从源码复制sentinel.conf或自行创建sentinel.conf到/etc/redis/sentinel.conf。配置 sentienl.conf : `sentinel monitor <监控名> <主机ip> <主机端口> <最低通过票数>`。
可以按需配置 `daemonize yes` 和 `logfile "/var/log/redis_sentinel.log"`。

接着，启动哨兵前，确保主从服务正常，启动主机服务，再启动从机服务。

最后，执行 `redis-sentinel /etc/redis/sentinel.conf`

注意，每次修改 sentinel.conf，都要重新启动 redis-sentinel

当主机宕机，哨兵进程会把从库自动提升为主库，并自动修改主从库的 redis.conf。下次原先主机重启服务，会自动变成从机服务。