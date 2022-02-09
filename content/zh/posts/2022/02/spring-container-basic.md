---
title: "Spring 容器基础"
date: 2022-02-02T10:05:33+08:00
description: "Spring 容器基础"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- spring
categories:
- java
---
 
## 一、控制反转和 Bean

Spring 框架的控制反转（IoC）容器，简称 IoC 容器。IoC 也称依赖注入（DI）。

对象仅通过构造方法参数，工厂方法参数，或对象实例的属性 setter 方法来定义依赖关系。然后在容器创建 Bean 时注入依赖项。

为什么叫控制反转呢？这与 Bean 的依赖项在类中直接构造，来控制其依赖关系的实例化的逆过程。依赖在外部实例化好，再传入 Bean 中。

什么是 Bean？Bean 由 Spring IoC 容器实例化、组装和管理的对象。Bean 和它们的依赖会在配置元数据中被容器反射。

`org.springframework.beans` 和 `org.springframework.context` 包是spring 框架的 IoC 容器基础。它使用 `BeanFactory` 接口提供配置的基础功能，能管理任何类型对象，而 `ApplicationContext` 是它的子接口，提供企业级特性功能。它易于整合 Spring AOP 特性，国际化的消息资源处理，事件发布还有应用层特定上下文，如 `WebApplicationContext` 用于 web 开发。

## 二、ApplicationContext

`org.springframework.context.ApplicationContext` 接口就能代表 Spring IoC 容器。它常用的两个实现类有：`ClassPathXmlApplication`，`AnnotationConfigApplicationContext`。第一个是基于 XML 定义配置的传统格式，第二个是基于 Java 代码定义配置的格式。XML 配置借助注解可以精简 XML。

Maven 引入依赖 `spring-context` 就可以配置 Spring IoC 容器：

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context</artifactId>
    <version>5.2.19.RELEASE</version>
</dependency>
```

### 2.1 XML 配置 Spring

基于 XML 配置元数据的基本结构如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="..." class="...">  
        <!-- 该 Bean 的依赖和配置放在这里 -->
    </bean>

    <bean id="..." class="...">
        <!-- 该 Bean 的依赖和配置放在这里 -->
    </bean>

    <!-- 更多 Bean 放在这里 -->

</beans>
```

> bean 标签里的 id 属性标识 bean 定义的唯一标识，class 属性表示 bean 定义的类型完全限定名。

以配置 Druid 数据源为例，说明 xml 配置 spring ioc 容器，

前提需要引入 druid 和 mysql-connector-java 等的依赖，还要搭建 mysql 数据库。

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid</artifactId>
    <version>1.2.8</version>
</dependency>

<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.22</version>
</dependency>

<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.20</version>
</dependency>
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.2.10</version>
</dependency>
```

编写 applicationContext.xml
```xml:applicationContext.xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="
    http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/context
    http://www.springframework.org/schema/context/spring-context.xsd" >

    <context:property-placeholder location="classpath:/jdbc.properties"/>

    <bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource" init-method="init" destroy-method="close">
        <property name="url" value="${jdbc_url}" />
        <property name="username" value="${jdbc_user}" />
        <property name="password" value="${jdbc_password}" />

        <property name="filters" value="stat" />

        <property name="maxActive" value="20" />
        <property name="initialSize" value="1" />
        <property name="maxWait" value="6000" />
        <property name="minIdle" value="1" />

        <property name="timeBetweenEvictionRunsMillis" value="60000" />
        <property name="minEvictableIdleTimeMillis" value="300000" />

        <property name="testWhileIdle" value="true" />
        <property name="testOnBorrow" value="false" />
        <property name="testOnReturn" value="false" />

        <property name="poolPreparedStatements" value="true" />
        <property name="maxOpenPreparedStatements" value="20" />
        <!-- 如果有initialSize数量较多时，打开会加快应用启动时间 -->
        <property name="asyncInit" value="true" />
    </bean>

</beans>
```

标签 `<context:property-placeholder>` 和其属性 `location` 用来注入外部运行值，这里会注入jdbc.properties 文件的属性。

标签 `<bean>` 用来定义一个 bean，id 和 class 是必填的属性，此处使用了属性的依赖注入。

编写 jdbc.properties

```
jdbc_url=jdbc:mysql://10.119.6.210:3306/testdb
jdbc_user=root
jdbc_password=root
```

获取容器中的 bean

```java
AbstractApplicationContext ctx = new ClassPathXmlApplicationContext("classpath:applicationContext.xml");
DruidDataSource dataSource = ctx.getBean("dataSource", DruidDataSource.class);
log.info(dataSource.toString());
ctx.close();
```

输出：
```
16:45:16.192 [main] DEBUG org.springframework.context.support.ClassPathXmlApplicationContext - Refreshing org.springframework.context.support.ClassPathXmlApplicationContext@156643d4
16:45:16.366 [main] DEBUG org.springframework.beans.factory.xml.XmlBeanDefinitionReader - Loaded 2 bean definitions from class path resource [applicationContext.xml]
16:45:16.397 [main] DEBUG org.springframework.beans.factory.support.DefaultListableBeanFactory - Creating shared instance of singleton bean 'org.springframework.context.support.PropertySourcesPlaceholderConfigurer#0'
16:45:16.464 [main] DEBUG org.springframework.core.env.PropertySourcesPropertyResolver - Found key 'jdbc_url' in PropertySource 'localProperties' with value of type String
16:45:16.464 [main] DEBUG org.springframework.core.env.PropertySourcesPropertyResolver - Found key 'jdbc_user' in PropertySource 'localProperties' with value of type String
16:45:16.464 [main] DEBUG org.springframework.core.env.PropertySourcesPropertyResolver - Found key 'jdbc_password' in PropertySource 'localProperties' with value of type String
16:45:16.470 [main] DEBUG org.springframework.beans.factory.support.DefaultListableBeanFactory - Creating shared instance of singleton bean 'dataSource'
16:45:16.638 [main] INFO com.alibaba.druid.pool.DruidDataSource - {dataSource-1} inited
16:45:16.651 [main] INFO org.example.Main - {
	CreateTime:"2022-02-07 16:45:16",
	ActiveCount:0,
	PoolingCount:0,
	CreateCount:0,
	DestroyCount:0,
	CloseCount:0,
	ConnectCount:0,
	Connections:[
	]
}

[
]
16:45:16.653 [main] DEBUG org.springframework.context.support.ClassPathXmlApplicationContext - Closing org.springframework.context.support.ClassPathXmlApplicationContext@156643d4, started on Mon Feb 07 16:45:16 CST 2022
16:45:16.655 [main] INFO com.alibaba.druid.pool.DruidDataSource - {dataSource-1} closing ...
16:45:16.656 [main] INFO com.alibaba.druid.pool.DruidDataSource - {dataSource-1} closed
```

### 2.2 Java 配置 Spring

基于 Java 配置其是全注解的配置，需要用到一些基本注解，如：`@Configuration`，`@Bean`。还有与组件扫描相关的注解：`@ComponentScan`，`@Component`，`@Repository`，`@Service`，`@Controller`。其中 `@Repository`，`@Service`，`@Controller` 更易于 AOP 的处理。

将之前 xml 配置修改为 Java 配置。

```java
@Configuration
@Slf4j
public class DataSourceConfig {
    @Bean
    public DruidDataSource dataSource() {
        log.info("create a new DruidDataSource object");
        DruidDataSource dataSource = new DruidDataSource();

        log.info("setting properties for DruidDataSource");
        dataSource.setMaxActive(20);
        dataSource.setInitialSize(1);
        dataSource.setMaxWait(6000);
        dataSource.setMinIdle(1);

        dataSource.setTimeBetweenEvictionRunsMillis(60000);
        dataSource.setMinEvictableIdleTimeMillis(300000);

        dataSource.setTestWhileIdle(true);
        dataSource.setTestOnBorrow(false);
        dataSource.setTestOnReturn(false);

        dataSource.setPoolPreparedStatements(true);
        dataSource.setMaxOpenPreparedStatements(20);

        dataSource.setAsyncInit(true);

        return dataSource;
    }
}
```

在获取 Bean 代码中修改如下：

```java
AbstractApplicationContext ctx = new AnnotationConfigApplicationContext(DataSourceConfig.class);
DruidDataSource dataSource = ctx.getBean("dataSource", DruidDataSource.class);
log.info(dataSource.toString());
ctx.close();
```


## 三、Bean 定义

Bean 的定义涉及 bean 实现类名；bean行为配置元素（如：作用域，生命周期回调，等等）；引用其他 Bean这称为依赖；还有一些其他的配置设置，比如连接池的大小限制或连接使用数量等

### 3.1 命名 Bean

可以为 Bean 命名别名，为 `dataSource` 起一个 `druidDataSource` 别名

```xml
<alias name="dataSource" alias="druidDataSource" />
```

或

```java
@Bean({"dataSource", "druidDataSource"})
public DruidDataSource dataSource() {
    ...
}

```

### 3.2 Bean 作用域

Bean 的作用域常见有 单例、原型。默认作用域为单例。使用单例作用域，每次使用相同共享的对象注入到其他 Bean 中。如果使用原型作用域，每次使用都克隆一个对象被引用。

### 3.3 依赖注入

### 3.4 懒实例化

### 3.5 初始化和解构回调