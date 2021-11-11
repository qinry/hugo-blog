---
title: "Mybatis-Spring-Boot-Starter 快速开始"
date: 2021-11-11T10:00:16+08:00
description: "Mybatis-Spring-Boot-Starter 快速开始"
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

编写build.gradle

```gradle:build.gradle
plugins {
    id 'org.springframework.boot' version '2.5.6' apply false
    id 'io.spring.dependency-management' version '1.0.11.RELEASE'
    id 'java'
}

group 'io.github.qinry'
version '1.0-SNAPSHOT'
sourceCompatibility = JavaVersion.VERSION_11

repositories {
    mavenCentral()
}

dependencyManagement {
    imports {
        mavenBom org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES
    }
}

dependencies {
    implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:2.2.0'
    runtimeOnly 'mysql:mysql-connector-java'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}

jar {
    archiveFileName = 'mybatis-spring-boot-starter-sample.jar'
}
```

这里创建了的是spring boot 库项目，用来提供其他项目来使用。注意 Spring Boot Plugin ，它是用来创建可执行的 jar，这里没有 main() 自然不需要，禁用掉。因此有这样的配置：

```gradle
plugins {
    id 'org.springframework.boot' version '2.5.6' apply false
}
```

虽然不使用Spring Boot Plugin 提供的 bootJar 任务创建可执行的 jar。但是需要Spring Boot 的依赖管理，这样引入 Spring Boot 起步依赖就不需要声明版本号了。如下配置：

```gradle 
plugins {
    id 'io.spring.dependency-management' version '1.0.11.RELEASE'
}

dependencyManagement {
    imports {
        mavenBom org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES
    }
}
```
编写settings.gradle

```gradle:settings.gradle
rootProject.name = 'mybatis-spring-boot-starter-sample'
```

## 设置属性

Spring Boot 起步依赖提供了大量的自动配置类，项目启动时会加载它们，所以我们减少了甚至不用配置程序，体现了它的理念——“约定大与配置”。当然可编写 `application.properties` 文件，此文件可用来自定义设置程序的属性来修改程序的行为。

```
spring.datasource.url=jdbc:mysql://localhost:3306/testdb?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.username=springuser
spring.datasource.password=123456

mybatis.config-location=classpath:mybatis-config.

loggin.level.com.owk.mapper=trace
```

设置数据源，mybatis 配置文件位置还有日志输出的等级。

##  编写mybatis xml配置文件

```xml:mybatis-config.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <setting name="mapUnderscoreToCamelCase" value="true"/>
        <setting name="lazyLoadingEnabled" value="true"/>
        <setting name="aggressiveLazyLoading" value="false" />
    </settings>
    <typeAliases>
        <package name="com.owk.pojo"/>
    </typeAliases>
    <mappers>
        <mapper resource="com/owk/mapper/StudentMapper.xml"/>
        <mapper resource="com/owk/mapper/GradeMapper.xml"/>
    </mappers>
</configuration>
```

## 编写 Spring IoC 容器的配置元数据

```java:com/owk/MybatisConfig.java
@SpringBootConfiguration
@EnableAutoConfiguration
@MapperScan("com.owk.mapper")
public class MybatisConfig {
}
```

这个 Java 类用了注解 `@SpringBootConfiguration` 声明，说明它是基于 Java 配置的 Spring Bean 配置。

注解 `@EnableAutoConfiguration` 启动起步依赖帮我们写好的默认配置，在 IoC 容器运行时会加载一系列自动配置类，例如：`MybatisAutoConfiguration`等，这些自动配置类会构建一些 Spring IoC 容器实例化、装配和管理的 Bean 实例，Bean 之间的依赖注入也有容器完成。当然我们也可以写我们自己 Bean 来替换默认的 Bean，大多数时不需要我们自己写。

对于集合了 Mybatis 的 Spring Boot 最好使用 `@MapperScan` 此注解，识别指定包下的映射器接口。

## 创建数据库

创建数据库 testdb 并建表插入数据

```sql
create table student(
    id bigint not null auto_increment,
    stu_name varchar(32) default null,
    grade_id bigint default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;

create table grade(
    id bigint not null auto_increment,
    grade_name varchar(32) default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;

insert into student(stu_name, grade_id) values
('王二', 1),
('张三', 2),
('李四', 3);

insert into grade(grade_name) values
('一年级'),
('二年级'),
('三年级');
```

## 编写pojo实体

Student实体

```java:com/owk/pojo/Student.java
public class Student implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private String stuName;
    private Long gradeId;

    private Grade grade;
    // 省略 setter getter 和 toString 方法
}
```

Grade实体

```java:com/owk/pojo/Grade.java
public class Grade implements Serializable {
    private static final long serialVersionUID = 2L;

    private Long id;
    private String gradeName;
    private List<Student> students;
    // 省略 setter getter 和 toString 方法
}
```

## 编写 xml 映射文件

```xml:StudentMapper.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.owk.mapper.StudentMapper">
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

## 编写映射器接口

```java:com/owk/mapper/StudentMapper.java
@Mapper
public interface StudentMapper {
    List<Student> findAll();
}
```

如果之前的 `MybatisConfig` 没使用注解 `@MapperScan` 就会在这个配置类所在基础包下自动搜索用 `@Mapper` 标记的映射器接口。

如果使用 `@MapperScan`，直接扫描指定包下的映射器接口，就可以不需要用 `@Mapper` 标记接口了。`@MapperScan` 注解还有属性 `annotationClass` 和 `markerInterface`。`annotationClass`找出指定注解的映射器接口；`markerInterface`找出指定标记父接口的映射器。

## 编写测试用例

```java:com/owk/mapper/StudentMapperTests.java
@SpringBootTest
@ContextConfiguration(classes = {MybatisConfig.class})
public class StudentMapperTests {

    @Autowired
    private  StudentMapper studentMapper;


    @Test
    void findAll() {
        List<Student> students = studentMapper.findAll();
        System.out.println("size:"+students.size());
        System.out.println("students:");
        students.forEach(System.out::println);
        System.out.println("grades:");
        students.stream().map(Student::getGrade).forEach(System.out::println);
    }
}
```

输出部分信息：

```
021-11-11 13:03:07.065 DEBUG 61145 --- [    Test worker] com.owk.mapper.StudentMapper.findAll     : ==>  Preparing: select s.id as stu_id, s.stu_name as stu_name, g.id as grade_id, g.grade_name as grade_name from student s left outer join grade g on s.grade_id = g.id
2021-11-11 13:03:07.192 DEBUG 61145 --- [    Test worker] com.owk.mapper.StudentMapper.findAll     : ==> Parameters: 
2021-11-11 13:03:07.309 TRACE 61145 --- [    Test worker] com.owk.mapper.StudentMapper.findAll     : <==    Columns: stu_id, stu_name, grade_id, grade_name
2021-11-11 13:03:07.310 TRACE 61145 --- [    Test worker] com.owk.mapper.StudentMapper.findAll     : <==        Row: 1, 王二, 1, 一年级
2021-11-11 13:03:07.313 TRACE 61145 --- [    Test worker] com.owk.mapper.StudentMapper.findAll     : <==        Row: 2, 张三, 2, 二年级
2021-11-11 13:03:07.314 TRACE 61145 --- [    Test worker] com.owk.mapper.StudentMapper.findAll     : <==        Row: 3, 李四, 3, 三年级
2021-11-11 13:03:07.318 DEBUG 61145 --- [    Test worker] com.owk.mapper.StudentMapper.findAll     : <==      Total: 3
size:3
students:
Student{id=1, stuName='王二', gradeId=1, grade=Grade{id=1, gradeName='一年级', students=null}}
Student{id=2, stuName='张三', gradeId=2, grade=Grade{id=2, gradeName='二年级', students=null}}
Student{id=3, stuName='李四', gradeId=3, grade=Grade{id=3, gradeName='三年级', students=null}}
grades:
Grade{id=1, gradeName='一年级', students=null}
Grade{id=2, gradeName='二年级', students=null}
Grade{id=3, gradeName='三年级', students=null}
```