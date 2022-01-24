---
title: "快速上手 Rocket MQ"
date: 2022-01-24T09:24:21+08:00
description: "快速上手 Rocket MQ"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- rocketmq
categories:
- mq
---

## 一、简介

**Apache RocketMQ**  是一个统一的消息引擎，轻量级的数据处理平台

特点：
* 低延迟
* 以金融为导向，具有跟踪和审核功能的高可用性
* 行业可持续发展，万亿级消息容量保证
* 供应商中立
* 大数据友好，批量转移，具有多功能集成，可实现淹没吞吐量。
* 海量积累，不损失性能的情况下积累消息，前提是给足磁盘空间

## 二、搭建 Rocket MQ

本文在 Linux 下搭建 Rocket MQ。

前提：
* CentOS Linux release 7.9.2009
* Docker 20.10.12
* Maven 3.8.4

### 2.1 用 Docker 安装 Rocket MQ

首先，用 git 克隆 rocketmq-docker 项目

```bash
git clone https://github.com/apache/rocketmq-docker.git
```

接着生成 Rocket MQ 镜像，build-image.sh 脚本需要传入对应的队列版本号和基础镜像

```bash
cd image-build
sh build-image.sh 4.5.0 alpine
cd ../
```

然后，以**单节点**方式运行镜像，stage.sh 脚本需要传入对应的版本号。

```bash
sh stage.sh 4.5.0
cd stages/4.5.0/templates
```

这里需要自定义 broker 的 ip 地址，将 brokerIP1 改成对应节点的IP地址就行了，可以通过 `ip addr` 查询。

```bash
vim data/broker/conf/broker.conf
```
接着修改 play-docker.sh 中 start_namesrv_broker() 里面 “# Start Broker” 下的一条命令，可以将他注释掉，然后添加以下内容：

```bash
docker run -d -p 10911:10911 -p 10909:10909 -v `pwd`/data/broker/logs:/root/logs -v `pwd`/data/broker/store:/root/store -v `pwd`/data/broker/conf/broker.conf:/home/rocketmq/rocketmq-4.5.0/conf/broker.conf --name rmqbroker --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" apacherocketmq/rocketmq:4.5.0 sh mqbroker -c /home/rocketmq/rocketmq-4.5.0/conf/broker.conf
```

最后，运行并检查

```bash
./play-docker.sh alpine
docker ps -a
```

rmqnamesrv 和 rmqbroker 两个容器在运行，状态为 up 即可。

### 2.2 安装 rocketmq-dashboard

首先，git 克隆 rocketmq-dashboard 项目

```bash
git clone https://github.com/apache/rocketmq-dashboard.git
```

运行前需要安装好 nodejs 和 yarn

```bash
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum install nodejs
npm install --global yarn
```

接着，这个项目是 spring boot 项目，执行下面命令，jvm 参数写队列对应的ip地址和端口即可

```
mvn clean package -Dmaven.test.skip
nohup java -jar target/rocketmq-dashboard-1.0.1-SNAPSHOT.jar -Drmq.namesrv.addr=127.0.0.1:9876 >> rocketmq-dashboard.log &
```

或

```
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Drmq.namesrv.addr=127.0.0.1:9876"
```

服务器默认端口号为 8080，用浏览器访问 rocketmq-dashboard 项目。

> 注意：建议先打包再运行

查看集群标签页下的默认集群中一个分片地址是否与节点的地址一致，而非 172.17.0.1。


## 三、演示官网的 simple example

演示前，需要到 rocketmq-dashboard的网页，在主题标签页下添加所需的主题(topic)，例如：“TopicTest”，结果如下：

<img src="../../../../images/posts/2022/01/quickstart-rocketmq/1.png">

接着是创建官网的simple example。

比如，创建单模块的maven项目，groupId 为 `com.example.rocketmqsimpleexample`，artifactId 为 `rocketmq-simple-example`。

再接着，添加依赖

```xml
<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-client</artifactId>
    <version>4.3.0</version>
</dependency>
```

陆续在包`com.example.rocketmqsimpleexample`下创建 `SyncProducer` 和 `Consumer` 类。

> 注意要修改为自己的生产者和消费者的组名与name server 地址，还有消息的主题、标签等。

```java:SyncProducer.java
public class SyncProducer {
    public static void main(String[] args) throws Exception {
        //实例化生产者组名
        DefaultMQProducer producer = new
                DefaultMQProducer("testrmq");
        // 指定 name server 对应的地址
        producer.setNamesrvAddr("10.119.6.210:9876");
        // 启动实例.
        producer.start();
        for (int i = 0; i < 100; i++) {
            try {
                // 创建消息实例，指定主题、标签和消息体.
                Message msg = new Message("TopicTest" /* Topic */,
                        "TagA" /* Tag */,
                        ("Hello RocketMQ " +
                                i).getBytes(RemotingHelper.DEFAULT_CHARSET) /* Message body */
                );
                // 调用发送消息的方法分发消息给某个 broker
                SendResult sendResult = producer.send(msg);
                System.out.printf("%s%n", sendResult);
            } catch (Exception e) {
                e.printStackTrace();
                Thread.sleep(1000);
            }
        }
        // 之后不再使用，关闭生产者
        producer.shutdown();
    }
}
```

```java:Consumer.java
public class Consumer {

    public static void main(String[] args) throws InterruptedException, MQClientException {

        // 指定消费者组名并实例化.
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("testrmq");

        // 指定 name server 地址.
        consumer.setNamesrvAddr("10.119.6.210:9876");
        consumer.setConsumeFromWhere(ConsumeFromWhere.CONSUME_FROM_FIRST_OFFSET);
        // 订阅消费多个主题
        consumer.subscribe("TopicTest", "*");
        // 注册回调用于从 broker 执行拉取到达的消息.
        consumer.registerMessageListener(new MessageListenerConcurrently() {

            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs,
                                                            ConsumeConcurrentlyContext context) {
                System.out.printf("%s Receive New Messages: %s %n", Thread.currentThread().getName(), msgs);
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });

        //启动消费者
        consumer.start();

        System.out.printf("Consumer Started.%n");
    }
}
```

先运行Consumer 然后 运行 SyncProducer。

Consumer 的部分控制台消息如下：

```
Consumer Started.
ConsumeMessageThread_1 Receive New Messages: [MessageExt [queueId=10, storeSize=178, queueOffset=6, sysFlag=0, bornTimestamp=1643009838234, bornHost=/10.253.129.14:52001, storeTimestamp=1643009836266, storeHost=/10.119.6.210:10911, msgId=0A7706D200002A9F00000000000045E2, commitLogOffset=17890, bodyCRC=613185359, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=7, CONSUME_START_TIME=1643009838491, UNIQ_KEY=0200000115BC18B4AAC279CC649A0000, WAIT=true, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 48], transactionId='null'}]] 

...
...

```

SyncProducer 的部分控制台消息如下：

```
SendResult [sendStatus=SEND_OK, msgId=0200000115BC18B4AAC279CC649A0000, offsetMsgId=0A7706D200002A9F00000000000045E2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-abc, queueId=10], queueOffset=6]
SendResult [sendStatus=SEND_OK, msgId=0200000115BC18B4AAC279CC65960001, offsetMsgId=0A7706D200002A9F0000000000004694, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-abc, queueId=11], queueOffset=6]

...
...

```