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

**Apache RocketMQ**  是一个统一的消息引擎，轻量级的数据处理平台。

特点：
* 低延迟
* 以金融为导向，具有跟踪和审核功能的高可用性
* 行业可持续发展，万亿级消息容量保证
* 供应商中立
* 大数据友好，批量转移，具有多功能集成，可实现淹没吞吐量。
* 海量积累，不损失性能的情况下积累消息，前提是给足磁盘空间

功能特性：
*  同步发送
* 异步发送
* one-way发送
* 发送顺序消息
* 批量发送
* 发送事务消息
* 发送延迟消息
* 并发消费（广播/集群）
* 顺序消费
* 支持消息过滤（使用tag/sql）
* 支持消息轨迹
* 认证和授权
* request-reply模式

## 二、搭建 Rocket MQ

本文在 Linux 下搭建 Rocket MQ。

前提：
* CentOS Linux release 7.9.2009
* Docker 20.10.12
* Maven 3.8.4

### 2.1 用 Docker 安装 Rocke tMQ

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

这里需要自定义 broker 的 ip 地址，将 brokerIP1 改成对应节点的IP地址就行了，可以通过 `ip addr` 查询。还有为下面的使用 SQL92 特性进行过滤，需要设置 `enablePropertyFilter=true`。

```bash
vim data/broker/conf/broker.conf
```

具体内容如下：

```
brokerClusterName = DefaultCluster
brokerName = broker-abc
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
# 设置 `brokerIP1`
brokerIP1 = 10.119.6.210
# 启用属性过滤
enablePropertyFilter=true
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

rocketmq-dashboard 还提供 docker 镜像：

```bash
docker run -d --name rocketmq-dashboard -e "JAVA_OPTS=-Drocketmq.namesrv.addr=127.0.0.1:9876" -p 8080:8080 -t apacherocketmq/rocketmq-dashboard:latest
```

修改对应 name server 的 ip 地址和端口即可。还可以使用数据卷提供自己的 application.properties 来替换默认的配置。

## 三、演示官网的简单示例

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
        consumer.registerMessageListener(new MessageListenerOrderly() {

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

先运行Consumer 然后 运行 SyncProducer。这里的消费者以并发模式消费。

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

以上是个同步发送的示例。Rocket MQ 还支持另外两种发送方式：异步发送和单向发送。

异步发送：

```java:AsyncProducer
public class AsyncProducer {
    public static void main(String[] args) throws Exception {
        // 用组名实例化生产者
        DefaultMQProducer producer = new DefaultMQProducer("asyncproducer");
        // 指定 name server 地址
        producer.setNamesrvAddr("10.119.6.210:9876");
        //启动生产者
        producer.start();
        producer.setRetryTimesWhenSendAsyncFailed(0);

        int messageCount = 100;
        final CountDownLatch cdl = new CountDownLatch(messageCount);
        for (int i = 0; i < messageCount; i++) {
            try {
                final int index = i;
                Message msg = new Message("Topic2",
                        "TagB",
                        "OrderID188",
                        "Hello world".getBytes(RemotingHelper.DEFAULT_CHARSET));
                producer.send(msg, new SendCallback() {
                    @Override
                    public void onSuccess(SendResult sendResult) {
                        cdl.countDown();
                        System.out.printf("%-10d OK %s %n", index, sendResult.getMsgId());
                    }

                    @Override
                    public void onException(Throwable e) {
                        cdl.countDown();
                        System.out.printf("%-10d Exception %s %n", index, e);
                        e.printStackTrace();
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        cdl.await(5, TimeUnit.SECONDS);
        producer.shutdown();
    }
}
```

单向发送：

```java:OnewayProducer
public class OnewayProducer {
    public static void main(String[] args) throws Exception{
        // 用组名实例化生产者
        DefaultMQProducer producer = new DefaultMQProducer("onewayproducer");
        // 指定 name server 地址
        producer.setNamesrvAddr("10.119.6.210:9876");
        //启动生产者.
        producer.start();
        for (int i = 0; i < 100; i++) {
            //创建消息实例, 指定主题、标签和消息体
            Message msg = new Message("Topic3" /* Topic */,
                    "TagC" /* Tag */,
                    ("Hello RocketMQ " +
                            i).getBytes(RemotingHelper.DEFAULT_CHARSET) /* Message body */
            );
            //调用发送消息，分发消息给 broker
            producer.sendOneway(msg);
        }
        // 等待发送完成
        Thread.sleep(5000);
        producer.shutdown();
    }
}
```

消费者做相应更改即可。

## 四、顺序消息、广播消息和调度消息

顺序消息使用 FIFO 顺序发送消息。把上面提到消费者所注册的消息监听器由 `MessageListenerOrderly` 改成 `MessageListenerOrderly`。

广播消息把消息发送给某个主题的所有订阅者。如果要所有订阅者都接受到关于某个主题的消息，拥抱广播吧。x需要在消费者修改消息模型为广播模式即可。

调度消息可以延迟消息发送。

### 4.1 顺序消息

发送消息如上不再赘述，这里消费者使用了 MessageListenerOrderly 作为监听器。

```java:OrderedConsumer.java
public class OrderedConsumer {
    public static void main(String[] args) throws Exception {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("orderedconsumer");

        consumer.setNamesrvAddr("10.119.6.210:9876");

        consumer.setConsumeFromWhere(ConsumeFromWhere.CONSUME_FROM_FIRST_OFFSET);

        consumer.subscribe("TopicTestjjj", "TagA || TagC || TagD");
        // 使用消息顺序监听器，FIFO接受消息
        consumer.registerMessageListener(new MessageListenerOrderly() {

            AtomicLong consumeTimes = new AtomicLong(0);
            @Override
            public ConsumeOrderlyStatus consumeMessage(List<MessageExt> msgs,
                                                       ConsumeOrderlyContext context) {
                context.setAutoCommit(false);
                System.out.printf(Thread.currentThread().getName() + " Receive New Messages: " + msgs + "%n");
                this.consumeTimes.incrementAndGet();
                if ((this.consumeTimes.get() % 2) == 0) {
                    return ConsumeOrderlyStatus.SUCCESS;
                } else if ((this.consumeTimes.get() % 3) == 0) {
                    return ConsumeOrderlyStatus.ROLLBACK;
                } else if ((this.consumeTimes.get() % 4) == 0) {
                    return ConsumeOrderlyStatus.COMMIT;
                } else if ((this.consumeTimes.get() % 5) == 0) {
                    context.setSuspendCurrentQueueTimeMillis(3000);
                    return ConsumeOrderlyStatus.SUSPEND_CURRENT_QUEUE_A_MOMENT;
                }
                return ConsumeOrderlyStatus.SUCCESS;

            }
        });

        consumer.start();

        System.out.printf("Consumer Started.%n");
    }
}
```

### 4.2 广播消息

同样修改消费者

```java:BroadcastConsumer.java
public class BroadcastConsumer {
    public static void main(String[] args) throws Exception {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("broadcastconsumer");
        consumer.setNamesrvAddr("10.119.6.210:9876");

        consumer.setConsumeFromWhere(ConsumeFromWhere.CONSUME_FROM_FIRST_OFFSET);

        // 消息模式设为广播
        consumer.setMessageModel(MessageModel.BROADCASTING);

        consumer.subscribe("TopicTest", "TagA || TagC || TagD");

        consumer.registerMessageListener(new MessageListenerConcurrently() {

            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs,
                                                            ConsumeConcurrentlyContext context) {
                System.out.printf(Thread.currentThread().getName() + " Receive New Messages: " + msgs + "%n");
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });

        consumer.start();
        System.out.printf("Broadcast Consumer Started.%n");
    }
}
```

### 4.3 调度消息

调度消息需要在生产者中设置

```java:ScheduledMessageProducer.java
public class ScheduledMessageProducer {
    public static void main(String[] args) throws Exception {
        DefaultMQProducer producer = new DefaultMQProducer("ScheduledMessageProducer");
        producer.setNamesrvAddr("10.119.6.210:9876");
        producer.start();
        int totalMessagesToSend = 100;
        for (int i = 0; i < totalMessagesToSend; i++) {
            Message message = new Message("TestTopic", ("Hello scheduled message " + i).getBytes());
            // 消息延迟10秒后分发
            message.setDelayTimeLevel(3);
            producer.send(message);
        }

        producer.shutdown();
    }
}
```

> 注意：试验时 检查name server 地址是否正确，producer 和 consumer 的主题是否对应

## 五、消息的批处理

批处理模式可以改善多而小消息的发送的性能。但它有要求同一批消息必须有相同的主题、相同的 waitStoreMsgOk，且不支持调度。同一批消息总体不超 1 MiB。 



```java:BatchProducer.java
public class BatchProducer {
    public static void main(String[] args) throws MQClientException {
        DefaultMQProducer producer = new
                DefaultMQProducer("batchproducer");
        producer.setNamesrvAddr("10.119.6.210:9876");
        producer.start();
        // 一批消息不超过限定
        String topic = "BatchTest";
        List<Message> messages1 = new ArrayList<>();
        List<Message> messages2 = new ArrayList<>();
        messages1.add(new Message(topic, "TagA", "OrderID001", "Hello world 0".getBytes()));
        messages1.add(new Message(topic, "TagA", "OrderID002", "Hello world 1".getBytes()));
        messages1.add(new Message(topic, "TagA", "OrderID003", "Hello world 2".getBytes()));

        try {
            producer.send(messages1);
        } catch (Exception e) {
            e.printStackTrace();
            //handle the error
        }

        messages2.add(new Message(topic, "TagA", "OrderID004", "Hello world 4".getBytes()));
        messages2.add(new Message(topic, "TagA", "OrderID005", "Hello world 5".getBytes()));
        messages2.add(new Message(topic, "TagA", "OrderID006", "Hello world 6".getBytes()));

        //当许多而小的消息的列表时，可以分割
        ListSplitter splitter = new ListSplitter(messages2);
        while (splitter.hasNext()) {
            try {
                List<Message>  listItem = splitter.next();
                producer.send(listItem);
            } catch (Exception e) {
                e.printStackTrace();
                //handle the error
            }
        }
    }
}
```

发送一大批消息，不能确保一批不超过 1 MiB。故要最好的做法就是分割，即放在用同一批的消息进行分割。

```java:ListSplitter.java 
public class ListSplitter implements Iterator<List<Message>> {
    private final int SIZE_LIMIT = 1000 * 1000;
    private final List<Message> messages;
    private int currIndex;
    public ListSplitter(List<Message> messages) {
        this.messages = messages;
    }
    @Override public boolean hasNext() {
        return currIndex < messages.size();
    }
    @Override public List<Message> next() {
        int nextIndex = currIndex;
        int totalSize = 0;
        for (; nextIndex < messages.size(); nextIndex++) {
            Message message = messages.get(nextIndex);
            int tmpSize = message.getTopic().length() + message.getBody().length;
            Map<String, String> properties = message.getProperties();
            for (Map.Entry<String, String> entry : properties.entrySet()) {
                tmpSize += entry.getKey().length() + entry.getValue().length();
            }
            tmpSize = tmpSize + 20; // 对于日志开销
            if (tmpSize > SIZE_LIMIT) {
                // 不期望时单个消息超过 SIZE_LIMIT 
                // 继续往下走, 否则会阻塞分割过程
                if (nextIndex - currIndex == 0) {
                    //如果下个子列表为空，自增1 ，不然直接 break 跳出
                    nextIndex++;
                }
                break;
            }
            if (tmpSize + totalSize > SIZE_LIMIT) {
                break;
            } else {
                totalSize += tmpSize;
            }

        }
        List<Message> subList = messages.subList(currIndex, nextIndex);
        currIndex = nextIndex;
        return subList;
    }
}
```

## 六、消息的过滤

有一个消息只能有一个标签，那么对于复杂过滤需求就能很好的满足。Rocket MQ 通过 SQL 特性对用户添加到消息的属性进行计算以达到灵活的过滤需求。只有 push consumer 才能使用 SQL92 这个特性。

语法大致：

数字比较：`>`，`>=`，`<`，`<=`，`BETWEEN`,`=`；

字符比较：`=`，`<>`，`IN`；

是否为空：`IS NULL` 还有 `IS NOT NULL`；

逻辑运算符：`AND`，`OR`，`NOT`；

常量举例：

数字：`123`，`3.14`；

字符：`'abc'`，不许是单引号；

特殊常量：`NULL`；

布尔：`TRUE`，`FALSE`

使用前确保 broker.conf 中设置 `enablePropertyFilter=true`，[见这里](#21-用-docker-安装-rocke-tmq)

生产者例子：

```java:FilterProducer.java
public class FilterProducer {
    public static void main(String[] args) throws Exception {
        DefaultMQProducer producer = new DefaultMQProducer("filterproducer");
        producer.setNamesrvAddr("10.119.6.210:9876");
        producer.start();

        String tag = "TagA";

        for (int i = 0; i < 100; i++) {
            Message msg = new Message("TopicTest",
                    tag,
                    ("Hello RocketMQ " + i).getBytes(RemotingHelper.DEFAULT_CHARSET)
            );
            // Set some properties.
            msg.putUserProperty("a", String.valueOf(i));

            SendResult sendResult = producer.send(msg);
        }

        producer.shutdown();

    }
}
```

消费者例子：

```java:FilterConsumer.java
public class FilterConsumer {
    public static void main(String[] args) throws MQClientException {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("filterconsumer");
        consumer.setNamesrvAddr("10.119.6.210:9876");

        // set proerty enablePropertyFilter=true in broker
        // only subsribe messages have property a, also a >=0 and a <= 3
        consumer.subscribe("TopicTest", MessageSelector.bySql("a >= 0 and a <= 3"));

        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs, ConsumeConcurrentlyContext context) {
                System.out.printf("%s Receive New Messages: %s %n", Thread.currentThread().getName(), msgs);
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });
        consumer.start();

    }
}
```

## 七、Rocket MQ 日志

日志是仅追加的文件，用来记录应用的行为的。Rocket MQ 支持三种日志追加框架：logback、log4j2 和 log4j。

由于 log4j 在 2015 不再维护，所以这里讨论 logback 和 log42 的日志采集。

首先，添加依赖。

对于 logback：

```xml
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.10</version>
</dependency>
```

对于 log4j2：

```xml
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-api</artifactId>
    <version>2.17.1</version>
</dependency>
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
    <version>2.17.1</version>
</dependency>

<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-slf4j-impl</artifactId>
    <version>2.17.1</version>
</dependency>
```

使用 log4j2 的 slf4j 绑定实现，与 log4j2 的 slf4j 适配器(artifactiId:log4j-to-slf4j)相比，没有log4j2 消息格式化传入 slf4j 带来的性能损失。

接着，添加日志配置。

对于 logback：

在 resources 文件夹下添加 logback.xml

```xml:logback.xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration debug="true">
    <appender name="mqAppender1" class="org.apache.rocketmq.logappender.logback.RocketmqLogbackAppender">
        <tag>logbackTag</tag>
        <topic>logTopic</topic>
        <producerGroup>logGroup</producerGroup>
        <nameServerAddress>10.119.6.210:9876</nameServerAddress>
        <layout>
            <pattern>%date %p %t - %m%n</pattern>
        </layout>
    </appender>

    <appender name="mqAsyncAppender1" class="ch.qos.logback.classic.AsyncAppender">
        <queueSize>1024</queueSize>
        <discardingThreshold>80</discardingThreshold>
        <maxFlushTime>2000</maxFlushTime>
        <neverBlock>true</neverBlock>
        <appender-ref ref="mqAppender1"/>
    </appender>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="debug">
        <appender-ref ref="STDOUT" />
        <appender-ref ref="mqAsyncAppender1"/>
    </root>
</configuration>
```

对于 log42：

添加 log4j2.xml

```xml:log4j2.xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="error">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n" />
        </Console>
        <RocketMQ name="rocketmqAppender" producerGroup="logGroup" nameServerAddress="10.119.6.210:9876"
                  topic="logTopic" tag="log4j2Tag">
            <PatternLayout pattern="%date %p %t - %m%n"/>
        </RocketMQ>
        <Async name="mqAsyncAppender1">
            <AppenderRef ref="rocketmqAppender"/>
        </Async>
    </Appenders>
    <Loggers>
        <Root level="DEBUG">
            <AppenderRef ref="Console" />
            <AppenderRef ref="mqAsyncAppender1" />
        </Root>
    </Loggers>
</Configuration>
```
最后，针对 sl4j-api 的接口编写程序。

生产者例程：

```java:Producer.java
public class Producer {
    private static final Logger log = LoggerFactory.getLogger(Producer.class);

    public static void main(String[] args) throws Exception {
        DefaultMQProducer producer = new DefaultMQProducer("logappenderproducer");

        producer.setNamesrvAddr("10.119.6.210:9876");

        producer.start();

        for (int i = 0; i < 10; i++) {
            Message msg = new Message("TopicTest" ,
                    "TagA",
                    ("Hello RocketMQ " + i).getBytes(RemotingHelper.DEFAULT_CHARSET)
            );

            SendResult sendResult = producer.send(msg);
            log.debug(sendResult.toString());
        }

        producer.shutdown();
    }
}
```

消费者例程：

```java:Consumer.java
public class Consumer {
    private static final Logger log = LoggerFactory.getLogger(Consumer.class);

    public static void main(String[] args) throws MQClientException {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("logappenderconsumer");

        consumer.setNamesrvAddr("10.119.6.210:9876");

        consumer.subscribe("TopicTest", "*");

        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
                log.debug("Receive New Messages: {}", msgs);
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });

        consumer.start();

        log.debug("Consumer Started.");
    }
}
```

运行二者，可以在 rocketmq-dashboard 中根据主题 logTopic，查找消息日志，具有标签 logbackTag，log4j2Tag。