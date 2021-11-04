---
title: "Mongodb 快速开始"
date: 2021-10-26T20:39:48+08:00
description: "MongoDB快速开始使用"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- mongodb
categories:
- 数据库
---

## 简介

MongoDB，是一款分布式文件存储数据库系统。是NoSQL类型（Not Only SQL）。旨在为WEB应用提供可扩展的高性能数据存储解决方案。其数据结构非常松散，类似JSON的BSON格式，作为其数据传输和存储的格式。BSON，理解为二进制的JSON，可以用来表示一些简答数据类型，还有对象和数组等。

其特点：
1. 面向集合存储，易存储对象类型数据。
2. 支持动态查询
3. 支持完全索引
4. 支持复制和故障恢复
5. 支持多语言开发
6. 使用高效的二进制存储

适合场景：
1. 网站实时数据处理。实时插入、更新和查询；
2. 缓存。充当关系型数据库数据的缓存，避免关系型数据库过载访问；
3. 高伸缩性的场景，非常适合由数十或数百台服务器组成的数据库，它的路线图中已经包含对 MapReduce引擎的内置支持。

不适合场景：

1. 要求高度事务性的系统
2. 传统的商业智能应用
3. 复杂跨文档查询，即级联查询

与关系型数据库类比概念

|关系型数据库|MongoDB|说明|
|:-:|:-:|:-:|
|database|database|数据库|
|table|collection|表/集合|
|row|document|行/文档|
|column|field|列/字段|
|index|index|索引|
|table joins|-|MongoDB不支持联表查询|
|primary key|primary key|主键，MongoDB自动生成_id字段设为主键|

## 安装

Linux CentOS7 发行版安装MongoDB

到MongoDB官网找到相应版本，拷贝连接，使用wget下载

```
# 安装mongodb依赖
sudo yum install libcurl openssl xz-libs
# 下载mongodb-community server和database-tools
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-5.0.3.tgz
wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel70-x86_64-100.5.1.tgz
# 解压安装
tar zxvf mongodb-linux-x86_64-rhel70-5.0.3.tgz
mv mongodb-linux-x86_64-rhel70-5.0.3 /usr/local/mongodb
tar zxvf mongodb-database-tools-rhel70-x86_64-100.5.1.tgz
cd mongodb-database-tools-rhel70-x86_64-100.5.1/bin
cp * /usr/local/mongodb/bin/
ln -s /usr/local/mongodb/bin/* /usr/local/bin/
cd ../../
```

创建数据库目录和日志目录

```
mkdir -p /var/lib/mongo
mkdir -p /var/log/mongodb
chown -R `whoami` /var/lib/mongo
chown -R `whomai` var/log/mongodb
```

安装emacs

```
yum install -y emacs
cd /usr/local/mongodb/bin
emacs -nw mongod.conf
```

编辑mongod.conf

```
systemLog:
   destination: file
   path: "/var/log/mongodb/mongod.log"
   logAppend: true
storage:
   dbPath: "/var/lib/mongo"
   journal:
      enabled: true
processManagement:
   fork: true
net:
   bindIp: 0.0.0.0
   port: 27017
```

C-x C-s 保存，C-x C-c 退出emacs（C指control键，x、s、c字母键）

## 运行

```
mongod -f /usr/local/mongodb/bin/mongod.conf
```

可编写脚本运行

退出运行

```
mongod -f /usr/local/mongodb/bin/mongod.conf --shutdown
```

## 连接MongoDB

在shell中输入命令mongo就可以进入客户端交互界面。

```
mongo 127.0.0.1 # shell没有指定ip，默认使用127.0.0.1
```

## 常见数据类型

```
{"x": null} # null类型
{"x": true}  # 布尔类型
{"x": 2.32} # 默认数字类型为64位浮点数
{"x": NumberInt(2)} # 32整数
{"x": NumberLong(2)} # 64位整数
{"x": "string"} # 字符串
{"x": new Date()} # 日期
{"x": ["hello","world"]} # 数组
{"x": /mongodb/i} # 正则表达式
{"x":{"name": "zhangsan"}} # 内嵌文档
{"_id": ObjectId()} # _id和ObjectId，_id可以是任何类型；不指定_id时，会生成ObjectId对象
```

ObjectId是12字节（24个十六进制数）存储空间，数据组织：
```
0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 
    时间戳     |   机器码   |进程PID| 计数器
```
## 常见指令

```
show dbs # 查看数据库
use db0 # use <database name>  切换数据库/创建再切换数据库
db # 当前所在数据库
show collections # 查看所有数据集
db.dropDatabase() # 删除当前数据库

db.createCollection("users") # 创建数据集
db.users.drop() # db.<collection name>.drop()删除数据集
db.users.renameCollection("user") # db.<old collection name>.renameCollection("new name") 改数据集名称

db.user.insert({"name": "zhangsan", age: 18}) # db.<collection name>.insert({"key": value}) 新增数据
db.user.save({"name": "zhangsan", age: 18}) # db.<collection name>.save({"key": value}) 新增数据

db.user.find() # db.<collection name>.find() 全查
# db.<collection name>.find(condition) 条件查询
db.user.find({"age": 18}) # 等于18
db.user.find({"age": {$gt:14}}) # 大于14
db.user.find({"age": {$gte:14}}) # 大于等于14
db.user.find({"age": {$lt:14}}) # 小于14
db.user.find({"age": {$lte:14}}) # 小于等于14
db.user.find().pretty() # 人性化格式化输出

# or关系：{$or:[{k1:v1},{k2:v2}]}
db.user.find({$or: [{"name": "zhangsan"},{"age": {$gt:12}}]}) # name等于zhangsan或者age大于12

# db.<collection name>.remove(condition) 条件删除
db.user.remove({"age": {$lt:12}}) 

db.user.findOne() # db.<collection name>.findOne() 查询一条数据
db.user.find({},{name:1}) # 查询指定字段，1表示只包含该字段，0表示排除该字段
db.user.distinct('name') # db.<collection name>.distinct('field name') 查询指定字段，并去重

db.user.find().sort({name:1}) # 升序， -1则表示降序
db.user.find().count() # 查询条数
db.user.find().limit(3) # 查询限定数量
db.user.find().limit(3).skip(5) # 先跳过前5个，再查询3个

# db.<collection name>.update(query, update, upsert, multi) query查询条件，update更新的字段，
# upsert为true，不存在值插入，默认为false不插入
# multi为true，更新所有查询的数据，为false更新第一条数据
db.user.update({name:'tom'},{$set:{age: 21}},false, true)
```

## 索引

创建索引
```
# db.<collection name>.createIndex(keys, options)
db.users.createIndex({"name": 1}) # 1表示升序，-1表示降序
```

options含义：

|参数|类型|说明|
|:-:|:-:|:-:|
|background|boolean|建索引过程会阻塞其它数据库操作，background可指定 以后台方式创建索引，即增加 "background" 可选参数。 "background" 默认值为false。|
|unique|boolean|建立的索引是否唯一。指定为true创建唯一索引。默认值 为false.|
|name|String|索引的名称。如果未指定，MongoDB的通过连接索引的 字段名和排序顺序生成一个索引名称。例如：name_1|
|dropDups|boolean|3.0+版本已废弃。在建立唯一索引时是否删除重复记录, 指定 true 创建唯一索引。默认值为 false.|
|sparse|boolean|对文档中不存在的字段数据不启用索引;这个参数需要特 别注意，如果设置为true的话，在索引字段中不会查询出 不包含对应字段的文档.。默认值为 false.|
|expireAfterSeconds|integer|指定一个以秒为单位的数值，完成 TTL设定，设定集合的 生存时间。|
|v|index version|索引的版本号。默认的索引版本取决于mongod创建索引 时运行的版本。|
|weigths|document|索引权重值，数值在 1 到 99,999 之间，表示该索引相对 于其他索引字段的得分权重。|
|default_language|String|对于文本索引，该参数决定了停用词列表及词干分析器和分词器的规则。 默认为 english|
|language_override|String|对于文本索引，该参数的值是集合文档中字段名，此字段包含索引指定使用的语言，默认值为 language.|

索引分类：
用创建的索引的参数来说明

1. 默认索引：集合创建后，系统自动创建名为_id的主键和名为_id_的索引，此索引**无法删除**
2. 单列索引：例如{"name":1}
3. 组合索引；例如{"name":1,"age":1}
4. 唯一索引：例如{"name":1},{unique:true}
5. TTL索引：例如{"createAt":1},{expireAfterSeconds:3600}

删除索引

```
# db.<collection name>.dropIndex("index name")
db.users.dropIndex("name")
db.users.dropIndexes() 
```

> 用remove删除集合数据不会删除索引，drop又删除集合数据又删除索引

## 备份和恢复

备份

```
mongodump -h 127.0.0.1:27017 -d db0 -o /Users/yourname
```

* -h指定主机ip和port，默认127.0.0.1和27017
* -d指定数据库名，这里是db0
* -o指定备份到目标目录


也可以不指定以上参数，将使用默认参数，并将有数据的数据库全部备份到当前目录
```
mongodump
tree dump
dump
├── admin
│   ├── system.version.bson
│   └── system.version.metadata.json
└── db0
    ├── users.bson
    └── users.metadata.json
```

将当前MongoDB服务实例的数据备份到当前目录下，在当前目录下会创建一个dump文件夹，该文件夹下又有与数据库同名的文件夹，如admin和db0。数据文件是.bson后缀的文件


恢复
```
mongorestore -h 127.0.0.1:27017 -d test dump/db0/users.bson
```

* -h指定主机ip和port，默认127.0.0.1和27017
* -d指定目标数据库名，这里是test
* dump/db0/users.bson指备份数据的路径，未指定则为当前目录下的dump中数据

将当前目录下的dump/db0/users.bson数据恢复到新数据库test中

## 搭建集群

在三个主机安装MongoDB，假如他们的主机地址分别为；192.168.123.181、192.168.123.182和192.168.123.183

三个不同主机的MongoDB实例，分别改写配置文件mongod.conf

```
emacs -nw /usr/local/mongodb/bin/mongod.conf
```

```
systemLog:
   destination: file
   path: "/var/log/mongodb/mongod.log"
   logAppend: true
storage:
   dbPath: "/var/lib/mongo"
   journal:
      enabled: true
processManagement:
   fork: true
net:
   bindIp: 0.0.0.0
   port: 27017
# 添加副本集，名为rs0
replication:
   replSetName: "rs0"
```

初始化副本集

```
mongo
> rs.initiate({_id:'rs0'},members:[{_id:1,host:'192.168.123.181:27017'},{_id:2,host:'192.168.123.182:27017'},{_id:3,host:'192.168.123.183:27017'}])
```

查看状态

```
rs0.PRIMARY> rs.status()

# 部分信息如下
{
   # ...
   members: [{
         "_id" : 1,
         "name" : "192.168.123.181:27017",
         "health" : 1,
         "state" : 1,
         "stateStr" : "PRIMARY",
         # ...
      },{
         "_id" : 2,
         "name" : "192.168.123.182:27017",
         "health" : 1,
         "state" : 2,
         "stateStr" : "SECONDARY",
      },
      # ...
   ],
}
```

要在从机查询数据，需要调用secondaryOK()方法

```
rs0.SECONDARY> rs.secondaryOk()
```

删除节点
```
rs0.PRIMARY> rs.remove("192.168.123.183:27017") # rs.remove("ip:port")
{
   "ok" : 1,
   "$clusterTime" : {
      "clusterTime" : Timestamp(1635336751, 1),
      "signature" : {
            "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
            "keyId" : NumberLong(0)
      }
   },
   "operationTime" : Timestamp(1635336751, 1)
}
```

添加节点与删除节点类似，rs.add("ip:port")

添加仲裁者
```
rs0.PRIMARY> db.adminCommand({setDefaultRWConcern:1,defaultWriteConcern:{"w":1}})
rs0.PRIMARY> rs.addArb("192.168.123.183:27017")
```

> 添加仲裁者之前需要强制修改Default Write Concern，从5.0开始。
> 注：仲裁者对偶数集群有效。在一主一从关系中，任意节点宕机都无法选举出主节点，无法提供写操作。此时需要加入仲裁者节点即可。