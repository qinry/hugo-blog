---
title: "Mybatis-Spring 快速开始"
date: 2021-11-10T07:07:29+08:00
description: "Mybatis-Spring 快速开始"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- mybatis
- spring
- gradle
- orm
categories:
- java
---

## 创建Gradle项目

使用 IDEA 创建一个初始的Gradle项目

编写项目配置和项目构建脚本

```gradle:settings.gradle
rootProject.name = 'mybatis-spring-sample'
```

```gradle:build.gradle
plugins {
    id 'java'
}

group 'io.github.qinry'
version '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework:spring-context:5.3.9'
    implementation 'org.springframework:spring-jdbc:5.3.9'
    implementation 'com.zaxxer:HikariCP:4.0.3'
    implementation 'org.mybatis:mybatis:3.5.6'
    implementation 'org.mybatis:mybatis-spring:2.0.6'
    implementation 'ch.qos.logback:logback-classic:1.2.6'
    runtimeOnly 'mysql:mysql-connector-java:8.0.27'
    testImplementation 'org.springframework:spring-test:5.3.9'
    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.8.1'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine:5.8.1'
}

test {
    useJUnitPlatform()
}


jar {
    archiveFileName = 'mybatis-spring-sample.jar'
}
```

引入mybatis-spring相关的依赖：
* spring相关：`spring-context`、`spring-jdbc` 和 `spring-test`
* mybatis相关：`mybatis-spring`、`mybatis`
* 连接池：`HikariCP`
* 数据库驱动：`mysql-connector-java`
* 日志：`logback`
* 单元测试：`junit-jupiter-api` 和 `junit-jupiter-engine`

## 配置 Spring IoC 容器元数据

编写applicationContext.xml，用于定义 IoC 容器实例化、组装和管理的对象及其依赖关系

```xml:applicationContext.xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="
       http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       https://www.springframework.org/schema/context/spring-context.xsd">

    <context:property-placeholder location="classpath:/jdbc.properties"  />
    <bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource">
        <property name="jdbcUrl" value="${url}" />
        <property name="username" value="${username}"/>
        <property name="password" value="${password}" />
        <property name="driverClassName" value="${driver}" />
    </bean>

    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource" />
    </bean>

    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <property name="configLocation" value="classpath:mybatis/mybatis-config.xml"/>
        <property name="mapperLocations" value="classpath*:mybatis/mappers/*.xml"/>
    </bean>

    <bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">
        <constructor-arg index="0" ref="sqlSessionFactory"/>
    </bean>

    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="basePackage" value="io.github.qinry.mapper" />
        <property name="sqlSessionTemplateBeanName" value="sqlSession"/>
    </bean>
</beans>
```

这里是使用解析属性占位符的配置，`<context:property-placeholder />`，可以使用外部属性注入到这个xml配置。

applicationContext.xml可以引入jdbc.propertis的属性。

```
driver=com.mysql.cj.jdbc.Driver
url=jdbc:mysql://localhost:3306/testdb?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
username=springuser
password=123456
```

jdbc.propertis用于配置数据源所需的属性，使用`${...}`引用外部属性

这里要配置数据源、事务管理器，还有与mybatis相关的`SqlSessionFactory`、`SqlSessionTemplate` 以及` MapperScannerConfigurer`。事务管理器和`SqlSessionFactory`都依赖数据源，而`SqlSessionTemplate`依赖`SqlSessionFactory`。

![images](../../../../../images/posts/2021/11/mybatis-spring-crash/1.png)

SqlSessionFactoryBean的属性还有两个经常要配置：`configLocation`和`mapperLocations`。分别指定 mybatis xml配置的位置和 xml 映射文件的位置（使用ant风格的路径指定多个mapper xml文件）。

Spring IoC会帮我们创建 mapper和SqlSession，无须我们自己创建，使用`@Autowired`这个注解装配就可使用。

mybatis xml配置如下：

```xml:mybatis/mybatis-config.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <setting name="mapUnderscoreToCamelCase" value="true"/>
        <setting name="lazyLoadingEnabled" value="true"/>
        <setting name="aggressiveLazyLoading" value="false" />
        <setting name="logImpl" value="SLF4J"/>
    </settings>
    <typeAliases>
        <package name="io.github.qinry.pojo"/>
    </typeAliases>
</configuration>
```

mybatis xml配置一般常常只要配置 `settings` 和 `typeAliases`即可。

因为mybatis-spring提供了环境的配置，所以这里再配置环境会被忽略。

映射文件的路径也不再用`mappers`标签设置，因为 `SqlSessionFactoryBean` 的 `mapLocations` 是更好的选择。

这里使用了日志框架logback，它实现slf4j的接口，所以配置的值为`SLF4J`。

编写logback日志输出配置

```logback.xml
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <!-- encoders are assigned the type
             ch.qos.logback.classic.encoder.PatternLayoutEncoder by default -->
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    <logger name="io.github.qinry.mapper" level="trace"/>
    <root level="error">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
```

MapperScannerConfigurer这个组件用于扫描发现映射器接口。它属性`basePackage`指定接口所在的包。而 `SqlSessionTemplate` 是 `SqlSession` 接口的实现类，由 `mybatis-spring` 提供，它是线程安全的，它也负责将 `MyBatis` 的异常翻译成 `Spring` 中的 `DataAccessExceptions。`

## 创建数据库

在mysql建库`testdb`还有创建两张表。

```sql
create table student(
    id bigint not null auto_increment,
    stu_name varchar(32) default null,
    grade_id bigint default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;
```
```sql
create table grade(
    id bigint not null auto_increment,
    grade_name varchar(32) default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;
```

测试数据：
为grade表插入三条数据
```sql
insert into grade(grade_name) values
('一年级'),
('二年级'),
('三年级');
```
为student表插入三条数据
```sql
insert into student(stu_name, grade_id) values
('王二', 1),
('张三', 2),
('李四', 3);
```

## 编写pojo

编写Student实体

```java:Student.java
public class Student implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private String stuName;
    private Long gradeId;

    private Grade grade;

    // 构造器、setter、getter和toString方法省略
}
```

编写Grade实体

```java:Grade.java
public class Grade implements Serializable {
    private static final long serialVersionUID = 2L;

    private Long id;
    private String gradeName;
    private List<Student> students;
    // 构造器、setter、getter和toString方法省略
}
```

## 编写映射器接口

编写StudentMapper

```java:StudentMapper.java
public interface StudentMapper {
    List<Student> findAll();
}
```

## 编写xml映射文件

编写StudentMapper.xml

```xml:StudentMapper.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="io.github.qinry.mapper.StudentMapper">
    <cache></cache>
    <sql id="column_list">
        id,stu_name,grade_id
    </sql>
    <resultMap id="studentResult" type="Student">
        <id property="id" column="stu_id"/>
        <result property="stuName" column="stu_name" />
        <result property="gradeId" column="grade_id"></result>
        <association property="grade" column="grade_id" resultMap="gradeResult"/>
    </resultMap>
    <resultMap id="gradeResult" type="Grade">
        <id property="id" column="grade_id" />
        <result property="gradeName" column="grade_name" />
    </resultMap>
    <select id="findAll" resultMap="studentResult">
        select
        s.id as stu_id,
        s.stu_name as stu_name,
        g.id as grade_id,
        g.grade_name as grade_name
        from student s
        left outer join grade g on s.grade_id = g.id
    </select>
</mapper>
```

## 编写junit5测试整合spring5

```java:StudentMapperTests.java
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = "classpath:/applicationContext.xml")
public class StudentMapperTests {
    @Autowired
    private SqlSession sqlSession;

    @Autowired
    private StudentMapper studentMapper;

    @Test
    void findAll() throws IOException {
        List<Student> students = studentMapper.findAll();
        System.out.println(students.size());
        students.stream().map(Student::getGrade).forEach(System.out::println);
    }
}
```

测试类使用 `SpringExtension.class` 扩展，测试用的 spring 上下文配置为`applicationContext.xml`。`@Autowired`装配`StudentMapper`可以直接使用。

输出：
```
10:59:57.991 [Test worker] DEBUG io.github.qinry.mapper.StudentMapper - Cache Hit Ratio [io.github.qinry.mapper.StudentMapper]: 0.0
10:59:58.806 [Test worker] DEBUG i.g.q.mapper.StudentMapper.findAll - ==>  Preparing: select s.id as stu_id, s.stu_name as stu_name, g.id as grade_id, g.grade_name as grade_name from student s left outer join grade g on s.grade_id = g.id
10:59:58.878 [Test worker] DEBUG i.g.q.mapper.StudentMapper.findAll - ==> Parameters: 
10:59:58.972 [Test worker] TRACE i.g.q.mapper.StudentMapper.findAll - <==    Columns: stu_id, stu_name, grade_id, grade_name
10:59:58.973 [Test worker] TRACE i.g.q.mapper.StudentMapper.findAll - <==        Row: 1, 王二, 1, 一年级
10:59:58.976 [Test worker] TRACE i.g.q.mapper.StudentMapper.findAll - <==        Row: 2, 张三, 2, 二年级
10:59:58.977 [Test worker] TRACE i.g.q.mapper.StudentMapper.findAll - <==        Row: 3, 李四, 3, 三年级
10:59:58.978 [Test worker] DEBUG i.g.q.mapper.StudentMapper.findAll - <==      Total: 3
3
Grade{id=1, gradeName='一年级', students=null}
Grade{id=2, gradeName='二年级', students=null}
Grade{id=3, gradeName='三年级', students=null}
```