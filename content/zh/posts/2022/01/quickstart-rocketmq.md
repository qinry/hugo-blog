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

### 1.1 核心概念：

<img src="../../../../images/posts/2022/01/quickstart-rocketmq/1.png">

#### 1.1.1 消息模型（Message Model）

RocketMQ主要由 Producer、Broker、Consumer 三部分组成，其中Producer 负责生产消息，Consumer 负责消费消息，Broker 负责存储消息。

#### 1.1.2 消息生产者（Producer）

提供同步发送、异步发送、顺序发送、单向发送。同步和异步方式均需要Broker返回确认信息，单向发送不需要。

#### 1.1.3 消息消费者（Consumer）

一般是后台系统负责异步消费。从用户应用的角度而言提供了两种消费形式：拉取式消费、推动式消费。

拉取式消费：通常主动调用Consumer的拉消息方法从Broker服务器拉消息、主动权由应用控制。

推动式消费：Broker收到数据后会主动推送给消费端，该消费模式一般实时性较高。

#### 1.1.4 代理服务器（Broker Server）

消息中转角色，负责存储消息、转发消息。存储消息相关的元数据，包括消费者组、消费进度偏移和主题和队列消息等。

#### 1.1.5 名字服务器（Name Server）

名称服务充当路由消息的提供者。生产者或消费者能够通过名字服务查找各主题相应的Broker IP列表。多个Namesrv实例组成集群，但相互独立，没有信息交换。

#### 1.1.6 主题（Topic）

表示一类消息的集合，每个主题包含若干条消息，每条消息只能属于一个主题，是RocketMQ进行消息订阅的基本单位。

#### 1.1.7 生产者组（Producer Group）和消费者组（Consumer Group）

生产者组：同一类Producer的集合，这类Producer发送同一类消息且发送逻辑一致。

消费者组：同一类Consumer的集合，这类Consumer通常消费同一类消息且消费逻辑一致。

> 注意：消费者组的消费者实例必须订阅完全相同的Topic。

消费模式：

* 集群消费（Clustering）：相同Consumer Group的每个Consumer实例平均分摊消息。

* 广播消费（Broadcasting）：相同Consumer Group的每个Consumer实例都接收全量的消息。

#### 1.1.8 消息

消息系统所传输信息的物理载体，生产和消费数据的最小单位，每条消息必须属于一个主题。RocketMQ中每个消息拥有唯一的Message ID，且可以携带具有业务标识的Key。系统提供了通过Message ID和Key查询消息的功能。

#### 1.1.9 标签

为消息设置的标志，用于同一主题下区分不同类型的消息。来自同一业务单元的消息，可以根据不同业务目的在同一主题下设置不同标签。标签能够有效地保持代码的清晰度和连贯性，并优化RocketMQ提供的查询系统。消费者可以根据Tag实现对不同子主题的不同消费逻辑，实现更好的扩展性。

#### 1.1.10 消息顺序

当使用 DefaultMQPushConsumer

* 顺序：消费消息的顺序与发送消息的顺序一致，对于同一个消息队列而言。

* 并发：并发消费消息，顺序自然无序

了解更多，见 [https://github.com/apache/rocketmq/tree/master/docs/cn](https://github.com/apache/rocketmq/tree/master/docs/cn)

### 1.2 需要了解

1. 如果主题在**三天内**发送消息，消费者从服务器的**第一条**开始消费。如果是**三天前**，则从消息队列**队尾**开始消费。如果消费者重新启动，开始从**上次**消费位置开始消费。

2. 集群消费模式，是每个消费者均摊全部大的消息，他的逻辑代码会返回 Action.ReconsumerLater ，或 NULL ，或异常。如果消息消费失败，最多尝试16次，之后会丢弃。而广播模式广播确保消息至少被消费1次，不提供重发。

3. 如果消息消费失败，可通过时间查询某段时间的消息；还可以通过Topic，也可以是Message ID 准确查询。使用 Topic 和 Message Key 准确查询具有相同 Message Key 的一类消息。

## 二、搭建 Rocket MQ

本文在 Linux 下搭建 Rocket MQ。

前提：
* CentOS Linux release 7.9.2009
* Docker 20.10.12
* Maven 3.8.4

### 2.1 用 Docker 安装 Rockect MQ

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

查看集群标签页下的默认集群中一个**分片地址**是否与节点的地址一致，而非 172.17.0.1。

rocketmq-dashboard 还提供 docker 镜像：

```bash
docker run -d --name rocketmq-dashboard -e "JAVA_OPTS=-Drocketmq.namesrv.addr=127.0.0.1:9876" -p 8080:8080 -t apacherocketmq/rocketmq-dashboard:latest
```

修改对应 name server 的 ip 地址和端口即可。还可以使用数据卷提供自己的 application.properties 来替换默认的配置。

## 三、演示官网的简单示例

演示前，需要到 rocketmq-dashboard的网页，在主题标签页下添加所需的主题(topic)，例如：“TopicTest”，结果如下：

<img src="../../../../images/posts/2022/01/quickstart-rocketmq/2.png">

接着是创建官网的simple example。

比如，创建单模块的maven项目，groupId 为 `com.example.rocketmqsimpleexample`，artifactId 为 `rocketmq-simple-example`。

再接着，添加依赖

```xml
<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-client</artifactId>
    <version>4.5.0</version>
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

```java:AsyncProducer.java
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

```java:OnewayProducer.java
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

使用前确保 broker.conf 中设置 `enablePropertyFilter=true`，[见这里](#21-用-docker-安装-rockect-mq)

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

## 八、OpenMessaging

OpenMessaging 意在分布式异构消息队列的、平台无关、语言无关的消息队列规范，提供一个通用的框架。而且它面向云，简单，灵活。

类似于为数据库提供的 SPI，即 JDBC，各个数据厂商提供自己 Driver 实现，它面向接口编程，只要提供的实现不一样，就能访问不同数据库。那么提供不同的消息队列厂商的 openmessaging 实现，根据openmessaging的 API 就能使用不同的消息队列产品。

使用 OpenMessaging 实现的 Rocket MQ 客户端。

首先，引入依赖到pom.xml

```xml
<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-client</artifactId>
    <version>4.5.0</version>
</dependency>

<dependency>
    <groupId>org.apache.rocketmq</groupId>
    <artifactId>rocketmq-openmessaging</artifactId>
    <version>4.5.0</version>
</dependency>
```

其次，编写生产者例程，和消费者例程。消费者有pull和push两种。pull 消费者通过轮询拉取消息。而push 消费者通过监听器监听消息。

> 注意：运行程序时都要设置环境变量 OMS_RMQ_DIRECT_NAME_SRV=true，否则客户端跳过设置 Name Server 地址。

生产者例程：

```java:OMSProducer.java
public class OMSProducer {
    public static void main(String[] args) {
        final MessagingAccessPoint messagingAccessPoint =
                OMS.getMessagingAccessPoint("oms:rocketmq://10.119.6.210:9876/default:default");

        final Producer producer = messagingAccessPoint.createProducer();

        messagingAccessPoint.startup();
        System.out.printf("MessagingAccessPoint startup OK%n");

        producer.startup();
        System.out.printf("Producer startup OK%n");

        {
            Message message = producer.createBytesMessage("OMS_HELLO_TOPIC", "OMS_HELLO_BODY".getBytes(Charset.forName("UTF-8")));
            SendResult sendResult = producer.send(message);
            //final Void aVoid = result.get(3000L);
            System.out.printf("Send sync message OK, msgId: %s%n", sendResult.messageId());
        }

        final CountDownLatch countDownLatch = new CountDownLatch(1);
        {
            final Future<SendResult> result = producer.sendAsync(producer.createBytesMessage("OMS_HELLO_TOPIC", "OMS_HELLO_BODY".getBytes(Charset.forName("UTF-8"))));
            result.addListener(new FutureListener<SendResult>() {
                @Override
                public void operationComplete(Future<SendResult> future) {
                    if (future.getThrowable() != null) {
                        System.out.printf("Send async message Failed, error: %s%n", future.getThrowable().getMessage());
                    } else {
                        System.out.printf("Send async message OK, msgId: %s%n", future.get().messageId());
                    }
                    countDownLatch.countDown();
                }
            });
        }

        {
            producer.sendOneway(producer.createBytesMessage("OMS_HELLO_TOPIC", "OMS_HELLO_BODY".getBytes(Charset.forName("UTF-8"))));
            System.out.printf("Send oneway message OK%n");
        }

        try {
            countDownLatch.await();
            Thread.sleep(500); // Wait some time for one-way delivery.
        } catch (InterruptedException ignore) {
        }

        producer.shutdown();
    }
}
```

Pull 消费者：

```java:OMSPullConsumer.java
public class OMSPullConsumer {
    public static void main(String[] args) {
        final MessagingAccessPoint messagingAccessPoint =
                OMS.getMessagingAccessPoint("oms:rocketmq://10.119.6.210:9876/default:default");

        messagingAccessPoint.startup();

        final Producer producer = messagingAccessPoint.createProducer();

        final PullConsumer consumer = messagingAccessPoint.createPullConsumer(
                OMS.newKeyValue().put(OMSBuiltinKeys.CONSUMER_ID, "OMS_CONSUMER"));

        messagingAccessPoint.startup();
        System.out.printf("MessagingAccessPoint startup OK%n");

        final String queueName = "TopicTest";

        producer.startup();
        Message msg = producer.createBytesMessage(queueName, "Hello Open Messaging".getBytes());
        SendResult sendResult = producer.send(msg);
        System.out.printf("Send Message OK. MsgId: %s%n", sendResult.messageId());
        producer.shutdown();

        consumer.attachQueue(queueName);

        consumer.startup();
        System.out.printf("Consumer startup OK%n");

        // Keep running until we find the one that has just been sent
        boolean stop = false;
        while (!stop) {
            Message message = consumer.receive();
            if (message != null) {
                String msgId = message.sysHeaders().getString(Message.BuiltinKeys.MESSAGE_ID);
                System.out.printf("Received one message: %s%n", msgId);
                consumer.ack(msgId);

                if (!stop) {
                    stop = msgId.equalsIgnoreCase(sendResult.messageId());
                }

            } else {
                System.out.printf("Return without any message%n");
            }
        }

        consumer.shutdown();
        messagingAccessPoint.shutdown();
    }
}
```

Push 消费者：

```java:OMSPushConsumer.java
public class OMSPushConsumer {
    public static void main(String[] args) {
        final MessagingAccessPoint messagingAccessPoint = OMS
                .getMessagingAccessPoint("oms:rocketmq://10.119.6.210:9876/default:default");

        final PushConsumer consumer = messagingAccessPoint.
                createPushConsumer(OMS.newKeyValue().put(OMSBuiltinKeys.CONSUMER_ID, "OMS_CONSUMER"));

        messagingAccessPoint.startup();
        System.out.printf("MessagingAccessPoint startup OK%n");

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            consumer.shutdown();
            messagingAccessPoint.shutdown();
        }));

        consumer.attachQueue("OMS_HELLO_TOPIC", new MessageListener() {
            @Override
            public void onReceived(Message message, Context context) {
                System.out.printf("Received one message: %s%n", message.sysHeaders().getString(Message.BuiltinKeys.MESSAGE_ID));
                context.ack();
            }
        });

        consumer.startup();
        System.out.printf("Consumer startup OK%n");
    }
}
```

## 九、事务消息

它可以被认为是一个两阶段的提交消息实现，以确保分布式系统的最终一致性。事务性消息确保本地事务的执行和消息的发送可以原子地执行。

使用限制：

(1)没有调度和批处理支持。

(2) 为避免单条消息被检查次数过多，导致半队列消息堆积，我们默认将单条消息的检查次数限制为15次，但用户可以通过更改“transactionCheckMax”来更改此限制”参数在broker的配置中，如果一条消息的检查次数超过“transactionCheckMax”次，broker默认会丢弃这条消息，同时打印错误日志。用户可以通过重写“AbstractTransactionCheckListener”类来改变这种行为。

(3) 事务消息将在一定时间后检查，该时间由代理配置中的参数“transactionTimeout”确定。并且用户也可以在发送事务消息时通过设置用户属性“CHECK_IMMUNITY_TIME_IN_SECONDS”来改变这个限制，这个参数优先于“transactionMsgTimeout”参数。

(4) 一个事务性消息可能会被检查或消费不止一次。

(5) 提交给用户目标主题的消息reput可能会失败。目前，它取决于日志记录。高可用是由 RocketMQ 本身的高可用机制来保证的。如果要保证事务消息不丢失，保证事务完整性，推荐使用同步双写机制。

(6) 事务性消息的生产者 ID 不能与其他类型消息的生产者 ID 共享。与其他类型的消息不同，事务性消息允许向后查询。MQ 服务器通过其生产者 ID 查询客户端。

事务性消息有三种状态：

(1) TransactionStatus.CommitTransaction：提交事务，表示允许消费者消费该消息。

(2) TransactionStatus.RollbackTransaction：回滚事务，表示该消息将被删除，不允许消费。

(3) TransactionStatus.Unknown：中间状态，表示需要MQ回查才能确定状态。

事务性消息生产者例程：

设置自定义线程池来处理检查请求。

```java:TransactionProducer.java
public class TransactionProducer {
    public static void main(String[] args) throws MQClientException, InterruptedException {
        TransactionListener transactionListener = new TransactionListenerImpl();
        TransactionMQProducer producer = new TransactionMQProducer("transactionproducer");
        ExecutorService executorService =
                new ThreadPoolExecutor(2,
                5,
                100,
                TimeUnit.SECONDS,
                new ArrayBlockingQueue<Runnable>(2000),
                new ThreadFactory() {
            @Override
            public Thread newThread(Runnable r) {
                Thread thread = new Thread(r);
                thread.setName("client-transaction-msg-check-thread");
                return thread;
            }
        });

        producer.setNamesrvAddr("10.119.6.210:9876");
        producer.setExecutorService(executorService);
        producer.setTransactionListener(transactionListener);
        // 开启事务
        producer.start();

        String[] tags = new String[] {"TagA", "TagB", "TagC", "TagD", "TagE"};
        for (int i = 0; i < 10; i++) {
            try {
                Message msg =
                        new Message("TopicTest1234", tags[i % tags.length], "KEY" + i,
                                ("Hello RocketMQ " + i).getBytes(RemotingHelper.DEFAULT_CHARSET));
                SendResult sendResult = producer.sendMessageInTransaction(msg, null);
                System.out.printf("%s%n", sendResult);

                Thread.sleep(10);
            } catch (MQClientException | UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }

        Thread.sleep(1000);
        // 结束事务
        producer.shutdown();
    }
}
```

事务监听器例程：

```java:TransactionListenerImpl.java
public class TransactionListenerImpl implements TransactionListener {
    private AtomicInteger transactionIndex = new AtomicInteger(0);

    private ConcurrentHashMap<String, Integer> localTrans = new ConcurrentHashMap<>();

    @Override
    public LocalTransactionState executeLocalTransaction(Message msg, Object arg) {
        int value = transactionIndex.getAndIncrement();
        int status = value % 3;
        localTrans.put(msg.getTransactionId(), status);
        return LocalTransactionState.UNKNOW;
    }

    @Override
    public LocalTransactionState checkLocalTransaction(MessageExt msg) {
        Integer status = localTrans.get(msg.getTransactionId());
        if (null != status) {
            switch (status) {
                case 0:
                    return LocalTransactionState.UNKNOW;
                case 1:
                    return LocalTransactionState.COMMIT_MESSAGE;
                case 2:
                    return LocalTransactionState.ROLLBACK_MESSAGE;
                default:
                    return LocalTransactionState.COMMIT_MESSAGE;
            }
        }
        return LocalTransactionState.COMMIT_MESSAGE;
    }
}
```

## 十、总结

Rocket MQ 重点在它的核心概念，生产者和消费者由应用代码完成消息发送和接受。

而broker 也就是消息代理，负责转发和存储，常常是异步消费的情况较多。

消费者和生产者通过组名进行分类。一般一个生产组只要一个生产者实例就够了。而且同一个消费组的消费者实例必须有相同的主题订阅。消息大致由主题、标签和消息体和其他键值对属性构成。

本文演示单节点 Rocket MQ 实例的 Docker 容器搭建，以及 web 控制台的搭建（rocketmq-dashboard）。还有常用功能快速上手，比如同步、异步和单向发送，广播消息，消息过滤，消息日志，事务消息，延迟调度消息，普通顺序消息，拉取和推送消息消费，以及消息批处理。



## 参考

* [Rocket MQ 官网](https://rocketmq.apache.org/)
* [Rocket MQ Github 仓库](https://github.com/apache/rocketmq)
* [Rocketmq-Docker Github 仓库](https://github.com/apache/rocketmq-docker)
* [Rocketmq-Dashboard Github 仓库](https://github.com/apache/rocketmq-dashboard)